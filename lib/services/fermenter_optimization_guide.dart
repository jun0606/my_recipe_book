/// 발효기 최적화 가이드 서비스
/// 레시피 분석을 통해 과학적 근거 기반의 최적 발효기 설정을 제공

import '../models/fermentation_scenario_v2.dart';
import '../models/sous_chef_models.dart';

/// 발효기 최적 설정 데이터 클래스
class FermenterOptimalSettings {
  final double temperature;
  final double humidity;
  final Duration duration;
  final Map<String, String> explanations;
  final List<String> warnings;
  final List<String> tips;

  const FermenterOptimalSettings({
    required this.temperature,
    required this.humidity,
    required this.duration,
    required this.explanations,
    required this.warnings,
    required this.tips,
  });
}

/// 냉동 보관 설정 데이터 클래스
class FreezerStorageSettings {
  final Duration recommendedDuration;
  final Duration maxStorageDuration;
  final List<String> packagingInstructions;
  final List<String> thawingInstructions;
  final String qualityImpact;
  final double suitabilityScore;

  const FreezerStorageSettings({
    required this.recommendedDuration,
    required this.maxStorageDuration,
    required this.packagingInstructions,
    required this.thawingInstructions,
    required this.qualityImpact,
    required this.suitabilityScore,
  });
}

class FermenterOptimizationGuide {
  /// 발효 단계별 최적 설정 계산
  static FermenterOptimalSettings calculateOptimalSettings({
    required RecipeAnalysis recipe,
    required FermentationStageType stageType,
  }) {
    switch (stageType) {
      case FermentationStageType.primary:
        return _calculatePrimaryFermentationSettings(recipe);
      case FermentationStageType.finalProofing:
        return _calculateFinalFermentationSettings(recipe);
      case FermentationStageType.storage:
        return _calculateStorageSettings(recipe);
      case FermentationStageType.rest:
        return _calculateRestSettings(recipe);
      default:
        return _calculatePrimaryFermentationSettings(recipe);
    }
  }

