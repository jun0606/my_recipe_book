# 📘 고도화된 MCP 사용 지침서 (2025.07.25 기준)

---

## 🔧 MCP 종류 및 기능 요약

| MCP 종류     | 주요 기능            | 설명                    |
|--------------|---------------------|-------------------------|
| filesystem   | 파일 읽기, 쓰기, 삭제      | 실제 파일 작업 수행            |
| git          | 변경 추적, 브랜치, diff   | Git 이력 및 변경 분석         |
| github       | GitHub API 연동      | PR, 이슈, 파일 참조 등 협업 지원 |
| sqlite       | 구조화된 데이터 저장/조회   | 메타데이터, 분석 결과 저장       |
| memory       | 임시 데이터 저장         | 세션 간 상태 공유, 빠른 캐시     |
| fetch        | 외부 리소스, AI 모델 호출  | 웹 문서, AI 연동 등 외부 요청   |
| mcp_go       | 병렬 처리, 복합 흐름 관리   | 고속 워크플로우, 효율 최적화     |

---

## 🧠 MCP 선택 결정 트리

```
작업 요청 받음
↓
단순 파일 읽기/쓰기? → YES → filesystem MCP
↓ NO
Git 관련 작업? → YES → git MCP
↓ NO
데이터 분석/쿼리? → YES → sqlite MCP
↓ NO
외부 리소스 필요? → YES → fetch MCP
↓ NO
세션 데이터 공유? → YES → memory MCP
↓ NO
복합 작업 → 여러 MCP 조합 사용 (mcp_go 포함)
```

---

## 🔍 작업별 MCP 우선순위 매트릭스 (MCP-GO 통합)

### 파일 작업

| 작업         | 1순위       | 2순위       | 3순위    | 4순위  | 사용 예시                      |
|--------------|-------------|-------------|----------|--------|-----------------------------|
| 단순 읽기     | filesystem  | mcp_go      | -        | -      | `read_file("lib/main.dart")` |
| 변경 추적     | git         | filesystem  | mcp_go    | -      | `git_diff("lib/main.dart")`  |
| 대용량 파일    | filesystem  | sqlite      | mcp_go    | -      | 분할 읽기 + 메타데이터 저장       |
| 복잡한 검색    | git         | filesystem  | sqlite   | mcp_go  | Git 히스토리 + 파일 내용 + 메타데이터 |

### 데이터 관리

| 작업         | 1순위       | 2순위       | 3순위    | 4순위  | 사용 예시                         |
|--------------|-------------|-------------|----------|--------|-------------------------------|
| 메타데이터 저장 | sqlite      | memory      | mcp_go    | -      | `execute_query("INSERT INTO...")` |
| 임시 데이터    | memory      | sqlite      | mcp_go    | -      | `create_entities([...])`           |
| 통계 분석     | sqlite      | memory      | mcp_go    | -      | `execute_query("SELECT COUNT...")` |
| 세션 공유     | memory      | sqlite      | mcp_go    | -      | `search_nodes("session_data")`      |

### 외부 연동

| 작업         | 1순위       | 2순위       | 3순위    | 4순위  | 사용 예시                     |
|--------------|-------------|-------------|----------|--------|-----------------------------|
| 웹 리소스     | fetch       | mcp_go      | -        | -      | `fetch("https://pub.dev/...")`  |
| GitHub 연동   | github      | git         | mcp_go    | -      | `get_file_contents(...)`        |
| 문서 참조     | fetch       | memory      | mcp_go    | -      | 외부 문서 + 캐싱                 |

---

## 🛠 MCP 주요 명령어 및 사용법

