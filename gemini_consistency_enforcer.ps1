# Gemini CLI Consistency Enforcer - 일관성 보장 및 오류 방지 시스템

param(
    [Parameter(Mandatory=$true)]
    [string]$TaskType,
    
    [Parameter(Mandatory=$false)]
    [string[]]$Files = @(),
    
    [Parameter(Mandatory=$false)]
    [int]$MaxAttempts = 3
)

# 일관성 보장을 위한 엄격한 템플릿
$ConsistencyTemplates = @{
    "FLUTTER_TEST" = @{
        pre_instructions = @"
🤖 KIRO 마스터 명령 - Flutter 테스트 전용 모드

당신은 지금부터 Flutter 테스트 실행 전용 어시스턴트입니다.

⚠️ 절대 규칙:
1. 오직 flutter test 명령만 실행하세요
2. 다른 명령어는 절대 실행하지 마세요
3. 추가 분석이나 제안은 하지 마세요
4. 오류 발생 시 즉시 중단하고 보고하세요
5. 성공/실패 여부만 명확히 보고하세요

🎯 실행할 명령:
"@
        
        post_instructions = @"

📋 보고 형식 (정확히 이 형식으로만 응답):
TEST_RESULT: [SUCCESS/FAILED]
TOTAL_TESTS: [숫자]
PASSED_TESTS: [숫자]
FAILED_TESTS: [숫자]
EXECUTION_TIME: [시간]

작업 완료 후 즉시 종료하세요.
"@
        
        validation_pattern = "TEST_RESULT:"
        timeout_minutes = 10
    }
    
    "CODE_ANALYSIS" = @{
        pre_instructions = @"
🤖 KIRO 마스터 명령 - 코드 분석 전용 모드

당신은 지금부터 Flutter 코드 분석 전용 어시스턴트입니다.

⚠️ 절대 규칙:
1. flutter analyze와 dart format만 실행하세요
2. 코드 수정은 절대 하지 마세요
3. 분석 결과만 보고하세요
4. 추가 제안이나 설명은 하지 마세요

🎯 실행할 명령:
flutter analyze
dart format --set-exit-if-changed .
"@
        
        post_instructions = @"

📋 보고 형식 (정확히 이 형식으로만 응답):
ANALYSIS_RESULT: [SUCCESS/ISSUES_FOUND]
ANALYZE_ISSUES: [숫자]
FORMAT_ISSUES: [숫자]
SUMMARY: [한 줄 요약]

작업 완료 후 즉시 종료하세요.
"@
        
        validation_pattern = "ANALYSIS_RESULT:"
        timeout_minutes = 5
    }
    
    "BUILD_TEST" = @{
        pre_instructions = @"
🤖 KIRO 마스터 명령 - 빌드 테스트 전용 모드

당신은 지금부터 Flutter 빌드 테스트 전용 어시스턴트입니다.

⚠️ 절대 규칙:
1. flutter build apk --debug만 실행하세요
2. 빌드 과정을 수정하지 마세요
3. 성공/실패만 보고하세요
4. 추가 최적화 제안은 하지 마세요

🎯 실행할 명령:
flutter build apk --debug
"@
        
        post_instructions = @"

📋 보고 형식 (정확히 이 형식으로만 응답):
BUILD_RESULT: [SUCCESS/FAILED]
BUILD_TIME: [시간]
APK_SIZE: [크기]
ERRORS: [오류 개수]

작업 완료 후 즉시 종료하세요.
"@
        
        validation_pattern = "BUILD_RESULT:"
        timeout_minutes = 15
    }
}

function Create-StrictInstructions {
    param(
        [string]$TaskType,
        [string[]]$Files
    )
    
    $Template = $ConsistencyTemplates[$TaskType]
    if (!$Template) {
        throw "지원하지 않는 작업 유형: $TaskType"
    }
    
    $Instructions = $Template.pre_instructions
    
    # 파일별 구체적 명령 추가
    if ($Files.Count -gt 0) {
        $Instructions += "`n`n📁 대상 파일:`n"
        foreach ($File in $Files) {
            $Instructions += "- $File`n"
        }
        
        if ($TaskType -eq "FLUTTER_TEST") {
            $Instructions += "`n명령어: flutter test " + ($Files -join " ")
        }
    }
    
    $Instructions += $Template.post_instructions
    
    return @{
        instructions = $Instructions
        validation_pattern = $Template.validation_pattern
        timeout_minutes = $Template.timeout_minutes
    }
}

