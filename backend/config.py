import os
from typing import Set
from dotenv import load_dotenv

load_dotenv()

# API Keys and Environment Variables
GOOGLE_FACTCHECK_API_KEY = os.getenv("GOOGLE_FACTCHECK_API_KEY", "").strip()
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "").strip()
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "").strip()

HOST = os.getenv("HOST", "0.0.0.0")
PORT = int(os.getenv("PORT", "8000"))
CACHE_DB_PATH = os.getenv("CACHE_DB_PATH", "unmai_cache.db")
DEFAULT_TIMEOUT_SECONDS = float(os.getenv("TIMEOUT_SECONDS", "15.0"))
RATE_LIMIT_PER_MINUTE = os.getenv("RATE_LIMIT", "30/minute")

# Official Government & Health Authority Domains
OFFICIAL_DOMAINS: Set[str] = {
    "gov.in",
    "nic.in",
    "pib.gov.in",
    "mohfw.gov.in",
    "mha.gov.in",
    "who.int",
    "un.org",
    "cdc.gov",
    "nih.gov",
    "rbi.org.in",
    "isro.gov.in",
    "police.gov.in",
    "eci.gov.in",
    "mygov.in",
    "ayush.gov.in",
}

# Certified & Authoritative Fact-Checking Organization Domains
FACTCHECK_DOMAINS: Set[str] = {
    "altnews.in",
    "boomlive.in",
    "vishvasnews.com",
    "thequint.com",
    "factly.in",
    "reuters.com",
    "afp.com",
    "snopes.com",
    "factcheck.org",
    "politifact.com",
    "indiatoday.in",
    "newsmobile.in",
    "logicallyfacts.com",
    "thip.media",
}

# Reputable Mainstream News & Reference Domains
NEWS_DOMAINS: Set[str] = {
    "thehindu.com",
    "indianexpress.com",
    "bbc.com",
    "bbc.co.uk",
    "ndtv.com",
    "hindustantimes.com",
    "timesofindia.indiatimes.com",
    "theprint.in",
    "scroll.in",
    "thewire.in",
    "apnews.com",
    "aljazeera.com",
    "wikipedia.org",
}

# Social Media & User-Generated Content Platforms
SOCIAL_DOMAINS: Set[str] = {
    "facebook.com",
    "fb.com",
    "twitter.com",
    "x.com",
    "instagram.com",
    "tiktok.com",
    "reddit.com",
    "youtube.com",
    "t.me",
    "whatsapp.com",
}

def classify_domain(url_or_domain: str) -> str:
    """Classifies a domain as official, fact-check, news, social media, or other."""
    domain = url_or_domain.lower()
    if "://" in domain:
        domain = domain.split("://")[1].split("/")[0]
    
    # Strip port if present
    domain = domain.split(":")[0]

    for s in SOCIAL_DOMAINS:
        if domain == s or domain.endswith("." + s):
            return "Social Media"
    for off in OFFICIAL_DOMAINS:
        if domain == off or domain.endswith("." + off):
            return "Official Public Record"
    for fc in FACTCHECK_DOMAINS:
        if domain == fc or domain.endswith("." + fc):
            return "Fact-Check Report"
    for nw in NEWS_DOMAINS:
        if domain == nw or domain.endswith("." + nw):
            return "News Archive"
    return "Public Web Source"

