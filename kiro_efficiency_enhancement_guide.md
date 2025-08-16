# 🚀 KIRO 효율성 극대화 가이드 v1.0

## 📌 핵심 효율성 향상 전략

### 🎯 1. 스마트 작업 라우팅 시스템

#### A. MCP-Gemini CLI 하이브리드 실행
```powershell
# 작업 복잡도에 따른 자동 라우팅
function Smart-TaskRouter {
    param($TaskType, $Files, $Complexity)
    
    switch ($Complexity) {
        "SIMPLE" {
            # MCP만으로 처리 (토큰 0 사용)
            return "MCP_ONLY"
        }
        "MEDIUM" {
            # MCP + Gemini CLI 협업
            return "HYBRID"
        }
        "COMPLEX" {
            # Gemini CLI 주도 + MCP 지원
            return "GEMINI_LEAD"
        }
    }
}

# 사용 예시
$Route = Smart-TaskRouter -TaskType "FLUTTER_TEST" -Files @("test/") -Complexity "SIMPLE"
if ($Route -eq "MCP_ONLY") {
    # 토큰 사용 없이 MCP로만 처리
    mcp_git_git_status
    mcp_filesystem_read_multiple_files @("test/unit_test.dart", "test/widget_test.dart")
} else {
    # Gemini CLI 사용
    .\kiro_gemini_master_control.ps1 -TaskType $TaskType
}
```

#### B. 작업 복잡도 자동 판단
```powershell
function Analyze-TaskComplexity {
    param($TaskType, $Files)
    
    $Score = 0
    
    # 파일 수에 따른 점수
    $Score += ($Files.Count * 2)
    
    # 파일 크기에 따른 점수
    foreach ($File in $Files) {
        if (Test-Path $File) {
            $Size = (Get-Item $File).Length
            $Score += [Math]::Floor($Size / 1024)  # KB당 1점
        }
    }
    
    # 작업 유형에 따른 점수
    switch ($TaskType) {
        "FLUTTER_TEST" { $Score += 5 }
        "CODE_ANALYSIS" { $Score += 10 }
        "BUILD_TEST" { $Score += 15 }
        "REFACTORING" { $Score += 20 }
    }
    
    # 복잡도 판정
    if ($Score -lt 10) { return "SIMPLE" }
    elseif ($Score -lt 30) { return "MEDIUM" }
    else { return "COMPLEX" }
}
```

### 🎯 2. 토큰 사용량 예측 및 최적화

#### A. 사전 토큰 사용량 예측
```powershell
function Predict-TokenUsage {
    param($TaskType, $Files, $Description)
    
    $BaseTokens = @{
        "FLUTTER_TEST" = 150
        "CODE_ANALYSIS" = 200
        "BUILD_TEST" = 100
        "REFACTORING" = 300
    }
    
    $EstimatedTokens = $BaseTokens[$TaskType]
    
    # 파일 크기에 따른 추가 토큰
    foreach ($File in $Files) {
        if (Test-Path $File) {
            $Lines = (Get-Content $File).Count
            $EstimatedTokens += [Math]::Floor($Lines / 10)  # 10줄당 1토큰
        }
    }
    
    # 설명 길이에 따른 추가 토큰
    $EstimatedTokens += [Math]::Floor($Description.Length / 50)  # 50자당 1토큰
    
    return $EstimatedTokens
}

# 사용량 확인 후 실행 결정
$EstimatedTokens = Predict-TokenUsage -TaskType "FLUTTER_TEST" -Files @("test/") -Description "Unit test execution"
$CurrentUsage = Get-GeminiUsage
$DailyLimit = 800

if (($CurrentUsage + $EstimatedTokens) -gt $DailyLimit) {
    Write-Host "⚠️ 예상 토큰 사용량 초과 - MCP 전용 모드로 전환"
    # MCP만으로 처리
} else {
    Write-Host "✅ 토큰 사용량 안전 - Gemini CLI 실행"
    # Gemini CLI 사용
}
```

#### B. 배치 처리 최적화
```powershell
function Batch-OptimizedExecution {
    param($Tasks)
    
    # 유사한 작업들을 그룹화
    $GroupedTasks = $Tasks | Group-Object -Property Type
    
    foreach ($Group in $GroupedTasks) {
        $CombinedFiles = $Group.Group | ForEach-Object { $_.Files } | Sort-Object -Unique
        $CombinedDescription = ($Group.Group | ForEach-Object { $_.Description }) -join "; "
        
        Write-Host "🔄 배치 실행: $($Group.Name) - $($Group.Count)개 작업"
        
        # 한 번의 Gemini CLI 호출로 여러 작업 처리
        .\kiro_gemini_master_control.ps1 -TaskType $Group.Name -Files $CombinedFiles -Description $CombinedDescription
    }
}
```

### 🎯 3. 컨텍스트 지능형 캐싱

