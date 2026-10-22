from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_health():
    res = client.get("/")
    assert res.status_code == 200
    assert res.json()["app"] == "Unmai"

def test_verify_unverified_text():
    res = client.post("/verify", json={
        "text": "Drinking boiled lemon water will permanently cure all ailments.",
        "language": "en"
    })
    assert res.status_code == 200
    data = res.json()
    assert "verdict" in data
    assert "scoreInfo" in data
    assert "claims" in data
    assert data["verdict"] in ["true", "false", "misleading", "unverified"]
    print(f"Health check and verify tests passed! Verdict: {data['verdict']}, Sources count: {len(data['confirmedSources'] + data['contradictingSources'])}")

if __name__ == "__main__":
    test_health()
    test_verify_unverified_text()
