# 베이킹 계산기 고도화 계획

## 개요
베이킹 계산기의 사용성과 기능성을 대폭 향상시키기 위한 상세 개선 계획입니다.

## 1. 계산 모드 순서 커스터마이징

### 1.1 요구사항
- 사용자가 7가지 계산 모드의 순서를 자유롭게 변경 가능
- 설정한 순서가 앱 재시작 후에도 유지
- 드래그 앤 드롭 또는 설정 화면을 통한 순서 변경

### 1.2 구현 계획
- `BakingModePreferencesService` 생성
- SharedPreferences를 통한 순서 저장
- 드래그 가능한 모드 선택기 UI 구현
- 설정 화면에 모드 순서 관리 섹션 추가

### 1.3 파일 구조
```
lib/services/baking_mode_preferences_service.dart
lib/widgets/recipe_detail/baking_calculator/draggable_mode_selector.dart
lib/screens/baking_mode_settings_screen.dart
```

## 2. 실시간 계산 및 UI 갱신

### 2.1 요구사항
- 입력 값 변경 시 즉시 재료 테이블과 계산 결과 카드 갱신
- 디바운싱을 통한 성능 최적화
- 사용자 입력 중 과도한 계산 방지

### 2.2 구현 계획
- `RealTimeCalculationMixin` 구현
- 입력 필드에 디바운싱 적용 (300ms)
- Stream 기반 반응형 계산 시스템
- 계산 상태 표시 (로딩 인디케이터)

### 2.3 기술적 세부사항
```dart
// 디바운싱 예시
Timer? _debounceTimer;
void _onInputChanged(String value) {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(Duration(milliseconds: 300), () {
    _performCalculation();
  });
}
```

## 3. 계산값 초기화 기능

### 3.1 요구사항
- 모든 입력 값을 원본 레시피 상태로 초기화
- 재료 테이블과 계산 결과 카드 즉시 반영
- 초기화 확인 다이얼로그 (선택사항)

### 3.2 구현 계획
- 각 계산 모드별 초기화 메서드 구현
- 전역 초기화 버튼 추가
- 애니메이션 효과로 초기화 과정 시각화

### 3.3 UI 배치
- 계산 결과 카드 우상단에 초기화 버튼
- 아이콘: `Icons.refresh` 또는 `Icons.restore`

## 4. 반올림 기능 온/오프

### 4.1 요구사항
- 각 계산기마다 반올림 기능 토글 가능
- 설정이 모든 계산 모드에 공통 적용
- 실시간 반영 (토글 즉시 재계산)

### 4.2 구현 계획
- `RoundingPreferencesService` 구현
- 반올림 설정 UI 컴포넌트 추가
- 소수점 자릿수 설정 옵션 (1-3자리)

### 4.3 반올림 옵션
- 소수점 1자리 (기본)
- 소수점 2자리
- 소수점 3자리
- 정수 (소수점 없음)

## 5. 재료 테이블 정보 개선

### 5.1 현재 문제점
- 분할된 1개의 무게만 표시
- 사용자가 원하는 총 필요 무게 정보 부족

### 5.2 개선 방안
- **기본 표시**: 총 필요 무게 (전체 레시피 기준)
- **추가 정보**: 분할된 1개당 무게 (괄호 안에 표시)
- **토글 옵션**: 표시 방식 전환 가능

### 5.3 표시 예시
```
밀가루: 500g (1개당: 62.5g)
설탕: 200g (1개당: 25g)
```

### 5.4 구현 계획
- `IngredientDisplayMode` enum 추가
- 재료 카드 UI 개선
- 표시 모드 토글 버튼 추가

## 6. 계산 모드 최적화

### 6.1 목표 수량 계산기 제거
- 동적 비교 계산기가 동일 기능 제공
- UI 복잡성 감소
- 사용자 혼란 방지

### 6.2 최종 계산 모드 (6가지)
1. 배율 조정 (Scale Adjustment)
2. 분할 수량 (Split by Count)
3. 분할 무게 (Split by Weight)
4. 배율+분할 (Scale and Split)
5. 동적 비교 (Dynamic Comparison)
6. 최적 분할 (Optimal Split)

## 7. 계산 갱신 검증 및 수정

### 7.1 검증 항목
- [ ] 배율 조정: 입력 즉시 갱신
- [ ] 분할 수량: 입력 즉시 갱신
- [ ] 분할 무게: 입력 즉시 갱신
- [ ] 배율+분할: 두 입력 모두 즉시 갱신
- [ ] 동적 비교: 입력 즉시 갱신
- [ ] 최적 분할: 입력 즉시 갱신

### 7.2 수정 계획
- 각 입력 위젯의 `onChanged` 콜백 검증
- Provider 알림 메커니즘 점검
- 계산 로직 디버깅

## 8. 계산 결과 카드 정보 완성

### 8.1 현재 문제점
- 변경사항이 없을 때 정보 누락
- 사용자가 변화 정도를 파악하기 어려움

### 8.2 개선 방안
- **모든 정보 항상 표시**
- **색상 코딩 시스템**:
  - 🖤 검정: 변화 없음 (원본과 동일)
  - 🟢 초록: 증가 (원본보다 많음)
  - 🔴 빨강: 감소 (원본보다 적음)

### 8.3 표시 정보
- 총 무게 (색상 코딩)
- 분할 무게 (색상 코딩)
- 분할 수량 (색상 코딩)
- 배율 (색상 코딩)
- 남은 재료 (있는 경우)
- 최적화 여부

### 8.4 구현 예시
```dart
Widget _buildResultRow(String label, String value, double? originalValue, double currentValue) {
  Color textColor = Colors.black;
  if (originalValue != null) {
    if (currentValue > originalValue) {
      textColor = Colors.green;
    } else if (currentValue < originalValue) {
      textColor = Colors.red;
    }
  }
  
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label),
      Text(value, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
    ],
  );
}
```

## 구현 우선순위

### Phase 1 (1주차)
1. 실시간 계산 및 UI 갱신 구현
2. 계산값 초기화 기능 추가
3. 계산 갱신 검증 및 수정

### Phase 2 (2주차)
4. 반올림 기능 온/오프 구현
5. 재료 테이블 정보 개선
6. 계산 결과 카드 정보 완성

### Phase 3 (3주차)
7. 계산 모드 순서 커스터마이징
8. 목표 수량 계산기 제거 및 UI 정리

## 기술적 고려사항

### 성능 최적화
- 디바운싱을 통한 과도한 계산 방지
- 메모이제이션을 통한 중복 계산 방지
- 가상화를 통한 대량 재료 목록 처리

### 사용자 경험
- 로딩 상태 표시
- 부드러운 애니메이션 전환
- 접근성 고려 (스크린 리더, 키보드 네비게이션)

### 데이터 지속성
- SharedPreferences를 통한 사용자 설정 저장
- 앱 재시작 시 설정 복원
- 설정 백업 및 복원 기능

## 테스트 계획

### 단위 테스트
- 각 계산 전략별 테스트
- 반올림 로직 테스트
- 실시간 갱신 로직 테스트

### 통합 테스트
- 사용자 시나리오 기반 테스트
- 성능 테스트 (대량 데이터)
- 접근성 테스트

### 사용자 테스트
- 베타 테스터를 통한 사용성 검증
- 피드백 수집 및 개선사항 도출