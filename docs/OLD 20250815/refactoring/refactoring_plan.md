# 리팩토링 계획

## 목표
- 코드 중복 제거 및 유지보수성 향상
- 확장성 강화 (레시피 히스토리, 다국어 지원)
- 기존 기능 및 UI 유지
- 테스트 가능성 향상

## 1단계: 서비스 계층 구현

### 1.1. 데이터 접근 서비스 구현
- `lib/services/database_service.dart` - 데이터베이스 작업 전담
- `lib/services/storage_service.dart` - 파일 시스템 작업 전담
- `lib/services/preferences_service.dart` - 사용자 설정 관리

### 1.2. 비즈니스 로직 서비스 구현
- `lib/services/recipe_service.dart` - 레시피 CRUD 및 비즈니스 로직
- `lib/services/history_service.dart` - 히스토리 관리 및 복원 로직
- `lib/services/baking_service.dart` - 베이킹 관련 계산 및 비즈니스 로직
- `lib/services/export_import_service.dart` - 데이터 내보내기/가져오기 로직
- `lib/services/localization_service.dart` - 국제화 및 지역화 로직

## 2단계: 베이킹 계산기 리팩토링

### 2.1. 계산 로직 분리
- `lib/services/calculation/calculation_strategy.dart` - 계산 전략 인터페이스
- `lib/services/calculation/scale_adjustment_strategy.dart` - 배율 조정 전략
- `lib/services/calculation/split_by_count_strategy.dart` - 분할 수량 전략
- `lib/services/calculation/split_by_weight_strategy.dart` - 분할 무게 전략
- `lib/services/calculation/scale_and_split_strategy.dart` - 배율+분할 전략
- `lib/services/calculation/dynamic_comparison_strategy.dart` - 동적 비교 전략
- `lib/services/calculation/optimal_split_strategy.dart` - 최적 분할 전략
- `lib/services/calculation/target_count_strategy.dart` - 목표 수량 전략

### 2.2. UI 컴포넌트 모듈화
- `lib/widgets/recipe_detail/baking_calculator/` - 베이킹 계산기 위젯 디렉토리
  - `baking_calculator.dart` - 메인 위젯
  - `mode_selector.dart` - 계산 모드 선택 위젯
  - `input_section.dart` - 입력 섹션 위젯
  - `result_section.dart` - 결과 섹션 위젯
  - `ingredient_list.dart` - 재료 목록 위젯
  - `input/` - 각 모드별 입력 위젯
    - `scale_input.dart`
    - `split_count_input.dart`
    - `split_weight_input.dart`
    - `scale_and_split_input.dart`
    - `dynamic_comparison_input.dart`
    - `optimal_split_input.dart`
    - `target_count_input.dart`

## 3단계: 레시피 히스토리 기능 구현

### 3.1. 데이터 모델 확장
- `lib/models/history.dart` - 히스토리 모델 확장
- `lib/models/history_entry.dart` - 히스토리 항목 모델
- `lib/models/history_change.dart` - 변경 사항 모델

### 3.2. 히스토리 UI 구현
- `lib/widgets/recipe_detail/history/` - 히스토리 위젯 디렉토리
  - `history_tab.dart` - 히스토리 탭 위젯
  - `history_list.dart` - 히스토리 목록 위젯
  - `history_entry_card.dart` - 히스토리 항목 카드 위젯
  - `change_details.dart` - 변경 사항 상세 위젯
  - `restore_dialog.dart` - 복원 확인 대화상자

### 3.3. 히스토리 통합
- `lib/screens/recipe_detail_screen.dart` - 히스토리 탭 추가
- `lib/providers/recipe_provider.dart` - 히스토리 관련 메서드 분리

## 4단계: 국제화 시스템 강화

### 4.1. 언어 리소스 확장
- `lib/l10n/` - 언어 리소스 파일 확장
  - 모든 하드코딩된 문자열 추출
  - 베이킹 계산기 관련 문자열 추가
  - 히스토리 관련 문자열 추가

### 4.2. 언어 전환 UI 개선
- `lib/widgets/common/language_selector.dart` - 언어 선택 위젯
- 모든 화면에 언어 선택 옵션 추가

## 5단계: RecipeProvider 리팩토링

### 5.1. 점진적 분리
- RecipeProvider에서 서비스로 기능 이동
- 하위 호환성 유지를 위한 위임 패턴 적용

### 5.2. 의존성 주입 구현
- `lib/di/service_locator.dart` - 서비스 로케이터 구현
- Provider 등록 및 의존성 관리

## 6단계: 테스트 자동화

### 6.1. 단위 테스트
- `test/services/` - 서비스 테스트
- `test/models/` - 모델 테스트
- `test/providers/` - 프로바이더 테스트

### 6.2. 위젯 테스트
- `test/widgets/` - 위젯 테스트
- `test/screens/` - 화면 테스트

### 6.3. 통합 테스트
- `integration_test/` - 통합 테스트
- 주요 사용자 시나리오 테스트

## 구현 일정
1. 서비스 계층 구현: 1-2주
2. 베이킹 계산기 리팩토링: 2-3주
3. 레시피 히스토리 기능 구현: 1-2주
4. 국제화 시스템 강화: 1주
5. RecipeProvider 리팩토링: 1주
6. 테스트 자동화: 1-2주

총 예상 기간: 7-11주