/// 실온 발효 템플릿 시스템
/// 다양한 실온 발효 방식에 대한 사전 정의된 시나리오를 제공
library;

import '../models/fermentation_scenario_v2.dart';
import '../models/environmental_conditions.dart';

/// 실온 발효 템플릿 관리자
class RoomTemperatureFermentationTemplates {
  
  /// 커스텀 가이드 생성 (새로운 권장 방식)
  static Map<String, dynamic> getCustomGuide({
    required RecipeAnalysis recipe,
    required EnvironmentalConditions env,
    Duration? availableTime,
    bool hasRefrigerator = true,
    bool hasFreezer = true,
  }) {
    final recommendedMethod = recommendMethod(
      recipe: recipe,
      env: env,
      availableTime: availableTime,
      hasRefrigerator: hasRefrigerator,
      hasFreezer: hasFreezer,
    );

    return {
      'recommendedMethod': recommendedMethod.name,
      'explanation': _getMethodExplanation(recommendedMethod),
      'customInstructions': _getCustomInstructions(recommendedMethod, recipe, env),
      'tips': _getMethodTips(recommendedMethod),
      'warnings': _getMethodWarnings(recommendedMethod),
      'alternatives': _getAlternativeMethods(recommendedMethod),
      // UI 호환성을 위한 추가 키들
      'environmentalFactors': {
        'temperature': {
          'current': env.temperature,
          'optimal': '25-28°C',
          'impact': env.temperature > 30 ? '온도가 높아 발효가 빨라질 수 있습니다' : '적절한 온도입니다',
          'suggestion': env.temperature > 30 ? '서늘한 곳으로 이동하세요' : '현재 온도를 유지하세요',
          'status': env.temperature > 30 ? 'warning' : 'good',
        },
        'humidity': {
          'current': env.humidity,
          'optimal': '60-75%',
          'impact': env.humidity < 50 ? '습도가 낮아 반죽이 마를 수 있습니다' : '적절한 습도입니다',
          'suggestion': env.humidity < 50 ? '덮개를 사용하세요' : '현재 습도를 유지하세요',
          'status': env.humidity < 50 ? 'warning' : 'good',
        },
      },
      'recipeFactors': {
        'yeast': {
          'percentage': recipe.yeastPercentage,
          'impact': recipe.yeastPercentage > 2 ? '이스트가 많아 발효가 빨라집니다' : '적절한 이스트 양입니다',
          'suggestion': recipe.yeastPercentage > 2 ? '발효 시간을 단축하세요' : '표준 시간을 따르세요',
        },
        'sugar': {
          'percentage': recipe.sugarPercentage,
          'impact': recipe.sugarPercentage > 15 ? '설탕이 많아 발효가 활발합니다' : '적절한 설탕 양입니다',
          'suggestion': recipe.sugarPercentage > 15 ? '온도를 낮추는 것을 고려하세요' : '표준 온도를 사용하세요',
        },
      },
      'recommendations': [
        {
          'title': '추천 발효 방식',
          'content': _getMethodExplanation(recommendedMethod),
          'priority': 'high',
        },
      ],
      'quickStartTips': _getMethodTips(recommendedMethod),
    };
  }

  /// 시나리오 추천 시스템
  static FermentationMethodV2 recommendMethod({
    required RecipeAnalysis recipe,
    required EnvironmentalConditions env,
    Duration? availableTime,
    bool hasRefrigerator = true,
    bool hasFreezer = true,
  }) {
    // 시간 제약이 있는 경우
    if (availableTime != null && availableTime.inHours < 6) {
      return FermentationMethodV2.normal;
    }

    // 고당분 레시피는 냉장 발효 추천
    if (recipe.sugarPercentage > 15 && hasRefrigerator) {
      return FermentationMethodV2.coldRetardation;
    }

    // 저이스트 레시피는 냉장 발효 추천
    if (recipe.yeastPercentage < 1.0 && hasRefrigerator) {
      return FermentationMethodV2.coldRetardation;
    }

    // 환경이 너무 더운 경우 냉장 발효 추천
    if (env.temperature > 30 && hasRefrigerator) {
      return FermentationMethodV2.coldRetardation;
    }

    // 계획적 베이킹을 위한 냉동 추천
    if (availableTime != null && availableTime.inDays >= 1 && hasFreezer) {
      return FermentationMethodV2.freezerOvernight;
    }

    // 기본값
    return FermentationMethodV2.normal;
  }

  // Private helper methods
  static String _getMethodExplanation(FermentationMethodV2 method) {
    switch (method) {
      case FermentationMethodV2.normal:
        return '실온에서 진행하는 표준적인 발효 방식입니다. 가장 일반적이고 안정적인 방법으로, 4-5시간 내에 완성됩니다.';
      case FermentationMethodV2.coldRetardation:
        return '냉장고에서 저온 발효하여 풍미를 발달시키는 방식입니다. 시간은 오래 걸리지만 깊은 맛과 향을 얻을 수 있습니다.';
      case FermentationMethodV2.freezerOvernight:
        return '냉동 보관 후 해동하여 사용하는 편리한 방식입니다. 최대 1주일까지 보관 가능하여 계획적인 베이킹에 적합합니다.';
      default:
        return '커스텀 발효 방식입니다.';
    }
  }

