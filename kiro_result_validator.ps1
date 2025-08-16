# Kiro Result Validator - Gemini CLI 작업 결과 검증 시스템

param(
    [Parameter(Mandatory=$false)]
    [string]$TaskId = ""
)

$ResultDir = ".kiro/results"
$LogDir = ".kiro/logs"

# 최신 결과 파일 찾기
if ($TaskId -eq "") {
    $ResultFiles = Get-ChildItem "$ResultDir/*.json" | Sort-Object LastWriteTime -Descending
    if ($ResultFiles.Count -eq 0) {
        Write-Host "📭 검증할 결과가 없습니다."
        exit 0
    }
    $ResultFile = $ResultFiles[0].FullName
    $TaskId = [System.IO.Path]::GetFileNameWithoutExtension($ResultFiles[0].Name)
} else {
    $ResultFile = "$ResultDir/$TaskId.json"
}

# 결과 파일 읽기
try {
    $Result = Get-Content $ResultFile | ConvertFrom-Json
    Write-Host "🔍 Kiro 결과 검증 시작"
    Write-Host "📋 작업 ID: $($Result.task_id)"
    Write-Host "📊 상태: $($Result.status)"
    Write-Host "⏱️ 실행 시간: $($Result.execution_time)"
} catch {
    Write-Host "❌ 결과 파일 읽기 실패: $ResultFile"
    exit 1
}

# 작업 유형별 검증
Write-Host ""
Write-Host "🧐 Kiro 검증 결과:"

switch ($Result.status) {
    "SUCCESS" {
        Write-Host "✅ 작업 성공 - 추가 조치 불필요"
        
        # 성공 통계 업데이트
        $SuccessLog = ".kiro/stats/success_log.txt"
        if (!(Test-Path (Split-Path $SuccessLog))) { 
            New-Item -ItemType Directory -Path (Split-Path $SuccessLog) -Force 
        }
        "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $($Result.task_id) - SUCCESS" | Add-Content $SuccessLog
    }
    
    "PARTIAL_SUCCESS" {
        Write-Host "⚠️ 부분 성공 - 실패 항목 검토 필요"
        
        if ($Result.results.failed_tests -gt 0) {
            Write-Host "❌ 실패한 테스트: $($Result.results.failed_tests)개"
            Write-Host "📋 Kiro 권장 조치:"
            Write-Host "  1. 실패한 테스트 로그 확인"
            Write-Host "  2. 테스트 코드 또는 구현 코드 수정"
            Write-Host "  3. 수정 후 재테스트 실행"
            
            # 실패 패턴 분석
            if ($Result.results.test_details) {
                $FailedTests = $Result.results.test_details | Where-Object { -not $_.success }
                Write-Host ""
                Write-Host "🔍 실패 테스트 분석:"
                foreach ($FailedTest in $FailedTests) {
                    Write-Host "  📁 $($FailedTest.file)"
                    Write-Host "  💬 $(($FailedTest.output -split "`n")[0..2] -join " | ")"
                }
            }
        }
    }
    
    "BUILD_FAILED" {
        Write-Host "🚨 빌드 실패 - 즉시 수정 필요"
        Write-Host "📋 Kiro 권장 조치:"
        Write-Host "  1. 빌드 오류 로그 상세 분석"
        Write-Host "  2. 의존성 문제 확인 (pubspec.yaml)"
        Write-Host "  3. 코드 문법 오류 수정"
        Write-Host "  4. flutter clean 후 재빌드"
    }
    
    "ISSUES_FOUND" {
        Write-Host "⚠️ 코드 품질 이슈 발견"
        Write-Host "📋 Kiro 권장 조치:"
        Write-Host "  1. flutter analyze 결과 검토"
        Write-Host "  2. dart format 적용"
        Write-Host "  3. 코드 스타일 가이드 준수"
        Write-Host "  4. 정적 분석 경고 해결"
    }
    
    "ERROR" {
        Write-Host "❌ 작업 실행 오류"
        Write-Host "📋 Kiro 권장 조치:"
        Write-Host "  1. 오류 로그 상세 분석"
        Write-Host "  2. 환경 설정 확인"
        Write-Host "  3. 필요시 작업 재실행"
        
        if ($Result.error) {
            Write-Host "💬 오류 메시지: $($Result.error)"
        }
    }
}

# 로그 파일 요약 표시
if ($Result.logs -and (Test-Path $Result.logs)) {
    Write-Host ""
    Write-Host "📝 로그 요약 (마지막 10줄):"
    Get-Content $Result.logs | Select-Object -Last 10 | ForEach-Object {
        Write-Host "  $_"
    }
}

# 다음 작업 제안
Write-Host ""
Write-Host "🎯 Kiro 다음 작업 제안:"

switch ($Result.status) {
    "SUCCESS" {
        Write-Host "  ✅ 현재 작업 완료 - 다음 단계로 진행 가능"
    }
    "PARTIAL_SUCCESS" {
        Write-Host "  🔧 실패 항목 수정 후 재테스트 권장"
        Write-Host "  📋 수정 대상: 실패한 테스트 $($Result.results.failed_tests)개"
    }
    "BUILD_FAILED" {
        Write-Host "  🚨 빌드 문제 해결 최우선"
        Write-Host "  🔍 flutter doctor 실행 권장"
    }
    "ISSUES_FOUND" {
        Write-Host "  📝 코드 품질 개선 작업 필요"
        Write-Host "  🎨 코드 포맷팅 및 정적 분석 경고 해결"
    }
    "ERROR" {
        Write-Host "  ⚠️ 환경 또는 설정 문제 해결 필요"
        Write-Host "  🔄 작업 재실행 고려"
    }
}

# 성과 지표 업데이트
$StatsFile = ".kiro/stats/performance_stats.json"
if (!(Test-Path (Split-Path $StatsFile))) { 
    New-Item -ItemType Directory -Path (Split-Path $StatsFile) -Force 
}

$Stats = if (Test-Path $StatsFile) {
    Get-Content $StatsFile | ConvertFrom-Json
} else {
    @{
        total_tasks = 0
        successful_tasks = 0
        failed_tasks = 0
        average_execution_time = "0s"
        last_updated = ""
    }
}

$Stats.total_tasks++
if ($Result.status -eq "SUCCESS") {
    $Stats.successful_tasks++
} else {
    $Stats.failed_tasks++
}
$Stats.last_updated = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$Stats | ConvertTo-Json | Out-File $StatsFile -Encoding UTF8

$SuccessRate = if ($Stats.total_tasks -gt 0) { 
    [math]::Round(($Stats.successful_tasks / $Stats.total_tasks) * 100, 1) 
} else { 0 }

Write-Host ""
Write-Host "📊 Kiro-Gemini CLI 협업 통계:"
Write-Host "  📈 전체 작업: $($Stats.total_tasks)개"
Write-Host "  ✅ 성공: $($Stats.successful_tasks)개"
Write-Host "  ❌ 실패: $($Stats.failed_tasks)개"
Write-Host "  🎯 성공률: $SuccessRate%"

Write-Host ""
Write-Host "🤖 Kiro 검증 완료 - 다음 지시를 기다립니다."