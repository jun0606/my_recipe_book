/// 실시간 레시피 분석기
/// 재료 데이터를 실시간으로 분석하여 베이킹 특성을 예측합니다.

import 'dart:math' as math;
import '../services/ingredient_analyzer.dart';
import '../services/dough_state_analyzer.dart';
import '../services/optimal_baking_engine.dart';
import '../services/mixing_time_advisor.dart';
import '../services/syrup_analyzer.dart';
import '../services/fat_analyzer.dart';

class RealTimeRecipeAnalyzer {
  /// 재료를 분석하여 베이킹 특성 예측 (제목 기반 인식률 개선)
  static RecipeAnalysisResult analyzeIngredients(
    List<Map<String, dynamic>> ingredients, {
    String? recipeTitle, // 레시피 제목 추가
    double ovenCapacityLiters = 30.0,
    double environmentTemperature = 25.0,
    double environmentHumidity = 65.0,
    double altitude = 0.0,
  }) {
    try {
      // 기본 분석 (제목 기반 정확도 개선)
      final hydrationLevel = IngredientAnalyzer.calculateHydration(ingredients, recipeTitle: recipeTitle) / 100.0; // 소수점으로 변환
      final yeastPercentage = IngredientAnalyzer.calculateYeastPercentage(ingredients, recipeTitle: recipeTitle) / 100.0; // 소수점으로 변환
      final saltPercentage = IngredientAnalyzer.calculateSaltPercentage(ingredients, recipeTitle: recipeTitle) / 100.0; // 소수점으로 변환
      final bakersPercentages = IngredientAnalyzer.calculateBakersPercentage(ingredients, recipeTitle: recipeTitle);
      
      // 재료 분류 (제목 기반)
      final flourIngredients = IngredientAnalyzer.findFlourIngredients(ingredients, recipeTitle: recipeTitle);
      final liquidIngredients = IngredientAnalyzer.findLiquidIngredients(ingredients, recipeTitle: recipeTitle);
      final sugarIngredients = _findSugarIngredients(ingredients);
      final fatIngredients = _findFatIngredients(ingredients);
      final eggIngredients = _findEggIngredients(ingredients);
      
      // 빵 타입 추정 (제목 우선, 재료 기반 보조)
      final titleBasedBreadType = recipeTitle != null 
          ? IngredientAnalyzer.estimateBreadTypeFromTitle(recipeTitle)
          : 'general';
      final ingredientBasedBreadType = _estimateBreadTypeForCalculation(hydrationLevel, yeastPercentage, sugarIngredients, fatIngredients);
      final finalBreadType = titleBasedBreadType != 'general' ? titleBasedBreadType : ingredientBasedBreadType;

      // 반죽 상태 상세 분석 (종합 제빵 과학 통합 계산식 기반)
      // 발효 시간 추정: 이스트 비율에 따른 예상 발효 시간
      final estimatedFermentationTime = yeastPercentage > 0.01 ? 90.0 : // 표준 이스트: 90분
                                       yeastPercentage > 0.005 ? 120.0 : // 적은 이스트: 120분
                                       yeastPercentage > 0 ? 180.0 : // 매우 적은 이스트: 180분
                                       0.0; // 이스트 없음
      
      final doughStateAnalysis = DoughStateAnalyzer.analyzeDoughState(
        ingredients: ingredients,
        environmentTemperature: environmentTemperature,
        environmentHumidity: environmentHumidity,
        altitude: altitude,
        recipeTitle: recipeTitle,
        fermentationTime: 0.0, // 아직 발효 시작 전 상태
      );
      
      // 최적 굽기 조건 계산 (종합 제빵 과학 통합 계산식 기반)
      final optimalBaking = OptimalBakingEngine.calculateOptimalBaking(
        doughState: doughStateAnalysis,
        ingredients: ingredients,
        ovenType: 'home_convection', // 기본값
        breadType: finalBreadType,
        recipeTitle: recipeTitle,
        environmentTemperature: environmentTemperature,
        environmentHumidity: environmentHumidity,
      );
      
      // 최적 믹싱 시간 계산 (반죽 믹싱 어드바이저)
      final optimalMixing = MixingTimeAdvisor.calculateOptimalMixingTime(
        doughState: doughStateAnalysis,
        ingredients: ingredients,
        recipeTitle: recipeTitle,
        mixerType: 'stand_mixer', // 기본값
        doughWeight: _calculateTotalWeight(ingredients),
      );
      
      // 시럽류 전문 분석 (물엿/올리고당 효과)
      final syrupAnalysis = SyrupAnalyzer.analyzeSyrupEffects(
        ingredients: ingredients,
        flourWeight: _calculateTotalWeight(flourIngredients),
        recipeTitle: recipeTitle,
        breadType: finalBreadType,
      );
      
      // 지방류 전문 분석 (버터/유지방 효과)
      final fatAnalysis = FatAnalyzer.analyzeFatEffects(
        ingredients: ingredients,
        flourWeight: _calculateTotalWeight(flourIngredients),
        recipeTitle: recipeTitle,
        breadType: finalBreadType,
        doughTemperature: environmentTemperature,
      );
      
      // 환경 보정 계수 적용 (종합 제빵 과학 통합 계산식 기반)
      final environmentalFactor = _calculateEnvironmentalFactor(
        environmentTemperature, 
        environmentHumidity, 
        altitude
      );
      
      // 특성 예측 (환경 보정 적용)
      final predictedTexture = _predictTexture(hydrationLevel, fatIngredients, eggIngredients, environmentalFactor);
      final predictedFlavor = _predictFlavor(sugarIngredients, fatIngredients, saltPercentage, environmentalFactor);
      final predictedAppearance = _predictAppearance(hydrationLevel, sugarIngredients, eggIngredients, environmentalFactor);
      
      // 베이킹 타입 추정 (제목 우선 로직)
      final estimatedBakingType = titleBasedBreadType != 'general' 
          ? _getBreadTypeDisplayName(titleBasedBreadType)
          : _estimateBakingType(hydrationLevel, yeastPercentage, sugarIngredients, fatIngredients);
      
      return RecipeAnalysisResult(
        hydrationLevel: hydrationLevel,
        yeastPercentage: yeastPercentage,
        saltPercentage: saltPercentage,
        bakersPercentages: bakersPercentages,
        predictedTexture: predictedTexture,
        predictedFlavor: predictedFlavor,
        predictedAppearance: predictedAppearance,
        estimatedBakingType: estimatedBakingType,
        flourWeight: _calculateTotalWeight(flourIngredients),
        liquidWeight: _calculateTotalWeight(liquidIngredients),
        sugarWeight: _calculateTotalWeight(sugarIngredients),
        fatWeight: _calculateTotalWeight(fatIngredients),
        confidenceScore: _calculateConfidenceScore(ingredients),
        analysisTimestamp: DateTime.now(),
        doughStateAnalysis: doughStateAnalysis,
        optimalBaking: optimalBaking,
        optimalMixing: optimalMixing,
        syrupAnalysis: syrupAnalysis,
        fatAnalysis: fatAnalysis,
        environmentalFactor: environmentalFactor,
      );
    } catch (e) {
      print('레시피 분석 중 오류: $e');
      return RecipeAnalysisResult.empty();
    }
  }