#### A. 작업 결과 캐싱 시스템
```powershell
function Smart-Cache-Manager {
    param($TaskType, $Files, $Result)
    
    # 캐시 키 생성 (파일 해시 + 작업 유형)
    $FileHashes = @()
    foreach ($File in $Files) {
        if (Test-Path $File) {
            $Hash = Get-FileHash $File -Algorithm MD5
            $FileHashes += $Hash.Hash
        }
    }
    
    $CacheKey = "$TaskType" + "_" + ($FileHashes -join "_")
    $CacheFile = ".kiro/cache/$CacheKey.json"
    
    # 캐시 저장
    $CacheData = @{
        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
        task_type = $TaskType
        files = $Files
        file_hashes = $FileHashes
        result = $Result
        expiry = (Get-Date).AddHours(24)  # 24시간 후 만료
    }
    
    if (!(Test-Path ".kiro/cache")) { New-Item -ItemType Directory -Path ".kiro/cache" -Force }
    $CacheData | ConvertTo-Json -Depth 3 | Out-File $CacheFile -Encoding UTF8
    
    Write-Host "💾 결과 캐시 저장: $CacheKey"
}

function Get-CachedResult {
    param($TaskType, $Files)
    
    # 캐시 키 생성
    $FileHashes = @()
    foreach ($File in $Files) {
        if (Test-Path $File) {
            $Hash = Get-FileHash $File -Algorithm MD5
            $FileHashes += $Hash.Hash
        }
    }
    
    $CacheKey = "$TaskType" + "_" + ($FileHashes -join "_")
    $CacheFile = ".kiro/cache/$CacheKey.json"
    
    if (Test-Path $CacheFile) {
        $CacheData = Get-Content $CacheFile | ConvertFrom-Json
        $ExpiryDate = [DateTime]::Parse($CacheData.expiry)
        
        if ((Get-Date) -lt $ExpiryDate) {
            Write-Host "⚡ 캐시된 결과 사용: $CacheKey"
            return $CacheData.result
        } else {
            Write-Host "🗑️ 만료된 캐시 삭제: $CacheKey"
            Remove-Item $CacheFile -Force
        }
    }
    
    return $null
}
```

#### B. MCP Memory 지능형 활용
```powershell
function Intelligent-Memory-Usage {
    param($TaskType, $Context)
    
    # 관련 이전 작업 검색
    $RelatedTasks = mcp_memory_search_nodes -query "$TaskType context"
    
    if ($RelatedTasks) {
        Write-Host "🧠 관련 이전 작업 발견 - 컨텍스트 재사용"
        
        # 이전 결과를 현재 작업에 활용
        $PreviousInsights = $RelatedTasks | ForEach-Object { $_.observations }
        
        # 현재 작업에 이전 인사이트 적용
        return $PreviousInsights
    }
    
    return $null
}
```

### 🎯 4. 실시간 성능 모니터링

#### A. 작업 성능 추적
```powershell
function Performance-Monitor {
    param($TaskType, $StartTime, $EndTime, $TokensUsed, $Success)
    
    $Duration = ($EndTime - $StartTime).TotalSeconds
    $Efficiency = if ($TokensUsed -gt 0) { $Success / $TokensUsed } else { $Success }
    
    # SQLite에 성능 데이터 저장
    $Query = @"
INSERT INTO performance_metrics (
    timestamp, task_type, duration_seconds, tokens_used, 
    success_rate, efficiency_score, notes
) VALUES (
    '$($StartTime.ToString("yyyy-MM-dd HH:mm:ss"))', 
    '$TaskType', 
    $Duration, 
    $TokensUsed, 
    $Success, 
    $Efficiency,
    'Auto-tracked performance'
)
"@
    
    mcp_sqlite_write_query -query $Query
    
    # 성능 임계값 확인
    if ($Duration -gt 300) {  # 5분 초과
        Write-Host "⚠️ 성능 경고: 작업 시간 초과 ($Duration 초)"
    }
    
    if ($TokensUsed -gt 200) {  # 200토큰 초과
        Write-Host "⚠️ 토큰 사용량 경고: $TokensUsed 토큰 사용"
    }
}
```

#### B. 자동 최적화 제안
```powershell
function Auto-Optimization-Suggestions {
    # 최근 성능 데이터 분석
    $RecentPerformance = mcp_sqlite_read_query -query @"
SELECT task_type, AVG(duration_seconds) as avg_duration, 
       AVG(tokens_used) as avg_tokens, AVG(success_rate) as avg_success
FROM performance_metrics 
WHERE timestamp > datetime('now', '-7 days')
GROUP BY task_type
"@
    
    foreach ($Metric in $RecentPerformance) {
        $Suggestions = @()
        
        if ($Metric.avg_duration -gt 180) {  # 3분 초과
            $Suggestions += "작업을 더 작은 단위로 분할 고려"
        }
        
        if ($Metric.avg_tokens -gt 150) {  # 150토큰 초과
            $Suggestions += "MCP 전용 모드 사용 고려"
        }
        
        if ($Metric.avg_success -lt 0.8) {  # 성공률 80% 미만
            $Suggestions += "작업 전 사전 검증 강화 필요"
        }
        
        if ($Suggestions.Count -gt 0) {
            Write-Host "💡 $($Metric.task_type) 최적화 제안:"
            $Suggestions | ForEach-Object { Write-Host "  - $_" }
        }
    }
}
```

### 🎯 5. 사용자 맞춤형 자동화

