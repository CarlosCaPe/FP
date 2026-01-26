@echo off
REM Run the IROC Video Wall Dashboard
echo Starting IROC Video Wall Dashboard...
echo.
echo Make sure you have installed requirements:
echo   pip install -r requirements.txt
echo.
streamlit run app.py --server.port 8501 --server.headless true
