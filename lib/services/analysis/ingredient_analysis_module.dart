import 'package:my_recipe_book/interfaces/analysis_module.dart';
import 'package:my_recipe_book/models/analysis_request.dart';
import 'package:my_recipe_book/models/advanced_sous_chef_models.dart'; // Recipe 모델이 필요할 수 있음
import 'package:my_recipe_book/models/ingredient.dart'; // Ingredient 모델이 필요할 수 있음

/// 재료 분석 모듈
///
/// 재료의 특성, 품질, 상호작용 등을 분석합니다.
class IngredientAnalysisModule extends BaseAnalysisModule {
  static const String moduleName = 'ingredient_analysis';
  static const String moduleVersion = '1.0.0';

  IngredientAnalysisModule()
      : super(
          name: moduleName,
          version: moduleVersion,
          description: '재료 특성 및 상호작용 분석 모듈',
          priority: 2, // RecipeAnalysisModule 다음 우선순위
          dependencies: [], // 초기 의존성 없음
          category: AnalysisModuleCategory.ingredient,
          initialConfiguration: {
            'enable_quality_assessment': true,
            'enable_substitution_suggestion': true,
            'enable_interaction_analysis': true,
          },
        );

  @override
  Future<void> onInitialize() async {
    // 재료 분석에 필요한 리소스 초기화
  }

  @override
  Future<void> onDispose() async {
    // 리소스 정리
  }

  @override
  bool canHandle(AnalysisRequest request) {
    // 재료 목록이 비어있지 않은 경우에만 처리 가능
    return request.ingredients.isNotEmpty;
  }

  @override
  Future<Map<String, dynamic>> analyze(AnalysisRequest request) async {
    final ingredients = request.ingredients;
    final options = request.options;

    final results = <String, dynamic>{};

    try {
      // 1. 재료 품질 평가
      if ((getConfiguration<bool>('enable_quality_assessment', true) ?? false)) {
        results['ingredient_quality'] = _analyzeIngredientQuality(ingredients);
      }

      // 2. 대체 재료 제안
      if ((getConfiguration<bool>('enable_substitution_suggestion', true) ?? false)) {
        results['substitution_suggestions'] = _suggestSubstitutes(ingredients);
      }

      // 3. 재료 간 상호작용 분석
      if ((getConfiguration<bool>('enable_interaction_analysis', true) ?? false)) {
        results['ingredient_interactions'] = _analyzeInteractions(ingredients);
      }

      // TODO: 영양소 분석은 NutritionalAnalysisModule에서 담당하도록 명확히 분리

    } catch (e) {
      throw AnalysisProcessingException(
        '재료 분석 중 오류가 발생했습니다: $e',
        moduleName: name,
        cause: e is Exception ? e : Exception(e.toString()),
      );
    }

    return results;
  }

  /// 재료 품질 평가
  Map<String, dynamic> _analyzeIngredientQuality(List<Ingredient> ingredients) {
    final qualityResults = <String, dynamic>{};
    for (final ingredient in ingredients) {
      // 예시: 신선도, 유기농 여부, 등급 등을 가정하여 평가
      String qualityLevel = '보통';
      if (ingredient.name.contains('유기농')) {
        qualityLevel = '높음';
      } else if (ingredient.name.contains('냉동')) {
        qualityLevel = '낮음';
      }
      qualityResults[ingredient.name] = {'quality_level': qualityLevel};
    }
    return qualityResults;
  }

  /// 대체 재료 제안
  List<Map<String, dynamic>> _suggestSubstitutes(List<Ingredient> ingredients) {
    final suggestions = <Map<String, dynamic>>[];
    for (final ingredient in ingredients) {
      // 예시: 특정 재료에 대한 대체 재료 제안
      if (ingredient.name.contains('버터')) {
        suggestions.add({
          'original': ingredient.name,
          'substitute': '마가린 또는 식물성 오일',
          'notes': '풍미와 질감에 차이가 있을 수 있습니다.',
        });
      }
    }
    return suggestions;
  }

  /// 재료 간 상호작용 분석
  List<Map<String, dynamic>> _analyzeInteractions(List<Ingredient> ingredients) {
    final interactions = <Map<String, dynamic>>[];
    // 예시: 베이킹 소다와 산성 재료의 반응, 특정 향신료 조합 등
    final ingredientNames = ingredients.map((i) => i.name.toLowerCase()).toList();

    if (ingredientNames.contains('베이킹 소다') && (ingredientNames.contains('레몬즙') || ingredientNames.contains('식초'))) {
      interactions.add({
        'ingredients': ['베이킹 소다', '산성 재료'],
        'interaction_type': '화학 반응 (팽창)',
        'notes': '반죽을 부풀리는 데 도움을 줍니다.',
      });
    }
    return interactions;
  }

  @override
  int estimateProcessingTime(AnalysisRequest request) {
    final baseTime = 300; // 0.3초
    final ingredientTime = request.ingredients.length * 15; // 재료당 15ms
    return baseTime + ingredientTime;
  }

  @override
  int estimateMemoryUsage(AnalysisRequest request) {
    final baseMemory = 3 * 1024 * 1024; // 3MB
    final ingredientMemory = request.ingredients.length * 512; // 0.5KB per item
    return baseMemory + ingredientMemory;
  }

  @override
  List<String> getSupportedFeatures() {
    return [
      'ingredient_quality_assessment',
      'substitution_suggestion',
      'ingredient_interaction_analysis',
    ];
  }

  @override
  List<String> getRequiredPermissions() {
    return []; // 특별한 권한 불필요
  }

  @override
  Map<String, dynamic> getConfigurationSchema() {
    return {
      'enable_quality_assessment': {
        'type': 'boolean',
        'default': true,
        'description': '재료 품질 평가 활성화',
      },
      'enable_substitution_suggestion': {
        'type': 'boolean',
        'default': true,
        'description': '대체 재료 제안 활성화',
      },
      'enable_interaction_analysis': {
        'type': 'boolean',
        'default': true,
        'description': '재료 간 상호작용 분석 활성화',
      },
    };
  }
}