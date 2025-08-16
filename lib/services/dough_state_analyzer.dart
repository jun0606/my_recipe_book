/// 반죽 상태 상세 분석기
/// 종합 제빵 과학 통합 계산식을 기반으로 반죽의 모든 상태를 분석

import 'dart:math' as math;
import '../services/ingredient_analyzer.dart';
import '../services/advanced_dough_analyzer_methods.dart';

class DoughStateAnalyzer {
  /// 반죽 상태 종합 분석
  /// 글루텐 형성도, 질감, 발효 상태, 물리화학적 특성을 모두 분석
  static DoughStateAnalysisResult analyzeDoughState({
    required List<Map<String, dynamic>> ingredients,
    required double environmentTemperature,
    required double environmentHumidity,
    required double altitude,
    String? recipeTitle,
    double fermentationTime = 0.0, // 현재까지 발효 시간 (분)
    String season = 'spring',
    double doughWeight = 0.0, // 반죽 총 무게 (g)
    double doughVolume = 0.0, // 반죽 부피 (cm³)
    double doughTemperature = 25.0, // 반죽 온도 (°C)
    double waterTemperature = 20.0, // 사용한 물 온도 (°C)
  }) {
    try {
      // 1. 기본 재료 분석
      final flourIngredients = IngredientAnalyzer.findFlourIngredients(ingredients, recipeTitle: recipeTitle);
      final liquidIngredients = IngredientAnalyzer.findLiquidIngredients(ingredients, recipeTitle: recipeTitle);
      final yeastIngredients = IngredientAnalyzer.findYeastIngredients(ingredients, recipeTitle: recipeTitle);
      final saltIngredients = IngredientAnalyzer.findSaltIngredients(ingredients, recipeTitle: recipeTitle);

      // 2. 기본 비율 계산
      final hydrationLevel = IngredientAnalyzer.calculateHydration(ingredients, recipeTitle: recipeTitle) / 100.0;
      final yeastPercentage = IngredientAnalyzer.calculateYeastPercentage(ingredients, recipeTitle: recipeTitle) / 100.0;
      final saltPercentage = IngredientAnalyzer.calculateSaltPercentage(ingredients, recipeTitle: recipeTitle) / 100.0;

      // 3. 글루텐 강도 지수 계산 (종합 제빵 과학 통합 계산식)
      final glutenStrengthIndex = _calculateGlutenStrengthIndex(ingredients, recipeTitle);

      // 4. 반죽 물리화학 계수 계산
      final doughPhysicochemicalFactor = _calculateDoughPhysicochemicalFactor(
        ingredients, environmentTemperature, recipeTitle
      );

      // 5. 미생물 활성 계수 계산
      final microbialActivityFactor = _calculateMicrobialActivityFactor(
        ingredients, environmentTemperature, recipeTitle
      );

      // 6. 환경 기후 계수 계산 (기후학)
      final environmentalFactor = _calculateEnvironmentalFactor(
        environmentTemperature, environmentHumidity, altitude, season
      );

      // 7. 반죽 밀도 계산 (물리학)
      final doughDensity = _calculateDoughDensity(
        ingredients, doughWeight, doughVolume, hydrationLevel, recipeTitle
      );

      // 8. 발효 진행도 분석 (통합 계산식)
      final fermentationProgress = _analyzeFermentationProgress(
        fermentationTime, microbialActivityFactor, doughPhysicochemicalFactor, 
        environmentalFactor, hydrationLevel
      );

      // 9. 가스 보유력 지수 (물리화학)
      final gasRetentionIndex = _calculateGasRetentionIndex(
        glutenStrengthIndex, hydrationLevel, fermentationProgress
      );

      // 10. 반죽 탄성 지수 (물리학)
      final elasticityIndex = _calculateElasticityIndex(
        glutenStrengthIndex, hydrationLevel, saltPercentage
      );

      // 11. 점성 지수 계산 (유체역학)
      final viscosityIndex = AdvancedDoughAnalyzerMethods.calculateViscosityIndex(
        hydrationLevel, glutenStrengthIndex, doughTemperature, ingredients, recipeTitle
      );

      // 12. 표면 장력 계수 (물리화학)
      final surfaceTensionFactor = AdvancedDoughAnalyzerMethods.calculateSurfaceTensionFactor(
        hydrationLevel, ingredients, recipeTitle
      );

      // 13. 열전달 특성 분석 (물리학)
      final heatTransferCharacteristics = AdvancedDoughAnalyzerMethods.analyzeHeatTransferCharacteristics(
        doughDensity, hydrationLevel, gasRetentionIndex, ingredients, recipeTitle
      );

      // 14. 반죽 질감 분석 (종합)
      final textureAnalysis = _analyzeTextureCharacteristics(
        hydrationLevel, glutenStrengthIndex, fermentationProgress
      );

      // 15. 표면 상태 분석
      final surfaceCondition = _analyzeSurfaceCondition(
        hydrationLevel, fermentationProgress, environmentHumidity
      );

      // 16. 반죽 안정성 지수 계산
      final stabilityIndex = AdvancedDoughAnalyzerMethods.calculateStabilityIndex(
        glutenStrengthIndex, fermentationProgress, gasRetentionIndex, 
        elasticityIndex, environmentalFactor
      );

      return DoughStateAnalysisResult(
        glutenStrengthIndex: glutenStrengthIndex,
        doughPhysicochemicalFactor: doughPhysicochemicalFactor,
        microbialActivityFactor: microbialActivityFactor,
        environmentalFactor: environmentalFactor,
        fermentationProgress: fermentationProgress,
        gasRetentionIndex: gasRetentionIndex,
        elasticityIndex: elasticityIndex,
        viscosityIndex: viscosityIndex,
        surfaceTensionFactor: surfaceTensionFactor,
        doughDensity: doughDensity,
        stabilityIndex: stabilityIndex,
        heatTransferCharacteristics: heatTransferCharacteristics,
        textureAnalysis: textureAnalysis,
        surfaceCondition: surfaceCondition,
        hydrationLevel: hydrationLevel,
        yeastPercentage: yeastPercentage,
        saltPercentage: saltPercentage,
        analysisTimestamp: DateTime.now(),
      );
    } catch (e) {
      print('반죽 상태 분석 오류: $e');
      return DoughStateAnalysisResult.empty();
    }
  }