# Human-centric, jargon-free translations for pipeline explanations
TRANSLATIONS = {
    "en": {
        "unverified_reason": "No authoritative fact-check records or verified public notices were found matching this exact claim.",
        "insufficient_evidence": "Not enough reliable evidence found in public databases to make a definitive ruling.",
        "verified_true_reason": "Confirmed by verified public sources including {publisher}.",
        "verified_false_reason": "Verified fact-check records from {publisher} contradict this claim.",
        "why_false_reason": "Directly disproven by published investigation from {publisher}.",
        "media_exif_clean": "Image contains standard camera hardware tags without immediate markers of AI synthesis.",
        "media_no_exif": "Image metadata is stripped (standard for social media forwards like WhatsApp). Inconclusive on origin.",
        "media_limitations": "Metadata stripping is standard in messaging apps; absence of metadata is not proof of tampering.",
        "media_ai_detected": "Image metadata contains signatures of AI generation software ({tool}).",
        "media_software_detected": "Image headers identify image editor software: {tool}.",
        "media_recycled_detected": "Image matches archival records published on {date}, indicating old content recycled out of context.",
    },
    "ta": {
        "unverified_reason": "இந்தக் குறிப்பிட்ட கூற்றுக்கு அதிகாரப்பூர்வ சரிபார்ப்பு பதிவுகள் எதுவும் கிடைக்கவில்லை.",
        "insufficient_evidence": "முடிவான தீர்ப்பை வழங்க பொதுத் தரவுத்தளங்களில் போதுமான நம்பகமான ஆதாரம் கிடைக்கவில்லை.",
        "verified_true_reason": "{publisher} உள்ளிட்ட நம்பகமான பொது ஆதாரங்களால் உறுதிப்படுத்தப்பட்டது.",
        "verified_false_reason": "{publisher} இன் சரிபார்ப்பு பதிவுகள் இந்தக் கூற்றை மறுக்கின்றன.",
        "why_false_reason": "{publisher} மேற்கொண்ட ஆய்வின் மூலம் இது தவறு என நிரூபிக்கப்பட்டுள்ளது.",
        "media_exif_clean": "படத்தில் வழக்கமான கேமரா தரவு உள்ளது; செயற்கை உருவாக்கத்திற்கான அறிகுறிகள் இல்லை.",
        "media_no_exif": "படத்தின் மெட்டாட援助 நீக்கப்பட்டுள்ளது (வாட்ஸ்அப் பகிர்வுகளில் இது வழக்கமானது). மூலத்தை உறுதியாகக் கூற முடியவில்லை.",
        "media_limitations": "வாட்ஸ்அப் போன்ற செயலிகள் மெட்டாடேட்டாவை தானாக நீக்கும்; இது மட்டும் மாற்றத்திற்கான ஆதாரம் அல்ல.",
        "media_ai_detected": "படத்தின் மெட்டாடேட்டாவில் செயற்கை நுண்ணறிவு (AI) உருவாக்க அடையாளங்கள் உள்ளன ({tool}).",
        "media_software_detected": "படம் மாற்றியமைக்கப்பட்ட மென்பொருளின் அடையாளம் உள்ளது: {tool}.",
        "media_recycled_detected": "இந்தப் படம் {date} தேதியில் வெளியான பழைய ஆவணங்களில் உள்ளது; இது பழைய படம் ஆகும்.",
    },
    "hi": {
        "unverified_reason": "इस दावे से संबंधित कोई आधिकारिक तथ्य-जांच रिकॉर्ड या सार्वजनिक सूचना नहीं मिली।",
        "insufficient_evidence": "निश्चित निष्कर्ष तक पहुँचने के लिए सार्वजनिक डेटाबेस में पर्याप्त विश्वसनीय सबूत नहीं मिले।",
        "verified_true_reason": "{publisher} सहित सत्यापित सार्वजनिक स्रोतों द्वारा पुष्टि की गई।",
        "verified_false_reason": "{publisher} के तथ्य-जांच रिकॉर्ड इस दावे का खंडन करते हैं।",
        "why_false_reason": "{publisher} की आधिकारिक जांच द्वारा इसे सीधे तौर पर खारिज किया गया है।",
        "media_exif_clean": "तस्वीर में सामान्य कैमरा मेटाडेटा मौजूद है; कृत्रिम निर्माण के संकेत नहीं मिले।",
        "media_no_exif": "तस्वीर का मेटाडेटा हटाया गया है (व्हाट्सएप जैसे संदेशों में यह सामान्य है)। स्रोत की पुष्टि नहीं हो सकी।",
        "media_limitations": "मैसेजिंग ऐप अक्सर मेटाडेटा हटा देते हैं; मेटाडेटा न होना छेड़छाड़ का पक्का सबूत नहीं है।",
        "media_ai_detected": "तस्वीर के मेटाडेटा में एआई निर्माण के संकेत मिले हैं ({tool})।",
        "media_software_detected": "तस्वीर में संपादन सॉफ्टवेयर के हस्ताक्षर मिले हैं: {tool}।",
        "media_recycled_detected": "यह तस्वीर {date} को प्रकाशित पुराने रिकॉर्ड से मेल खाती है, जो इसके पुनर्चक्रित होने का संकेत देती है।",
    },
}
