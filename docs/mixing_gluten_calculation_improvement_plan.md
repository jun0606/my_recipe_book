# 믹싱 단계별 글루텐 계산 정확도 개선 프로젝트 문서

## 프로젝트 개요

**프로젝트명**: 믹싱 단계별 글루텐 계산 정확도 개선 프로젝트
**목적**: 사용자가 입력한 레시피와 믹싱 방법대로 계산하여 순수한 계산 결과를 제공
**범위**: mixing_analysis_types.dart, mixing_analysis_service.dart, mixing_step_card.dart
**기간**: 2025.09.17 - 2025.09.30 (2주)
**담당**: AI Assistant (MCP 기반)

## 핵심 요구사항

1. **사용자 입력 기반 계산**: 레시피, 각 단계별 믹싱 차수/속도/시간, 환경정보, 믹서절정 사용
2. **순수 계산 값 제공**: 하드코딩과 clamp로 오염된 정보 제공 금지
3. **거짓 정보 방지**: 계산 불가 시 0 리턴
4. **실시간 피드백**: 각 차수별 믹싱 종료 시 글루텐 발달 값 제공

## 현재 문제점 분석

### 1. 하드코딩된 기본값 문제
```dart
// mixing_analysis_types.dart - 문제 지점
DoughState({
  double? glutenFormation,
  // ...
}) : glutenFormation = glutenFormation ?? 0.0, // ❌ 하드코딩
```

### 2. clamp 제한으로 인한 값 왜곡
```dart
// SafeValueUtils에서 clamp 적용으로 실제 값 왜곡
glutenFormation.clamp(0.0, 1.0) // ❌ 실제 빵 제조 값 제한
```

### 3. 누적 계산 로직 문제
```dart
// mixing_analysis_service.dart - 문제 지점
double increment = baseIncrement * combinedFactor;
if (increment > 0.25) increment = 0.25; // ❌ 최대 증가량 제한이 너무 낮음
```

## 구현 계획

### Phase 1: 기초 구조 개선 (1주)
- [ ] 하드코딩된 기본값 제거 및 동적 계산 시스템 구축
- [ ] clamp 제한 제거 및 실제 빵 제조 과학적 범위 적용
- [ ] 사용자 입력 기반 초기값 계산 함수 구현

### Phase 2: 계산 로직 개선 (1주)
- [ ] 단계별 누적 계산 로직 개선
- [ ] 환경정보와 믹서절정 반영 계산 구현
- [ ] 거짓 정보 방지 정책 강화

### Phase 3: UI 및 테스트 (1주)
- [ ] UI 표시 개선 (실제 빵 제조 값 범위 표시)
- [ ] 단위 테스트 및 통합 테스트 구현
- [ ] 사용자 피드백 수집 및 개선

## 파일 구조 및 변경 계획

```
lib/features/chef/screen/widgets/
├── mixing_analysis_types.dart     # ✅ 주요 변경 대상
├── mixing_analysis_service.dart   # ✅ 주요 변경 대상
├── mixing_step_card.dart         # ✅ UI 표시 개선
└── mixing_analysis_utils.dart    # ✅ 헬퍼 함수 추가

lib/services/
├── ingredient_analyzer.dart      # ✅ 재료 분석 개선
├── environment_defaults_calculator.dart # ✅ 환경 계산 개선
└── baking_science_formula_engine.dart  # ✅ 계산 엔진 개선
```

## 주요 변경사항

### 1. DoughState 클래스 개선
```dart
class DoughState {
  // 기존 하드코딩 제거
  // double? glutenFormation = 0.0; // ❌ 제거

  // 동적 계산 적용
  double get glutenFormation => _calculateDynamicGlutenFormation();

  double _calculateDynamicGlutenFormation() {
    // 사용자 입력 기반 동적 계산
    return calculateGlutenFormationFromUserInputs(
      ingredients: ingredients,
      environment: environment,
      mixerType: mixerType,
      recipeData: recipeData,
    );
  }
}
```

### 2. 계산 서비스 개선
```dart
class MixingAnalysisService {
  // 사용자 입력 기반 계산 메소드
  double calculateGlutenFormationFromUserInputs({
    required List<Map<String, dynamic>> ingredients,
    required UserEnvironment environment,
    required String mixerType,
    required Map<String, dynamic> recipeData,
  }) {
    // 1. 재료 기반 기초 계산
    final baseFormation = _calculateBaseFromIngredients(ingredients);

    // 2. 환경 조건 반영
    final environmentFactor = _calculateEnvironmentFactor(environment);

    // 3. 믹서 타입 반영
    final mixerFactor = _calculateMixerFactor(mixerType);

    // 4. 순수 계산 값 반환 (clamp 없음)
    return baseFormation * environmentFactor * mixerFactor;
  }
}
```

