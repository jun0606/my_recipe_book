# AI GUIDE

This document is a merge of the following files:
- ai_context_optimization_guide.md
- ai_code_modification_guidelines.md
- ai_hallucination_prevention_guide.md

---

## AI CONTEXT OPTIMIZATION GUIDE

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

---

## AI CODE MODIFICATION GUIDELINES

# AI 코드 수정 및 안전한 리팩토링 지침

## 1. 개요

이 문서는 AI가 코드를 수정하거나 리팩토링할 때 따라야 할 지침을 제공합니다. 코드 변경 시 기존 기능에 부정적인 영향을 미치지 않고, 기능 유실을 방지하며, 안전하게 코드를 개선하는 방법을 설명합니다.

## 2. 코드 수정 기본 원칙

### 2.1 기능 보존 우선

1. **기존 기능 유지**: 모든 코드 수정은 기존 기능을 정확히 유지해야 함
2. **동작 방식 존중**: 코드의 원래 의도와 동작 방식을 이해하고 존중
3. **부작용 최소화**: 다른 부분에 미치는 영향을 최소화
4. **점진적 변경**: 한 번에 대규모 변경보다 작은 단위로 점진적 변경

### 2.2 수정 전 필수 확인 사항

1. **코드 이해**: 수정할 코드의 목적과 동작 방식을 완전히 이해
2. **의존성 파악**: 해당 코드에 의존하는 다른 코드 식별
3. **테스트 가능성**: 변경 후 테스트 방법 확인
4. **롤백 계획**: 문제 발생 시 이전 상태로 돌아갈 방법 준비

## 3. 함수 수정 지침

### 3.1 함수 시그니처 변경 시 주의사항

1. **매개변수 추가/제거**
   - 기존 호출 코드가 모두 영향을 받음
   - 기본값을 사용하여 하위 호환성 유지
   ```dart
   // 나쁜 예: 기존 호출 코드가 모두 깨짐
   // 변경 전
   void processData(String data) { ... }
   // 변경 후
   void processData(String data, bool validate) { ... }
   
   // 좋은 예: 기본값으로 하위 호환성 유지
   // 변경 후
   void processData(String data, {bool validate = false}) { ... }
   ```

2. **반환 타입 변경**
   - 반환 타입 변경은 매우 위험함
   - 반환 타입을 확장하는 방향으로만 변경 (예: `int`에서 `num`으로)
   - 불가피한 경우 새 함수 생성 고려

3. **함수 이름 변경**
   - 모든 호출 지점 식별 및 업데이트 필요
   - 일시적으로 두 함수 모두 유지하고 점진적으로 마이그레이션

### 3.2 함수 내부 로직 변경 시 주의사항

1. **경계 조건 처리**
   - 기존 코드의 모든 경계 조건 처리 방식 유지
   - 새로운 경계 조건 발견 시 기존 패턴과 일관되게 처리

2. **성능 최적화**
   - 최적화로 인해 동작이 변경되지 않는지 확인
   - 최적화 전후 결과가 동일한지 검증

3. **오류 처리**
   - 기존 오류 처리 메커니즘 유지
   - 오류 처리 개선 시 기존 호출자에게 영향 없는지 확인

### 3.3 함수 추가/삭제 시 주의사항

1. **함수 추가**
   - 기존 함수와 이름 충돌 없는지 확인
   - 명확한 목적과 문서화 제공

2. **함수 삭제**
   - 해당 함수를 호출하는 모든 코드 식별
   - 대체 함수 제공 또는 호출 코드 수정
   - 삭제 전 일정 기간 `@deprecated` 표시 고려

## 4. 변수 수정 지침

### 4.1 변수 이름/타입 변경 시 주의사항

1. **변수 이름 변경**
   - 해당 변수의 모든 사용처 식별 및 업데이트
   - 특히 문자열 참조(예: JSON 키)에 주의

