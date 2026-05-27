@echo off
title AgriLens AI Setup and Launcher
echo =================================================================
echo             AgriLens AI Backend setup starting...
echo =================================================================
echo.

cd /d "%~dp0agrilens_backend"

echo [1/4] Creating Python virtual environment (venv)...
python -m venv venv
if %errorlevel% neq 0 (
    echo Error: Failed to create virtual environment. Please check Python installation.
    pause
    exit /b %errorlevel%
)
echo Done.
echo.

echo [2/4] Activating virtual environment and updating pip...
call venv\Scripts\activate.bat
python -m pip install --upgrade pip
echo.

echo [3/4] Installing backend dependencies (FastAPI, Uvicorn, etc.)...
pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo Error: Failed to install backend dependencies.
    pause
    exit /b %errorlevel%
)
echo Done.
echo.

echo [4/4] Setting up .env configuration file...
if not exist .env (
    echo # AgriLens AI API Configuration > .env
    echo GEMINI_API_KEY="" >> .env
    echo OPENWEATHER_API_KEY="" >> .env
    echo FIREBASE_CREDENTIALS_PATH="" >> .env
    echo Created template .env file in agrilens_backend/
) else (
    echo File .env already exists. Skipping creation.
)
echo.

echo =================================================================
echo Setup Completed Successfully! Starting AgriLens AI FastAPI Server...
echo =================================================================
echo.

python main.py

pause