  /// 1차 발효 최적 설정
  static FermenterOptimalSettings _calculatePrimaryFermentationSettings(RecipeAnalysis recipe) {
    // 기본 설정값
    double baseTemp = 28.0;
    double baseHumidity = 75.0;
    int baseDurationMinutes = 60;

    // 이스트 타입별 조정
    if (recipe.yeastType == YeastType.dry) {
      baseTemp += 2.0; // 건조 이스트는 약간 높은 온도
      baseDurationMinutes += 15;
    } else if (recipe.yeastType == YeastType.fresh) {
      baseTemp -= 1.0; // 생이스트는 약간 낮은 온도
      baseDurationMinutes -= 10;
    }

    // 이스트 양에 따른 조정
    final yeastRatio = recipe.yeastAmount / recipe.flourAmount;
    if (yeastRatio > 0.015) { // 이스트 많음 (1.5% 이상)
      baseTemp -= 2.0;
      baseDurationMinutes = (baseDurationMinutes * 0.8).round();
    } else if (yeastRatio < 0.008) { // 이스트 적음 (0.8% 미만)
      baseTemp += 2.0;
      baseDurationMinutes = (baseDurationMinutes * 1.3).round();
    }

    // 당분 함량에 따른 조정
    final sugarRatio = recipe.sugarAmount / recipe.flourAmount;
    if (sugarRatio > 0.15) { // 당분 많음 (15% 이상)
      baseTemp -= 1.0; // 과발효 방지
      baseDurationMinutes = (baseDurationMinutes * 0.9).round();
    } else if (sugarRatio < 0.05) { // 당분 적음 (5% 미만)
      baseTemp += 1.0;
      baseDurationMinutes = (baseDurationMinutes * 1.1).round();
    }

    // 수분 함량에 따른 조정
    final hydrationRatio = recipe.liquidAmount / recipe.flourAmount;
    if (hydrationRatio > 0.75) { // 고수분 (75% 이상)
      baseHumidity += 5.0;
      baseDurationMinutes = (baseDurationMinutes * 1.1).round();
    } else if (hydrationRatio < 0.55) { // 저수분 (55% 미만)
      baseHumidity -= 5.0;
      baseDurationMinutes = (baseDurationMinutes * 0.9).round();
    }

    // 지방 함량에 따른 조정
    final fatRatio = recipe.fatAmount / recipe.flourAmount;
    if (fatRatio > 0.2) { // 지방 많음 (20% 이상)
      baseDurationMinutes = (baseDurationMinutes * 1.2).round();
    }

    // 설명 생성
    final explanations = <String, String>{
      '온도': '${baseTemp.toStringAsFixed(1)}°C는 이스트 활동이 가장 활발한 온도입니다. '
             '${recipe.yeastType == YeastType.dry ? '건조 이스트' : '생이스트'}의 특성과 '
             '이스트 비율(${(yeastRatio * 100).toStringAsFixed(1)}%)을 고려했습니다.',
      '습도': '${baseHumidity.toStringAsFixed(0)}%는 반죽 표면 건조를 방지하면서 '
             '과도한 습기로 인한 끈적임을 막는 최적 습도입니다. '
             '수분 함량(${(hydrationRatio * 100).toStringAsFixed(0)}%)에 맞춰 조정했습니다.',
      '시간': '${baseDurationMinutes}분은 레시피의 이스트량, 당분, 수분 비율을 종합적으로 '
             '분석하여 계산된 최적 발효 시간입니다.',
    };

    // 경고사항 생성
    final warnings = <String>[];
    if (yeastRatio > 0.02) {
      warnings.add('이스트가 많아 과발효 위험이 있습니다. 발효 상태를 자주 확인하세요.');
    }
    if (sugarRatio > 0.2) {
      warnings.add('당분이 많아 발효가 빨라질 수 있습니다. 시간을 단축할 수 있습니다.');
    }
    if (fatRatio > 0.25) {
      warnings.add('지방 함량이 높아 발효가 느려질 수 있습니다. 시간을 연장할 수 있습니다.');
    }

    // 팁 생성
    final tips = <String>[
      '발효 완료 판단: 반죽이 1.5-2배 부풀고 손가락으로 눌렀을 때 천천히 돌아오면 완료',
      '발효기 예열: 설정 온도로 5분 정도 미리 예열하면 더 정확한 발효가 가능합니다',
      '습도 조절: 물그릇을 함께 넣거나 분무기로 벽면에 물을 뿌려 습도를 높일 수 있습니다',
    ];

    if (recipe.breadType == BreadType.sourdough) {
      tips.add('사워도우는 일반 이스트보다 발효 시간이 2-3배 더 걸릴 수 있습니다');
    }

    return FermenterOptimalSettings(
      temperature: baseTemp,
      humidity: baseHumidity,
      duration: Duration(minutes: baseDurationMinutes),
      explanations: explanations,
      warnings: warnings,
      tips: tips,
    );
  }

