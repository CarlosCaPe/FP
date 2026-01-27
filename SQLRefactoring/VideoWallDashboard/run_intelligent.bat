@echo off
REM ============================================================
REM IROC Intelligent Dashboard - Run Script
REM ============================================================
REM Launches the intelligent dashboard with integrated chat
REM ============================================================

echo.
echo  ========================================
echo   IROC Intelligent Dashboard
echo   Video Wall + Chat Interface
echo  ========================================
echo.

REM Check if virtual environment exists
if exist "..\..\.venv\Scripts\activate.bat" (
    echo [*] Activating virtual environment...
    call ..\..\.venv\Scripts\activate.bat
) else (
    echo [!] Virtual environment not found, using system Python
)

REM Check dependencies
echo [*] Checking dependencies...
pip show streamlit >nul 2>&1
if errorlevel 1 (
    echo [*] Installing requirements...
    pip install -r requirements.txt
)

echo.
echo [*] Starting Intelligent Dashboard...
echo [*] Open browser at: http://localhost:8501
echo.

REM Run the intelligent dashboard
streamlit run intelligent_dashboard.py --server.port 8501 --theme.base dark

pause
