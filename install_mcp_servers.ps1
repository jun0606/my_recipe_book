# Encoding: UTF-8 without BOM
# KIRO v7.0 MCP Server Installation Script (13 servers)
# GitHub repository direct installation

# Set console encoding to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "KIRO v7.0 MCP Server Installation Started (13 servers)" -ForegroundColor Cyan

# MCP server installation directory creation
$MCPDir = "C:\Users\junlyn\.kiro\mcp-servers"
if (!(Test-Path $MCPDir)) {
    New-Item -ItemType Directory -Path $MCPDir -Force
    Write-Host "MCP server directory created: $MCPDir" -ForegroundColor Green
}

# 1. Sequential-Thinking MCP 서버 설치
Write-Host "🧠 1/3: Sequential-Thinking MCP 서버 설치 중..." -ForegroundColor Yellow
try {
    # NPM 패키지로 설치 시도
    npm install -g @modelcontextprotocol/server-sequential-thinking
    Write-Host "✅ Sequential-Thinking MCP 서버 설치 완료" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Sequential-Thinking NPM 패키지 설치 실패, GitHub에서 클론 시도..." -ForegroundColor Yellow
    
    $SeqThinkingDir = "$MCPDir\sequential-thinking"
    if (Test-Path $SeqThinkingDir) {
        Remove-Item $SeqThinkingDir -Recurse -Force
    }
    
    git clone https://github.com/modelcontextprotocol/servers.git $SeqThinkingDir
    Set-Location "$SeqThinkingDir\src\sequentialthinking"
    npm install
    Write-Host "✅ Sequential-Thinking GitHub 클론 및 설치 완료" -ForegroundColor Green
}

# 2. Desktop-Commander MCP 서버 설치
Write-Host "🖥️ 2/3: Desktop-Commander MCP 서버 설치 중..." -ForegroundColor Yellow
try {
    $DesktopCommanderDir = "$MCPDir\desktop-commander"
    if (Test-Path $DesktopCommanderDir) {
        Remove-Item $DesktopCommanderDir -Recurse -Force
    }
    
    git clone https://github.com/wonderwhy-er/desktop-commander.git $DesktopCommanderDir
    Set-Location $DesktopCommanderDir
    npm install
    Write-Host "✅ Desktop-Commander MCP 서버 설치 완료" -ForegroundColor Green
} catch {
    Write-Host "❌ Desktop-Commander 설치 실패: $($_.Exception.Message)" -ForegroundColor Red
}

# 3. ArXiv-Search MCP 서버 설치 (API 유료 사용시 제거 예정)
Write-Host "🔬 3/7: ArXiv-Search MCP 서버 설치 중..." -ForegroundColor Yellow
try {
    $ArxivSearchDir = "$MCPDir\arxiv-search"
    if (Test-Path $ArxivSearchDir) {
        Remove-Item $ArxivSearchDir -Recurse -Force
    }
    
    git clone https://github.com/markmcd/arxiv-search-mcp.git $ArxivSearchDir
    Set-Location $ArxivSearchDir
    npm install
    Write-Host "✅ ArXiv-Search MCP 서버 설치 완료" -ForegroundColor Green
    Write-Host "⚠️ 참고: API 유료 사용시 이 서버는 비활성화됩니다" -ForegroundColor Yellow
} catch {
    Write-Host "❌ ArXiv-Search 설치 실패: $($_.Exception.Message)" -ForegroundColor Red
}

# 4. Playwright MCP 서버 설치
Write-Host "🎭 4/7: Playwright MCP 서버 설치 중..." -ForegroundColor Yellow
try {
    # Playwright 브라우저 설치
    npx playwright install
    
    # Playwright MCP 서버 글로벌 설치
    npm install -g @microsoft/playwright-mcp
    Write-Host "✅ Playwright MCP 서버 설치 완료" -ForegroundColor Green
} catch {
    Write-Host "❌ Playwright 설치 실패: $($_.Exception.Message)" -ForegroundColor Red
}

