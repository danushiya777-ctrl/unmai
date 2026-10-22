import sqlite3
import json
import time
from typing import Optional, Dict, Any
from config import CACHE_DB_PATH

class ResponseCache:
    def __init__(self, db_path: str = CACHE_DB_PATH, ttl_seconds: int = 86400):
        self.db_path = db_path
        self.ttl_seconds = ttl_seconds
        self._init_db()

    def _init_db(self):
        try:
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.cursor()
                cursor.execute("""
                    CREATE TABLE IF NOT EXISTS verification_cache (
                        content_hash TEXT PRIMARY KEY,
                        response_json TEXT NOT NULL,
                        created_at INTEGER NOT NULL
                    )
                """)
                conn.commit()
        except Exception:
            pass

    def get(self, content_hash: str) -> Optional[Dict[str, Any]]:
        try:
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.cursor()
                cursor.execute(
                    "SELECT response_json, created_at FROM verification_cache WHERE content_hash = ?",
                    (content_hash,),
                )
                row = cursor.fetchone()
                if row:
                    response_json, created_at = row
                    if time.time() - created_at < self.ttl_seconds:
                        data = json.loads(response_json)
                        data["isCached"] = True
                        return data
                    else:
                        # Expired, clean up
                        cursor.execute("DELETE FROM verification_cache WHERE content_hash = ?", (content_hash,))
                        conn.commit()
        except Exception:
            pass
        return None

    def set(self, content_hash: str, response_dict: Dict[str, Any]):
        try:
            clean_dict = dict(response_dict)
            clean_dict.pop("isCached", None)
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.cursor()
                cursor.execute(
                    """
                    INSERT OR REPLACE INTO verification_cache (content_hash, response_json, created_at)
                    VALUES (?, ?, ?)
                    """,
                    (content_hash, json.dumps(clean_dict), int(time.time())),
                )
                conn.commit()
        except Exception:
            pass

    def clear(self):
        """Clear all entries from the verification cache."""
        try:
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.cursor()
                cursor.execute("DELETE FROM verification_cache")
                conn.commit()
        except Exception:
            pass

