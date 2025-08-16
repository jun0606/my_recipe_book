/// 고급 베이킹 과학 엔진
/// 종합 제빵 과학 통합 계산식을 기반으로 한 고급 베이킹 계산 시스템

import 'dart:math' as math;
import '../services/ingredient_analyzer.dart';

class AdvancedBakingScienceEngine {
  /// 최적 발효 시간 계산 (종합 제빵 과학 통합 계산식 기반)
  /// 공식: 최적 발효 시간(분) = 기본 발효 시간 × [미생물 활성 계수] × [반죽 물리화학 계수] × [환경 기후 계수] × [반죽 유형 보정 계수]
  static double calculateOptimalFermentationTime({
    required List<Map<String, dynamic>> ingredients,
    required double environmentTemperature,
    required double environmentHumidity,
    required double altitude,
    required String breadType,
    double baseFermentationTime = 120.0, // 기본 발효 시간 (분)
    String season = 'spring', // 계절
  }) {
    try {
      // 1. 미생물 활성 계수 계산
      final microbialActivityFactor = _calculateMicrobialActivityFactor(
        ingredients, environmentTemperature
      );

      // 2. 반죽 물리화학 계수 계산
      final doughPhysicochemicalFactor = _calculateDoughPhysicochemicalFactor(
        ingredients, environmentTemperature
      );

      // 3. 환경 기후 계수 계산
      final environmentalClimateFactor = _calculateEnvironmentalClimateFactor(
        environmentTemperature, environmentHumidity, altitude, season
      );

      // 4. 반죽 유형 보정 계수
      final doughTypeCorrectionFactor = _getDoughTypeCorrectionFactor(breadType);

      // 최종 계산
      final optimalTime = baseFermentationTime * 
                         microbialActivityFactor * 
                         doughPhysicochemicalFactor * 
                         environmentalClimateFactor * 
                         doughTypeCorrectionFactor;

      return optimalTime.clamp(30.0, 480.0); // 30분~8시간 범위로 제한
    } catch (e) {
      print('발효 시간 계산 오류: $e');
      return baseFermentationTime;
    }
  }

