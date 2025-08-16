# Kiro 통합 초기화 스크립트
# Kiro IDE 시작시 자동으로 실행되어 모든 준비를 완료하는 마스터 스크립트

param(
    [switch]$Force,
    [switch]$Quick,
    [switch]$Silent
)

if (-not $Silent) {
    Write-Host "               KIRO 통합 초기화 시스템 시작" -ForegroundColor Magenta
    Write-Host "====================================" -ForegroundColor Gray
}

# 전역 변수
$Script:InitResults = @{
    "StartTime" = Get-Date
    "Steps" = @()
    "Errors" = @()
    "Status" = "RUNNING"
}

# 로깅 함수
function Write-InitLog {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [string]$Color = "White"
    )
    
    $Timestamp = Get-Date -Format "HH:mm:ss"
    $LogEntry = "[$Timestamp] [$Level] $Message"
    
    if (-not $Silent) {
        Write-Host $LogEntry -ForegroundColor $Color
    }
    
    # 로그 파일에 기록
    if (-not (Test-Path ".kiro/logs")) {
        New-Item -ItemType Directory -Path ".kiro/logs" -Force | Out-Null
    }
    $LogEntry | Add-Content ".kiro/logs/kiro_init.log" -Encoding UTF8
}

# 단계 실행 함수
function Invoke-InitStep {
    param(
        [string]$StepName,
        [scriptblock]$Action,
        [bool]$Critical = $true
    )
    
    $StepStart = Get-Date
    Write-InitLog " 시작: $StepName" "STEP" "Yellow"
    
    try {
        $Result = & $Action
        $Duration = (Get-Date) - $StepStart
        
        $Script:InitResults.Steps += @{
            "Name" = $StepName
            "Status" = "SUCCESS"
            "Duration" = $Duration.TotalSeconds
            "Result" = $Result
        }
        
        Write-InitLog " 완료: $StepName ($(($Duration.TotalSeconds).ToString('F1'))초)" "SUCCESS" "Green"
        return $true
        
    } catch {
        $Duration = (Get-Date) - $StepStart
        $ErrorMsg = $_.Exception.Message
        
        $Script:InitResults.Steps += @{
            "Name" = $StepName
            "Status" = "FAILED"
            "Duration" = $Duration.TotalSeconds
            "Error" = $ErrorMsg
        }
        
        $Script:InitResults.Errors += "${StepName}: $ErrorMsg"
        
        Write-InitLog " 실패: $StepName - $ErrorMsg" "ERROR" "Red"
        
        if ($Critical) {
            throw "Critical step failed: $StepName"
        }
        return $false
    }
}

# 1. 워크스페이스 정리
$CleanupStep = {
    if ($Force -or -not (Test-Path "kiro_core_files.md")) {
        Write-InitLog "중복 파일 정리 실행 중..." "INFO" "Cyan"
        & .\cleanup_duplicates.ps1
        return "워크스페이스 정리 완료"
    } else {
        return "워크스페이스 이미 정리됨"
    }
}

# 2. 필수 디렉토리 구조 생성
$DirectoryStep = {
    $RequiredDirs = @(
        ".kiro/session",
        ".kiro/logs", 
        ".kiro/results",
        ".kiro/backup",
        ".kiro/specs",
        ".kiro/settings"
    )
    
    $CreatedCount = 0
    foreach ($Dir in $RequiredDirs) {
        if (-not (Test-Path $Dir)) {
            New-Item -ItemType Directory -Path $Dir -Force | Out-Null
            $CreatedCount++
        }
    }
    
    return "디렉토리 $CreatedCount 개 생성/확인 완료"
}

# 3. MCP 설정 확인
$MCPStep = {
    $MCPConfig = ".kiro/settings/mcp.json"
    if (-not (Test-Path $MCPConfig)) {
        Write-InitLog "MCP 설정 파일이 없습니다. 기본 설정을 생성합니다." "WARN" "Yellow"
        
        $DefaultMCP = @{
            "mcpServers" = @{
                "filesystem" = @{
                    "command" = "uvx"
                    "args" = @("mcp-server-filesystem")
                    "disabled" = $false
                }
                "git" = @{
                    "command" = "uvx"
                    "args" = @("mcp-server-git")
                    "disabled" = $false
                }
                "sqlite" = @{
                    "command" = "uvx"
                    "args" = @("mcp-server-sqlite")
                    "disabled" = $false
                }
            }
        }
        
        $DefaultMCP | ConvertTo-Json -Depth 3 | Out-File $MCPConfig -Encoding UTF8
        return "MCP 기본 설정 생성 완료"
    } else {
        return "MCP 설정 확인 완료"
    }
}

