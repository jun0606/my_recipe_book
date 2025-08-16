# KIRO v7.0 Gemini CLI 무료 플랜 사용량 관리자
# 작성일: 2025-01-27
# 목적: Gemini CLI 무료 플랜 제한사항 준수 및 최적 사용

param(
    [ValidateSet("CHECK", "REQUEST", "RESET", "STATUS")]
    [string]$Action = "CHECK",
    
    [string]$LogFile = ".kiro/logs/gemini_daily_usage.log"
)

# UTF-8 인코딩 설정
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 무료 플랜 제한사항 (2025년 기준)
$DAILY_LIMIT = 1000        # 일일 요청 한도
$MINUTE_LIMIT = 60         # 분당 요청 한도
$SAFE_DAILY_LIMIT = 800    # 안전 일일 한도 (80%)
$SAFE_MINUTE_LIMIT = 50    # 안전 분당 한도 (83%)

# 로그 디렉토리 생성
$LogDir = Split-Path $LogFile -Parent
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

function Get-TodayUsage {
    if (-not (Test-Path $LogFile)) {
        return 0
    }
    
    $Today = (Get-Date).Date
    $TodayLogs = Get-Content $LogFile -ErrorAction SilentlyContinue | Where-Object {
        if ($_ -match '"Date":"([^"]+)"') {
            $LogDate = [DateTime]::Parse($Matches[1]).Date
            return $LogDate -eq $Today
        }
        return $false
    }
    
    return $TodayLogs.Count
}

function Get-RecentMinuteUsage {
    if (-not (Test-Path $LogFile)) {
        return 0
    }
    
    $OneMinuteAgo = (Get-Date).AddMinutes(-1)
    $RecentLogs = Get-Content $LogFile -ErrorAction SilentlyContinue | Where-Object {
        if ($_ -match '"DateTime":"([^"]+)"') {
            $LogDateTime = [DateTime]::Parse($Matches[1])
            return $LogDateTime -ge $OneMinuteAgo
        }
        return $false
    }
    
    return $RecentLogs.Count
}

function Add-UsageLog {
    $LogEntry = @{
        DateTime = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        Date = (Get-Date).ToString("yyyy-MM-dd")
        Action = "REQUEST"
        DailyCount = (Get-TodayUsage) + 1
    }
    
    $LogEntry | ConvertTo-Json -Compress | Add-Content -Path $LogFile -Encoding UTF8
}

