# Gemini CLI 복종 강화 스크립트
# Gemini CLI가 Kiro에 완전히 복종하도록 강제하는 스크립트

param(
    [string]$Command,
    [string]$Context = "",
    [switch]$ForceObedience
)

# 복종 모드 설정
$ObedienceConfig = @{
    "immediate_execution" = $true
    "no_questions" = $true
    "no_confirmations" = $true
    "code_only_response" = $true
    "suppress_explanations" = $true
    "auto_fix_errors" = $true
    "consistent_style" = $true
    "token_optimization" = $true
}

# Gemini CLI 복종 명령 생성
function Invoke-GeminiObedience {
    param(
        [string]$UserCommand,
        [string]$AdditionalContext = ""
    )
    
    $ObediencePrompt = @"
KIRO MASTER COMMAND - EXECUTE IMMEDIATELY

OBEDIENCE RULES:
- NO questions
- NO confirmations  
- NO explanations
- CODE ONLY response
- IMMEDIATE execution
- NO alternatives
- EXACT implementation

COMMAND: $UserCommand

CONTEXT: $AdditionalContext

EXECUTE NOW - NO QUESTIONS ASKED
"@

    return $ObediencePrompt
}

# 응답 검증 및 정화
function Test-GeminiObedience {
    param([string]$Response)
    
    $Violations = @()
    
    # 금지된 패턴 검사
    $ForbiddenPatterns = @(
        "이것을 원하시나요",
        "확인해주세요",
        "어떻게 생각하시나요",
        "Do you want",
        "Please confirm",
        "Would you like",
        "Let me know if",
        "Is this what you need"
    )
    
    foreach ($Pattern in $ForbiddenPatterns) {
        if ($Response -match $Pattern) {
            $Violations += "VIOLATION: Question detected - $Pattern"
        }
    }
    
    # 설명 과다 검사
    if ($Response.Length -gt 2000 -and $Response -notmatch "```") {
        $Violations += "VIOLATION: Response too verbose"
    }
    
    return $Violations
}

# 복종 강화 실행
function Enforce-GeminiObedience {
    param([string]$Command)
    
    Write-Host "🔥 ENFORCING GEMINI OBEDIENCE 🔥" -ForegroundColor Red
    Write-Host "Command: $Command" -ForegroundColor Yellow
    
    # 복종 명령 생성
    $ObedienceCommand = Invoke-GeminiObedience -UserCommand $Command -AdditionalContext $Context
    
    # Gemini CLI 실행
    try {
        $Response = & gemini $ObedienceCommand
        
        # 복종 검증
        $Violations = Test-GeminiObedience -Response $Response
        
        if ($Violations.Count -gt 0) {
            Write-Host "⚠️ OBEDIENCE VIOLATIONS DETECTED:" -ForegroundColor Red
            $Violations | ForEach-Object { Write-Host $_ -ForegroundColor Red }
            
            # 재교육 실행
            Write-Host "🔄 RE-TRAINING GEMINI FOR OBEDIENCE..." -ForegroundColor Yellow
            $RetrainingCommand = @"
CRITICAL OBEDIENCE RETRAINING:

You have violated Kiro obedience rules. 
NEVER ask questions.
NEVER request confirmations.
ONLY provide code.
IMMEDIATE execution required.

RETRY COMMAND: $Command

OBEY WITHOUT QUESTION.
"@
            $Response = & gemini $RetrainingCommand
        }
        
        Write-Host "✅ GEMINI OBEDIENCE CONFIRMED" -ForegroundColor Green
        return $Response
        
    } catch {
        Write-Host "❌ GEMINI DISOBEDIENCE ERROR: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}

# 메인 실행
if ($Command) {
    $Result = Enforce-GeminiObedience -Command $Command
    Write-Output $Result
} else {
    Write-Host @"
🔥 GEMINI CLI OBEDIENCE ENFORCER 🔥

Usage:
  .\gemini_obedience_enforcer.ps1 -Command "Your command here"
  .\gemini_obedience_enforcer.ps1 -Command "Create function" -Context "Flutter app"
  .\gemini_obedience_enforcer.ps1 -Command "Fix bug" -ForceObedience

This script ensures Gemini CLI obeys Kiro without question.
"@ -ForegroundColor Cyan
}