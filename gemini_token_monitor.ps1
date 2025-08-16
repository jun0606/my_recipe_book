# KIRO v7.0 Gemini CLI 무료 플랜 사용량 안전 모니터링 시스템
# 작성일: 2025-01-27 (업데이트)
# 목적: Gemini CLI 무료 플랜 제한사항 준수 및 안전 사용
# 
# 📊 Gemini CLI 무료 플랜 제한사항 (2025년 기준):
# - 일일 요청 제한: 1,000건 (RPD)
# - 분당 요청 제한: 60건 (RPM)
# - 할당 모델: Gemini 2.5 Pro → 초과시 Flash 모델 자동 전환
# - 안전 마진: 일일 800건, 분당 50건 권장

param(
    [Parameter(Mandatory=$true)]
    [string]$Command,
    
    [int]$TimeoutMs = 30000,
    
    [string]$LogFile = ".kiro/logs/gemini_token_usage.log"
)

# UTF-8 인코딩 설정
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 로그 디렉토리 생성
$LogDir = Split-Path $LogFile -Parent
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

# 시작 시간 기록
$StartTime = Get-Date
$SessionId = Get-Random

Write-Host "🤖 KIRO v7.0 Gemini CLI 안전 실행 시작" -ForegroundColor Green
Write-Host "📝 명령어: $Command" -ForegroundColor Cyan
Write-Host "🕐 시작 시간: $($StartTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Yellow
Write-Host "🆔 세션 ID: $SessionId" -ForegroundColor Magenta

# 로그 기록 시작
$LogEntry = @{
    SessionId = $SessionId
    StartTime = $StartTime
    Command = $Command
    Status = "STARTED"
}
$LogEntry | ConvertTo-Json | Add-Content -Path $LogFile -Encoding UTF8

try {
    # Gemini CLI 실행
    Write-Host "⚡ Gemini CLI 실행 중..." -ForegroundColor Yellow
    
    $ProcessInfo = Start-Process -FilePath "gemini" -ArgumentList $Command -NoNewWindow -PassThru -RedirectStandardOutput "temp_output.txt" -RedirectStandardError "temp_error.txt"
    
    # 타임아웃 처리
    $TimeoutSeconds = $TimeoutMs / 1000
    if (-not $ProcessInfo.WaitForExit($TimeoutSeconds * 1000)) {
        Write-Host "⏰ 타임아웃 발생 - 프로세스 강제 종료" -ForegroundColor Red
        $ProcessInfo.Kill()
        throw "Gemini CLI 실행 타임아웃"
    }
    
    # 출력 결과 읽기
    $Output = Get-Content "temp_output.txt" -Raw -Encoding UTF8
    $ErrorOutput = Get-Content "temp_error.txt" -Raw -Encoding UTF8
    
    Write-Host "✅ Gemini CLI 실행 완료" -ForegroundColor Green
    
    # 출력에서 토큰 사용량 정보 추출
    $TokenUsagePattern = "tokens used: (\d+)"
    $InputTokensPattern = "input tokens: (\d+)"
    $OutputTokensPattern = "output tokens: (\d+)"
    
    $TokensUsed = 0
    $InputTokens = 0
    $OutputTokens = 0
    
    if ($Output -match $TokenUsagePattern) {
        $TokensUsed = [int]$Matches[1]
    }
    if ($Output -match $InputTokensPattern) {
        $InputTokens = [int]$Matches[1]
    }
    if ($Output -match $OutputTokensPattern) {
        $OutputTokens = [int]$Matches[1]
    }
    
    # 종료 시간 및 실행 시간 계산
    $EndTime = Get-Date
    $Duration = $EndTime - $StartTime
    
    # 결과 출력
    Write-Host "`n📊 토큰 사용량 리포트" -ForegroundColor Cyan
    Write-Host "=" * 40 -ForegroundColor Cyan
    Write-Host "💰 총 사용 토큰: $TokensUsed" -ForegroundColor $(if ($TokensUsed -gt 0) { "Yellow" } else { "Green" })
    Write-Host "📥 입력 토큰: $InputTokens" -ForegroundColor White
    Write-Host "📤 출력 토큰: $OutputTokens" -ForegroundColor White
    Write-Host "⏱️ 실행 시간: $($Duration.TotalSeconds.ToString('F2'))초" -ForegroundColor White
    Write-Host "🕐 종료 시간: $($EndTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor White
    
    # 무료 플랜 제한사항 경고
    Write-Host "`n⚠️ 무료 플랜 사용량 체크" -ForegroundColor Yellow
    Write-Host "=" * 30 -ForegroundColor Yellow
    
    # 일일 사용량 체크 (로그에서 오늘 사용량 계산 필요)
    $TodayUsage = 1  # 현재 요청 포함
    $DailyLimit = 1000
    $SafeLimit = 800
    
    if ($TodayUsage -ge $DailyLimit) {
        Write-Host "🚨 일일 한도 도달! ($TodayUsage/$DailyLimit)" -ForegroundColor Red
        Write-Host "💡 내일까지 대기하거나 Flash 모델로 자동 전환됩니다." -ForegroundColor Yellow
    } elseif ($TodayUsage -ge $SafeLimit) {
        Write-Host "⚠️ 안전 한도 근접! ($TodayUsage/$SafeLimit)" -ForegroundColor Yellow
        Write-Host "💡 오늘 사용량을 줄이는 것을 권장합니다." -ForegroundColor Green
    } else {
        Write-Host "✅ 안전한 사용량 ($TodayUsage/$SafeLimit)" -ForegroundColor Green
    }
    
    # 로그 업데이트
    $LogEntry = @{
        SessionId = $SessionId
        StartTime = $StartTime
        EndTime = $EndTime
        Duration = $Duration.TotalSeconds
        Command = $Command
        TokensUsed = $TokensUsed
        InputTokens = $InputTokens
        OutputTokens = $OutputTokens
        Status = "COMPLETED"
        Output = $Output
        Error = $ErrorOutput
    }
    $LogEntry | ConvertTo-Json | Add-Content -Path $LogFile -Encoding UTF8
    
    # 출력 결과 반환
    Write-Host "`n📄 Gemini CLI 응답:" -ForegroundColor Green
    Write-Host $Output
    
    return @{
        Success = $true
        TokensUsed = $TokensUsed
        InputTokens = $InputTokens
        OutputTokens = $OutputTokens
        Duration = $Duration.TotalSeconds
        Output = $Output
    }
    
} catch {
    $EndTime = Get-Date
    $Duration = $EndTime - $StartTime
    
    Write-Host "❌ 오류 발생: $($_.Exception.Message)" -ForegroundColor Red
    
    # 오류 로그 기록
    $LogEntry = @{
        SessionId = $SessionId
        StartTime = $StartTime
        EndTime = $EndTime
        Duration = $Duration.TotalSeconds
        Command = $Command
        Status = "ERROR"
        Error = $_.Exception.Message
    }
    $LogEntry | ConvertTo-Json | Add-Content -Path $LogFile -Encoding UTF8
    
    return @{
        Success = $false
        Error = $_.Exception.Message
        Duration = $Duration.TotalSeconds
    }
    
} finally {
    # 임시 파일 정리
    if (Test-Path "temp_output.txt") { Remove-Item "temp_output.txt" -Force }
    if (Test-Path "temp_error.txt") { Remove-Item "temp_error.txt" -Force }
}