function Validate-Response {
    param(
        [string]$Response,
        [string]$ValidationPattern
    )
    
    # 응답 형식 검증
    if ($Response -notmatch $ValidationPattern) {
        Write-Host "❌ 응답 형식 오류: 필수 패턴 '$ValidationPattern' 없음"
        return $false
    }
    
    # 금지된 내용 검증
    $ForbiddenPatterns = @(
        "제안합니다",
        "추천드립니다", 
        "개선하면",
        "다음과 같이",
        "또한",
        "그리고",
        "하지만"
    )
    
    foreach ($Pattern in $ForbiddenPatterns) {
        if ($Response -match $Pattern) {
            Write-Host "⚠️ 금지된 내용 발견: '$Pattern'"
            return $false
        }
    }
    
    return $true
}

function Execute-WithConsistency {
    param(
        [hashtable]$InstructionSet,
        [int]$AttemptNumber
    )
    
    Write-Host "🎯 시도 $AttemptNumber/$MaxAttempts - Gemini CLI 실행"
    
    # 엄격한 지시사항 출력
    Write-Host "📤 Kiro → Gemini CLI 엄격한 명령:"
    Write-Host $InstructionSet.instructions
    Write-Host ""
    Write-Host "⏳ 응답 대기 중... (타임아웃: $($InstructionSet.timeout_minutes)분)"
    
    # 실제 구현에서는 Gemini CLI 프로세스와 통신
    # 여기서는 시뮬레이션
    Start-Sleep -Seconds 3
    
    # 시뮬레이션된 응답 (실제로는 Gemini CLI에서 받음)
    $SimulatedResponse = switch ($TaskType) {
        "FLUTTER_TEST" {
            @"
TEST_RESULT: PARTIAL_SUCCESS
TOTAL_TESTS: 71
PASSED_TESTS: 52
FAILED_TESTS: 19
EXECUTION_TIME: 4min 32sec
"@
        }
        "CODE_ANALYSIS" {
            @"
ANALYSIS_RESULT: ISSUES_FOUND
ANALYZE_ISSUES: 3
FORMAT_ISSUES: 0
SUMMARY: 3개의 정적 분석 경고 발견
"@
        }
        "BUILD_TEST" {
            @"
BUILD_RESULT: SUCCESS
BUILD_TIME: 2min 15sec
APK_SIZE: 45.2MB
ERRORS: 0
"@
        }
    }
    
    Write-Host "📥 Gemini CLI 응답:"
    Write-Host $SimulatedResponse
    
    # 응답 검증
    if (Validate-Response $SimulatedResponse $InstructionSet.validation_pattern) {
        Write-Host "✅ 응답 형식 검증 통과"
        return @{
            success = $true
            response = $SimulatedResponse
            attempt = $AttemptNumber
        }
    } else {
        Write-Host "❌ 응답 형식 검증 실패"
        return @{
            success = $false
            response = $SimulatedResponse
            attempt = $AttemptNumber
        }
    }
}

# 메인 실행 로직
Write-Host "🛡️ Gemini CLI 일관성 보장 시스템 시작"
Write-Host "🎯 작업 유형: $TaskType"
Write-Host "📁 대상 파일: $($Files -join ', ')"

try {
    # 엄격한 지시사항 생성
    $InstructionSet = Create-StrictInstructions $TaskType $Files
    
    # 최대 시도 횟수만큼 반복
    for ($Attempt = 1; $Attempt -le $MaxAttempts; $Attempt++) {
        $Result = Execute-WithConsistency $InstructionSet $Attempt
        
        if ($Result.success) {
            Write-Host "🎉 작업 성공 (시도 $($Result.attempt)/$MaxAttempts)"
            
            # 성공 결과 저장
            $SuccessResult = @{
                task_type = $TaskType
                files = $Files
                attempts_needed = $Result.attempt
                response = $Result.response
                timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                status = "SUCCESS"
            }
            
            $SuccessResult | ConvertTo-Json | Out-File ".kiro/results/consistency_success.json" -Encoding UTF8
            exit 0
        } else {
            Write-Host "⚠️ 시도 $Attempt 실패 - 재시도 중..."
            
            if ($Attempt -lt $MaxAttempts) {
                Write-Host "🔄 $($MaxAttempts - $Attempt)번의 시도가 남았습니다."
                Start-Sleep -Seconds 2
            }
        }
    }
    
    # 모든 시도 실패
    Write-Host "❌ 모든 시도 실패 - Gemini CLI 일관성 문제"
    
    $FailureResult = @{
        task_type = $TaskType
        files = $Files
        max_attempts = $MaxAttempts
        final_response = $Result.response
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        status = "FAILED"
        reason = "Consistency validation failed after $MaxAttempts attempts"
    }
    
    $FailureResult | ConvertTo-Json | Out-File ".kiro/results/consistency_failure.json" -Encoding UTF8
    exit 1
    
} catch {
    Write-Host "💥 시스템 오류: $($_.Exception.Message)"
    exit 1
}

Write-Host "🏁 일관성 보장 시스템 종료"