| MCP 종류     | 주요 명령어                                     | 입력 파라미터 예시                     | 반환값 예시                        | 에러 핸들링                     |
|--------------|-----------------------------------------------|---------------------------------------|------------------------------------|---------------------------------|
| filesystem   | `read_file(path)`                            | `path: "lib/main.dart"`              | `String` or `null`                 | 파일 없음 → `null` 반환, 로그 기록 |
|              | `write_file(path, content)`                  | `path: "lib/main.dart", content: "..."` | `bool` (성공 여부)                 | 쓰기 실패 → 예외 처리, 사용자 알림 |
|              | `read_multiple_files(paths)`                  | `paths: ["lib/a.dart", "lib/b.dart"]` | `List<String>`                     | 일부 파일 없음 → 부분 결과 반환   |
| git          | `git_status()`                               | -                                    | `String` (상태 정보)               | Git 오류 → 대체 파일 확인         |
|              | `git_diff(file)`                             | `file: "lib/main.dart"`              | `String` (diff 출력)               | 파일 미존재 → 빈 문자열 반환      |
| github       | `get_file_contents(repo, path)`              | `repo: "user/repo", path: "main.dart"` | `String` (파일 내용)               | 404 에러 → 대체 경로 제안        |
| sqlite       | `execute_query(sql)`                         | `sql: "INSERT INTO ..."`             | -                                  | 쿼리 오류 → 롤백 및 로그 기록     |
|              | `fetch_query(sql)`                           | `sql: "SELECT * FROM ..."`           | `List<Map>`                        | 결과 없음 → 빈 리스트 반환        |
| memory       | `create_entities(data)`                      | `data: [{"name": "key", "value": "..."}]` | -                              | 메모리 초과 → sqlite로 전환      |
|              | `load_entities(session_id)`                  | `session_id: "abc123"`               | `Map<String, dynamic>`             | 세션 없음 → 기본값 반환          |
| fetch        | `fetch(url, params)`                         | `url: "https://pub.dev", params: {...}` | `String` or `JSON`                 | 네트워크 오류 → 재시도 또는 캐시  |
| mcp_go       | `run_pipeline(tasks)`                        | `tasks: [read_file, git_status]`      | -                                  | 작업 실패 → 대체 경로 실행       |
|              | `run_parallel(tasks)`                        | `tasks: [read_file, fetch]`           | `List<dynamic>`                    | 부분 실패 → 실패 작업만 재시도    |

---

## 🔄 실제 사용 시나리오

### 시나리오 1: Flutter 오류 분석

1. **Git으로 최근 변경사항 확인**:
   - 명령어: `git_status()`
   - 출력: 변경된 파일 목록 (`lib/main.dart modified`)
   - 에러 핸들링: Git 상태 확인 실패 시 `filesystem`으로 파일 목록 대체 조회.

2. **filesystem으로 오류 파일 읽기**:
   - 명령어: `read_file("lib/main.dart")`
   - 출력: 파일 내용 문자열
   - 에러 핸들링: 파일 없음 → `null` 반환 및 사용자 알림.

3. **sqlite에 분석 결과 저장**:
   - 명령어: `execute_query("INSERT INTO code_analysis (error) VALUES ('Sample error')")`
   - 에러 핸들링: 쿼리 실패 시 롤백 및 로그 기록.

4. **memory에 해결 방법 캐싱**:
   - 명령어: `create_entities([{"name": "error_solution", "value": "Update widget tree"}])`
   - 에러 핸들링: 메모리 초과 시 `sqlite`로 전환.

5. **mcp_go로 작업 병렬 처리**:
   - 명령어: `mcp_go.run_pipeline(["git_status", "read_file", "execute_query", "create_entities"])`

**Flutter 코드 예시**:

```dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class MCP {
  Future<String?> readFile(String path) async {
    try {
      final file = File(path);
      return await file.exists() ? file.readAsString() : null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<String> gitStatus() async => 'lib/main.dart modified';

  Future<void> saveToSqlite(String query, Database db) async {
    try {
      await db.execute(query);
    } catch (e) {
      print('Error: $e');
    }
  }

  Map<String, dynamic> memoryCache = {};
  void createEntities(Map<String, dynamic> data) => memoryCache.addAll(data);

  Future<void> runPipeline(List<Function> tasks) async {
    for (var task in tasks) await task();
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(home: ErrorAnalysisScreen());
}

class ErrorAnalysisScreen extends StatefulWidget {
  @override
  _ErrorAnalysisScreenState createState() => _ErrorAnalysisScreenState();
}

class _ErrorAnalysisScreenState extends State<ErrorAnalysisScreen> {
  final MCP mcp = MCP();
  String result = '분석 대기 중...';

  Future<void> analyzeError() async {
    final dbPath = await getDatabasesPath();
    final db = await openDatabase('$dbPath/errors.db', version: 1,
        onCreate: (db, version) => db.execute(
            'CREATE TABLE code_analysis (id INTEGER PRIMARY KEY, error TEXT)'));

    await mcp.runPipeline([
      () async => setState(() => result = 'Git: ${await mcp.gitStatus()}'),
      () async => setState(() => result += '\nFile: ${(await mcp.readFile('lib/main.dart'))?.substring(0, 100) ?? "Not found"}'),
      () async => await mcp.saveToSqlite("INSERT INTO code_analysis (error) VALUES ('Sample error')", db),
      () => mcp.createEntities({'error_solution': 'Update widget tree'}) && setState(() => result += '\nCached: ${mcp.memoryCache['error_solution']}'),
    ]);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('MCP 오류 분석')),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(result),
              ElevatedButton(onPressed: analyzeError, child: Text('오류 분석 시작')),
            ],
          ),
        ),
      );
}
```