# 4. Gemini CLI 설정 확인
$GeminiStep = {
    $GeminiConfig = "C:\Users\junlyn\.gemini\settings.json"
    if (-not (Test-Path $GeminiConfig)) {
        Write-InitLog "Gemini CLI 설정이 없습니다. 복종 설정을 생성합니다." "WARN" "Yellow"
        
        if (-not (Test-Path "C:\Users\junlyn\.gemini")) {
            New-Item -ItemType Directory -Path "C:\Users\junlyn\.gemini" -Force | Out-Null
        }
        
        $GeminiSettings = @{
            "model" = "gemini-1.5-flash"
            "temperature" = 0.1
            "kiro_integration" = @{
                "obedience_mode" = $true
                "auto_execute" = $true
                "confirmation_required" = $false
                "code_only" = $true
                "no_questions" = $true
            }
        }
        
        $GeminiSettings | ConvertTo-Json -Depth 3 | Out-File $GeminiConfig -Encoding UTF8
        return "Gemini CLI 복종 설정 생성 완료"
    } else {
        return "Gemini CLI 설정 확인 완료"
    }
}

# 5. 세션 컨텍스트 초기화
$SessionStep = {
    $SessionFile = ".kiro/session/current_session.json"
    
    $SessionContext = @{
        "session_id" = [System.Guid]::NewGuid().ToString()
        "start_time" = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "project_path" = (Get-Location).Path
        "initialization_status" = "COMPLETED"
        "active_specs" = @()
        "last_activity" = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    
    # 활성 스펙 확인
    if (Test-Path ".kiro/specs") {
        $ActiveSpecs = Get-ChildItem ".kiro/specs" -Directory
        $SessionContext.active_specs = $ActiveSpecs.Name
    }
    
    $SessionContext | ConvertTo-Json -Depth 3 | Out-File $SessionFile -Encoding UTF8
    return "세션 컨텍스트 초기화 완료 (ID: $($SessionContext.session_id.Substring(0,8)))"
}

# 6. 프로젝트 상태 스냅샷
$SnapshotStep = {
    $Snapshot = @{
        "timestamp" = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "git_status" = @{}
        "flutter_status" = @{}
        "test_status" = @{}
        "spec_status" = @{}
    }
    
    # Git 상태
    try {
        $GitStatus = git status --porcelain 2>$null
        $Snapshot.git_status = @{
            "clean" = [string]::IsNullOrEmpty($GitStatus)
            "changed_files" = if ($GitStatus) { ($GitStatus | Measure-Object).Count } else { 0 }
        }
    } catch {
        $Snapshot.git_status = @{ "error" = "Git not available" }
    }
    
    # Flutter 상태
    $Snapshot.flutter_status = @{
        "pubspec_exists" = Test-Path "pubspec.yaml"
        "lib_exists" = Test-Path "lib"
        "main_dart_exists" = Test-Path "lib/main.dart"
    }
    
    # 테스트 상태
    if (Test-Path "test") {
        $TestFiles = Get-ChildItem "test" -Recurse -Filter "*.dart"
        $Snapshot.test_status = @{
            "test_dir_exists" = $true
            "test_files_count" = $TestFiles.Count
        }
    } else {
        $Snapshot.test_status = @{ "test_dir_exists" = $false }
    }
    
    # 스펙 상태
    if (Test-Path ".kiro/specs") {
        $Specs = Get-ChildItem ".kiro/specs" -Directory
        $Snapshot.spec_status = @{
            "specs_count" = $Specs.Count
            "specs" = @()
        }
        
        foreach ($Spec in $Specs) {
            $SpecInfo = @{
                "name" = $Spec.Name
                "has_requirements" = Test-Path "$($Spec.FullName)/requirements.md"
                "has_design" = Test-Path "$($Spec.FullName)/design.md"
                "has_tasks" = Test-Path "$($Spec.FullName)/tasks.md"
            }
            $Snapshot.spec_status.specs += $SpecInfo
        }
    } else {
        $Snapshot.spec_status = @{ "specs_count" = 0 }
    }
    
    $Snapshot | ConvertTo-Json -Depth 4 | Out-File ".kiro/session/project_snapshot.json" -Encoding UTF8
    return "프로젝트 상태 스냅샷 생성 완료"
}

# 7. 추천 작업 생성
$RecommendationStep = {
    $Recommendations = @()
    
    # 스펙 기반 추천
    if (Test-Path ".kiro/specs") {
        $ActiveSpecs = Get-ChildItem ".kiro/specs" -Directory
        foreach ($Spec in $ActiveSpecs) {
            if (Test-Path "$($Spec.FullName)/tasks.md") {
                $Recommendations += "스펙 '$($Spec.Name)' 다음 작업 실행"
            } elseif (Test-Path "$($Spec.FullName)/design.md") {
                $Recommendations += "스펙 '$($Spec.Name)' 작업 목록 생성"
            } elseif (Test-Path "$($Spec.FullName)/requirements.md") {
                $Recommendations += "스펙 '$($Spec.Name)' 설계 문서 작성"
            }
        }
    }
    
    # 일반 추천
    $Recommendations += @(
        "Flutter 테스트 실행",
        "코드 품질 검사",
        "Gemini CLI 사용량 확인",
        "새 기능 스펙 생성"
    )
    
    $RecommendationData = @{
        "timestamp" = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "recommendations" = $Recommendations
    }
    
    $RecommendationData | ConvertTo-Json -Depth 2 | Out-File ".kiro/session/recommendations.json" -Encoding UTF8
    return "추천 작업 $($Recommendations.Count) 개 생성 완료"
}

# 메인 실행
try {
    # 단계별 실행
    Invoke-InitStep "워크스페이스 정리" $CleanupStep $false
    Invoke-InitStep "디렉토리 구조 생성" $DirectoryStep $true
    Invoke-InitStep "MCP 설정 확인" $MCPStep $true
    Invoke-InitStep "Gemini CLI 설정 확인" $GeminiStep $false
    Invoke-InitStep "세션 컨텍스트 초기화" $SessionStep $true
    
    if (-not $Quick) {
        Invoke-InitStep "프로젝트 상태 스냅샷" $SnapshotStep $false
        Invoke-InitStep "추천 작업 생성" $RecommendationStep $false
    }
    
    $Script:InitResults.Status = "SUCCESS"
    $TotalDuration = (Get-Date) - $Script:InitResults.StartTime
    
    if (-not $Silent) {
        Write-Host ""
        Write-Host "        KIRO 초기화 완료!" -ForegroundColor Green
        Write-Host "====================================" -ForegroundColor Gray
        Write-Host " 실행 결과:" -ForegroundColor Cyan
        Write-Host "  • 총 소요시간: $($TotalDuration.TotalSeconds.ToString('F1'))초" -ForegroundColor White
        Write-Host "  • 성공한 단계: $($Script:InitResults.Steps | Where-Object { $_.Status -eq 'SUCCESS' } | Measure-Object).Count 개" -ForegroundColor Green
        Write-Host "  • 실패한 단계: $($Script:InitResults.Steps | Where-Object { $_.Status -eq 'FAILED' } | Measure-Object).Count 개" -ForegroundColor Red
        
        if ($Script:InitResults.Errors.Count -gt 0) {
            Write-Host "  • 오류 목록:" -ForegroundColor Yellow
            foreach ($Error in $Script:InitResults.Errors) {
                Write-Host "    - $Error" -ForegroundColor Red
            }
        }
        
        Write-Host ""
        Write-Host " Kiro가 사용 준비되었습니다!" -ForegroundColor Magenta
        Write-Host " 추천 명령: '추천 작업 보여줘' 또는 '프로젝트 상태 확인해줘'" -ForegroundColor Cyan
    }
    
    # 결과 저장
    $Script:InitResults | ConvertTo-Json -Depth 4 | Out-File ".kiro/session/init_results.json" -Encoding UTF8
    
    exit 0
    
} catch {
    $Script:InitResults.Status = "FAILED"
    $Script:InitResults.FatalError = $_.Exception.Message
    
    Write-InitLog " 초기화 중 치명적 오류 발생: $($_.Exception.Message)" "FATAL" "Red"
    
    # 결과 저장
    $Script:InitResults | ConvertTo-Json -Depth 4 | Out-File ".kiro/session/init_results.json" -Encoding UTF8
    
    exit 1
}