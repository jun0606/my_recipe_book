@echo off
chcp 65001 > nul
echo Lightweight Session Recovery System (Complex Tasks)
echo ==================================================

set PROJECT_ROOT=C:\Users\junlyn\my_recipe_book

if exist "%PROJECT_ROOT%\lightweight_recovery_info.txt" (
    echo Lightweight Recovery Info:
    echo ================================
    type "%PROJECT_ROOT%\lightweight_recovery_info.txt"
    echo ================================
    echo.
    echo Provide this info to new AI session!
    echo Expected token usage: ~300 tokens
) else (
    echo lightweight_recovery_info.txt file not found.
    echo Please run "session_save.bat" first.
)

pause