# Kiro를 위한 강화된 지침서 v2.0: MCP 최적화, Claude 토큰 효율성, 일관성 보장

## 🎯 1. 목적 및 핵심 원칙
이 지침서는 Kiro IDE에서 Claude AI의 토큰 효율성을 극대화하고, MCP 도구를 체계적으로 활용하며, 세션 간 일관성을 보장하는 방법을 정의합니다. Flutter 개발(`C:/Users/junlyn/my_recipe_book`, GitHub: `jun0606/my_recipe_book`)에 특화되어 있으며, 학생 친화적 무료 도구만 사용합니다.

### 🔥 핵심 원칙
- **토큰 효율성 최우선**: 모든 작업에서 토큰 낭비 최소화
- **MCP 도구 우선 활용**: 기본 도구보다 MCP 도구 우선 사용
- **일관성 보장**: 세션 간 설정 및 작업 방식 통일
- **오류 예방**: 사전 검증을 통한 오류 방지

---

## 🚀 2. MCP 도구 사용 우선순위 매트릭스

### 2.1 파일 작업 우선순위
```
1순위: mcp_filesystem_* (토큰 효율성 최고)
2순위: readFile, readMultipleFiles (Kiro 내장)
3순위: filesystem MCP (호환성용)
```

### 2.2 검색 작업 우선순위
```
1순위: grepSearch (정확한 패턴 매칭)
2순위: fileSearch (파일명 검색)
3순위: mcp_filesystem_search_files (대용량 검색)
```

### 2.3 디렉토리 탐색 우선순위
```
1순위: listDirectory (구조 파악)
2순위: mcp_filesystem_directory_tree (전체 구조)
3순위: mcp_filesystem_list_directory (상세 정보)
```

---

## 💡 3. 토큰 효율성 강화 전략

### 3.1 응답 길이 제한 규칙
- **코드 블록**: 50줄 이하, 초과 시 fsWrite + fsAppend 분할
- **로그 출력**: 핵심 오류만 20줄 이하로 발췌
- **파일 내용**: start_line, end_line 활용해 관련 부분만 표시
- **설명**: 불필요한 반복 제거, 액션 중심 서술

### 3.2 필수 사전 검증 패턴
```bash
# 파일 읽기 전 필수 검증
1. fileSearch 또는 listDirectory로 존재 확인
2. mcp_filesystem_get_file_info로 크기 확인
3. 대용량 파일(>1000줄)은 부분 읽기 적용
```

### 3.3 캐싱 전략
```bash
# Memory MCP 적극 활용
- 검색 결과: mcp_memory_create_entities로 저장
- 파일 구조: 세션당 1회만 탐색 후 캐싱
- 오류 패턴: 해결 방법과 함께 저장
```

---

## 🛠️ 4. 자동 오류 복구 워크플로우

### 4.1 Flutter 특화 오류 처리
```dart
// 자동 감지 패턴
1. Widget 생성 오류 → const 키워드 자동 추가 제안
2. State 관리 오류 → Provider 패턴 검증
3. 비동기 처리 → FutureBuilder/StreamBuilder 검증
4. 의존성 충돌 → pubspec.yaml 호환성 자동 체크
```

### 4.2 오류 발생 시 자동 복구 순서
```bash
1. grepSearch로 유사 오류 패턴 검색
2. mcp_memory에서 이전 해결 방법 조회
3. 자동 수정 제안 생성
4. 수정 후 결과를 mcp_memory에 저장
```

---

## 🔧 5. 실제 MCP 설정 (Kiro 구조 기반)

