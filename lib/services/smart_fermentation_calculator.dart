/// 스마트 발효 시간 계산 엔진
/// 레시피 데이터와 환경 조건을 기반으로 최적의 발효 시간을 계산

import 'dart:math' as math;
import '../models/fermentation_scenario.dart';
import '../models/sous_chef_models.dart';
import '../models/environmental_conditions.dart';
import 'ingredient_analyzer.dart';

/// 스마트 발효 계산기
class SmartFermentationCalculator {
  /// 레시피와 환경 조건을 기반으로 발효 시간 계산
  static Map<FermentationStage, double> calculateOptimalTimes({
    required List<FermentationStage> selectedStages,
    required List<Map<String, dynamic>> ingredients,
    required double environmentTemperature,
    required double environmentHumidity,
    required double altitude,
    String? recipeTitle,
  }) {
    // 1. 레시피 분석
    final recipeAnalysis = _analyzeRecipe(ingredients, recipeTitle);
    
    // 2. 환경 조건 분석
    final environmentFactor = _calculateEnvironmentFactor(
      environmentTemperature, 
      environmentHumidity, 
      altitude
    );
    
    // 3. 각 단계별 기본 시간 계산
    final baseTimes = _calculateBaseTimes(selectedStages, recipeAnalysis);
    
    // 4. 환경 조건 적용
    final adjustedTimes = <FermentationStage, double>{};
    for (final stage in selectedStages) {
      final baseTime = baseTimes[stage] ?? _getDefaultTime(stage);
      adjustedTimes[stage] = baseTime * environmentFactor * recipeAnalysis.complexityFactor;
    }
    
    // 5. 디버그 정보 출력
    _printCalculationDetails(recipeAnalysis, environmentFactor, baseTimes, adjustedTimes);
    
    return adjustedTimes;
  }

  /// 레시피 분석
  static RecipeAnalysis _analyzeRecipe(List<Map<String, dynamic>> ingredients, String? recipeTitle) {
    final hydration = IngredientAnalyzer.calculateHydration(ingredients, recipeTitle: recipeTitle);
    final yeastPercentage = IngredientAnalyzer.calculateYeastPercentage(ingredients, recipeTitle: recipeTitle);
    final saltPercentage = IngredientAnalyzer.calculateSaltPercentage(ingredients, recipeTitle: recipeTitle);
    
    // 복잡도 계산 (하이드레이션, 이스트량, 소금량 기반)
    double complexityFactor = 1.0;
    
    // 하이드레이션 영향 (높을수록 발효 빨라짐)
    if (hydration > 75) {
      complexityFactor *= 0.85; // 15% 빠름
    } else if (hydration < 60) {
      complexityFactor *= 1.15; // 15% 느림
    }
    
    // 이스트량 영향
    if (yeastPercentage > 1.5) {
      complexityFactor *= 0.8; // 20% 빠름
    } else if (yeastPercentage < 0.8) {
      complexityFactor *= 1.3; // 30% 느림
    }
    
    // 소금량 영향 (높을수록 발효 느려짐)
    if (saltPercentage > 2.5) {
      complexityFactor *= 1.1; // 10% 느림
    }
    
    return RecipeAnalysis(
      hydration: hydration,
      yeastPercentage: yeastPercentage,
      saltPercentage: saltPercentage,
      complexityFactor: complexityFactor.clamp(0.6, 1.8),
    );
  }

  /// 환경 조건 계수 계산
  static double _calculateEnvironmentFactor(double temp, double humidity, double altitude) {
    // 온도 계수 (26°C 기준)
    double tempFactor = 1.0;
    if (temp > 26) {
      tempFactor = 1.0 - (temp - 26) * 0.03; // 온도 높으면 빨라짐
    } else if (temp < 26) {
      tempFactor = 1.0 + (26 - temp) * 0.04; // 온도 낮으면 느려짐
    }
    
    // 습도 계수 (65% 기준)
    double humidityFactor = 1.0;
    final humidityDiff = (humidity - 65).abs();
    humidityFactor = 1.0 + humidityDiff * 0.002; // 습도 차이가 클수록 약간 느려짐
    
    // 고도 계수
    double altitudeFactor = 1.0 - altitude * 0.00005; // 고도 높을수록 빨라짐
    
    return (tempFactor * humidityFactor * altitudeFactor).clamp(0.5, 2.0);
  }

