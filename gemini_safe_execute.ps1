# KIRO v7.0 Gemini CLI 안전 실행 시스템
# 작성일: 2025-01-27
# 목적: 무료 플랜 제한사항을 준수하는 안전한 Gemini CLI 실행

param(
    [Parameter(Mandatory=$true)]
    [string]$Command,
    
    [int]$TimeoutMs = 30000,
    
    [switch]$Force
)

# UTF-8 인코딩 설정
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "🛡️ KIRO v7.0 Gemini CLI 안전 실행 시스템" -ForegroundColor Green
Write-Host "=" * 45 -ForegroundColor Green

# 1단계: 무료 플랜 사용량 확인
Write-Host "`n📊 1단계: 무료 플랜 사용량 확인" -ForegroundColor Cyan

if (-not $Force) {
    $UsageCheck = & ".\gemini_free_plan_manager.ps1" -Action CHECK
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "🛑 실행 중단: 무료 플랜 한도 초과" -ForegroundColor Red
        Write-Host "💡 해결책:" -ForegroundColor Yellow
        Write-Host "   - 일일 한도 초과: 내일까지 대기" -ForegroundColor White
        Write-Host "   - 분당 한도 초과: 1분 후 재시도" -ForegroundColor White
        Write-Host "   - 강제 실행: -Force 옵션 사용 (Flash 모델)" -ForegroundColor White
        exit 1
    }
} else {
    Write-Host "⚠️ 강제 실행 모드: 한도 확인 생략" -ForegroundColor Yellow
}

# 2단계: Desktop-Commander 세션 정리
Write-Host "`n🧹 2단계: 시스템 정리" -ForegroundColor Cyan

try {
    $CleanupResult = & ".\desktop_commander_safe_wrapper.ps1" -Command "echo 'cleanup test'" -CleanupFirst
    Write-Host "✅ 시스템 정리 완료" -ForegroundColor Green
} catch {
    Write-Host "⚠️ 시스템 정리 중 오류: $($_.Exception.Message)" -ForegroundColor Yellow
}

# 3단계: 안전한 Gemini CLI 실행
Write-Host "`n⚡ 3단계: Gemini CLI 실행" -ForegroundColor Cyan
Write-Host "📝 명령어: $Command" -ForegroundColor White

$StartTime = Get-Date

try {
    # 사용량 로그 기록 (Force 모드가 아닌 경우)
    if (-not $Force) {
        & ".\gemini_free_plan_manager.ps1" -Action REQUEST | Out-Null
    }
    
    # Gemini CLI 실행
    Write-Host "🤖 Gemini CLI 실행 중..." -ForegroundColor Yellow
    
    $ProcessInfo = Start-Process -FilePath "gemini" -ArgumentList $Command -NoNewWindow -PassThru -RedirectStandardOutput "temp_gemini_output.txt" -RedirectStandardError "temp_gemini_error.txt"
    
    # 타임아웃 처리
    $TimeoutSeconds = $TimeoutMs / 1000
    if (-not $ProcessInfo.WaitForExit($TimeoutSeconds * 1000)) {
        Write-Host "⏰ 타임아웃 발생 - 프로세스 강제 종료" -ForegroundColor Red
        $ProcessInfo.Kill()
        throw "Gemini CLI 실행 타임아웃 ($TimeoutSeconds 초)"
    }
    
    # 결과 읽기
    $Output = ""
    $ErrorOutput = ""
    
    if (Test-Path "temp_gemini_output.txt") {
        $Output = Get-Content "temp_gemini_output.txt" -Raw -Encoding UTF8
    }
    if (Test-Path "temp_gemini_error.txt") {
        $ErrorOutput = Get-Content "temp_gemini_error.txt" -Raw -Encoding UTF8
    }
    
    $EndTime = Get-Date
    $Duration = $EndTime - $StartTime
    
    # 4단계: 결과 분석 및 리포트
    Write-Host "`n📊 4단계: 실행 결과 분석" -ForegroundColor Cyan
    
    Write-Host "✅ Gemini CLI 실행 완료" -ForegroundColor Green
    Write-Host "⏱️ 실행 시간: $($Duration.TotalSeconds.ToString('F2'))초" -ForegroundColor White
    Write-Host "🕐 완료 시간: $($EndTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor White
    
    # 모델 감지 (Pro vs Flash)
    if ($Output -match "flash" -or $ErrorOutput -match "flash") {
        Write-Host "🔄 모델: Gemini Flash (한도 초과로 자동 전환)" -ForegroundColor Yellow
    } else {
        Write-Host "🤖 모델: Gemini 2.5 Pro (무료 플랜)" -ForegroundColor Green
    }
    
    # 출력 결과
    Write-Host "`n📄 Gemini CLI 응답:" -ForegroundColor Green
    Write-Host "-" * 30 -ForegroundColor Green
    if ($Output) {
        Write-Host $Output -ForegroundColor White
    } else {
        Write-Host "응답 없음" -ForegroundColor Yellow
    }
    
    if ($ErrorOutput) {
        Write-Host "`n❌ 오류 출력:" -ForegroundColor Red
        Write-Host $ErrorOutput -ForegroundColor Red
    }
    
    # 5단계: 사용량 업데이트된 상태 표시
    Write-Host "`n📈 5단계: 업데이트된 사용량 현황" -ForegroundColor Cyan
    & ".\gemini_free_plan_manager.ps1" -Action STATUS
    
    return @{
        Success = $true
        Output = $Output
        Error = $ErrorOutput
        Duration = $Duration.TotalSeconds
        Model = if ($Output -match "flash") { "Flash" } else { "Pro" }
    }
    
} catch {
    $EndTime = Get-Date
    $Duration = $EndTime - $StartTime
    
    Write-Host "❌ 실행 오류: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "⏱️ 실행 시간: $($Duration.TotalSeconds.ToString('F2'))초" -ForegroundColor White
    
    return @{
        Success = $false
        Error = $_.Exception.Message
        Duration = $Duration.TotalSeconds
    }
    
} finally {
    # 임시 파일 정리
    @("temp_gemini_output.txt", "temp_gemini_error.txt") | ForEach-Object {
        if (Test-Path $_) { 
            Remove-Item $_ -Force -ErrorAction SilentlyContinue
        }
    }
}