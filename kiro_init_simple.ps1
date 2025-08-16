# Kiro Simple Initialization Script

param(
    [switch]$Quick,
    [switch]$Force
)

Write-Host "Kiro Initialization Started" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Gray

# 1. Create required directories
Write-Host "Step 1: Creating required directories" -ForegroundColor Yellow

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
        Write-Host "  Created: $Dir" -ForegroundColor Green
        $CreatedCount++
    } else {
        Write-Host "  Exists: $Dir" -ForegroundColor Gray
    }
}

Write-Host "  Total directories created/verified: $($RequiredDirs.Count)" -ForegroundColor Cyan

# 2. Check MCP configuration
Write-Host "`nStep 2: Checking MCP configuration" -ForegroundColor Yellow

$MCPConfig = ".kiro/settings/mcp.json"
if (-not (Test-Path $MCPConfig)) {
    Write-Host "  Creating default MCP configuration..." -ForegroundColor Yellow
    
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
    Write-Host "  MCP configuration created" -ForegroundColor Green
} else {
    Write-Host "  MCP configuration exists" -ForegroundColor Green
}

# 3. Check Gemini CLI configuration
Write-Host "`nStep 3: Checking Gemini CLI configuration" -ForegroundColor Yellow

$GeminiConfig = "C:\Users\junlyn\.gemini\settings.json"
if (-not (Test-Path $GeminiConfig)) {
    Write-Host "  Creating Gemini CLI obedience configuration..." -ForegroundColor Yellow
    
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
    Write-Host "  Gemini CLI configuration created" -ForegroundColor Green
} else {
    Write-Host "  Gemini CLI configuration exists" -ForegroundColor Green
}

# 4. Initialize session context
Write-Host "`nStep 4: Initializing session context" -ForegroundColor Yellow

$SessionFile = ".kiro/session/current_session.json"
$SessionId = [System.Guid]::NewGuid().ToString().Substring(0,8)

$SessionContext = @{
    "session_id" = $SessionId
    "start_time" = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "project_path" = (Get-Location).Path
    "initialization_status" = "COMPLETED"
    "active_specs" = @()
    "last_activity" = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
}

# Check for active specs
if (Test-Path ".kiro/specs") {
    $ActiveSpecs = Get-ChildItem ".kiro/specs" -Directory
    $SessionContext.active_specs = $ActiveSpecs.Name
    Write-Host "  Found $($ActiveSpecs.Count) active specs" -ForegroundColor Cyan
}

$SessionContext | ConvertTo-Json -Depth 3 | Out-File $SessionFile -Encoding UTF8
Write-Host "  Session context initialized (ID: $SessionId)" -ForegroundColor Green

# 5. Project status snapshot (if not Quick mode)
if (-not $Quick) {
    Write-Host "`nStep 5: Creating project status snapshot" -ForegroundColor Yellow
    
    $Snapshot = @{
        "timestamp" = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "git_status" = @{}
        "flutter_status" = @{}
        "test_status" = @{}
        "spec_status" = @{}
    }
    
    # Git status
    try {
        $GitStatus = git status --porcelain 2>$null
        $Snapshot.git_status = @{
            "clean" = [string]::IsNullOrEmpty($GitStatus)
            "changed_files" = if ($GitStatus) { ($GitStatus | Measure-Object).Count } else { 0 }
        }
        Write-Host "  Git status: $(if ($Snapshot.git_status.clean) { 'Clean' } else { $Snapshot.git_status.changed_files + ' files changed' })" -ForegroundColor Gray
    } catch {
        $Snapshot.git_status = @{ "error" = "Git not available" }
        Write-Host "  Git status: Not available" -ForegroundColor Gray
    }
    
    # Flutter status
    $Snapshot.flutter_status = @{
        "pubspec_exists" = Test-Path "pubspec.yaml"
        "lib_exists" = Test-Path "lib"
        "main_dart_exists" = Test-Path "lib/main.dart"
    }
    Write-Host "  Flutter project: $(if ($Snapshot.flutter_status.main_dart_exists) { 'Valid' } else { 'Invalid' })" -ForegroundColor Gray
    
    # Test status
    if (Test-Path "test") {
        $TestFiles = Get-ChildItem "test" -Recurse -Filter "*.dart"
        $Snapshot.test_status = @{
            "test_dir_exists" = $true
            "test_files_count" = $TestFiles.Count
        }
        Write-Host "  Test files: $($TestFiles.Count)" -ForegroundColor Gray
    } else {
        $Snapshot.test_status = @{ "test_dir_exists" = $false }
        Write-Host "  Test files: None" -ForegroundColor Gray
    }
    
    # Spec status
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
        Write-Host "  Active specs: $($Specs.Count)" -ForegroundColor Gray
    } else {
        $Snapshot.spec_status = @{ "specs_count" = 0 }
        Write-Host "  Active specs: 0" -ForegroundColor Gray
    }
    
    $Snapshot | ConvertTo-Json -Depth 4 | Out-File ".kiro/session/project_snapshot.json" -Encoding UTF8
    Write-Host "  Project snapshot created" -ForegroundColor Green
}

# 6. Generate recommendations
Write-Host "`nStep 6: Generating recommendations" -ForegroundColor Yellow

$Recommendations = @()

# Spec-based recommendations
if (Test-Path ".kiro/specs") {
    $ActiveSpecs = Get-ChildItem ".kiro/specs" -Directory
    foreach ($Spec in $ActiveSpecs) {
        if (Test-Path "$($Spec.FullName)/tasks.md") {
            $Recommendations += "Execute next task for spec '$($Spec.Name)'"
        } elseif (Test-Path "$($Spec.FullName)/design.md") {
            $Recommendations += "Create task list for spec '$($Spec.Name)'"
        } elseif (Test-Path "$($Spec.FullName)/requirements.md") {
            $Recommendations += "Create design document for spec '$($Spec.Name)'"
        }
    }
}

# General recommendations
$Recommendations += @(
    "Run Flutter tests",
    "Perform code quality check",
    "Check Gemini CLI usage status",
    "Create new feature spec"
)

$RecommendationData = @{
    "timestamp" = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "recommendations" = $Recommendations
}

$RecommendationData | ConvertTo-Json -Depth 2 | Out-File ".kiro/session/recommendations.json" -Encoding UTF8
Write-Host "  Generated $($Recommendations.Count) recommendations" -ForegroundColor Green

# Completion
$Duration = (Get-Date) - (Get-Date $SessionContext.start_time)
Write-Host "`nKiro Initialization Complete!" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Gray
Write-Host "Session ID: $SessionId" -ForegroundColor Cyan
Write-Host "Duration: $($Duration.TotalSeconds.ToString('F1')) seconds" -ForegroundColor Cyan
Write-Host ""
Write-Host "Kiro is ready for use!" -ForegroundColor Magenta
Write-Host "Recommended commands:" -ForegroundColor Yellow
Write-Host "  • 'Show recommended tasks'" -ForegroundColor White
Write-Host "  • 'Check project status'" -ForegroundColor White
Write-Host "  • 'Check Gemini CLI status'" -ForegroundColor White
Write-Host "  • 'Show active specs'" -ForegroundColor White