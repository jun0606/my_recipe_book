# Gemini CLI Usage Monitor - 무료 티어 사용량 모니터링 시스템

param(
    [Parameter(Mandatory=$false)]
    [string]$Action = "STATUS" # STATUS, RESET, ALERT, REPORT
)

# 무료 티어 제한 (안전 마진 포함)
$LIMITS = @{
    daily_requests = 800      # 실제 1000, 안전 마진 20%
    minute_requests = 50      # 실제 60, 안전 마진
    warning_threshold = 0.8   # 80% 도달 시 경고
    critical_threshold = 0.95 # 95% 도달 시 중단
}

$UsageFile = ".kiro/gemini_usage.json"
$AlertFile = ".kiro/gemini_alerts.json"
$ReportFile = ".kiro/reports/gemini_usage_report.json"

# 디렉토리 생성
if (!(Test-Path ".kiro/reports")) { New-Item -ItemType Directory -Path ".kiro/reports" -Force }

function Get-CurrentUsage {
    if (Test-Path $UsageFile) {
        $Usage = Get-Content $UsageFile | ConvertFrom-Json
        
        # 일일 리셋 체크
        $Today = Get-Date -Format "yyyy-MM-dd"
        if ($Usage.last_reset -ne $Today) {
            $Usage.daily_count = 0
            $Usage.minute_count = 0
            $Usage.last_reset = $Today
            $Usage.daily_resets++
            Save-Usage $Usage
        }
        
        # 분당 리셋 체크
        if ($Usage.last_request) {
            $LastRequest = [DateTime]::Parse($Usage.last_request)
            $Now = Get-Date
            if (($Now - $LastRequest).TotalMinutes -ge 1) {
                $Usage.minute_count = 0
            }
        }
        
        return $Usage
    } else {
        return @{
            daily_count = 0
            minute_count = 0
            last_request = ""
            last_reset = (Get-Date -Format "yyyy-MM-dd")
            total_requests = 0
            successful_requests = 0
            failed_requests = 0
            daily_resets = 0
            sessions_started = 0
            average_session_requests = 0
        }
    }
}

function Save-Usage {
    param([hashtable]$Usage)
    $Usage | ConvertTo-Json | Out-File $UsageFile -Encoding UTF8
}

function Check-Limits {
    param([hashtable]$Usage)
    
    $DailyPercent = $Usage.daily_count / $LIMITS.daily_requests
    $MinutePercent = $Usage.minute_count / $LIMITS.minute_requests
    
    $Status = @{
        daily_usage = @{
            count = $Usage.daily_count
            limit = $LIMITS.daily_requests
            percentage = [math]::Round($DailyPercent * 100, 1)
            status = "OK"
        }
        minute_usage = @{
            count = $Usage.minute_count
            limit = $LIMITS.minute_requests
            percentage = [math]::Round($MinutePercent * 100, 1)
            status = "OK"
        }
        overall_status = "OK"
        can_proceed = $true
        recommendations = @()
    }
    
    # 일일 사용량 체크
    if ($DailyPercent -ge $LIMITS.critical_threshold) {
        $Status.daily_usage.status = "CRITICAL"
        $Status.overall_status = "CRITICAL"
        $Status.can_proceed = $false
        $Status.recommendations += "일일 사용량 한계 도달 - 내일까지 대기 필요"
    } elseif ($DailyPercent -ge $LIMITS.warning_threshold) {
        $Status.daily_usage.status = "WARNING"
        if ($Status.overall_status -eq "OK") { $Status.overall_status = "WARNING" }
        $Status.recommendations += "일일 사용량 80% 초과 - 신중한 사용 필요"
    }
    
    # 분당 사용량 체크
    if ($MinutePercent -ge $LIMITS.critical_threshold) {
        $Status.minute_usage.status = "CRITICAL"
        $Status.overall_status = "CRITICAL"
        $Status.can_proceed = $false
        $Status.recommendations += "분당 사용량 한계 도달 - 1분 대기 필요"
    } elseif ($MinutePercent -ge $LIMITS.warning_threshold) {
        $Status.minute_usage.status = "WARNING"
        if ($Status.overall_status -eq "OK") { $Status.overall_status = "WARNING" }
        $Status.recommendations += "분당 사용량 80% 초과 - 요청 간격 조정 필요"
    }
    
    return $Status
}

