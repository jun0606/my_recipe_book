# 기능 유실 방지를 위한 상세 리팩토링 계획

## 1. 위젯 분리 (UI 컴포넌트화)

### RecipeDetailScreen 분리
- `widgets/recipe_detail/ingredient_card.dart`: 재료 카드 위젯
  - 원본 vs 계산된 재료량 비교 표시 기능 유지
  - 하이라이트 효과 유지
- `widgets/recipe_detail/instruction_step.dart`: 조리법 단계 위젯
  - 이미지 표시 기능 유지
  - 하이라이트 효과 유지
- `widgets/recipe_detail/cooking_mode_controls.dart`: 요리 모드 컨트롤 위젯
  - 시작/종료/재시작 버튼 기능 유지
- `widgets/recipe_detail/baking_calculator.dart`: 베이킹 계산기 위젯
  - 분할량/분할 개수 계산 기능 유지
  - 원본 분할 무게 유지 옵션 기능 유지
- `widgets/recipe_detail/servings_calculator.dart`: 인분 계산기 위젯
  - 인분 수 조정 기능 유지

### AddRecipeScreen 분리
- `widgets/add_recipe/ingredient_form.dart`: 재료 입력 폼 위젯
  - 재료 추가/수정/삭제 기능 유지
  - 단위 선택 기능 유지
- `widgets/add_recipe/instruction_form.dart`: 조리법 입력 폼 위젯
  - 조리법 단계 추가/수정/삭제 기능 유지
  - 이미지 추가 기능 유지
- `widgets/add_recipe/image_picker_widget.dart`: 이미지 선택 위젯
  - 카메라/갤러리 선택 기능 유지
  - 이미지 압축 기능 유지
- `widgets/add_recipe/baking_options.dart`: 베이킹 옵션 위젯
  - 분할량/분할 개수 입력 기능 유지
  - 단위 변환 기능 유지

## 2. 서비스 클래스 분리 (비즈니스 로직)

### 계산 로직 분리
- `services/recipe_calculation_service.dart`: 레시피 계산 서비스
  - 인분 수 조정 계산 로직
  - 배율 조정 계산 로직
  - 분할량/분할 개수 계산 로직
  - 총 재료 무게 계산 로직

### 이미지 처리 로직 분리
- `services/image_service.dart`: 이미지 서비스
  - 이미지 압축 로직
  - 이미지 저장 로직
  - 이미지 복사 로직

### 데이터 처리 로직 분리
- `services/recipe_export_service.dart`: 레시피 내보내기 서비스
  - Excel 내보내기 로직
  - 백업 생성 로직
- `services/recipe_import_service.dart`: 레시피 가져오기 서비스
  - 백업 복원 로직

## 3. 상태 관리 개선

### Provider 분리
- `providers/cooking_mode_provider.dart`: 요리 모드 상태 관리
  - 요리 모드 상태 (활성화/비활성화)
  - 현재 단계 상태
  - 재료/조리법 단계 전환 상태
- `providers/recipe_calculation_provider.dart`: 레시피 계산 상태 관리
  - 계산된 재료량 상태
  - 배율/인분 수 상태
  - 분할량/분할 개수 상태

### RecipeProvider 개선
- 오류 처리 개선
- 비동기 작업 상태 관리 개선
- 로깅 개선

## 4. 유틸리티 확장

### 기존 유틸리티 개선
- `utils/unit_converter.dart`: 단위 변환 유틸리티 개선
  - 오류 처리 추가
  - 지원 단위 확장

### 새로운 유틸리티 추가
- `utils/image_utils.dart`: 이미지 유틸리티
  - 이미지 압축 함수
  - 이미지 크기 조정 함수
- `utils/file_utils.dart`: 파일 유틸리티
  - 파일 저장 함수
  - 파일 복사 함수
- `utils/validation_utils.dart`: 입력 검증 유틸리티
  - 숫자 입력 검증 함수
  - 필수 입력 검증 함수

## 5. 오류 처리 개선

### 일관된 오류 처리 메커니즘
- `utils/error_handler.dart`: 오류 처리 유틸리티
  - 오류 로깅 함수
  - 사용자 친화적 오류 메시지 생성 함수

### 사용자 피드백 개선
- 오류 발생 시 스낵바 표시
- 로딩 상태 표시 개선
- 성공 피드백 개선

## 6. 단계별 구현 및 테스트 계획

### 단계 1: 유틸리티 및 서비스 클래스 분리
1. 유틸리티 클래스 분리 및 테스트
2. 서비스 클래스 분리 및 테스트
3. 기존 코드에서 새 유틸리티/서비스 사용하도록 수정

### 단계 2: 위젯 컴포넌트 분리
1. RecipeDetailScreen 위젯 분리 및 테스트
2. AddRecipeScreen 위젯 분리 및 테스트
3. 기존 화면에서 새 위젯 사용하도록 수정

### 단계 3: 상태 관리 개선
1. Provider 분리 및 테스트
2. 기존 상태 관리 코드를 새 Provider로 이전
3. 화면에서 새 Provider 사용하도록 수정

### 단계 4: 종합 테스트
1. 체크리스트의 모든 기능 테스트
2. 엣지 케이스 및 오류 상황 테스트
3. 사용자 시나리오 기반 테스트