### 3. UI 표시 개선
```dart
class MixingStepCard {
  String _getGlutenDisplayText(double glutenValue) {
    if (glutenValue == 0.0) {
      return "계산 불가 (레시피 확인 필요)";
    }

    // 실제 빵 제조 과학적 범위 표시
    if (glutenValue >= 0.6 && glutenValue <= 0.8) {
      return "${(glutenValue * 100).toStringAsFixed(1)}% (최적 범위)";
    } else if (glutenValue >= 0.5 && glutenValue <= 0.9) {
      return "${(glutenValue * 100).toStringAsFixed(1)}% (양호 범위)";
    } else {
      return "${(glutenValue * 100).toStringAsFixed(1)}% (주의 필요)";
    }
  }
}
```

## 테스트 케이스

### 정상 케이스
```dart
void testNormalCase() {
  final result = calculateGlutenFormation({
    'ingredients': [
      {'name': '강력분', 'amount': 500, 'unit': 'g'},
      {'name': '물', 'amount': 300, 'unit': 'g'}
    ],
    'environment': {'temperature': 25, 'humidity': 60},
    'mixerType': 'stand',
    'steps': [
      {'speed': '중속', 'duration': 5},
      {'speed': '고속', 'duration': 3}
    ]
  });

  // 결과: 0.65-0.75 범위 (실제 빵 제조 값)
  expect(result, greaterThan(0.6));
  expect(result, lessThan(0.8));
}
```

### 계산 불가 케이스
```dart
void testCalculationFailure() {
  final result = calculateGlutenFormation({
    'ingredients': [], // 빈 재료
    'environment': {},
    'mixerType': 'unknown'
  });

  // 결과: 0.0 (명확한 계산 불가 표시)
  expect(result, equals(0.0));
}
```

## 성과 측정 지표

1. **정확도 향상**: 실제 빵 제조 값 (60-80%) 범위 내 계산 결과 비율 95% 이상
2. **사용자 만족도**: 계산 결과에 대한 사용자 신뢰도 향상
3. **거짓 정보 방지**: 계산 불가 시 명확한 0 값 표시로 혼란 방지
4. **성능 유지**: 계산 속도 저하 없이 정확도 향상

## 리스크 및 완화 방안

### 리스크 1: 계산 복잡도 증가
- **완화 방안**: 단계별 계산 캐싱 및 최적화
- **모니터링**: 계산 시간 측정 및 임계값 설정

### 리스크 2: 사용자 입력 오류
- **완화 방안**: 입력값 검증 및 사용자 피드백 강화
- **모니터링**: 입력 오류 로그 분석 및 개선

### 리스크 3: 기존 시스템 호환성
- **완화 방안**: 점진적 마이그레이션 및 A/B 테스트
- **모니터링**: 기존 기능 유지 확인

## 개발 일정

### Week 1: 기초 구조 개선
- Day 1-2: 하드코딩된 기본값 제거 및 동적 계산 시스템 구축
- Day 3-4: clamp 제한 제거 및 실제 빵 제조 과학적 범위 적용
- Day 5-7: 사용자 입력 기반 초기값 계산 함수 구현 및 테스트

### Week 2: 계산 로직 개선
- Day 8-10: 단계별 누적 계산 로직 개선
- Day 11-12: 환경정보와 믹서절정 반영 계산 구현
- Day 13-14: 거짓 정보 방지 정책 강화 및 테스트

### Week 3: UI 및 최종 테스트
- Day 15-17: UI 표시 개선 (실제 빵 제조 값 범위 표시)
- Day 18-19: 단위 테스트 및 통합 테스트 구현
- Day 20-21: 사용자 피드백 수집 및 개선

## 검증 및 배포 계획

1. **단위 테스트**: 각 계산 함수별 테스트 케이스 작성
2. **통합 테스트**: 전체 믹싱 분석 플로우 테스트
3. **사용자验收 테스트**: 실제 사용자 시나리오 기반 테스트
4. **성능 테스트**: 계산 속도 및 메모리 사용량 검증
5. **배포**: 점진적 롤아웃 및 모니터링

## 문서화

- [ ] API 문서 업데이트
- [ ] 사용자 가이드 작성
- [ ] 개발자 문서 작성
- [ ] 테스트 케이스 문서화

## 모니터링 및 유지보수

- [ ] 계산 정확도 모니터링 대시보드 구축
- [ ] 사용자 피드백 수집 시스템 구축
- [ ] 정기적인 성능 모니터링
- [ ] 버그 수정 및 개선사항 적용

---

**문서 버전**: 1.0
**작성일**: 2025.09.17
**작성자**: AI Assistant (MCP 기반)
**다음 검토일**: 2025.10.01