  /// 환경 보정 계수 계산 (종합 제빵 과학 통합 계산식 기반)
  static double _calculateEnvironmentalFactor(
    double temperature, 
    double humidity, 
    double altitude
  ) {
    // 발효 속도 온도 보정: 2^((실제 온도 - 25) / 10)
    final temperatureFactor = math.pow(2, (temperature - 25) / 10).toDouble();
    
    // 습도 보정: 1 + ((실제 습도% - 65%) × 0.005)
    final humidityFactor = 1 + ((humidity - 65) * 0.005);
    
    // 고도 보정: 1 + ((현재 고도(m) / 1000) × 0.02)
    final altitudeFactor = 1 + ((altitude / 1000) * 0.02);
    
    return temperatureFactor * humidityFactor * altitudeFactor;
  }

  /// 계산용 빵 타입 추정
  static String _estimateBreadTypeForCalculation(
    double hydrationLevel,
    double yeastPercentage,
    List<Map<String, dynamic>> sugarIngredients,
    List<Map<String, dynamic>> fatIngredients
  ) {
    final sugarWeight = _calculateTotalWeight(sugarIngredients);
    final fatWeight = _calculateTotalWeight(fatIngredients);
    
    if (yeastPercentage > 0.005) {
      if (sugarWeight > 50 && fatWeight > 50) return 'brioche';
      if (hydrationLevel > 0.7) return 'bread';
      return 'bread';
    } else {
      if (hydrationLevel < 0.3 && fatWeight > 30) return 'cookie';
      if (hydrationLevel > 0.6 && sugarWeight > 20) return 'cake';
      return 'general';
    }
  }

