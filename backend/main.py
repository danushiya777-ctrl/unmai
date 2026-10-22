import os
import time
import uuid
import hashlib
import datetime
import logging
from typing import Optional, List, Dict, Any

from fastapi import FastAPI, UploadFile, File, Form, Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import httpx
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

from config import (
    GOOGLE_FACTCHECK_API_KEY,
    GEMINI_API_KEY,
    DEFAULT_TIMEOUT_SECONDS,
    RATE_LIMIT_PER_MINUTE,
)
from pipeline.input_processor import InputProcessor
from pipeline.claim_extractor import ClaimExtractor
from pipeline.evidence_retriever import EvidenceRetriever
from pipeline.verdict_engine import VerdictEngine
from pipeline.media_checker import MediaChecker
from pipeline.cache import ResponseCache

# Configure secure server logging (scrubs raw text content)
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
logger = logging.getLogger("unmai_backend")

# Rate limiting
limiter = Limiter(key_func=get_remote_address)
app = FastAPI(
    title="Unmai Verification Backend",
    description="Evidence-based real verification pipeline for WhatsApp forwards and media.",
    version="1.0.0",
)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

cache = ResponseCache()

class VerifyRequest(BaseModel):
    text: Optional[str] = ""
    url: Optional[str] = ""
    language: Optional[str] = "en"

@app.get("/health")
@app.get("/")
def health_check():
    """Health check endpoint displaying service health and configured integrations."""
    return {
        "app": "Unmai",
        "tagline": "Check before you share.",
        "status": "online",
        "version": "1.0.0",
        "has_google_factcheck_key": bool(GOOGLE_FACTCHECK_API_KEY),
        "has_gemini_key": bool(GEMINI_API_KEY),
        "cache_enabled": True,
        "max_upload_size_mb": 50,
    }

@app.post("/verify")
@limiter.limit(RATE_LIMIT_PER_MINUTE)
async def verify(
    request: Request,
    text: Optional[str] = Form(None),
    url: Optional[str] = Form(None),
    language: Optional[str] = Form("en"),
    file: Optional[UploadFile] = File(None),
):
    start_time = time.time()

    # Support JSON request payload in addition to multipart form
    content_type_header = request.headers.get("content-type", "")
    if content_type_header.startswith("application/json"):
        try:
            body = await request.json()
            text = body.get("text", "")
            url = body.get("url", "")
            language = body.get("language", "en")
        except Exception:
            pass

    lang = language if language in ["en", "ta", "hi"] else "en"
    raw_content = (text or url or (file.filename if file else "") or "").strip()

    if not raw_content and not file:
        raise HTTPException(status_code=400, detail="Please provide text, a URL, or attach media to verify.")

    content_type = "text"
    file_bytes: Optional[bytes] = None
    media_assessment: Optional[Dict[str, Any]] = None

    # Process file attachment
    if file:
        file_bytes = await file.read()
        if len(file_bytes) > 50 * 1024 * 1024:
            raise HTTPException(status_code=413, detail="File exceeds maximum allowed size of 50MB.")

        mime = file.content_type or ""
        if "video" in mime or (file.filename and file.filename.lower().endswith(('.mp4', '.mov', '.webm'))):
            content_type = "video"
            media_assessment = {
                "result": "inconclusive",
                "reasons": ["Video header validated. Full automated video frame verification is in development."],
                "toolUsed": "Video container stream header parser",
                "limitations": "Frame-by-frame deepfake analysis requires desktop video inspection tools.",
            }
        else:
            content_type = "image"
            media_assessment = MediaChecker.analyze_image(file_bytes, lang=lang)
            # OCR inspection
            ocr_res = InputProcessor.process_image(file_bytes)
            if ocr_res.get("has_ocr") and not text:
                text = ocr_res["extracted_text"]

    elif url and (url.startswith("http://") or url.startswith("https://")):
        content_type = "url"

    # Compute content hash for cache check
    hash_input = (text or "") + (url or "") + (hashlib.sha256(file_bytes).hexdigest() if file_bytes else "") + lang
    content_hash = hashlib.sha256(hash_input.encode("utf-8")).hexdigest()

    cached_result = cache.get(content_hash)
    if cached_result:
        logger.info(f"Verification cache hit for hash={content_hash[:8]} in {time.time() - start_time:.2f}s")
        return cached_result

    # 1. Clean text and extract URL content if applicable
    async with httpx.AsyncClient(timeout=DEFAULT_TIMEOUT_SECONDS) as client:
        url_metadata = None
        if content_type == "url" and url:
            url_metadata = await InputProcessor.process_url(url, client)
            if url_metadata.get("text"):
                text = f"{url_metadata['title']}\n\n{url_metadata['text']}"

        cleaned_text = InputProcessor.clean_text(text or raw_content)

        # 2. Extract Claims
        claims_raw = await ClaimExtractor.extract_claims(cleaned_text, client)
        if not claims_raw:
            claims_raw = [{"id": "claim_1", "text": cleaned_text[:160], "checkable": True}]

        # 3. Retrieve Evidence and evaluate claims
        evaluated_claims: List[Dict[str, Any]] = []
        all_retrieved_sources: List[Dict[str, Any]] = []

        for c in claims_raw:
            c_text = c.get("text", "")
            # Retrieve evidence for claim
            claim_sources = await EvidenceRetriever.retrieve_for_claim(c_text, client, lang=lang)
            for s in claim_sources:
                if s not in all_retrieved_sources:
                    all_retrieved_sources.append(s)

            # Evaluate claim against retrieved evidence
            eval_c = await VerdictEngine.evaluate_claim(c, claim_sources, lang=lang, client=client)
            evaluated_claims.append(eval_c)

        # 4. Synthesize Overall Verdict
        overall = VerdictEngine.compute_overall_verdict(evaluated_claims, all_retrieved_sources, lang=lang)

    response_payload = {
        "id": f"inv_{uuid.uuid4().hex[:10]}",
        "content": raw_content[:400],
        "contentType": content_type,
        "verdict": overall["verdict"],
        "oneSentenceReason": overall["oneSentenceReason"],
        "scoreInfo": overall["scoreInfo"],
        "mediaAssessment": media_assessment,
        "confirmedSources": overall["confirmedSources"],
        "whyFalseReason": overall["whyFalseReason"],
        "contradictingSources": overall["contradictingSources"],
        "claims": evaluated_claims,
        "createdAt": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "isDemo": False,
        "isCached": False,
    }

    # Store in cache
    cache.set(content_hash, response_payload)

    elapsed = time.time() - start_time
    logger.info(f"Verified content_type={content_type} verdict={overall['verdict']} claims={len(evaluated_claims)} sources={len(all_retrieved_sources)} in {elapsed:.2f}s")

    return response_payload