  /// 글루텐 강도 지수 계산
  /// 공식: (밀가루 단백질% × 1.2) + (소금% × 0.7) - (지방% × 0.5) - (설탕% × 0.3)
  static double _calculateGlutenStrengthIndex(
    List<Map<String, dynamic>> ingredients,
    String? recipeTitle
  ) {
    final flourIngredients = IngredientAnalyzer.findFlourIngredients(ingredients, recipeTitle: recipeTitle);
    if (flourIngredients.isEmpty) return 0.0;

    // 밀가루 단백질 함량 추정 (밀가루 종류별)
    double proteinPercentage = 12.0; // 기본값
    for (final flour in flourIngredients) {
      final name = (flour['name'] as String? ?? '').toLowerCase();
      if (name.contains('강력분') || name.contains('bread flour')) {
        proteinPercentage = 13.5;
        break;
      } else if (name.contains('박력분') || name.contains('cake flour')) {
        proteinPercentage = 8.5;
        break;
      } else if (name.contains('중력분') || name.contains('all-purpose flour')) {
        proteinPercentage = 11.0;
        break;
      }
    }

    final saltPercentage = IngredientAnalyzer.calculateSaltPercentage(ingredients, recipeTitle: recipeTitle);
    final fatPercentage = _calculateFatPercentage(ingredients, recipeTitle);
    final sugarPercentage = _calculateSugarPercentage(ingredients, recipeTitle);

    final glutenIndex = (proteinPercentage * 1.2) + 
                       (saltPercentage * 0.7) - 
                       (fatPercentage * 0.5) - 
                       (sugarPercentage * 0.3);

    return glutenIndex.clamp(0.0, 20.0);
  }

