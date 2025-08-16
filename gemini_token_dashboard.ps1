# KIRO v7.0 Gemini CLI 토큰 사용량 대시보드
# 작성일: 2025-01-27
# 목적: 일일/주간/월간 토큰 사용량 추적 및 과금 방지

param(
    [ValidateSet("TODAY", "WEEK", "MONTH", "ALL")]
    [string]$Period = "TODAY",
    
    [switch]$Export,
    
    [string]$LogFile = ".kiro/logs/gemini_token_usage.log"
)

# UTF-8 인코딩 설정
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "📊 KIRO v7.0 Gemini CLI 토큰 사용량 대시보드" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Cyan

# 로그 파일 존재 확인
if (-not (Test-Path $LogFile)) {
    Write-Host "⚠️ 토큰 사용량 로그 파일이 없습니다: $LogFile" -ForegroundColor Yellow
    Write-Host "💡 Gemini CLI를 사용한 후 다시 확인해주세요." -ForegroundColor Green
    return
}

try {
    # 로그 데이터 읽기
    $LogData = Get-Content $LogFile -Encoding UTF8 | ForEach-Object {
        try {
            $_ | ConvertFrom-Json
        } catch {
            # 잘못된 JSON 라인 무시
        }
    } | Where-Object { $_ -ne $null -and $_.Status -eq "COMPLETED" }
    
    if (-not $LogData) {
        Write-Host "📝 완료된 Gemini CLI 세션이 없습니다." -ForegroundColor Yellow
        return
    }
    
    # 기간별 필터링
    $Now = Get-Date
    $FilteredData = switch ($Period) {
        "TODAY" {
            $Today = $Now.Date
            $LogData | Where-Object { 
                $SessionDate = [DateTime]$_.StartTime
                $SessionDate.Date -eq $Today
            }
        }
        "WEEK" {
            $WeekAgo = $Now.AddDays(-7)
            $LogData | Where-Object { 
                $SessionDate = [DateTime]$_.StartTime
                $SessionDate -ge $WeekAgo
            }
        }
        "MONTH" {
            $MonthAgo = $Now.AddDays(-30)
            $LogData | Where-Object { 
                $SessionDate = [DateTime]$_.StartTime
                $SessionDate -ge $MonthAgo
            }
        }
        "ALL" {
            $LogData
        }
    }
    
    if (-not $FilteredData) {
        Write-Host "📝 선택한 기간($Period)에 완료된 세션이 없습니다." -ForegroundColor Yellow
        return
    }
    
    # 통계 계산
    $TotalSessions = $FilteredData.Count
    $TotalTokens = ($FilteredData | Measure-Object -Property TokensUsed -Sum).Sum
    $TotalInputTokens = ($FilteredData | Measure-Object -Property InputTokens -Sum).Sum
    $TotalOutputTokens = ($FilteredData | Measure-Object -Property OutputTokens -Sum).Sum
    $AverageTokens = if ($TotalSessions -gt 0) { [math]::Round($TotalTokens / $TotalSessions, 2) } else { 0 }
    $TotalDuration = ($FilteredData | Measure-Object -Property Duration -Sum).Sum
    $AverageDuration = if ($TotalSessions -gt 0) { [math]::Round($TotalDuration / $TotalSessions, 2) } else { 0 }
    
    # 대시보드 출력
    Write-Host "`n🗓️ 기간: $Period" -ForegroundColor Green
    Write-Host "📅 조회 시간: $($Now.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor White
    Write-Host "`n📈 전체 통계" -ForegroundColor Cyan
    Write-Host "-" * 30 -ForegroundColor Cyan
    Write-Host "🔢 총 세션 수: $TotalSessions" -ForegroundColor White
    Write-Host "💰 총 사용 토큰: $TotalTokens" -ForegroundColor $(if ($TotalTokens -gt 5000) { "Red" } elseif ($TotalTokens -gt 2000) { "Yellow" } else { "Green" })
    Write-Host "📥 총 입력 토큰: $TotalInputTokens" -ForegroundColor White
    Write-Host "📤 총 출력 토큰: $TotalOutputTokens" -ForegroundColor White
    Write-Host "📊 평균 토큰/세션: $AverageTokens" -ForegroundColor White
    Write-Host "⏱️ 총 실행 시간: $([math]::Round($TotalDuration, 2))초" -ForegroundColor White
    Write-Host "⏱️ 평균 실행 시간: $AverageDuration초" -ForegroundColor White
    
    # 상위 토큰 사용 세션
    Write-Host "`n🔥 상위 토큰 사용 세션 (TOP 5)" -ForegroundColor Cyan
    Write-Host "-" * 40 -ForegroundColor Cyan
    $TopSessions = $FilteredData | Sort-Object TokensUsed -Descending | Select-Object -First 5
    
    foreach ($Session in $TopSessions) {
        $StartTime = [DateTime]$Session.StartTime
        $CommandPreview = if ($Session.Command.Length -gt 50) { 
            $Session.Command.Substring(0, 47) + "..." 
        } else { 
            $Session.Command 
        }
        
        Write-Host "🕐 $($StartTime.ToString('MM-dd HH:mm')) | 💰 $($Session.TokensUsed) tokens | 📝 $CommandPreview" -ForegroundColor White
    }
    
    # 무료 플랜 제한사항 경고 시스템
    Write-Host "`n📊 무료 플랜 사용량 분석" -ForegroundColor Cyan
    Write-Host "-" * 35 -ForegroundColor Cyan
    
    # 일일 제한사항 기준
    $DailyLimit = 1000      # 공식 일일 한도
    $SafeLimit = 800        # 안전 마진 (80%)
    $WarningLimit = 600     # 경고 수준 (60%)
    
    # 오늘 세션 수 기준 분석
    if ($Period -eq "TODAY") {
        $TodaySessions = $TotalSessions
        
        if ($TodaySessions -ge $DailyLimit) {
            Write-Host "🚨 일일 한도 초과! ($TodaySessions/$DailyLimit 요청)" -ForegroundColor Red
            Write-Host "💡 Gemini 2.5 Pro → Flash 모델로 자동 전환됨" -ForegroundColor Yellow
            Write-Host "⏰ 내일 00:00에 한도가 리셋됩니다." -ForegroundColor Yellow
        } elseif ($TodaySessions -ge $SafeLimit) {
            Write-Host "⚠️ 안전 한도 근접! ($TodaySessions/$SafeLimit 요청)" -ForegroundColor Yellow
            Write-Host "💡 오늘 사용량을 줄이는 것을 권장합니다." -ForegroundColor Green
            Write-Host "📈 남은 안전 사용량: $($SafeLimit - $TodaySessions)건" -ForegroundColor White
        } elseif ($TodaySessions -ge $WarningLimit) {
            Write-Host "🔔 주의 수준 ($TodaySessions/$WarningLimit 요청)" -ForegroundColor Yellow
            Write-Host "💡 사용량을 모니터링하고 있습니다." -ForegroundColor Green
            Write-Host "📈 남은 안전 사용량: $($SafeLimit - $TodaySessions)건" -ForegroundColor White
        } else {
            Write-Host "✅ 안전한 사용량 ($TodaySessions/$SafeLimit 요청)" -ForegroundColor Green
            Write-Host "💡 현재 사용량은 적정 수준입니다." -ForegroundColor Green
            Write-Host "📈 남은 안전 사용량: $($SafeLimit - $TodaySessions)건" -ForegroundColor White
        }
        
        # 분당 제한 경고
        Write-Host "`n⏱️ 분당 제한: 60건/분 (권장: 50건/분)" -ForegroundColor Cyan
    }
    
    Write-Host "`n🆓 Gemini CLI 무료 플랜 정보" -ForegroundColor Green
    Write-Host "-" * 30 -ForegroundColor Green
    Write-Host "📊 일일 한도: 1,000건 요청" -ForegroundColor White
    Write-Host "⏱️ 분당 한도: 60건 요청" -ForegroundColor White
    Write-Host "🤖 모델: Gemini 2.5 Pro (무료)" -ForegroundColor White
    Write-Host "🔄 초과시: Flash 모델 자동 전환" -ForegroundColor White
    Write-Host "💰 비용: 완전 무료 (API 키 불필요)" -ForegroundColor Green
    
    # 내보내기 옵션
    if ($Export) {
        $ExportFile = ".kiro/reports/gemini_token_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
        $ExportDir = Split-Path $ExportFile -Parent
        
        if (-not (Test-Path $ExportDir)) {
            New-Item -ItemType Directory -Path $ExportDir -Force | Out-Null
        }
        
        $Report = @{
            Period = $Period
            GeneratedAt = $Now
            TotalSessions = $TotalSessions
            TotalTokens = $TotalTokens
            TotalInputTokens = $TotalInputTokens
            TotalOutputTokens = $TotalOutputTokens
            AverageTokens = $AverageTokens
            TotalDuration = $TotalDuration
            AverageDuration = $AverageDuration
            TopSessions = $TopSessions
            AllSessions = $FilteredData
        }
        
        $Report | ConvertTo-Json -Depth 10 | Set-Content -Path $ExportFile -Encoding UTF8
        Write-Host "`n📄 리포트 내보내기 완료: $ExportFile" -ForegroundColor Green
    }
    
} catch {
    Write-Host "❌ 대시보드 생성 오류: $($_.Exception.Message)" -ForegroundColor Red
}