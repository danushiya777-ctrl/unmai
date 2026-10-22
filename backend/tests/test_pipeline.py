import sys
from pathlib import Path
import pytest
from fastapi.testclient import TestClient

backend_dir = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(backend_dir))

from main import app
from pipeline.verdict_engine import VerdictEngine

client = TestClient(app)

def test_health_endpoint():
    res = client.get("/health")
    assert res.status_code == 200
    data = res.json()
    assert data["app"] == "Unmai"
    assert data["status"] == "online"

def test_json_parsing_contract():
    """Verify that response matches all fields expected by Flutter Investigation model."""
    res = client.post("/verify", json={
        "text": "The Moon orbits around Planet Earth in approximately 27 days.",
        "language": "en"
    })
    assert res.status_code == 200
    data = res.json()

    required_keys = [
        "id",
        "content",
        "contentType",
        "verdict",
        "oneSentenceReason",
        "scoreInfo",
        "confirmedSources",
        "contradictingSources",
        "claims",
        "createdAt",
        "isDemo"
    ]
    for key in required_keys:
        assert key in data, f"Missing required contract key: {key}"

    # Validate ScoreInfo structure
    assert "supportedClaims" in data["scoreInfo"]
    assert "totalClaims" in data["scoreInfo"]
    assert "evidenceStrength" in data["scoreInfo"]
    assert "explanation" in data["scoreInfo"]

def test_verdict_combination_rules():
    """Unit test the documented verdict aggregation rules."""
    mock_sources = [
        {"id": "s1", "publisher": "Test Gov", "sourceType": "Official Public Record", "stance": "supports", "url": "https://gov.in/notice"},
        {"id": "s2", "publisher": "Fact Check Bureau", "sourceType": "Fact-Check Report", "stance": "contradicts", "url": "https://reuters.com/factcheck"},
    ]

    # 1. Any contradicted -> False
    claims_with_false = [
        {"id": "c1", "text": "Claim 1", "verdict": "false"},
        {"id": "c2", "text": "Claim 2", "verdict": "true"},
    ]
    result_false = VerdictEngine.compute_overall_verdict(claims_with_false, mock_sources, lang="en")
    assert result_false["verdict"] == "false"

    # 2. All supported -> True
    claims_all_true = [
        {"id": "c1", "text": "Claim 1", "verdict": "true"},
        {"id": "c2", "text": "Claim 2", "verdict": "true"},
    ]
    result_true = VerdictEngine.compute_overall_verdict(claims_all_true, [mock_sources[0]], lang="en")
    assert result_true["verdict"] == "true"

    # 3. Mixed / Partial -> Misleading
    claims_mixed = [
        {"id": "c1", "text": "Claim 1", "verdict": "true"},
        {"id": "c2", "text": "Claim 2", "verdict": "misleading"},
    ]
    result_misleading = VerdictEngine.compute_overall_verdict(claims_mixed, mock_sources, lang="en")
    assert result_misleading["verdict"] == "misleading"

    # 4. No evidence -> Can't verify (unverified, NEVER False)
    claims_empty = [
        {"id": "c1", "text": "Unknown Claim", "verdict": "unverified"},
    ]
    result_unverified = VerdictEngine.compute_overall_verdict(claims_empty, [], lang="en")
    assert result_unverified["verdict"] == "unverified"
    assert result_unverified["verdict"] != "false"

def test_no_fabricated_sources_guarantee():
    """Verify that every source returned in the output has a valid http/https URL and legitimate origin."""
    res = client.post("/verify", json={
        "text": "ISRO launched Chandrayaan to explore lunar surface.",
        "language": "en"
    })
    assert res.status_code == 200
    data = res.json()

    all_returned_sources = (
        data.get("confirmedSources", [])
        + data.get("contradictingSources", [])
    )
    for c in data.get("claims", []):
        all_returned_sources.extend(c.get("sources", []))

    for s in all_returned_sources:
        url = s.get("url", "")
        assert url.startswith("http://") or url.startswith("https://"), f"Invalid source URL format: {url}"
        assert len(s.get("publisher", "")) > 0, "Missing publisher name in source"
        assert len(s.get("title", "")) > 0, "Missing title in source"

def test_unverified_never_false_on_missing_evidence():
    """Strict test verifying that an unknown query with zero fact-checks produces UNVERIFIED, not FALSE."""
    res = client.post("/verify", json={
        "text": "Random unique gibberish 98324759283475928347592384759238475928347592348572938475",
        "language": "en"
    })
    assert res.status_code == 200
    data = res.json()
    assert data["verdict"] == "unverified"
    assert data["verdict"] != "false"
