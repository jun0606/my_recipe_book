import 'dart:math' as math;
import 'package:my_recipe_book/models/advanced_sous_chef_models.dart';

/// 종합 제빵 과학 통합 계산식 엔진
/// 
/// 이 클래스는 문서에서 제시된 6가지 핵심 계산식을 구현합니다:
/// I. 기본 재료 비율 최적화 공식
/// II. 반죽 물리화학적 상태 조정 공식
/// III. 환경 및 지역 변수 보정 공식
/// IV. 빵 종류별 특화 계산식
/// V. 최적 공정 제어 및 시간 예측
/// VI. 굽기 공정 최적화 모듈
class BakingScienceFormulaEngine {
  /// I. 기본 재료 비율 최적화 공식
  /// 
  /// 하이드레이션, 소금, 이스트 비율을 계산하고 최적화합니다.
  static MaterialRatioResult optimizeMaterialRatio(List<Ingredient> ingredients) {
    final flourAmount = _getFlourAmount(ingredients);
    if (flourAmount == 0) {
      throw ArgumentError('밀가루가 포함되지 않은 레시피입니다.');
    }

    // 하이드레이션(%) = (물의 양 ÷ 밀가루 양) × 100
    final waterAmount = _getWaterAmount(ingredients);
    final hydrationPercentage = (waterAmount / flourAmount) * 100;

    // 소금(%) = (소금 양 ÷ 밀가루 양) × 100 (표준: 1.8~2.2%)
    final saltAmount = _getSaltAmount(ingredients);
    final saltPercentage = (saltAmount / flourAmount) * 100;

    // 이스트(%) = (이스트 양 ÷ 밀가루 양) × 100
    final yeastAmount = _getYeastAmount(ingredients);
    final yeastPercentage = (yeastAmount / flourAmount) * 100;

    // 설탕(%) = (설탕 양 ÷ 밀가루 양) × 100
    final sugarAmount = _getSugarAmount(ingredients);
    final sugarPercentage = (sugarAmount / flourAmount) * 100;

    // 지방(%) = (지방 양 ÷ 밀가루 양) × 100
    final fatAmount = _getFatAmount(ingredients);
    final fatPercentage = (fatAmount / flourAmount) * 100;

    return MaterialRatioResult(
      flourAmount: flourAmount,
      hydrationPercentage: hydrationPercentage,
      saltPercentage: saltPercentage,
      yeastPercentage: yeastPercentage,
      sugarPercentage: sugarPercentage,
      fatPercentage: fatPercentage,
      isOptimal: _isOptimalRatio(hydrationPercentage, saltPercentage, yeastPercentage),
      recommendations: _generateRatioRecommendations(
        hydrationPercentage, 
        saltPercentage, 
        yeastPercentage,
        sugarPercentage,
        fatPercentage,
      ),
    );
  }

  /// II. 반죽 물리화학적 상태 조정 공식
  /// 
  /// 글루텐 강도 지수 = (유효 밀가루 단백질% × 1.2) + (소금% × 0.7) - (지방% × 0.5) - (설탕% × 0.3)
  static DoughPhysicalState calculateDoughState(MaterialRatioResult ratios, List<IngredientMetadata> metadata) {
    // 유효 밀가루 단백질% 계산
    final flourMeta = metadata.firstWhere(
      (meta) => meta.name.toLowerCase().contains('밀가루') || 
                meta.name.toLowerCase().contains('flour'),
      orElse: () => const IngredientMetadata(
        name: '',
        properties: {'protein': 11.0},
        effectiveValue: 11.0,
        function: '',
        qualityCorrectionFactor: 1.0,
      ),
    );

    final effectiveProtein = flourMeta.effectiveProteinPercentage;

    // 글루텐 강도 지수 계산
    final glutenStrengthIndex = (effectiveProtein * 1.2) + 
                               (ratios.saltPercentage * 0.7) - 
                               (ratios.fatPercentage * 0.5) - 
                               (ratios.sugarPercentage * 0.3);

    // 반죽 탄성 지수 계산 (글루텐 강도 기반)
    final doughElasticityIndex = _calculateDoughElasticity(glutenStrengthIndex, ratios.hydrationPercentage);

    // 발효 안정성 계수 계산
    final fermentationStabilityCoefficient = _calculateFermentationStability(
      glutenStrengthIndex, 
      ratios.saltPercentage, 
      ratios.sugarPercentage,
    );

    return DoughPhysicalState(
      glutenStrengthIndex: glutenStrengthIndex,
      doughElasticityIndex: doughElasticityIndex,
      fermentationStabilityCoefficient: fermentationStabilityCoefficient,
      optimalHydrationRange: _calculateOptimalHydrationRange(effectiveProtein),
      recommendations: _generateDoughStateRecommendations(glutenStrengthIndex, ratios),
    );
  }

