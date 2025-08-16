/// 고급 반죽 분석 메서드들
/// 종합 제빵 과학 통합 계산식을 기반으로 한 추가 분석 기능들

import 'dart:math' as math;

class AdvancedDoughAnalyzerMethods {
  /// 점성 지수 계산 (유체역학)
  static double calculateViscosityIndex(
    double hydrationLevel,
    double glutenStrengthIndex,
    double doughTemperature,
    List<Map<String, dynamic>> ingredients,
    String? recipeTitle
  ) {
    // 기본 점성 (수분율 기반)
    final baseViscosity = 1.0 / (hydrationLevel + 0.1); // 수분이 많을수록 점성 감소
    
    // 글루텐 영향 (글루텐이 강할수록 점성 증가)
    final glutenEffect = 1.0 + (glutenStrengthIndex / 20.0);
    
    // 온도 영향 (온도가 높을수록 점성 감소)
    final temperatureEffect = 1.0 - ((doughTemperature - 20.0) * 0.02);
    
    // 지방 영향 (지방이 많을수록 점성 감소)
    final fatPercentage = _calculateFatPercentage(ingredients, recipeTitle);
    final fatEffect = 1.0 - (fatPercentage * 0.01);
    
    final viscosity = baseViscosity * glutenEffect * temperatureEffect * fatEffect;
    return viscosity.clamp(0.1, 3.0);
  }

  /// 표면 장력 계수 계산 (물리화학)
  static double calculateSurfaceTensionFactor(
    double hydrationLevel,
    List<Map<String, dynamic>> ingredients,
    String? recipeTitle
  ) {
    // 기본 표면 장력 (물 기준)
    double baseTension = 1.0;
    
    // 지방 영향 (지방이 표면 장력 감소)
    final fatPercentage = _calculateFatPercentage(ingredients, recipeTitle);
    final fatEffect = 1.0 - (fatPercentage * 0.02);
    
    // 설탕 영향 (설탕이 표면 장력 증가)
    final sugarPercentage = _calculateSugarPercentage(ingredients, recipeTitle);
    final sugarEffect = 1.0 + (sugarPercentage * 0.005);
    
    // 소금 영향 (소금이 표면 장력 증가)
    final saltPercentage = _calculateSaltPercentage(ingredients, recipeTitle);
    final saltEffect = 1.0 + (saltPercentage * 0.1);
    
    final surfaceTension = baseTension * fatEffect * sugarEffect * saltEffect;
    return surfaceTension.clamp(0.5, 1.5);
  }

  /// 열전달 특성 분석 (물리학)
  static Map<String, dynamic> analyzeHeatTransferCharacteristics(
    double doughDensity,
    double hydrationLevel,
    double gasRetentionIndex,
    List<Map<String, dynamic>> ingredients,
    String? recipeTitle
  ) {
    // 열전도율 계산 (W/m·K)
    final baseThermalConductivity = 0.5; // 기본 반죽 열전도율
    final waterEffect = hydrationLevel * 0.6; // 물의 열전도율 기여
    final gasEffect = -gasRetentionIndex * 0.2; // 가스가 열전도 방해
    final thermalConductivity = baseThermalConductivity + waterEffect + gasEffect;
    
    // 비열 계산 (J/g·K)
    final baseSpecificHeat = 2.5; // 기본 반죽 비열
    final moistureEffect = hydrationLevel * 1.5; // 수분의 비열 기여
    final specificHeat = baseSpecificHeat + moistureEffect;
    
    // 열확산율 계산 (m²/s)
    final thermalDiffusivity = thermalConductivity / (doughDensity * specificHeat);
    
    // 굽기 시 내부 온도 상승 예측 시간 (분)
    final heatPenetrationTime = _calculateHeatPenetrationTime(
      doughDensity, thermalDiffusivity, ingredients, recipeTitle
    );
    
    return {
      'thermalConductivity': thermalConductivity.clamp(0.2, 1.0),
      'specificHeat': specificHeat.clamp(2.0, 5.0),
      'thermalDiffusivity': thermalDiffusivity.clamp(0.1, 0.5),
      'heatPenetrationTime': heatPenetrationTime.clamp(5.0, 60.0),
      'heatTransferEfficiency': (thermalConductivity * specificHeat).clamp(1.0, 5.0),
    };
  }