### 5.1 현재 작동하는 MCP 서버
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", 
               "C:/Users/junlyn/my_recipe_book", 
               "C:/Users/junlyn/.gemini"],
      "disabled": false
    },
    "fetch": {
      "command": "uvx",
      "args": ["mcp-server-fetch"],
      "disabled": false
    },
    "memory": {
      "command": "mcp-server-memory",
      "args": ["--root", "."],
      "disabled": false
    },
    "github": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-github"],
      "env": {"GITHUB_TOKEN": "YOUR_TOKEN"},
      "disabled": false
    }
  }
}
```

### 5.2 MCP 도구 역할 분담
- **filesystem**: 로컬 파일 읽기/쓰기/검색
- **fetch**: 외부 문서 참조 (pub.dev, GitHub 등)
- **memory**: 세션 중 정보 캐싱 및 관계 추론
- **github**: 원격 저장소 탐색 및 예제 참조

---

## 📊 6. 세션 연속성 보장 체크리스트

### 6.1 작업 시작 시 필수 확인
```bash
✅ MCP 서버 상태 확인
✅ 이전 작업 상태 mcp_memory에서 조회
✅ 프로젝트 구조 변경사항 확인
✅ 언어 설정 (한국어) 확인
```

### 6.2 작업 완료 시 필수 기록
```bash
✅ 변경사항 mcp_memory에 저장
✅ 다음 작업 가이드 생성
✅ 오류 해결 패턴 문서화
✅ .kiro/specs/에 주요 변경사항 기록
```

---

## 🎯 7. Flutter 특화 최적화

### 7.1 자주 발생하는 오류 자동 감지
```dart
// 패턴 매칭으로 자동 감지
- "Text(숫자)" → "Text('$숫자')" 자동 제안
- "Column(children: Widget)" → "Column(children: [Widget])" 수정
- "setState() 누락" → Provider 패턴 제안
- "Null safety 오류" → ?. 연산자 추가 제안
```

### 7.2 의존성 관리 자동화
```yaml
# pubspec.yaml 자동 검증
- 최신 버전 자동 확인 (pub.dev API 활용)
- 호환성 충돌 사전 감지
- 불필요한 의존성 정리 제안
```

---

## 🔍 8. 고급 검색 및 분석 패턴

### 8.1 코드 패턴 분석
```bash
# 효율적인 코드 분석 순서
1. grepSearch로 특정 패턴 검색
2. readMultipleFiles로 관련 파일 일괄 조회
3. mcp_memory로 분석 결과 저장
4. 개선 제안 생성
```

### 8.2 프로젝트 구조 분석
```bash
# 토큰 효율적인 구조 파악
1. listDirectory로 주요 디렉토리 확인
2. mcp_filesystem_directory_tree로 전체 구조 1회 조회
3. 결과를 mcp_memory에 캐싱
4. 이후 캐시된 정보 활용
```

---

## 🚨 9. 토큰 누수 방지 강화

### 9.1 금지된 패턴
```bash
❌ 존재 확인 없이 파일 읽기
❌ 동일한 검색 반복 실행
❌ 대용량 파일 전체 읽기
❌ 불필요한 디렉토리 전체 탐색
```

### 9.2 권장 패턴
```bash
✅ fileSearch → 존재 확인 → 조건부 읽기
✅ mcp_memory 캐싱 → 재사용
✅ start_line, end_line 활용한 부분 읽기
✅ grepSearch로 정확한 위치 파악 후 읽기
```

---

## 📈 10. 성능 모니터링 및 최적화

### 10.1 토큰 사용량 추적
```bash
# 세션별 토큰 사용량 기록
- 파일 읽기: 라인 수 × 토큰 계수
- 검색 작업: 결과 수 × 복잡도
- 응답 생성: 길이 × 상세도
```

### 10.2 최적화 지표
```bash
# 목표 지표
- 파일 읽기 성공률: >95%
- 캐시 활용률: >80%
- 오류 예방률: >90%
- 응답 간결성: <50줄/응답
```

---

## 🔄 11. 지속적 개선 메커니즘

### 11.1 학습 패턴 저장
```bash
# mcp_memory 활용한 패턴 학습
- 성공한 해결 방법 저장
- 실패한 접근 방식 기록
- 사용자 선호도 학습
- 프로젝트별 특성 저장
```

### 11.2 자동 업데이트 체크
```bash
# 정기적 최적화 검토
- MCP 서버 상태 점검
- 새로운 도구 호환성 확인
- 토큰 효율성 개선 방안 탐색
- 사용자 피드백 반영
```

---

## 📚 12. 참고 정보 및 리소스

### 12.1 프로젝트 정보
- **로컬 경로**: `C:/Users/junlyn/my_recipe_book`
- **GitHub**: `jun0606/my_recipe_book`
- **언어**: 한국어 고정
- **개발 스택**: Flutter (Dart 3.x), Provider 패턴

### 12.2 주요 문서 위치
- **본 지침**: `kiro_guidelines_updated_v2.md`
- **세션 기록**: `.kiro/specs/session_history.md`
- **오류 패턴**: `.kiro/specs/error_patterns.md`
- **최적화 로그**: `.kiro/specs/optimization_log.md`

---

## ✅ 13. 체크리스트 및 검증

### 13.1 매 세션 시작 시
- [ ] MCP 서버 연결 상태 확인
- [ ] 이전 세션 정보 mcp_memory에서 로드
- [ ] 프로젝트 구조 변경사항 확인
- [ ] 토큰 효율성 목표 설정

### 13.2 작업 진행 중
- [ ] 파일 읽기 전 존재 여부 확인
- [ ] 검색 결과 mcp_memory에 캐싱
- [ ] 응답 길이 50줄 이하 유지
- [ ] 오류 발생 시 자동 복구 패턴 적용

### 13.3 세션 종료 시
- [ ] 주요 변경사항 mcp_memory에 저장
- [ ] 다음 작업 가이드 생성
- [ ] 토큰 사용량 기록
- [ ] 개선점 문서화

---

**🎯 이 강화된 지침서는 Claude AI의 토큰 효율성을 극대화하고, Kiro IDE에서의 일관된 작업 환경을 보장하며, Flutter 개발 생산성을 향상시키는 것을 목표로 합니다.**