  /// III. 환경 및 지역 변수 보정 공식
  /// 
  /// 온도, 습도, 고도에 따른 보정 계수를 계산합니다.
  static EnvironmentCorrection calculateEnvironmentCorrection(EnvironmentalConditions conditions) {
    // 발효 속도 온도 보정: 2^((실제 온도 - 25) / 10)
    final fermentationSpeedCorrection = math.pow(2, (conditions.temperature - 25) / 10).toDouble();

    // 습도 보정: 1 + ((실제 습도% - 65%) × 0.005)
    final humidityCorrection = 1 + ((conditions.humidity - 65) * 0.005);

    // 고도 보정: 1 + ((현재 고도(m) / 1000) × 0.02)
    final altitudeCorrection = conditions.altitude != null 
        ? 1 + ((conditions.altitude! / 1000) * 0.02)
        : 1.0;

    // 계절 보정 계수
    final seasonalCorrection = _calculateSeasonalCorrection(conditions.season);

    // 통합 환경 보정 계수
    final overallCorrection = fermentationSpeedCorrection * humidityCorrection * altitudeCorrection * seasonalCorrection;

    return EnvironmentCorrection(
      temperatureCorrection: conditions.temperatureCorrection,
      humidityCorrection: humidityCorrection,
      altitudeCorrection: altitudeCorrection,
      fermentationSpeedCorrection: fermentationSpeedCorrection,
      seasonalCorrection: seasonalCorrection,
      overallCorrection: overallCorrection,
      recommendations: _generateEnvironmentRecommendations(conditions),
    );
  }

  /// IV. 빵 종류별 특화 계산식
  /// 
  /// 빵 종류에 따른 최적 비율과 공정을 계산합니다.
  static BreadTypeOptimization optimizeForBreadType(
    BreadType breadType, 
    MaterialRatioResult ratios,
    List<IngredientMetadata> metadata,
  ) {
    switch (breadType) {
      case BreadType.sourdough:
        return _optimizeSourdoughBread(ratios, metadata);
      case BreadType.baguette:
        return _optimizeBaguette(ratios, metadata);
      case BreadType.brioche:
        return _optimizeBrioche(ratios, metadata);
      case BreadType.wholeWheat:
        return _optimizeWholeWheatBread(ratios, metadata);
      case BreadType.rye:
        return _optimizeRyeBread(ratios, metadata);
      case BreadType.ciabatta:
        return _optimizeCiabatta(ratios, metadata);
      default:
        return _optimizeBasicBread(ratios, metadata);
    }
  }