  /// 빵 타입 표시명 변환
  static String _getBreadTypeDisplayName(String breadType) {
    switch (breadType.toLowerCase()) {
      case 'bread': return '식빵/브레드류';
      case 'baguette': return '바게트/프렌치빵';
      case 'croissant': return '크루아상/페이스트리';
      case 'brioche': return '브리오슈/버터리치빵';
      case 'sourdough': return '사워도우/천연발효빵';
      case 'pizza': return '피자도우';
      case 'cookie': return '쿠키/비스킷류';
      case 'cake': return '케이크류';
      case 'muffin': return '머핀/컵케이크류';
      case 'scone': return '스콘류';
      case 'donut': return '도넛류';
      case 'bagel': return '베이글류';
      case 'pretzel': return '프레첼류';
      case 'ciabatta': return '치아바타';
      case 'focaccia': return '포카치아';
      case 'naan': return '난/인도빵';
      default: return '일반 베이킹류';
    }
  }

  /// 식감 예측 (환경 보정 적용)
  static String _predictTexture(
    double hydrationLevel, 
    List<Map<String, dynamic>> fatIngredients,
    List<Map<String, dynamic>> eggIngredients,
    double environmentalFactor
  ) {
    final fatWeight = _calculateTotalWeight(fatIngredients);
    final eggWeight = _calculateTotalWeight(eggIngredients);
    
    // 환경 보정 적용
    final adjustedHydration = hydrationLevel * (1 + (environmentalFactor - 1) * 0.1);
    
    if (adjustedHydration >= 0.75) {
      if (fatWeight > 50) {
        return "매우 촉촉하고 부드러움";
      } else {
        return "촉촉하고 쫄깃함";
      }
    } else if (adjustedHydration >= 0.65) {
      if (eggWeight > 100) {
        return "부드럽고 폭신함";
      } else {
        return "적당히 촉촉함";
      }
    } else if (adjustedHydration >= 0.55) {
      return "단단하고 조밀함";
    } else {
      return "바삭하고 건조함";
    }
  }

  /// 풍미 예측 (환경 보정 적용)
  static String _predictFlavor(
    List<Map<String, dynamic>> sugarIngredients,
    List<Map<String, dynamic>> fatIngredients,
    double saltPercentage,
    double environmentalFactor
  ) {
    final sugarWeight = _calculateTotalWeight(sugarIngredients);
    final fatWeight = _calculateTotalWeight(fatIngredients);
    
    List<String> flavorNotes = [];
    
    // 환경 보정 적용 (발효가 활발할수록 풍미 증진)
    final flavorIntensity = environmentalFactor > 1.2 ? 1.2 : (environmentalFactor < 0.8 ? 0.8 : environmentalFactor);
    
    if (sugarWeight > 30 * flavorIntensity) {
      flavorNotes.add("달콤함");
    }
    
    if (fatWeight > 40 * flavorIntensity) {
      flavorNotes.add("고소함");
    }
    
    if (saltPercentage > 0.015) {
      flavorNotes.add("짭짤함");
    } else if (saltPercentage > 0.008) {
      flavorNotes.add("담백함");
    }
    
    // 환경에 따른 추가 풍미 노트
    if (environmentalFactor > 1.1) {
      flavorNotes.add("풍부한 발효향");
    }
    
    if (flavorNotes.isEmpty) {
      return "심플하고 깔끔함";
    }
    
    return flavorNotes.join(", ");
  }