# 5. Context 7 MCP 서버 설치
Write-Host "🧠 5/7: Context 7 MCP 서버 설치 중..." -ForegroundColor Yellow
try {
    npm install -g @upstash/context7-mcp
    Write-Host "✅ Context 7 MCP 서버 설치 완료" -ForegroundColor Green
} catch {
    Write-Host "❌ Context 7 설치 실패: $($_.Exception.Message)" -ForegroundColor Red
}

# 6. Magic MCP 서버 설치
Write-Host "✨ 6/7: Magic MCP 서버 설치 중..." -ForegroundColor Yellow
try {
    npm install -g @21st-dev/magic-mcp
    Write-Host "✅ Magic MCP 서버 설치 완료" -ForegroundColor Green
} catch {
    Write-Host "❌ Magic 설치 실패: $($_.Exception.Message)" -ForegroundColor Red
}

# 7. Task Master MCP 서버 설치
Write-Host "📋 7/7: Task Master MCP 서버 설치 중..." -ForegroundColor Yellow
try {
    npm install -g @eyaltoledano/task-master-mcp
    Write-Host "✅ Task Master MCP 서버 설치 완료" -ForegroundColor Green
} catch {
    Write-Host "❌ Task Master 설치 실패: $($_.Exception.Message)" -ForegroundColor Red
}

# 원래 디렉토리로 복귀
Set-Location "C:\Users\junlyn\my_recipe_book"

Write-Host ""
Write-Host "🎉 KIRO v7.0 MCP 서버 설치 완료!" -ForegroundColor Green
Write-Host "📊 설치된 서버 (13개):" -ForegroundColor Cyan
Write-Host "  🏗️ 기본 인프라 (7개):" -ForegroundColor Yellow
Write-Host "    1. Filesystem: 파일 시스템 관리" -ForegroundColor White
Write-Host "    2. Git: 버전 관리" -ForegroundColor White
Write-Host "    3. SQLite: 데이터베이스 관리" -ForegroundColor White
Write-Host "    4. Memory: 지식 그래프 관리" -ForegroundColor White
Write-Host "    5. Fetch: 웹 리소스 접근" -ForegroundColor White
Write-Host "    6. GitHub: GitHub API 통합" -ForegroundColor White
Write-Host "    7. MCP Go: Flutter/Dart 전용 분석" -ForegroundColor White
Write-Host "  🧠 지능형 레이어 (2개):" -ForegroundColor Yellow
Write-Host "    8. Sequential-Thinking: 구조화된 사고 프로세스" -ForegroundColor White
Write-Host "    9. Desktop-Commander: 데스크톱 시스템 제어" -ForegroundColor White
Write-Host "  🚀 고급 자동화 (4개):" -ForegroundColor Yellow
Write-Host "    10. Playwright: UI 자동화 및 테스팅" -ForegroundColor White
Write-Host "    11. Context 7: 컨텍스트 관리 및 기억" -ForegroundColor White
Write-Host "    12. Magic: AI 기반 코드 생성 및 최적화" -ForegroundColor White
Write-Host "    13. Task Master: 작업 관리 및 스케줄링" -ForegroundColor White
Write-Host "  ⚠️ 비활성화 (1개):" -ForegroundColor Red
Write-Host "    - ArXiv-Search: 연구 문서 검색 (API 제한)" -ForegroundColor Gray

Write-Host ""
Write-Host "🔧 다음 단계:" -ForegroundColor Yellow
Write-Host "  1. Kiro IDE 재시작" -ForegroundColor White
Write-Host "  2. 13개 MCP 서버 연결 상태 확인" -ForegroundColor White
Write-Host "  3. 새로운 고급 기능 테스트" -ForegroundColor White
Write-Host "  4. KIRO v7.0 통합 워크플로우 실행" -ForegroundColor White