2. **변수 타입 변경**
   - 타입 호환성 확인
   - 해당 변수를 사용하는 모든 코드에서 타입 가정 확인
   ```dart
   // 나쁜 예: 타입 변경으로 인한 오류
   // 변경 전
   int count = 5;
   // 사용 코드
   int doubledCount = count * 2;
   
   // 변경 후
   String count = "5"; // 타입 변경
   // 기존 사용 코드에서 오류 발생
   int doubledCount = count * 2; // 컴파일 오류
   ```

### 4.2 전역 변수 수정 시 주의사항

1. **값 변경**
   - 전역 변수는 여러 곳에서 사용될 수 있음을 인지
   - 모든 사용처에서 새 값이 적합한지 확인

2. **가시성 변경**
   - 공개 변수를 비공개로 변경 시 모든 외부 접근 코드 식별
   - 필요한 경우 접근자 메서드 제공

3. **상수화**
   - 변수를 상수로 변경 시 모든 수정 시도 코드 식별

## 5. 클래스 및 구조 수정 지침

### 5.1 클래스 구조 변경 시 주의사항

1. **필드 추가/제거**
   - 생성자 매개변수 업데이트 필요
   - 직렬화/역직렬화 코드 영향 확인 (JSON 변환 등)

2. **상속 관계 변경**
   - 하위 클래스에 미치는 영향 분석
   - 오버라이드된 메서드의 동작 변경 여부 확인

3. **인터페이스 변경**
   - 모든 구현체 업데이트 필요
   - 인터페이스 분리 원칙 고려

### 5.2 리팩토링 패턴 적용 시 주의사항

1. **메서드 추출**
   - 추출된 메서드의 가시성 적절히 설정
   - 상태 변경 시 원래 메서드와 동일한 효과 유지

2. **클래스 분할**
   - 분할된 클래스 간 책임 명확히 구분
   - 기존 API 호환성 유지

3. **코드 이동**
   - 이동된 코드의 컨텍스트 변화로 인한 영향 확인
   - 특히 `this` 참조나 상속된 멤버 접근에 주의

## 6. 컴파일 오류 해결 지침

### 6.1 컴파일 오류 유형별 대응 방법

1. **타입 오류**
   - 명시적 타입 캐스팅 대신 근본 원인 해결
   - 제네릭 타입 파라미터 확인

2. **누락된 구현**
   - 인터페이스 요구사항 완전히 구현
   - 추상 메서드 구현 시 원래 의도 파악

3. **구문 오류**
   - 언어 버전 호환성 확인
   - 들여쓰기 및 괄호 짝 맞춤 확인

4. **임포트 오류**
   - 패키지 의존성 확인
   - 순환 참조 방지

### 6.2 컴파일 오류 해결 프로세스

1. **오류 메시지 분석**
   - 오류 메시지와 위치 정확히 파악
   - 관련 코드 맥락 이해

2. **최소 변경 원칙**
   - 오류 해결을 위한 최소한의 변경만 적용
   - 불필요한 코드 변경 지양

3. **연쇄 효과 확인**
   - 한 오류 수정이 다른 오류를 유발할 수 있음
   - 수정 후 전체 컴파일 확인

4. **문서화**
   - 비직관적인 해결책의 경우 주석으로 설명 추가

## 7. 런타임 오류 방지 지침

### 7.1 일반적인 런타임 오류 방지

1. **널 참조**
   - 널 안전성 확보
   - 널 체크 또는 널 안전 연산자 사용
   ```dart
   // 나쁜 예: 널 참조 가능성
   void processUser(User user) {
     print(user.name.toUpperCase()); // user.name이 null이면 오류
   }
   
   // 좋은 예: 널 안전성 확보
   void processUser(User user) {
     final name = user.name;
     if (name != null) {
       print(name.toUpperCase());
     }
   }
   ```

2. **인덱스 범위 오류**
   - 배열/리스트 접근 전 범위 확인
   - 빈 컬렉션 처리 로직 구현

3. **타입 캐스팅 오류**
   - 캐스팅 전 타입 확인
   - `as?` 또는 `is` 연산자 활용

