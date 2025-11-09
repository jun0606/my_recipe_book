# KIRO v7.0 Encoding Safe Guide

## Problem Analysis

### Korean Text Issues in Windows Console
- **Problem**: Korean characters display as garbled text (���)
- **Cause**: UTF-8 BOM vs PowerShell console encoding mismatch
- **Solution**: Use UTF-8 without BOM + explicit encoding settings

### Emoji Issues in Windows Console
- **Problem**: Emojis may not display correctly in older Windows versions
- **Cause**: Limited Unicode support in Windows Console
- **Solution**: Use text alternatives or ensure UTF-8 encoding

## Solutions Implemented

### 1. PowerShell Scripts (.ps1)
```powershell
# Encoding: UTF-8 without BOM
# Set console encoding to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
```

### 2. Batch Files (.bat)
```batch
@echo off
REM Encoding: UTF-8 without BOM
chcp 65001 >nul 2>&1
```

### 3. Markdown Files (.md)
- Save as UTF-8 without BOM
- Use English for critical system messages
- Korean text for documentation only

## Safe Script Versions Created

### Core Scripts
1. **kiro_v7_install_safe.ps1** - Encoding safe installation
2. **kiro_autostart_safe.bat** - Safe auto-start script
3. **session_continuity_safe.ps1** - Session management script

### Usage Examples
```powershell
# Install MCP servers safely
.\.kiro\scripts\kiro_v7_install_safe.ps1

# Auto-start KIRO safely
.\.kiro\scripts\kiro_autostart_safe.bat

# Manage sessions safely
.\.kiro\scripts\session_continuity_safe.ps1 -Action save -SessionId "abc123" -Context "Working on KIRO v7.0"
```

## Best Practices

### For PowerShell Scripts
1. Always add encoding header: `# Encoding: UTF-8 without BOM`
2. Set console encoding at script start
3. Use English for system messages
4. Test on different Windows versions

### For Batch Files
1. Set code page to UTF-8: `chcp 65001`
2. Suppress output: `>nul 2>&1`
3. Use REM for comments instead of ::

### For Documentation
1. Save as UTF-8 without BOM
2. Use English for critical instructions
3. Korean text acceptable for user documentation

## Testing Checklist

- [ ] PowerShell 5.1 compatibility
- [ ] PowerShell 7+ compatibility
- [ ] Windows 10 console
- [ ] Windows 11 console
- [ ] Korean text display
- [ ] Emoji fallback handling

## Migration Guide

### Old Script Pattern
```powershell
Write-Host "🚀 KIRO v7.0 MCP 서버 설치 시작" -ForegroundColor Cyan
```

### New Safe Pattern
```powershell
# Encoding: UTF-8 without BOM
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "KIRO v7.0 MCP Server Installation Started" -ForegroundColor Cyan
```

This ensures compatibility across all Windows environments while maintaining functionality.