  /// 최종 발효 최적 설정
  static FermenterOptimalSettings _calculateFinalFermentationSettings(RecipeAnalysis recipe) {
    // 기본 설정값 (1차보다 약간 낮음)
    double baseTemp = 32.0;
    double baseHumidity = 80.0;
    int baseDurationMinutes = 45;

    // 빵 타입별 조정
    switch (recipe.breadType) {
      case BreadType.white:
        baseTemp += 1.0;
        break;
      case BreadType.whole_wheat:
        baseTemp -= 1.0;
        baseDurationMinutes += 10;
        break;
      case BreadType.sourdough:
        baseTemp -= 2.0;
        baseDurationMinutes = (baseDurationMinutes * 1.5).round();
        break;
      case BreadType.enriched:
        baseTemp += 2.0;
        baseHumidity += 5.0;
        break;
      default:
        break;
    }

    // 이스트 양에 따른 조정
    final yeastRatio = recipe.yeastAmount / recipe.flourAmount;
    if (yeastRatio > 0.015) {
      baseTemp -= 1.0;
      baseDurationMinutes = (baseDurationMinutes * 0.8).round();
    } else if (yeastRatio < 0.008) {
      baseTemp += 1.0;
      baseDurationMinutes = (baseDurationMinutes * 1.2).round();
    }

    // 당분과 지방 함량 고려
    final sugarRatio = recipe.sugarAmount / recipe.flourAmount;
    final fatRatio = recipe.fatAmount / recipe.flourAmount;
    
    if (sugarRatio > 0.1 || fatRatio > 0.15) { // 리치 도우
      baseTemp += 1.0;
      baseHumidity += 5.0;
      baseDurationMinutes = (baseDurationMinutes * 1.1).round();
    }

    final explanations = <String, String>{
      '온도': '${baseTemp.toStringAsFixed(1)}°C는 최종 발효에 최적화된 온도입니다. '
             '1차 발효보다 약간 높여 표면 발효를 촉진하고 좋은 크러스트를 만듭니다.',
      '습도': '${baseHumidity.toStringAsFixed(0)}%는 반죽 표면의 유연성을 유지하여 '
             '오븐 스프링을 극대화하는 습도입니다.',
      '시간': '${baseDurationMinutes}분은 ${recipe.breadType.toString().split('.').last} 빵의 '
             '특성을 고려한 최적 최종 발효 시간입니다.',
    };

    final warnings = <String>[];
    if (recipe.breadType == BreadType.enriched) {
      warnings.add('리치 도우는 과발효되기 쉽습니다. 발효 상태를 자주 확인하세요.');
    }
    if (sugarRatio > 0.15) {
      warnings.add('당분이 많아 표면이 빨리 갈색이 될 수 있습니다.');
    }

    final tips = <String>[
      '최종 발효 완료 판단: 손가락으로 살짝 눌렀을 때 천천히 돌아오면 완료',
      '오븐 예열: 최종 발효 80% 시점에 오븐을 예열하기 시작하세요',
      '표면 처리: 달걀물이나 물을 발라 윤기와 색을 낼 수 있습니다',
    ];

    return FermenterOptimalSettings(
      temperature: baseTemp,
      humidity: baseHumidity,
      duration: Duration(minutes: baseDurationMinutes),
      explanations: explanations,
      warnings: warnings,
      tips: tips,
    );
  }

  /// 보관 설정
  static FermenterOptimalSettings _calculateStorageSettings(RecipeAnalysis recipe) {
    // 냉장 보관 기본 설정
    double baseTemp = 4.0;
    double baseHumidity = 85.0;
    int baseDurationHours = 12;

    // 빵 타입별 조정
    if (recipe.breadType == BreadType.sourdough) {
      baseDurationHours = 24; // 사워도우는 더 긴 저온 발효 가능
    }

    final explanations = <String, String>{
      '온도': '${baseTemp.toStringAsFixed(1)}°C는 이스트 활동을 크게 늦춰 천천히 발효시키는 온도입니다.',
      '습도': '${baseHumidity.toStringAsFixed(0)}%는 냉장 환경에서 반죽 건조를 방지하는 습도입니다.',
      '시간': '${baseDurationHours}시간 동안 저온 발효하면 풍미가 깊어집니다.',
    };

    final warnings = <String>[
      '냉장 보관 후에는 실온에서 1시간 정도 적응시킨 후 최종 발효를 진행하세요.',
      '밀폐 용기나 랩으로 잘 포장하여 건조를 방지하세요.',
    ];

    final tips = <String>[
      '저온 발효는 풍미를 향상시키고 소화를 돕습니다',
      '최대 3일까지 냉장 보관 가능하지만 2일 이내가 최적입니다',
      '사용 전 실온 적응 시간을 충분히 주세요',
    ];

    return FermenterOptimalSettings(
      temperature: baseTemp,
      humidity: baseHumidity,
      duration: Duration(hours: baseDurationHours),
      explanations: explanations,
      warnings: warnings,
      tips: tips,
    );
  }