  /// 각 단계별 기본 시간 계산
  static Map<FermentationStage, double> _calculateBaseTimes(
    List<FermentationStage> stages, 
    RecipeAnalysis analysis
  ) {
    final baseTimes = <FermentationStage, double>{};
    
    for (final stage in stages) {
      double baseTime = _getDefaultTime(stage);
      
      // 레시피 특성에 따른 조정
      switch (stage) {
        case FermentationStage.bulk:
          // 1차 발효는 이스트량에 가장 민감
          if (analysis.yeastPercentage > 1.2) {
            baseTime *= 0.8; // 이스트 많으면 빠름
          } else if (analysis.yeastPercentage < 0.8) {
            baseTime *= 1.4; // 이스트 적으면 느림
          }
          break;
          
        case FermentationStage.finalProof:
          // 최종 발효는 하이드레이션에 민감
          if (analysis.hydration > 70) {
            baseTime *= 0.9; // 수분 많으면 빠름
          } else if (analysis.hydration < 60) {
            baseTime *= 1.2; // 수분 적으면 느림
          }
          break;
          
        case FermentationStage.overnight:
          // 오버나이트는 이스트량을 줄여서 계산
          baseTime *= (2.0 - analysis.yeastPercentage).clamp(0.5, 1.5);
          break;
          
        default:
          // 다른 단계들은 기본 시간 사용
          break;
      }
      
      baseTimes[stage] = baseTime;
    }
    
    return baseTimes;
  }

  /// 기본 시간 반환 (분)
  static double _getDefaultTime(FermentationStage stage) {
    switch (stage) {
      case FermentationStage.bulk:
        return 90.0; // 1시간 30분
      case FermentationStage.secondary:
        return 60.0; // 1시간
      case FermentationStage.divided:
        return 20.0; // 20분
      case FermentationStage.shaped:
        return 15.0; // 15분
      case FermentationStage.finalProof:
        return 60.0; // 1시간
      case FermentationStage.overnight:
        return 480.0; // 8시간
      case FermentationStage.coldRetard:
        return 720.0; // 12시간
    }
  }

  /// 계산 세부사항 출력
  static void _printCalculationDetails(
    RecipeAnalysis analysis,
    double environmentFactor,
    Map<FermentationStage, double> baseTimes,
    Map<FermentationStage, double> adjustedTimes,
  ) {
    print('🧮 스마트 발효 시간 계산:');
    print('   📊 레시피 분석:');
    print('      - 하이드레이션: ${analysis.hydration.toStringAsFixed(1)}%');
    print('      - 이스트: ${analysis.yeastPercentage.toStringAsFixed(2)}%');
    print('      - 소금: ${analysis.saltPercentage.toStringAsFixed(2)}%');
    print('      - 복잡도 계수: ${analysis.complexityFactor.toStringAsFixed(3)}');
    print('   🌡️ 환경 계수: ${environmentFactor.toStringAsFixed(3)}');
    print('   ⏱️ 계산된 시간:');
    
    for (final stage in adjustedTimes.keys) {
      final baseTime = baseTimes[stage] ?? 0;
      final adjustedTime = adjustedTimes[stage] ?? 0;
      final stageName = _getStageName(stage);
      print('      - $stageName: ${baseTime.toInt()}분 → ${adjustedTime.toInt()}분');
    }
  }

  /// 단계 이름 반환
  static String _getStageName(FermentationStage stage) {
    switch (stage) {
      case FermentationStage.bulk:
        return '1차 발효';
      case FermentationStage.secondary:
        return '2차 발효';
      case FermentationStage.divided:
        return '분할 휴지';
      case FermentationStage.shaped:
        return '성형 휴지';
      case FermentationStage.finalProof:
        return '최종 발효';
      case FermentationStage.overnight:
        return '오버나이트';
      case FermentationStage.coldRetard:
        return '냉장 숙성';
    }
  }
}

/// 레시피 분석 결과
class RecipeAnalysis {
  final double hydration;
  final double yeastPercentage;
  final double saltPercentage;
  final double complexityFactor;

  const RecipeAnalysis({
    required this.hydration,
    required this.yeastPercentage,
    required this.saltPercentage,
    required this.complexityFactor,
  });
}