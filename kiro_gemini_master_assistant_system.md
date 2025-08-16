# 🤖 Kiro-Gemini CLI 마스터-어시스턴트 시스템

## 🎯 시스템 개념

### 역할 분담
- **Kiro (마스터)**: 전략적 계획, 아키텍처 설계, 최종 검증
- **Gemini CLI (어시스턴트)**: 단순 반복 작업, 코드 테스트, 실행 작업

### 작업 흐름
```
Kiro 계획 수립 → Gemini CLI 실행 → Kiro 검증 → 결과 승인/수정
```

## 🔧 구현 방법

### 1. 명령 전달 시스템
```bash
# Kiro가 Gemini CLI에게 작업 지시
echo "TASK: run_flutter_tests" > .kiro/tasks/current_task.json
echo "FILES: test/providers/baking_calculation_provider_test.dart" >> .kiro/tasks/current_task.json
echo "EXPECTED: all_tests_pass" >> .kiro/tasks/current_task.json
```

### 2. 결과 보고 시스템
```bash
# Gemini CLI가 Kiro에게 결과 보고
echo "STATUS: completed" > .kiro/results/task_result.json
echo "SUCCESS_RATE: 73%" >> .kiro/results/task_result.json
echo "FAILED_TESTS: 19" >> .kiro/results/task_result.json
echo "LOG_FILE: .kiro/logs/test_execution.log" >> .kiro/results/task_result.json
```

## 🚀 자동화 가능한 작업들

### A급 (완전 자동화)
- **단위 테스트 실행**: `flutter test`
- **코드 포맷팅**: `dart format`
- **정적 분석**: `flutter analyze`
- **의존성 업데이트**: `flutter pub get`
- **빌드 테스트**: `flutter build apk --debug`

### B급 (반자동화 - 검증 필요)
- **코드 리팩토링**: 패턴 기반 수정
- **테스트 코드 생성**: 기존 패턴 복제
- **문서 업데이트**: 코드 변경사항 반영
- **성능 측정**: 벤치마크 실행

### C급 (Kiro 직접 처리)
- **아키텍처 설계**: 전략적 판단 필요
- **복잡한 버그 수정**: 창의적 문제 해결
- **사용자 요구사항 분석**: 비즈니스 로직 이해
- **최종 코드 리뷰**: 품질 보증

## 📋 실제 사용 시나리오

### 시나리오 1: Flutter 테스트 자동화
```bash
# Kiro 지시
"Gemini CLI야, 베이킹 계산기 관련 모든 테스트를 실행하고 결과를 정리해줘"

# Gemini CLI 실행
1. flutter test test/providers/baking_calculation_provider_test.dart
2. flutter test test/models/baking_calculation_models_test.dart  
3. flutter test test/widgets/baking_calculator_test.dart
4. 결과 취합 및 보고서 생성

# Kiro 검증
- 실패한 테스트 분석
- 수정 방향 결정
- 다음 작업 지시
```

### 시나리오 2: 코드 품질 검사
```bash
# Kiro 지시
"전체 프로젝트 코드 품질을 검사하고 개선점을 찾아줘"

# Gemini CLI 실행
1. flutter analyze
2. dart format --set-exit-if-changed .
3. 코드 복잡도 분석
4. 중복 코드 탐지
5. 개선 제안 생성

# Kiro 검증
- 제안사항 우선순위 결정
- 수정 계획 수립
- 실행 지시
```

## 🔄 통신 프로토콜

### 작업 지시 형식
```json
{
  "task_id": "kiro_task_001",
  "timestamp": "2025-07-25T05:30:00Z",
  "priority": "HIGH",
  "type": "TEST_EXECUTION",
  "description": "Run all baking calculator tests",
  "files": [
    "test/providers/baking_calculation_provider_test.dart",
    "test/models/baking_calculation_models_test.dart",
    "test/widgets/baking_calculator_test.dart"
  ],
  "expected_outcome": "all_tests_pass",
  "timeout": "10min",
  "retry_count": 3
}
```

### 결과 보고 형식
```json
{
  "task_id": "kiro_task_001",
  "completion_time": "2025-07-25T05:35:00Z",
  "status": "COMPLETED",
  "success_rate": 0.73,
  "results": {
    "total_tests": 71,
    "passed_tests": 52,
    "failed_tests": 19,
    "execution_time": "4min 32sec"
  },
  "logs": ".kiro/logs/test_execution_001.log",
  "recommendations": [
    "Fix UI element finding issues in widget tests",
    "Update BakingService mock implementations",
    "Add missing test cases for edge conditions"
  ],
  "next_actions": [
    "manual_review_required",
    "fix_failing_tests",
    "update_test_documentation"
  ]
}
```

## 🛠️ 구현 단계

### Phase 1: 기본 통신 시스템
1. 파일 기반 작업 큐 구현
2. 기본 명령 실행 스크립트
3. 결과 파싱 및 보고 시스템

### Phase 2: 자동화 작업 확장
1. Flutter 테스트 자동화
2. 코드 품질 검사 자동화
3. 빌드 및 배포 자동화

### Phase 3: 지능형 어시스턴트
1. 작업 패턴 학습
2. 예측적 작업 제안
3. 자동 오류 복구

## 💡 기대 효과

### 즉시 효과
- **작업 속도 5배 향상**: 병렬 처리로 동시 작업
- **실수 감소 90%**: 자동화로 인적 오류 제거
- **일관성 보장**: 표준화된 프로세스 적용

### 장기 효과
- **Kiro 전문성 집중**: 고급 작업에만 집중
- **학습 효과**: 반복 작업 패턴 최적화
- **확장성**: 새로운 자동화 작업 쉽게 추가

## ⚠️ 주의사항

### 보안 및 안전성
- 중요한 파일 수정은 Kiro 승인 필요
- 자동 커밋 금지 (검토 후 수동 커밋)
- 실행 권한 제한 (읽기 전용 작업 우선)

### 품질 보증
- 모든 결과는 Kiro 검증 필수
- 실패 시 자동 롤백 메커니즘
- 작업 로그 완전 기록

## 🎯 시작 방법

1. **기본 스크립트 작성**: 파일 기반 통신 시스템
2. **테스트 자동화**: Flutter 테스트 실행 자동화
3. **점진적 확장**: 성공한 작업부터 단계적 확장

이 시스템을 구현하면 Kiro는 전략적 사고에 집중하고, Gemini CLI는 실행 작업을 담당하는 효율적인 AI 협업 환경이 완성됩니다!