  /// 외관 예측 (환경 보정 적용)
  static String _predictAppearance(
    double hydrationLevel,
    List<Map<String, dynamic>> sugarIngredients,
    List<Map<String, dynamic>> eggIngredients,
    double environmentalFactor
  ) {
    final sugarWeight = _calculateTotalWeight(sugarIngredients);
    final eggWeight = _calculateTotalWeight(eggIngredients);
    
    String crustColor = "연한 갈색";
    String crustTexture = "부드러운";
    
    // 환경 보정에 따른 마이야르 반응 조정
    final browningFactor = environmentalFactor > 1.0 ? 1.1 : 0.9;
    
    if (sugarWeight > 50 * browningFactor) {
      crustColor = "진한 갈색";
    } else if (sugarWeight > 20 * browningFactor) {
      crustColor = "황금색";
    }
    
    if (eggWeight > 50) {
      crustColor += " 윤기나는";
    }
    
    // 환경 보정에 따른 수분 증발 조정
    final adjustedHydration = hydrationLevel * (environmentalFactor > 1.0 ? 0.95 : 1.05);
    
    if (adjustedHydration < 0.6) {
      crustTexture = "바삭한";
    } else if (adjustedHydration > 0.75) {
      crustTexture = "얇고 부드러운";
    }
    
    return "$crustTexture $crustColor 크러스트";
  }

  /// 베이킹 타입 추정 (개선된 로직)
  static String _estimateBakingType(
    double hydrationLevel,
    double yeastPercentage,
    List<Map<String, dynamic>> sugarIngredients,
    List<Map<String, dynamic>> fatIngredients
  ) {
    final sugarWeight = _calculateTotalWeight(sugarIngredients);
    final fatWeight = _calculateTotalWeight(fatIngredients);
    
    if (yeastPercentage > 0.005) {
      // 이스트가 있는 경우 - 발효빵류
      if (sugarWeight > 50 && fatWeight > 50) {
        return "브리오슈/단빵류";
      } else if (hydrationLevel > 0.7) {
        return "고수분 식빵";
      } else {
        return "일반 식빵";
      }
    } else {
      // 이스트가 없는 경우 - 더 정교한 분류
      return _classifyNonYeastBaking(hydrationLevel, sugarWeight, fatWeight);
    }
  }

  /// 비발효 베이킹 분류 (정교한 로직)
  static String _classifyNonYeastBaking(
    double hydrationLevel, 
    double sugarWeight, 
    double fatWeight
  ) {
    // 수분율과 재료 비율을 종합적으로 고려
    
    // 1. 쿠키/비스킷류 판별
    if (hydrationLevel < 0.3 && fatWeight > 30) {
      return "쿠키/비스킷류";
    }
    
    // 2. 케이크류 판별 (수분율이 높고 설탕이 적당히 있음)
    if (hydrationLevel > 0.6 && sugarWeight > 20) {
      if (fatWeight > 40) {
        return "버터케이크류";
      } else {
        return "스펀지케이크류";
      }
    }
    
    // 3. 머핀/컵케이크류 (중간 수분율, 적당한 설탕과 지방)
    if (hydrationLevel >= 0.4 && hydrationLevel <= 0.7 && 
        sugarWeight > 15 && fatWeight > 20) {
      return "머핀/컵케이크류";
    }
    
    // 4. 퀵브레드류 (수분율 중간, 설탕 적음)
    if (hydrationLevel >= 0.5 && hydrationLevel <= 0.8 && 
        sugarWeight <= 30 && fatWeight <= 40) {
      return "퀵브레드류";
    }
    
    // 5. 스콘류 (낮은 수분율, 적당한 지방)
    if (hydrationLevel < 0.5 && fatWeight > 15 && fatWeight <= 50) {
      return "스콘류";
    }
    
    // 6. 파이/타르트류 (매우 낮은 수분율, 높은 지방)
    if (hydrationLevel < 0.4 && fatWeight > 60) {
      return "파이/타르트류";
    }
    
    // 기본값 - 더 구체적인 분석 필요
    return "기타 베이킹류";
  }

  /// 신뢰도 점수 계산
  static double _calculateConfidenceScore(List<Map<String, dynamic>> ingredients) {
    double score = 0.5; // 기본 점수
    
    // 재료 개수에 따른 점수
    if (ingredients.length >= 5) score += 0.2;
    if (ingredients.length >= 8) score += 0.1;
    
    // 필수 재료 존재 여부
    final hasFlour = IngredientAnalyzer.findFlourIngredients(ingredients).isNotEmpty;
    final hasLiquid = IngredientAnalyzer.findLiquidIngredients(ingredients).isNotEmpty;
    
    if (hasFlour) score += 0.15;
    if (hasLiquid) score += 0.15;
    
    return score.clamp(0.0, 1.0);
  }

