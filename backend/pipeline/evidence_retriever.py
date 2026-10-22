import re
import datetime
import email.utils
import xml.etree.ElementTree as ET
from urllib.parse import quote_plus
from typing import List, Dict, Any, Set
import httpx
from config import GOOGLE_FACTCHECK_API_KEY, classify_domain

STOPWORDS: Set[str] = {
    "this", "that", "with", "from", "have", "been", "were", "what", "when", "where",
    "which", "will", "would", "about", "their", "there", "they", "them", "then", "into",
    "more", "most", "also", "some", "other", "just", "very", "than", "here", "only",
    "such", "said", "each", "both", "even", "does", "done", "says", "the", "and", "for",
    "breaking", "urgent", "watch", "shocking", "video", "photo", "news", "viral", "alert",
    "claim", "claims", "claimed", "report", "reports", "reported", "today", "yesterday",
    "captures", "capture", "showing", "shows", "show", "photograph", "photographs", "picture",
    "specifically", "entire", "real-time", "real", "time", "shared", "share", "minutes"
}

DEBUNK_PATTERN = re.compile(
    r'\b(fake alert|fact check:\s*(?:no|false|fake|misleading|hoax|debunk)?|'
    r'claim (?:is|of)\s*(?:false|fake|untrue|bogus|misleading|baseless)|'
    r'not (?:declared|true|real|rank|exist|show|a photo|diwali)|never (?:declared|issued|announced)|'
    r'no,\s*(?:this|it)\s*is\s*not|no truth|refutes (?:viral|rumour|rumor|claim)|viral claim is (?:false|fake)|'
    r'debunked|hoax|is fake|is false|false claim of|no evidence to suggest|'
    r'does not show|cannot cure|cannot eliminate|cure for coronavirus is false|'
    r'real or fake)\b',
    re.IGNORECASE
)

CONFIRM_PATTERN = re.compile(
    r'\b(successfully|launches|launched|launch|announces|announced|confirmed|official|'
    r'approved|approves|rolled out|commemorates|wins|won|win|victory|defeats|defeated|beats|beaten|'
    r'achieved|inaugurated|inaugurates|soft landing|'
    r'historic (?:landing|moon landing|milestone|victory|programme|program|achievement|mission|feat)|'
    r'vaccination drive|vaccination program|eradication|all set to roll out|landing|'
    r'making history|historic moon landing|pib fact check: true|'
    r'issues|issued|orders|ordered|directs|directed|rules|ruled|grants|granted|'
    r'declares|declared|introduces|introduced|unveils|unveiled|passes|passed|'
    r'clears|cleared|cabinet|arrests|arrested|held|detains|detained|charges|charged|'
    r'clinches|clinched|qualifies|record|lead|secures|secured|lashes|batters|red alert|'
    r'cyclone|quake|earthquake|landslide|accident|killed|injured|dies|death|'
    r'reports|reported|hikes|hiked|cuts|reduces|reduced|increases|increased|scheme|relief)\b',
    re.IGNORECASE
)