  /// 반죽 물리화학 계수 계산
  /// 공식: [글루텐 형성 지수] × [수분 상태 계수] × [지방 영향 계수] × [열역학 전달 계수]
  static double _calculateDoughPhysicochemicalFactor(
    List<Map<String, dynamic>> ingredients,
    double temperature,
    String? recipeTitle
  ) {
    final glutenFormationIndex = _calculateGlutenStrengthIndex(ingredients, recipeTitle);
    
    // 수분 상태 계수
    final waterHardness = 150.0; // 일반적인 물 경도 (ppm)
    final waterTemperatureDeviation = (temperature - 20.0).abs();
    final moistureStateFactor = 1 + (waterHardness * 0.0002) + (waterTemperatureDeviation * 0.01);

    // 지방 영향 계수
    final fatPercentage = _calculateFatPercentage(ingredients, recipeTitle);
    final solidFatPercentage = fatPercentage * 0.7; // 고체 지방 추정
    final liquidFatPercentage = fatPercentage * 0.3; // 액체 지방 추정
    final fatInfluenceFactor = 1 - (solidFatPercentage * 0.02) - (liquidFatPercentage * 0.01);

    // 열역학 전달 계수 (반죽 크기 추정)
    final flourWeight = _calculateFlourWeight(ingredients, recipeTitle);
    final estimatedDoughSize = math.pow(flourWeight / 100, 1/3) * 10; // cm 단위 추정
    final thermodynamicTransferFactor = 1 - 0.1 * (estimatedDoughSize / 10);

    final physicochemicalFactor = glutenFormationIndex * 
                                moistureStateFactor * 
                                fatInfluenceFactor * 
                                thermodynamicTransferFactor;

    return physicochemicalFactor.clamp(0.1, 5.0);
  }

  /// 미생물 활성 계수 계산
  /// 공식: 1 / [이스트 농도 계수 × 온도 활성 계수 × pH 영향 계수 × 당 농도 계수]
  static double _calculateMicrobialActivityFactor(
    List<Map<String, dynamic>> ingredients,
    double temperature,
    String? recipeTitle
  ) {
    // 이스트 농도 계수
    final yeastPercentage = IngredientAnalyzer.calculateYeastPercentage(ingredients, recipeTitle: recipeTitle) / 100.0;
    final standardYeastPercentage = 0.006; // 표준 이스트 비율 0.6%
    final yeastConcentrationFactor = math.pow(yeastPercentage / standardYeastPercentage, 0.8).toDouble();

    // 온도 활성 계수
    final optimalTemperature = 27.0; // 이스트 최적 온도
    final temperatureActivityFactor = math.pow(2, (temperature - 25) / 10) * 
                                    math.pow(1 - (temperature - optimalTemperature).abs() / 15, 2);

    // pH 영향 계수 (추정값 사용)
    final estimatedPH = 5.5; // 일반적인 반죽 pH
    final optimalPH = 5.0; // 이스트 최적 pH
    final phInfluenceFactor = 1 - 0.3 * (estimatedPH - optimalPH).abs();

    // 당 농도 계수
    final sugarPercentage = _calculateSugarPercentage(ingredients, recipeTitle);
    final sugarConcentrationFactor = 1 - 0.2 * ((sugarPercentage - 4.0).abs() / 4.0);

    final microbialFactor = 1 / (yeastConcentrationFactor * 
                                temperatureActivityFactor * 
                                phInfluenceFactor * 
                                sugarConcentrationFactor);

    return microbialFactor.clamp(0.1, 3.0);
  }