  /// 설탕 재료 찾기
  static List<Map<String, dynamic>> _findSugarIngredients(List<Map<String, dynamic>> ingredients) {
    return ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final sugarKeywords = [
        '설탕', '백설탕', '흑설탕', '황설탕', '코코넛설탕', '올리고당',
        'sugar', 'white sugar', 'brown sugar', 'coconut sugar',
        'cane sugar', 'raw sugar', 'turbinado', '꿀', 'honey', '메이플', 'maple'
      ];
      return sugarKeywords.any((keyword) => name.contains(keyword));
    }).toList();
  }

  /// 지방 재료 찾기
  static List<Map<String, dynamic>> _findFatIngredients(List<Map<String, dynamic>> ingredients) {
    return ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final fatKeywords = [
        '버터', '마가린', '쇼트닝', '라드', '코코넛오일', '올리브오일', '식용유',
        'butter', 'margarine', 'shortening', 'lard', 'coconut oil', 'olive oil', 'oil'
      ];
      return fatKeywords.any((keyword) => name.contains(keyword));
    }).toList();
  }

  /// 계란 재료 찾기
  static List<Map<String, dynamic>> _findEggIngredients(List<Map<String, dynamic>> ingredients) {
    return ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final eggKeywords = [
        '계란', '달걀', '계란흰자', '계란노른자', '전란',
        'egg', 'eggs', 'egg white', 'egg yolk', 'whole egg'
      ];
      return eggKeywords.any((keyword) => name.contains(keyword));
    }).toList();
  }

  /// 재료 그룹의 총 무게 계산
  static double _calculateTotalWeight(List<Map<String, dynamic>> ingredients) {
    double totalWeight = 0.0;
    for (final ingredient in ingredients) {
      final amount = ingredient['amount'] as double? ?? 0.0;
      final unit = ingredient['unit'] as String? ?? 'g';
      final name = ingredient['name'] as String? ?? '';
      
      totalWeight += IngredientAnalyzer.convertToGrams(amount, unit, name);
    }
    return totalWeight;
  }


}

/// 레시피 분석 결과 클래스 (종합 제빵 과학 통합 계산식 기반 확장)
class RecipeAnalysisResult {
  final double hydrationLevel;
  final double yeastPercentage;
  final double saltPercentage;
  final Map<String, double> bakersPercentages;
  final String predictedTexture;
  final String predictedFlavor;
  final String predictedAppearance;
  final String estimatedBakingType;
  final double flourWeight;
  final double liquidWeight;
  final double sugarWeight;
  final double fatWeight;
  final double confidenceScore;
  final DateTime analysisTimestamp;
  final DoughStateAnalysisResult? doughStateAnalysis; // 반죽 상태 상세 분석 결과
  final OptimalBakingResult? optimalBaking; // 최적 굽기 조건 결과
  final MixingTimeResult? optimalMixing; // 최적 믹싱 시간 결과
  final SyrupAnalysisResult? syrupAnalysis; // 시럽류 전문 분석 결과
  final FatAnalysisResult? fatAnalysis; // 지방류 전문 분석 결과
  final double? environmentalFactor; // 환경 보정 계수

  RecipeAnalysisResult({
    required this.hydrationLevel,
    required this.yeastPercentage,
    required this.saltPercentage,
    required this.bakersPercentages,
    required this.predictedTexture,
    required this.predictedFlavor,
    required this.predictedAppearance,
    required this.estimatedBakingType,
    required this.flourWeight,
    required this.liquidWeight,
    required this.sugarWeight,
    required this.fatWeight,
    required this.confidenceScore,
    required this.analysisTimestamp,
    this.doughStateAnalysis,
    this.optimalBaking,
    this.optimalMixing,
    this.syrupAnalysis,
    this.fatAnalysis,
    this.environmentalFactor,
  });

