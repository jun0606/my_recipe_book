# AI 컨텍스트 최적화 가이드

## 1. 개요

이 문서는 AI가 프로젝트를 더 효율적으로 이해하고 작업할 수 있도록 최적화된 컨텍스트를 제공합니다. 코드 구조, 패턴, 주요 컴포넌트 간의 관계를 간결하게 요약하여 AI가 빠르게 프로젝트를 파악할 수 있도록 돕습니다.

## 2. 핵심 코드 구조 요약

### 2.1 주요 클래스 및 관계

```
[UI 레이어]
RecipeListScreen → RecipeDetailScreen → AddRecipeScreen
       ↓                  ↓                   ↓
[상태 관리 레이어]
RecipeProvider ←--------------------------→ RecipeCalculationProvider
       ↓                                       ↓
[서비스 레이어]
RecipeService ←------------------------→ RecipeDerivationService
       ↓
[데이터 레이어]
로컬 저장소 / 원격 API
```

### 2.2 핵심 알고리즘 및 비즈니스 로직

1. **레시피 CRUD 작업**: `RecipeProvider`에서 관리
2. **레시피 계산 로직**: `RecipeCalculationProvider`에서 처리 (분량 조절, 단위 변환 등)
3. **레시피 파생 로직**: `RecipeDerivationService`에서 처리 (유사 레시피 찾기, 레시피 변형 등)
4. **이미지 처리**: `ImagePickerWidget`에서 관리

### 2.3 가장 중요한 파일 10개

1. `lib/providers/recipe_provider.dart` - 레시피 데이터 관리의 중심
2. `lib/models/recipe.dart` - 핵심 데이터 모델 정의
3. `lib/screens/recipe_detail_screen.dart` - 레시피 상세 정보 표시
4. `lib/screens/recipe_list_screen.dart` - 레시피 목록 표시
5. `lib/screens/add_recipe_screen.dart` - 레시피 추가/편집 기능
6. `lib/providers/recipe_calculation_provider.dart` - 레시피 계산 로직
7. `lib/services/recipe_derivation_service.dart` - 레시피 파생 기능
8. `lib/widgets/recipe_detail/baking_calculator.dart` - 베이킹 계산 기능
9. `lib/widgets/add_recipe/ingredient_form.dart` - 재료 입력 폼
10. `lib/widgets/add_recipe/instruction_form.dart` - 조리 과정 입력 폼

## 3. 코드 패턴 사전

### 3.1 상태 관리 패턴

```dart
// Provider 패턴 예시
class RecipeProvider with ChangeNotifier {
  List<Recipe> _recipes = [];
  
  List<Recipe> get recipes => [..._recipes];
  
  void addRecipe(Recipe recipe) {
    _recipes.add(recipe);
    notifyListeners();
  }
}

// 사용 예시
final recipeProvider = Provider.of<RecipeProvider>(context);
final recipes = recipeProvider.recipes;
```

### 3.2 폼 관리 패턴

```dart
// 폼 상태 관리 예시
final _formKey = GlobalKey<FormState>();
final _nameController = TextEditingController();

// 폼 검증 및 저장
void _saveForm() {
  final isValid = _formKey.currentState!.validate();
  if (!isValid) return;
  
  _formKey.currentState!.save();
  // 저장 로직
}
```

### 3.3 비동기 데이터 로딩 패턴

```dart
// FutureBuilder 사용 예시
FutureBuilder<List<Recipe>>(
  future: recipeProvider.fetchRecipes(),
  builder: (ctx, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    if (snapshot.error != null) {
      return ErrorWidget(snapshot.error.toString());
    }
    final recipes = snapshot.data ?? [];
    return RecipeList(recipes);
  }
)
```

### 3.4 위젯 구성 패턴

```dart
// 위젯 분리 및 재사용 패턴
class RecipeDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('레시피 상세')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            RecipeHeader(),
            IngredientList(),
            InstructionList(),
            BakingCalculator(),
          ],
        ),
      ),
    );
  }
}
```

## 4. 빠른 참조 가이드

### 4.1 자주 사용되는 변수 및 함수

| 이름 | 위치 | 목적 | 사용 예시 |
|------|------|------|----------|
| `recipes` | `RecipeProvider` | 모든 레시피 목록 접근 | `final recipes = Provider.of<RecipeProvider>(context).recipes;` |
| `addRecipe` | `RecipeProvider` | 새 레시피 추가 | `recipeProvider.addRecipe(newRecipe);` |
| `calculateIngredients` | `RecipeCalculationProvider` | 레시피 분량 계산 | `final calculated = calculationProvider.calculateIngredients(recipe, servings);` |
| `pickImage` | `ImagePickerWidget` | 이미지 선택 기능 | `final image = await ImagePickerWidget.pickImage();` |
| `saveRecipe` | `RecipeService` | 레시피 저장 | `await recipeService.saveRecipe(recipe);` |