  /// 환경 기후 계수 계산 (기후학)
  /// 공식: 1 + (습도 보정) + (기압 보정) + (계절 보정)
  static double _calculateEnvironmentalFactor(
    double temperature,
    double humidity,
    double altitude,
    String season
  ) {
    // 습도 보정
    final humidityCorrection = (humidity - 65.0) * 0.005;
    
    // 기압 보정 (고도 기반)
    final standardPressure = 1013.0; // hPa
    final pressureAtAltitude = standardPressure * math.pow(1 - (0.0065 * altitude / 288.15), 5.255);
    final pressureCorrection = (pressureAtAltitude - standardPressure) * 0.0002;
    
    // 계절 보정
    double seasonCorrection = 0.0;
    switch (season.toLowerCase()) {
      case 'summer':
      case '여름':
        seasonCorrection = -0.1;
        break;
      case 'winter':
      case '겨울':
        seasonCorrection = 0.1;
        break;
      case 'spring':
      case 'autumn':
      case '봄':
      case '가을':
        seasonCorrection = 0.0;
        break;
    }
    
    final environmentalFactor = 1 + humidityCorrection + pressureCorrection + seasonCorrection;
    return environmentalFactor.clamp(0.5, 2.0);
  }

  /// 반죽 밀도 계산 (물리학)
  static double _calculateDoughDensity(
    List<Map<String, dynamic>> ingredients,
    double doughWeight,
    double doughVolume,
    double hydrationLevel,
    String? recipeTitle
  ) {
    if (doughWeight > 0 && doughVolume > 0) {
      return doughWeight / doughVolume; // g/cm³
    }
    
    // 추정 계산
    final flourWeight = _calculateFlourWeight(ingredients, recipeTitle);
    final totalWeight = flourWeight * (1 + hydrationLevel + 0.05); // 기타 재료 5% 추정
    
    // 수분율과 발효 상태에 따른 밀도 추정
    final baseDensity = 1.2; // g/cm³ (기본 반죽 밀도)
    final hydrationEffect = -0.3 * hydrationLevel; // 수분이 많을수록 밀도 감소
    final estimatedDensity = baseDensity + hydrationEffect;
    
    return estimatedDensity.clamp(0.8, 1.5);
  }

  /// 발효 진행도 분석 (통합 계산식)
  /// 공식: 기본 발효 시간 × [미생물 활성 계수] × [반죽 물리화학 계수] × [환경 기후 계수]
  static double _analyzeFermentationProgress(
    double fermentationTime,
    double microbialActivityFactor,
    double doughPhysicochemicalFactor,
    double environmentalFactor,
    double hydrationLevel
  ) {
    if (fermentationTime <= 0) return 0.0;

    // 기본 발효 시간 (분)
    final baseFermentationTime = 90.0; // 표준 1차 발효 시간
    
    // 통합 계산식 적용
    final fermentationRate = microbialActivityFactor * 
                           doughPhysicochemicalFactor * 
                           environmentalFactor;
    
    // 실제 발효 진행도 계산
    final progress = (fermentationTime / baseFermentationTime) * fermentationRate;

    return progress.clamp(0.0, 1.0);
  }

  /// 반죽 질감 특성 분석
  static String _analyzeTextureCharacteristics(
    double hydrationLevel,
    double glutenStrengthIndex,
    double fermentationProgress
  ) {
    List<String> characteristics = [];

    // 수분율 기반 질감
    if (hydrationLevel >= 0.75) {
      characteristics.add("매우 촉촉");
    } else if (hydrationLevel >= 0.65) {
      characteristics.add("촉촉");
    } else if (hydrationLevel >= 0.55) {
      characteristics.add("적당한 수분");
    } else {
      characteristics.add("건조");
    }

    // 글루텐 강도 기반 질감
    if (glutenStrengthIndex >= 12.0) {
      characteristics.add("매우 탄력적");
    } else if (glutenStrengthIndex >= 8.0) {
      characteristics.add("탄력적");
    } else if (glutenStrengthIndex >= 5.0) {
      characteristics.add("부드러움");
    } else {
      characteristics.add("약한 구조");
    }

    // 발효 진행도 기반 질감
    if (fermentationProgress >= 0.8) {
      characteristics.add("충분히 발효됨");
    } else if (fermentationProgress >= 0.5) {
      characteristics.add("적당히 발효됨");
    } else if (fermentationProgress >= 0.2) {
      characteristics.add("발효 진행 중");
    } else {
      characteristics.add("발효 초기");
    }

    return characteristics.join(", ");
  }

