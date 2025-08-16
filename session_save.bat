@echo off
chcp 65001 > nul
echo Session Save System (No Token Required)
echo ========================================

set PROJECT_ROOT=C:\Users\junlyn\my_recipe_book
set TIMESTAMP=%date:~0,4%-%date:~5,2%-%date:~8,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%

echo Saving session... (%TIMESTAMP%)

REM 1. Smart Recovery Info (General case - 150 tokens)
echo Smart Session Recovery (Core Only) > "%PROJECT_ROOT%\smart_recovery_info.txt"
echo ================================ >> "%PROJECT_ROOT%\smart_recovery_info.txt"
echo. >> "%PROJECT_ROOT%\smart_recovery_info.txt"
echo Current Status: my_recipe_book Flutter app, Task1-4 completed, BakingCalculator Phase2 done >> "%PROJECT_ROOT%\smart_recovery_info.txt"
echo MCP: 15 servers active, check .kiro/settings/mcp.json >> "%PROJECT_ROOT%\smart_recovery_info.txt"
echo Backup: workflow_backup_2025_07_29/ folder >> "%PROJECT_ROOT%\smart_recovery_info.txt"
echo Guides: KIRO_MASTER_GUIDE.md, docs/next_steps_action_plan.md >> "%PROJECT_ROOT%\smart_recovery_info.txt"
echo Next: new features/optimization/testing >> "%PROJECT_ROOT%\smart_recovery_info.txt"

REM 2. Lightweight Recovery Info (Complex tasks - 300 tokens)
echo Lightweight Session Recovery Info > "%PROJECT_ROOT%\lightweight_recovery_info.txt"
echo ================================ >> "%PROJECT_ROOT%\lightweight_recovery_info.txt"
echo. >> "%PROJECT_ROOT%\lightweight_recovery_info.txt"
echo Project: my_recipe_book Flutter app >> "%PROJECT_ROOT%\lightweight_recovery_info.txt"
echo Status: Task1,2,3,4 completed >> "%PROJECT_ROOT%\lightweight_recovery_info.txt"
echo BakingCalculator: Phase2 done, 100%% tests passed >> "%PROJECT_ROOT%\lightweight_recovery_info.txt"
echo MCP Servers: 15 active >> "%PROJECT_ROOT%\lightweight_recovery_info.txt"
echo Backup: workflow_backup_2025_07_29/ >> "%PROJECT_ROOT%\lightweight_recovery_info.txt"
echo. >> "%PROJECT_ROOT%\lightweight_recovery_info.txt"
echo Key Files: >> "%PROJECT_ROOT%\lightweight_recovery_info.txt"
echo - KIRO_MASTER_GUIDE.md >> "%PROJECT_ROOT%\lightweight_recovery_info.txt"
echo - docs/next_steps_action_plan.md >> "%PROJECT_ROOT%\lightweight_recovery_info.txt"
echo - mcp_shared_access.md >> "%PROJECT_ROOT%\lightweight_recovery_info.txt"
echo. >> "%PROJECT_ROOT%\lightweight_recovery_info.txt"
echo Next Tasks: new features or optimization >> "%PROJECT_ROOT%\lightweight_recovery_info.txt"

REM 3. Emergency Message (50 tokens)
echo Task1-4 completed, BakingCalculator done, MCP 15 servers active > "%PROJECT_ROOT%\emergency_recovery_msg.txt"

REM 4. Git Status Save (No tokens required)
cd /d "%PROJECT_ROOT%"
git status > "%PROJECT_ROOT%\git_status_%TIMESTAMP%.txt" 2>&1

echo Session save completed!
echo Generated files:
echo    - smart_recovery_info.txt (General - 150 tokens)
echo    - lightweight_recovery_info.txt (Complex tasks - 300 tokens)  
echo    - emergency_recovery_msg.txt (Emergency - 50 tokens)
echo    - git_status_%TIMESTAMP%.txt (Git status)

pause