**의존성** (`pubspec.yaml`):
```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.3
  path_provider: ^2.1.4
```

---

### 시나리오 2: 프로젝트 구조 분석

1. **filesystem으로 프로젝트 구조 파악**:
   - 명령어: `directory_tree(".")`
   - 출력: 디렉토리 구조 JSON
   - 에러 핸들링: 디렉토리 접근 실패 시 기본 경로로 재시도.

2. **git으로 변경 빈도 분석**:
   - 명령어: `git_log("--stat")`
   - 출력: 파일별 변경 통계
   - 에러 핸들링: 로그 없음 → 빈 결과 반환.

3. **sqlite에 구조 메타데이터 저장**:
   - 명령어: `execute_query("UPDATE file_metadata SET complexity_score = ...")`

4. **fetch로 외부 베스트 프랙티스 참조**:
   - 명령어: `fetch("https://flutter.dev/docs/development/...")`

5. **mcp_go로 병렬 실행**:
   - 명령어: `mcp_go.run_parallel(["directory_tree", "git_log", "execute_query", "fetch"])`

---

### 시나리오 3: 코드 리팩터링

1. **git으로 브랜치 상태 확인**:
   - 명령어: `git_branch()`
2. **sqlite에서 리팩터링 대상 조회**:
   - 명령어: `execute_query("SELECT * FROM code_analysis WHERE severity > 3")`
3. **filesystem으로 대상 파일 읽기**:
   - 명령어: `read_multiple_files([...])`
4. **memory에 리팩터링 계획 저장**:
   - 명령어: `create_entities([{"name": "refactor_plan", ...}])`
5. **리팩터링 전후 비교**:
   - 명령어: `compare_code(before_files, after_files)`
   - 검증: UI/기능/목적 변조 여부 체크
6. **mcp_go로 프로세스 최적화**:
   - 명령어: `mcp_go.run_pipeline([...])`

---

### 시나리오 4: 기능 수정

1. **요구사항 분석**:
   - 명령어: `fetch("https://user_request_specification")`
2. **git 상태 확인**:
   - 명령어: `git_status()`
3. **sqlite로 영향 코드 조회**:
   - 명령어: `execute_query("SELECT * FROM code_analysis WHERE related_feature = 'target_feature'")`
4. **파일 읽기**:
   - 명령어: `read_multiple_files([...])`
5. **기능/UI 스냅샷 저장**:
   - 명령어: `memory.create_entities([{"name": "pre_change_snapshot", ...}])`
6. **코드 수정**:
   - 명령어: `fetch("AI_code_generation_endpoint", params={...})`
7. **변경 비교 및 검증**:
   - 명령어: `compare_code(...)`, `evaluate_consistency(...)`
8. **mcp_go로 프로세스 조율**:
   - 명령어: `mcp_go.run_pipeline([...])`

---

### 시나리오 5: 신규 기능 생성

1. **요구사항 수집**:
   - 명령어: `memory.create_entities([{"name": "feature_request", ...}])`
2. **AI로 코드 생성**:
   - 명령어: `fetch("AI_code_generation_endpoint", params={...})`
3. **충돌 확인**:
   - 명령어: `git_status()`, `execute_query(...)`
4. **파일 저장**:
   - 명령어: `write_files([...])`
5. **테스트 계획 저장**:
   - 명령어: `memory.create_entities([{"name": "feature_test_plan", ...}])`