  /// 가스 보유력 지수 계산
  static double _calculateGasRetentionIndex(
    double glutenStrengthIndex,
    double hydrationLevel,
    double fermentationProgress
  ) {
    // 글루텐 망의 강도가 가스 보유력의 핵심
    final glutenFactor = glutenStrengthIndex / 15.0; // 정규화
    
    // 적절한 수분율이 가스 보유에 도움
    final hydrationFactor = hydrationLevel > 0.6 ? 
        (1.0 - (hydrationLevel - 0.6).abs() * 2) : 
        hydrationLevel / 0.6;
    
    // 발효 진행도에 따른 가스 생성량
    final fermentationFactor = fermentationProgress;

    final gasRetention = glutenFactor * hydrationFactor * fermentationFactor;
    return gasRetention.clamp(0.0, 1.0);
  }

  /// 반죽 탄성 지수 계산
  static double _calculateElasticityIndex(
    double glutenStrengthIndex,
    double hydrationLevel,
    double saltPercentage
  ) {
    // 글루텐 강도가 탄성의 기본
    final glutenFactor = glutenStrengthIndex / 15.0;
    
    // 수분율이 탄성에 미치는 영향
    final hydrationFactor = hydrationLevel > 0.7 ? 
        (1.0 - (hydrationLevel - 0.7) * 2) : 
        hydrationLevel / 0.7;
    
    // 소금이 글루텐 강화에 미치는 영향
    final saltFactor = saltPercentage > 0.015 ? 
        1.0 + (saltPercentage - 0.015) * 10 : 
        saltPercentage / 0.015;

    final elasticity = glutenFactor * hydrationFactor * saltFactor;
    return elasticity.clamp(0.0, 1.0);
  }

  /// 표면 상태 분석
  static String _analyzeSurfaceCondition(
    double hydrationLevel,
    double fermentationProgress,
    double environmentHumidity
  ) {
    List<String> conditions = [];

    // 수분 상태
    if (hydrationLevel >= 0.7 && environmentHumidity >= 60) {
      conditions.add("촉촉한 표면");
    } else if (hydrationLevel <= 0.5 || environmentHumidity <= 40) {
      conditions.add("건조한 표면");
    } else {
      conditions.add("적당한 표면 수분");
    }

    // 발효에 따른 표면 변화
    if (fermentationProgress >= 0.7) {
      conditions.add("표면 팽창");
    } else if (fermentationProgress >= 0.3) {
      conditions.add("표면 변화 진행");
    } else {
      conditions.add("표면 안정");
    }

    return conditions.join(", ");
  }

  // === 헬퍼 메서드들 ===

