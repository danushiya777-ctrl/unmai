import re
import json
from typing import List, Dict, Any, Optional
import httpx
from config import GEMINI_API_KEY, OPENAI_API_KEY

class ClaimExtractor:
    @staticmethod
    async def extract_claims(text: str, client: Optional[httpx.AsyncClient] = None) -> List[Dict[str, Any]]:
        """Extract up to 5 distinct, checkable factual claims, skipping opinions."""
        if not text or len(text.strip()) < 10:
            return []

        # If LLM key is available, call LLM for structured extraction
        if GEMINI_API_KEY and client:
            try:
                llm_claims = await ClaimExtractor._extract_with_gemini(text, client)
                if llm_claims:
                    return llm_claims[:5]
            except Exception:
                pass

        # Fallback: Robust rule-based factual claims extraction
        return ClaimExtractor._extract_rule_based(text)

    @staticmethod
    async def _extract_with_gemini(text: str, client: httpx.AsyncClient) -> List[Dict[str, Any]]:
        """Extract checkable claims using Gemini API with structured JSON output."""
        url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={GEMINI_API_KEY}"
        prompt = (
            "You are a factual misinformation analyst. Analyze the following text message and extract up to 5 "
            "distinct, verifiable FACTUAL claims. Omit pure opinions, emotional commentary, and forward-sharing instructions. "
            "Return a JSON array of objects with keys: 'id' (e.g. 'c1'), 'text' (the concise factual assertion), "
            "and 'checkable' (true/false).\n\n"
            f"Input text:\n{text}\n\n"
            "Return valid JSON array only."
        )
        payload = {
            "contents": [{"parts": [{"text": prompt}]}],
            "generationConfig": {"temperature": 0.1, "responseMimeType": "application/json"},
        }
        resp = await client.post(url, json=payload, timeout=8.0)
        if resp.status_code == 200:
            data = resp.json()
            raw_json = data["candidates"][0]["content"]["parts"][0]["text"]
            parsed = json.loads(raw_json)
            if isinstance(parsed, list):
                return [p for p in parsed if p.get("checkable", True) and len(p.get("text", "")) > 10]
        return []

    @staticmethod
    def _extract_rule_based(text: str) -> List[Dict[str, Any]]:
        """Deterministic extractor that isolates actionable factual sentences and drops pure opinions."""
        # Normalize line breaks and periods
        sentences = [
            s.strip()
            for s in re.split(r'[.!?\n]+', text)
            if len(s.strip()) > 15
        ]

        opinion_cues = [
            r'\bi\s+(?:think|feel|believe|suppose)\b',
            r'\bin\s+my\s+(?:opinion|view)\b',
            r'\b(?:best|worst|greatest|terrible)\s+(?:in\s+the\s+world|ever)\b',
            r'\bshould\s+(?:be|do)\b',
            r'\bplease\s+(?:share|forward|send)\b',
            r'\bdon\'?t\s+forget\s+to\b',
        ]

        claims = []
        claim_idx = 1
        for s in sentences:
            # Check if this sentence is purely an opinion or CTA
            is_opinion = any(re.search(pat, s, re.IGNORECASE) for pat in opinion_cues)
            if is_opinion:
                continue

            # Ensure sentence has at least some subject/verb substance
            words = s.split()
            if len(words) < 4:
                continue

            claims.append({
                "id": f"claim_{claim_idx}",
                "text": s,
                "checkable": True,
            })
            claim_idx += 1
            if len(claims) >= 5:
                break

        # If all were filtered out but text exists, return original text as single claim
        if not claims and text.strip():
            claims.append({
                "id": "claim_1",
                "text": text.strip()[:180],
                "checkable": True,
            })

        return claims
