# 실용적 레시피 계산기 설계 문서

## 개요

실제 현장에서 사용되는 실용적인 레시피 계산 시스템의 설계입니다. 복잡한 베이킹 과학보다는 사용자가 실제로 필요로 하는 기능들에 집중하여 직관적이고 효율적인 시스템을 구축합니다.

## 아키텍처

### 전체 시스템 구조

```
┌─────────────────────────────────────────────────────────────┐
│                    사용자 인터페이스 계층                      │
├─────────────────┬─────────────────┬─────────────────────────┤
│   일반 사용자    │   베이커리      │      연구원             │
│   간단 모드      │   실무 모드      │     전문가 모드          │
└─────────────────┴─────────────────┴─────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                    비즈니스 로직 계층                         │
├─────────────────┬─────────────────┬─────────────────────────┤
│  분할 계산 엔진  │  레시피 관리    │    파생 관리 시스템      │
│  재료 조정 엔진  │  버전 관리      │    안전성 검증 엔진      │
└─────────────────┴─────────────────┴─────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                      데이터 계층                            │
├─────────────────┬─────────────────┬─────────────────────────┤
│   레시피 저장소  │   히스토리 저장소│     설정 저장소          │
│   (SQLite)      │   (SQLite)      │     (SharedPrefs)       │
└─────────────────┴─────────────────┴─────────────────────────┘
```

### 핵심 컴포넌트

#### 1. 사용자 레벨 적응 시스템
```dart
enum UserLevel {
  beginner,    // 일반 사용자 - 간단한 기능만
  intermediate, // 베이커리 실무자 - 효율성 중심
  expert       // 연구원 - 모든 기능 제공
}

class UserLevelAdapter {
  Widget buildInterface(UserLevel level, Widget child) {
    switch (level) {
      case UserLevel.beginner:
        return BeginnerInterface(child: child);
      case UserLevel.intermediate:
        return IntermediateInterface(child: child);
      case UserLevel.expert:
        return ExpertInterface(child: child);
    }
  }
}
```

#### 2. 분할 계산 엔진
```dart
class DivisionCalculationEngine {
  // 기본 분할 계산 (5개 → 6개)
  Recipe calculateDivision({
    required Recipe originalRecipe,
    required int originalCount,
    required int targetCount,
  });
  
  // 무게 기반 분할 계산
  Recipe calculateByWeight({
    required Recipe originalRecipe,
    required double originalTotalWeight,
    required double targetTotalWeight,
  });
  
  // 남은 재료 계산
  Map<String, double> calculateRemainder({
    required Recipe scaledRecipe,
    required int actualDivisions,
  });
}
```

#### 3. 레시피 버전 관리 시스템
```dart
class RecipeVersionManager {
  // 자동 버전 생성
  RecipeVersion createVersion(Recipe recipe, String changeDescription);
  
  // 변경 사항 추적
  List<RecipeChange> trackChanges(Recipe original, Recipe modified);
  
  // 버전 비교
  RecipeComparison compareVersions(RecipeVersion v1, RecipeVersion v2);
  
  // 롤백 기능
  Recipe rollbackToVersion(String recipeId, String versionId);
}
```

#### 4. 레시피 파생 관리 시스템
```dart
class RecipeDerivationManager {
  // 파생 레시피 생성
  Recipe createDerivation({
    required List<Recipe> parentRecipes,
    required String derivationName,
    required Map<String, dynamic> modifications,
  });
  
  // 계보 트리 생성
  RecipeTree buildFamilyTree(String rootRecipeId);
  
  // 파생 관계 추적
  List<RecipeRelation> getRelations(String recipeId);
}
```

## 컴포넌트 및 인터페이스

### 1. 메인 계산 인터페이스

#### 간단 모드 (일반 사용자)
```dart
class SimpleCalculatorInterface extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 레시피 선택
        RecipeSelector(),
        
        // 간단한 분할 입력
        Row(
          children: [
            Text("원래 개수:"),
            NumberInput(controller: originalCountController),
            Text("→"),
            Text("만들고 싶은 개수:"),
            NumberInput(controller: targetCountController),
          ],
        ),
        
        // 계산 버튼
        ElevatedButton(
          onPressed: calculateSimple,
          child: Text("계산하기"),
        ),
        
        // 결과 표시 (매우 간단하게)
        if (result != null) SimpleResultDisplay(result: result),
        
        // 재료 조정 제안
        if (result != null) IngredientAdjustmentSuggestions(),
      ],
    );
  }
}
```

