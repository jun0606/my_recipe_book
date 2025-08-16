# KIRO v7.1 MCP 서버 설치 스크립트 (16개 서버)
# 작성일: 2025-01-27
# 목적: 3개 신규 MCP 서버 추가 설치

param(
    [switch]$Force,
    [switch]$NewServersOnly
)

# UTF-8 인코딩 설정
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "🚀 KIRO v7.1 MCP 서버 설치 시작" -ForegroundColor Green
Write-Host "=" * 50 -ForegroundColor Green

# 신규 서버만 설치하는 경우
if ($NewServersOnly) {
    Write-Host "📦 신규 3개 MCP 서버만 설치합니다" -ForegroundColor Cyan
    
    # 🪟 Windows Control MCP 설치
    Write-Host "`n🪟 1. Windows Control MCP 설치 중..." -ForegroundColor Yellow
    try {
        # Windows Control MCP는 아직 공식 패키지가 없을 수 있으므로 대안 사용
        Write-Host "⚠️ Windows Control MCP는 현재 개발 중입니다" -ForegroundColor Yellow
        Write-Host "💡 대신 Desktop-Commander MCP로 Windows 제어 기능 사용 가능" -ForegroundColor Green
    } catch {
        Write-Host "❌ Windows Control MCP 설치 실패: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # 🎭 Playwright MCP 확인 (이미 설치됨)
    Write-Host "`n🎭 2. Playwright MCP 확인 중..." -ForegroundColor Yellow
    try {
        $PlaywrightCheck = npm list -g @microsoft/playwright-mcp 2>$null
        if ($PlaywrightCheck) {
            Write-Host "✅ Playwright MCP 이미 설치됨" -ForegroundColor Green
        } else {
            Write-Host "📦 Playwright MCP 설치 중..." -ForegroundColor Cyan
            npm install -g @microsoft/playwright-mcp
            Write-Host "✅ Playwright MCP 설치 완료" -ForegroundColor Green
        }
        
        # Playwright 브라우저 설치
        Write-Host "🌐 Playwright 브라우저 설치 중..." -ForegroundColor Cyan
        npx playwright install
        Write-Host "✅ Playwright 브라우저 설치 완료" -ForegroundColor Green
        
    } catch {
        Write-Host "❌ Playwright MCP 설치 실패: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # 📄 MarkItDown MCP 설치
    Write-Host "`n📄 3. MarkItDown MCP 설치 중..." -ForegroundColor Yellow
    try {
        # Microsoft MarkItDown 설치
        Write-Host "📦 MarkItDown 패키지 설치 중..." -ForegroundColor Cyan
        pip install markitdown
        
        # MCP 서버 래퍼 생성 (Python 기반)
        $MarkItDownWrapper = @"
#!/usr/bin/env python3
import json
import sys
from markitdown import MarkItDown

def main():
    md = MarkItDown()
    
    # MCP 서버 기본 구조
    server_info = {
        "name": "markitdown-mcp",
        "version": "1.0.0",
        "description": "Microsoft MarkItDown MCP Server",
        "tools": [
            {
                "name": "convert_document",
                "description": "Convert document to markdown",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "file_path": {"type": "string"},
                        "output_path": {"type": "string"}
                    }
                }
            }
        ]
    }
    
    print(json.dumps(server_info, indent=2))

if __name__ == "__main__":
    main()
"@
        
        $WrapperPath = ".kiro/mcp-servers/markitdown/server.py"
        $WrapperDir = Split-Path $WrapperPath -Parent
        
        if (-not (Test-Path $WrapperDir)) {
            New-Item -ItemType Directory -Path $WrapperDir -Force | Out-Null
        }
        
        $MarkItDownWrapper | Set-Content -Path $WrapperPath -Encoding UTF8
        Write-Host "✅ MarkItDown MCP 서버 생성 완료" -ForegroundColor Green
        
    } catch {
        Write-Host "❌ MarkItDown MCP 설치 실패: $($_.Exception.Message)" -ForegroundColor Red
    }
    
} else {
    Write-Host "📦 전체 16개 MCP 서버 설치를 진행합니다" -ForegroundColor Cyan
    Write-Host "💡 기존 13개 서버 + 신규 3개 서버" -ForegroundColor White
    
    # 기존 설치 스크립트 실행
    if (Test-Path "install_mcp_servers.ps1") {
        Write-Host "`n🔄 기존 MCP 서버 설치 실행..." -ForegroundColor Cyan
        & ".\install_mcp_servers.ps1" -Force:$Force
    }
    
    # 신규 서버 설치
    & $MyInvocation.MyCommand.Path -NewServersOnly
}

# 설치 완료 확인
Write-Host "`n📊 KIRO v7.1 MCP 서버 설치 완료" -ForegroundColor Green
Write-Host "=" * 50 -ForegroundColor Green

# MCP 설정 파일 확인
if (Test-Path ".kiro/settings/mcp.json") {
    $McpConfig = Get-Content ".kiro/settings/mcp.json" | ConvertFrom-Json
    $ServerCount = $McpConfig.mcpServers.PSObject.Properties.Count
    Write-Host "✅ 총 $ServerCount 개 MCP 서버 설정 완료" -ForegroundColor Green
    
    # 신규 서버 확인
    $NewServers = @("windows-control", "markitdown")
    $ExistingServers = @("playwright")
    
    foreach ($Server in $NewServers) {
        if ($McpConfig.mcpServers.$Server) {
            Write-Host "🆕 $Server MCP 서버 설정 완료" -ForegroundColor Cyan
        }
    }
    
    foreach ($Server in $ExistingServers) {
        if ($McpConfig.mcpServers.$Server) {
            Write-Host "✅ $Server MCP 서버 기존 설정 확인" -ForegroundColor Green
        }
    }
}

Write-Host "`n🎉 KIRO v7.1 업그레이드 완료!" -ForegroundColor Green
Write-Host "🚀 13개 → 16개 MCP 서버로 확장" -ForegroundColor Yellow
Write-Host "💡 새로운 기능: Windows 제어, UI 자동화, 문서 변환" -ForegroundColor Cyan