# Kiro-Gemini CLI Master Control - 완전 통합 제어 시스템 (복종 강화 버전)
# Gemini CLI가 Kiro에 완전히 복종하도록 강제하는 마스터 제어 시스템

param(
    [Parameter(Mandatory=$true)]
    [string]$TaskType, # FLUTTER_TEST, CODE_ANALYSIS, BUILD_TEST
    
    [Parameter(Mandatory=$false)]
    [string[]]$Files = @(),
    
    [Parameter(Mandatory=$false)]
    [string]$Description = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Priority = "NORMAL"
)

Write-Host "🤖 Kiro-Gemini CLI 마스터 제어 시스템 시작"
Write-Host "=" * 60

# 1단계: 사용량 확인
Write-Host "📊 1단계: Gemini CLI 사용량 확인"
$UsageStatus = & ".\gemini_usage_monitor.ps1" -Action STATUS

if ($UsageStatus -match "❌ 사용량 한계로 인해 작업 실행 불가") {
    Write-Host "🚫 Kiro 결정: 사용량 한계로 인해 작업 중단"
    Write-Host "💡 권장: 내일 다시 시도하거나 수동으로 작업 수행"
    exit 1
}

# 2단계: Gemini CLI 세션 시작
Write-Host ""
Write-Host "🚀 2단계: Gemini CLI 세션 시작"
$SessionResult = & ".\gemini_cli_controller.ps1" -Action START

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Kiro 결정: 세션 시작 실패로 인해 작업 중단"
    exit 1
}

