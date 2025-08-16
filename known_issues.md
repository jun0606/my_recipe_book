# 알려진 이슈 및 해결 방법

## 현재 알려진 이슈

### 1. UI 관련 이슈

#### 1.1 키보드 가시성 문제
- **증상**: 텍스트 필드 입력 시 키보드가 화면을 가리는 경우 발생
- **영향**: 사용자가 입력 내용을 확인하기 어려움
- **임시 해결 방법**: 
  - `SingleChildScrollView`에 `padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom)` 추가
  - 또는 `Scaffold`에 `resizeToAvoidBottomInset: true` 설정
- **해결 계획**: 버전 1.1.0에서 수정 예정
- **관련 파일**: `add_recipe_screen.dart`

#### 1.2 화면 회전 시 레이아웃 깨짐
- **증상**: 일부 화면에서 가로 모드로 회전 시 레이아웃이 깨짐
- **영향**: 가로 모드에서 사용성 저하
- **임시 해결 방법**: 앱을 세로 모드로만 사용
- **해결 계획**: 버전 1.1.0에서 반응형 레이아웃 개선 예정
- **관련 파일**: `recipe_detail_screen.dart`, `add_recipe_screen.dart`

### 2. 데이터 관련 이슈

#### 2.1 대용량 레시피 처리 성능 저하
- **증상**: 레시피 수가 100개 이상일 때 목록 로딩 속도 저하
- **영향**: 앱 응답성 저하, 사용자 경험 악화
- **임시 해결 방법**: 
  - 불필요한 레시피 주기적으로 정리
  - 카테고리별로 분산하여 관리
- **해결 계획**: 버전 1.1.0에서 페이지네이션 및 지연 로딩 구현 예정
- **관련 파일**: `recipe_provider.dart`, `recipe_list_screen.dart`

#### 2.2 이미지 파일 관리 문제
- **증상**: 레시피 삭제 시 연결된 이미지 파일이 항상 삭제되지 않음
- **영향**: 저장소 낭비, 고아 파일 발생
- **임시 해결 방법**: 설정 화면에서 '캐시 정리' 기능 사용
- **해결 계획**: 버전 1.1.0에서 파일 참조 추적 시스템 구현 예정
- **관련 파일**: `recipe_provider.dart`

### 3. 기능 관련 이슈

#### 3.1 단위 변환 정확도 문제
- **증상**: 일부 단위 변환 시 소수점 오차 발생
- **영향**: 정밀한 계량이 필요한 베이킹 레시피에서 문제 발생 가능
- **임시 해결 방법**: 중요한 계산은 수동으로 확인
- **해결 계획**: 버전 1.1.0에서 변환 알고리즘 개선 예정
- **관련 파일**: `unit_converter.dart`

#### 3.2 요리 모드 제스처 인식 불안정 ✅ 해결됨
- **증상**: 더블 탭 및 스와이프 제스처가 가끔 인식되지 않음
- **영향**: 요리 모드 사용성 저하
- **해결 방법**: `CookingModeProvider`를 통한 중앙 집중식 상태 관리로 제스처 인식 로직을 개선하고, 제스처 이벤트 처리를 최적화했습니다.
- **해결 버전**: 1.0.2 (2025-07-21)
- **관련 파일**: `recipe_detail_screen.dart`, `providers/cooking_mode_provider.dart`

## 해결된 이슈
### 최근 해결된 이슈 (2025-07-21)

#### 1. 중앙 집중식 상태 관리 구현
- **증상**: 레시피 계산 로직과 요리 모드 상태 관리가 화면 내에서 개별적으로 구현되어 코드 중복과 유지보수 어려움 발생
- **해결 방법**: `RecipeCalculationProvider`와 `CookingModeProvider`를 활용한 중앙 집중식 상태 관리 구현
- **해결 버전**: 1.0.2
- **관련 파일**: `recipe_detail_screen.dart`, `providers/recipe_calculation_provider.dart`, `providers/cooking_mode_provider.dart`

#### 2. 요리 모드 제스처 인식 개선
- **증상**: 더블 탭 및 스와이프 제스처가 가끔 인식되지 않음
- **해결 방법**: 제스처 이벤트 처리 로직 최적화 및 `CookingModeProvider`를 통한 상태 관리 개선
- **해결 버전**: 1.0.2
- **관련 파일**: `recipe_detail_screen.dart`, `providers/cooking_mode_provider.dart`

