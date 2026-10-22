import httpx
import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

claims = [
    ('all schools in tamilnadu is declared as holiday due to heavy rain', 'en'),
    ('schools are declared holiday in all district of Tamil Nadu today due to heavy rain', 'en'),
    ('heavy rain: holiday declared for all schools across tamil nadu', 'en'),
    ('கனமழை காரணமாக தமிழ்நாட்டில் உள்ள அனைத்து பள்ளிகளுக்கும் விடுமுறை அறிவிக்கப்பட்டுள்ளது', 'ta'),
]

for text, lang in claims:
    r = httpx.post('http://127.0.0.1:8000/verify', data={'text': text, 'language': lang}, timeout=30)
    data = r.json()
    print(f"[{lang}] Claim: {text[:60]}")
    print(f"     Status: {r.status_code} | Verdict: {data.get('verdict')}")
    print(f"     Reason: {data.get('oneSentenceReason')}")
    print(f"     MissingContext: {data.get('missingContext')}")
    print("-" * 60)