class EvidenceRetriever:
    @staticmethod
    async def retrieve_for_claim(
        claim_text: str,
        client: httpx.AsyncClient,
        lang: str = "en",
    ) -> List[Dict[str, Any]]:
        """Retrieve real evidence from fact-checking tools, live news, and authoritative repositories."""
        sources: List[Dict[str, Any]] = []
        clean_query = EvidenceRetriever._clean_search_query(claim_text)
        if not clean_query:
            return []

        # Auto-detect language script if text contains Tamil or Hindi characters
        has_tamil = bool(re.search(r'[\u0B80-\u0BFF]', claim_text))
        has_hindi = bool(re.search(r'[\u0900-\u097F]', claim_text))
        effective_lang = "ta" if has_tamil else ("hi" if has_hindi else lang)

        # 1. Google Fact Check Tools API (if API key configured)
        if GOOGLE_FACTCHECK_API_KEY:
            fc_sources = await EvidenceRetriever._search_google_factcheck(clean_query, client)
            sources.extend(fc_sources)

        # 2. Live News & Incident Search via Google News RSS
        news_sources = await EvidenceRetriever._search_google_news(clean_query, effective_lang, client)
        sources.extend(news_sources)

        # 3. Targeted Fact-Check / Debunk Search via Google News RSS
        fc_news_sources = await EvidenceRetriever._search_google_news(f"{clean_query} fact check", effective_lang, client)
        sources.extend(fc_news_sources)

        # 4. Wikipedia Search (strictly filtered for substantive entity overlap)
        wiki_sources = await EvidenceRetriever._search_wikipedia(clean_query, effective_lang, client)
        sources.extend(wiki_sources)

        # 5. Filter for strict relevance to the specific incident / claim
        relevant_sources = EvidenceRetriever._filter_by_relevance(claim_text, sources)

        # 6. Deduplicate sources by URL and normalized title
        deduped = EvidenceRetriever._deduplicate_sources(relevant_sources)

        # 7. Sort: Fact-checks and Official sources first, then verified News
        deduped.sort(
            key=lambda s: (
                0 if s.get("sourceType") == "Fact-Check Report"
                else (1 if s.get("sourceType") == "Official Public Record"
                else (2 if s.get("stance") in ["contradicts", "supports"] else 3))
            )
        )

        # 8. Attach sequential source IDs
        for idx, s in enumerate(deduped):
            s["id"] = f"src_{idx + 1}"

        # Return top 4-6 most relevant sources
        return deduped[:6]

    @staticmethod
    def _clean_search_query(text: str) -> str:
        """Strip boilerplate prefixes, broadcast channel tags, and isolate substantive incident keywords."""
        cleaned = re.sub(
            r'^(?:breaking(?:\s+news)?|urgent|watch|shocking|alert|viral|fact\s+check|'
            r'sun\s+news|thanthi(?:\s+tv)?|puthiya\s+thalaimurai|polimer(?:\s+news)?|'
            r'news18(?:\s+\w+)?|ndtv|india\s+today|bbc(?:\s+news)?|daily\s+thanthi|'
            r'dinamalar|dinamani|times\s+now|republic|abp\s+news):\s*',
            '',
            text.strip(),
            flags=re.IGNORECASE
        )
        # Strip trailing attributions like "(reported by Sun News)" or "- Puthiya Thalaimurai"
        cleaned = re.sub(
            r'[\(\[\-]\s*(?:reported\s+by|via|source:?|news\s+by)\s+[\w\s]+[\)\]]?$',
            '',
            cleaned,
            flags=re.IGNORECASE
        )
        # Remove special characters but keep spaces and alphanumeric
        cleaned = re.sub(r'[^\w\s\-]', ' ', cleaned)
        words = [w.strip() for w in cleaned.split() if w.lower().strip() not in STOPWORDS and len(w.strip()) > 2]
        if not words:
            words = cleaned.split()[:8]
        return " ".join(words[:10])

    @staticmethod
    async def _search_google_factcheck(query: str, client: httpx.AsyncClient) -> List[Dict[str, Any]]:
        url = "https://factchecktools.googleapis.com/v1alpha1/claims:search"
        params = {
            "query": query,
            "key": GOOGLE_FACTCHECK_API_KEY,
            "pageSize": 5,
        }
        results = []
        try:
            resp = await client.get(url, params=params, timeout=8.0)
            if resp.status_code == 200:
                data = resp.json()
                raw_claims = data.get("claims", [])
                for fc in raw_claims:
                    claim_text = fc.get("text", "")
                    reviews = fc.get("claimReview", [])
                    for r in reviews:
                        publisher = r.get("publisher", {}).get("name", "Verified Fact-Checker")
                        title = r.get("title") or claim_text
                        source_url = r.get("url", "")
                        review_date = r.get("reviewDate", "")
                        textual_rating = (r.get("textualRating") or "").lower()

                        is_false = bool(DEBUNK_PATTERN.search(textual_rating) or DEBUNK_PATTERN.search(title))
                        is_true = bool(CONFIRM_PATTERN.search(textual_rating) or CONFIRM_PATTERN.search(title))
                        stance = "contradicts" if is_false else ("supports" if is_true else "neutral")

                        results.append({
                            "publisher": publisher,
                            "title": title,
                            "url": source_url,
                            "publishedDate": review_date[:10] if review_date else None,
                            "sourceType": "Fact-Check Report",
                            "stance": stance,
                            "summary": f"Fact-check review by {publisher}: {r.get('textualRating', 'Evaluated')}",
                        })
        except Exception:
            pass
        return results

    @staticmethod
    async def _search_google_news(query: str, lang: str, client: httpx.AsyncClient) -> List[Dict[str, Any]]:
        """Query Google News RSS for real-time incident reports and news coverage."""
        results: List[Dict[str, Any]] = []
        hl = "en-IN" if lang == "en" else (lang if lang in ["ta", "hi"] else "en-IN")
        ceid = f"IN:{hl}" if hl in ["en-IN", "ta", "hi"] else "IN:en"
        url = f"https://news.google.com/rss/search?q={quote_plus(query)}&hl={hl}&gl=IN&ceid={ceid}"
        headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) UnmaiBot/1.0"}

        try:
            resp = await client.get(url, headers=headers, follow_redirects=True, timeout=8.0)
            if resp.status_code == 200:
                root = ET.fromstring(resp.text)
                items = root.findall(".//item")[:5]
                for item in items:
                    raw_title = (item.find("title").text or "").strip()
                    link = (item.find("link").text or "").strip()
                    pub_date_raw = (item.find("pubDate").text or "").strip()

                    # Extract title and publisher (Google News format: "Headline - Publisher Name")
                    if " - " in raw_title:
                        parts = raw_title.rsplit(" - ", 1)
                        headline = parts[0].strip()
                        publisher = parts[1].strip()
                    else:
                        headline = raw_title
                        publisher = "News Media"

                    # Parse publication date to YYYY-MM-DD
                    published_date = None
                    if pub_date_raw:
                        try:
                            dt = email.utils.parsedate_to_datetime(pub_date_raw)
                            published_date = dt.strftime("%Y-%m-%d")
                        except Exception:
                            published_date = datetime.date.today().isoformat()

                    # Determine source classification based on publisher
                    source_type = classify_domain(link)
                    pub_lower = publisher.lower()
                    if any(fc in pub_lower for fc in [
                        "fact check", "factcheck", "boom", "alt news", "factly",
                        "vishvas", "snopes", "afp", "reuters fact", "thip", "quint fact"
                    ]):
                        source_type = "Fact-Check Report"
                    elif any(off in pub_lower for off in [
                        "isro", "pib", "press information bureau", "who", "rbi",
                        "ministry", "police", "government", "britannica"
                    ]):
                        source_type = "Official Public Record"
                    elif any(s in pub_lower for s in ["facebook", "twitter", "reddit", "youtube", "instagram", "tiktok"]):
                        source_type = "Social Media"
                    elif source_type == "Public Web Source":
                        source_type = "News Archive"

                    # Stance detection
                    is_debunk = bool(DEBUNK_PATTERN.search(headline))
                    is_confirm = bool(CONFIRM_PATTERN.search(headline))

                    if is_debunk:
                        stance = "contradicts"
                    elif is_confirm and source_type in ["Official Public Record", "News Archive", "Fact-Check Report"]:
                        stance = "supports"
                    else:
                        stance = "neutral"

                    results.append({
                        "publisher": publisher,
                        "title": headline,
                        "url": link,
                        "publishedDate": published_date,
                        "sourceType": source_type,
                        "stance": stance,
                        "summary": headline,
                    })
        except Exception:
            pass
        return results

    @staticmethod
    async def _search_wikipedia(query: str, lang: str, client: httpx.AsyncClient) -> List[Dict[str, Any]]:
        """Query official Wikipedia API for public encyclopedic documentation."""
        headers = {"User-Agent": "UnmaiFactChecker/1.0 (https://unmai.app; support@unmai.app)"}
        wiki_lang = lang if lang in ["en", "ta", "hi"] else "en"
        search_url = f"https://{wiki_lang}.wikipedia.org/w/api.php"
        params = {
            "action": "query",
            "list": "search",
            "srsearch": query,
            "format": "json",
            "srlimit": 3,
        }

        results = []
        try:
            resp = await client.get(search_url, params=params, headers=headers, timeout=6.0)
            if resp.status_code == 200:
                data = resp.json()
                hits = data.get("query", {}).get("search", [])
                for hit in hits:
                    title = hit.get("title", "")
                    snippet = re.sub(r'<[^>]+>', '', hit.get("snippet", "")).strip()
                    page_url = f"https://{wiki_lang}.wikipedia.org/wiki/{title.replace(' ', '_')}"
                    
                    # Wikipedia is reference/background; default stance is neutral unless debunk keyword found
                    stance = "contradicts" if DEBUNK_PATTERN.search(snippet) else "neutral"

                    results.append({
                        "publisher": f"Wikipedia ({wiki_lang.upper()})",
                        "title": title,
                        "url": page_url,
                        "publishedDate": datetime.date.today().isoformat(),
                        "sourceType": "Reference Encyclopedia",
                        "stance": stance,
                        "summary": snippet[:180] + ("..." if len(snippet) > 180 else ""),
                    })
        except Exception:
            pass
        return results

    @staticmethod
    def _filter_by_relevance(claim_text: str, sources: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Ensure every source is strictly relevant to the specific incident or claim."""
        def extract_tokens(text: str) -> Set[str]:
            tokens = [
                re.sub(r'^[^\w\u0B80-\u0BFF\u0900-\u097F]+|[^\w\u0B80-\u0BFF\u0900-\u097F]+$', '', w.lower())
                for w in text.split()
            ]
            return {w for w in tokens if len(w) >= 2 and w not in STOPWORDS}

        claim_words = extract_tokens(claim_text)
        if not claim_words:
            return sources

        # Extract specific proper noun entities from claim (e.g., India, Diwali, NASA, ISRO)
        claim_entities = {
            w.lower()
            for w in re.findall(r'\b[A-Z][a-zA-Z0-9]{2,}\b', claim_text)
            if w.lower() not in STOPWORDS
        }

        relevant: List[Dict[str, Any]] = []
        for s in sources:
            source_text = f"{s.get('title', '')} {s.get('summary', '')}"
            source_words = extract_tokens(source_text)
            overlap = claim_words.intersection(source_words)
            overlap_ratio = len(overlap) / max(len(claim_words), 1)

            # If claim has multiple distinct proper noun entities, check entity alignment
            entity_overlap = claim_entities.intersection(source_words) if claim_entities else set()
            has_entity_match = bool(entity_overlap) if len(claim_entities) >= 2 else True

            # Must satisfy entity match and substantive keyword overlap
            is_fact_check = s.get("sourceType") == "Fact-Check Report"
            if is_fact_check:
                if has_entity_match and (len(overlap) >= 2 or overlap_ratio >= 0.2):
                    relevant.append(s)
            elif has_entity_match:
                if len(overlap) >= 3 or (len(overlap) >= 2 and overlap_ratio >= 0.25):
                    relevant.append(s)

        # Fallback: if strict filter dropped all, preserve sources with at least 2 substantive keyword matches
        if not relevant and sources:
            for s in sources:
                source_words = extract_tokens(s.get('title', ''))
                if len(claim_words.intersection(source_words)) >= 2:
                    relevant.append(s)

        return relevant

    @staticmethod
    def _deduplicate_sources(sources: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Deduplicate sources by normalized URL and title."""
        seen_urls: Set[str] = set()
        seen_titles: Set[str] = set()
        unique: List[Dict[str, Any]] = []

        for s in sources:
            raw_url = s.get("url", "").strip()
            if not raw_url or not (raw_url.startswith("http://") or raw_url.startswith("https://")):
                continue

            clean_url = raw_url.split("?")[0].rstrip("/").lower()
            norm_title = re.sub(r'[^\w]', '', s.get("title", "").lower())[:40]

            if clean_url in seen_urls or (norm_title and norm_title in seen_titles):
                continue

            seen_urls.add(clean_url)
            if norm_title:
                seen_titles.add(norm_title)

            unique.append(s)

        return unique

