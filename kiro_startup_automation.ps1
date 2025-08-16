# 🚀 Kiro 시작 자동화 시스템
# Kiro IDE 시작시 자동으로 실행되는 통합 준비 스크립트

param(
    [switch]$NewSession,
    [switch]$ContinueSession,
    [switch]$QuickStart
)

Write-Host "🚀 KIRO 시작 자동화 시스템 v3.0" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Gray

# 1. 환경 상태 확인
function Test-KiroEnvironment {
    Write-Host "🔍 1단계: Kiro 환경 상태 확인" -ForegroundColor Yellow
    
    $Status = @{
        "MCP_Config" = Test-Path ".kiro/settings/mcp.json"
        "Gemini_Settings" = Test-Path "C:\Users\junlyn\.gemini\settings.json"
        "Project_Structure" = Test-Path "lib/main.dart"
        "Specs_Ready" = Test-Path ".kiro/specs"
    }
    
    foreach ($Check in $Status.GetEnumerator()) {
        if ($Check.Value) {
            Write-Host "  ✅ $($Check.Key): OK" -ForegroundColor Green
        } else {
            Write-Host "  ❌ $($Check.Key): MISSING" -ForegroundColor Red
        }
    }
    
    return $Status
}

# 2. 이전 세션 컨텍스트 복원
function Restore-SessionContext {
    Write-Host "🔄 2단계: 이전 세션 컨텍스트 복원" -ForegroundColor Yellow
    
    # 메모리에서 이전 작업 내용 로드
    if (Test-Path ".kiro/session/last_context.json") {
        $LastContext = Get-Content ".kiro/session/last_context.json" | ConvertFrom-Json
        Write-Host "  📋 마지막 작업: $($LastContext.last_task)" -ForegroundColor Gray
        Write-Host "  📅 작업 시간: $($LastContext.timestamp)" -ForegroundColor Gray
        Write-Host "  🎯 진행 상태: $($LastContext.progress)" -ForegroundColor Gray
        
        # 진행중인 스펙 작업 확인
        if ($LastContext.active_spec) {
            Write-Host "  📝 활성 스펙: $($LastContext.active_spec)" -ForegroundColor Cyan
            Write-Host "  🔄 다음 작업: $($LastContext.next_task)" -ForegroundColor Cyan
        }
    } else {
        Write-Host "  ℹ️ 새로운 세션 시작" -ForegroundColor Gray
    }
}

# 3. Gemini CLI 준비 상태 확인
function Test-GeminiReadiness {
    Write-Host "🤖 3단계: Gemini CLI 준비 상태 확인" -ForegroundColor Yellow
    
    try {
        # 사용량 확인
        $UsageResult = & .\gemini_usage_monitor.ps1 -Action STATUS 2>$null
        if ($UsageResult -match "새 작업 실행 가능") {
            Write-Host "  ✅ Gemini CLI: 사용 가능" -ForegroundColor Green
            Write-Host "  📊 사용량: 정상 범위" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️ Gemini CLI: 사용량 한계" -ForegroundColor Yellow
        }
        
        # 복종 설정 확인
        $ObedienceResult = & .\verify_gemini_obedience.ps1 2>$null
        if ($ObedienceResult -match "OBEDIENCE VERIFICATION COMPLETE") {
            Write-Host "  ✅ 복종 설정: 활성화됨" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️ 복종 설정: 확인 필요" -ForegroundColor Yellow
        }
        
    } catch {
        Write-Host "  ❌ Gemini CLI: 설정 오류" -ForegroundColor Red
    }
}

# 4. 프로젝트 상태 분석
function Analyze-ProjectStatus {
    Write-Host "📊 4단계: 프로젝트 상태 분석" -ForegroundColor Yellow
    
    # Git 상태 확인
    try {
        $GitStatus = git status --porcelain 2>$null
        if ($GitStatus) {
            $ChangedFiles = ($GitStatus | Measure-Object).Count
            Write-Host "  📝 변경된 파일: $ChangedFiles 개" -ForegroundColor Cyan
        } else {
            Write-Host "  ✅ Git: 깔끔한 상태" -ForegroundColor Green
        }
    } catch {
        Write-Host "  ℹ️ Git: 상태 확인 불가" -ForegroundColor Gray
    }
    
    # 활성 스펙 확인
    if (Test-Path ".kiro/specs") {
        $ActiveSpecs = Get-ChildItem ".kiro/specs" -Directory
        if ($ActiveSpecs) {
            Write-Host "  📋 활성 스펙: $($ActiveSpecs.Count) 개" -ForegroundColor Cyan
            foreach ($Spec in $ActiveSpecs) {
                if (Test-Path "$($Spec.FullName)/tasks.md") {
                    Write-Host "    🎯 $($Spec.Name): 실행 준비됨" -ForegroundColor Green
                } else {
                    Write-Host "    📝 $($Spec.Name): 설계 단계" -ForegroundColor Yellow
                }
            }
        }
    }
    
    # 테스트 상태 확인
    if (Test-Path "test") {
        $TestFiles = Get-ChildItem "test" -Recurse -Filter "*.dart"
        Write-Host "  🧪 테스트 파일: $($TestFiles.Count) 개" -ForegroundColor Cyan
    }
}

