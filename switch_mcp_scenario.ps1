# 🎯 MCP 시나리오 전환 스크립트
# 사용법: .\switch_mcp_scenario.ps1 -Scenario "coding"

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("coding", "tasks", "docs", "cleanup", "all")]
    [string]$Scenario
)

$KiroPath = ".kiro/settings"
$ScenariosPath = ".kiro/scenarios"

# 디렉토리 생성
if (!(Test-Path $KiroPath)) {
    New-Item -ItemType Directory -Path $KiroPath -Force
}

function Show-MCPStatus {
    Write-Host "🎯 현재 MCP 시나리오: " -ForegroundColor Cyan -NoNewline
    Write-Host $Scenario -ForegroundColor Yellow
    Write-Host ""
}

function Switch-MCPScenario {
    param([string]$ScenarioName)
    
    $SourceFile = "$ScenariosPath/${ScenarioName}_mcp.json"
    $TargetFile = "$KiroPath/mcp.json"
    
    if (Test-Path $SourceFile) {
        Copy-Item $SourceFile $TargetFile -Force
        Write-Host "✅ MCP 설정이 '$ScenarioName' 시나리오로 전환되었습니다." -ForegroundColor Green
        
        # 활성화된 서버 표시
        $Config = Get-Content $TargetFile | ConvertFrom-Json
        Write-Host "🔧 활성화된 MCP 서버:" -ForegroundColor Cyan
        foreach ($Server in $Config.mcpServers.PSObject.Properties.Name) {
            Write-Host "   • $Server" -ForegroundColor White
        }
        
        # 토큰 절약 효과 표시
        $ServerCount = $Config.mcpServers.PSObject.Properties.Count
        $SavingRate = [math]::Round((15 - $ServerCount) / 15 * 100, 0)
        Write-Host "💰 토큰 절약률: $SavingRate% (15개 → $ServerCount개)" -ForegroundColor Green
        
    } else {
        Write-Host "❌ 시나리오 파일을 찾을 수 없습니다: $SourceFile" -ForegroundColor Red
    }
}

# 시나리오별 처리
switch ($Scenario) {
    "coding" {
        Write-Host "🔧 코딩 & 디버깅 시나리오로 전환 중..." -ForegroundColor Yellow
        Write-Host "   • filesystem: 파일 작업" -ForegroundColor Gray
        Write-Host "   • git: 버전 관리" -ForegroundColor Gray
        Write-Host "   • sequential-thinking: 구조화된 사고" -ForegroundColor Gray
        Switch-MCPScenario "coding"
    }
    "tasks" {
        Write-Host "📊 작업 관리 시나리오로 전환 중..." -ForegroundColor Yellow
        Write-Host "   • task-master-ai: 작업 관리 (로컬 Ollama)" -ForegroundColor Gray
        Write-Host "   • filesystem: 파일 작업" -ForegroundColor Gray
        Switch-MCPScenario "tasks"
    }
    "docs" {
        Write-Host "📝 문서 작성 시나리오로 전환 중..." -ForegroundColor Yellow
        Write-Host "   • filesystem: 파일 작업" -ForegroundColor Gray
        Write-Host "   • sequential-thinking: 구조화된 사고" -ForegroundColor Gray
        
        # docs 시나리오 파일 생성
        $DocsConfig = @{
            mcpServers = @{
                filesystem = @{
                    command = "npx"
                    args = @("-y", "@modelcontextprotocol/server-filesystem", "C:/Users/junlyn/my_recipe_book")
                    disabled = $false
                    autoApprove = @("read_file", "write_file", "list_directory", "search_files")
                }
                "sequential-thinking" = @{
                    command = "npx"
                    args = @("-y", "@modelcontextprotocol/server-sequential-thinking")
                    disabled = $false
                    autoApprove = @("sequentialthinking")
                }
            }
        }
        $DocsConfig | ConvertTo-Json -Depth 10 | Out-File "$ScenariosPath/docs_mcp.json" -Encoding UTF8
        Switch-MCPScenario "docs"
    }
    "cleanup" {
        Write-Host "🧹 환경 정리 시나리오로 전환 중..." -ForegroundColor Yellow
        Write-Host "   • filesystem: 파일 작업" -ForegroundColor Gray
        Write-Host "   • git: 버전 관리" -ForegroundColor Gray
        
        # cleanup 시나리오 파일 생성
        $CleanupConfig = @{
            mcpServers = @{
                filesystem = @{
                    command = "npx"
                    args = @("-y", "@modelcontextprotocol/server-filesystem", "C:/Users/junlyn/my_recipe_book")
                    disabled = $false
                    autoApprove = @("read_file", "write_file", "list_directory", "search_files", "move_file")
                }
                git = @{
                    command = "npx"
                    args = @("-y", "@modelcontextprotocol/server-git", "--repository", "C:/Users/junlyn/my_recipe_book")
                    disabled = $false
                    autoApprove = @("git_status", "git_add", "git_commit", "git_log")
                }
            }
        }
        $CleanupConfig | ConvertTo-Json -Depth 10 | Out-File "$ScenariosPath/cleanup_mcp.json" -Encoding UTF8
        Switch-MCPScenario "cleanup"
    }
    "all" {
        Write-Host "🎯 전체 MCP 서버 활성화..." -ForegroundColor Yellow
        Copy-Item ".kiro/mcp_optimized.json" "$KiroPath/mcp.json" -Force
        Write-Host "✅ 4개 핵심 MCP 서버가 모두 활성화되었습니다." -ForegroundColor Green
    }
}

Write-Host ""
Show-MCPStatus
Write-Host "🔄 Kiro를 재시작하여 변경사항을 적용하세요." -ForegroundColor Cyan