  /// 휴지 설정
  static FermenterOptimalSettings _calculateRestSettings(RecipeAnalysis recipe) {
    // 실온 휴지 기본 설정
    double baseTemp = 25.0;
    double baseHumidity = 70.0;
    int baseDurationMinutes = 20;

    // 글루텐 함량에 따른 조정
    if (recipe.breadType == BreadType.whole_wheat) {
      baseDurationMinutes = 30; // 통밀은 더 긴 휴지 필요
    }

    final explanations = <String, String>{
      '온도': '${baseTemp.toStringAsFixed(1)}°C는 글루텐 이완에 적합한 실온입니다.',
      '습도': '${baseHumidity.toStringAsFixed(0)}%는 반죽 표면 건조를 방지하는 습도입니다.',
      '시간': '${baseDurationMinutes}분은 글루텐이 충분히 이완되는 시간입니다.',
    };

    final warnings = <String>[
      '휴지 중에는 반드시 덮개를 덮어 건조를 방지하세요.',
    ];

    final tips = <String>[
      '휴지 후 반죽이 부드러워지고 성형하기 쉬워집니다',
      '젖은 수건이나 랩으로 덮어 습도를 유지하세요',
    ];

    return FermenterOptimalSettings(
      temperature: baseTemp,
      humidity: baseHumidity,
      duration: Duration(minutes: baseDurationMinutes),
      explanations: explanations,
      warnings: warnings,
      tips: tips,
    );
  }

  /// 냉동 보관 설정 계산
  static FreezerStorageSettings calculateFreezerSettings({
    required RecipeAnalysis recipe,
  }) {
    // 기본 냉동 보관 설정
    Duration recommendedDuration = const Duration(days: 7);
    Duration maxStorageDuration = const Duration(days: 30);
    double suitabilityScore = 0.8;
    String qualityImpact = '약간의 질감 변화';

    // 빵 타입별 적합성 조정
    switch (recipe.breadType) {
      case BreadType.white:
      case BreadType.enriched:
        suitabilityScore = 0.9;
        qualityImpact = '최소한의 질감 변화';
        break;
      case BreadType.whole_wheat:
        suitabilityScore = 0.7;
        qualityImpact = '약간의 질감 변화, 해동 후 수분 보충 권장';
        break;
      case BreadType.sourdough:
        suitabilityScore = 0.6;
        qualityImpact = '산미와 질감에 변화 있음';
        recommendedDuration = const Duration(days: 5);
        break;
      default:
        break;
    }

    // 수분 함량에 따른 조정
    final hydrationRatio = recipe.liquidAmount / recipe.flourAmount;
    if (hydrationRatio > 0.7) {
      suitabilityScore -= 0.1;
      qualityImpact += ', 고수분으로 인한 얼음 결정 형성 가능';
    }

    // 지방 함량에 따른 조정
    final fatRatio = recipe.fatAmount / recipe.flourAmount;
    if (fatRatio > 0.2) {
      suitabilityScore += 0.1;
      qualityImpact = '지방 함량이 높아 냉동 보관에 적합';
    }

    final packagingInstructions = <String>[
      '반죽을 개별 포장하여 사용량만큼 나누어 냉동',
      '공기를 최대한 제거하고 밀폐 포장',
      '냉동 날짜와 레시피명을 라벨에 기록',
      '급속 냉동이 가능하면 -20°C 이하에서 빠르게 냉동',
    ];

    final thawingInstructions = <String>[
      '사용 12시간 전에 냉장고로 이동하여 천천히 해동',
      '완전 해동 후 실온에서 30분-1시간 적응',
      '해동된 반죽은 재냉동하지 말고 당일 사용',
      '필요시 따뜻한 곳에서 추가 발효 진행',
    ];

    return FreezerStorageSettings(
      recommendedDuration: recommendedDuration,
      maxStorageDuration: maxStorageDuration,
      packagingInstructions: packagingInstructions,
      thawingInstructions: thawingInstructions,
      qualityImpact: qualityImpact,
      suitabilityScore: suitabilityScore,
    );
  }