  static double _calculateFatPercentage(List<Map<String, dynamic>> ingredients, String? recipeTitle) {
    final flourWeight = _calculateFlourWeight(ingredients, recipeTitle);
    if (flourWeight == 0) return 0.0;

    final fatIngredients = ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      return name.contains('버터') || name.contains('butter') || 
             name.contains('기름') || name.contains('oil') ||
             name.contains('마가린') || name.contains('margarine');
    }).toList();

    double totalFat = 0.0;
    for (final fat in fatIngredients) {
      final amount = fat['amount'] as double? ?? 0.0;
      final unit = fat['unit'] as String? ?? 'g';
      totalFat += IngredientAnalyzer.convertToGrams(amount, unit, fat['name'] as String? ?? '');
    }

    return (totalFat / flourWeight) * 100;
  }

  static double _calculateSugarPercentage(List<Map<String, dynamic>> ingredients, String? recipeTitle) {
    final flourWeight = _calculateFlourWeight(ingredients, recipeTitle);
    if (flourWeight == 0) return 0.0;

    final sugarIngredients = ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      return name.contains('설탕') || name.contains('sugar') || 
             name.contains('꿀') || name.contains('honey');
    }).toList();

    double totalSugar = 0.0;
    for (final sugar in sugarIngredients) {
      final amount = sugar['amount'] as double? ?? 0.0;
      final unit = sugar['unit'] as String? ?? 'g';
      totalSugar += IngredientAnalyzer.convertToGrams(amount, unit, sugar['name'] as String? ?? '');
    }

    return (totalSugar / flourWeight) * 100;
  }

  static double _calculateFlourWeight(List<Map<String, dynamic>> ingredients, String? recipeTitle) {
    final flourIngredients = IngredientAnalyzer.findFlourIngredients(ingredients, recipeTitle: recipeTitle);
    double totalWeight = 0.0;
    
    for (final flour in flourIngredients) {
      final amount = flour['amount'] as double? ?? 0.0;
      final unit = flour['unit'] as String? ?? 'g';
      totalWeight += IngredientAnalyzer.convertToGrams(amount, unit, flour['name'] as String? ?? '');
    }
    
    return totalWeight;
  }
}

/// 반죽 상태 분석 결과 클래스
class DoughStateAnalysisResult {
  final double glutenStrengthIndex;
  final double doughPhysicochemicalFactor;
  final double microbialActivityFactor;
  final double environmentalFactor;
  final double fermentationProgress;
  final double gasRetentionIndex;
  final double elasticityIndex;
  final double viscosityIndex;
  final double surfaceTensionFactor;
  final double doughDensity;
  final double stabilityIndex;
  final Map<String, dynamic> heatTransferCharacteristics;
  final String textureAnalysis;
  final String surfaceCondition;
  final double hydrationLevel;
  final double yeastPercentage;
  final double saltPercentage;
  final DateTime analysisTimestamp;

  DoughStateAnalysisResult({
    required this.glutenStrengthIndex,
    required this.doughPhysicochemicalFactor,
    required this.microbialActivityFactor,
    required this.environmentalFactor,
    required this.fermentationProgress,
    required this.gasRetentionIndex,
    required this.elasticityIndex,
    required this.viscosityIndex,
    required this.surfaceTensionFactor,
    required this.doughDensity,
    required this.stabilityIndex,
    required this.heatTransferCharacteristics,
    required this.textureAnalysis,
    required this.surfaceCondition,
    required this.hydrationLevel,
    required this.yeastPercentage,
    required this.saltPercentage,
    required this.analysisTimestamp,
  });

  /// 빈 결과 생성 (오류 시 사용)
  factory DoughStateAnalysisResult.empty() {
    return DoughStateAnalysisResult(
      glutenStrengthIndex: 0.0,
      doughPhysicochemicalFactor: 0.0,
      microbialActivityFactor: 0.0,
      environmentalFactor: 1.0,
      fermentationProgress: 0.0,
      gasRetentionIndex: 0.0,
      elasticityIndex: 0.0,
      viscosityIndex: 0.0,
      surfaceTensionFactor: 1.0,
      doughDensity: 1.0,
      stabilityIndex: 0.0,
      heatTransferCharacteristics: {},
      textureAnalysis: "분석 불가",
      surfaceCondition: "분석 불가",
      hydrationLevel: 0.0,
      yeastPercentage: 0.0,
      saltPercentage: 0.0,
      analysisTimestamp: DateTime.now(),
    );
  }

  /// 글루텐 강도 텍스트
  String get glutenStrengthText {
    if (glutenStrengthIndex >= 12.0) return "매우 강함 (${glutenStrengthIndex.toStringAsFixed(1)})";
    if (glutenStrengthIndex >= 8.0) return "강함 (${glutenStrengthIndex.toStringAsFixed(1)})";
    if (glutenStrengthIndex >= 5.0) return "보통 (${glutenStrengthIndex.toStringAsFixed(1)})";
    if (glutenStrengthIndex >= 2.0) return "약함 (${glutenStrengthIndex.toStringAsFixed(1)})";
    return "매우 약함 (${glutenStrengthIndex.toStringAsFixed(1)})";
  }

