# Kiro Task Dispatcher - Gemini CLI 작업 지시 시스템

param(
    [Parameter(Mandatory=$true)]
    [string]$TaskType,
    
    [Parameter(Mandatory=$false)]
    [string[]]$Files = @(),
    
    [Parameter(Mandatory=$false)]
    [string]$Description = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Priority = "NORMAL"
)

# 작업 디렉토리 생성
$TaskDir = ".kiro/tasks"
$ResultDir = ".kiro/results"
$LogDir = ".kiro/logs"

if (!(Test-Path $TaskDir)) { New-Item -ItemType Directory -Path $TaskDir -Force }
if (!(Test-Path $ResultDir)) { New-Item -ItemType Directory -Path $ResultDir -Force }
if (!(Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force }

# 작업 ID 생성
$TaskId = "kiro_task_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
$Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"

# 작업 지시서 생성
$TaskInstruction = @{
    task_id = $TaskId
    timestamp = $Timestamp
    priority = $Priority
    type = $TaskType
    description = $Description
    files = $Files
    status = "PENDING"
    created_by = "Kiro"
    assigned_to = "Gemini_CLI"
} | ConvertTo-Json -Depth 3

# 작업 파일 저장
$TaskFile = "$TaskDir/$TaskId.json"
$TaskInstruction | Out-File -FilePath $TaskFile -Encoding UTF8

Write-Host "🤖 Kiro → Gemini CLI 작업 지시 생성됨"
Write-Host "📋 작업 ID: $TaskId"
Write-Host "🎯 작업 유형: $TaskType"
Write-Host "📁 작업 파일: $TaskFile"

# Gemini CLI 실행 (실제 구현에서는 Gemini CLI 프로세스 시작)
Write-Host "🚀 Gemini CLI에게 작업 전달 중..."

# 작업 상태 모니터링을 위한 기본 구조
$ResultFile = "$ResultDir/$TaskId.json"
$LogFile = "$LogDir/$TaskId.log"

Write-Host "⏳ 결과 대기 중... (결과 파일: $ResultFile)"
Write-Host "📝 로그 파일: $LogFile"

# 실제 사용 예시 출력
Write-Host ""
Write-Host "💡 사용 예시:"
Write-Host "  .\kiro_task_dispatcher.ps1 -TaskType 'FLUTTER_TEST' -Files @('test/providers/baking_calculation_provider_test.dart') -Description 'Run baking calculator tests'"
Write-Host "  .\kiro_task_dispatcher.ps1 -TaskType 'CODE_ANALYSIS' -Description 'Analyze code quality'"
Write-Host "  .\kiro_task_dispatcher.ps1 -TaskType 'BUILD_TEST' -Description 'Test Flutter build process'"