  /// 반죽 안정성 지수 계산
  static double calculateStabilityIndex(
    double glutenStrengthIndex,
    double fermentationProgress,
    double gasRetentionIndex,
    double elasticityIndex,
    double environmentalFactor
  ) {
    // 글루텐 안정성 (강할수록 안정)
    final glutenStability = glutenStrengthIndex / 15.0;
    
    // 발효 안정성 (적절한 발효 상태가 안정)
    final fermentationStability = fermentationProgress > 0.8 ? 
        (1.0 - (fermentationProgress - 0.8) * 2) : fermentationProgress;
    
    // 가스 보유 안정성
    final gasStability = gasRetentionIndex;
    
    // 구조적 안정성 (탄성)
    final structuralStability = elasticityIndex;
    
    // 환경 안정성
    final environmentStability = 1.0 / environmentalFactor;
    
    final overallStability = (glutenStability * 0.3) + 
                           (fermentationStability * 0.25) + 
                           (gasStability * 0.2) + 
                           (structuralStability * 0.15) + 
                           (environmentStability * 0.1);
    
    return overallStability.clamp(0.0, 1.0);
  }

  /// 열 침투 시간 계산
  static double _calculateHeatPenetrationTime(
    double doughDensity,
    double thermalDiffusivity,
    List<Map<String, dynamic>> ingredients,
    String? recipeTitle
  ) {
    // 반죽 크기 추정 (cm)
    final flourWeight = _calculateFlourWeight(ingredients, recipeTitle);
    final estimatedRadius = math.pow(flourWeight / 500, 1/3) * 5; // cm
    
    // 열 침투 시간 = r² / (4 × α) (분 단위)
    final penetrationTime = (estimatedRadius * estimatedRadius) / (4 * thermalDiffusivity * 60);
    
    return penetrationTime;
  }

  /// 밀가루 무게 계산
  static double _calculateFlourWeight(
    List<Map<String, dynamic>> ingredients,
    String? recipeTitle
  ) {
    double flourWeight = 0.0;
    
    for (final ingredient in ingredients) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final weight = ingredient['weight'] as double? ?? 0.0;
      
      if (name.contains('밀가루') || name.contains('강력분') || 
          name.contains('중력분') || name.contains('박력분') ||
          name.contains('flour')) {
        flourWeight += weight;
      }
    }
    
    return flourWeight;
  }

  /// 지방 비율 계산
  static double _calculateFatPercentage(
    List<Map<String, dynamic>> ingredients,
    String? recipeTitle
  ) {
    double fatWeight = 0.0;
    double flourWeight = _calculateFlourWeight(ingredients, recipeTitle);
    
    if (flourWeight <= 0) return 0.0;
    
    for (final ingredient in ingredients) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final weight = ingredient['weight'] as double? ?? 0.0;
      
      if (name.contains('버터') || name.contains('오일') || 
          name.contains('올리브오일') || name.contains('butter') ||
          name.contains('oil')) {
        fatWeight += weight;
      }
    }
    
    return (fatWeight / flourWeight) * 100;
  }

  /// 설탕 비율 계산
  static double _calculateSugarPercentage(
    List<Map<String, dynamic>> ingredients,
    String? recipeTitle
  ) {
    double sugarWeight = 0.0;
    double flourWeight = _calculateFlourWeight(ingredients, recipeTitle);
    
    if (flourWeight <= 0) return 0.0;
    
    for (final ingredient in ingredients) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final weight = ingredient['weight'] as double? ?? 0.0;
      
      if (name.contains('설탕') || name.contains('꿀') || 
          name.contains('시럽') || name.contains('sugar') ||
          name.contains('honey')) {
        sugarWeight += weight;
      }
    }
    
    return (sugarWeight / flourWeight) * 100;
  }

  /// 소금 비율 계산
  static double _calculateSaltPercentage(
    List<Map<String, dynamic>> ingredients,
    String? recipeTitle
  ) {
    double saltWeight = 0.0;
    double flourWeight = _calculateFlourWeight(ingredients, recipeTitle);
    
    if (flourWeight <= 0) return 0.0;
    
    for (final ingredient in ingredients) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final weight = ingredient['weight'] as double? ?? 0.0;
      
      if (name.contains('소금') || name.contains('salt')) {
        saltWeight += weight;
      }
    }
    
    return (saltWeight / flourWeight) * 100;
  }
}