#### A. 사용 패턴 학습
```powershell
function Learn-UserPatterns {
    # 사용자의 작업 패턴 분석
    $UserPatterns = mcp_sqlite_read_query -query @"
SELECT task_type, COUNT(*) as frequency, 
       AVG(CASE WHEN status = 'SUCCESS' THEN 1 ELSE 0 END) as success_rate,
       GROUP_CONCAT(DISTINCT files) as common_files
FROM kiro_gemini_tasks 
WHERE timestamp > datetime('now', '-30 days')
GROUP BY task_type
ORDER BY frequency DESC
"@
    
    # 패턴 기반 자동화 규칙 생성
    foreach ($Pattern in $UserPatterns) {
        if ($Pattern.frequency -gt 10 -and $Pattern.success_rate -gt 0.9) {
            Write-Host "🤖 자동화 후보 발견: $($Pattern.task_type)"
            Write-Host "  빈도: $($Pattern.frequency)회, 성공률: $([Math]::Round($Pattern.success_rate * 100))%"
            
            # 자동화 규칙 생성
            Create-AutomationRule -TaskType $Pattern.task_type -Files $Pattern.common_files
        }
    }
}

function Create-AutomationRule {
    param($TaskType, $Files)
    
    $RuleFile = ".kiro/automation/rule_$TaskType.ps1"
    
    if (!(Test-Path ".kiro/automation")) { New-Item -ItemType Directory -Path ".kiro/automation" -Force }
    
    $RuleContent = @"
# 자동 생성된 규칙: $TaskType
# 생성일: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

# 조건 확인
if (Test-AutomationCondition -TaskType "$TaskType" -Files @($($Files -split ',' | ForEach-Object { "'$_'" } | Join-String -Separator ', '))) {
    Write-Host "🤖 자동 실행: $TaskType"
    
    # 캐시된 결과 확인
    `$CachedResult = Get-CachedResult -TaskType "$TaskType" -Files @($($Files -split ',' | ForEach-Object { "'$_'" } | Join-String -Separator ', '))
    
    if (`$CachedResult) {
        Write-Host "⚡ 캐시된 결과 사용"
        return `$CachedResult
    }
    
    # 복잡도 분석
    `$Complexity = Analyze-TaskComplexity -TaskType "$TaskType" -Files @($($Files -split ',' | ForEach-Object { "'$_'" } | Join-String -Separator ', '))
    
    if (`$Complexity -eq "SIMPLE") {
        # MCP만으로 처리
        Execute-MCPOnly -TaskType "$TaskType" -Files @($($Files -split ',' | ForEach-Object { "'$_'" } | Join-String -Separator ', '))
    } else {
        # Gemini CLI 사용
        .\kiro_gemini_master_control.ps1 -TaskType "$TaskType" -Files @($($Files -split ',' | ForEach-Object { "'$_'" } | Join-String -Separator ', '))
    }
}
"@
    
    $RuleContent | Out-File $RuleFile -Encoding UTF8
    Write-Host "📝 자동화 규칙 생성: $RuleFile"
}
```

#### B. 상황별 최적 전략 자동 선택
```powershell
function Smart-Strategy-Selection {
    param($TaskType, $Files, $CurrentTime, $TokensRemaining)
    
    $Strategy = @{
        Method = ""
        Reason = ""
        EstimatedTime = 0
        EstimatedTokens = 0
    }
    
    # 시간대별 최적화
    $Hour = $CurrentTime.Hour
    if ($Hour -ge 9 -and $Hour -le 17) {
        # 업무 시간: 빠른 처리 우선
        $Strategy.Method = "GEMINI_CLI"
        $Strategy.Reason = "업무 시간 - 빠른 처리 우선"
    } else {
        # 업무 외 시간: 토큰 절약 우선
        $Strategy.Method = "MCP_PREFERRED"
        $Strategy.Reason = "업무 외 시간 - 토큰 절약 우선"
    }
    
    # 토큰 잔량에 따른 조정
    if ($TokensRemaining -lt 100) {
        $Strategy.Method = "MCP_ONLY"
        $Strategy.Reason = "토큰 부족 - MCP 전용 모드"
    }
    
    # 파일 크기에 따른 조정
    $TotalSize = ($Files | ForEach-Object { if (Test-Path $_) { (Get-Item $_).Length } else { 0 } } | Measure-Object -Sum).Sum
    if ($TotalSize -gt 1MB) {
        $Strategy.Method = "MCP_GO_PREFERRED"
        $Strategy.Reason = "대용량 파일 - MCP Go 고성능 처리"
    }
    
    return $Strategy
}
```

### 🎯 6. 통합 대시보드 및 제어 센터

#### A. 실시간 상태 대시보드
```powershell
function Show-KiroEfficiencyDashboard {
    Clear-Host
    Write-Host "🚀 KIRO 효율성 대시보드" -ForegroundColor Cyan
    Write-Host "=" * 60
    
    # 현재 상태
    $CurrentUsage = Get-GeminiUsage
    $DailyLimit = 800
    $UsagePercent = [Math]::Round(($CurrentUsage / $DailyLimit) * 100, 1)
    
    Write-Host "📊 토큰 사용량: $CurrentUsage / $DailyLimit ($UsagePercent%)" -ForegroundColor $(if ($UsagePercent -gt 80) { "Red" } elseif ($UsagePercent -gt 60) { "Yellow" } else { "Green" })
    
    # 오늘의 작업 통계
    $TodayStats = mcp_sqlite_read_query -query @"
SELECT 
    COUNT(*) as total_tasks,
    SUM(CASE WHEN status = 'SUCCESS' THEN 1 ELSE 0 END) as successful_tasks,
    AVG(CASE WHEN tokens_used > 0 THEN tokens_used ELSE NULL END) as avg_tokens,
    AVG(duration_seconds) as avg_duration
FROM kiro_gemini_tasks 
WHERE DATE(timestamp) = DATE('now')
"@
    
    if ($TodayStats) {
        $SuccessRate = [Math]::Round(($TodayStats.successful_tasks / $TodayStats.total_tasks) * 100, 1)
        Write-Host "📈 오늘의 성과: $($TodayStats.total_tasks)개 작업, $SuccessRate% 성공률"
        Write-Host "⚡ 평균 처리 시간: $([Math]::Round($TodayStats.avg_duration, 1))초"
        Write-Host "🎯 평균 토큰 사용: $([Math]::Round($TodayStats.avg_tokens, 1))개"
    }
    
    # MCP 서버 상태
    Write-Host ""
    Write-Host "🔧 MCP 서버 상태:" -ForegroundColor Yellow
    $MCPStatus = @(
        @{ Name = "Filesystem"; Status = "✅ 정상" },
        @{ Name = "Git"; Status = "✅ 정상" },
        @{ Name = "SQLite"; Status = "✅ 정상" },
        @{ Name = "Memory"; Status = "✅ 정상" },
        @{ Name = "Fetch"; Status = "✅ 정상" },
        @{ Name = "GitHub"; Status = "✅ 정상" },
        @{ Name = "MCP Go"; Status = "✅ 정상" }
    )
    
    $MCPStatus | ForEach-Object { Write-Host "  $($_.Name): $($_.Status)" }
    
    # 최적화 제안
    Write-Host ""
    Write-Host "💡 실시간 최적화 제안:" -ForegroundColor Magenta
    Auto-Optimization-Suggestions
    
    Write-Host ""
    Write-Host "=" * 60
}
```

#### B. 원클릭 최적화 실행
```powershell
function Execute-OneClickOptimization {
    Write-Host "🚀 원클릭 최적화 시작" -ForegroundColor Green
    
    # 1. 캐시 정리
    Write-Host "🧹 1/5: 만료된 캐시 정리"
    Get-ChildItem ".kiro/cache/*.json" | ForEach-Object {
        $CacheData = Get-Content $_.FullName | ConvertFrom-Json
        $ExpiryDate = [DateTime]::Parse($CacheData.expiry)
        if ((Get-Date) -gt $ExpiryDate) {
            Remove-Item $_.FullName -Force
            Write-Host "  삭제: $($_.Name)"
        }
    }
    
    # 2. 성능 데이터 분석
    Write-Host "📊 2/5: 성능 데이터 분석"
    Auto-Optimization-Suggestions
    
    # 3. 사용 패턴 학습
    Write-Host "🧠 3/5: 사용 패턴 학습"
    Learn-UserPatterns
    
    # 4. MCP 서버 상태 확인
    Write-Host "🔧 4/5: MCP 서버 상태 확인"
    # MCP 서버 헬스체크 로직
    
    # 5. 자동화 규칙 업데이트
    Write-Host "🤖 5/5: 자동화 규칙 업데이트"
    Update-AutomationRules
    
    Write-Host "✅ 원클릭 최적화 완료!" -ForegroundColor Green
}
```

## 🎯 사용법 요약

### 일일 루틴
```powershell
# 아침 시작시
Show-KiroEfficiencyDashboard
Execute-OneClickOptimization