  /// V. 최적 공정 제어 및 시간 예측
  /// 
  /// 발효 시간, 믹싱 시간, 전체 공정 시간을 예측합니다.
  static ProcessTimeOptimization optimizeProcessTiming(
    MaterialRatioResult ratios,
    DoughPhysicalState doughState,
    EnvironmentCorrection environmentCorrection,
    BreadType breadType,
  ) {
    // 기본 발효 시간 계산 (분)
    final baseFermentationTime = _calculateBaseFermentationTime(breadType, ratios.yeastPercentage);
    
    // 환경 보정 적용
    final adjustedFermentationTime = baseFermentationTime / environmentCorrection.fermentationSpeedCorrection;
    
    // 믹싱 시간 계산
    final mixingTime = _calculateMixingTime(doughState.glutenStrengthIndex, ratios.hydrationPercentage);
    
    // 벌크 발효 시간
    final bulkFermentationTime = adjustedFermentationTime * 0.7;
    
    // 최종 발효 시간
    final finalFermentationTime = adjustedFermentationTime * 0.3;
    
    // 굽기 시간 예측
    final bakingTime = _calculateBakingTime(breadType, ratios.flourAmount);

    return ProcessTimeOptimization(
      mixingTime: mixingTime,
      bulkFermentationTime: bulkFermentationTime,
      finalFermentationTime: finalFermentationTime,
      bakingTime: bakingTime,
      totalTime: mixingTime + bulkFermentationTime + finalFermentationTime + bakingTime,
      fermentationStages: _generateFermentationStages(bulkFermentationTime, finalFermentationTime),
      recommendations: _generateProcessRecommendations(ratios, doughState, environmentCorrection),
    );
  }

  /// VI. 굽기 공정 최적화 모듈
  /// 
  /// 오븐 온도, 스팀, 굽기 시간을 최적화합니다.
  static BakingProcessOptimization optimizeBakingProcess(
    BreadType breadType,
    double doughWeight,
    OvenCharacteristics ovenCharacteristics,
    EnvironmentalConditions conditions,
  ) {
    // 기본 굽기 온도 설정
    final baseTemperature = _getBaseBakingTemperature(breadType);
    
    // 오븐 특성에 따른 온도 보정
    final adjustedTemperature = _adjustTemperatureForOven(baseTemperature, ovenCharacteristics);
    
    // 스팀 설정 계산
    final steamSettings = _calculateSteamSettings(breadType, doughWeight);
    
    // 굽기 단계별 온도 프로파일
    final temperatureProfile = _generateTemperatureProfile(adjustedTemperature, breadType);
    
    // 굽기 완료 판정 기준
    final doneness = _calculateDonenessIndicators(breadType, doughWeight);

    return BakingProcessOptimization(
      initialTemperature: adjustedTemperature,
      temperatureProfile: temperatureProfile,
      steamDuration: steamSettings.duration,
      steamIntensity: steamSettings.intensity,
      totalBakingTime: _calculateBakingTime(breadType, doughWeight),
      donenessIndicators: doneness,
      recommendations: _generateBakingRecommendations(breadType, ovenCharacteristics),
    );
  }

  // ========== 헬퍼 메서드들 ==========

  static double _getFlourAmount(List<Ingredient> ingredients) {
    return ingredients
        .where((ingredient) => _isFlour(ingredient.name))
        .fold(0.0, (sum, ingredient) => sum + ingredient.amount);
  }

  static double _getWaterAmount(List<Ingredient> ingredients) {
    return ingredients
        .where((ingredient) => _isWater(ingredient.name))
        .fold(0.0, (sum, ingredient) => sum + ingredient.amount);
  }

  static double _getSaltAmount(List<Ingredient> ingredients) {
    return ingredients
        .where((ingredient) => _isSalt(ingredient.name))
        .fold(0.0, (sum, ingredient) => sum + ingredient.amount);
  }

  static double _getYeastAmount(List<Ingredient> ingredients) {
    return ingredients
        .where((ingredient) => _isYeast(ingredient.name))
        .fold(0.0, (sum, ingredient) => sum + ingredient.amount);
  }

  static double _getSugarAmount(List<Ingredient> ingredients) {
    return ingredients
        .where((ingredient) => _isSugar(ingredient.name))
        .fold(0.0, (sum, ingredient) => sum + ingredient.amount);
  }

  static double _getFatAmount(List<Ingredient> ingredients) {
    return ingredients
        .where((ingredient) => _isFat(ingredient.name))
        .fold(0.0, (sum, ingredient) => sum + ingredient.amount);
  }

