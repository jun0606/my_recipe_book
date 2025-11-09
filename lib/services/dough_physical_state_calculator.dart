import '../models/dough_physical_state.dart';
import '../models/recipe.dart';
import '../models/ingredient.dart';
import 'ingredient_analyzer.dart';

/// 반죽 물리화학적 상태 계산 서비스
class DoughPhysicalStateCalculator {
  /// 글루텐 강도 지수 계산
  /// 공식: (유효 밀가루 단백질% × 1.2) + (소금% × 0.7) - (지방% × 0.5) - (설탕% × 0.3)
  static double calculateGlutenStrengthIndex({
    required double flourProteinPercentage,
    required double saltPercentage,
    required double fatPercentage,
    required double sugarPercentage,
  }) {
    final index = (flourProteinPercentage * 1.2) +
        (saltPercentage * 0.7) -
        (fatPercentage * 0.5) -
        (sugarPercentage * 0.3);

    // 지수를 0.0 ~ 10.0 범위로 제한
    return index.clamp(0.0, 10.0);
  }

  /// 레시피로부터 반죽 물리화학적 상태 분석
  static DoughPhysicalState analyzeRecipe(Recipe recipe) {
    final ratios = _extractIngredientRatios(recipe);

    final glutenStrengthIndex = calculateGlutenStrengthIndex(
      flourProteinPercentage: ratios.flourProteinPercentage,
      saltPercentage: ratios.saltPercentage,
      fatPercentage: ratios.fatPercentage,
      sugarPercentage: ratios.sugarPercentage,
    );

    final quality = DoughQuality.fromGlutenStrengthIndex(glutenStrengthIndex);
    final suggestions =
        _generateAdjustmentSuggestions(ratios, glutenStrengthIndex);

    return DoughPhysicalState(
      glutenStrengthIndex: glutenStrengthIndex,
      quality: quality,
      suggestions: suggestions,
      ingredientRatios: ratios,
      calculatedAt: DateTime.now(),
    );
  }

  /// 레시피에서 재료 비율 추출
  static DoughIngredientRatios _extractIngredientRatios(Recipe recipe) {
    double flourAmount = 0.0;
    double saltAmount = 0.0;
    double fatAmount = 0.0;
    double sugarAmount = 0.0;
    double waterAmount = 0.0;

    // 재료별 양 계산
    for (final ingredient in recipe.ingredients) {
      final amount = ingredient.amount;
      final name = ingredient.name.toLowerCase();

      if (IngredientAnalyzer.isFlour(name)) {
        flourAmount += amount;
      } else if (_isSalt(name)) {
        saltAmount += amount;
      } else if (_isFat(name)) {
        fatAmount += amount;
      } else if (_isSugar(name)) {
        sugarAmount += amount;
      } else if (_isWater(name)) {
        waterAmount += amount;
      }
    }

    // 밀가루 기준 비율 계산
    if (flourAmount == 0) {
      return const DoughIngredientRatios(
        flourProteinPercentage: 0.0,
        saltPercentage: 0.0,
        fatPercentage: 0.0,
        sugarPercentage: 0.0,
        hydrationPercentage: 0.0,
      );
    }

    return DoughIngredientRatios(
      flourProteinPercentage:
          _estimateFlourProteinPercentage(recipe.ingredients),
      saltPercentage: (saltAmount / flourAmount) * 100,
      fatPercentage: (fatAmount / flourAmount) * 100,
      sugarPercentage: (sugarAmount / flourAmount) * 100,
      hydrationPercentage: (waterAmount / flourAmount) * 100,
    );
  }

  /// 밀가루 단백질 비율 추정
  static double _estimateFlourProteinPercentage(List<Ingredient> ingredients) {
    // 기본값: 중력분 기준 11%
    double proteinPercentage = 11.0;

    for (final ingredient in ingredients) {
      final name = ingredient.name.toLowerCase();

      if (name.contains('강력분') || name.contains('bread flour')) {
        proteinPercentage = 13.0; // 강력분
      } else if (name.contains('박력분') || name.contains('cake flour')) {
        proteinPercentage = 8.5; // 박력분
      } else if (name.contains('중력분') || name.contains('all purpose')) {
        proteinPercentage = 11.0; // 중력분
      } else if (name.contains('통밀') || name.contains('whole wheat')) {
        proteinPercentage = 12.0; // 통밀가루
      }
    }

    return proteinPercentage;
  }