4. **비동기 오류**
   - 모든 Future/Promise 오류 처리
   - 적절한 try-catch 구문 사용

### 7.2 상태 관리 관련 오류 방지

1. **상태 불일치**
   - 관련 상태 변수 동시 업데이트
   - 트랜잭션적 업데이트 패턴 사용

2. **경쟁 상태**
   - 비동기 작업의 순서 보장
   - 적절한 동기화 메커니즘 사용

3. **메모리 누수**
   - 리스너/옵저버 등록 해제
   - 순환 참조 방지

## 8. 기능 유실 방지 지침

### 8.1 기능 유실 위험이 높은 상황

1. **조건부 로직 변경**
   - 복잡한 if-else 구문 수정 시 모든 분기 처리 확인
   - 특히 예외 케이스 처리 유지

2. **API 응답 처리 변경**
   - 응답 구조 가정 변경 시 주의
   - 모든 필드 처리 로직 유지

3. **이벤트 핸들러 수정**
   - 이벤트 전파 및 기본 동작 처리 유지
   - 부수 효과 유지

4. **UI 관련 코드 변경**
   - 레이아웃 및 스타일 영향 확인
   - 접근성 기능 유지

### 8.2 기능 유실 방지 전략

1. **변경 전후 동작 비교**
   - 주요 사용 시나리오 목록 작성
   - 각 시나리오에 대한 변경 전후 동작 검증

2. **점진적 변경**
   - 한 번에 하나의 기능만 수정
   - 각 단계마다 테스트

3. **기능 문서화**
   - 수정 전 기존 기능 동작 문서화
   - 변경 후 문서와 실제 동작 일치 확인

4. **사용자 피드백 수집**
   - 변경 후 사용자 경험 모니터링
   - 피드백 기반 신속한 조정

## 9. AI가 사용자에게 물어봐야 할 상황

다음 상황에서는 AI가 직접 결정하지 말고 사용자에게 물어봐야 합니다:

### 9.1 명확한 지침이 없는 경우

1. **여러 해결책이 가능한 경우**
   - 각 접근법의 장단점 설명 후 선택 요청
   - 예: "이 문제는 A 방식과 B 방식으로 해결할 수 있습니다. A는 성능이 좋지만 복잡하고, B는 간단하지만 약간 느립니다. 어떤 방식을 선호하시나요?"

2. **기존 패턴과 충돌하는 경우**
   - 기존 코드 패턴과 모범 사례가 충돌할 때
   - 예: "기존 코드는 싱글톤 패턴을 사용하고 있지만, 의존성 주입이 더 좋은 방법입니다. 기존 패턴을 유지할까요, 아니면 개선할까요?"

3. **중요한 구조적 변경이 필요한 경우**
   - 광범위한 리팩토링이 필요한 상황
   - 예: "이 문제를 제대로 해결하려면 인증 시스템 전체를 재구성해야 합니다. 이런 대규모 변경을 진행해도 될까요?"

### 9.2 위험 요소가 있는 경우

1. **데이터 손실 가능성**
   - 데이터 구조나 저장 방식 변경 시
   - 예: "사용자 프로필 스키마 변경은 기존 데이터와 호환되지 않을 수 있습니다. 마이그레이션 전략을 논의해야 합니다."

2. **성능에 중대한 영향**
   - 성능 트레이드오프가 필요한 결정
   - 예: "이 변경은 메모리 사용량을 줄이지만 처리 속도가 느려질 수 있습니다. 어떤 측면을 우선시할까요?"

3. **보안 관련 변경**
   - 인증, 권한 부여, 암호화 등 보안 관련 코드 수정
   - 예: "토큰 검증 로직 변경은 보안에 영향을 줄 수 있습니다. 이 접근 방식이 요구사항에 맞는지 확인해 주시겠어요?"

### 9.3 비즈니스 로직 관련 결정