  static bool _isFlour(String name) {
    final lowerName = name.toLowerCase();
    return lowerName.contains('밀가루') || 
           lowerName.contains('flour') || 
           lowerName.contains('강력분') || 
           lowerName.contains('박력분') ||
           lowerName.contains('중력분');
  }

  static bool _isWater(String name) {
    final lowerName = name.toLowerCase();
    return lowerName.contains('물') || 
           lowerName.contains('water') ||
           lowerName.contains('우유') ||
           lowerName.contains('milk');
  }

  static bool _isSalt(String name) {
    final lowerName = name.toLowerCase();
    return lowerName.contains('소금') || lowerName.contains('salt');
  }

  static bool _isYeast(String name) {
    final lowerName = name.toLowerCase();
    return lowerName.contains('이스트') || 
           lowerName.contains('yeast') ||
           lowerName.contains('스타터') ||
           lowerName.contains('starter');
  }

  static bool _isSugar(String name) {
    final lowerName = name.toLowerCase();
    return lowerName.contains('설탕') || 
           lowerName.contains('sugar') ||
           lowerName.contains('꿀') ||
           lowerName.contains('honey') ||
           lowerName.contains('시럽') ||
           lowerName.contains('syrup');
  }

  static bool _isFat(String name) {
    final lowerName = name.toLowerCase();
    return lowerName.contains('버터') || 
           lowerName.contains('butter') ||
           lowerName.contains('오일') ||
           lowerName.contains('oil') ||
           lowerName.contains('마가린') ||
           lowerName.contains('margarine');
  }

  static bool _isOptimalRatio(double hydration, double salt, double yeast) {
    return hydration >= 60 && hydration <= 80 &&
           salt >= 1.8 && salt <= 2.2 &&
           yeast >= 0.5 && yeast <= 2.0;
  }

  static List<String> _generateRatioRecommendations(
    double hydration, 
    double salt, 
    double yeast,
    double sugar,
    double fat,
  ) {
    final recommendations = <String>[];

    if (hydration < 60) {
      recommendations.add('하이드레이션이 낮습니다. 물을 더 추가하여 60-80% 범위로 조정하세요.');
    } else if (hydration > 80) {
      recommendations.add('하이드레이션이 높습니다. 밀가루를 더 추가하거나 물을 줄이세요.');
    }

    if (salt < 1.8) {
      recommendations.add('소금이 부족합니다. 1.8-2.2% 범위로 조정하세요.');
    } else if (salt > 2.2) {
      recommendations.add('소금이 과다합니다. 양을 줄이세요.');
    }

    if (yeast < 0.5) {
      recommendations.add('이스트가 부족합니다. 발효 시간이 길어질 수 있습니다.');
    } else if (yeast > 2.0) {
      recommendations.add('이스트가 과다합니다. 발효가 너무 빨라질 수 있습니다.');
    }

    if (sugar > 15) {
      recommendations.add('설탕 함량이 높습니다. 발효 속도와 갈변에 주의하세요.');
    }

    if (fat > 20) {
      recommendations.add('지방 함량이 높습니다. 글루텐 형성에 영향을 줄 수 있습니다.');
    }

    return recommendations;
  }

  static double _calculateDoughElasticity(double glutenStrength, double hydration) {
    // 반죽 탄성 = 글루텐 강도 × (하이드레이션 보정 계수)
    final hydrationFactor = 1 + ((hydration - 65) * 0.01);
    return glutenStrength * hydrationFactor;
  }

  static double _calculateFermentationStability(double glutenStrength, double salt, double sugar) {
    // 발효 안정성 = 글루텐 강도 + (소금% × 2) - (설탕% × 0.5)
    return glutenStrength + (salt * 2) - (sugar * 0.5);
  }