function Show-Status {
    $Usage = Get-CurrentUsage
    $Status = Check-Limits $Usage
    
    Write-Host "📊 Gemini CLI 무료 티어 사용량 현황"
    Write-Host "=" * 50
    
    # 일일 사용량
    $DailyColor = switch ($Status.daily_usage.status) {
        "OK" { "Green" }
        "WARNING" { "Yellow" }
        "CRITICAL" { "Red" }
    }
    Write-Host "📅 일일 사용량: " -NoNewline
    Write-Host "$($Status.daily_usage.count)/$($Status.daily_usage.limit) " -NoNewline -ForegroundColor $DailyColor
    Write-Host "($($Status.daily_usage.percentage)%)" -ForegroundColor $DailyColor
    
    # 분당 사용량
    $MinuteColor = switch ($Status.minute_usage.status) {
        "OK" { "Green" }
        "WARNING" { "Yellow" }
        "CRITICAL" { "Red" }
    }
    Write-Host "⚡ 분당 사용량: " -NoNewline
    Write-Host "$($Status.minute_usage.count)/$($Status.minute_usage.limit) " -NoNewline -ForegroundColor $MinuteColor
    Write-Host "($($Status.minute_usage.percentage)%)" -ForegroundColor $MinuteColor
    
    # 전체 상태
    $OverallColor = switch ($Status.overall_status) {
        "OK" { "Green" }
        "WARNING" { "Yellow" }
        "CRITICAL" { "Red" }
    }
    Write-Host "🎯 전체 상태: " -NoNewline
    Write-Host $Status.overall_status -ForegroundColor $OverallColor
    
    # 통계
    Write-Host ""
    Write-Host "📈 누적 통계:"
    Write-Host "  총 요청: $($Usage.total_requests)개"
    Write-Host "  성공 요청: $($Usage.successful_requests)개"
    Write-Host "  실패 요청: $($Usage.failed_requests)개"
    Write-Host "  성공률: $(if ($Usage.total_requests -gt 0) { [math]::Round(($Usage.successful_requests / $Usage.total_requests) * 100, 1) } else { 0 })%"
    Write-Host "  총 세션: $($Usage.sessions_started)개"
    
    # 권장사항
    if ($Status.recommendations.Count -gt 0) {
        Write-Host ""
        Write-Host "💡 권장사항:"
        foreach ($Recommendation in $Status.recommendations) {
            Write-Host "  - $Recommendation"
        }
    }
    
    # 작업 가능 여부
    Write-Host ""
    if ($Status.can_proceed) {
        Write-Host "✅ 새 작업 실행 가능" -ForegroundColor Green
    } else {
        Write-Host "❌ 사용량 한계로 인해 작업 실행 불가" -ForegroundColor Red
    }
    
    return $Status
}

function Create-Alert {
    param([hashtable]$Status, [string]$AlertType)
    
    $Alert = @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        alert_type = $AlertType
        daily_usage = $Status.daily_usage
        minute_usage = $Status.minute_usage
        overall_status = $Status.overall_status
        recommendations = $Status.recommendations
    }
    
    # 기존 알림 로드
    $Alerts = if (Test-Path $AlertFile) {
        Get-Content $AlertFile | ConvertFrom-Json
    } else {
        @()
    }
    
    # 새 알림 추가
    $Alerts += $Alert
    
    # 최근 100개만 유지
    if ($Alerts.Count -gt 100) {
        $Alerts = $Alerts[-100..-1]
    }
    
    $Alerts | ConvertTo-Json -Depth 3 | Out-File $AlertFile -Encoding UTF8
    
    Write-Host "🚨 알림 생성: $AlertType"
}

function Generate-Report {
    $Usage = Get-CurrentUsage
    $Status = Check-Limits $Usage
    
    $Report = @{
        generated_at = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        usage_summary = $Usage
        current_status = $Status
        efficiency_metrics = @{
            daily_efficiency = if ($LIMITS.daily_requests -gt 0) { 
                [math]::Round(($Usage.daily_count / $LIMITS.daily_requests) * 100, 2) 
            } else { 0 }
            success_rate = if ($Usage.total_requests -gt 0) { 
                [math]::Round(($Usage.successful_requests / $Usage.total_requests) * 100, 2) 
            } else { 0 }
            average_requests_per_session = if ($Usage.sessions_started -gt 0) { 
                [math]::Round($Usage.total_requests / $Usage.sessions_started, 2) 
            } else { 0 }
        }
        recommendations = @{
            optimization_tips = @(
                "작업을 배치로 그룹화하여 세션 수 최소화",
                "실패율이 높은 작업 유형 분석 및 개선",
                "피크 시간대 사용량 분산"
            )
            cost_saving_tips = @(
                "무료 티어 한도 내에서 최대 효율 달성",
                "불필요한 재시도 최소화",
                "작업 우선순위 기반 실행"
            )
        }
    }
    
    $Report | ConvertTo-Json -Depth 4 | Out-File $ReportFile -Encoding UTF8
    
    Write-Host "📋 사용량 보고서 생성 완료: $ReportFile"
    return $Report
}

function Reset-Usage {
    $Usage = @{
        daily_count = 0
        minute_count = 0
        last_request = ""
        last_reset = (Get-Date -Format "yyyy-MM-dd")
        total_requests = 0
        successful_requests = 0
        failed_requests = 0
        daily_resets = 0
        sessions_started = 0
        average_session_requests = 0
    }
    
    Save-Usage $Usage
    Write-Host "🔄 사용량 통계 리셋 완료"
}

# 메인 실행 로직
switch ($Action.ToUpper()) {
    "STATUS" {
        Show-Status | Out-Null
    }
    
    "RESET" {
        Reset-Usage
    }
    
    "ALERT" {
        $Status = Show-Status
        if ($Status.overall_status -ne "OK") {
            Create-Alert $Status $Status.overall_status
        }
    }
    
    "REPORT" {
        Generate-Report | Out-Null
    }
    
    default {
        Write-Host "❌ 알 수 없는 액션: $Action"
        Write-Host "사용법: .\gemini_usage_monitor.ps1 -Action [STATUS|RESET|ALERT|REPORT]"
        exit 1
    }
}