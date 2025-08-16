# KIRO v7.0 Desktop-Commander 안전 래퍼 시스템
# 작성일: 2025-01-27
# 목적: Desktop-Commander 세션 관리 및 좀비 프로세스 방지

param(
    [Parameter(Mandatory=$true)]
    [string]$Command,
    
    [int]$TimeoutMs = 20000,
    
    [switch]$CleanupFirst
)

# UTF-8 인코딩 설정
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "🛡️ KIRO v7.0 Desktop-Commander 안전 실행" -ForegroundColor Green

# 1단계: 기존 좀비 세션 정리 (선택적)
if ($CleanupFirst) {
    Write-Host "🧹 기존 세션 정리 중..." -ForegroundColor Yellow
    
    try {
        # 활성 세션 목록 확인
        $Sessions = & mcp_desktop_commander_list_sessions
        
        if ($Sessions -match "PID: (\d+)") {
            $PIDs = [regex]::Matches($Sessions, "PID: (\d+)") | ForEach-Object { $_.Groups[1].Value }
            
            foreach ($PID in $PIDs) {
                Write-Host "🔄 세션 $PID 정리 중..." -ForegroundColor Cyan
                try {
                    & mcp_desktop_commander_force_terminate -pid $PID
                    Start-Sleep -Milliseconds 500
                } catch {
                    Write-Host "⚠️ 세션 $PID 정리 실패: $($_.Exception.Message)" -ForegroundColor Yellow
                }
            }
        }
        
        Write-Host "✅ 세션 정리 완료" -ForegroundColor Green
        Start-Sleep -Seconds 2
        
    } catch {
        Write-Host "⚠️ 세션 정리 중 오류: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# 2단계: 안전한 명령어 실행
try {
    Write-Host "⚡ 명령어 실행: $Command" -ForegroundColor Cyan
    
    # Desktop-Commander로 프로세스 시작
    $StartResult = & mcp_desktop_commander_start_process -command $Command -timeout_ms $TimeoutMs
    
    if ($StartResult -match "Process started with PID (\d+)") {
        $PID = [int]$Matches[1]
        Write-Host "🆔 프로세스 PID: $PID" -ForegroundColor Green
        
        # 출력 읽기 시도
        $MaxRetries = 3
        $RetryCount = 0
        $Output = ""
        
        while ($RetryCount -lt $MaxRetries) {
            try {
                Start-Sleep -Seconds 2
                $ReadResult = & mcp_desktop_commander_read_process_output -pid $PID -timeout_ms ($TimeoutMs / 2)
                
                if ($ReadResult -and $ReadResult -notmatch "No active session found") {
                    $Output = $ReadResult
                    break
                } else {
                    $RetryCount++
                    Write-Host "🔄 재시도 $RetryCount/$MaxRetries..." -ForegroundColor Yellow
                }
                
            } catch {
                $RetryCount++
                Write-Host "⚠️ 읽기 시도 $RetryCount 실패: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
        
        # 프로세스 정리
        try {
            & mcp_desktop_commander_force_terminate -pid $PID
            Write-Host "🧹 프로세스 $PID 정리 완료" -ForegroundColor Green
        } catch {
            Write-Host "⚠️ 프로세스 정리 실패: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        return @{
            Success = $true
            PID = $PID
            Output = $Output
            Command = $Command
        }
        
    } else {
        throw "프로세스 시작 실패: $StartResult"
    }
    
} catch {
    Write-Host "❌ 실행 오류: $($_.Exception.Message)" -ForegroundColor Red
    
    return @{
        Success = $false
        Error = $_.Exception.Message
        Command = $Command
    }
}