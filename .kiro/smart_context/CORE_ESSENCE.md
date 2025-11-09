# 🎯 KIRO 핵심 요약 (Core Essence)
*토큰 최적화를 위한 초압축 가이드 - 200토큰 이내*

## ⚡ 즉시 사용 명령어
```powershell
# MCP 서버 상태 확인
Get-Process | Where-Object {$_.ProcessName -like "*mcp*"}

# Context7 라이브러리 검색
mcp_context7_resolve_library_id -libraryName "react"

# 자동화 스크립트 실행
.\kiro_smart_wrapper.ps1 -Task "analyze"
```

## 🔧 핵심 도구 3가지
1. **MCP 서버**: 외부 도구 연동 (uvx 명령어 사용)
2. **Context7**: 최신 라이브러리 문서 (토큰 10000 기본)
3. **자동화**: PowerShell 스크립트 기반 워크플로우

## 🚨 긴급 상황 대응
- 컴파일 오류: `emergency_fix.md` 모듈 로드
- MCP 연결 실패: `.kiro/settings/mcp.json` 확인
- 토큰 부족: 스마트 컨텍스트 매니저 실행

## 📊 현재 프로젝트 상태
- **레시피 계산기**: 컴파일 오류 해결 중
- **MCP 설정**: 정상 작동
- **자동화**: 스크립트 최적화 완료

*필요시 specific 모듈 요청: "mcp_core", "automation_key", "context7_quick", "emergency_fix"*