#### 실무 모드 (베이커리)
```dart
class PracticalCalculatorInterface extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 빠른 배수 버튼들
        QuickMultiplierButtons(multipliers: [2, 3, 5, 10]),
        
        // 정확한 개수/무게 입력
        TabBar(
          tabs: [
            Tab(text: "개수로 계산"),
            Tab(text: "무게로 계산"),
          ],
        ),
        
        TabBarView(
          children: [
            CountBasedCalculation(),
            WeightBasedCalculation(),
          ],
        ),
        
        // 남은 재료 표시 및 활용 제안
        RemainingIngredientsPanel(),
        
        // 즐겨찾기 및 최근 사용
        QuickAccessPanel(),
      ],
    );
  }
}
```

#### 전문가 모드 (연구원)
```dart
class ExpertCalculatorInterface extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 모든 계산 옵션
        AdvancedCalculationOptions(),
        
        // 레시피 비교 및 분석
        RecipeComparisonPanel(),
        
        // 버전 관리
        VersionControlPanel(),
        
        // 파생 관리
        DerivationManagementPanel(),
        
        // 상세 분석 결과
        DetailedAnalysisResults(),
      ],
    );
  }
}
```

### 2. 레시피 파생 트리 시각화

```dart
class RecipeTreeVisualization extends StatelessWidget {
  final RecipeTree tree;
  
  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      child: CustomPaint(
        painter: RecipeTreePainter(tree),
        child: Container(
          width: double.infinity,
          height: 400,
          child: Stack(
            children: tree.nodes.map((node) => 
              Positioned(
                left: node.x,
                top: node.y,
                child: RecipeNodeWidget(
                  recipe: node.recipe,
                  onTap: () => navigateToRecipe(node.recipe.id),
                ),
              )
            ).toList(),
          ),
        ),
      ),
    );
  }
}
```

### 3. 버전 비교 인터페이스

```dart
class RecipeVersionComparison extends StatelessWidget {
  final RecipeVersion version1;
  final RecipeVersion version2;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 왼쪽: 이전 버전
        Expanded(
          child: RecipeVersionDisplay(
            version: version1,
            highlightChanges: false,
          ),
        ),
        
        // 중간: 변경 사항 표시
        Container(
          width: 100,
          child: ChangeIndicatorColumn(
            changes: compareVersions(version1, version2),
          ),
        ),
        
        // 오른쪽: 현재 버전
        Expanded(
          child: RecipeVersionDisplay(
            version: version2,
            highlightChanges: true,
          ),
        ),
      ],
    );
  }
}
```

## 데이터 모델

### 1. 확장된 레시피 모델

```dart
class PracticalRecipe {
  final String id;
  final String name;
  final List<Ingredient> ingredients;
  final int originalYield; // 원래 나오는 개수
  final double originalTotalWeight; // 원래 총 무게
  final RecipeMetadata metadata;
  final List<String> parentRecipeIds; // 파생 관계
  final List<RecipeVersion> versions; // 버전 히스토리
  
  // 실용적 계산을 위한 메서드들
  PracticalRecipe scaleByCount(int targetCount);
  PracticalRecipe scaleByWeight(double targetWeight);
  Map<String, double> calculateRemainder(int actualDivisions);
  List<IngredientAdjustment> getSafeAdjustments();
}
```

### 2. 레시피 버전 모델

```dart
class RecipeVersion {
  final String id;
  final String recipeId;
  final DateTime createdAt;
  final String description;
  final PracticalRecipe recipe;
  final List<RecipeChange> changes;
  final String createdBy;
  
  bool isOriginal() => changes.isEmpty;
  RecipeVersion getPreviousVersion();
  List<RecipeChange> getChangesFrom(RecipeVersion other);
}

class RecipeChange {
  final String field;
  final dynamic oldValue;
  final dynamic newValue;
  final ChangeType type; // added, modified, removed
  final DateTime timestamp;
}
```

### 3. 레시피 파생 관계 모델

```dart
class RecipeDerivation {
  final String id;
  final String childRecipeId;
  final List<String> parentRecipeIds;
  final DerivationType type; // variation, fusion, adaptation
  final String description;
  final Map<String, dynamic> modifications;
  final DateTime createdAt;
}

class RecipeTree {
  final String rootRecipeId;
  final List<RecipeTreeNode> nodes;
  final List<RecipeTreeEdge> edges;
  
  List<PracticalRecipe> getAncestors(String recipeId);
  List<PracticalRecipe> getDescendants(String recipeId);
  int getDerivationDepth(String recipeId);
}
```

## 에러 처리

### 1. 계산 에러 처리