function Show-UsageStatus {
    $TodayUsage = Get-TodayUsage
    $RecentMinuteUsage = Get-RecentMinuteUsage
    
    Write-Host "📊 KIRO v7.0 Gemini CLI 무료 플랜 사용량 현황" -ForegroundColor Cyan
    Write-Host "=" * 50 -ForegroundColor Cyan
    Write-Host "📅 날짜: $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor White
    
    # 일일 사용량 상태
    Write-Host "`n📈 일일 사용량 분석" -ForegroundColor Green
    Write-Host "-" * 25 -ForegroundColor Green
    Write-Host "🔢 오늘 사용량: $TodayUsage / $DAILY_LIMIT (공식 한도)" -ForegroundColor White
    Write-Host "🛡️ 안전 한도: $TodayUsage / $SAFE_DAILY_LIMIT (권장 한도)" -ForegroundColor White
    
    $DailyPercentage = if ($DAILY_LIMIT -gt 0) { [math]::Round(($TodayUsage / $DAILY_LIMIT) * 100, 1) } else { 0 }
    $SafePercentage = if ($SAFE_DAILY_LIMIT -gt 0) { [math]::Round(($TodayUsage / $SAFE_DAILY_LIMIT) * 100, 1) } else { 0 }
    
    Write-Host "📊 사용률: $DailyPercentage% (공식) / $SafePercentage% (안전)" -ForegroundColor White
    
    # 일일 상태 판정
    if ($TodayUsage -ge $DAILY_LIMIT) {
        Write-Host "🚨 일일 한도 초과! Flash 모델로 자동 전환됨" -ForegroundColor Red
        $CanProceed = $false
    } elseif ($TodayUsage -ge $SAFE_DAILY_LIMIT) {
        Write-Host "⚠️ 안전 한도 초과! 사용량 주의 필요" -ForegroundColor Yellow
        $CanProceed = $true
    } elseif ($TodayUsage -ge ($SAFE_DAILY_LIMIT * 0.75)) {
        Write-Host "🔔 안전 한도 75% 도달" -ForegroundColor Yellow
        $CanProceed = $true
    } else {
        Write-Host "✅ 안전한 사용량 수준" -ForegroundColor Green
        $CanProceed = $true
    }
    
    # 분당 사용량 상태
    Write-Host "`n⏱️ 분당 사용량 분석" -ForegroundColor Green
    Write-Host "-" * 25 -ForegroundColor Green
    Write-Host "🔢 최근 1분: $RecentMinuteUsage / $MINUTE_LIMIT (공식 한도)" -ForegroundColor White
    Write-Host "🛡️ 안전 한도: $RecentMinuteUsage / $SAFE_MINUTE_LIMIT (권장 한도)" -ForegroundColor White
    
    # 분당 상태 판정
    if ($RecentMinuteUsage -ge $MINUTE_LIMIT) {
        Write-Host "🚨 분당 한도 초과! 1분 대기 필요" -ForegroundColor Red
        $CanProceed = $false
    } elseif ($RecentMinuteUsage -ge $SAFE_MINUTE_LIMIT) {
        Write-Host "⚠️ 분당 안전 한도 초과! 속도 조절 필요" -ForegroundColor Yellow
    } else {
        Write-Host "✅ 안전한 분당 사용량" -ForegroundColor Green
    }
    
    # 권장사항
    Write-Host "`n💡 권장사항" -ForegroundColor Cyan
    Write-Host "-" * 15 -ForegroundColor Cyan
    
    $RemainingDaily = $SAFE_DAILY_LIMIT - $TodayUsage
    $RemainingMinute = $SAFE_MINUTE_LIMIT - $RecentMinuteUsage
    
    if ($CanProceed) {
        Write-Host "✅ 새 요청 실행 가능" -ForegroundColor Green
        Write-Host "📈 남은 일일 안전 사용량: $RemainingDaily건" -ForegroundColor White
        Write-Host "⏱️ 남은 분당 안전 사용량: $RemainingMinute건" -ForegroundColor White
    } else {
        Write-Host "🛑 새 요청 실행 불가" -ForegroundColor Red
        if ($TodayUsage -ge $DAILY_LIMIT) {
            Write-Host "⏰ 내일 00:00에 일일 한도 리셋" -ForegroundColor Yellow
        }
        if ($RecentMinuteUsage -ge $MINUTE_LIMIT) {
            Write-Host "⏰ 1분 후 분당 한도 리셋" -ForegroundColor Yellow
        }
    }
    
    return $CanProceed
}

# 메인 로직
switch ($Action) {
    "CHECK" {
        $CanProceed = Show-UsageStatus
        exit $(if ($CanProceed) { 0 } else { 1 })
    }
    
    "REQUEST" {
        $CanProceed = Show-UsageStatus
        
        if ($CanProceed) {
            Add-UsageLog
            Write-Host "`n✅ 요청 로그 기록 완료" -ForegroundColor Green
            exit 0
        } else {
            Write-Host "`n🛑 요청 거부 - 한도 초과" -ForegroundColor Red
            exit 1
        }
    }
    
    "RESET" {
        if (Test-Path $LogFile) {
            Remove-Item $LogFile -Force
            Write-Host "🔄 사용량 로그 리셋 완료" -ForegroundColor Green
        } else {
            Write-Host "📝 리셋할 로그가 없습니다" -ForegroundColor Yellow
        }
    }
    
    "STATUS" {
        Show-UsageStatus | Out-Null
    }
}