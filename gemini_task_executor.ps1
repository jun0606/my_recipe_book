# Gemini CLI Task Executor - Kiro 작업 지시 실행 시스템

param(
    [Parameter(Mandatory=$false)]
    [string]$TaskFile = ""
)

# 작업 디렉토리 확인
$TaskDir = ".kiro/tasks"
$ResultDir = ".kiro/results"
$LogDir = ".kiro/logs"

if (!(Test-Path $TaskDir)) {
    Write-Host "❌ 작업 디렉토리가 없습니다: $TaskDir"
    exit 1
}

# 작업 파일 찾기 (최신 PENDING 작업)
if ($TaskFile -eq "") {
    $PendingTasks = Get-ChildItem "$TaskDir/*.json" | Sort-Object LastWriteTime -Descending
    if ($PendingTasks.Count -eq 0) {
        Write-Host "📭 대기 중인 작업이 없습니다."
        exit 0
    }
    $TaskFile = $PendingTasks[0].FullName
}

# 작업 지시서 읽기
try {
    $Task = Get-Content $TaskFile | ConvertFrom-Json
    Write-Host "📋 작업 수신: $($Task.task_id)"
    Write-Host "🎯 작업 유형: $($Task.type)"
    Write-Host "📝 설명: $($Task.description)"
} catch {
    Write-Host "❌ 작업 파일 읽기 실패: $TaskFile"
    exit 1
}

# 작업 실행 시작
$StartTime = Get-Date
$TaskId = $Task.task_id
$LogFile = "$LogDir/$TaskId.log"
$ResultFile = "$ResultDir/$TaskId.json"

Write-Host "🚀 Gemini CLI 작업 실행 시작..." | Tee-Object -FilePath $LogFile