  /// 발효기 설정 검증
  static Map<String, dynamic> validateSettings({
    required double temperature,
    required double humidity,
    required Duration duration,
    required FermentationStageType stageType,
  }) {
    final issues = <String>[];
    final suggestions = <String>[];

    // 온도 검증
    if (temperature < 20) {
      issues.add('온도가 너무 낮습니다 (${temperature.toStringAsFixed(1)}°C)');
      suggestions.add('최소 20°C 이상으로 설정하세요');
    } else if (temperature > 40) {
      issues.add('온도가 너무 높습니다 (${temperature.toStringAsFixed(1)}°C)');
      suggestions.add('40°C 이하로 설정하세요. 이스트가 죽을 수 있습니다');
    }

    // 습도 검증
    if (humidity < 60) {
      issues.add('습도가 너무 낮습니다 (${humidity.toStringAsFixed(0)}%)');
      suggestions.add('반죽 표면이 건조할 수 있습니다. 70% 이상 권장');
    } else if (humidity > 90) {
      issues.add('습도가 너무 높습니다 (${humidity.toStringAsFixed(0)}%)');
      suggestions.add('곰팡이 위험이 있습니다. 85% 이하 권장');
    }

    // 시간 검증
    final maxDuration = stageType == FermentationStageType.primary 
        ? const Duration(hours: 4)
        : const Duration(hours: 3);
    
    if (duration > maxDuration) {
      issues.add('발효 시간이 너무 깁니다 (${_formatDuration(duration)})');
      suggestions.add('과발효 위험이 있습니다. ${_formatDuration(maxDuration)} 이하 권장');
    }

    return {
      'isValid': issues.isEmpty,
      'issues': issues,
      'suggestions': suggestions,
    };
  }

  /// 환경 조건에 따른 발효기 설정 보정
  static FermenterOptimalSettings adjustForEnvironment({
    required FermenterOptimalSettings baseSettings,
    required double roomTemperature,
    required double roomHumidity,
  }) {
    double adjustedTemp = baseSettings.temperature;
    double adjustedHumidity = baseSettings.humidity;
    Duration adjustedDuration = baseSettings.duration;

    // 실온이 높으면 발효기 온도를 약간 낮춤
    if (roomTemperature > 25) {
      adjustedTemp -= (roomTemperature - 25) * 0.3;
    } else if (roomTemperature < 20) {
      adjustedTemp += (20 - roomTemperature) * 0.2;
    }

    // 실내 습도가 높으면 발효기 습도를 약간 낮춤
    if (roomHumidity > 70) {
      adjustedHumidity -= (roomHumidity - 70) * 0.3;
    } else if (roomHumidity < 50) {
      adjustedHumidity += (50 - roomHumidity) * 0.2;
    }

    // 온도 조정에 따른 시간 보정
    final tempDiff = adjustedTemp - baseSettings.temperature;
    if (tempDiff > 0) {
      // 온도가 높아지면 시간 단축
      adjustedDuration = Duration(
        minutes: (adjustedDuration.inMinutes * (1 - tempDiff * 0.05)).round(),
      );
    } else if (tempDiff < 0) {
      // 온도가 낮아지면 시간 연장
      adjustedDuration = Duration(
        minutes: (adjustedDuration.inMinutes * (1 + (-tempDiff) * 0.08)).round(),
      );
    }

    final newExplanations = Map<String, String>.from(baseSettings.explanations);
    newExplanations['환경 보정'] = 
        '실온 ${roomTemperature.toStringAsFixed(1)}°C, 습도 ${roomHumidity.toStringAsFixed(0)}%에 맞춰 '
        '발효기 설정을 보정했습니다.';

    return FermenterOptimalSettings(
      temperature: adjustedTemp.clamp(20.0, 40.0),
      humidity: adjustedHumidity.clamp(60.0, 90.0),
      duration: adjustedDuration,
      explanations: newExplanations,
      warnings: baseSettings.warnings,
      tips: baseSettings.tips,
    );
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}시간 ${minutes}분';
    } else {
      return '${minutes}분';
    }
  }
}