import '../models/recipe.dart';
import '../models/ingredient.dart';

/// 실용적 레시피 계산을 위한 확장 클래스
/// 기존 Recipe 모델을 활용하면서 분할 계산에 필요한 기능들을 추가
class PracticalRecipe {
  final Recipe recipe;

  const PracticalRecipe({
    required this.recipe,
  });

  /// 기존 Recipe로부터 PracticalRecipe 생성
  factory PracticalRecipe.fromRecipe(Recipe recipe) {
    return PracticalRecipe(recipe: recipe);
  }

  /// 다양한 단위 테스트용 샘플 레시피 생성
  factory PracticalRecipe.sampleWithMixedUnits() {
    return PracticalRecipe(
      recipe: Recipe(
        title: '프리미엄 브라우니',
        category: '베이킹',
        baseServings: 8, // 8조각 나오는 레시피
        isBaking: true,
        ingredients: [
          Ingredient(name: '다크 초콜릿', amount: 0.2, unit: 'kg'), // 200g을 kg로 표시
          Ingredient(name: '버터', amount: 150.0, unit: 'g'),
          Ingredient(name: '설탕', amount: 1.5, unit: 'cup'), // 컵 단위
          Ingredient(name: '계란', amount: 3.0, unit: 'ea'),
          Ingredient(name: '밀가루', amount: 100.0, unit: 'g'),
          Ingredient(name: '코코아 파우더', amount: 3.0, unit: 'tbsp'), // 테이블스푼
          Ingredient(name: '우유', amount: 120.0, unit: 'ml'),
          Ingredient(name: '바닐라 에센스', amount: 2.0, unit: 'tsp'), // 티스푼
          Ingredient(name: '소금', amount: 0.5, unit: 'tsp'),
          Ingredient(name: '호두', amount: 4.0, unit: 'oz'), // 온스 단위
        ],
        instructions: [
          {'step': 1, 'description': '초콜릿과 버터를 중탕으로 녹입니다'},
          {'step': 2, 'description': '설탕과 계란을 잘 섞습니다'},
          {'step': 3, 'description': '녹인 초콜릿을 넣고 섞습니다'},
          {'step': 4, 'description': '밀가루와 코코아 파우더를 체쳐서 넣습니다'},
          {'step': 5, 'description': '우유와 바닐라 에센스를 넣습니다'},
          {'step': 6, 'description': '호두를 넣고 가볍게 섞습니다'},
          {'step': 7, 'description': '180도에서 25-30분간 굽습니다'},
        ],
        totalIngredientWeight: 850.0, // 대략적인 총 무게
      ),
    );
  }

  /// 샘플 레시피 생성 (테스트용)
  factory PracticalRecipe.sample() {
    return PracticalRecipe(
      recipe: Recipe(
        title: '초콜릿 쿠키',
        category: '베이킹',
        baseServings: 5, // 5개 나오는 레시피
        isBaking: true,
        ingredients: [
          {'name': '밀가루', 'amount': 200.0, 'unit': 'g'},
          {'name': '설탕', 'amount': 100.0, 'unit': 'g'},
          {'name': '버터', 'amount': 80.0, 'unit': 'g'},
          {'name': '계란', 'amount': 1.0, 'unit': 'ea'},
          {'name': '우유', 'amount': 50.0, 'unit': 'ml'},
          {'name': '베이킹파우더', 'amount': 1.0, 'unit': 'tsp'},
          {'name': '바닐라 에센스', 'amount': 0.5, 'unit': 'tsp'},
          {'name': '초콜릿칩', 'amount': 50.0, 'unit': 'g'},
        ],
        instructions: [
          {'step': 1, 'description': '버터와 설탕을 크림화합니다'},
          {'step': 2, 'description': '계란을 넣고 잘 섞습니다'},
          {'step': 3, 'description': '밀가루를 넣고 반죽합니다'},
          {'step': 4, 'description': '초콜릿칩을 넣고 섞습니다'},
          {'step': 5, 'description': '180도에서 15분간 굽습니다'},
        ],
        totalIngredientWeight: 431.0, // 대략적인 총 무게
      ),
    );
  }

  // Getter들
  String get id => recipe.id?.toString() ?? '';
  String get name => recipe.title;
  List<Map<String, dynamic>> get ingredients => recipe.ingredients;
  int get originalYield => recipe.baseServings;
  double get originalTotalWeight => recipe.totalIngredientWeight ?? 0.0;
  double get totalIngredientWeight => recipe.totalIngredientWeight ?? 0.0;

  /// 개수 기반으로 레시피 스케일링
  PracticalRecipe scaleByCount(int targetCount) {
    if (targetCount <= 0) {
      throw ArgumentError('목표 개수는 1개 이상이어야 합니다');
    }

    final scaleFactor = targetCount / originalYield;

    // 재료들을 스케일링
    final scaledIngredients = ingredients.map((ingredient) {
      final amount = ingredient['amount'] as double;
      return {
        ...ingredient,
        'amount': amount * scaleFactor,
      };
    }).toList();

    final scaledRecipe = Recipe(
      id: recipe.id,
      title: recipe.title,
      category: recipe.category,
      baseServings: targetCount,
      isBaking: recipe.isBaking,
      ingredients: scaledIngredients,
      instructions: recipe.instructions,
      imagePath: recipe.imagePath,
      totalIngredientWeight:
          (recipe.totalIngredientWeight ?? 0.0) * scaleFactor,
      parentId: recipe.parentId,
    );

    return PracticalRecipe(recipe: scaledRecipe);
  }

  /// 무게 기반으로 레시피 스케일링
  PracticalRecipe scaleByWeight(double targetWeight) {
    if (targetWeight <= 0) {
      throw ArgumentError('목표 무게는 0보다 커야 합니다');
    }

    final scaleFactor = targetWeight / originalTotalWeight;

    // 재료들을 스케일링
    final scaledIngredients = ingredients.map((ingredient) {
      final amount = ingredient['amount'] as double;
      return {
        ...ingredient,
        'amount': amount * scaleFactor,
      };
    }).toList();

    final scaledRecipe = Recipe(
      id: recipe.id,
      title: recipe.title,
      category: recipe.category,
      baseServings: (recipe.baseServings * scaleFactor).round(),
      isBaking: recipe.isBaking,
      ingredients: scaledIngredients,
      instructions: recipe.instructions,
      imagePath: recipe.imagePath,
      totalIngredientWeight: targetWeight,
      parentId: recipe.parentId,
    );

    return PracticalRecipe(recipe: scaledRecipe);
  }
}

/// 분할 계산 결과를 담는 클래스
class DivisionResult {
  final PracticalRecipe originalRecipe;
  final PracticalRecipe scaledRecipe;
  final Map<String, double> remainder;
  final double scaleFactor;
  final String calculationType;
  final DateTime calculatedAt;

  const DivisionResult({
    required this.originalRecipe,
    required this.scaledRecipe,
    required this.remainder,
    required this.scaleFactor,
    required this.calculationType,
    required this.calculatedAt,
  });

  // 편의 getter들
  int get originalCount => originalRecipe.originalYield;
  int get targetCount => scaledRecipe.originalYield;
  double get scalingMultiplier => scaleFactor;
  double get totalWeight => scaledRecipe.originalTotalWeight;
  double get weightPerPiece => totalWeight / targetCount;
  List<Map<String, dynamic>> get adjustedIngredients =>
      scaledRecipe.ingredients;
  Map<String, double> get remainingIngredients => remainder;
  double get costEfficiencyScore => 8.5; // 임시값
  List<String> get suggestions => ['재료를 정확히 계량하세요', '오븐을 미리 예열하세요'];
}
