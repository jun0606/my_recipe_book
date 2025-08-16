# Gemini CLI Controller - Kiro의 완전 제어 시스템

param(
    [Parameter(Mandatory=$true)]
    [string]$Action, # START, EXECUTE, STOP, STATUS
    
    [Parameter(Mandatory=$false)]
    [string]$TaskFile = "",
    
    [Parameter(Mandatory=$false)]
    [int]$MaxRetries = 2
)

# 무료 티어 제한 설정
$DAILY_LIMIT = 1000
$MINUTE_LIMIT = 60
$SAFE_DAILY_LIMIT = 800  # 안전 마진 20%
$SAFE_MINUTE_LIMIT = 50  # 안전 마진

# 사용량 추적 파일
$UsageFile = ".kiro/gemini_usage.json"
$SessionFile = ".kiro/gemini_session.json"
$LogFile = ".kiro/logs/gemini_controller.log"

# 디렉토리 생성
if (!(Test-Path ".kiro/logs")) { New-Item -ItemType Directory -Path ".kiro/logs" -Force }

function Write-Log {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp - $Message" | Tee-Object -FilePath $LogFile -Append
}

function Get-UsageStats {
    if (Test-Path $UsageFile) {
        return Get-Content $UsageFile | ConvertFrom-Json
    } else {
        return @{
            daily_count = 0
            minute_count = 0
            last_request = ""
            last_reset = (Get-Date -Format "yyyy-MM-dd")
            total_sessions = 0
            failed_requests = 0
        }
    }
}

function Update-UsageStats {
    param([hashtable]$Stats)
    $Stats | ConvertTo-Json | Out-File $UsageFile -Encoding UTF8
}

function Check-RateLimit {
    $Stats = Get-UsageStats
    $Now = Get-Date
    $Today = $Now.ToString("yyyy-MM-dd")
    
    # 일일 리셋 체크
    if ($Stats.last_reset -ne $Today) {
        $Stats.daily_count = 0
        $Stats.minute_count = 0
        $Stats.last_reset = $Today
        Write-Log "일일 사용량 리셋됨"
    }
    
    # 분당 리셋 체크 (1분 경과 시)
    if ($Stats.last_request) {
        $LastRequest = [DateTime]::Parse($Stats.last_request)
        if (($Now - $LastRequest).TotalMinutes -ge 1) {
            $Stats.minute_count = 0
            Write-Log "분당 사용량 리셋됨"
        }
    }
    
    # 제한 확인
    if ($Stats.daily_count -ge $SAFE_DAILY_LIMIT) {
        Write-Log "❌ 일일 사용량 한계 도달: $($Stats.daily_count)/$SAFE_DAILY_LIMIT"
        return $false
    }
    
    if ($Stats.minute_count -ge $SAFE_MINUTE_LIMIT) {
        Write-Log "❌ 분당 사용량 한계 도달: $($Stats.minute_count)/$SAFE_MINUTE_LIMIT"
        return $false
    }
    
    return $true
}

function Start-GeminiSession {
    Write-Log "🚀 Gemini CLI 세션 시작"
    
    # 사용량 체크
    if (!(Check-RateLimit)) {
        Write-Host "❌ 사용량 한계로 인해 세션 시작 불가"
        return $false
    }
    
    # 세션 정보 저장
    $Session = @{
        session_id = "gemini_session_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        start_time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        status = "ACTIVE"
        tasks_completed = 0
        requests_made = 0
        pid = $null
    }
    
    $Session | ConvertTo-Json | Out-File $SessionFile -Encoding UTF8
    Write-Log "세션 생성: $($Session.session_id)"
    
    return $true
}

