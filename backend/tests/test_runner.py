import os
import sys
import json
from pathlib import Path

# Add backend directory to sys.path
backend_dir = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(backend_dir))

from fastapi.testclient import TestClient
from main import app, cache

client = TestClient(app)

def run_all_cases():
    cache.clear()
    cases_file = Path(__file__).parent / "test_cases.json"
    with open(cases_file, "r", encoding="utf-8") as f:
        test_cases = json.load(f)

    print("=" * 80)
    print(" UNMAI REAL-DATA VERIFICATION TEST SUITE (12 REAL TEST CASES)")
    print("=" * 80)

    passed_count = 0
    total_count = len(test_cases)

    for i, tc in enumerate(test_cases, 1):
        case_id = tc["id"]
        category = tc["category"]
        text = tc["text"]
        expected = tc["expected_verdicts"]

        print(f"\n[{i}/{total_count}] Test Case: {case_id} ({category})")
        print(f" Input: \"{text[:75]}...\"")

        res = client.post("/verify", json={"text": text, "language": "en"})
        if res.status_code != 200:
            print(f" FAIL (HTTP {res.status_code})")
            continue

        data = res.json()
        verdict = data.get("verdict", "")
        sources = data.get("confirmedSources", []) + data.get("contradictingSources", [])
        score_info = data.get("scoreInfo", {})
        evidence_strength = score_info.get("evidenceStrength", "Unknown")

        passed = verdict in expected
        if passed:
            passed_count += 1
            status_str = "PASS"
        else:
            status_str = "FAIL"

        print(f" Expected: {expected} | Actual Verdict: {verdict.upper()} ({evidence_strength} evidence)")
        print(f" Sources Found: {len(sources)}")
        for s in sources[:2]:
            safe_pub = str(s.get('publisher', '')).encode('ascii', 'replace').decode('ascii')
            safe_title = str(s.get('title', ''))[:55].encode('ascii', 'replace').decode('ascii')
            print(f"   * {safe_pub}: {safe_title} ({s.get('sourceType')})")

        safe_reason = str(data.get('oneSentenceReason', ''))[:70].encode('ascii', 'replace').decode('ascii')
        print(f" Result: [{status_str}] - Reason: {safe_reason}...")

    pass_rate = (passed_count / total_count) * 100
    print("\n" + "=" * 80)
    print(f" HONEST TEST REPORT: {passed_count}/{total_count} PASSED ({pass_rate:.1f}% Pass Rate)")
    print("=" * 80)
    return passed_count == total_count

if __name__ == "__main__":
    success = run_all_cases()
    sys.exit(0 if success else 1)