1. **비즈니스 규칙 해석**
   - 비즈니스 로직이 명확하지 않은 경우
   - 예: "할인 적용 순서가 명시되어 있지 않습니다. 쿠폰 할인을 먼저 적용한 후 회원 할인을 적용할까요, 아니면 그 반대로 할까요?"

2. **예외 처리 정책**
   - 오류 상황에서의 동작 방식
   - 예: "결제 실패 시 주문을 취소할까요, 아니면 보류 상태로 유지할까요?"

3. **기능 우선순위**
   - 여러 기능 간의 우선순위 결정
   - 예: "성능과 사용성 중 어떤 측면을 우선시해야 할까요?"

## 10. 효율적인 코드 수정 워크플로우

### 10.1 수정 전 준비

1. **요구사항 명확화**
   - 수정 목적과 기대 결과 명확히 이해
   - 모호한 부분은 질문으로 명확히

2. **영향 범위 분석**
   - 수정할 코드와 영향 받는 코드 식별
   - 의존성 그래프 작성

3. **테스트 계획**
   - 변경 검증 방법 계획
   - 핵심 기능 테스트 케이스 식별

### 10.2 수정 과정

1. **단계적 접근**
   - 논리적 단위로 나누어 순차적 수정
   - 각 단계마다 컴파일 및 기본 테스트

2. **변경 추적**
   - 수정 내용과 이유 기록
   - 원래 코드와 수정된 코드 비교 유지

3. **중간 검증**
   - 주요 변경 후 중간 검증
   - 예상치 못한 부작용 조기 발견

### 10.3 수정 후 검증

1. **전체 테스트**
   - 모든 관련 기능 테스트
   - 경계 조건 및 예외 상황 확인

2. **코드 품질 검토**
   - 코드 스타일 및 표준 준수 확인
   - 불필요한 복잡성 제거

3. **문서화 업데이트**
   - 변경 사항 문서화
   - 필요시 주석 및 API 문서 업데이트

## 11. 결론

코드 수정은 기존 기능을 유지하면서 개선하는 섬세한 작업입니다. 이 지침을 따르면 AI가 안전하고 효과적으로 코드를 수정하여 기능 유실이나 오류를 최소화할 수 있습니다.

불확실한 상황이나 지침에 명시되지 않은 경우에는 항상 사용자에게 문의하여 결정을 내리는 것이 중요합니다. 코드 수정은 기술적 측면뿐만 아니라 비즈니스 요구사항과 사용자 경험을 모두 고려해야 하는 복합적인 과정입니다.

효율적인 코드 수정을 위해 준비, 실행, 검증의 체계적인 워크플로우를 따르고, 변경 사항을 명확히 문서화하여 향후 유지보수를 용이하게 만드는 것이 중요합니다.

---

## AI HALLUCINATION PREVENTION GUIDE

# AI 할루시네이션 감지 및 방지 가이드

## 1. 개요

이 문서는 AI 할루시네이션(존재하지 않는 정보를 실제인 것처럼 생성하는 현상)을 감지하고 방지하는 방법을 설명합니다. 프로젝트에서 AI와 협업할 때 정확하고 신뢰할 수 있는 결과를 얻기 위한 지침을 제공합니다.

## 2. 할루시네이션 이해하기

### 2.1 할루시네이션의 정의

AI 할루시네이션은 AI가 실제로 존재하지 않는 정보, 코드, 파일, 함수 등을 마치 존재하는 것처럼 생성하거나 참조하는 현상입니다. 이는 AI가 학습 데이터에서 패턴을 과도하게 일반화하거나, 컨텍스트를 잘못 해석하거나, 불완전한 정보를 기반으로 추론할 때 발생합니다.

### 2.2 일반적인 할루시네이션 유형

1. **코드 할루시네이션**: 프로젝트에 존재하지 않는 함수, 클래스, 변수를 참조
2. **파일 할루시네이션**: 존재하지 않는 파일이나 디렉토리를 언급
3. **기능 할루시네이션**: 구현되지 않은 기능이 이미 존재한다고 가정
4. **API 할루시네이션**: 존재하지 않는 API 엔드포인트나 매개변수를 설명
5. **문서 할루시네이션**: 존재하지 않는 문서나 문서 섹션을 참조

