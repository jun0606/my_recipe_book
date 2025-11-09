@echo off
REM Encoding: UTF-8 without BOM
REM KIRO v7.0 Auto-start Script (Encoding Safe)
REM Safe for Windows Console with Korean support

chcp 65001 >nul 2>&1

echo KIRO v7.0 Auto-start initiated...
echo Project: my_recipe_book
echo MCP Servers: 13 total (12 active)

REM Check if PowerShell is available
powershell -Command "Write-Host 'PowerShell available' -ForegroundColor Green"
if %errorlevel% neq 0 (
    echo PowerShell not available, using basic initialization
    goto :basic_init
)

REM Run PowerShell initialization
powershell -ExecutionPolicy Bypass -File ".kiro\scripts\kiro_v7_install_safe.ps1"
if %errorlevel% equ 0 (
    echo KIRO v7.0 initialization completed successfully
) else (
    echo KIRO v7.0 initialization completed with warnings
)

goto :end

:basic_init
echo Basic initialization mode
echo Please run PowerShell script manually if needed

:end
echo KIRO v7.0 ready for development
pause