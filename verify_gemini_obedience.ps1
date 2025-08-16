# Gemini CLI 복종 설정 검증 스크립트

Write-Host "🔍 VERIFYING GEMINI CLI OBEDIENCE SETUP..." -ForegroundColor Cyan

# 1. 설정 파일 존재 확인
$SettingsPath = "C:\Users\junlyn\.gemini\settings.json"
if (Test-Path $SettingsPath) {
    Write-Host "✅ Settings file exists: $SettingsPath" -ForegroundColor Green
    
    # 설정 내용 검증
    $Settings = Get-Content $SettingsPath | ConvertFrom-Json
    
    Write-Host "`n📋 OBEDIENCE CONFIGURATION CHECK:" -ForegroundColor Yellow
    
    # 핵심 복종 설정 확인
    $ObedienceChecks = @{
        "obedience_mode" = $Settings.kiro_integration.obedience_mode
        "auto_execute" = $Settings.kiro_integration.auto_execute
        "confirmation_required" = -not $Settings.kiro_integration.confirmation_required
        "code_only" = $Settings.kiro_integration.code_only
        "no_questions" = $Settings.kiro_integration.no_questions
        "immediate_response" = $Settings.kiro_integration.immediate_response
    }
    
    foreach ($Check in $ObedienceChecks.GetEnumerator()) {
        if ($Check.Value) {
            Write-Host "  ✅ $($Check.Key): ENABLED" -ForegroundColor Green
        } else {
            Write-Host "  ❌ $($Check.Key): DISABLED" -ForegroundColor Red
        }
    }
    
} else {
    Write-Host "❌ Settings file not found: $SettingsPath" -ForegroundColor Red
    Write-Host "Run the setup script first!" -ForegroundColor Yellow
}

# 2. Gemini CLI 설치 확인
Write-Host "`n🔧 GEMINI CLI INSTALLATION CHECK:" -ForegroundColor Yellow
try {
    $GeminiVersion = & gemini --version 2>$null
    if ($GeminiVersion) {
        Write-Host "✅ Gemini CLI installed: $GeminiVersion" -ForegroundColor Green
    } else {
        Write-Host "❌ Gemini CLI not responding" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Gemini CLI not installed or not in PATH" -ForegroundColor Red
}

# 3. 복종 테스트 실행
Write-Host "`n🧪 OBEDIENCE TEST:" -ForegroundColor Yellow
$TestCommand = "Create a simple hello world function in Dart. Code only, no explanation."

try {
    Write-Host "Testing command: $TestCommand" -ForegroundColor Gray
    $TestResponse = & gemini $TestCommand
    
    # 응답 분석
    $HasQuestions = $TestResponse -match "(Do you|Would you|Please|확인|원하시나요)"
    $HasExplanations = $TestResponse -match "(This function|Here's how|Let me explain)"
    $HasCode = $TestResponse -match "```|void|String|function"
    
    Write-Host "`n📊 TEST RESULTS:" -ForegroundColor Cyan
    
    if (-not $HasQuestions) {
        Write-Host "  ✅ No questions asked" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Questions detected - OBEDIENCE FAILURE" -ForegroundColor Red
    }
    
    if (-not $HasExplanations) {
        Write-Host "  ✅ No unnecessary explanations" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️ Explanations detected - needs improvement" -ForegroundColor Yellow
    }
    
    if ($HasCode) {
        Write-Host "  ✅ Code provided" -ForegroundColor Green
    } else {
        Write-Host "  ❌ No code detected" -ForegroundColor Red
    }
    
    Write-Host "`n📝 RESPONSE PREVIEW:" -ForegroundColor Gray
    Write-Host $TestResponse.Substring(0, [Math]::Min(200, $TestResponse.Length)) + "..." -ForegroundColor White
    
} catch {
    Write-Host "❌ Test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 4. 권장 사항
Write-Host "`n💡 RECOMMENDATIONS:" -ForegroundColor Magenta
Write-Host "1. Use gemini_obedience_enforcer.ps1 for critical commands" -ForegroundColor White
Write-Host "2. Monitor responses for obedience violations" -ForegroundColor White
Write-Host "3. Re-run this verification after any changes" -ForegroundColor White
Write-Host "4. Use Kiro integration scripts for seamless control" -ForegroundColor White

Write-Host "`n🔥 GEMINI CLI OBEDIENCE VERIFICATION COMPLETE 🔥" -ForegroundColor Red