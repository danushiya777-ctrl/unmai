import sqlite3
import json
import sys

sys.stdout.reconfigure(encoding='utf-8')
conn = sqlite3.connect('unmai_cache.db')
c = conn.cursor()
c.execute("SELECT content_hash, response_json FROM verification_cache WHERE content_hash LIKE '802bc43b%'")
row = c.fetchone()
if row:
    data = json.loads(row[1])
    print("Hash:", row[0])
    print("Verdict:", data.get("verdict"))
    print("Claims:", data.get("claims"))
    print("Reason:", data.get("oneSentenceReason"))
    print("Sources:", [s.get("title") for s in data.get("sources", [])])