6. **테스트 실행**:
   - Kiro: `mcp_go.run_pipeline(["deploy_test_code", "execute_test"])`
   - Gemini CLI: `gemini_cli.run_tests(test_code_path)`

---

### 시나리오 6: 세션 일관성 유지

1. **세션 데이터 로드**:
   - 명령어: `memory.load_entities(session_id=previous_session_id)`
2. **세션 데이터 저장**:
   - 명령어: `memory.save_entities(session_id=current_session_id)`
3. **데이터 동기화**:
   - 명령어: `sqlite.update_session_metadata()`, `git_commit_if_needed()`
4. **세션 변경 알림**:
   - 명령어: `notify_user("세션 변경 감지...")`

---

### 시나리오 7: 코드 테스트

1. **테스트 요청 저장**:
   - 명령어: `memory.create_entities([{"name": "code_test_request", ...}])`
2. **테스트 방식 선택**:
   - Kiro: 로컬 테스트, 빠른 피드백, 소규모 프로젝트 적합
   - Gemini CLI: 외부 API 호출, 대규모 테스트 적합
   - 사용자 선택 요청: `notify_user("Kiro 또는 Gemini CLI 선택")`
3. **테스트 실행**:
   - Kiro: `mcp_go.run_pipeline(["deploy_test_code", "execute_test"])`
   - Gemini CLI: `gemini_cli.run_tests(test_code_path)`
4. **결과 분석**:
   - 명령어: `memory.create_entities([{"name": "test_outcome", ...}])`
   - 명령어: `evaluate_consistency(expected_behavior, actual_behavior)`

**테스트 방식 비교**:

| 방식         | 장점                          | 단점                          | 추천 시나리오                 |
|--------------|------------------------------|------------------------------|-----------------------------|
| Kiro         | 빠른 실행, 로컬 환경 적합      | 대규모 테스트 제한            | 소규모/로컬 테스트            |
| Gemini CLI   | 외부 API 연동, 확장성 우수     | 네트워크 의존, 설정 복잡      | 대규모/원격 테스트            |

---

## ⚡ 성능 최적화 및 토큰 절약 전략

1. **MCP 조합 활용**:
   - `mcp_go.run_parallel`로 병렬 처리.
   - `memory`로 중복 요청 캐싱.
   - `sqlite`로 영구 데이터 저장.
   - `fetch` 호출 최소화.

2. **조건부/배치 처리**:
   - 파일 존재 여부 확인: `File(path).exists()`
   - 배치 호출: `read_multiple_files([...])`
   - 캐시 활용: `memory.load_entities(...)`

3. **일관성 유지**:
   - 리팩터링/수정 시 `compare_code`, `evaluate_consistency`로 검증.
   - 세션 동기화: `sqlite-memory sync`.

---

## 🚨 주의사항 및 권장 사항

- **메모리 관리**: MCP 서버 동시 실행 시 메모리 부하 주의.
- **데이터 동기화**: `sqlite-memory sync` 정기 실행.
- **Git 상태 확인**: `git`과 `filesystem` 불일치 시 `git_status` 우선.
- **파일 체크**: 파일 존재 여부 확인 후 작업 수행.
- **일관성 검증**: 리팩터링/수정 시 UI/기능/목적 검증 필수.
- **테스트 방식**: 사용자 선택 전 Kiro/Gemini CLI 장단점 설명.

---

## 📈 성공 지표

| 지표          | 목표                    | 측정 방법                          |
|---------------|------------------------|-----------------------------------|
| 토큰 효율성    | 기존 대비 60% 절약      | `sqlite`에 토큰 사용량 기록         |
| 작업 속도      | 50% 시간 단축          | `work_sessions` 테이블에 시간 기록   |
| 코드 정확도    | 오류 발생률 30% 감소    | `code_analysis` 테이블에 오류 기록   |
| 일관성 유지율  | 95% 이상               | `compare_code`, `evaluate_consistency` |

---

## 🎉 결론

7개의 MCP를 체계적으로 조합하여 작업 효율성 극대화, 토큰 낭비 최소화, 세션 및 작업 일관성 유지, 코드 테스트 및 검증을 완성합니다. 2025년 7월 25일 기준 최신화된 이 지침서는 Kiro 에디터와 Claude Sonnet 3.7 AI를 활용해 안정적이고 고품질의 Flutter/Python 개발 환경을 제공합니다.