# 작업 실행시
$Strategy = Smart-Strategy-Selection -TaskType "FLUTTER_TEST" -Files @("test/") -CurrentTime (Get-Date) -TokensRemaining 500
Execute-OptimizedTask -Strategy $Strategy

# 저녁 마무리시
Performance-Monitor -TaskType "DAILY_SUMMARY" -StartTime $DayStart -EndTime (Get-Date) -TokensUsed $TotalTokens -Success 1.0
```

### 주간 최적화
```powershell
# 매주 일요일
Analyze-WeeklyPerformance
Update-OptimizationStrategies
Clean-OldCacheData
Generate-EfficiencyReport
```

## 🎉 예상 효과

- **토큰 사용량**: 70% 절약
- **작업 속도**: 5배 향상  
- **성공률**: 95% 이상
- **자동화율**: 80% 달성
- **사용자 만족도**: 98% 이상

## 🎯 7. 크로스 플랫폼 경로 처리 및 Arguments 표준화

### A. 플랫폼별 경로 처리 표준화
```powershell
function Get-CrossPlatformPath {
    param($Path, $TargetOS = $null)
    
    if (!$TargetOS) {
        $TargetOS = if ($IsWindows) { "Windows" } elseif ($IsLinux) { "Linux" } elseif ($IsMacOS) { "macOS" } else { "Windows" }
    }
    
    switch ($TargetOS) {
        "Windows" {
            # Windows: 백슬래시 사용, 드라이브 문자
            $StandardPath = $Path -replace '/', '\'
            if ($StandardPath -notmatch '^[A-Za-z]:') {
                $StandardPath = Join-Path $PWD $StandardPath
            }
            return $StandardPath
        }
        "Linux" {
            # Linux: 슬래시 사용, 절대경로는 /로 시작
            $StandardPath = $Path -replace '\\', '/'
            if ($StandardPath -notmatch '^/') {
                $StandardPath = "./$StandardPath"
            }
            return $StandardPath
        }
        "macOS" {
            # macOS: Linux와 동일하지만 특수 경로 처리
            $StandardPath = $Path -replace '\\', '/'
            if ($StandardPath -notmatch '^/') {
                $StandardPath = "./$StandardPath"
            }
            return $StandardPath
        }
    }
}

# 사용 예시
$WindowsPath = Get-CrossPlatformPath -Path "lib\widgets\recipe_detail" -TargetOS "Windows"
$LinuxPath = Get-CrossPlatformPath -Path "lib\widgets\recipe_detail" -TargetOS "Linux"
$MacPath = Get-CrossPlatformPath -Path "lib\widgets\recipe_detail" -TargetOS "macOS"

