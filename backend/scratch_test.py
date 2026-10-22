import sys
import re

sys.stdout.reconfigure(encoding='utf-8')
t = 'கனமழை காரணமாக தமிழ்நாட்டில் உள்ள அனைத்து பள்ளிகளுக்கும் விடுமுறை'

# Extract tokens by stripping whitespace and punctuation
words = [re.sub(r'^[^\w\u0B80-\u0BFF\u0900-\u097F]+|[^\w\u0B80-\u0BFF\u0900-\u097F]+$', '', w.lower()) for w in t.split()]
words = [w for w in words if len(w) >= 2]
print("Tokens:", words)