# 5. 자동 정리 및 최적화
function Optimize-WorkspaceCleanup {
    Write-Host "🧹 5단계: 워크스페이스 정리 및 최적화" -ForegroundColor Yellow
    
    # 중복 파일 정리
    $DuplicateFiles = @(
        "gemini_cli_kiro_integration.md",  # v2가 있으므로 제거
        "kiro_guidelines_updated v1.md",   # v2가 있으므로 제거
        "refactoring_plan.md",             # detailed 버전이 있으므로 제거
        "gemini_setup_guide.md",           # complete_guide가 있으므로 제거
        "mcp_connection_report.md",        # final_recommendation이 있으므로 제거
        "mcp_enhancement_strategy.md"      # final_recommendation이 있으므로 제거
    )
    
    $CleanedCount = 0
    foreach ($File in $DuplicateFiles) {
        if (Test-Path $File) {
            try {
                Remove-Item $File -Force
                Write-Host "  🗑️ 제거됨: $File" -ForegroundColor Gray
                $CleanedCount++
            } catch {
                Write-Host "  ⚠️ 제거 실패: $File" -ForegroundColor Yellow
            }
        }
    }
    
    if ($CleanedCount -gt 0) {
        Write-Host "  ✅ $CleanedCount 개 중복 파일 정리 완료" -ForegroundColor Green
    } else {
        Write-Host "  ✅ 워크스페이스 이미 정리됨" -ForegroundColor Green
    }
    
    # 로그 디렉토리 정리
    if (Test-Path ".kiro/logs") {
        $OldLogs = Get-ChildItem ".kiro/logs" | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) }
        if ($OldLogs) {
            $OldLogs | Remove-Item -Force
            Write-Host "  🗑️ 오래된 로그 $($OldLogs.Count) 개 정리" -ForegroundColor Gray
        }
    }
}

# 6. 필수 디렉토리 구조 생성
function Initialize-KiroStructure {
    Write-Host "📁 6단계: Kiro 디렉토리 구조 초기화" -ForegroundColor Yellow
    
    $RequiredDirs = @(
        ".kiro/session",
        ".kiro/logs",
        ".kiro/results",
        ".kiro/backup",
        ".kiro/specs"
    )
    
    foreach ($Dir in $RequiredDirs) {
        if (-not (Test-Path $Dir)) {
            New-Item -ItemType Directory -Path $Dir -Force | Out-Null
            Write-Host "  📁 생성됨: $Dir" -ForegroundColor Green
        }
    }
}

# 7. 세션 컨텍스트 저장
function Save-SessionContext {
    param([string]$Status)
    
    $Context = @{
        "timestamp" = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "session_type" = if ($NewSession) { "new" } elseif ($ContinueSession) { "continue" } else { "auto" }
        "startup_status" = $Status
        "project_path" = (Get-Location).Path
        "active_files" = @()
        "next_recommendations" = @()
    }
    
    # 활성 스펙이 있으면 추가
    if (Test-Path ".kiro/specs") {
        $ActiveSpecs = Get-ChildItem ".kiro/specs" -Directory
        $Context["active_specs"] = $ActiveSpecs.Name
    }
    
    $Context | ConvertTo-Json -Depth 3 | Out-File ".kiro/session/last_context.json" -Encoding UTF8
}

# 8. 추천 작업 제시
function Show-RecommendedActions {
    Write-Host "💡 8단계: 추천 작업" -ForegroundColor Yellow
    
    # 활성 스펙 기반 추천
    if (Test-Path ".kiro/specs") {
        $ActiveSpecs = Get-ChildItem ".kiro/specs" -Directory
        foreach ($Spec in $ActiveSpecs) {
            if (Test-Path "$($Spec.FullName)/tasks.md") {
                Write-Host "  🎯 스펙 실행 가능: $($Spec.Name)" -ForegroundColor Cyan
                Write-Host "    명령: 스펙 '$($Spec.Name)' 다음 작업 실행해줘" -ForegroundColor Gray
            }
        }
    }
    
    # 일반적인 추천 작업
    Write-Host "  📋 일반 작업:" -ForegroundColor Cyan
    Write-Host "    • 'Flutter 테스트 실행해줘' - 전체 테스트 실행" -ForegroundColor Gray
    Write-Host "    • '코드 품질 검사해줘' - 정적 분석 실행" -ForegroundColor Gray
    Write-Host "    • '새 기능 스펙 만들어줘' - 기능 설계 시작" -ForegroundColor Gray
    Write-Host "    • 'Gemini CLI 상태 확인해줘' - 사용량 모니터링" -ForegroundColor Gray
}

# 메인 실행 로직
function Start-KiroAutomation {
    $StartTime = Get-Date
    
    try {
        # 환경 확인
        $EnvStatus = Test-KiroEnvironment
        
        # 세션 복원
        if (-not $NewSession) {
            Restore-SessionContext
        }
        
        # Gemini CLI 준비 상태
        Test-GeminiReadiness
        
        # 프로젝트 분석
        Analyze-ProjectStatus
        
        # 워크스페이스 정리
        if (-not $QuickStart) {
            Optimize-WorkspaceCleanup
        }
        
        # 구조 초기화
        Initialize-KiroStructure
        
        # 컨텍스트 저장
        Save-SessionContext -Status "SUCCESS"
        
        # 추천 작업
        Show-RecommendedActions
        
        $Duration = (Get-Date) - $StartTime
        Write-Host "`n🎉 Kiro 시작 준비 완료! (소요시간: $($Duration.TotalSeconds.ToString('F1'))초)" -ForegroundColor Green
        Write-Host "============================================" -ForegroundColor Gray
        Write-Host "이제 Kiro와 함께 작업을 시작할 수 있습니다! 🚀" -ForegroundColor Cyan
        
    } catch {
        Write-Host "❌ Kiro 시작 중 오류 발생: $($_.Exception.Message)" -ForegroundColor Red
        Save-SessionContext -Status "ERROR"
        exit 1
    }
}

# 실행
Start-KiroAutomation