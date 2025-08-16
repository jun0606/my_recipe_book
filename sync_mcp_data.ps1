# MCP 데이터 동기화 스크립트

# Kiro와 Gemini CLI 간 MCP 데이터 실시간 동기화

function Sync-MCPData {
    param(
        [string]$SourcePath = ".kiro/mcp_cache",
        [string]$TargetPath = ".gemini/mcp_cache"
    )
    
    # 캐시 디렉토리 생성
    if (!(Test-Path $SourcePath)) { New-Item -ItemType Directory -Path $SourcePath }
    if (!(Test-Path $TargetPath)) { New-Item -ItemType Directory -Path $TargetPath }
    
    # 파일 변경 감지 및 동기화
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = $SourcePath
    $watcher.Filter = "*.json"
    $watcher.EnableRaisingEvents = $true
    
    # 변경 이벤트 처리
    Register-ObjectEvent -InputObject $watcher -EventName "Changed" -Action {
        $changedFile = $Event.SourceEventArgs.FullPath
        $targetFile = $changedFile.Replace($SourcePath, $TargetPath)
        
        Write-Host "Syncing: $changedFile -> $targetFile"
        Copy-Item $changedFile $targetFile -Force
    }
    
    Write-Host "MCP Data Sync Started. Press Ctrl+C to stop."
    try {
        while ($true) { Start-Sleep 1 }
    } finally {
        $watcher.Dispose()
    }
}

# 실행
Sync-MCPData