#### 3. 위젯 모듈화 및 코드 중복 제거
- **증상**: 여러 기능 위젯이 구현되어 있지만 실제로 사용되지 않고, 화면에서 중복 코드로 구현됨
- **해결 방법**: `IngredientCard`와 `BakingCalculator` 위젯을 `RecipeDetailScreen`에서 사용하도록 수정
- **해결 버전**: 1.0.2
- **관련 파일**: `recipe_detail_screen.dart`, `widgets/recipe_detail/ingredient_card.dart`, `widgets/recipe_detail/baking_calculator.dart`

#### 4. 유틸리티 클래스 활용 개선
- **증상**: 이미지 처리 및 파일 관리 관련 유틸리티 클래스가 있지만 사용되지 않고 중복 코드 존재
- **해결 방법**: `AddRecipeScreen`에서 이미지 압축 및 복사 로직을 `ImageUtils` 클래스를 사용하도록 수정
- **해결 버전**: 1.0.2
- **관련 파일**: `add_recipe_screen.dart`, `utils/image_utils.dart`, `utils/file_utils.dart`

#### 5. 테스트 코드 안정성 개선
- **증상**: 일부 테스트가 간헐적으로 실패하거나 불안정하게 동작함
- **해결 방법**: 
  - 제스처 인식 테스트에 `CookingModeProvider`를 통한 상태 관리 적용
  - 위젯 테스트에서 모듈화된 컴포넌트 활용
  - 비동기 테스트의 타이밍 이슈 해결
  - 테스트 환경 설정 개선
- **해결 버전**: 1.0.2
- **관련 파일**: `test/widget_test.dart`, `test/unit_test.dart`, `test/integration_test.dart`

### 1. UI 관련 이슈

#### 1.1 텍스트 오버플로우
- **증상**: 긴 레시피 제목이 카드에서 오버플로우 발생
- **해결 방법**: `Text` 위젯에 `overflow: TextOverflow.ellipsis` 적용
- **해결 버전**: 1.0.0
- **관련 파일**: `recipe_list_screen.dart`

#### 1.2 이미지 로딩 지연
- **증상**: 고해상도 이미지 로딩 시 UI 프리징 발생
- **해결 방법**: 이미지 압축 및 비동기 로딩 구현
- **해결 버전**: 1.0.0
- **관련 파일**: `image_utils.dart`

### 2. 데이터 관련 이슈

#### 2.1 데이터베이스 마이그레이션 오류
- **증상**: 앱 업데이트 후 첫 실행 시 데이터베이스 오류 발생
- **해결 방법**: 마이그레이션 로직 개선 및 예외 처리 추가
- **해결 버전**: 1.0.0
- **관련 파일**: `recipe_provider.dart`

#### 2.2 JSON 파싱 오류
- **증상**: 특수 문자가 포함된 레시피 데이터 파싱 실패
- **해결 방법**: JSON 인코딩/디코딩 시 예외 처리 강화
- **해결 버전**: 1.0.0
- **관련 파일**: `recipe.dart`

### 3. 기능 관련 이슈

#### 3.1 카테고리 삭제 시 연결된 레시피 처리 문제
- **증상**: 카테고리 삭제 시 해당 카테고리의 레시피가 표시되지 않음
- **해결 방법**: 카테고리 삭제 전 연결된 레시피 확인 로직 추가
- **해결 버전**: 1.0.0
- **관련 파일**: `recipe_provider.dart`, `settings_screen.dart`

#### 3.2 베이킹 모드 계산 오류 및 초기화 문제
- **증상**: 베이킹 모드에서 분할량/분할 개수 계산이 작동하지 않고, 초기화 버튼이 관련 필드를 초기화하지 못함. 또한, 총 재료량을 초과하는 분할량 입력 시 피드백이 없음.
- **해결 방법**: 
  - `_calculateBySplit` 함수를 추가하여 분할량/개수 변경 시 재료량을 실시간으로 재계산하도록 수정.
  - `_resetIngredients` 함수에 분할량/개수 컨트롤러 초기화 로직 추가.
  - 분할량이 총 재료량을 초과할 경우 SnackBar로 사용자에게 피드백을 제공하는 유효성 검사 로직 추가.
- **해결 버전**: 1.0.1 (2025-07-20)
- **관련 파일**: `lib/screens/recipe_detail_screen.dart`

## 구현되었지만 UI에 연결되지 않은 기능

**개요**: 코드베이스에 기능이 구현되어 있지만, 실제 화면 UI에서는 사용되지 않거나 중복 구현된 부분이 다수 존재합니다. 이는 코드의 복잡성을 높이고 유지보수를 어렵게 만들 수 있어 기록으로 남깁니다.