  /// 1. 미생물 활성 계수 계산
  /// 공식: 미생물 활성 계수 = 1 / [이스트 농도 계수 × 온도 활성 계수 × pH 영향 계수 × 당 농도 계수]
  static double _calculateMicrobialActivityFactor(
    List<Map<String, dynamic>> ingredients,
    double temperature
  ) {
    // 이스트 농도 계수
    final yeastPercentage = IngredientAnalyzer.calculateYeastPercentage(ingredients) / 100.0;
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
    final sugarIngredients = ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      return name.contains('설탕') || name.contains('sugar') || 
             name.contains('꿀') || name.contains('honey');
    }).toList();
    
    double totalSugar = 0.0;
    final flourWeight = _calculateFlourWeight(ingredients);
    
    for (final sugar in sugarIngredients) {
      final amount = sugar['amount'] as double? ?? 0.0;
      final unit = sugar['unit'] as String? ?? 'g';
      totalSugar += _convertToGrams(amount, unit, sugar['name'] as String? ?? '');
    }
    
    final sugarPercentage = flourWeight > 0 ? (totalSugar / flourWeight) * 100 : 0.0;
    final sugarConcentrationFactor = 1 - 0.2 * ((sugarPercentage - 4.0).abs() / 4.0);

    final microbialFactor = 1 / (yeastConcentrationFactor * 
                                temperatureActivityFactor * 
                                phInfluenceFactor * 
                                sugarConcentrationFactor);

    return microbialFactor.clamp(0.5, 2.0);
  }

  /// 2. 반죽 물리화학 계수 계산
  /// 공식: 반죽 물리화학 계수 = [글루텐 형성 지수] × [수분 상태 계수] × [지방 영향 계수] × [열역학 전달 계수]
  static double _calculateDoughPhysicochemicalFactor(
    List<Map<String, dynamic>> ingredients,
    double temperature
  ) {
    final flourWeight = _calculateFlourWeight(ingredients);
    if (flourWeight == 0) return 1.0;

    // 글루텐 형성 지수
    final proteinPercentage = 12.0; // 일반적인 밀가루 단백질 함량
    final saltPercentage = IngredientAnalyzer.calculateSaltPercentage(ingredients);
    final fatPercentage = _calculateFatPercentage(ingredients);
    final sugarPercentage = _calculateSugarPercentage(ingredients);
    
    final glutenFormationIndex = (proteinPercentage * 1.2) + 
                               (saltPercentage * 0.7) - 
                               (fatPercentage * 0.5) - 
                               (sugarPercentage * 0.3);

    // 수분 상태 계수 (물 경도와 온도 편차 고려)
    final waterHardness = 150.0; // 일반적인 물 경도 (ppm)
    final waterTemperatureDeviation = (temperature - 20.0).abs();
    final moistureStateFactor = 1 + (waterHardness * 0.0002) + (waterTemperatureDeviation * 0.01);

    // 지방 영향 계수
    final solidFatPercentage = fatPercentage * 0.7; // 고체 지방 추정
    final liquidFatPercentage = fatPercentage * 0.3; // 액체 지방 추정
    final fatInfluenceFactor = 1 - (solidFatPercentage * 0.02) - (liquidFatPercentage * 0.01);

    // 열역학 전달 계수 (반죽 크기 추정)
    final estimatedDoughSize = math.pow(flourWeight / 100, 1/3) * 10; // cm 단위 추정
    final thermodynamicTransferFactor = 1 - 0.1 * (estimatedDoughSize / 10);

    final physicochemicalFactor = glutenFormationIndex * 
                                moistureStateFactor * 
                                fatInfluenceFactor * 
                                thermodynamicTransferFactor;

    return physicochemicalFactor.clamp(0.5, 2.0);
  }

  /// 3. 환경 기후 계수 계산
  /// 공식: 환경 기후 계수 = 1 + (습도 보정) + (기압 보정) + (계절 보정)
  static double _calculateEnvironmentalClimateFactor(
    double temperature,
    double humidity,
    double altitude,
    String season
  ) {
    // 습도 보정
    final humidityCorrection = (humidity - 65.0) * 0.005;

    // 기압 보정 (고도 기반 추정)
    final estimatedPressure = 1013.25 * math.pow(1 - (0.0065 * altitude / 288.15), 5.255);
    final pressureCorrection = (estimatedPressure - 1013.0) * 0.0002;

    // 계절 보정
    double seasonalCorrection = 0.0;
    switch (season.toLowerCase()) {
      case 'summer':
      case '여름':
        seasonalCorrection = -0.1;
        break;
      case 'winter':
      case '겨울':
        seasonalCorrection = 0.1;
        break;
      case 'spring':
      case 'fall':
      case 'autumn':
      case '봄':
      case '가을':
        seasonalCorrection = 0.0;
        break;
    }

    final environmentalFactor = 1 + humidityCorrection + pressureCorrection + seasonalCorrection;
    return environmentalFactor.clamp(0.7, 1.5);
  }

  /// 4. 반죽 유형 보정 계수
  static double _getDoughTypeCorrectionFactor(String breadType) {
    switch (breadType.toLowerCase()) {
      case 'bread':
      case 'loaf':
      case '식빵':
        return 1.0; // 기준
      case 'baguette':
      case 'french':
      case '바게트':
      case '프렌치':
        return 1.2; // 더 긴 발효 필요
      case 'brioche':
      case '브리오슈':
        return 0.8; // 지방 함량 높음
      case 'whole wheat':
      case 'multigrain':
      case '통밀':
      case '잡곡':
        return 1.3; // 글루텐 형성 더딤
      case 'sourdough':
      case '사워도우':
        return 1.8; // 젖산균 발효 필요
      case 'croissant':
      case 'pastry':
      case '크루아상':
      case '페이스트리':
        return 0.7; // 층 형성 구조
      default:
        return 1.0;
    }
  }

  /// 굽기 온도 프로파일 계산 (종합 제빵 과학 통합 계산식 기반)
  static Map<String, dynamic> calculateBakingTemperatureProfile({
    required List<Map<String, dynamic>> ingredients,
    required String breadType,
    required String ovenType,
    double ovenCapacity = 30.0,
  }) {
    try {
      final flourWeight = _calculateFlourWeight(ingredients);
      final hydration = IngredientAnalyzer.calculateHydration(ingredients) / 100.0;
      final sugarWeight = _calculateSugarWeight(ingredients);
      final fatWeight = _calculateFatWeight(ingredients);

      // 빵 종류별 기본 온도
      final baseTemperature = _getBaseTemperatureForBreadType(breadType);
      
      // 오븐 캘리브레이션 계수
      final ovenCalibrationFactor = _getOvenCalibrationFactor(ovenType);
      
      // 단계별 온도 프로파일
      final phase1Temperature = baseTemperature + 20; // 오븐 스프링 단계
      final phase2Temperature = baseTemperature; // 내부 익힘 단계
      final phase3Temperature = baseTemperature - 10; // 크러스트 완성 단계

      // 굽는 시간 계산
      final baseTime = _getBaseTimeForBreadType(breadType);
      final weightCorrection = math.pow(flourWeight / 500, 0.3);
      final hydrationCorrection = 1 + (hydration - 0.65) * 0.005;
      final ovenEfficiency = 1 / ovenCalibrationFactor;
      
      final totalBakingTime = baseTime * weightCorrection * hydrationCorrection * ovenEfficiency;

      // 스팀 설정
      final steamTime = _calculateSteamTime(breadType, flourWeight);
      final steamAmount = _calculateSteamAmount(breadType, hydration);

      return {
        'temperatureProfile': {
          'phase1': {
            'temperature': phase1Temperature * ovenCalibrationFactor,
            'duration': (totalBakingTime * 0.2).round(),
            'description': '오븐 스프링 유도 및 초기 껍질 형성 지연',
          },
          'phase2': {
            'temperature': phase2Temperature * ovenCalibrationFactor,
            'duration': (totalBakingTime * 0.5).round(),
            'description': '내부 익힘 및 크러스트 형성 시작',
          },
          'phase3': {
            'temperature': phase3Temperature * ovenCalibrationFactor,
            'duration': (totalBakingTime * 0.3).round(),
            'description': '크러스트 색상 및 풍미 완성',
          },
        },
        'totalBakingTime': totalBakingTime.round(),
        'steamSettings': {
          'duration': steamTime,
          'amount': steamAmount,
          'timing': 'phase1_start',
        },
        'ovenType': ovenType,
        'breadType': breadType,
        'confidence': _calculateBakingConfidence(ingredients, breadType),
      };
    } catch (e) {
      print('굽기 프로파일 계산 오류: $e');
      return {
        'error': '계산 중 오류가 발생했습니다: $e',
        'totalBakingTime': 30,
        'temperatureProfile': {},
      };
    }
  }

  // === 헬퍼 메서드들 ===

  static double _calculateFlourWeight(List<Map<String, dynamic>> ingredients) {
    final flourIngredients = IngredientAnalyzer.findFlourIngredients(ingredients);
    double totalWeight = 0.0;
    
    for (final flour in flourIngredients) {
      final amount = flour['amount'] as double? ?? 0.0;
      final unit = flour['unit'] as String? ?? 'g';
      totalWeight += _convertToGrams(amount, unit, flour['name'] as String? ?? '');
    }
    
    return totalWeight;
  }

  static double _calculateFatPercentage(List<Map<String, dynamic>> ingredients) {
    final flourWeight = _calculateFlourWeight(ingredients);
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
      totalFat += _convertToGrams(amount, unit, fat['name'] as String? ?? '');
    }

    return (totalFat / flourWeight) * 100;
  }

  static double _calculateSugarPercentage(List<Map<String, dynamic>> ingredients) {
    final flourWeight = _calculateFlourWeight(ingredients);
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
      totalSugar += _convertToGrams(amount, unit, sugar['name'] as String? ?? '');
    }

    return (totalSugar / flourWeight) * 100;
  }

  static double _calculateSugarWeight(List<Map<String, dynamic>> ingredients) {
    final sugarIngredients = ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      return name.contains('설탕') || name.contains('sugar') || 
             name.contains('꿀') || name.contains('honey');
    }).toList();

    double totalWeight = 0.0;
    for (final sugar in sugarIngredients) {
      final amount = sugar['amount'] as double? ?? 0.0;
      final unit = sugar['unit'] as String? ?? 'g';
      totalWeight += _convertToGrams(amount, unit, sugar['name'] as String? ?? '');
    }

    return totalWeight;
  }

  static double _calculateFatWeight(List<Map<String, dynamic>> ingredients) {
    final fatIngredients = ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      return name.contains('버터') || name.contains('butter') || 
             name.contains('기름') || name.contains('oil') ||
             name.contains('마가린') || name.contains('margarine');
    }).toList();

    double totalWeight = 0.0;
    for (final fat in fatIngredients) {
      final amount = fat['amount'] as double? ?? 0.0;
      final unit = fat['unit'] as String? ?? 'g';
      totalWeight += _convertToGrams(amount, unit, fat['name'] as String? ?? '');
    }

    return totalWeight;
  }

  static double _getBaseTemperatureForBreadType(String breadType) {
    switch (breadType.toLowerCase()) {
      case 'bread':
      case 'loaf':
      case '식빵':
        return 180.0;
      case 'baguette':
      case '바게트':
        return 220.0;
      case 'pizza':
      case '피자':
        return 250.0;
      case 'croissant':
      case '크루아상':
        return 200.0;
      case 'brioche':
      case '브리오슈':
        return 170.0;
      case 'sourdough':
      case '사워도우':
        return 230.0;
      default:
        return 180.0;
    }
  }

  static double _getBaseTimeForBreadType(String breadType) {
    switch (breadType.toLowerCase()) {
      case 'bread':
      case 'loaf':
      case '식빵':
        return 35.0;
      case 'baguette':
      case '바게트':
        return 25.0;
      case 'pizza':
      case '피자':
        return 12.0;
      case 'croissant':
      case '크루아상':
        return 20.0;
      case 'brioche':
      case '브리오슈':
        return 30.0;
      case 'sourdough':
      case '사워도우':
        return 45.0;
      default:
        return 30.0;
    }
  }

  static double _getOvenCalibrationFactor(String ovenType) {
    switch (ovenType.toLowerCase()) {
      case 'home_convection':
      case '가정용컨벡션':
        return 0.8;
      case 'professional_convection':
      case '전문가용컨벡션':
        return 1.0;
      case 'deck_oven':
      case '덱오븐':
        return 1.2;
      case 'rotary_oven':
      case '로터리오븐':
        return 1.1;
      case 'steam_oven':
      case '스팀오븐':
        return 1.3;
      default:
        return 1.0;
    }
  }

  static int _calculateSteamTime(String breadType, double flourWeight) {
    final baseTime = breadType.toLowerCase().contains('baguette') || 
                    breadType.toLowerCase().contains('바게트') ? 15 : 5;
    final weightFactor = (flourWeight / 500).clamp(0.5, 2.0);
    return (baseTime * weightFactor).round();
  }

  static double _calculateSteamAmount(String breadType, double hydration) {
    final baseAmount = breadType.toLowerCase().contains('baguette') || 
                      breadType.toLowerCase().contains('바게트') ? 80.0 : 50.0;
    final hydrationFactor = (1 - hydration).clamp(0.2, 0.8);
    return baseAmount * hydrationFactor;
  }

  static double _calculateBakingConfidence(List<Map<String, dynamic>> ingredients, String breadType) {
    double confidence = 0.5;
    
    // 재료 개수에 따른 신뢰도
    if (ingredients.length >= 4) confidence += 0.2;
    if (ingredients.length >= 6) confidence += 0.1;
    
    // 필수 재료 존재 여부
    final hasFlour = IngredientAnalyzer.findFlourIngredients(ingredients).isNotEmpty;
    final hasLiquid = IngredientAnalyzer.findLiquidIngredients(ingredients).isNotEmpty;
    final hasYeast = IngredientAnalyzer.findYeastIngredients(ingredients).isNotEmpty;
    
    if (hasFlour) confidence += 0.15;
    if (hasLiquid) confidence += 0.15;
    if (hasYeast && breadType.toLowerCase() != 'cookie') confidence += 0.1;
    
    return confidence.clamp(0.0, 1.0);
  }

  static double _convertToGrams(double amount, String unit, String ingredientName) {
    // IngredientAnalyzer의 변환 로직 재사용
    return IngredientAnalyzer.convertToGrams(amount, unit, ingredientName);
  }
}