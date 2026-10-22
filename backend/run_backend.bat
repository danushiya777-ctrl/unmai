@echo off
cd /d "%~dp0"
echo Starting Unmai FastAPI Backend on http://localhost:8000 ...
.venv\Scripts\python.exe -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
pause