try {
    # 3단계: 작업 지시서 생성
    Write-Host ""
    Write-Host "📋 3단계: Kiro 작업 지시서 생성"
    
    $TaskId = "kiro_task_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    $TaskFile = ".kiro/tasks/$TaskId.json"
    
    if (!(Test-Path ".kiro/tasks")) { New-Item -ItemType Directory -Path ".kiro/tasks" -Force }
    
    $Task = @{
        task_id = $TaskId
        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
        priority = $Priority
        type = $TaskType
        description = $Description
        files = $Files
        status = "PENDING"
        created_by = "Kiro_Master"
        assigned_to = "Gemini_CLI_Assistant"
        max_attempts = 3
        timeout_minutes = switch ($TaskType) {
            "FLUTTER_TEST" { 10 }
            "CODE_ANALYSIS" { 5 }
            "BUILD_TEST" { 15 }
            default { 10 }
        }
    }
    
    $Task | ConvertTo-Json -Depth 3 | Out-File $TaskFile -Encoding UTF8
    Write-Host "✅ 작업 지시서 생성: $TaskId"
    
    # 4단계: 일관성 보장 실행
    Write-Host ""
    Write-Host "🛡️ 4단계: 일관성 보장 시스템으로 실행"
    
    $ConsistencyResult = & ".\gemini_consistency_enforcer.ps1" -TaskType $TaskType -Files $Files -MaxAttempts 3
    $ConsistencyExitCode = $LASTEXITCODE
    
    # 5단계: 결과 검증 및 처리
    Write-Host ""
    Write-Host "🔍 5단계: Kiro 결과 검증"
    
    if ($ConsistencyExitCode -eq 0) {
        Write-Host "✅ Gemini CLI 작업 성공"
        
        # 성공 결과 처리
        if (Test-Path ".kiro/results/consistency_success.json") {
            $SuccessResult = Get-Content ".kiro/results/consistency_success.json" | ConvertFrom-Json
            
            Write-Host ""
            Write-Host "📊 Kiro 검증 결과:"
            Write-Host "  🎯 작업 유형: $($SuccessResult.task_type)"
            Write-Host "  📁 처리 파일: $($SuccessResult.files -join ', ')"
            Write-Host "  🔄 필요 시도: $($SuccessResult.attempts_needed)회"
            Write-Host "  ⏰ 완료 시간: $($SuccessResult.timestamp)"
            
            # SQLite에 성공 기록
            $SqliteQuery = @"
INSERT INTO kiro_gemini_tasks (task_id, task_type, status, success_rate, execution_time, notes) 
VALUES ('$TaskId', '$TaskType', 'SUCCESS', 1.0, '$(Get-Date -Format "HH:mm:ss")', 'Completed with $($SuccessResult.attempts_needed) attempts')
"@
            
            # 사용량 업데이트
            & ".\gemini_usage_monitor.ps1" -Action STATUS | Out-Null
            
            Write-Host ""
            Write-Host "🎉 Kiro 최종 판정: 작업 성공적 완료"
            
        } else {
            Write-Host "⚠️ 성공 결과 파일을 찾을 수 없음"
        }
        
    } else {
        Write-Host "❌ Gemini CLI 작업 실패"
        
        # 실패 결과 처리
        if (Test-Path ".kiro/results/consistency_failure.json") {
            $FailureResult = Get-Content ".kiro/results/consistency_failure.json" | ConvertFrom-Json
            
            Write-Host ""
            Write-Host "📊 Kiro 실패 분석:"
            Write-Host "  🎯 작업 유형: $($FailureResult.task_type)"
            Write-Host "  🔄 시도 횟수: $($FailureResult.max_attempts)회"
            Write-Host "  ❌ 실패 원인: $($FailureResult.reason)"
            Write-Host "  ⏰ 실패 시간: $($FailureResult.timestamp)"
            
            Write-Host ""
            Write-Host "💡 Kiro 권장 조치:"
            switch ($TaskType) {
                "FLUTTER_TEST" {
                    Write-Host "  1. 테스트 파일 문법 오류 확인"
                    Write-Host "  2. 의존성 문제 해결 (flutter pub get)"
                    Write-Host "  3. 수동으로 flutter test 실행하여 상세 오류 확인"
                }
                "CODE_ANALYSIS" {
                    Write-Host "  1. flutter doctor 실행하여 환경 확인"
                    Write-Host "  2. 수동으로 flutter analyze 실행"
                    Write-Host "  3. 코드 문법 오류 수정 후 재시도"
                }
                "BUILD_TEST" {
                    Write-Host "  1. flutter clean 실행"
                    Write-Host "  2. flutter pub get 실행"
                    Write-Host "  3. 수동으로 flutter build apk --debug 실행"
                }
            }
            
            # SQLite에 실패 기록
            $SqliteQuery = @"
INSERT INTO kiro_gemini_tasks (task_id, task_type, status, success_rate, execution_time, notes) 
VALUES ('$TaskId', '$TaskType', 'FAILED', 0.0, '$(Get-Date -Format "HH:mm:ss")', 'Failed after $($FailureResult.max_attempts) attempts: $($FailureResult.reason)')
"@
            
            Write-Host ""
            Write-Host "🚨 Kiro 최종 판정: 작업 실패 - 수동 개입 필요"
        }
    }
    
} finally {
    # 6단계: Gemini CLI 세션 종료 (반드시 실행)
    Write-Host ""
    Write-Host "🛑 6단계: Gemini CLI 세션 강제 종료"
    & ".\gemini_cli_controller.ps1" -Action STOP
    
    # 최종 사용량 확인
    Write-Host ""
    Write-Host "📊 최종 사용량 현황:"
    & ".\gemini_usage_monitor.ps1" -Action STATUS | Out-Null
}

Write-Host ""
Write-Host "🏁 Kiro-Gemini CLI 마스터 제어 완료"
Write-Host "=" * 60

# 다음 작업 제안
Write-Host ""
Write-Host "🎯 Kiro 다음 작업 제안:"
if ($ConsistencyExitCode -eq 0) {
    Write-Host "  ✅ 현재 작업 성공 - 다음 단계 진행 가능"
    Write-Host "  📋 권장: 코드 품질 검사 또는 빌드 테스트 실행"
} else {
    Write-Host "  🔧 현재 작업 실패 - 문제 해결 우선"
    Write-Host "  📋 권장: 수동으로 오류 확인 및 수정 후 재시도"
}

exit $ConsistencyExitCode