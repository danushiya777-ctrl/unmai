# Unmai Verification Backend

The backend engine for **Unmai** (fake news and misinformation checker). It verifies claims, news URLs, images, and videos against authoritative real-world sources with zero hallucinated references.

---

## Architecture Overview

```
Flutter Client (No API Keys)
         │
         ▼  (HTTPS / HTTP)
FastAPI Backend (/verify)
         │
         ├── 1. Input Processing (Text normalization, Trafilatura web article extraction, Tesseract OCR)
         ├── 2. Claim Extraction (Factual claim isolation, skipping opinion)
         ├── 3. Evidence Retrieval (Google Fact Check Tools API + Wikipedia REST API)
         ├── 4. Source Classification & Deduplication (gov.in, who.int, altnews.in, boomlive.in, etc.)
         ├── 5. Verdict Engine (Evidence-only evaluation: Supported / Contradicted / Unverified)
         ├── 6. Overall Verdict & Score Info (True / False / Misleading / Can't verify, Evidence Strength)
         ├── 7. Media Check (EXIF metadata, C2PA, AI camera tag detection)
         └── 8. SQLite Content-Hash Cache (24-hour TTL for deduplicating repeated forwards)
```

---

## Environment Variables

Create a `.env` file inside `/backend` (copied from `.env.example`):

```bash
# Google Fact Check Tools API Key (Optional but recommended)
GOOGLE_FACTCHECK_API_KEY=your_google_cloud_api_key_here

# Gemini API Key (Optional for deep reasoning)
GEMINI_API_KEY=your_gemini_api_key_here

# Server Configuration
HOST=0.0.0.0
PORT=8000
```

> **Security Guarantee**: The Flutter application contains **zero API keys**. All credentials reside securely in this backend.

---

## Local Development Setup

### 1. Requirements
- Python 3.10+ (Recommended Python 3.12)
- (Optional for OCR) Tesseract OCR with `eng`, `tam`, `hin` language data

### 2. Setup Virtual Environment
```bash
cd backend
python -m venv .venv

# On Windows:
.venv\Scripts\activate

# On macOS/Linux:
source .venv/bin/activate

pip install -r requirements.txt
```

### 3. Run the Server
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```
Visit http://localhost:8000/docs for the interactive Swagger API documentation or http://localhost:8000/health for health status.

---

## Testing Real Devices via ngrok

To test the mobile app running on a physical Android or iOS smartphone connected over 4G/5G or separate Wi-Fi:

1. Install [ngrok](https://ngrok.com/) if you haven't already.
2. In a separate terminal, expose port 8000:
   ```bash
   ngrok http 8000
   ```
3. Copy the generated forwarding HTTPS URL (e.g. `https://xxxx-xx-xx-xx.ngrok-free.app`).
4. In the Unmai Flutter App:
   - Go to **Settings** (`/settings`).
   - Under **Backend Server**, enter the ngrok URL.
   - Tap **Test Connection** to verify live communication.

---

## Cloud Deployment

### Option 1: Render
1. Push your repository to GitHub.
2. In [Render Dashboard](https://dashboard.render.com/), choose **New Web Service**.
3. Point to the repository and select **Docker** environment (or Python environment).
   - Root Directory: `backend`
   - Build Command: `pip install -r requirements.txt`
   - Start Command: `uvicorn main:app --host 0.0.0.0 --port $PORT`
4. In **Environment Variables**, add:
   - `GOOGLE_FACTCHECK_API_KEY` (if available)
   - `GEMINI_API_KEY` (if available)

### Option 2: Railway
1. Click **New Project** -> **Deploy from GitHub repo**.
2. Select repository, set root directory to `/backend`.
3. Railway will automatically detect the `Dockerfile`.
4. Add environment variables under **Variables** tab.

### Option 3: Google Cloud Run
1. Build and push container to Google Artifact Registry:
   ```bash
   gcloud builds submit --tag gcr.io/[PROJECT_ID]/unmai-backend ./backend
   ```
2. Deploy to Cloud Run:
   ```bash
   gcloud run deploy unmai-backend \
     --image gcr.io/[PROJECT_ID]/unmai-backend \
     --platform managed \
     --region asia-south1 \
     --allow-unauthenticated \
     --set-env-vars GOOGLE_FACTCHECK_API_KEY=your_key
   ```

---

## API Endpoints

### 1. `GET /health`
Returns system status, active capabilities, and integrations.
```json
{
  "app": "Unmai",
  "status": "online",
  "version": "1.0.0",
  "has_google_factcheck_key": true,
  "cache_enabled": true
}
```

### 2. `POST /verify`
Verifies text forwards, web URLs, or uploaded media. Accepts `multipart/form-data` or `application/json`.

**Input Parameters:**
- `text` (string, optional): The WhatsApp forward, post, or claim statement.
- `url` (string, optional): Web article URL.
- `language` (string, optional): Target language for reasoning and summary (`en`, `ta`, `hi`). Default: `en`.
- `file` (file upload, optional): Image (`.jpg`, `.png`, `.webp`) or video.

**Output Structure:**
Matches Flutter `Investigation` domain models (`investigation.dart`).

---

## Running Automated Tests

Run the full real-world test suite (12 real historical claims):
```bash
python tests/test_runner.py
```

Run unit and integration pipeline assertions:
```bash
pytest tests/test_pipeline.py
```
