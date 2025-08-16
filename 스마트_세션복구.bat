@echo off
chcp 65001 > nul
echo Smart Session Recovery System (General)
echo ======================================

set PROJECT_ROOT=C:\Users\junlyn\my_recipe_book

if exist "%PROJECT_ROOT%\smart_recovery_info.txt" (
    echo Smart Recovery Info:
    echo ================================
    type "%PROJECT_ROOT%\smart_recovery_info.txt"
    echo ================================
    echo.
    echo Provide this info to new AI session!
    echo Expected token usage: ~150 tokens
) else (
    echo smart_recovery_info.txt file not found.
    echo Please run "session_save.bat" first.
)

pause