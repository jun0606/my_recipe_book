# 🏠 완전 무료 로컬 Ollama 설정 스크립트
# 개인 컴퓨터용 경량 모델 설치

Write-Host "🏠 로컬 Ollama 설정을 시작합니다..." -ForegroundColor Cyan

# 1. Ollama 설치 확인
Write-Host "1️⃣ Ollama 설치 확인 중..." -ForegroundColor Yellow
if (!(Get-Command ollama -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Ollama가 설치되지 않았습니다." -ForegroundColor Red
    Write-Host "📥 Ollama 설치 방법:" -ForegroundColor Cyan
    Write-Host "   1. https://ollama.ai 에서 다운로드" -ForegroundColor White
    Write-Host "   2. 또는 winget install Ollama.Ollama" -ForegroundColor White
    exit 1
} else {
    Write-Host "✅ Ollama가 설치되어 있습니다." -ForegroundColor Green
}

# 2. Ollama 서비스 시작
Write-Host "2️⃣ Ollama 서비스 시작 중..." -ForegroundColor Yellow
Start-Process "ollama" -ArgumentList "serve" -WindowStyle Hidden
Start-Sleep 3

# 3. 개인 컴퓨터용 경량 모델 설치
Write-Host "3️⃣ 경량 모델 설치 중..." -ForegroundColor Yellow

$Models = @(
    @{Name="phi3:mini"; Size="1.7GB"; Description="초경량 (저사양 PC용)"},
    @{Name="llama3.2:3b"; Size="4.1GB"; Description="일반 작업용"},
    @{Name="codellama:7b"; Size="3.8GB"; Description="코딩 최적화"}
)

foreach ($Model in $Models) {
    Write-Host "📦 $($Model.Name) 설치 중... ($($Model.Size) - $($Model.Description))" -ForegroundColor Cyan
    ollama pull $Model.Name
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ $($Model.Name) 설치 완료" -ForegroundColor Green
    } else {
        Write-Host "❌ $($Model.Name) 설치 실패" -ForegroundColor Red
    }
}

# 4. Task Master AI 로컬 설정
Write-Host "4️⃣ Task Master AI 로컬 설정 중..." -ForegroundColor Yellow

$TaskMasterConfig = @{
    models = @{
        main = "codellama:7b"
        research = "llama3.2:3b"
        fallback = "phi3:mini"
    }
    endpoints = @{
        ollama = "http://localhost:11434/api"
    }
    settings = @{
        maxTokens = 2048
        temperature = 0.1
        logLevel = "error"
    }
}

# .taskmaster 디렉토리 생성
if (!(Test-Path ".taskmaster")) {
    New-Item -ItemType Directory -Path ".taskmaster" -Force
}

$TaskMasterConfig | ConvertTo-Json -Depth 10 | Out-File ".taskmaster/ollama_config.json" -Encoding UTF8

# 5. 환경 변수 설정
Write-Host "5️⃣ 환경 변수 설정 중..." -ForegroundColor Yellow

$EnvContent = @"
# 🏠 로컬 Ollama 설정 (완전 무료)
OLLAMA_BASE_URL=http://localhost:11434/api
TASKMASTER_MODEL=codellama:7b
TASKMASTER_RESEARCH_MODEL=llama3.2:3b
TASKMASTER_FALLBACK_MODEL=phi3:mini
TASKMASTER_LOG_LEVEL=error

# 🚫 외부 API 키 비활성화 (완전 로컬)
# ANTHROPIC_API_KEY=
# OPENAI_API_KEY=
# PERPLEXITY_API_KEY=
"@

$EnvContent | Out-File ".env.local" -Encoding UTF8

# 6. 테스트
Write-Host "6️⃣ 설정 테스트 중..." -ForegroundColor Yellow

Write-Host "🧪 Ollama 연결 테스트..." -ForegroundColor Cyan
$TestResult = ollama list
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Ollama 연결 성공" -ForegroundColor Green
    Write-Host "📋 설치된 모델:" -ForegroundColor Cyan
    ollama list
} else {
    Write-Host "❌ Ollama 연결 실패" -ForegroundColor Red
}

# 7. 사용 가이드
Write-Host ""
Write-Host "🎉 로컬 Ollama 설정이 완료되었습니다!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 사용 방법:" -ForegroundColor Cyan
Write-Host "   1. Task Master AI가 자동으로 로컬 모델을 사용합니다" -ForegroundColor White
Write-Host "   2. 외부 API 키가 필요하지 않습니다" -ForegroundColor White
Write-Host "   3. 완전히 오프라인에서 작동합니다" -ForegroundColor White
Write-Host ""
Write-Host "🔧 모델 변경:" -ForegroundColor Cyan
Write-Host "   • 코딩: codellama:7b (기본값)" -ForegroundColor White
Write-Host "   • 일반: llama3.2:3b" -ForegroundColor White
Write-Host "   • 경량: phi3:mini" -ForegroundColor White
Write-Host ""
Write-Host "💰 비용: 완전 무료! 🎯" -ForegroundColor Green