### 4.2 주요 상태 관리 흐름

1. **레시피 목록 표시**:
   ```
   RecipeProvider.fetchRecipes() → RecipeListScreen 업데이트 → 사용자에게 표시
   ```

2. **레시피 추가**:
   ```
   AddRecipeScreen 입력 → RecipeProvider.addRecipe() → 로컬 저장소에 저장 → RecipeListScreen 업데이트
   ```

3. **레시피 수정**:
   ```
   RecipeDetailScreen → 편집 모드 → AddRecipeScreen → RecipeProvider.updateRecipe() → 로컬 저장소 업데이트
   ```

### 4.3 데이터 모델 관계

```
Recipe
 ├── id: String
 ├── title: String
 ├── description: String
 ├── imageUrl: String?
 ├── ingredients: List<Ingredient>
 ├── instructions: List<Instruction>
 ├── servings: int
 ├── prepTime: Duration
 ├── cookTime: Duration
 └── tags: List<String>?

Ingredient
 ├── name: String
 ├── amount: double
 ├── unit: String
 └── notes: String?

Instruction
 ├── step: int
 ├── description: String
 └── imageUrl: String?
```

## 5. 코드 변경 영향 분석

### 5.1 고위험 변경 영역

다음 영역을 변경할 때는 특히 주의가 필요합니다:

1. **Recipe 모델 구조**: 많은 화면과 위젯이 의존하므로 변경 시 광범위한 영향
2. **RecipeProvider 메서드**: 앱 전체의 데이터 흐름에 영향
3. **계산 로직**: 정확성에 영향을 미치므로 신중한 테스트 필요

### 5.2 변경 시 영향 받는 컴포넌트

| 변경 대상 | 영향 받는 컴포넌트 | 주의사항 |
|----------|-----------------|---------|
| `Recipe` 모델 | 모든 화면, 대부분의 위젯 | 직렬화/역직렬화 로직도 함께 업데이트 |
| `RecipeProvider` | 모든 화면, 목록 관련 위젯 | 상태 업데이트 로직 확인 |
| `BakingCalculator` | 계산 관련 UI, 단위 변환 | 계산 정확성 검증 필요 |
| 이미지 처리 로직 | 이미지 선택, 표시 위젯 | 권한 및 저장소 접근 확인 |

## 6. 자주 발생하는 오류 패턴 및 해결책

### 6.1 널 참조 오류

```dart
// 문제 코드
void processRecipe(Recipe? recipe) {
  final title = recipe.title; // recipe가 null일 수 있음
}

// 해결책
void processRecipe(Recipe? recipe) {
  if (recipe == null) return;
  final title = recipe.title;
  
  // 또는
  final title = recipe?.title ?? 'Untitled';
}
```

### 6.2 비동기 상태 관리 오류

```dart
// 문제 코드
void fetchAndProcess() async {
  final recipes = await fetchRecipes();
  setState(() {
    // 컴포넌트가 이미 dispose된 경우 오류 발생 가능
    this.recipes = recipes;
  });
}

// 해결책
void fetchAndProcess() async {
  if (!mounted) return;
  final recipes = await fetchRecipes();
  if (!mounted) return;
  setState(() {
    this.recipes = recipes;
  });
}
```

### 6.3 리스트 수정 오류

```dart
// 문제 코드
void addIngredient(Ingredient ingredient) {
  recipe.ingredients.add(ingredient); // 원본 리스트 직접 수정
}

// 해결책
void addIngredient(Ingredient ingredient) {
  setState(() {
    recipe = recipe.copyWith(
      ingredients: [...recipe.ingredients, ingredient]
    );
  });
}
```

## 7. 효율적인 AI 작업을 위한 팁

1. **문서 간 상호 참조**: 관련 문서를 함께 참조하여 전체적인 맥락 파악
2. **코드 패턴 재사용**: 이미 프로젝트에서 사용 중인 패턴을 따라 일관성 유지
3. **변경 범위 최소화**: 필요한 부분만 최소한으로 변경하여 부작용 방지
4. **테스트 케이스 고려**: 코드 변경 시 어떤 테스트가 필요한지 고려
5. **문서 업데이트**: 코드 변경 후 관련 문서도 함께 업데이트

## 8. 결론

이 가이드를 통해 AI는 프로젝트의 구조와 패턴을 빠르게 이해하고, 효율적으로 코드를 분석하며, 안전하게 변경할 수 있습니다. 코드 변경 시에는 항상 이 문서를 참조하여 프로젝트의 일관성과 품질을 유지하세요.