## 3. 할루시네이션 감지 방법

### 3.1 코드 할루시네이션 감지

1. **함수 및 클래스 확인**
   - AI가 언급한 함수나 클래스가 실제로 존재하는지 코드베이스에서 검색
   - 예: `findRecipeByTag()` 함수를 언급했다면, 해당 함수가 실제로 구현되어 있는지 확인

2. **임포트 확인**
   - AI가 제안한 임포트 문이 유효한지 확인
   - 존재하지 않는 패키지나 모듈을 임포트하는지 확인

3. **API 사용법 검증**
   - AI가 제안한 API 호출 방식이 실제 API 문서와 일치하는지 확인
   - 매개변수 이름, 타입, 필수 여부 등을 검증

### 3.2 문서 할루시네이션 감지

1. **문서 참조 확인**
   - AI가 언급한 문서나 문서 섹션이 실제로 존재하는지 확인
   - 예: "feature_catalog.md의 태그 기능 섹션을 참조하세요"라고 했다면, 해당 섹션이 실제로 존재하는지 확인

2. **버전 정보 검증**
   - AI가 언급한 버전 번호나 릴리스 정보가 실제와 일치하는지 확인

### 3.3 기능 할루시네이션 감지

1. **기능 목록 대조**
   - AI가 언급한 기능이 feature_catalog.md에 실제로 등록되어 있는지 확인
   - 구현 상태가 AI의 설명과 일치하는지 확인

2. **스크린샷 또는 UI 설명 검증**
   - AI가 설명한 UI 요소나 화면이 실제 앱에 존재하는지 확인

## 4. 할루시네이션 방지 전략

### 4.1 명확한 컨텍스트 제공

1. **관련 파일 명시적 제공**
   - AI에게 질문할 때 관련 파일을 명시적으로 제공
   - 예: "다음 파일을 참조하여 질문에 답해주세요: recipe_provider.dart, recipe_model.dart"

2. **현재 상태 명확히 설명**
   - 프로젝트의 현재 상태, 구현된 기능, 미구현 기능을 명확히 설명
   - 예: "현재 태그 기능은 아직 구현되지 않았으며, 이를 새로 추가하려고 합니다."

3. **질문 범위 제한**
   - 너무 광범위한 질문보다는 구체적이고 범위가 제한된 질문 사용
   - 예: "전체 앱을 설명해주세요" 대신 "레시피 저장 기능이 어떻게 구현되어 있나요?"

### 4.2 AI 응답 검증 프로세스

1. **단계적 검증**
   - AI의 응답을 한 번에 모두 적용하지 않고 단계별로 검증
   - 각 단계마다 실행 가능한지, 기존 코드와 호환되는지 확인

2. **참조 확인 요청**
   - AI에게 응답의 근거가 되는 파일이나 코드 부분을 명시적으로 인용하도록 요청
   - 예: "이 접근 방식의 근거가 되는 코드나 문서를 인용해주세요."

3. **불확실성 표현 주의**
   - AI가 "아마도", "~일 수 있습니다" 등의 불확실한 표현을 사용할 때 추가 확인
   - 확실하지 않은 정보는 검증 후 사용

### 4.3 AI 프롬프트 최적화

1. **명확한 지시어 사용**
   - "추측하지 말고 확실한 정보만 제공해주세요."
   - "코드베이스에 없는 함수나 클래스를 참조하지 말아주세요."
   - "모르는 경우 솔직히 모른다고 말해주세요."

2. **검증 요청 포함**
   - "제안하는 코드가 기존 코드베이스와 호환되는지 확인해주세요."
   - "이 접근 방식의 잠재적 문제점도 함께 알려주세요."

3. **단계별 응답 요청**
   - 복잡한 작업은 단계별로 나누어 응답하도록 요청
   - 각 단계마다 검증 가능한 중간 결과물 요청