  static Map<String, double> _calculateOptimalHydrationRange(double proteinContent) {
    // 단백질 함량에 따른 최적 하이드레이션 범위
    final baseHydration = 65.0;
    final proteinAdjustment = (proteinContent - 11) * 2;
    
    return {
      'min': baseHydration + proteinAdjustment - 5,
      'max': baseHydration + proteinAdjustment + 5,
      'optimal': baseHydration + proteinAdjustment,
    };
  }

  static List<String> _generateDoughStateRecommendations(double glutenStrength, MaterialRatioResult ratios) {
    final recommendations = <String>[];

    if (glutenStrength < 10) {
      recommendations.add('글루텐 강도가 낮습니다. 강력분 비율을 높이거나 믹싱 시간을 늘리세요.');
    } else if (glutenStrength > 20) {
      recommendations.add('글루텐 강도가 높습니다. 과도한 믹싱을 피하세요.');
    }

    if (ratios.hydrationPercentage > 75 && glutenStrength < 12) {
      recommendations.add('높은 하이드레이션에 비해 글루텐 강도가 부족합니다.');
    }

    return recommendations;
  }

  static double _calculateSeasonalCorrection(Season? season) {
    if (season == null) return 1.0;
    
    switch (season) {
      case Season.spring:
        return 1.0;
      case Season.summer:
        return 1.1; // 더운 날씨로 발효 빨라짐
      case Season.autumn:
        return 0.95;
      case Season.winter:
        return 0.9; // 추운 날씨로 발효 느려짐
    }
  }

  static List<String> _generateEnvironmentRecommendations(EnvironmentalConditions conditions) {
    final recommendations = <String>[];

    if (conditions.temperature < 20) {
      recommendations.add('온도가 낮습니다. 발효 시간을 늘리거나 따뜻한 곳에서 발효하세요.');
    } else if (conditions.temperature > 30) {
      recommendations.add('온도가 높습니다. 발효 시간을 줄이거나 시원한 곳에서 발효하세요.');
    }

    if (conditions.humidity < 50) {
      recommendations.add('습도가 낮습니다. 반죽 표면이 마를 수 있으니 덮개를 사용하세요.');
    } else if (conditions.humidity > 80) {
      recommendations.add('습도가 높습니다. 곰팡이 발생에 주의하세요.');
    }

    return recommendations;
  }

  // 빵 종류별 최적화 메서드들
  static BreadTypeOptimization _optimizeSourdoughBread(MaterialRatioResult ratios, List<IngredientMetadata> metadata) {
    return BreadTypeOptimization(
      breadType: BreadType.sourdough,
      optimalHydration: 75.0,
      optimalSalt: 2.0,
      optimalYeast: 0.0, // 사워도우는 천연 발효
      fermentationTime: 720, // 12시간
      specialInstructions: [
        '사워도우 스타터의 활성도를 확인하세요',
        '긴 발효 시간이 필요합니다',
        '산도 조절을 위해 온도를 낮게 유지하세요',
      ],
    );
  }

  static BreadTypeOptimization _optimizeBaguette(MaterialRatioResult ratios, List<IngredientMetadata> metadata) {
    return BreadTypeOptimization(
      breadType: BreadType.baguette,
      optimalHydration: 70.0,
      optimalSalt: 2.0,
      optimalYeast: 0.8,
      fermentationTime: 480, // 8시간
      specialInstructions: [
        '높은 글루텐 강도가 필요합니다',
        '스팀을 충분히 사용하세요',
        '높은 온도에서 구워야 합니다',
      ],
    );
  }

  static BreadTypeOptimization _optimizeBrioche(MaterialRatioResult ratios, List<IngredientMetadata> metadata) {
    return BreadTypeOptimization(
      breadType: BreadType.brioche,
      optimalHydration: 60.0,
      optimalSalt: 1.8,
      optimalYeast: 1.5,
      fermentationTime: 360, // 6시간
      specialInstructions: [
        '버터를 단계적으로 추가하세요',
        '낮은 온도에서 긴 발효가 필요합니다',
        '달걀 워시를 사용하세요',
      ],
    );
  }