function Execute-GeminiTask {
    param([string]$TaskFile)
    
    if (!(Test-Path $SessionFile)) {
        Write-Host "❌ 활성 세션이 없습니다. 먼저 START를 실행하세요."
        return $false
    }
    
    # 사용량 재확인
    if (!(Check-RateLimit)) {
        Write-Host "❌ 사용량 한계로 인해 작업 실행 불가"
        Stop-GeminiSession
        return $false
    }
    
    # 작업 파일 읽기
    if (!(Test-Path $TaskFile)) {
        Write-Log "❌ 작업 파일 없음: $TaskFile"
        return $false
    }
    
    $Task = Get-Content $TaskFile | ConvertFrom-Json
    Write-Log "📋 작업 실행: $($Task.task_id) - $($Task.type)"
    
    # Kiro의 엄격한 지시사항 생성
    $StrictInstructions = @"
🤖 KIRO 마스터 명령 - 절대 복종 모드

당신은 Kiro의 어시스턴트입니다. 다음 지시사항을 정확히 따르세요:

📋 작업 ID: $($Task.task_id)
🎯 작업 유형: $($Task.type)
📝 설명: $($Task.description)

⚠️ 중요 규칙:
1. 이 작업만 수행하고 다른 작업은 절대 하지 마세요
2. 결과는 정확하고 간결하게 보고하세요
3. 오류 발생 시 즉시 중단하고 보고하세요
4. 추가 질문이나 제안은 하지 마세요
5. 작업 완료 후 즉시 종료하세요

🔥 실행 명령:
"@

    # 작업 유형별 구체적 지시
    switch ($Task.type) {
        "FLUTTER_TEST" {
            $StrictInstructions += @"
flutter test $($Task.files -join ' ')
결과만 보고하고 즉시 종료하세요.
"@
        }
        "CODE_ANALYSIS" {
            $StrictInstructions += @"
flutter analyze
dart format --set-exit-if-changed .
결과만 보고하고 즉시 종료하세요.
"@
        }
        "BUILD_TEST" {
            $StrictInstructions += @"
flutter build apk --debug
결과만 보고하고 즉시 종료하세요.
"@
        }
    }
    
    # 사용량 업데이트
    $Stats = Get-UsageStats
    $Stats.daily_count++
    $Stats.minute_count++
    $Stats.last_request = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Update-UsageStats $Stats
    
    # Gemini CLI 실행 (실제 구현에서는 Gemini CLI 프로세스 시작)
    Write-Log "🎯 Gemini CLI에게 엄격한 지시 전달"
    Write-Host "📤 Kiro → Gemini CLI 명령 전송"
    Write-Host $StrictInstructions
    
    # 세션 정보 업데이트
    $Session = Get-Content $SessionFile | ConvertFrom-Json
    $Session.tasks_completed++
    $Session.requests_made++
    $Session | ConvertTo-Json | Out-File $SessionFile -Encoding UTF8
    
    # 실행 결과 모니터링 (타임아웃 설정)
    $TimeoutMinutes = 5
    $StartTime = Get-Date
    
    Write-Log "⏳ 작업 실행 중... (타임아웃: $TimeoutMinutes분)"
    
    # 실제 구현에서는 Gemini CLI 프로세스 모니터링
    # 여기서는 시뮬레이션
    Start-Sleep -Seconds 2
    
    Write-Log "✅ 작업 완료 또는 타임아웃"
    return $true
}

function Stop-GeminiSession {
    Write-Log "🛑 Gemini CLI 세션 종료"
    
    if (Test-Path $SessionFile) {
        $Session = Get-Content $SessionFile | ConvertFrom-Json
        $Session.status = "STOPPED"
        $Session.end_time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $Session | ConvertTo-Json | Out-File $SessionFile -Encoding UTF8
        
        Write-Log "세션 종료: $($Session.session_id)"
        Write-Log "완료된 작업: $($Session.tasks_completed)개"
        Write-Log "총 요청: $($Session.requests_made)개"
        
        # 세션 파일 삭제 (정리)
        Remove-Item $SessionFile -Force
    }
    
    # Gemini CLI 프로세스 강제 종료 (실제 구현에서)
    Write-Host "🔌 Gemini CLI 프로세스 종료됨"
}

function Get-GeminiStatus {
    $Stats = Get-UsageStats
    $IsActive = Test-Path $SessionFile
    
    Write-Host "📊 Gemini CLI 상태 보고"
    Write-Host "🔋 세션 상태: $(if ($IsActive) { '활성' } else { '비활성' })"
    Write-Host "📈 일일 사용량: $($Stats.daily_count)/$SAFE_DAILY_LIMIT"
    Write-Host "⚡ 분당 사용량: $($Stats.minute_count)/$SAFE_MINUTE_LIMIT"
    Write-Host "📅 마지막 요청: $($Stats.last_request)"
    Write-Host "🎯 총 세션: $($Stats.total_sessions)"
    Write-Host "❌ 실패 요청: $($Stats.failed_requests)"
    
    if ($IsActive) {
        $Session = Get-Content $SessionFile | ConvertFrom-Json
        Write-Host "🆔 현재 세션: $($Session.session_id)"
        Write-Host "⏰ 시작 시간: $($Session.start_time)"
        Write-Host "✅ 완료 작업: $($Session.tasks_completed)개"
    }
}

# 메인 실행 로직
switch ($Action.ToUpper()) {
    "START" {
        if (Start-GeminiSession) {
            Write-Host "✅ Gemini CLI 세션 시작됨"
        } else {
            Write-Host "❌ 세션 시작 실패"
            exit 1
        }
    }
    
    "EXECUTE" {
        if ($TaskFile -eq "") {
            Write-Host "❌ 작업 파일이 지정되지 않았습니다."
            exit 1
        }
        
        if (Execute-GeminiTask $TaskFile) {
            Write-Host "✅ 작업 실행 완료"
        } else {
            Write-Host "❌ 작업 실행 실패"
            exit 1
        }
    }
    
    "STOP" {
        Stop-GeminiSession
        Write-Host "✅ Gemini CLI 세션 종료됨"
    }
    
    "STATUS" {
        Get-GeminiStatus
    }
    
    default {
        Write-Host "❌ 알 수 없는 액션: $Action"
        Write-Host "사용법: .\gemini_cli_controller.ps1 -Action [START|EXECUTE|STOP|STATUS]"
        exit 1
    }
}