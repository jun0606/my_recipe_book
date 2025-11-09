# 프로젝트 문서 인덱스

## 1. 개요

이 문서는 프로젝트의 모든 문서에 대한 중앙 집중식 인덱스를 제공합니다. 각 문서의 목적, 중요도, 관련 문서를 한눈에 파악할 수 있도록 구성되어 있습니다.

## 2. 문서 카테고리 및 우선순위

문서 중요도는 다음과 같이 분류됩니다:
- **필수(Essential)**: 프로젝트 이해와 작업에 반드시 필요한 문서
- **권장(Recommended)**: 효율적인 작업을 위해 참조하는 것이 좋은 문서
- **참조(Reference)**: 특정 상황에서 필요할 때 참조하는 문서

## 3. 문서 목록

### 3.1 프로젝트 개요 및 구조 문서

| 문서명 | 경로 | 목적 | 중요도 | 관련 문서 |
|-------|------|------|--------|----------|
| 앱 구조 | `app_structure.md` | 앱 구조와 파일 위치 설명 | 필수 | `feature_catalog.md`, `data_models.md` |
| 환경 설정 | `environment_setup.md` | 개발 환경 설정 방법 | 필수 | - |
| 데이터 모델 | `data_models.md` | 데이터 구조 및 관계 설명 | 필수 | `app_structure.md` |

### 3.2 기능 및 개발 관련 문서

| 문서명 | 경로 | 목적 | 중요도 | 관련 문서 |
|-------|------|------|--------|----------|
| 기능 카탈로그 | `feature_catalog.md` | 모든 기능 목록과 상태 | 필수 | `app_structure.md`, `known_issues.md` |
| API 문서 | `api_documentation.md` | 내부 API 및 외부 서비스 연동 정보 | 권장 | `data_models.md` |
| 개발 가이드라인 | `development_guidelines.md` | 코드 작성 규칙과 개발 표준 | 필수 | `code_quality_guidelines.md` |
| 코드 품질 가이드라인 | `code_quality_guidelines.md` | 코드 품질 관리 및 중복 코드 방지 지침 | 권장 | `development_guidelines.md` |

### 3.3 품질 및 유지보수 관련 문서

| 문서명 | 경로 | 목적 | 중요도 | 관련 문서 |
|-------|------|------|--------|----------|
| 알려진 이슈 | `known_issues.md` | 현재 문제점과 해결 방법 | 필수 | `feature_catalog.md` |
| 테스트 문서 | `testing_documentation.md` | 테스트 전략 및 결과 | 권장 | `development_guidelines.md` |
| 버전 히스토리 | `version_history.md` | 앱 버전별 변경 사항 기록 | 참조 | `known_issues.md` |

### 3.4 사용자 및 관리 관련 문서

| 문서명 | 경로 | 목적 | 중요도 | 관련 문서 |
|-------|------|------|--------|----------|
| 사용자 피드백 | `user_feedback.md` | 사용자 피드백 및 개선 계획 | 참조 | `feature_catalog.md`, `known_issues.md` |
| 문서 업데이트 가이드 | `document_update_guide.md` | 문서 업데이트 지침 | 권장 | `project_documentation_guidelines.md` |

### 3.5 AI 협업 관련 문서

| 문서명 | 경로 | 목적 | 중요도 | 관련 문서 |
|-------|------|------|--------|----------|
| AI 가이드 | `ai_guide.md` | AI와 효과적으로 협업하는 방법 | 필수 | 모든 문서 |
| AI 코드 수정 가이드라인 | `ai_code_modification_guidelines.md` | AI가 코드 수정 시 따라야 할 안전한 리팩토링 지침 | 필수 | `code_quality_guidelines.md`, `development_guidelines.md` |
| AI 컨텍스트 최적화 가이드 | `ai_context_optimization_guide.md` | AI가 프로젝트를 빠르게 이해하기 위한 컨텍스트 | 필수 | `app_structure.md`, `data_models.md` |
| AI 할루시네이션 방지 가이드 | `ai_hallucination_prevention_guide.md` | AI 할루시네이션 감지 및 방지 방법 | 필수 | `ai_guide.md`, `code_quality_guidelines.md` |
| 프로젝트 문서화 가이드라인 | `project_documentation_guidelines.md` | 프로젝트 문서화 표준 및 방법론 | 권장 | `document_update_guide.md` |

## 4. 상황별 참조 가이드

### 4.1 새 기능 개발 시

1. `feature_catalog.md` - 기존 기능 파악
2. `app_structure.md` - 코드 구조 이해
3. `data_models.md` - 데이터 모델 확인
4. `development_guidelines.md` - 개발 표준 준수
5. `code_quality_guidelines.md` - 코드 품질 유지

### 4.2 버그 수정 시

1. `known_issues.md` - 관련 이슈 확인
2. `ai_context_optimization_guide.md` - 코드 구조 빠르게 이해
3. `ai_code_modification_guidelines.md` - 안전한 코드 수정 방법
4. `testing_documentation.md` - 테스트 방법 확인

### 4.3 리팩토링 시

1. `ai_code_modification_guidelines.md` - 안전한 리팩토링 지침
2. `code_quality_guidelines.md` - 코드 품질 기준
3. `app_structure.md` - 전체 구조 이해
4. `ai_context_optimization_guide.md` - 코드 변경 영향 분석
5. `ai_hallucination_prevention_guide.md` - 잘못된 코드 참조 방지

### 4.4 문서화 작업 시

1. `project_documentation_guidelines.md` - 문서화 표준
2. `document_update_guide.md` - 업데이트 프로세스
3. `documentation_index.md` - 문서 간 관계 파악

## 5. 문서 유지보수 지침

1. **정기적 검토**: 모든 문서는 분기별로 검토하여 최신성 유지
2. **변경 시 업데이트**: 코드 변경 시 관련 문서도 함께 업데이트
3. **일관성 유지**: 모든 문서는 이 인덱스에 등록하고 표준 형식 준수
4. **링크 유효성**: 문서 간 상호 참조 링크의 유효성 정기적 확인

## 6. 결론

이 문서 인덱스를 통해 프로젝트의 모든 문서에 체계적으로 접근할 수 있습니다. 문서를 찾거나 참조할 때 항상 이 인덱스를 시작점으로 사용하세요. 새로운 문서가 추가되면 이 인덱스도 함께 업데이트해야 합니다.