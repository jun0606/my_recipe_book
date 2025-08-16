@echo off
echo Kiro Auto Start System
echo ======================

cd /d "%~dp0"

echo Initializing Kiro...
powershell -ExecutionPolicy Bypass -File ".\kiro_init_simple.ps1" -Quick

if %ERRORLEVEL% EQU 0 (
    echo Kiro initialization successful!
    echo You can now start working with Kiro IDE.
) else (
    echo Kiro initialization failed!
    echo Try running .\kiro_init_simple.ps1 manually.
)

echo.
echo Main Commands:
echo   - "Show recommended tasks"
echo   - "Check project status" 
echo   - "Check Gemini CLI status"
echo   - "Show active specs"

timeout /t 3 /nobreak >nul