  /// 발효 진행도 텍스트
  String get fermentationProgressText {
    if (fermentationProgress >= 0.9) return "과발효 위험 (${(fermentationProgress * 100).toStringAsFixed(0)}%)";
    if (fermentationProgress >= 0.7) return "충분히 발효됨 (${(fermentationProgress * 100).toStringAsFixed(0)}%)";
    if (fermentationProgress >= 0.5) return "적당히 발효됨 (${(fermentationProgress * 100).toStringAsFixed(0)}%)";
    if (fermentationProgress >= 0.2) return "발효 진행 중 (${(fermentationProgress * 100).toStringAsFixed(0)}%)";
    return "발효 초기 (${(fermentationProgress * 100).toStringAsFixed(0)}%)";
  }

  /// 가스 보유력 텍스트
  String get gasRetentionText {
    if (gasRetentionIndex >= 0.8) return "우수 (${(gasRetentionIndex * 100).toStringAsFixed(0)}%)";
    if (gasRetentionIndex >= 0.6) return "양호 (${(gasRetentionIndex * 100).toStringAsFixed(0)}%)";
    if (gasRetentionIndex >= 0.4) return "보통 (${(gasRetentionIndex * 100).toStringAsFixed(0)}%)";
    if (gasRetentionIndex >= 0.2) return "부족 (${(gasRetentionIndex * 100).toStringAsFixed(0)}%)";
    return "매우 부족 (${(gasRetentionIndex * 100).toStringAsFixed(0)}%)";
  }

  /// 탄성 지수 텍스트
  String get elasticityText {
    if (elasticityIndex >= 0.8) return "매우 탄력적 (${(elasticityIndex * 100).toStringAsFixed(0)}%)";
    if (elasticityIndex >= 0.6) return "탄력적 (${(elasticityIndex * 100).toStringAsFixed(0)}%)";
    if (elasticityIndex >= 0.4) return "적당한 탄성 (${(elasticityIndex * 100).toStringAsFixed(0)}%)";
    if (elasticityIndex >= 0.2) return "탄성 부족 (${(elasticityIndex * 100).toStringAsFixed(0)}%)";
    return "탄성 매우 부족 (${(elasticityIndex * 100).toStringAsFixed(0)}%)";
  }