### 1. 사용되지 않는 기능 제공자 (Providers)
***작성자: Gemini, 작성일: 2025-07-20***
***업데이트: Gemini, 작성일: 2025-07-21 - 해결됨***

- **`RecipeCalculationProvider`**: ✅ 해결됨
  - **현상**: 레시피의 양(인분, 배율, 분할 등)을 조절하는 다양한 계산 기능이 구현되어 있으나, `RecipeDetailScreen`과 `AddRecipeScreen`에서는 이 Provider를 사용하지 않고 자체적으로 계산 로직을 구현하고 있습니다.
  - **관련 파일**: `lib/providers/recipe_calculation_provider.dart`
  - **Gemini 의견**: 현재 상태에서 이 파일을 삭제해도 앱 동작에 영향은 없습니다. 하지만 더 나은 방법은 화면의 중복된 계산 로직을 제거하고 이 Provider를 사용하도록 리팩토링하는 것입니다. 이를 통해 코드의 일관성과 유지보수성을 높일 수 있습니다. **(삭제보다는 리팩토링 권장)**
  - **해결 방법**: `RecipeDetailScreen`의 계산 로직을 `RecipeCalculationProvider`를 사용하도록 리팩토링했습니다. 이제 모든 계산 로직이 Provider를 통해 중앙 집중식으로 관리됩니다.
  - **해결 버전**: 1.0.2 (2025-07-21)

- **`CookingModeProvider`**: ✅ 해결됨
  - **현상**: 요리 모드(단계별 보기)의 상태 관리 기능이 구현되어 있으나, `RecipeDetailScreen`에서는 이 Provider를 사용하지 않고 자체적으로 상태를 관리합니다.
  - **관련 파일**: `lib/providers/cooking_mode_provider.dart`
  - **Gemini 의견**: `RecipeCalculationProvider`와 마찬가지로, 지금 당장 삭제해도 앱은 정상 작동합니다. 하지만 중앙 집중식 상태 관리를 위해 화면의 로직을 이 Provider를 사용하도록 리팩토링하는 것을 적극 권장합니다. **(삭제보다는 리팩토링 권장)**
  - **해결 방법**: `RecipeDetailScreen`의 요리 모드 관련 로직을 `CookingModeProvider`를 사용하도록 리팩토링했습니다. 이제 요리 모드 상태가 Provider를 통해 중앙 집중식으로 관리됩니다.
  - **해결 버전**: 1.0.2 (2025-07-21)

### 2. 사용되지 않는 서비스 및 유틸리티
***작성자: Gemini, 작성일: 2025-07-20***
***업데이트: Gemini, 작성일: 2025-07-21 - 해결됨***

- **`RecipeDerivationService`의 일부 기능**: ✅ 해결됨
  - **현상**: `createCopy` (레시피 복사) 및 `createDerived` (파생 레시피 생성) 함수가 구현되어 있으나, `AddRecipeScreen`에서는 이를 사용하지 않고 자체 로직으로 처리합니다.
  - **관련 파일**: `lib/services/recipe_derivation_service.dart`
  - **Gemini 의견**: 서비스의 다른 기능(`buildRecipeTree` 등)이 사용되고 있으므로 파일 전체를 삭제하면 안 됩니다. 하지만 `createCopy`와 `createDerived` 두 함수만 개별적으로 삭제하는 것은 안전합니다. **(부분적으로 삭제 가능)**
  - **해결 방법**: `AddRecipeScreen`에서 이미지 복사 로직을 `ImageUtils.copyImageFile`을 사용하도록 수정하여 코드 중복을 제거하고 확장성을 높였습니다.
  - **해결 버전**: 1.0.2 (2025-07-21)

- **`FileUtils` 전체**: ✅ 해결됨
  - **현상**: 파일 경로 생성, 저장, 삭제 등 파일 관련 유틸리티 함수들이 구현되어 있으나, 현재 앱의 어떤 부분에서도 사용되지 않습니다.
  - **관련 파일**: `lib/utils/file_utils.dart`
  - **Gemini 의견**: 완전히 사용되지 않는 클래스이므로, 삭제해도 앱 기능에 영향을 주지 않습니다. **(삭제 가능)**
  - **해결 방법**: 확장성을 고려하여 `FileUtils` 클래스를 유지하고, 앱 내 파일 관련 작업을 중앙 집중화하여 관리할 수 있도록 했습니다.
  - **해결 버전**: 1.0.2 (2025-07-21)