  /// 빈 결과 생성 (오류 시 사용)
  factory RecipeAnalysisResult.empty() {
    return RecipeAnalysisResult(
      hydrationLevel: 0.0,
      yeastPercentage: 0.0,
      saltPercentage: 0.0,
      bakersPercentages: {},
      predictedTexture: "분석 불가",
      predictedFlavor: "분석 불가",
      predictedAppearance: "분석 불가",
      estimatedBakingType: "알 수 없음",
      flourWeight: 0.0,
      liquidWeight: 0.0,
      sugarWeight: 0.0,
      fatWeight: 0.0,
      confidenceScore: 0.0,
      analysisTimestamp: DateTime.now(),
      doughStateAnalysis: null,
      optimalBaking: null,
      environmentalFactor: null,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'hydrationLevel': hydrationLevel,
      'yeastPercentage': yeastPercentage,
      'saltPercentage': saltPercentage,
      'bakersPercentages': bakersPercentages,
      'predictedTexture': predictedTexture,
      'predictedFlavor': predictedFlavor,
      'predictedAppearance': predictedAppearance,
      'estimatedBakingType': estimatedBakingType,
      'flourWeight': flourWeight,
      'liquidWeight': liquidWeight,
      'sugarWeight': sugarWeight,
      'fatWeight': fatWeight,
      'confidenceScore': confidenceScore,
      'analysisTimestamp': analysisTimestamp.toIso8601String(),
      'doughStateAnalysis': doughStateAnalysis?.toJson(),
      'environmentalFactor': environmentalFactor,
    };
  }

  /// JSON에서 생성
  factory RecipeAnalysisResult.fromJson(Map<String, dynamic> json) {
    return RecipeAnalysisResult(
      hydrationLevel: json['hydrationLevel']?.toDouble() ?? 0.0,
      yeastPercentage: json['yeastPercentage']?.toDouble() ?? 0.0,
      saltPercentage: json['saltPercentage']?.toDouble() ?? 0.0,
      bakersPercentages: Map<String, double>.from(json['bakersPercentages'] ?? {}),
      predictedTexture: json['predictedTexture'] ?? "분석 불가",
      predictedFlavor: json['predictedFlavor'] ?? "분석 불가",
      predictedAppearance: json['predictedAppearance'] ?? "분석 불가",
      estimatedBakingType: json['estimatedBakingType'] ?? "알 수 없음",
      flourWeight: json['flourWeight']?.toDouble() ?? 0.0,
      liquidWeight: json['liquidWeight']?.toDouble() ?? 0.0,
      sugarWeight: json['sugarWeight']?.toDouble() ?? 0.0,
      fatWeight: json['fatWeight']?.toDouble() ?? 0.0,
      confidenceScore: json['confidenceScore']?.toDouble() ?? 0.0,
      analysisTimestamp: DateTime.parse(json['analysisTimestamp'] ?? DateTime.now().toIso8601String()),
      doughStateAnalysis: json['doughStateAnalysis'] != null 
          ? DoughStateAnalysisResult.fromJson(json['doughStateAnalysis'])
          : null,
      optimalMixing: json['optimalMixing'] != null 
          ? MixingTimeResult.fromJson(json['optimalMixing'])
          : null,
      environmentalFactor: json['environmentalFactor']?.toDouble(),
    );
  }

  /// 수분율 레벨 텍스트
  String get hydrationLevelText {
    if (hydrationLevel >= 0.75) return "고수분 (${(hydrationLevel * 100).toStringAsFixed(1)}%)";
    if (hydrationLevel >= 0.65) return "표준 (${(hydrationLevel * 100).toStringAsFixed(1)}%)";
    if (hydrationLevel >= 0.55) return "저수분 (${(hydrationLevel * 100).toStringAsFixed(1)}%)";
    return "매우 저수분 (${(hydrationLevel * 100).toStringAsFixed(1)}%)";
  }

  /// 이스트 비율 텍스트
  String get yeastPercentageText {
    if (yeastPercentage >= 0.02) return "높음 (${(yeastPercentage * 100).toStringAsFixed(1)}%)";
    if (yeastPercentage >= 0.01) return "표준 (${(yeastPercentage * 100).toStringAsFixed(1)}%)";
    if (yeastPercentage > 0) return "낮음 (${(yeastPercentage * 100).toStringAsFixed(1)}%)";
    return "없음";
  }

