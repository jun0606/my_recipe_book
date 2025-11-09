import 'package:my_recipe_book/interfaces/analysis_module.dart';
import 'package:my_recipe_book/models/analysis_request.dart';
import 'package:my_recipe_book/models/advanced_sous_chef_models.dart'; // Recipe 모델이 필요할 수 있음
import 'package:my_recipe_book/models/ingredient.dart'; // Ingredient 모델이 필요할 수 있음

/// 영양 분석 모듈
///
/// 레시피의 영양 성분을 분석하고, 영양 정보에 기반한 추천을 제공합니다.
class NutritionalAnalysisModule extends BaseAnalysisModule {
  static const String moduleName = 'nutritional_analysis';
  static const String moduleVersion = '1.0.0';

  NutritionalAnalysisModule()
      : super(
          name: moduleName,
          version: moduleVersion,
          description: '레시피 영양 성분 분석 및 추천 모듈',
          priority: 3, // IngredientAnalysisModule 다음 우선순위
          dependencies: ['ingredient_analysis'], // 재료 분석 모듈에 의존
          category: AnalysisModuleCategory.nutrition,
          initialConfiguration: {
            'enable_nutrient_breakdown': true,
            'enable_dietary_recommendations': true,
          },
        );

  @override
  Future<void> onInitialize() async {
    // 영양 데이터베이스 로드 등 초기화 작업
  }

  @override
  Future<void> onDispose() async {
    // 리소스 정리
  }

  @override
  bool canHandle(AnalysisRequest request) {
    // 레시피와 재료가 있는 경우에만 처리 가능
    return request.recipe != null && request.ingredients.isNotEmpty;
  }

  @override
  Future<Map<String, dynamic>> analyze(AnalysisRequest request) async {
    final recipe = request.recipe;
    final ingredients = request.ingredients;
    final options = request.options;

    final results = <String, dynamic>{};

    try {
      // 1. 영양 성분 분석
      if ((getConfiguration<bool>('enable_nutrient_breakdown', true) ?? false)) {
        results['nutrient_breakdown'] = _calculateNutrientBreakdown(recipe, ingredients);
      }

      // 2. 식단 추천
      if ((getConfiguration<bool>('enable_dietary_recommendations', true) ?? false)) {
        results['dietary_recommendations'] = _generateDietaryRecommendations(recipe, ingredients);
      }
    } catch (e) {
      throw AnalysisProcessingException(
        '영양 분석 중 오류가 발생했습니다: $e',
        moduleName: name,
        cause: e is Exception ? e : Exception(e.toString()),
      );
    }

    return results;
  }

  /// 영양 성분 분석
  Map<String, dynamic> _calculateNutrientBreakdown(Recipe recipe, List<Ingredient> ingredients) {
    // 실제 영양 성분 계산 로직 (플레이스홀더)
    double totalCalories = 0;
    double totalProtein = 0;
    double totalFat = 0;
    double totalCarbs = 0;

    for (final ingredient in ingredients) {
      // 각 재료의 영양 정보에 따라 계산
      // 예시: 밀가루 100g당 364kcal, 단백질 10g, 지방 1g, 탄수화물 76g
      if (ingredient.name.contains('밀가루')) {
        totalCalories += (ingredient.amount / 100) * 364;
        totalProtein += (ingredient.amount / 100) * 10;
        totalFat += (ingredient.amount / 100) * 1;
        totalCarbs += (ingredient.amount / 100) * 76;
      }
      // 다른 재료에 대한 영양 정보 추가
    }

    return {
      'total_calories': totalCalories,
      'total_protein': totalProtein,
      'total_fat': totalFat,
      'total_carbs': totalCarbs,
    };
  }

  /// 식단 추천
  List<String> _generateDietaryRecommendations(Recipe recipe, List<Ingredient> ingredients) {
    final recommendations = <String>[];
    final nutrientBreakdown = _calculateNutrientBreakdown(recipe, ingredients);

    if (nutrientBreakdown['total_calories'] > 2000) {
      recommendations.add('칼로리가 높습니다. 섭취량 조절을 권장합니다.');
    }
    if (nutrientBreakdown['total_protein'] < 50) {
      recommendations.add('단백질 함량이 낮습니다. 단백질 보충을 고려하세요.');
    }
    return recommendations;
  }

  @override
  int estimateProcessingTime(AnalysisRequest request) {
    final baseTime = 500; // 0.5초
    final ingredientTime = request.ingredients.length * 20; // 재료당 20ms
    return baseTime + ingredientTime;
  }

  @override
  int estimateMemoryUsage(AnalysisRequest request) {
    final baseMemory = 5 * 1024 * 1024; // 5MB
    final ingredientMemory = request.ingredients.length * 1024; // 1KB per item
    return baseMemory + ingredientMemory;
  }

  @override
  List<String> getSupportedFeatures() {
    return [
      'nutrient_breakdown',
      'dietary_recommendations',
    ];
  }

  @override
  List<String> getRequiredPermissions() {
    return []; // 특별한 권한 불필요
  }

  @override
  Map<String, dynamic> getConfigurationSchema() {
    return {
      'enable_nutrient_breakdown': {
        'type': 'boolean',
        'default': true,
        'description': '영양 성분 분석 활성화',
      },
      'enable_dietary_recommendations': {
        'type': 'boolean',
        'default': true,
        'description': '식단 추천 활성화',
      },
    };
  }
}