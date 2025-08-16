# MCP 서버 공유 접근 가이드

## 🔄 동시 접근 해결 방안

### 방안 1: 별도 MCP 인스턴스 (현재 적용)
```json
// Kiro: .kiro/settings/mcp.json
// Gemini CLI: .gemini/mcp_config.json
// 각각 독립적인 MCP 서버 프로세스 실행
```

### 방안 2: 파일 기반 공유 통신
```bash
# Kiro가 MCP 결과를 파일로 저장
mcp_filesystem_read_file("lib/main.dart") > .shared/kiro_result.json

# Gemini CLI가 파일에서 읽기
result=$(cat .shared/kiro_result.json)
```

### 방안 3: Memory MCP 공유 데이터베이스
```bash
# 공통 메모리 공간 사용
- Kiro: mcp_memory_create_entities(shared_data)
- Gemini CLI: mcp_memory_search_nodes(shared_data)
- 실시간 데이터 동기화 가능
```

## 🚀 권장 구현 방법

### 1단계: 독립 MCP 인스턴스
- Kiro: 기존 .kiro/settings/mcp.json 사용
- Gemini CLI: 새로운 .gemini/mcp_config.json 사용
- 각각 독립적으로 MCP 서버 접근

### 2단계: 공유 데이터 동기화
- Memory MCP를 통한 상태 공유
- 파일 기반 결과 교환
- 실시간 협업 가능

### 3단계: 충돌 방지 메커니즘
- 파일 잠금 (lock file) 사용
- 작업 순서 조정
- 우선순위 기반 접근 제어

## 📊 성능 비교

| 방법 | 동시성 | 성능 | 구현 복잡도 | 안정성 |
|------|--------|------|-------------|--------|
| 별도 인스턴스 | ✅ 높음 | ⚡ 빠름 | 🟢 낮음 | 🛡️ 높음 |
| 파일 공유 | ⚠️ 제한적 | 🐌 느림 | 🟡 중간 | 🟡 중간 |
| 포트 기반 | ✅ 높음 | ⚡ 빠름 | 🔴 높음 | 🛡️ 높음 |

## 🎯 결론
**별도 MCP 인스턴스 + Memory MCP 공유**가 가장 실용적인 해결책입니다.

## ✅ Task 2 완료 상태 (2025-07-29)
- [x] MCP 서버 공유 접근 시스템 설계 완료
- [x] 3가지 해결 방안 분석 및 비교 완료
- [x] 성능 비교표 작성 완료
- [x] 구현 가이드 문서화 완료
- [x] 워크플로우 성공적으로 실행됨

**상태: 완료 ✅**