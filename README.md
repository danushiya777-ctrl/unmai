# Unmai (உண்மை) - Check Before You Share

**Unmai** (Tamil for "truth") is a consumer fact-checking app built with Flutter and Python. It is designed to help everyday users verify suspicious WhatsApp forwards, screenshots, images, videos, and news links in simple, human language without "AI" hype or technical jargon.

---

## Key Features

1. **Human & Accessible Design**:
   - Clean, light theme (soft off-white background, blue accent, 12-16px rounded cards).
   - Accessible verdicts with distinct colors, icons, and text labels:
     - **True**: Green + Check icon
     - **False**: Red + Cancel icon
     - **Misleading**: Amber + Warning icon
     - **Can't verify**: Slate grey-blue + Help icon
   - Language switcher supporting **English**, **Tamil (தமிழ்)**, and **Hindi (हिन्दी)**.

2. **Android Share Intent Integration**:
   - Receive forwards and media directly from WhatsApp and other apps via Android Share Intent (`text/plain`, `image/*`, `video/*`).
   - Automatically opens shared content into the verification pipeline.

3. **8-Part Transparent Result Report**:
   1. Verdict banner
   2. One-sentence plain-language reason
   3. Correctness meter with claims breakdown & evidence strength
   4. Media check card with method and limitations disclosures
   5. Confirmed by source cards (if True)
   6. Why this is false reason & contradicting sources (if False/Misleading)
   7. Expandable claim-by-claim breakdown with citations
   8. One-tap "Share correction card" (renders a high-res image to post back into WhatsApp groups)

4. **Local Device History**:
   - Offline local persistence powered by Hive.
   - Searchable and filterable by verdict chips.

5. **Demo Mode Rehearsal**:
   - Toggle between instant realistic rehearsal reports and live server verification.
   - Includes two preloaded demo reports:
     - (1) Recycled disaster photograph (False)
     - (2) Official nationwide HPV vaccination campaign (True)

---

## How to Run the App

### 1. Run Flutter App (Android Emulator / Device)
Ensure your Android emulator or physical device is connected:
```bash
# Check connected devices
flutter devices

# Run on the connected emulator
flutter run -d emulator-5554
```

### 2. Testing WhatsApp Share Intent
1. Open the Android Emulator.
2. In WhatsApp (or any browser/notes app), select any text or photo.
3. Tap **Share** -> Choose **Unmai**.
4. The app will launch immediately into the **Verify** screen with the shared text/media pre-populated.

### 3. Run the Python (FastAPI) Backend
The backend runs using `uv` or any standard Python 3.11/3.12 environment:
```bash
cd backend

# Install dependencies using uv
& "$HOME\.local\bin\uv.exe" pip install -r requirements.txt

# Run backend with uvicorn
& "$HOME\.local\bin\uv.exe" run uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```
The backend will be live at `http://127.0.0.1:8000` (and accessible from the Android emulator at `http://10.0.2.2:8000`).

---

## Switching Between Demo and Live Data

1. Open **Unmai**.
2. Tap the **Settings** tab in the bottom navigation bar.
3. Toggle the **Demo Mode** switch:
   - **ON (Default)**: Instant practice with pre-loaded realistic scenarios without requiring backend servers.
   - **OFF**: Direct live verification requests to `http://10.0.2.2:8000/verify` (or configured API URL).

---

## Verification Rules (Non-Negotiable)

- **No Hallucinated Sources**: Sources are only displayed if returned by actual fact-checking databases.
- **Unverified ≠ False**: If no evidence is found, the verdict is strictly **"Can't verify"** (Unverified) with an explanation, never False.
- **Transparent Confidence**: No black-box LLM percentages; scores represent explicit fractions of verified claims.

---

## Running Automated Tests

```bash
flutter test
flutter analyze
```
All **12 unit and widget tests pass** with **zero analyzer errors**.