  /// 소금 비율 텍스트
  String get saltPercentageText {
    if (saltPercentage >= 0.02) return "높음 (${(saltPercentage * 100).toStringAsFixed(1)}%)";
    if (saltPercentage >= 0.01) return "표준 (${(saltPercentage * 100).toStringAsFixed(1)}%)";
    if (saltPercentage > 0) return "낮음 (${(saltPercentage * 100).toStringAsFixed(1)}%)";
    return "없음";
  }

  /// 신뢰도 텍스트
  String get confidenceText {
    if (confidenceScore >= 0.8) return "높음";
    if (confidenceScore >= 0.6) return "보통";
    if (confidenceScore >= 0.4) return "낮음";
    return "매우 낮음";
  }

  /// 반죽 총량 정보 텍스트
  String get totalDoughAmountText {
    final totalWeight = flourWeight + liquidWeight + sugarWeight + fatWeight;
    return "${totalWeight.toStringAsFixed(0)}g";
  }

  /// 환경 보정 상태 텍스트
  String get environmentalFactorText {
    if (environmentalFactor == null) return "표준 환경";
    
    final factor = environmentalFactor!;
    if (factor > 1.2) return "발효 촉진 환경 (${factor.toStringAsFixed(2)}x)";
    if (factor > 1.05) return "발효 양호 환경 (${factor.toStringAsFixed(2)}x)";
    if (factor < 0.8) return "발효 억제 환경 (${factor.toStringAsFixed(2)}x)";
    if (factor < 0.95) return "발효 저조 환경 (${factor.toStringAsFixed(2)}x)";
    return "표준 환경 (${factor.toStringAsFixed(2)}x)";
  }

  /// 반죽 품질 권장사항
  String get qualityRecommendation {
    if (doughStateAnalysis == null) return "분석 불가";
    
    final stability = doughStateAnalysis!.stabilityIndex;
    if (stability >= 0.8) return "최적 상태 - 바로 굽기 가능";
    if (stability >= 0.6) return "양호 - 추가 발효 고려";
    if (stability >= 0.4) return "보통 - 온도/습도 조정 필요";
    return "개선 필요 - 재료 비율 재검토";
  }

  /// 반죽 밀도 텍스트 (위임)
  String get doughDensityText {
    if (doughStateAnalysis == null) return "분석 불가";
    return doughStateAnalysis!.doughDensityText;
  }

  /// 점성 지수 텍스트 (위임)
  String get viscosityText {
    if (doughStateAnalysis == null) return "분석 불가";
    return doughStateAnalysis!.viscosityText;
  }

  /// 안정성 지수 텍스트 (위임)
  String get stabilityText {
    if (doughStateAnalysis == null) return "분석 불가";
    return doughStateAnalysis!.stabilityText;
  }

  /// 열전달 효율 텍스트 (위임)
  String get heatTransferEfficiencyText {
    if (doughStateAnalysis == null) return "분석 불가";
    return doughStateAnalysis!.heatTransferEfficiencyText;
  }

  /// 열 침투 시간 텍스트 (위임)
  String get heatPenetrationTimeText {
    if (doughStateAnalysis == null) return "분석 불가";
    return doughStateAnalysis!.heatPenetrationTimeText;
  }

  /// 반죽 상태 텍스트 (위임)
  String get doughStateText {
    if (doughStateAnalysis == null) return "분석 불가";
    return doughStateAnalysis!.overallDoughState;
  }

  /// 글루텐 강도 텍스트 (위임)
  String get glutenStrengthText {
    if (doughStateAnalysis == null) return "분석 불가";
    return doughStateAnalysis!.glutenStrengthText;
  }

  /// 발효 진행도 텍스트 (위임)
  String get fermentationProgressText {
    if (doughStateAnalysis == null) return "분석 불가";
    final progress = doughStateAnalysis!.fermentationProgress;
    if (progress >= 0.8) return "충분히 발효됨 (${(progress * 100).toStringAsFixed(0)}%)";
    if (progress >= 0.5) return "적당히 발효됨 (${(progress * 100).toStringAsFixed(0)}%)";
    if (progress >= 0.2) return "발효 진행 중 (${(progress * 100).toStringAsFixed(0)}%)";
    return "발효 초기 (${(progress * 100).toStringAsFixed(0)}%)";
  }