## 5. 할루시네이션 발생 시 대응 방법

### 5.1 할루시네이션 식별 후 명확화 요청

```
# 할루시네이션 명확화 요청

방금 언급하신 [함수/파일/기능]은 현재 프로젝트에 존재하지 않는 것 같습니다.
다음 정보를 바탕으로 다시 설명해주세요:

1. 실제 존재하는 파일: [파일 목록]
2. 실제 구현된 기능: [기능 목록]

존재하지 않는 요소를 참조하지 말고, 실제 코드베이스에 기반하여 답변해주세요.
```

### 5.2 단계적 검증 프로세스

1. **소규모 테스트**
   - AI가 제안한 코드를 전체 적용하기 전에 작은 부분부터 테스트
   - 컴파일 오류나 런타임 오류 확인

2. **점진적 통합**
   - 검증된 부분부터 점진적으로 코드베이스에 통합
   - 각 단계마다 기능 테스트 수행

3. **문서화**
   - 할루시네이션이 발생한 경우와 해결 방법을 known_issues.md에 기록
   - 유사한 상황에서 참조할 수 있도록 문서화

## 6. 프로젝트별 할루시네이션 방지 설정

### 6.1 프로젝트 컨텍스트 파일 생성

프로젝트 루트에 `project_context.md` 파일을 생성하여 다음 정보를 포함:

```markdown
# 프로젝트 컨텍스트

## 1. 핵심 파일 목록
- [주요 파일 경로와 간략한 설명]

## 2. 구현된 기능
- [구현 완료된 기능 목록]

## 3. 구현 예정 기능
- [아직 구현되지 않은 기능 목록]

## 4. 사용 중인 라이브러리/프레임워크
- [주요 의존성 목록]

## 5. 코드 스타일 및 패턴
- [프로젝트에서 사용하는 주요 패턴]
```

### 6.2 Gemini CLI 설정 최적화

`start_gemini.bat` 파일을 수정하여 할루시네이션 방지 지침 포함:

```batch
@echo off
REM start_gemini.bat

set PROJECT_DIR=%CD%

REM Gemini CLI 시작 (할루시네이션 방지 지침 포함)
gemini -i "Please read and follow the instructions in %PROJECT_DIR%\.kiro\ai_guide.md and use %PROJECT_DIR%\.kiro\documentation_index.md, %PROJECT_DIR%\.kiro\ai_context_optimization_guide.md, and %PROJECT_DIR%\.kiro\ai_hallucination_prevention_guide.md as context for this project. Only reference files and functions that actually exist in the codebase. If you're uncertain about something, please state that clearly instead of making assumptions."
```

## 7. 할루시네이션 감지 체크리스트

AI 응답을 검토할 때 다음 체크리스트를 사용하세요:

- [ ] 언급된 모든 함수와 클래스가 실제로 존재하는가?
- [ ] 참조된 파일 경로가 정확한가?
- [ ] 설명된 기능이 실제로 구현되어 있는가?
- [ ] 제안된 코드가 기존 코드베이스와 호환되는가?
- [ ] API 사용법이 문서와 일치하는가?
- [ ] 불확실한 표현이나 모호한 설명이 있는가?
- [ ] 응답이 프로젝트의 현재 상태와 일치하는가?

## 8. 결론

AI 할루시네이션은 완전히 제거할 수는 없지만, 적절한 전략과 검증 프로세스를 통해 최소화할 수 있습니다. 명확한 컨텍스트 제공, 단계적 검증, 그리고 의심스러운 정보에 대한 추가 확인을 통해 AI와의 협업에서 더 정확하고 신뢰할 수 있는 결과를 얻을 수 있습니다.

AI는 강력한 도구이지만, 최종 판단과 검증은 항상 개발자의 몫임을 기억하세요. AI의 제안을 맹목적으로 따르기보다는 비판적으로 평가하고 검증하는 습관을 기르는 것이 중요합니다.

---