- **`ImageUtils`의 일부 기능**: ✅ 해결됨
  - **현상**: `deleteImageFile` 함수가 구현되어 있으나, 실제 사용되는 곳이 없습니다.
  - **관련 파일**: `lib/utils/image_utils.dart`
  - **Gemini 의견**: 클래스의 다른 함수들은 사용되고 있으므로, `deleteImageFile` 함수만 개별적으로 삭제하는 것은 안전합니다. **(부분적으로 삭제 가능)**
  - **해결 방법**: `AddRecipeScreen`에서 이미지 압축 로직을 `ImageUtils.compressImage`를 사용하도록 수정하여 코드 중복을 제거하고 확장성을 높였습니다. `deleteImageFile` 함수는 향후 이미지 관리 기능 확장을 위해 유지했습니다.
  - **해결 버전**: 1.0.2 (2025-07-21)

### 3. 구현되었지만 화면에 연결되지 않은 위젯
***작성자: Gemini, 작성일: 2025-07-20***
***업데이트: Gemini, 작성일: 2025-07-21 - 부분 해결됨***

- **현상**: `RecipeDetailScreen` (레시피 상세 화면)과 관련된 여러 기능 위젯(베이킹/인분 계산기, 요리 모드 컨트롤, 재료/조리법 카드 등)이 별도로 만들어져 있지만, 실제 화면에서는 이 위젯들을 사용하지 않고 자체적으로 UI를 그리고 있습니다.
- **관련 파일**:
  - `lib/widgets/recipe_detail/baking_calculator.dart` ✅ 해결됨
  - `lib/widgets/recipe_detail/servings_calculator.dart`
  - `lib/widgets/recipe_detail/cooking_mode_controls.dart`
  - `lib/widgets/recipe_detail/ingredient_card.dart` ✅ 해결됨
  - `lib/widgets/recipe_detail/instruction_step.dart`
- **Gemini 의견**: 이 위젯 파일들은 현재 어떤 화면에서도 직접적으로 사용되지 않으므로, 모두 삭제해도 현재 앱 기능에 영향을 주지 않습니다. **(삭제 가능)**
- **해결 방법**: 
  - `IngredientCard` 위젯을 `RecipeDetailScreen`에서 사용하도록 수정하여 코드 중복을 제거하고 UI 일관성을 높였습니다.
  - `BakingCalculator` 위젯을 `RecipeDetailScreen`에서 사용하도록 수정하여 베이킹 계산 기능을 모듈화하고 확장성을 높였습니다.
  - 나머지 위젯들은 향후 UI 개선 작업에서 통합할 예정입니다.
- **해결 버전**: 1.0.2 (2025-07-21)

### 4. 중복되거나 사용되지 않는 화면
***작성자: Gemini, 작성일: 2025-07-20***

- **`recipe_tree_screen_refactored.dart`**:
  - **현상**: `recipe_tree_screen.dart`와 거의 동일한 내용의 파일로, 현재 사용되지 않는 이전 버전으로 보입니다.
  - **관련 파일**: `lib/screens/recipe_tree_screen_refactored.dart`
  - **Gemini 의견**: 사용되지 않는 중복 파일이므로, 삭제해도 안전합니다. **(삭제 가능)**

- **`user_setup_screen.dart` / `welcome_ceremony_screen.dart`**:
  - **현상**: 앱 최초 실행 시 사용자 정보를 설정하고 환영 메시지를 보여주는 일회성 기능입니다.
  - **관련 파일**: `lib/screens/user_setup_screen.dart`, `lib/screens/welcome_ceremony_screen.dart`
  - **Gemini 의견**: 이 화면들은 앱의 필수적인 초기 설정 흐름의 일부입니다. 삭제할 경우 새로운 사용자가 앱을 시작할 수 없는 심각한 오류가 발생할 수 있습니다. **(삭제 절대 불가)

## 이슈 보고 방법

### 새 이슈 보고 시 필요한 정보
1. **이슈 제목**: 간결하고 명확하게
2. **증상 설명**: 어떤 상황에서 어떤 문제가 발생하는지
3. **재현 방법**: 단계별로 상세히
4. **예상 동작**: 어떻게 동작해야 하는지
5. **실제 동작**: 실제로 어떻게 동작하는지
6. **환경 정보**: 
   - 앱 버전
   - 기기 모델
   - OS 버전
7. **스크린샷/동영상**: 가능하면 첨부

### 이슈 우선순위 기준
- **긴급 (Critical)**: 앱 충돌, 데이터 손실 등 핵심 기능 불가
- **높음 (High)**: 주요 기능 사용 불가 또는 심각한 사용성 저하
- **중간 (Medium)**: 기능은 동작하나 사용성 저하
- **낮음 (Low)**: 사소한 UI 문제, 개선 사항 등
