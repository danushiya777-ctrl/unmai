import re
import datetime
import json
from typing import List, Dict, Any, Optional
import httpx
from config import TRANSLATIONS, GEMINI_API_KEY

class VerdictEngine:
    @staticmethod
    async def evaluate_claim(
        claim_dict: Dict[str, Any],
        sources: List[Dict[str, Any]],
        lang: str = "en",
        client: Optional[httpx.AsyncClient] = None,
    ) -> Dict[str, Any]:
        """Evaluate a single claim against retrieved evidence, returning strictly evidence-backed verdict."""
        t = TRANSLATIONS.get(lang, TRANSLATIONS["en"])
        claim_text = claim_dict.get("text", "")
        source_map = {s["id"]: s for s in sources if "id" in s}

        # If LLM key is configured, evaluate using strict evidence constraint prompt
        if GEMINI_API_KEY and client and sources:
            try:
                llm_eval = await VerdictEngine._evaluate_with_gemini(claim_text, sources, lang, client)
                if llm_eval:
                    return VerdictEngine._format_claim_evaluation(claim_dict, llm_eval, source_map, t)
            except Exception:
                pass

        # Deterministic evidence evaluation fallback
        return VerdictEngine._evaluate_rule_based(claim_dict, sources, lang, t)

    @staticmethod
    async def _evaluate_with_gemini(
        claim_text: str,
        sources: List[Dict[str, Any]],
        lang: str,
        client: httpx.AsyncClient,
    ) -> Optional[Dict[str, Any]]:
        """Query LLM with strict evidence-only instructions. LLM calculates verdict from references."""
        today_str = datetime.date.today().isoformat()
        sources_context = [
            f"ID: {s['id']} | Published: {s.get('publishedDate', 'Unknown')} | Publisher: {s['publisher']} | Type: {s['sourceType']} | Stance: {s.get('stance', 'neutral')} | Title: {s['title']} | Summary: {s['summary']}"
            for s in sources
        ]
        prompt = (
            "You are an objective misinformation and incident verification engine. "
            f"Today's Date: {today_str}.\n"
            "An incident report/claim was submitted for verification:\n\n"
            f"Claim: {claim_text}\n\n"
            "Here are the real references retrieved for this incident:\n"
            + "\n".join(sources_context) + "\n\n"
            "STRICT INSTRUCTIONS:\n"
            "1. Base your ruling EXCLUSIVELY on what the retrieved references report about the incident.\n"
            "2. If one or more references explicitly refute, debunk, or contradict the claim, return 'contradicted'.\n"
            "3. If reputable news or official records confirm the incident happened as described, return 'supported'.\n"
            "4. CRITICAL TEMPORAL ACCURACY: If the claim asserts the event happened 'yesterday', 'today', 'this morning', 'just now', or on a specific date/year, but the references show the event occurred months or years ago (check 'Published' date of the references), you MUST return 'partly_supported' (misleading). In 'reasoning', clearly state that the event is old (mention the actual date/year) and is being recycled with a false recency claim.\n"
            "5. If numbers, casualties, or details are heavily exaggerated or distorted, return 'partly_supported'.\n"
            "6. If the references do not directly confirm or refute this incident, return 'unverified'.\n"
            f"7. In 'reasoning' (max 2 sentences in language '{lang}'), write a factual analysis explaining what the referenced sources reported (e.g. 'Reports from [Publisher] confirmed that...' or 'A fact-check by [Publisher] found that...').\n"
            "8. Populate 'supporting_source_ids' and 'contradicting_source_ids' with matching IDs from the references (e.g. ['src_1']).\n"
            "9. Return valid JSON only with keys: 'verdict', 'reasoning', 'supporting_source_ids', 'contradicting_source_ids', 'missing_context'.\n"
        )
        url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={GEMINI_API_KEY}"
        payload = {
            "contents": [{"parts": [{"text": prompt}]}],
            "generationConfig": {"temperature": 0.0, "responseMimeType": "application/json"},
        }
        resp = await client.post(url, json=payload, timeout=8.0)
        if resp.status_code == 200:
            data = resp.json()
            raw_json = data["candidates"][0]["content"]["parts"][0]["text"]
            return json.loads(raw_json)
        return None

    @staticmethod
    def _format_claim_evaluation(
        claim_dict: Dict[str, Any],
        eval_result: Dict[str, Any],
        source_map: Dict[str, Any],
        t: Dict[str, str],
    ) -> Dict[str, Any]:
        raw_v = eval_result.get("verdict", "unverified").lower()
        if raw_v == "supported":
            verdict = "true"
        elif raw_v == "contradicted":
            verdict = "false"
        elif raw_v == "partly_supported":
            verdict = "misleading"
        else:
            verdict = "unverified"

        sup_ids = eval_result.get("supporting_source_ids", [])
        con_ids = eval_result.get("contradicting_source_ids", [])

        supporting_sources = [source_map[sid] for sid in sup_ids if sid in source_map]
        contradicting_sources = [source_map[sid] for sid in con_ids if sid in source_map]

        return {
            "id": claim_dict.get("id", "c1"),
            "text": claim_dict.get("text", ""),
            "verdict": verdict,
            "explanation": eval_result.get("reasoning", t["unverified_reason"]),
            "supportingEvidence": [s["summary"] for s in supporting_sources],
            "contradictingEvidence": [s["summary"] for s in contradicting_sources],
            "missingContext": eval_result.get("missing_context"),
            "sources": supporting_sources + contradicting_sources,
        }

    @staticmethod
    def _check_temporal_accuracy(claim_text: str, sources: List[Dict[str, Any]], lang: str) -> Optional[Dict[str, Any]]:
        """Detect when an older real incident is being falsely shared as happening 'yesterday' or 'today'."""
        recency_pattern = re.compile(
            r'(?:\b|^|\s)(yesterday|today|this morning|last night|just now|minutes ago|hours ago|'
            r'earlier today|few hours ago|few days ago|நேற்று|இன்று|சற்றுமுன்|இன்று காலை|'
            r'நேற்று இரவு|அண்மையில்|சமீபத்தில்|कल|आज|अभी|आज सुबह|कल रात|हाल ही में)(?:\b|$|\s)',
            re.IGNORECASE
        )
        has_recency = bool(recency_pattern.search(claim_text))
        if not has_recency:
            return None

        today = datetime.date.today()

        pub_dates = []
        for s in sources:
            raw_d = s.get("publishedDate")
            if raw_d:
                try:
                    pub_dates.append(datetime.date.fromisoformat(raw_d[:10]))
                except Exception:
                    pass

        if not pub_dates:
            return None

        # Representative source publication date
        median_date = sorted(pub_dates)[len(pub_dates) // 2]
        days_ago = (today - median_date).days

        # Claim asserts recent occurrence ("yesterday", "today", "just now"), but sources are older (> 7 days)
        if days_ago > 7:
            date_str = median_date.strftime("%B %Y")
            if lang == "ta":
                explanation = f"தவறாக வழிநடத்துகிறது: இந்த சம்பவம் உண்மையில் நிகழ்ந்திருந்தாலும், இது நேற்று அல்லது அண்மையில் நடக்கவில்லை. இது {median_date.strftime('%d-%m-%Y')} அன்று பதிவான பழைய நிகழ்வு."
            elif lang == "hi":
                explanation = f"भ्रामक: यद्यपि यह घटना वास्तव में हुई थी, लेकिन यह कल या हाल ही में नहीं हुई है। यह {median_date.strftime('%d-%m-%Y')} की पुरानी घटना है जिसे हालिया बताकर साझा किया जा रहा है।"
            else:
                explanation = f"Misleading: While this event occurred, it did NOT happen yesterday/recently. It is an older incident from {date_str} being shared out of context as breaking news."

            return {
                "verdict": "misleading",
                "explanation": explanation,
                "missingContext": f"Incident occurred on {median_date.isoformat()}, not recently.",
            }

    @staticmethod
    def _check_scope_and_quantity_accuracy(claim_text: str, sources: List[Dict[str, Any]], lang: str) -> Optional[Dict[str, Any]]:
        """Detect when an incident is localized (e.g. 4 districts) but the claim falsely generalizes to 'all' or 'statewide'."""
        universal_scope_pat = re.compile(
            r'(?:\b|^|\s)(all\s+(?:schools?|colleges?|educational\s+institutions?|offices?|banks?|districts?|trains?|flights?)|'
            r'all\s+\d+\s+districts?|'
            r'across\s+all\s+(?:districts?|schools?|colleges?)|'
            r'throughout\s+(?:the\s+state|the\s+country|tamil\s*nadu|india)|'
            r'all\s+over\s+(?:the\s+state|the\s+country|tamil\s*nadu|india)|'
            r'entire\s+(?:state|country|nation|tamil\s*nadu|india)|across\s+(?:the\s+state|the\s+country|tamil\s*nadu)|'
            r'statewide|nationwide|every\s+(?:school|college|district|educational\s+institution)|'
            r'அனைத்து\s+(?:பள்ளிகளுக்கும்|பள்ளிகளும்|கல்லூரிகளுக்கும்|மாவட்டங்களிலும்|மாவட்டங்களுக்கும்|கல்வி\s+நிறுவனங்களுக்கும்)|'
            r'அனைத்து\s+\d+\s+மாவட்டங்களிலும்|'
            r'மாநிலம்\s+முழுவதும்|தமிழகம்\s+முழுவதும்|தமிழ்நாடு\s+முழுவதும்|'
            r'सभी\s+(?:स्कूलों|जिलों|कॉलेजों|संस्थानों)|पूरे\s+(?:राज्य|देश)\s+में|राज्यभर\s+में)(?:\b|$|\s)',
            re.IGNORECASE
        )
        if not universal_scope_pat.search(claim_text):
            return None

        local_scope_pat = re.compile(
            r'\b(?:only\s+)?(\d+|two|three|four|five|six|seven|eight|nine|ten|several|some|few|select)\s+(?:other\s+|more\s+|tamil\s*nadu\s+)?(?:districts?|cities|regions?|places?)\b|'
            r'\b(?:schools?|colleges?|holiday|closure)\s+(?:in|shut\s+in|closed\s+in|declared\s+in|for)\s+(?:only\s+)?(\d+|two|three|four|five|six|several|some|few|select)\s+(?:other\s+|tamil\s*nadu\s+)?(?:districts?|cities)\b|'
            r'\b(\d+|two|three|four|five|six|several|some|few)\s+(?:other\s+|tamil\s*nadu\s+)?districts?\s+(?:declare|announce|close|shut|holiday)\b|'
            r'(\d+)\s+மாவட்டங்களில்|சில\s+மாவட்டங்களில்|குறிப்பிட்ட\s+மாவட்டங்களில்|'
            r'(\d+)\s+जिलों\s+में|कुछ\s+जिलों\s+में',
            re.IGNORECASE
        )

        for s in sources:
            source_content = f"{s.get('title', '')} {s.get('summary', '')}"
            match = local_scope_pat.search(source_content)
            if match:
                matched_scope = match.group(0).strip()
                if lang == "ta":
                    explanation = f"தவறாக வழிநடத்துகிறது: மாநிலம் முழுவதும் உள்ள அனைத்து பள்ளிகளுக்கும் விடுமுறை அறிவிக்கப்படவில்லை; குறிப்பிட்ட சில பகுதிகளுக்கு ({matched_scope}) மட்டுமே விடுமுறை அறிவிக்கப்பட்டுள்ளது."
                elif lang == "hi":
                    explanation = f"भ्रामक: पूरे राज्य के सभी स्कूलों के लिए छुट्टी घोषित नहीं की गई है; केवल कुछ सीमित क्षेत्रों ({matched_scope}) में ही आदेश दिया गया है।"
                else:
                    explanation = f"Misleading: The announcement/holiday applies only to specific areas ({matched_scope}), NOT all schools across the entire state."

                return {
                    "verdict": "misleading",
                    "explanation": explanation,
                    "missingContext": f"Holiday declared in localized districts ({matched_scope}), not statewide.",
                }

        return None

    @staticmethod
    def _evaluate_rule_based(
        claim_dict: Dict[str, Any],
        sources: List[Dict[str, Any]],
        lang: str,
        t: Dict[str, str],
    ) -> Dict[str, Any]:
        """Deterministic evaluation calculating verdict directly from retrieved references."""
        contradicting = [s for s in sources if s.get("stance") == "contradicts"]
        supporting = [s for s in sources if s.get("stance") == "supports" and s.get("sourceType") in ["Fact-Check Report", "Official Public Record", "News Archive"]]

        # If no fact-checker contradicts and multiple reputable news sources report on the incident, corroborate it
        if not supporting and not contradicting:
            news_sources = [s for s in sources if s.get("sourceType") in ["News Archive", "Official Public Record"]]
            if len(news_sources) >= 2:
                supporting = news_sources

        missing_context = None

        if contradicting:
            verdict = "false"
            ref = contradicting[0]
            publisher = ref.get("publisher", "Fact-Check Records")
            title = ref.get("title", "")
            if lang == "ta":
                explanation = f"{publisher} வெளியிட்ட தகவலின்படி இது தவறு என நிரூபிக்கப்பட்டுள்ளது: {title}."
            elif lang == "hi":
                explanation = f"{publisher} की रिपोर्ट के अनुसार यह दावा गलत साबित हुआ है: {title}."
            else:
                explanation = f"Contradicted by {publisher}: '{title}'."
        elif supporting:
            # Rigorous temporal verification: catch older incidents recycled as 'yesterday' or 'today'
            temporal_check = VerdictEngine._check_temporal_accuracy(claim_dict.get("text", ""), supporting, lang)
            # Rigorous scope verification: catch localized events falsely generalized as 'all' or 'statewide'
            scope_check = VerdictEngine._check_scope_and_quantity_accuracy(claim_dict.get("text", ""), supporting, lang)

            if temporal_check:
                verdict = "misleading"
                explanation = temporal_check["explanation"]
                missing_context = temporal_check.get("missingContext")
            elif scope_check:
                verdict = "misleading"
                explanation = scope_check["explanation"]
                missing_context = scope_check.get("missingContext")
            else:
                verdict = "true"
                ref = supporting[0]
                publisher = ref.get("publisher", "Official Sources")
                title = ref.get("title", "")
                if lang == "ta":
                    explanation = f"{publisher} வெளியிட்ட அறிக்கையின்படி இந்த சம்பவம் உறுதிப்படுத்தப்பட்டுள்ளது: {title}."
                elif lang == "hi":
                    explanation = f"{publisher} द्वारा प्रकाशित रिपोर्ट के अनुसार इस घटना की पुष्टि की गई है: {title}."
                else:
                    explanation = f"Confirmed by {publisher}: '{title}'."
        else:
            verdict = "unverified"
            if sources:
                pub = sources[0].get("publisher", "public archives")
                if lang == "ta":
                    explanation = f"{pub} மூலம் தொடர்புடைய குறிப்புகள் காணப்பட்டாலும், இந்த கூற்றுக்கு நேரடி உறுதிப்படுத்தல் கிடைக்கவில்லை."
                elif lang == "hi":
                    explanation = f"{pub} से संबंधित संदर्भ मिले हैं, लेकिन इस दावे की प्रत्यक्ष पुष्टि नहीं मिली।"
                else:
                    explanation = f"References found from {pub}, but no verified records directly confirm or refute this incident."
            else:
                explanation = t["unverified_reason"]

        relevant_sources = (contradicting if verdict == "false" else supporting) or sources[:2]

        return {
            "id": claim_dict.get("id", "c1"),
            "text": claim_dict.get("text", ""),
            "verdict": verdict,
            "explanation": explanation,
            "supportingEvidence": [s["summary"] for s in supporting],
            "contradictingEvidence": [s["summary"] for s in contradicting],
            "missingContext": missing_context,
            "sources": relevant_sources,
        }

    @staticmethod
    def compute_overall_verdict(
        claims: List[Dict[str, Any]],
        all_sources: List[Dict[str, Any]],
        lang: str = "en",
    ) -> Dict[str, Any]:
        """Aggregate individual claim verdicts into a transparent overall report."""
        t = TRANSLATIONS.get(lang, TRANSLATIONS["en"])
        total_claims = len(claims) or 1
        supported_count = sum(1 for c in claims if c.get("verdict") == "true")
        false_count = sum(1 for c in claims if c.get("verdict") == "false")
        misleading_count = sum(1 for c in claims if c.get("verdict") == "misleading")

        # Gather unique sources by stance
        all_contradicting: List[Dict[str, Any]] = []
        all_supporting: List[Dict[str, Any]] = []
        for s in all_sources:
            if s.get("stance") == "contradicts" and s not in all_contradicting:
                all_contradicting.append(s)
            elif s.get("stance") == "supports" and s not in all_supporting:
                all_supporting.append(s)

        # Verdict combination rules calculated from references
        if false_count > 0:
            verdict = "false"
            ref = all_contradicting[0] if all_contradicting else (all_sources[0] if all_sources else {})
            pub = ref.get("publisher", "Fact-Checking Reports")
            title = ref.get("title", "")
            
            if lang == "ta":
                one_sentence_reason = f"{pub} வெளியிட்ட ஆய்வின்படி இந்த தகவல் தவறானது: {title}."
                why_false_reason = f"{pub} வெளியிட்ட செய்திக்குறிப்பில் இது உறுதிப்படுத்தப்பட்டுள்ளது."
            elif lang == "hi":
                one_sentence_reason = f"{pub} द्वारा की गई जांच के अनुसार यह दावा गलत है: {title}."
                why_false_reason = f"{pub} की आधिकारिक तथ्य-जांच में इसका खंडन किया गया है।"
            else:
                one_sentence_reason = f"Contradicted by {pub}: '{title}'."
                why_false_reason = f"Disproven by investigation from {pub} ('{title}')."
            
            confirmed_sources = []
            contradicting_sources = all_contradicting
        elif supported_count == total_claims and supported_count > 0:
            verdict = "true"
            ref = all_supporting[0] if all_supporting else (all_sources[0] if all_sources else {})
            pub = ref.get("publisher", "Authoritative Sources")
            title = ref.get("title", "")

            if lang == "ta":
                one_sentence_reason = f"{pub} உள்ளிட்ட நம்பகமான செய்தி ஆதாரங்களால் உறுதிப்படுத்தப்பட்டது: {title}."
            elif lang == "hi":
                one_sentence_reason = f"{pub} सहित विश्वसनीय स्रोतों द्वारा इस घटना की पुष्टि की गई: {title}."
            else:
                one_sentence_reason = f"Confirmed by verified reporting from {pub}: '{title}'."

            why_false_reason = None
            confirmed_sources = all_supporting
            contradicting_sources = []
        elif misleading_count > 0 or (supported_count > 0 and supported_count < total_claims):
            verdict = "misleading"
            ref_sup = all_supporting[0] if all_supporting else (all_sources[0] if all_sources else {})
            pub_sup = ref_sup.get("publisher", "Verified Outlets")
            
            misleading_explanations = [c.get("explanation") for c in claims if c.get("verdict") == "misleading" and c.get("explanation")]
            if misleading_explanations:
                one_sentence_reason = misleading_explanations[0]
                why_false_reason = "Incident details or timing are misattributed or recycled from the past."
            elif lang == "ta":
                one_sentence_reason = f"இந்த சம்பவத்தின் சில பகுதிகள் {pub_sup} மூலம் உறுதி செய்யப்பட்டாலும், பிற தகவல்கள் உண்மைக்குப் புறம்பானவை."
                why_false_reason = "கூடுதல் உண்மை சூழல் அல்லது அதிகாரப்பூர்வ உறுதிப்படுத்தல் இதில் விடுபட்டுள்ளது."
            elif lang == "hi":
                one_sentence_reason = f"इस घटना के कुछ अंश {pub_sup} द्वारा समर्थित हैं, लेकिन कुछ दावे भ्रामक पाए गए।"
                why_false_reason = "इस संदेश में महत्वपूर्ण संदर्भ छोड़ा गया है।"
            else:
                one_sentence_reason = f"Elements are corroborated by {pub_sup}, but key details lack proof or are exaggerated."
                why_false_reason = "Contains claims that lack verification or are contradicted by available context."

            confirmed_sources = all_supporting
            contradicting_sources = all_contradicting
        else:
            verdict = "unverified"
            if all_sources:
                pub = all_sources[0].get("publisher", "public archives")
                if lang == "ta":
                    one_sentence_reason = f"{pub} மூலம் தொடர்புடைய பொது குறிப்புகள் காணப்பட்டாலும், இந்த கூற்றுக்கு நேரடி உறுதிப்படுத்தல் கிடைக்கவில்லை."
                elif lang == "hi":
                    one_sentence_reason = f"{pub} से संबंधित संदर्भ उपलब्ध हैं, लेकिन इस दावे की निश्चित पुष्टि नहीं हो सकी।"
                else:
                    one_sentence_reason = f"Public references found ({pub}), but no authoritative records confirm or refute this incident."
            else:
                one_sentence_reason = t["unverified_reason"]

            why_false_reason = None
            confirmed_sources = all_supporting
            contradicting_sources = []

        # Determine evidence strength
        has_factcheck_or_official = any(s.get("sourceType") in ["Fact-Check Report", "Official Public Record"] for s in all_sources)
        has_news = any(s.get("sourceType") == "News Archive" for s in all_sources)

        if has_factcheck_or_official and (verdict in ["true", "false"]):
            evidence_strength = "Strong"
            score_explanation = "Verified against authoritative databases and certified records."
        elif has_news:
            evidence_strength = "Medium"
            score_explanation = "Corroborated by mainstream news publications."
        elif all_sources:
            evidence_strength = "Weak"
            score_explanation = "Limited public references found; not enough for a definitive ruling."
        else:
            evidence_strength = "Insufficient"
            score_explanation = t["insufficient_evidence"]

        score_info = {
            "supportedClaims": supported_count,
            "totalClaims": total_claims,
            "evidenceStrength": evidence_strength,
            "explanation": score_explanation,
        }

        return {
            "verdict": verdict,
            "oneSentenceReason": one_sentence_reason,
            "whyFalseReason": why_false_reason,
            "scoreInfo": score_info,
            "confirmedSources": confirmed_sources,
            "contradictingSources": contradicting_sources,
        }
