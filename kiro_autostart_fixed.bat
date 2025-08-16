@echo off
chcp 65001 >nul
REM KIRO Auto Start System
REM Automatically executed when Kiro IDE starts to complete all preparations

echo KIRO Auto Start System
echo ========================

REM Set current directory to project root
cd /d "%~dp0"

REM Check and set PowerShell execution policy
powershell -Command "if ((Get-ExecutionPolicy) -eq 'Restricted') { Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force }"

REM Execute Kiro initialization script
echo Initializing Kiro...
powershell -ExecutionPolicy Bypass -File ".\kiro_init.ps1" -Quick

REM Check result
if %ERRORLEVEL% EQU 0 (
    echo Kiro initialization successful!
    echo You can now start working in Kiro IDE.
) else (
    echo Kiro initialization failed!
    echo Please manually run .\kiro_init.ps1
)

echo.
echo Main Commands:
echo   • "Show recommended tasks" - Get task recommendations for current situation
echo   • "Check project status" - Overall project status check
echo   • "Check Gemini CLI status" - Usage and configuration check
echo   • "Show spec list" - Active specs and progress

REM Auto close after 3 seconds (for immediate visibility in IDE)
timeout /t 3 /nobreak >nul