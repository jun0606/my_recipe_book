# 🔧 MCP 핵심 모듈 (300토큰)

## ⚡ 필수 명령어
```json
// .kiro/settings/mcp.json 기본 구조
{
  "mcpServers": {
    "context7": {
      "command": "uvx",
      "args": ["context7-mcp-server@latest"],
      "disabled": false
    }
  }
}
```

## 🚀 자주 사용하는 MCP 도구
1. **mcp_context7_resolve_library_id**: 라이브러리 ID 검색
2. **mcp_context7_get_library_docs**: 문서 가져오기
3. **mcp_desktop_commander_**: 파일 시스템 작업
4. **mcp_task_master_ai_**: 작업 관리

## 🔍 트러블슈팅
- 서버 재연결: MCP Server view에서 reconnect
- uvx 설치: `pip install uv` 후 uv 설치
- 권한 오류: PowerShell 관리자 모드 실행

## 📊 성능 최적화
- 토큰 제한: 기본 10000, 필요시 조정
- 자동 승인: autoApprove 배열에 도구명 추가
- 로그 레벨: FASTMCP_LOG_LEVEL=ERROR