  static List<String> _getCustomInstructions(
    FermentationMethodV2 method,
    RecipeAnalysis recipe,
    EnvironmentalConditions env,
  ) {
    switch (method) {
      case FermentationMethodV2.normal:
        return [
          '반죽을 볼에 넣고 덮개를 덮으세요',
          '실온(${env.temperature.toStringAsFixed(1)}°C)에서 1.5-2시간 발효하세요',
          '30분마다 폴딩하여 글루텐을 강화하세요',
          '반죽이 1.5-2배 부풀면 분할하세요',
          '15분 휴지 후 성형하세요',
          '최종 발효 45-60분 후 굽기 시작하세요',
        ];
      case FermentationMethodV2.coldRetardation:
        return [
          '실온에서 1시간 1차 발효하세요',
          '냉장고(4°C)에서 12-24시간 저온 발효하세요',
          '사용 1시간 전에 실온에 꺼내 적응시키세요',
          '성형 후 45분 최종 발효하세요',
          '손가락 테스트로 발효 상태를 확인하세요',
        ];
      case FermentationMethodV2.freezerOvernight:
        return [
          '실온에서 45분 1차 발효하세요',
          '냉동고(-18°C)에서 최대 1주일 보관하세요',
          '사용 12시간 전에 냉장고로 이동하여 해동하세요',
          '실온에서 2시간 적응시키세요',
          '성형 후 90분 최종 발효하세요',
        ];
      default:
        return ['커스텀 발효 빌더를 사용하여 단계를 설정하세요'];
    }
  }

  static List<String> _getMethodTips(FermentationMethodV2 method) {
    switch (method) {
      case FermentationMethodV2.normal:
        return [
          '온도가 높으면 발효 시간을 단축하세요',
          '습도가 낮으면 덮개를 사용하여 마르지 않게 하세요',
          '과발효를 방지하기 위해 시간을 정확히 지키세요',
        ];
      case FermentationMethodV2.coldRetardation:
        return [
          '냉장 발효는 풍미 발달에 탁월합니다',
          '최대 3일까지 냉장 보관 가능합니다',
          '실온 적응 시간을 충분히 주세요',
        ];
      case FermentationMethodV2.freezerOvernight:
        return [
          '냉동 전에 날짜를 표시해두세요',
          '재냉동은 절대 금지입니다',
          '해동 시간을 충분히 계산하세요',
        ];
      default:
        return [];
    }
  }

  static List<String> _getMethodWarnings(FermentationMethodV2 method) {
    switch (method) {
      case FermentationMethodV2.normal:
        return [
          '35°C를 초과하면 이스트가 사멸할 수 있습니다',
          '과발효되면 반죽이 무너질 수 있습니다',
        ];
      case FermentationMethodV2.coldRetardation:
        return [
          '냉장고 온도가 너무 낮으면 발효가 멈춥니다',
          '3일을 초과하면 과발효될 수 있습니다',
        ];
      case FermentationMethodV2.freezerOvernight:
        return [
          '1주일을 초과하면 품질이 저하됩니다',
          '해동 과정에서 수분이 손실될 수 있습니다',
        ];
      default:
        return [];
    }
  }

  static List<String> _getAlternativeMethods(FermentationMethodV2 currentMethod) {
    switch (currentMethod) {
      case FermentationMethodV2.normal:
        return ['냉장 저온 발효', '냉동 오버나이트'];
      case FermentationMethodV2.coldRetardation:
        return ['실온 발효', '냉동 오버나이트'];
      case FermentationMethodV2.freezerOvernight:
        return ['실온 발효', '냉장 저온 발효'];
      default:
        return ['실온 발효', '냉장 저온 발효', '냉동 오버나이트'];
    }
  }

  /// 레거시 메서드들 - 사용 중단 안내
  @Deprecated('실온 발효는 이제 커스텀 빌더를 사용하세요. getCustomGuide()를 사용하세요.')
  static FermentationScenarioV2 normalRoomFermentation({
    required RecipeAnalysis recipe,
    required EnvironmentalConditions env,
    String? customName,
  }) {
    throw UnsupportedError(
      '실온 발효 프리셋은 더 이상 지원되지 않습니다.\n'
      '커스텀 발효 빌더를 사용하여 나만의 시나리오를 만들어보세요.\n'
      'getCustomGuide() 메서드를 사용하면 맞춤형 추천을 받을 수 있습니다.'
    );
  }
  
  @Deprecated('실온 발효는 이제 커스텀 빌더를 사용하세요.')
  static FermentationScenarioV2 coldRetardation({
    required RecipeAnalysis recipe,
    required EnvironmentalConditions env,
    Duration? retardationTime,
    String? customName,
  }) {
    throw UnsupportedError(
      '실온 발효 프리셋은 더 이상 지원되지 않습니다.\n'
      '커스텀 발효 빌더를 사용하여 냉장 발효 시나리오를 만들어보세요.'
    );
  }
  
  @Deprecated('실온 발효는 이제 커스텀 빌더를 사용하세요.')
  static FermentationScenarioV2 freezerOvernight({
    required RecipeAnalysis recipe,
    required EnvironmentalConditions env,
    Duration? freezerTime,
    String? customName,
  }) {
    throw UnsupportedError(
      '실온 발효 프리셋은 더 이상 지원되지 않습니다.\n'
      '커스텀 발효 빌더를 사용하여 냉동 보관 시나리오를 만들어보세요.'
    );
  }
}