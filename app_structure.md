# 앱 구조 문서

## 프로젝트 구조

```
lib/
├── models/             # 데이터 모델 클래스
│   ├── recipe.dart     # 레시피 모델
│   └── history.dart    # 히스토리 모델
│
├── providers/          # 상태 관리 Provider
│   ├── recipe_provider.dart             # 레시피 데이터 관리
│   ├── cooking_mode_provider.dart       # 요리 모드 상태 관리
│   └── recipe_calculation_provider.dart # 레시피 계산 상태 관리
│
├── screens/            # 화면 UI
│   ├── add_recipe_screen.dart           # 레시피 추가/수정 화면
│   ├── recipe_detail_screen.dart        # 레시피 상세 화면
│   ├── recipe_list_screen.dart          # 레시피 목록 화면
│   ├── recipe_tree_screen.dart          # 레시피 계보 화면
│   ├── recipe_history_screen.dart       # 레시피 히스토리 화면
│   ├── settings_screen.dart             # 설정 화면
│   ├── user_setup_screen.dart           # 사용자 설정 화면
│   └── welcome_ceremony_screen.dart     # 환영 화면
│
├── services/           # 비즈니스 로직 서비스
│   └── recipe_derivation_service.dart   # 레시피 파생 관계 서비스
│
├── utils/              # 유틸리티 클래스
│   ├── unit_converter.dart              # 단위 변환 유틸리티
│   ├── navigation.dart                  # 네비게이션 유틸리티
│   ├── image_utils.dart                 # 이미지 처리 유틸리티
│   ├── file_utils.dart                  # 파일 처리 유틸리티
│   ├── validation_utils.dart            # 입력 검증 유틸리티
│   └── error_handler.dart               # 오류 처리 유틸리티
│
├── widgets/            # 재사용 가능한 위젯
│   ├── recipe_detail/                   # 레시피 상세 화면 위젯
│   │   ├── ingredient_card.dart         # 재료 카드 위젯
│   │   ├── instruction_step.dart        # 조리법 단계 위젯
│   │   ├── cooking_mode_controls.dart   # 요리 모드 컨트롤 위젯
│   │   ├── baking_calculator.dart       # 베이킹 계산기 위젯
│   │   ├── servings_calculator.dart     # 인분 계산기 위젯
│   │   └── recipe_actions_menu.dart     # 레시피 액션 메뉴 위젯
│   │
│   ├── add_recipe/                      # 레시피 추가 화면 위젯
│   │   ├── ingredient_form.dart         # 재료 입력 폼 위젯
│   │   ├── instruction_form.dart        # 조리법 입력 폼 위젯
│   │   ├── image_picker_widget.dart     # 이미지 선택 위젯
│   │   └── baking_options.dart          # 베이킹 옵션 위젯
│   │
│   ├── recipe_tree/                     # 레시피 트리 화면 위젯
│   │   └── recipe_tree_item.dart        # 레시피 트리 항목 위젯
│   │
│   ├── recipe_search_delegate.dart      # 레시피 검색 위젯
│   └── tree_line_painter.dart           # 트리 라인 그리기 위젯
│
└── main.dart           # 앱 진입점
```

## 아키텍처 개요

### 데이터 흐름
1. **데이터 저장소**: SQLite 데이터베이스 (sqflite 패키지 사용)
2. **데이터 접근 계층**: RecipeProvider
3. **비즈니스 로직 계층**: 서비스 클래스 (RecipeDerivationService 등)
4. **상태 관리**: Provider 패턴 (provider 패키지 사용)
5. **UI 계층**: 화면 및 위젯

### 주요 상태 관리
- **RecipeProvider**: 레시피 CRUD 작업 및 데이터베이스 상호작용
- **CookingModeProvider**: 요리 모드 상태 관리
- **RecipeCalculationProvider**: 레시피 계산 상태 관리

### 의존성 관계
```
UI 계층 → 상태 관리 계층 → 비즈니스 로직 계층 → 데이터 접근 계층 → 데이터 저장소
```

## 주요 기술 스택
- **Flutter**: UI 프레임워크
- **Provider**: 상태 관리
- **SQLite (sqflite)**: 로컬 데이터베이스
- **shared_preferences**: 사용자 설정 저장
- **path_provider**: 파일 시스템 접근
- **image_picker**: 이미지 선택
- **flutter_image_compress**: 이미지 압축
- **excel**: Excel 파일 생성
- **share_plus**: 콘텐츠 공유
- **flutter_screenutil**: 반응형 UI

## 데이터베이스 스키마

### recipes 테이블
```sql
CREATE TABLE recipes (
  id INTEGER PRIMARY KEY AUTOINCREMENT, 
  title TEXT, 
  category TEXT,
  ingredients TEXT, 
  instructions TEXT, 
  imagePath TEXT,
  baseServings INTEGER DEFAULT 1, 
  isBaking INTEGER DEFAULT 0,
  targetSplitAmount REAL,
  targetSplitCount INTEGER,
  calculatedRemainingWeight REAL,
  totalIngredientWeight REAL,
  parentId INTEGER
)
```

### history 테이블
```sql
CREATE TABLE history (
  id INTEGER PRIMARY KEY AUTOINCREMENT, 
  recipeId INTEGER,
  modifiedDate TEXT, 
  changes TEXT, 
  recipeState TEXT
)
```

## 확장 계획
- **클라우드 동기화**: Firebase 통합
- **사용자 인증**: 계정 기반 데이터 관리
- **소셜 공유**: 레시피 공유 및 협업 기능
- **AI 기능**: 레시피 추천 및 자동 생성