  static BreadTypeOptimization _optimizeWholeWheatBread(MaterialRatioResult ratios, List<IngredientMetadata> metadata) {
    return BreadTypeOptimization(
      breadType: BreadType.wholeWheat,
      optimalHydration: 80.0,
      optimalSalt: 2.2,
      optimalYeast: 1.2,
      fermentationTime: 300, // 5시간
      specialInstructions: [
        '통밀가루는 더 많은 수분이 필요합니다',
        '오토리제 과정을 추가하세요',
        '발효 시간을 조금 줄이세요',
      ],
    );
  }

  static BreadTypeOptimization _optimizeRyeBread(MaterialRatioResult ratios, List<IngredientMetadata> metadata) {
    return BreadTypeOptimization(
      breadType: BreadType.rye,
      optimalHydration: 85.0,
      optimalSalt: 2.5,
      optimalYeast: 1.0,
      fermentationTime: 600, // 10시간
      specialInstructions: [
        '호밀가루는 글루텐이 적어 끈적합니다',
        '산성 환경이 도움이 됩니다',
        '낮은 온도에서 긴 발효가 필요합니다',
      ],
    );
  }

  static BreadTypeOptimization _optimizeCiabatta(MaterialRatioResult ratios, List<IngredientMetadata> metadata) {
    return BreadTypeOptimization(
      breadType: BreadType.ciabatta,
      optimalHydration: 80.0,
      optimalSalt: 2.0,
      optimalYeast: 0.5,
      fermentationTime: 900, // 15시간
      specialInstructions: [
        '매우 높은 하이드레이션이 특징입니다',
        '접기 기법을 사용하세요',
        '긴 발효와 낮은 이스트 함량',
      ],
    );
  }

  static BreadTypeOptimization _optimizeBasicBread(MaterialRatioResult ratios, List<IngredientMetadata> metadata) {
    return BreadTypeOptimization(
      breadType: BreadType.basic,
      optimalHydration: 65.0,
      optimalSalt: 2.0,
      optimalYeast: 1.0,
      fermentationTime: 240, // 4시간
      specialInstructions: [
        '기본적인 빵 제조법을 따르세요',
        '적절한 믹싱과 발효가 중요합니다',
      ],
    );
  }

  static double _calculateBaseFermentationTime(BreadType breadType, double yeastPercentage) {
    final baseTime = switch (breadType) {
      BreadType.sourdough => 720.0,
      BreadType.baguette => 480.0,
      BreadType.brioche => 360.0,
      BreadType.wholeWheat => 300.0,
      BreadType.rye => 600.0,
      BreadType.ciabatta => 900.0,
      _ => 240.0,
    };

    // 이스트 양에 따른 시간 조정
    final yeastFactor = 1.0 / math.max(yeastPercentage, 0.1);
    return baseTime * yeastFactor;
  }

  static double _calculateMixingTime(double glutenStrength, double hydration) {
    // 기본 믹싱 시간 (분)
    double baseTime = 8.0;
    
    // 글루텐 강도에 따른 조정
    if (glutenStrength > 15) {
      baseTime += 2.0;
    } else if (glutenStrength < 10) {
      baseTime -= 1.0;
    }
    
    // 하이드레이션에 따른 조정
    if (hydration > 75) {
      baseTime -= 1.0; // 높은 하이드레이션은 짧게
    }
    
    return math.max(baseTime, 5.0);
  }

  static double _calculateBakingTime(BreadType breadType, double weight) {
    final baseTimePerKg = switch (breadType) {
      BreadType.baguette => 25.0,
      BreadType.ciabatta => 30.0,
      BreadType.sourdough => 45.0,
      BreadType.rye => 50.0,
      _ => 35.0,
    };

    return baseTimePerKg * (weight / 1000);
  }