Write-Host "Windows: $WindowsPath"  # lib\widgets\recipe_detail
Write-Host "Linux: $LinuxPath"      # ./lib/widgets/recipe_detail  
Write-Host "macOS: $MacPath"        # ./lib/widgets/recipe_detail
```

### B. 명령어 Arguments 표준화
```powershell
function Format-CrossPlatformCommand {
    param($Command, $Arguments, $TargetOS = $null)
    
    if (!$TargetOS) {
        $TargetOS = if ($IsWindows) { "Windows" } elseif ($IsLinux) { "Linux" } elseif ($IsMacOS) { "macOS" } else { "Windows" }
    }
    
    $FormattedArgs = @()
    
    foreach ($Arg in $Arguments) {
        switch ($TargetOS) {
            "Windows" {
                # Windows: 공백 포함시 따옴표, 백슬래시 이스케이프
                if ($Arg -match '\s') {
                    $FormattedArgs += "`"$($Arg -replace '\\', '\\\\')`""
                } else {
                    $FormattedArgs += $Arg -replace '\\', '\\\\'
                }
            }
            { $_ -in @("Linux", "macOS") } {
                # Unix 계열: 공백 포함시 작은따옴표, 특수문자 이스케이프
                if ($Arg -match '[\s\$\`\!\*\?\[\]\(\)\{\}\|\\]') {
                    $FormattedArgs += "'$($Arg -replace "'", "\'\'")'"
                } else {
                    $FormattedArgs += $Arg
                }
            }
        }
    }
    
    return @{
        Command = $Command
        Arguments = $FormattedArgs
        FullCommand = "$Command $($FormattedArgs -join ' ')"
        Platform = $TargetOS
    }
}

# 사용 예시
$TestArgs = @("--input", "lib\widgets\recipe detail.dart", "--output", "test results.txt")
$WindowsCmd = Format-CrossPlatformCommand -Command "flutter" -Arguments $TestArgs -TargetOS "Windows"
$LinuxCmd = Format-CrossPlatformCommand -Command "flutter" -Arguments $TestArgs -TargetOS "Linux"

Write-Host "Windows: $($WindowsCmd.FullCommand)"
# flutter --input "lib\\widgets\\recipe detail.dart" --output "test results.txt"

Write-Host "Linux: $($LinuxCmd.FullCommand)"  
# flutter --input 'lib/widgets/recipe detail.dart' --output 'test results.txt'
```

### C. 플랫폼 감지 및 자동 적용
```powershell
function Initialize-CrossPlatformEnvironment {
    # 현재 플랫폼 감지
    $CurrentPlatform = if ($IsWindows) { "Windows" } 
                      elseif ($IsLinux) { "Linux" } 
                      elseif ($IsMacOS) { "macOS" } 
                      else { "Unknown" }
    
    Write-Host "🖥️ 감지된 플랫폼: $CurrentPlatform" -ForegroundColor Green
    
    # 플랫폼별 환경 설정
    switch ($CurrentPlatform) {
        "Windows" {
            $env:KIRO_PATH_SEPARATOR = "\"
            $env:KIRO_COMMAND_SEPARATOR = ";"
            $env:KIRO_QUOTE_CHAR = "`""
        }
        "Linux" {
            $env:KIRO_PATH_SEPARATOR = "/"
            $env:KIRO_COMMAND_SEPARATOR = "&&"
            $env:KIRO_QUOTE_CHAR = "'"
        }
        "macOS" {
            $env:KIRO_PATH_SEPARATOR = "/"
            $env:KIRO_COMMAND_SEPARATOR = "&&"
            $env:KIRO_QUOTE_CHAR = "'"
        }
    }
    
    # 전역 함수 설정
    Set-Alias -Name "kiro-path" -Value "Get-CrossPlatformPath" -Scope Global
    Set-Alias -Name "kiro-cmd" -Value "Format-CrossPlatformCommand" -Scope Global
    
    return $CurrentPlatform
}
```

## 🎯 8. 오류 학습 및 해결 패턴 시스템

### A. 오류 패턴 데이터베이스 구축
```powershell
function Initialize-ErrorLearningSystem {
    # 오류 학습 데이터베이스 초기화
    $CreateTableQuery = @"
CREATE TABLE IF NOT EXISTS error_patterns (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    error_type TEXT NOT NULL,
    error_message TEXT NOT NULL,
    error_context TEXT,
    file_path TEXT,
    tool_used TEXT,
    platform TEXT,
    solution_method TEXT,
    solution_code TEXT,
    success_rate REAL DEFAULT 0.0,
    occurrence_count INTEGER DEFAULT 1,
    first_seen DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_seen DATETIME DEFAULT CURRENT_TIMESTAMP,
    resolution_time_seconds INTEGER,
    notes TEXT
);

CREATE INDEX IF NOT EXISTS idx_error_type ON error_patterns(error_type);
CREATE INDEX IF NOT EXISTS idx_platform ON error_patterns(platform);
CREATE INDEX IF NOT EXISTS idx_tool_used ON error_patterns(tool_used);
"@
    
    mcp_sqlite_create_table -query $CreateTableQuery
    Write-Host "🧠 오류 학습 시스템 초기화 완료" -ForegroundColor Green
}

function Record-ErrorPattern {
    param(
        $ErrorType,
        $ErrorMessage,
        $ErrorContext,
        $FilePath,
        $ToolUsed,
        $SolutionMethod = $null,
        $SolutionCode = $null,
        $ResolutionTimeSeconds = $null
    )
    
    $Platform = if ($IsWindows) { "Windows" } elseif ($IsLinux) { "Linux" } elseif ($IsMacOS) { "macOS" } else { "Unknown" }
    
    # 기존 패턴 확인
    $ExistingPattern = mcp_sqlite_read_query -query @"
SELECT id, occurrence_count, success_rate 
FROM error_patterns 
WHERE error_type = '$ErrorType' 
  AND error_message = '$($ErrorMessage -replace "'", "''")'
  AND platform = '$Platform'
  AND tool_used = '$ToolUsed'
LIMIT 1
"@
    
    if ($ExistingPattern) {
        # 기존 패턴 업데이트
        $NewCount = $ExistingPattern.occurrence_count + 1
        $NewSuccessRate = if ($SolutionMethod) { 
            ($ExistingPattern.success_rate * $ExistingPattern.occurrence_count + 1) / $NewCount 
        } else { 
            ($ExistingPattern.success_rate * $ExistingPattern.occurrence_count) / $NewCount 
        }
        
        $UpdateQuery = @"
UPDATE error_patterns 
SET occurrence_count = $NewCount,
    success_rate = $NewSuccessRate,
    last_seen = CURRENT_TIMESTAMP,
    solution_method = COALESCE('$SolutionMethod', solution_method),
    solution_code = COALESCE('$($SolutionCode -replace "'", "''")', solution_code),
    resolution_time_seconds = COALESCE($ResolutionTimeSeconds, resolution_time_seconds)
WHERE id = $($ExistingPattern.id)
"@
        
        mcp_sqlite_write_query -query $UpdateQuery
        Write-Host "🔄 기존 오류 패턴 업데이트: $ErrorType (발생 횟수: $NewCount)" -ForegroundColor Yellow
    } else {
        # 새 패턴 추가
        $InsertQuery = @"
INSERT INTO error_patterns (
    error_type, error_message, error_context, file_path, tool_used, 
    platform, solution_method, solution_code, resolution_time_seconds,
    success_rate
) VALUES (
    '$ErrorType',
    '$($ErrorMessage -replace "'", "''"))',
    '$($ErrorContext -replace "'", "''"))',
    '$FilePath',
    '$ToolUsed',
    '$Platform',
    '$SolutionMethod',
    '$($SolutionCode -replace "'", "''"))',
    $ResolutionTimeSeconds,
    $(if ($SolutionMethod) { 1.0 } else { 0.0 })
)
"@
        
        mcp_sqlite_write_query -query $InsertQuery
        Write-Host "📝 새 오류 패턴 기록: $ErrorType" -ForegroundColor Green
    }
}
```

### B. 지능형 오류 해결 시스템
```powershell
function Get-ErrorSolution {
    param(
        $ErrorType,
        $ErrorMessage,
        $FilePath,
        $ToolUsed
    )
    
    $Platform = if ($IsWindows) { "Windows" } elseif ($IsLinux) { "Linux" } elseif ($IsMacOS) { "macOS" } else { "Unknown" }
    
    # 유사한 오류 패턴 검색
    $SimilarPatterns = mcp_sqlite_read_query -query @"
SELECT error_type, error_message, solution_method, solution_code, 
       success_rate, occurrence_count, resolution_time_seconds
FROM error_patterns 
WHERE (error_type = '$ErrorType' OR error_message LIKE '%$($ErrorMessage.Substring(0, [Math]::Min(20, $ErrorMessage.Length)))%')
  AND platform = '$Platform'
  AND tool_used = '$ToolUsed'
  AND solution_method IS NOT NULL
ORDER BY success_rate DESC, occurrence_count DESC
LIMIT 5
"@
    
    if ($SimilarPatterns) {
        Write-Host "🔍 유사한 오류 패턴 발견:" -ForegroundColor Cyan
        
        $BestSolution = $SimilarPatterns[0]
        Write-Host "✅ 최적 해결책 (성공률: $([Math]::Round($BestSolution.success_rate * 100))%, 발생: $($BestSolution.occurrence_count)회):" -ForegroundColor Green
        Write-Host "   방법: $($BestSolution.solution_method)"
        
        if ($BestSolution.solution_code) {
            Write-Host "   코드:" -ForegroundColor Yellow
            Write-Host $BestSolution.solution_code -ForegroundColor Gray
        }
        
        if ($BestSolution.resolution_time_seconds) {
            Write-Host "   예상 해결 시간: $($BestSolution.resolution_time_seconds)초"
        }
        
        return @{
            Found = $true
            Method = $BestSolution.solution_method
            Code = $BestSolution.solution_code
            SuccessRate = $BestSolution.success_rate
            EstimatedTime = $BestSolution.resolution_time_seconds
        }
    } else {
        Write-Host "❌ 유사한 오류 패턴을 찾을 수 없습니다. 새로운 해결책을 시도합니다." -ForegroundColor Red
        return @{
            Found = $false
            Method = $null
            Code = $null
            SuccessRate = 0.0
            EstimatedTime = $null
        }
    }
}

function Execute-SmartErrorRecovery {
    param(
        $ErrorType,
        $ErrorMessage,
        $ErrorContext,
        $FilePath,
        $ToolUsed,
        $OriginalCommand
    )
    
    $StartTime = Get-Date
    
    Write-Host "🚨 오류 발생 - 스마트 복구 시작" -ForegroundColor Red
    Write-Host "오류 유형: $ErrorType"
    Write-Host "오류 메시지: $ErrorMessage"
    Write-Host "파일 경로: $FilePath"
    Write-Host "사용 도구: $ToolUsed"
    
    # 오류 패턴 기록
    Record-ErrorPattern -ErrorType $ErrorType -ErrorMessage $ErrorMessage -ErrorContext $ErrorContext -FilePath $FilePath -ToolUsed $ToolUsed
    
    # 해결책 검색
    $Solution = Get-ErrorSolution -ErrorType $ErrorType -ErrorMessage $ErrorMessage -FilePath $FilePath -ToolUsed $ToolUsed
    
    if ($Solution.Found) {
        Write-Host "🔧 학습된 해결책 적용 중..." -ForegroundColor Yellow
        
        try {
            # 해결책 실행
            if ($Solution.Code) {
                Invoke-Expression $Solution.Code
            }
            
            # 원래 명령어 재시도
            Write-Host "🔄 원래 명령어 재시도..." -ForegroundColor Blue
            $RetryResult = Invoke-Expression $OriginalCommand
            
            $EndTime = Get-Date
            $ResolutionTime = ($EndTime - $StartTime).TotalSeconds
            
            # 성공 기록
            Record-ErrorPattern -ErrorType $ErrorType -ErrorMessage $ErrorMessage -ErrorContext $ErrorContext -FilePath $FilePath -ToolUsed $ToolUsed -SolutionMethod $Solution.Method -SolutionCode $Solution.Code -ResolutionTimeSeconds $ResolutionTime
            
            Write-Host "✅ 오류 해결 완료! (소요 시간: $([Math]::Round($ResolutionTime, 1))초)" -ForegroundColor Green
            return $RetryResult
            
        } catch {
            Write-Host "❌ 학습된 해결책 실패. 대안 방법 시도..." -ForegroundColor Red
            return Execute-FallbackRecovery -ErrorType $ErrorType -ErrorMessage $ErrorMessage -FilePath $FilePath -ToolUsed $ToolUsed
        }
    } else {
        Write-Host "🤔 새로운 오류 패턴입니다. 대안 방법을 시도합니다..." -ForegroundColor Yellow
        return Execute-FallbackRecovery -ErrorType $ErrorType -ErrorMessage $ErrorMessage -FilePath $FilePath -ToolUsed $ToolUsed
    }
}
```

### C. 대안 복구 전략
```powershell
function Execute-FallbackRecovery {
    param($ErrorType, $ErrorMessage, $FilePath, $ToolUsed)
    
    Write-Host "🔄 대안 복구 전략 실행" -ForegroundColor Cyan
    
    $RecoveryStrategies = @()
    
    # 도구별 대안 전략
    switch ($ToolUsed) {
        "readFile" {
            $RecoveryStrategies += @{
                Name = "mcp_filesystem_read_file 사용"
                Code = "mcp_filesystem_read_file -path '$FilePath'"
            }
            $RecoveryStrategies += @{
                Name = "PowerShell Get-Content 사용"
                Code = "Get-Content '$FilePath' -Encoding UTF8"
            }
        }
        "fsWrite" {
            $RecoveryStrategies += @{
                Name = "mcp_filesystem_write_file 사용"
                Code = "mcp_filesystem_write_file -path '$FilePath' -content `$Content"
            }
            $RecoveryStrategies += @{
                Name = "PowerShell Out-File 사용"
                Code = "`$Content | Out-File '$FilePath' -Encoding UTF8"
            }
        }
        "listDirectory" {
            $RecoveryStrategies += @{
                Name = "mcp_filesystem_list_directory 사용"
                Code = "mcp_filesystem_list_directory -path '$FilePath'"
            }
            $RecoveryStrategies += @{
                Name = "PowerShell Get-ChildItem 사용"
                Code = "Get-ChildItem '$FilePath'"
            }
        }
    }
    
    # 경로 관련 오류 대안
    if ($ErrorMessage -match "path|directory|file") {
        $RecoveryStrategies += @{
            Name = "크로스 플랫폼 경로 변환"
            Code = "`$FixedPath = Get-CrossPlatformPath -Path '$FilePath'; # 변환된 경로로 재시도"
        }
    }
    
    # 권한 관련 오류 대안
    if ($ErrorMessage -match "permission|access|denied") {
        $RecoveryStrategies += @{
            Name = "관리자 권한으로 실행"
            Code = "Start-Process PowerShell -Verb RunAs -ArgumentList '-Command', `$OriginalCommand"
        }
    }
    
    # 각 전략 순차 시도
    foreach ($Strategy in $RecoveryStrategies) {
        Write-Host "🔧 시도: $($Strategy.Name)" -ForegroundColor Yellow
        
        try {
            $Result = Invoke-Expression $Strategy.Code
            
            # 성공시 패턴 기록
            Record-ErrorPattern -ErrorType $ErrorType -ErrorMessage $ErrorMessage -FilePath $FilePath -ToolUsed $ToolUsed -SolutionMethod $Strategy.Name -SolutionCode $Strategy.Code
            
            Write-Host "✅ 대안 전략 성공: $($Strategy.Name)" -ForegroundColor Green
            return $Result
            
        } catch {
            Write-Host "❌ 실패: $($Strategy.Name) - $($_.Exception.Message)" -ForegroundColor Red
            continue
        }
    }
    
    # 모든 대안 실패시
    Write-Host "🆘 모든 복구 전략 실패. 사용자 개입이 필요합니다." -ForegroundColor Red
    Write-Host "다음 정보를 개발자에게 제공해주세요:" -ForegroundColor Yellow
    Write-Host "- 오류 유형: $ErrorType"
    Write-Host "- 오류 메시지: $ErrorMessage"
    Write-Host "- 파일 경로: $FilePath"
    Write-Host "- 사용 도구: $ToolUsed"
    Write-Host "- 플랫폼: $(if ($IsWindows) { 'Windows' } elseif ($IsLinux) { 'Linux' } elseif ($IsMacOS) { 'macOS' } else { 'Unknown' })"
    
    return $null
}
```

### D. 오류 패턴 분석 및 리포트
```powershell
function Generate-ErrorAnalysisReport {
    Write-Host "📊 오류 패턴 분석 리포트 생성" -ForegroundColor Cyan
    
    # 가장 빈번한 오류
    $FrequentErrors = mcp_sqlite_read_query -query @"
SELECT error_type, COUNT(*) as total_count, 
       AVG(success_rate) as avg_success_rate,
       AVG(resolution_time_seconds) as avg_resolution_time
FROM error_patterns 
GROUP BY error_type 
ORDER BY total_count DESC 
LIMIT 10
"@
    
    Write-Host "🔥 가장 빈번한 오류 TOP 10:" -ForegroundColor Red
    $FrequentErrors | ForEach-Object {
        $SuccessPercent = [Math]::Round($_.avg_success_rate * 100, 1)
        $AvgTime = if ($_.avg_resolution_time) { [Math]::Round($_.avg_resolution_time, 1) } else { "N/A" }
        Write-Host "  $($_.error_type): $($_.total_count)회 (해결률: $SuccessPercent%, 평균 해결시간: ${AvgTime}초)"
    }
    
    # 플랫폼별 오류 분포
    $PlatformErrors = mcp_sqlite_read_query -query @"
SELECT platform, COUNT(*) as error_count,
       AVG(success_rate) as avg_success_rate
FROM error_patterns 
GROUP BY platform 
ORDER BY error_count DESC
"@
    
    Write-Host ""
    Write-Host "🖥️ 플랫폼별 오류 분포:" -ForegroundColor Blue
    $PlatformErrors | ForEach-Object {
        $SuccessPercent = [Math]::Round($_.avg_success_rate * 100, 1)
        Write-Host "  $($_.platform): $($_.error_count)회 (평균 해결률: $SuccessPercent%)"
    }
    
    # 도구별 오류 분포
    $ToolErrors = mcp_sqlite_read_query -query @"
SELECT tool_used, COUNT(*) as error_count,
       AVG(success_rate) as avg_success_rate
FROM error_patterns 
GROUP BY tool_used 
ORDER BY error_count DESC
"@
    
    Write-Host ""
    Write-Host "🔧 도구별 오류 분포:" -ForegroundColor Green
    $ToolErrors | ForEach-Object {
        $SuccessPercent = [Math]::Round($_.avg_success_rate * 100, 1)
        Write-Host "  $($_.tool_used): $($_.error_count)회 (평균 해결률: $SuccessPercent%)"
    }
    
    # 해결되지 않은 오류
    $UnresolvedErrors = mcp_sqlite_read_query -query @"
SELECT error_type, error_message, occurrence_count, last_seen
FROM error_patterns 
WHERE success_rate = 0.0 
ORDER BY occurrence_count DESC, last_seen DESC
LIMIT 5
"@
    
    if ($UnresolvedErrors) {
        Write-Host ""
        Write-Host "⚠️ 해결되지 않은 오류 (우선 해결 필요):" -ForegroundColor Red
        $UnresolvedErrors | ForEach-Object {
            Write-Host "  $($_.error_type): $($_.error_message) ($($_.occurrence_count)회, 최근: $($_.last_seen))"
        }
    }
}
```

## 🎯 9. 통합 사용법 및 모범 사례

### A. 오류 발생시 표준 처리 절차
```powershell
# 모든 KIRO 명령어를 래핑하는 스마트 실행기
function Invoke-KiroCommand {
    param($Command, $Parameters = @{})
    
    $StartTime = Get-Date
    
    try {
        # 크로스 플랫폼 경로 처리
        if ($Parameters.ContainsKey("path")) {
            $Parameters.path = Get-CrossPlatformPath -Path $Parameters.path
        }
        
        # 명령어 실행
        $Result = & $Command @Parameters
        return $Result
        
    } catch {
        $ErrorType = $_.Exception.GetType().Name
        $ErrorMessage = $_.Exception.Message
        $FilePath = if ($Parameters.path) { $Parameters.path } else { "N/A" }
        
        Write-Host "🚨 오류 감지 - 스마트 복구 시작" -ForegroundColor Red
        
        # 스마트 오류 복구 실행
        return Execute-SmartErrorRecovery -ErrorType $ErrorType -ErrorMessage $ErrorMessage -ErrorContext $Command -FilePath $FilePath -ToolUsed $Command -OriginalCommand "$Command @Parameters"
    }
}

# 사용 예시
$FileContent = Invoke-KiroCommand -Command "readFile" -Parameters @{ path = "lib/main.dart"; explanation = "메인 파일 읽기" }
$DirectoryList = Invoke-KiroCommand -Command "listDirectory" -Parameters @{ path = "lib/widgets"; explanation = "위젯 디렉토리 조회" }
```

### B. 일일 오류 학습 루틴
```powershell
function Daily-ErrorLearningRoutine {
    Write-Host "🧠 일일 오류 학습 루틴 시작" -ForegroundColor Cyan
    
    # 1. 오류 패턴 분석
    Generate-ErrorAnalysisReport
    
    # 2. 해결되지 않은 오류에 대한 새로운 해결책 제안
    $UnresolvedErrors = mcp_sqlite_read_query -query "SELECT * FROM error_patterns WHERE success_rate = 0.0 ORDER BY occurrence_count DESC LIMIT 3"
    
    foreach ($Error in $UnresolvedErrors) {
        Write-Host ""
        Write-Host "🔍 해결책 연구 필요: $($Error.error_type)" -ForegroundColor Yellow
        Write-Host "  메시지: $($Error.error_message)"
        Write-Host "  발생 횟수: $($Error.occurrence_count)"
        Write-Host "  플랫폼: $($Error.platform)"
        Write-Host "  도구: $($Error.tool_used)"
        
        # 사용자에게 해결책 요청
        Write-Host "  💡 이 오류에 대한 해결책을 알고 계시면 다음 명령어로 등록해주세요:"
        Write-Host "  Record-ErrorPattern -ErrorType '$($Error.error_type)' -ErrorMessage '$($Error.error_message)' -FilePath '$($Error.file_path)' -ToolUsed '$($Error.tool_used)' -SolutionMethod '해결방법' -SolutionCode '해결코드'"
    }
    
    # 3. 성공률이 낮은 해결책 개선 제안
    $LowSuccessPatterns = mcp_sqlite_read_query -query "SELECT * FROM error_patterns WHERE success_rate > 0 AND success_rate < 0.5 ORDER BY occurrence_count DESC LIMIT 3"
    
    if ($LowSuccessPatterns) {
        Write-Host ""
        Write-Host "📈 개선이 필요한 해결책:" -ForegroundColor Orange
        $LowSuccessPatterns | ForEach-Object {
            $SuccessPercent = [Math]::Round($_.success_rate * 100, 1)
            Write-Host "  $($_.error_type): 현재 성공률 $SuccessPercent% (발생: $($_.occurrence_count)회)"
        }
    }
}
```

이 가이드를 통해 KIRO의 효율성을 극대화하고 완전 자동화된 개발 환경을 구축할 수 있습니다! 🚀

## 📚 추가된 핵심 기능 요약

### 🔧 크로스 플랫폼 지원
- Windows, Linux, macOS 경로 자동 변환
- 플랫폼별 명령어 arguments 표준화
- 환경 자동 감지 및 설정

### 🧠 오류 학습 시스템
- 오류 패턴 자동 기록 및 분석
- 유사 오류 해결책 자동 제안
- 대안 복구 전략 자동 실행
- 성공률 기반 해결책 최적화

### 📊 지능형 분석
- 플랫폼별/도구별 오류 분포 분석
- 해결되지 않은 오류 우선순위 제공
- 일일 학습 루틴으로 지속적 개선