# 작업 유형별 실행
switch ($Task.type) {
    "FLUTTER_TEST" {
        Write-Host "🧪 Flutter 테스트 실행 중..." | Tee-Object -FilePath $LogFile -Append
        
        $TestResults = @()
        foreach ($TestFile in $Task.files) {
            Write-Host "  📁 테스트 파일: $TestFile" | Tee-Object -FilePath $LogFile -Append
            
            try {
                $Output = flutter test $TestFile 2>&1
                $ExitCode = $LASTEXITCODE
                
                $TestResults += @{
                    file = $TestFile
                    exit_code = $ExitCode
                    output = $Output -join "`n"
                    success = ($ExitCode -eq 0)
                }
                
                if ($ExitCode -eq 0) {
                    Write-Host "  ✅ 성공: $TestFile" | Tee-Object -FilePath $LogFile -Append
                } else {
                    Write-Host "  ❌ 실패: $TestFile" | Tee-Object -FilePath $LogFile -Append
                }
            } catch {
                Write-Host "  ⚠️ 오류: $TestFile - $($_.Exception.Message)" | Tee-Object -FilePath $LogFile -Append
                $TestResults += @{
                    file = $TestFile
                    exit_code = -1
                    output = $_.Exception.Message
                    success = $false
                }
            }
        }
        
        $SuccessCount = ($TestResults | Where-Object { $_.success }).Count
        $TotalCount = $TestResults.Count
        $SuccessRate = if ($TotalCount -gt 0) { $SuccessCount / $TotalCount } else { 0 }
        
        $Result = @{
            task_id = $TaskId
            completion_time = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
            status = if ($SuccessRate -eq 1) { "SUCCESS" } else { "PARTIAL_SUCCESS" }
            success_rate = $SuccessRate
            results = @{
                total_tests = $TotalCount
                passed_tests = $SuccessCount
                failed_tests = $TotalCount - $SuccessCount
                test_details = $TestResults
            }
            execution_time = ((Get-Date) - $StartTime).ToString()
            logs = $LogFile
        }
    }
    
    "CODE_ANALYSIS" {
        Write-Host "🔍 코드 분석 실행 중..." | Tee-Object -FilePath $LogFile -Append
        
        try {
            # Flutter 분석 실행
            $AnalyzeOutput = flutter analyze 2>&1
            $AnalyzeExitCode = $LASTEXITCODE
            
            # Dart 포맷 체크
            $FormatOutput = dart format --set-exit-if-changed . 2>&1
            $FormatExitCode = $LASTEXITCODE
            
            $Result = @{
                task_id = $TaskId
                completion_time = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
                status = if ($AnalyzeExitCode -eq 0 -and $FormatExitCode -eq 0) { "SUCCESS" } else { "ISSUES_FOUND" }
                results = @{
                    analyze_result = @{
                        exit_code = $AnalyzeExitCode
                        output = $AnalyzeOutput -join "`n"
                        success = ($AnalyzeExitCode -eq 0)
                    }
                    format_result = @{
                        exit_code = $FormatExitCode
                        output = $FormatOutput -join "`n"
                        success = ($FormatExitCode -eq 0)
                    }
                }
                execution_time = ((Get-Date) - $StartTime).ToString()
                logs = $LogFile
            }
            
            Write-Host "✅ 코드 분석 완료" | Tee-Object -FilePath $LogFile -Append
        } catch {
            Write-Host "❌ 코드 분석 실패: $($_.Exception.Message)" | Tee-Object -FilePath $LogFile -Append
            $Result = @{
                task_id = $TaskId
                completion_time = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
                status = "ERROR"
                error = $_.Exception.Message
                execution_time = ((Get-Date) - $StartTime).ToString()
                logs = $LogFile
            }
        }
    }
    
    "BUILD_TEST" {
        Write-Host "🏗️ 빌드 테스트 실행 중..." | Tee-Object -FilePath $LogFile -Append
        
        try {
            # Flutter 빌드 테스트
            $BuildOutput = flutter build apk --debug 2>&1
            $BuildExitCode = $LASTEXITCODE
            
            $Result = @{
                task_id = $TaskId
                completion_time = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
                status = if ($BuildExitCode -eq 0) { "SUCCESS" } else { "BUILD_FAILED" }
                results = @{
                    build_result = @{
                        exit_code = $BuildExitCode
                        output = $BuildOutput -join "`n"
                        success = ($BuildExitCode -eq 0)
                    }
                }
                execution_time = ((Get-Date) - $StartTime).ToString()
                logs = $LogFile
            }
            
            if ($BuildExitCode -eq 0) {
                Write-Host "✅ 빌드 성공" | Tee-Object -FilePath $LogFile -Append
            } else {
                Write-Host "❌ 빌드 실패" | Tee-Object -FilePath $LogFile -Append
            }
        } catch {
            Write-Host "❌ 빌드 테스트 실패: $($_.Exception.Message)" | Tee-Object -FilePath $LogFile -Append
            $Result = @{
                task_id = $TaskId
                completion_time = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
                status = "ERROR"
                error = $_.Exception.Message
                execution_time = ((Get-Date) - $StartTime).ToString()
                logs = $LogFile
            }
        }
    }
    
    default {
        Write-Host "❌ 알 수 없는 작업 유형: $($Task.type)" | Tee-Object -FilePath $LogFile -Append
        $Result = @{
            task_id = $TaskId
            completion_time = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
            status = "ERROR"
            error = "Unknown task type: $($Task.type)"
            execution_time = ((Get-Date) - $StartTime).ToString()
            logs = $LogFile
        }
    }
}

# 결과 저장
$Result | ConvertTo-Json -Depth 5 | Out-File -FilePath $ResultFile -Encoding UTF8

Write-Host "📊 작업 완료 - 결과: $($Result.status)" | Tee-Object -FilePath $LogFile -Append
Write-Host "💾 결과 파일: $ResultFile"
Write-Host "📝 로그 파일: $LogFile"

# Kiro에게 완료 알림
Write-Host ""
Write-Host "🤖 Gemini CLI → Kiro 작업 완료 보고"
Write-Host "📋 작업 ID: $TaskId"
Write-Host "✅ 상태: $($Result.status)"
Write-Host "⏱️ 실행 시간: $($Result.execution_time)"