  static List<FermentationStage> _generateFermentationStages(double bulkTime, double finalTime) {
    return [
      FermentationStage(
        name: '벌크 발효',
        duration: bulkTime,
        temperature: 25.0,
        description: '반죽의 기본 발효 단계',
      ),
      FermentationStage(
        name: '최종 발효',
        duration: finalTime,
        temperature: 27.0,
        description: '성형 후 최종 발효',
      ),
    ];
  }

  static List<String> _generateProcessRecommendations(
    MaterialRatioResult ratios,
    DoughPhysicalState doughState,
    EnvironmentCorrection environmentCorrection,
  ) {
    final recommendations = <String>[];

    if (environmentCorrection.fermentationSpeedCorrection > 1.2) {
      recommendations.add('온도가 높아 발효가 빨라집니다. 시간을 단축하세요.');
    } else if (environmentCorrection.fermentationSpeedCorrection < 0.8) {
      recommendations.add('온도가 낮아 발효가 느려집니다. 시간을 연장하세요.');
    }

    if (doughState.glutenStrengthIndex < 10) {
      recommendations.add('글루텐 강도가 낮습니다. 믹싱 시간을 늘리세요.');
    }

    return recommendations;
  }

  static double _getBaseBakingTemperature(BreadType breadType) {
    return switch (breadType) {
      BreadType.baguette => 240.0,
      BreadType.sourdough => 230.0,
      BreadType.ciabatta => 220.0,
      BreadType.brioche => 180.0,
      BreadType.rye => 200.0,
      _ => 200.0,
    };
  }

  static double _adjustTemperatureForOven(double baseTemp, OvenCharacteristics oven) {
    double adjustment = 0.0;

    // 오븐 타입에 따른 조정
    if (oven.type == OvenType.convection) {
      adjustment -= 20.0; // 컨벡션은 20도 낮게
    }

    // 오븐 정확도에 따른 조정
    if (oven.temperatureAccuracy < 0.9) {
      adjustment += 10.0; // 부정확한 오븐은 높게 설정
    }

    return baseTemp + adjustment;
  }

  static SteamSettings _calculateSteamSettings(BreadType breadType, double weight) {
    final needsHighSteam = [BreadType.baguette, BreadType.sourdough, BreadType.ciabatta];
    
    if (needsHighSteam.contains(breadType)) {
      return SteamSettings(
        duration: 15.0,
        intensity: 0.8,
      );
    } else {
      return SteamSettings(
        duration: 10.0,
        intensity: 0.5,
      );
    }
  }

  static List<TemperatureStage> _generateTemperatureProfile(double initialTemp, BreadType breadType) {
    return [
      TemperatureStage(
        temperature: initialTemp,
        duration: 15.0,
        description: '초기 고온으로 오븐 스프링 유도',
      ),
      TemperatureStage(
        temperature: initialTemp - 20,
        duration: 25.0,
        description: '온도를 낮춰 내부까지 익히기',
      ),
    ];
  }

  static DonenessIndicators _calculateDonenessIndicators(BreadType breadType, double weight) {
    return DonenessIndicators(
      internalTemperature: 95.0,
      crustColor: 'golden brown',
      soundTest: 'hollow sound when tapped',
      estimatedTime: _calculateBakingTime(breadType, weight),
    );
  }

  static List<String> _generateBakingRecommendations(BreadType breadType, OvenCharacteristics oven) {
    final recommendations = <String>[];

    if (oven.hasStone) {
      recommendations.add('피자 스톤을 충분히 예열하세요.');
    }

    if (oven.hasSteam) {
      recommendations.add('스팀 기능을 활용하여 크러스트를 개선하세요.');
    } else {
      recommendations.add('물을 담은 팬을 오븐 바닥에 놓아 스팀을 만드세요.');
    }

    final highTempBreads = [BreadType.baguette, BreadType.sourdough];
    if (highTempBreads.contains(breadType)) {
      recommendations.add('높은 온도에서 시작하여 점진적으로 낮추세요.');
    }

    return recommendations;
  }
}

// ========== 결과 클래스들 ==========