  /// 가스 보유력 텍스트 (위임)
  String get gasRetentionText {
    if (doughStateAnalysis == null) return "분석 불가";
    return doughStateAnalysis!.gasRetentionText;
  }

  /// 온도 프로파일 텍스트
  String get temperatureProfileText {
    if (optimalBaking == null) return "계산 불가";
    return optimalBaking!.temperatureProfileSummary;
  }

  /// 총 굽기 시간 텍스트
  String get totalBakingTimeText {
    if (optimalBaking == null) return "계산 불가";
    return "${optimalBaking!.totalBakingTime}분";
  }

  /// 스팀 설정 텍스트
  String get steamSettingsText {
    if (optimalBaking == null) return "계산 불가";
    return optimalBaking!.steamSettingsSummary;
  }

  /// 굽기 성공 예측 텍스트
  String get bakingSuccessPredictionText {
    if (optimalBaking == null) return "예측 불가";
    return optimalBaking!.successPredictionText;
  }

  /// 믹싱 가이드 텍스트
  String get mixingGuideText {
    if (optimalMixing == null) return "계산 불가";
    return optimalMixing!.mixingGuideText;
  }

  /// 믹싱 총 시간 텍스트
  String get totalMixingTimeText {
    if (optimalMixing == null) return "계산 불가";
    return "${optimalMixing!.totalMixingTime}분";
  }

  /// 믹싱 복잡도 텍스트
  String get mixingComplexityText {
    if (optimalMixing == null) return "분석 불가";
    return optimalMixing!.complexityText;
  }

  /// 글루텐 발달 예측 텍스트
  String get glutenDevelopmentText {
    if (optimalMixing == null) return "예측 불가";
    return optimalMixing!.glutenDevelopmentPrediction;
  }

  /// 믹싱 완료 기준 텍스트
  String get mixingCompletionText {
    if (optimalMixing == null) return "기준 없음";
    return optimalMixing!.completionSummary;
  }

  /// 시럽 타입 텍스트
  String get syrupTypeText {
    if (syrupAnalysis == null) return "시럽 없음";
    return syrupAnalysis!.syrupTypeText;
  }

  /// 시럽 함량 텍스트
  String get syrupPercentageText {
    if (syrupAnalysis == null) return "0%";
    return syrupAnalysis!.syrupPercentageText;
  }

  /// 갈변 속도 텍스트
  String get browningSpeedText {
    if (syrupAnalysis == null) return "보통";
    return syrupAnalysis!.browningSpeedText;
  }

  /// 시럽 발효 영향 텍스트
  String get syrupFermentationEffectText {
    if (syrupAnalysis == null) return "영향 없음";
    return syrupAnalysis!.fermentationEffectText;
  }

  /// 시럽 보습 효과 텍스트
  String get syrupMoistureEffectText {
    if (syrupAnalysis == null) return "보통";
    return syrupAnalysis!.moistureEffectText;
  }

  /// 시럽 권장사항 텍스트
  String get syrupRecommendationText {
    if (syrupAnalysis == null) return "조정 불필요";
    return syrupAnalysis!.recommendationSummary;
  }

  /// 지방 타입 텍스트
  String get fatTypeText {
    if (fatAnalysis == null) return "지방 없음";
    return fatAnalysis!.fatTypeText;
  }

  /// 지방 함량 텍스트
  String get fatPercentageText {
    if (fatAnalysis == null) return "0%";
    return fatAnalysis!.fatPercentageText;
  }

  /// 크리밍 능력 텍스트
  String get creamingAbilityText {
    if (fatAnalysis == null) return "없음";
    return fatAnalysis!.creamingAbilityText;
  }

  /// 쇼트닝 효과 텍스트
  String get shorteningEffectText {
    if (fatAnalysis == null) return "미미";
    return fatAnalysis!.shorteningEffectText;
  }

  /// 지방 질감 효과 텍스트
  String get fatTextureEffectText {
    if (fatAnalysis == null) return "보통";
    return fatAnalysis!.textureEffectText;
  }

  /// 지방 볼륨 영향 텍스트
  String get fatVolumeEffectText {
    if (fatAnalysis == null) return "정상";
    return fatAnalysis!.volumeEffectText;
  }
}