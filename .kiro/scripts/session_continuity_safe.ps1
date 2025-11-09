# Encoding: UTF-8 without BOM
# KIRO v7.0 Session Continuity System (Encoding Safe)
# Safe for Windows Console with Korean support

# Set console encoding to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

param(
    [string]$Action = "save",
    [string]$SessionId = "",
    [string]$Context = ""
)

function Save-SessionContext {
    param($SessionId, $Context)
    
    $SessionDir = ".kiro\session\conversations"
    if (!(Test-Path $SessionDir)) {
        New-Item -ItemType Directory -Path $SessionDir -Force
    }
    
    $SessionFile = "$SessionDir\session_$SessionId.json"
    $SessionData = @{
        session_id = $SessionId
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        context = $Context
        project_path = (Get-Location).Path
        kiro_version = "v7.0"
        mcp_servers = 13
        active_servers = 12
    }
    
    $SessionData | ConvertTo-Json -Depth 10 | Out-File -FilePath $SessionFile -Encoding UTF8
    Write-Host "Session context saved: $SessionFile" -ForegroundColor Green
}

function Restore-SessionContext {
    param($SessionId)
    
    $SessionFile = ".kiro\session\conversations\session_$SessionId.json"
    if (Test-Path $SessionFile) {
        $SessionData = Get-Content $SessionFile | ConvertFrom-Json
        Write-Host "Session context restored from: $SessionFile" -ForegroundColor Green
        Write-Host "Session ID: $($SessionData.session_id)" -ForegroundColor Cyan
        Write-Host "Timestamp: $($SessionData.timestamp)" -ForegroundColor Cyan
        Write-Host "KIRO Version: $($SessionData.kiro_version)" -ForegroundColor Cyan
        Write-Host "MCP Servers: $($SessionData.mcp_servers) total, $($SessionData.active_servers) active" -ForegroundColor Cyan
        return $SessionData
    } else {
        Write-Host "Session file not found: $SessionFile" -ForegroundColor Red
        return $null
    }
}

function List-Sessions {
    $SessionDir = ".kiro\session\conversations"
    if (Test-Path $SessionDir) {
        $Sessions = Get-ChildItem $SessionDir -Filter "session_*.json"
        Write-Host "Available sessions:" -ForegroundColor Cyan
        foreach ($Session in $Sessions) {
            $SessionData = Get-Content $Session.FullName | ConvertFrom-Json
            Write-Host "  $($SessionData.session_id) - $($SessionData.timestamp)" -ForegroundColor White
        }
    } else {
        Write-Host "No sessions found" -ForegroundColor Yellow
    }
}

# Main execution
switch ($Action.ToLower()) {
    "save" {
        if ($SessionId -and $Context) {
            Save-SessionContext -SessionId $SessionId -Context $Context
        } else {
            Write-Host "Usage: -Action save -SessionId <id> -Context <context>" -ForegroundColor Red
        }
    }
    "restore" {
        if ($SessionId) {
            Restore-SessionContext -SessionId $SessionId
        } else {
            Write-Host "Usage: -Action restore -SessionId <id>" -ForegroundColor Red
        }
    }
    "list" {
        List-Sessions
    }
    default {
        Write-Host "Available actions: save, restore, list" -ForegroundColor Yellow
        Write-Host "Example: .\session_continuity_safe.ps1 -Action save -SessionId 'abc123' -Context 'Working on KIRO v7.0'" -ForegroundColor Yellow
    }
}