class MaterialRatioResult {
  final double flourAmount;
  final double hydrationPercentage;
  final double saltPercentage;
  final double yeastPercentage;
  final double sugarPercentage;
  final double fatPercentage;
  final bool isOptimal;
  final List<String> recommendations;

  const MaterialRatioResult({
    required this.flourAmount,
    required this.hydrationPercentage,
    required this.saltPercentage,
    required this.yeastPercentage,
    required this.sugarPercentage,
    required this.fatPercentage,
    required this.isOptimal,
    required this.recommendations,
  });
}

class DoughPhysicalState {
  final double glutenStrengthIndex;
  final double doughElasticityIndex;
  final double fermentationStabilityCoefficient;
  final Map<String, double> optimalHydrationRange;
  final List<String> recommendations;

  const DoughPhysicalState({
    required this.glutenStrengthIndex,
    required this.doughElasticityIndex,
    required this.fermentationStabilityCoefficient,
    required this.optimalHydrationRange,
    required this.recommendations,
  });
}

class EnvironmentCorrection {
  final double temperatureCorrection;
  final double humidityCorrection;
  final double altitudeCorrection;
  final double fermentationSpeedCorrection;
  final double seasonalCorrection;
  final double overallCorrection;
  final List<String> recommendations;

  const EnvironmentCorrection({
    required this.temperatureCorrection,
    required this.humidityCorrection,
    required this.altitudeCorrection,
    required this.fermentationSpeedCorrection,
    required this.seasonalCorrection,
    required this.overallCorrection,
    required this.recommendations,
  });
}

class BreadTypeOptimization {
  final BreadType breadType;
  final double optimalHydration;
  final double optimalSalt;
  final double optimalYeast;
  final double fermentationTime;
  final List<String> specialInstructions;

  const BreadTypeOptimization({
    required this.breadType,
    required this.optimalHydration,
    required this.optimalSalt,
    required this.optimalYeast,
    required this.fermentationTime,
    required this.specialInstructions,
  });
}

class ProcessTimeOptimization {
  final double mixingTime;
  final double bulkFermentationTime;
  final double finalFermentationTime;
  final double bakingTime;
  final double totalTime;
  final List<FermentationStage> fermentationStages;
  final List<String> recommendations;

  const ProcessTimeOptimization({
    required this.mixingTime,
    required this.bulkFermentationTime,
    required this.finalFermentationTime,
    required this.bakingTime,
    required this.totalTime,
    required this.fermentationStages,
    required this.recommendations,
  });
}

class BakingProcessOptimization {
  final double initialTemperature;
  final List<TemperatureStage> temperatureProfile;
  final double steamDuration;
  final double steamIntensity;
  final double totalBakingTime;
  final DonenessIndicators donenessIndicators;
  final List<String> recommendations;

  const BakingProcessOptimization({
    required this.initialTemperature,
    required this.temperatureProfile,
    required this.steamDuration,
    required this.steamIntensity,
    required this.totalBakingTime,
    required this.donenessIndicators,
    required this.recommendations,
  });
}

class FermentationStage {
  final String name;
  final double duration;
  final double temperature;
  final String description;

  const FermentationStage({
    required this.name,
    required this.duration,
    required this.temperature,
    required this.description,
  });
}

class SteamSettings {
  final double duration;
  final double intensity;

  const SteamSettings({
    required this.duration,
    required this.intensity,
  });
}

class TemperatureStage {
  final double temperature;
  final double duration;
  final String description;

  const TemperatureStage({
    required this.temperature,
    required this.duration,
    required this.description,
  });
}

class DonenessIndicators {
  final double internalTemperature;
  final String crustColor;
  final String soundTest;
  final double estimatedTime;

  const DonenessIndicators({
    required this.internalTemperature,
    required this.crustColor,
    required this.soundTest,
    required this.estimatedTime,
  });
}

enum BreadType {
  basic,
  sourdough,
  baguette,
  brioche,
  wholeWheat,
  rye,
  ciabatta,
}