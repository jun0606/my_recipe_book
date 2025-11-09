# Encoding: UTF-8 without BOM
# KIRO v7.0 MCP Server Installation Script (Encoding Safe)
# Safe for Windows Console with Korean support

# Set console encoding to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "KIRO v7.0 MCP Server Installation Started (13 servers)" -ForegroundColor Cyan

# Create MCP server directory
$MCPDir = "C:\Users\junlyn\.kiro\mcp-servers"
if (!(Test-Path $MCPDir)) {
    New-Item -ItemType Directory -Path $MCPDir -Force
    Write-Host "MCP server directory created: $MCPDir" -ForegroundColor Green
}

# Function to safely display progress
function Show-Progress {
    param($Step, $Total, $Description)
    Write-Host "[$Step/$Total] $Description" -ForegroundColor Yellow
}

# 1. Sequential-Thinking MCP Server
Show-Progress 1 7 "Installing Sequential-Thinking MCP Server..."
try {
    npm install -g @modelcontextprotocol/server-sequential-thinking
    Write-Host "Sequential-Thinking MCP Server installed successfully" -ForegroundColor Green
} catch {
    Write-Host "Sequential-Thinking installation failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 2. Desktop-Commander MCP Server
Show-Progress 2 7 "Installing Desktop-Commander MCP Server..."
try {
    npm install -g @wonderwhy-er/desktop-commander@latest
    Write-Host "Desktop-Commander MCP Server installed successfully" -ForegroundColor Green
} catch {
    Write-Host "Desktop-Commander installation failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 3. ArXiv-Search MCP Server (disabled by default)
Show-Progress 3 7 "Skipping ArXiv-Search MCP Server (disabled)..."
Write-Host "ArXiv-Search MCP Server skipped (API limitations)" -ForegroundColor Yellow

# 4. Playwright MCP Server
Show-Progress 4 7 "Installing Playwright MCP Server..."
try {
    # Install Playwright browsers first
    npx playwright install
    
    # Install Playwright MCP server
    npm install -g @microsoft/playwright-mcp
    Write-Host "Playwright MCP Server installed successfully" -ForegroundColor Green
} catch {
    Write-Host "Playwright installation failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 5. Context 7 MCP Server
Show-Progress 5 7 "Installing Context 7 MCP Server..."
try {
    npm install -g @upstash/context7-mcp
    Write-Host "Context 7 MCP Server installed successfully" -ForegroundColor Green
} catch {
    Write-Host "Context 7 installation failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 6. Magic MCP Server
Show-Progress 6 7 "Installing Magic MCP Server..."
try {
    npm install -g @21st-dev/magic-mcp
    Write-Host "Magic MCP Server installed successfully" -ForegroundColor Green
} catch {
    Write-Host "Magic installation failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 7. Task Master MCP Server
Show-Progress 7 7 "Installing Task Master MCP Server..."
try {
    npm install -g @eyaltoledano/task-master-mcp
    Write-Host "Task Master MCP Server installed successfully" -ForegroundColor Green
} catch {
    Write-Host "Task Master installation failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Return to original directory
Set-Location "C:\Users\junlyn\my_recipe_book"

Write-Host ""
Write-Host "KIRO v7.0 MCP Server Installation Completed!" -ForegroundColor Green
Write-Host "Installed servers (13 total):" -ForegroundColor Cyan
Write-Host "  Basic Infrastructure (7):" -ForegroundColor Yellow
Write-Host "    1. Filesystem: File system management" -ForegroundColor White
Write-Host "    2. Git: Version control" -ForegroundColor White
Write-Host "    3. SQLite: Database management" -ForegroundColor White
Write-Host "    4. Memory: Knowledge graph management" -ForegroundColor White
Write-Host "    5. Fetch: Web resource access" -ForegroundColor White
Write-Host "    6. GitHub: GitHub API integration" -ForegroundColor White
Write-Host "    7. MCP Go: Flutter/Dart analysis" -ForegroundColor White
Write-Host "  Intelligent Layer (2):" -ForegroundColor Yellow
Write-Host "    8. Sequential-Thinking: Structured thinking process" -ForegroundColor White
Write-Host "    9. Desktop-Commander: Desktop system control" -ForegroundColor White
Write-Host "  Advanced Automation (4):" -ForegroundColor Yellow
Write-Host "    10. Playwright: UI automation and testing" -ForegroundColor White
Write-Host "    11. Context 7: Context management and memory" -ForegroundColor White
Write-Host "    12. Magic: AI-based code generation and optimization" -ForegroundColor White
Write-Host "    13. Task Master: Task management and scheduling" -ForegroundColor White
Write-Host "  Disabled (1):" -ForegroundColor Red
Write-Host "    - ArXiv-Search: Research document search (API limitations)" -ForegroundColor Gray

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Restart Kiro IDE" -ForegroundColor White
Write-Host "  2. Verify 13 MCP server connections" -ForegroundColor White
Write-Host "  3. Test new advanced features" -ForegroundColor White
Write-Host "  4. Run KIRO v7.0 integrated workflow" -ForegroundColor White