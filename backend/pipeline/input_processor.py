import re
import io
import datetime
from typing import Optional, Dict, Any, List
import httpx
import trafilatura
from PIL import Image

try:
    import pytesseract
except ImportError:
    pytesseract = None

class InputProcessor:
    @staticmethod
    def clean_text(raw_text: str) -> str:
        """Clean and normalize viral messages, stripping zero-width chars and boilerplate."""
        if not raw_text:
            return ""

        # Remove zero-width characters often found in copied WhatsApp forwards
        cleaned = re.sub(r'[\u200b-\u200f\ufeff\u202a-\u202e]', '', raw_text)

        # Remove common social media forward boilerplate
        patterns = [
            r'(?i)forwarded\s+(?:as\s+received|message)',
            r'(?i)\*?forwarded\*?',
            r'(?i)share\s+to\s+\d+\s+groups?',
            r'(?i)send\s+to\s+all\s+your\s+contacts?',
            r'(?i)viral\s+message',
            r'(?i)breaking\s+news[:!]',
        ]
        for pat in patterns:
            cleaned = re.sub(pat, '', cleaned)

        # Normalize extra spaces and linebreaks
        cleaned = re.sub(r'[ \t]+', ' ', cleaned)
        cleaned = re.sub(r'\n{3,}', '\n\n', cleaned)
        return cleaned.strip()

    @staticmethod
    async def process_url(url: str, client: httpx.AsyncClient) -> Dict[str, Any]:
        """Fetch webpage and extract clean article text, title, publisher, and date."""
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 UnmaiBot/1.0",
        }
        try:
            resp = await client.get(url, headers=headers, follow_redirects=True, timeout=12.0)
            if resp.status_code == 200:
                html = resp.text
                extracted_text = trafilatura.extract(html, include_comments=False, output_format="txt") or ""
                metadata = trafilatura.extract_metadata(html)

                domain = url.split("://")[1].split("/")[0] if "://" in url else url
                title = (metadata.title if metadata and metadata.title else "") or domain
                publisher = (metadata.sitename if metadata and metadata.sitename else "") or domain
                date = metadata.date if metadata and metadata.date else None

                return {
                    "text": extracted_text[:4000],
                    "title": title,
                    "publisher": publisher,
                    "publishedDate": date,
                    "url": str(resp.url),
                    "success": True,
                }
        except Exception:
            pass

        return {
            "text": "",
            "title": url,
            "publisher": url,
            "publishedDate": None,
            "url": url,
            "success": False,
        }

    @staticmethod
    def process_image(image_bytes: bytes) -> Dict[str, Any]:
        """Extract text from screenshot or meme via OCR and parse visible dates/numbers."""
        extracted_text = ""
        has_ocr = False

        try:
            img = Image.open(io.BytesIO(image_bytes))
            if pytesseract:
                try:
                    # Attempt OCR with standard English
                    extracted_text = pytesseract.image_to_string(img, timeout=5).strip()
                    has_ocr = bool(extracted_text)
                except Exception:
                    # Tesseract binary might not be in PATH
                    pass
        except Exception:
            pass

        # Extract dates and prominent numbers/monetary figures from extracted text
        dates_found = re.findall(r'\b(?:\d{1,2}[/-]\d{1,2}[/-]\d{2,4}|\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]* \d{1,2},? \d{4})\b', extracted_text)
        amounts_found = re.findall(r'(?:₹|Rs\.?|INR|\$)\s*[\d,]+', extracted_text)

        return {
            "extracted_text": InputProcessor.clean_text(extracted_text),
            "has_ocr": has_ocr,
            "dates_found": dates_found,
            "amounts_found": amounts_found,
        }
