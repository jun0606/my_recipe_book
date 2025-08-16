@echo off
chcp 65001 > nul
echo Emergency Session Recovery (Minimal Tokens)
echo ============================================

set PROJECT_ROOT=C:\Users\junlyn\my_recipe_book

if exist "%PROJECT_ROOT%\emergency_recovery_msg.txt" (
    echo Emergency Recovery Message:
    echo ================================
    type "%PROJECT_ROOT%\emergency_recovery_msg.txt"
    echo ================================
    echo.
    echo Provide this one line to new AI session!
    echo Expected token usage: ~50 tokens
) else (
    echo emergency_recovery_msg.txt file not found.
    echo Please run "session_save.bat" first.
    echo.
    echo For emergency, use this message directly:
    echo "Task1-4 completed, BakingCalculator done, MCP 15 servers active"
)

pause