  /// 종합 반죽 상태 평가
  String get overallDoughState {
    final scores = [
      glutenStrengthIndex / 15.0,
      fermentationProgress,
      gasRetentionIndex,
      elasticityIndex,
    ];
    
    final averageScore = scores.reduce((a, b) => a + b) / scores.length;
    
    if (averageScore >= 0.8) return "최적 상태";
    if (averageScore >= 0.6) return "양호한 상태";
    if (averageScore >= 0.4) return "보통 상태";
    if (averageScore >= 0.2) return "개선 필요";
    return "문제 있음";
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'glutenStrengthIndex': glutenStrengthIndex,
      'doughPhysicochemicalFactor': doughPhysicochemicalFactor,
      'microbialActivityFactor': microbialActivityFactor,
      'environmentalFactor': environmentalFactor,
      'fermentationProgress': fermentationProgress,
      'gasRetentionIndex': gasRetentionIndex,
      'elasticityIndex': elasticityIndex,
      'viscosityIndex': viscosityIndex,
      'surfaceTensionFactor': surfaceTensionFactor,
      'doughDensity': doughDensity,
      'stabilityIndex': stabilityIndex,
      'heatTransferCharacteristics': heatTransferCharacteristics,
      'textureAnalysis': textureAnalysis,
      'surfaceCondition': surfaceCondition,
      'hydrationLevel': hydrationLevel,
      'yeastPercentage': yeastPercentage,
      'saltPercentage': saltPercentage,
      'analysisTimestamp': analysisTimestamp.toIso8601String(),
    };
  }

  /// JSON에서 생성
  factory DoughStateAnalysisResult.fromJson(Map<String, dynamic> json) {
    return DoughStateAnalysisResult(
      glutenStrengthIndex: json['glutenStrengthIndex']?.toDouble() ?? 0.0,
      doughPhysicochemicalFactor: json['doughPhysicochemicalFactor']?.toDouble() ?? 0.0,
      microbialActivityFactor: json['microbialActivityFactor']?.toDouble() ?? 0.0,
      environmentalFactor: json['environmentalFactor']?.toDouble() ?? 1.0,
      fermentationProgress: json['fermentationProgress']?.toDouble() ?? 0.0,
      gasRetentionIndex: json['gasRetentionIndex']?.toDouble() ?? 0.0,
      elasticityIndex: json['elasticityIndex']?.toDouble() ?? 0.0,
      viscosityIndex: json['viscosityIndex']?.toDouble() ?? 0.0,
      surfaceTensionFactor: json['surfaceTensionFactor']?.toDouble() ?? 1.0,
      doughDensity: json['doughDensity']?.toDouble() ?? 1.0,
      stabilityIndex: json['stabilityIndex']?.toDouble() ?? 0.0,
      heatTransferCharacteristics: Map<String, dynamic>.from(json['heatTransferCharacteristics'] ?? {}),
      textureAnalysis: json['textureAnalysis'] ?? "분석 불가",
      surfaceCondition: json['surfaceCondition'] ?? "분석 불가",
      hydrationLevel: json['hydrationLevel']?.toDouble() ?? 0.0,
      yeastPercentage: json['yeastPercentage']?.toDouble() ?? 0.0,
      saltPercentage: json['saltPercentage']?.toDouble() ?? 0.0,
      analysisTimestamp: DateTime.parse(json['analysisTimestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// 점성 지수 텍스트
  String get viscosityText {
    if (viscosityIndex >= 2.0) return "높음 (${viscosityIndex.toStringAsFixed(1)})";
    if (viscosityIndex >= 1.0) return "보통 (${viscosityIndex.toStringAsFixed(1)})";
    return "낮음 (${viscosityIndex.toStringAsFixed(1)})";
  }

  /// 안정성 지수 텍스트
  String get stabilityText {
    if (stabilityIndex >= 0.8) return "매우 안정 (${(stabilityIndex * 100).toStringAsFixed(0)}%)";
    if (stabilityIndex >= 0.6) return "안정 (${(stabilityIndex * 100).toStringAsFixed(0)}%)";
    if (stabilityIndex >= 0.4) return "보통 (${(stabilityIndex * 100).toStringAsFixed(0)}%)";
    return "불안정 (${(stabilityIndex * 100).toStringAsFixed(0)}%)";
  }

  /// 반죽 밀도 텍스트
  String get doughDensityText {
    return "${doughDensity.toStringAsFixed(2)} g/cm³";
  }

  /// 열전달 효율 텍스트
  String get heatTransferEfficiencyText {
    final efficiency = heatTransferCharacteristics['heatTransferEfficiency'] as double? ?? 0.0;
    if (efficiency >= 4.0) return "매우 높음 (${efficiency.toStringAsFixed(1)})";
    if (efficiency >= 3.0) return "높음 (${efficiency.toStringAsFixed(1)})";
    if (efficiency >= 2.0) return "보통 (${efficiency.toStringAsFixed(1)})";
    return "낮음 (${efficiency.toStringAsFixed(1)})";
  }

  /// 열 침투 시간 텍스트
  String get heatPenetrationTimeText {
    final time = heatTransferCharacteristics['heatPenetrationTime'] as double? ?? 0.0;
    return "${time.toStringAsFixed(0)}분";
  }
}