  /// 조정 제안 생성
  static List<DoughAdjustmentSuggestion> _generateAdjustmentSuggestions(
    DoughIngredientRatios ratios,
    double glutenStrengthIndex,
  ) {
    final suggestions = <DoughAdjustmentSuggestion>[];

    // 글루텐 강도가 낮은 경우
    if (glutenStrengthIndex < 4.0) {
      if (ratios.flourProteinPercentage < 11.0) {
        suggestions.add(const DoughAdjustmentSuggestion(
          type: AdjustmentType.protein,
          message: '강력분 비율을 늘려 단백질 함량을 높이세요',
          priority: 1,
          expectedEffect: '글루텐 강도 향상으로 반죽 탄성 증가',
        ));
      }

      if (ratios.saltPercentage < 1.8) {
        suggestions.add(const DoughAdjustmentSuggestion(
          type: AdjustmentType.salt,
          message: '소금을 1.8-2.2% 범위로 조정하세요',
          priority: 2,
          expectedEffect: '글루텐 네트워크 강화 및 발효 조절',
        ));
      }

      if (ratios.fatPercentage > 15.0) {
        suggestions.add(DoughAdjustmentSuggestion(
          type: AdjustmentType.fat,
          message:
              '지방 함량을 줄여보세요 (현재 ${ratios.fatPercentage.toStringAsFixed(1)}%)',
          priority: 2,
          expectedEffect: '글루텐 형성 방해 요소 감소',
        ));
      }

      if (ratios.sugarPercentage > 20.0) {
        suggestions.add(DoughAdjustmentSuggestion(
          type: AdjustmentType.sugar,
          message:
              '설탕 함량을 줄여보세요 (현재 ${ratios.sugarPercentage.toStringAsFixed(1)}%)',
          priority: 3,
          expectedEffect: '글루텐 형성 방해 요소 감소',
        ));
      }
    }

    // 글루텐 강도가 너무 높은 경우
    if (glutenStrengthIndex > 8.0) {
      suggestions.add(const DoughAdjustmentSuggestion(
        type: AdjustmentType.kneading,
        message: '반죽 시간을 줄이거나 오토리제 방법을 사용하세요',
        priority: 1,
        expectedEffect: '과도한 글루텐 발달 방지',
      ));

      if (ratios.hydrationPercentage < 60.0) {
        suggestions.add(const DoughAdjustmentSuggestion(
          type: AdjustmentType.hydration,
          message: '수분을 늘려 반죽을 부드럽게 만드세요',
          priority: 2,
          expectedEffect: '반죽 질감 개선 및 글루텐 완화',
        ));
      }
    }

    // 수분 관련 제안
    if (ratios.hydrationPercentage < 50.0) {
      suggestions.add(const DoughAdjustmentSuggestion(
        type: AdjustmentType.hydration,
        message: '수분이 부족합니다. 물을 더 추가하세요',
        priority: 1,
        expectedEffect: '반죽 작업성 향상 및 최종 제품 촉촉함 증가',
      ));
    } else if (ratios.hydrationPercentage > 85.0) {
      suggestions.add(const DoughAdjustmentSuggestion(
        type: AdjustmentType.hydration,
        message: '수분이 과도합니다. 밀가루를 추가하거나 물을 줄이세요',
        priority: 1,
        expectedEffect: '반죽 다루기 쉬워짐 및 구조 안정성 향상',
      ));
    }

    // 우선순위별 정렬
    suggestions.sort((a, b) => a.priority.compareTo(b.priority));

    return suggestions;
  }

  /// 밀가루 판별
  static bool _isFlour(String name) {
    return name.contains('밀가루') ||
        name.contains('flour') ||
        name.contains('강력분') ||
        name.contains('박력분') ||
        name.contains('중력분') ||
        name.contains('통밀');
  }

  /// 소금 판별
  static bool _isSalt(String name) {
    return name.contains('소금') || name.contains('salt');
  }

  /// 지방 판별
  static bool _isFat(String name) {
    return name.contains('버터') ||
        name.contains('butter') ||
        name.contains('오일') ||
        name.contains('oil') ||
        name.contains('마가린') ||
        name.contains('margarine') ||
        name.contains('쇼트닝') ||
        name.contains('shortening') ||
        name.contains('라드') ||
        name.contains('lard');
  }

  /// 설탕 판별
  static bool _isSugar(String name) {
    return name.contains('설탕') ||
        name.contains('sugar') ||
        name.contains('꿀') ||
        name.contains('honey') ||
        name.contains('시럽') ||
        name.contains('syrup') ||
        name.contains('메이플') ||
        name.contains('maple');
  }

  /// 물 판별
  static bool _isWater(String name) {
    return name.contains('물') ||
        name.contains('water') ||
        name.contains('우유') ||
        name.contains('milk') ||
        name.contains('크림') ||
        name.contains('cream');
  }
}