```dart
class CalculationErrorHandler {
  static CalculationResult handleDivisionCalculation(
    Recipe recipe, 
    int originalCount, 
    int targetCount
  ) {
    try {
      // 기본 유효성 검사
      if (targetCount <= 0) {
        return CalculationResult.error("개수는 1개 이상이어야 합니다");
      }
      
      if (targetCount > originalCount * 10) {
        return CalculationResult.warning(
          "너무 많은 양입니다. 정말 ${targetCount}개를 만드시겠습니까?",
          result: performCalculation(recipe, originalCount, targetCount)
        );
      }
      
      return CalculationResult.success(
        performCalculation(recipe, originalCount, targetCount)
      );
      
    } catch (e) {
      return CalculationResult.error("계산 중 오류가 발생했습니다: ${e.message}");
    }
  }
}
```

### 2. 재료 조정 안전성 검증

```dart
class IngredientSafetyValidator {
  static ValidationResult validateAdjustment(
    Ingredient ingredient, 
    double adjustmentPercentage
  ) {
    final safetyRules = {
      'sugar': SafetyRule(minAdjustment: -20, maxAdjustment: 30),
      'salt': SafetyRule(minAdjustment: -10, maxAdjustment: 10),
      'baking_powder': SafetyRule(minAdjustment: -5, maxAdjustment: 15),
      'yeast': SafetyRule(minAdjustment: -20, maxAdjustment: 50),
    };
    
    final rule = safetyRules[ingredient.category];
    if (rule == null) {
      return ValidationResult.safe(); // 일반 재료는 자유롭게 조정 가능
    }
    
    if (adjustmentPercentage < rule.minAdjustment) {
      return ValidationResult.unsafe(
        "너무 적게 넣으면 맛이 이상해질 수 있습니다. "
        "${rule.minAdjustment}% 이상 권장합니다."
      );
    }
    
    if (adjustmentPercentage > rule.maxAdjustment) {
      return ValidationResult.unsafe(
        "너무 많이 넣으면 실패할 위험이 있습니다. "
        "${rule.maxAdjustment}% 이하 권장합니다."
      );
    }
    
    return ValidationResult.safe();
  }
}
```

## 테스트 전략

### 1. 단위 테스트

```dart
// 분할 계산 테스트
group('Division Calculation Tests', () {
  test('should correctly scale recipe from 5 to 6 pieces', () {
    final recipe = createTestRecipe(originalYield: 5);
    final result = DivisionCalculationEngine().calculateDivision(
      originalRecipe: recipe,
      originalCount: 5,
      targetCount: 6,
    );
    
    expect(result.ingredients.first.amount, equals(120.0)); // 100g * 1.2
  });
  
  test('should calculate remainder correctly', () {
    final recipe = createTestRecipe(totalWeight: 1000);
    final remainder = DivisionCalculationEngine().calculateRemainder(
      scaledRecipe: recipe,
      actualDivisions: 7,
    );
    
    expect(remainder['flour'], closeTo(14.3, 0.1)); // 1000g / 7 = 142.8g per piece
  });
});
```

### 2. 통합 테스트

```dart
// 전체 워크플로우 테스트
testWidgets('Complete recipe scaling workflow', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // 레시피 선택
  await tester.tap(find.text('초콜릿 쿠키'));
  await tester.pumpAndSettle();
  
  // 개수 입력
  await tester.enterText(find.byKey(Key('originalCount')), '12');
  await tester.enterText(find.byKey(Key('targetCount')), '18');
  
  // 계산 실행
  await tester.tap(find.text('계산하기'));
  await tester.pumpAndSettle();
  
  // 결과 확인
  expect(find.text('밀가루: 225g'), findsOneWidget); // 150g * 1.5
  expect(find.text('남은 재료로 2개 더 만들 수 있습니다'), findsOneWidget);
});
```

### 3. 성능 테스트

```dart
// 대용량 레시피 처리 성능 테스트
test('should handle large recipe calculations efficiently', () {
  final stopwatch = Stopwatch()..start();
  
  final largeRecipe = createLargeTestRecipe(ingredientCount: 50);
  final result = DivisionCalculationEngine().calculateDivision(
    originalRecipe: largeRecipe,
    originalCount: 100,
    targetCount: 1000,
  );
  
  stopwatch.stop();
  expect(stopwatch.elapsedMilliseconds, lessThan(100)); // 100ms 이내
  expect(result.ingredients.length, equals(50));
});
```

이 설계는 실제 현장의 요구사항을 반영하여 실용성과 사용성에 중점을 둔 시스템입니다. 복잡한 베이킹 과학보다는 사용자가 실제로 필요로 하는 기능들을 효율적으로 제공하는 것을 목표로 합니다.