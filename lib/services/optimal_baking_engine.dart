/// 최적 굽기 조건 계산 엔진
/// 종합 제빵 과학 통합 계산식을 기반으로 반죽 상태에 따른 최적 굽기 조건 계산

import 'dart:math' as math;
import 'dart:developer' as developer;

// Phase 4: 재료 효과 통합을 위한 import 추가
import '../core/data/ingredient_effects_database.dart';
import '../core/types/ingredient_analysis_types.dart';
import '../services/dough_state_analyzer.dart';

class OptimalBakingEngine {
  /// 로깅을 위한 분석 세션 ID
  static String? _currentAnalysisSessionId;

  /// 로깅 헬퍼
  static void _log(String message, {String? level = 'INFO', dynamic data}) {
    final timestamp = DateTime.now().toIso8601String();
    final sessionId = _currentAnalysisSessionId ?? 'unknown';
    final logMessage =
        '[$timestamp] [OptimalBakingEngine] [$sessionId] [$level] $message';

    if (data != null) {
      print('$logMessage | Data: $data');
    } else {
      print(logMessage);
    }
  }

  /// 분석 세션 시작 로깅
  static void _startAnalysisSession() {
    _currentAnalysisSessionId =
        'baking_session_${DateTime.now().millisecondsSinceEpoch}';
    _log('=== 최적 굽기 조건 분석 세션 시작 ===', level: 'START');
  }

  /// 분석 세션 종료 로깅
  static void _endAnalysisSession({String? result = 'unknown', dynamic error}) {
    if (error != null) {
      _log('=== 최적 굽기 조건 분석 세션 실패 ===', level: 'ERROR', data: error);
    } else {
      _log('=== 최적 굽기 조건 분석 세션 완료 ===',
          level: 'SUCCESS', data: {'result': result});
    }
    _currentAnalysisSessionId = null;
  }

  /// 최적 굽기 조건 계산
  static OptimalBakingResult calculateOptimalBaking({
    required DoughStateAnalysisResult doughState,
    required List<Map<String, dynamic>> ingredients,
    required String ovenType,
    required String breadType,
    String? recipeTitle,
    double environmentTemperature = 25.0,
    double environmentHumidity = 65.0,
  }) {
    _startAnalysisSession();

    try {
      _log('최적 굽기 조건 계산 시작', data: {
        'oven_type': ovenType,
        'bread_type': breadType,
        'recipe_title': recipeTitle,
        'ingredients_count': ingredients.length,
        'environment_temp': environmentTemperature,
        'environment_humidity': environmentHumidity,
        'dough_state_score': doughState.overallDoughState,
      });

      // 1. 오븐 특성 계수 계산
      _log('오븐 특성 계수 계산 시작');
      final ovenCharacteristics = _calculateOvenCharacteristics(ovenType);
      _log('오븐 특성 계수 계산 완료', data: {
        'oven_characteristics': ovenCharacteristics,
      });

      // 2. 빵 종류별 기본 굽기 조건
      _log('빵 종류별 기본 굽기 조건 조회');
      final baseBakingConditions = _getBaseBakingConditions(breadType);
      _log('기본 굽기 조건 조회 완료', data: {
        'base_conditions': baseBakingConditions,
      });

      // 3. 반죽 상태 기반 조정
      _log('반죽 상태 기반 조정 계산');
      final doughAdjustments = _calculateDoughStateAdjustments(doughState);
      _log('반죽 상태 조정 계산 완료', data: {
        'dough_adjustments': doughAdjustments,
        'gluten_index': doughState.glutenStrengthIndex,
        'fermentation_progress': doughState.fermentationProgress,
      });

      // 4. 단계별 온도 프로파일 계산
      _log('단계별 온도 프로파일 계산 시작');
      final temperatureProfile = _calculateTemperatureProfile(
        baseBakingConditions,
        doughAdjustments,
        ovenCharacteristics,
        doughState,
      );
      _log('온도 프로파일 계산 완료', data: {
        'temperature_profile_keys': temperatureProfile.keys.toList(),
      });

      // 5. 총 굽기 시간 계산
      _log('총 굽기 시간 계산 시작');
      final totalBakingTime = _calculateTotalBakingTime(
        baseBakingConditions,
        doughAdjustments,
        ovenCharacteristics,
        doughState,
      );
      _log('총 굽기 시간 계산 완료', data: {
        'total_baking_time_minutes': totalBakingTime,
      });

      // 6. 스팀 설정 계산
      _log('스팀 설정 계산 시작');
      final steamSettings = _calculateSteamSettings(
        breadType,
        doughState,
        ovenCharacteristics,
        environmentHumidity,
      );
      _log('스팀 설정 계산 완료', data: {
        'steam_settings': steamSettings,
      });

      // 7. 굽기 성공 예측 지수
      _log('굽기 성공 예측 지수 계산 시작');
      final successPrediction = _calculateSuccessPrediction(
        doughState,
        temperatureProfile,
        totalBakingTime,
        ovenCharacteristics,
      );
      _log('성공 예측 지수 계산 완료', data: {
        'success_prediction': successPrediction,
      });

      final result = OptimalBakingResult(
        temperatureProfile: temperatureProfile,
        totalBakingTime: totalBakingTime,
        steamSettings: steamSettings,
        successPrediction: successPrediction,
        ovenType: ovenType,
        breadType: breadType,
        doughStateScore: doughState.overallDoughState,
        calculationTimestamp: DateTime.now(),
      );

      _log('최적 굽기 조건 계산 완료', data: {
        'final_result_summary': {
          'temperature_profile_phases': temperatureProfile.length,
          'total_baking_time': totalBakingTime,
          'success_prediction_percent': (successPrediction * 100).round(),
        },
      });

      _endAnalysisSession(result: 'baking_calculation_successful');
      return result;
    } catch (e) {
      _log('최적 굽기 조건 계산 오류', level: 'ERROR', data: {
        'error': e.toString(),
        'oven_type': ovenType,
        'bread_type': breadType,
        'dough_state': doughState.overallDoughState,
      });
      _endAnalysisSession(error: {
        'error_message': e.toString(),
        'phase': 'baking_calculation',
        'oven_type': ovenType,
        'bread_type': breadType,
      });
      return OptimalBakingResult.empty();
    }
  }

  /// 오븐 특성 계수 계산
  static Map<String, double> _calculateOvenCharacteristics(String ovenType) {
    switch (ovenType.toLowerCase()) {
      case 'home_convection':
      case '가정용컨벡션':
        return {
          'efficiency': 0.8,
          'heatRecovery': 0.7,
          'uniformity': 0.8,
          'steamCapability': 0.3,
          'temperatureStability': 0.7,
        };
      case 'professional_convection':
      case '전문가용컨벡션':
        return {
          'efficiency': 1.0,
          'heatRecovery': 0.9,
          'uniformity': 0.95,
          'steamCapability': 0.7,
          'temperatureStability': 0.9,
        };
      case 'deck_oven':
      case '덱오븐':
        return {
          'efficiency': 1.2,
          'heatRecovery': 1.0,
          'uniformity': 1.0,
          'steamCapability': 0.9,
          'temperatureStability': 1.0,
        };
      default:
        return {
          'efficiency': 1.0,
          'heatRecovery': 0.8,
          'uniformity': 0.8,
          'steamCapability': 0.5,
          'temperatureStability': 0.8,
        };
    }
  }

  /// 빵 종류별 기본 굽기 조건 (현실적인 값으로 수정)
  static Map<String, dynamic> _getBaseBakingConditions(String breadType) {
    switch (breadType.toLowerCase()) {
      case 'bread':
      case 'loaf':
      case '식빵':
        return {
          'baseTemperature': 180.0,
          'baseTime': 25.0, // 35분 → 25분으로 단축
          'steamTime': 3.0, // 5분 → 3분으로 단축
          'steamAmount': 30.0, // 50% → 30%로 감소
        };
      case 'baguette':
      case '바게트':
        return {
          'baseTemperature': 200.0, // 220°C → 200°C로 낮춤
          'baseTime': 20.0, // 25분 → 20분으로 단축
          'steamTime': 10.0, // 15분 → 10분으로 단축
          'steamAmount': 60.0, // 80% → 60%로 감소
        };
      default:
        return {
          'baseTemperature': 180.0,
          'baseTime': 25.0, // 30분 → 25분으로 단축
          'steamTime': 3.0, // 5분 → 3분으로 단축
          'steamAmount': 30.0, // 50% → 30%로 감소
        };
    }
  }

  /// 반죽 상태 기반 조정 계수 계산
  static Map<String, double> _calculateDoughStateAdjustments(
      DoughStateAnalysisResult doughState) {
    final glutenAdjustment = doughState.glutenStrengthIndex > 10.0
        ? 1.1
        : doughState.glutenStrengthIndex > 6.0
            ? 1.0
            : 0.9;

    final fermentationAdjustment = doughState.fermentationProgress > 0.8
        ? 0.9
        : doughState.fermentationProgress > 0.5
            ? 1.0
            : 1.1;

    return {
      'temperatureAdjustment': glutenAdjustment * fermentationAdjustment,
      'timeAdjustment': fermentationAdjustment,
    };
  }

  /// 단계별 온도 프로파일 계산 (현실적인 로직으로 수정)
  static Map<String, dynamic> _calculateTemperatureProfile(
    Map<String, dynamic> baseConditions,
    Map<String, double> adjustments,
    Map<String, double> ovenCharacteristics,
    DoughStateAnalysisResult doughState,
  ) {
    final baseTemp = baseConditions['baseTemperature'] as double;
    final tempAdjustment = adjustments['temperatureAdjustment']!;
    final ovenEfficiency = ovenCharacteristics['efficiency']!;

    // 오븐 효율이 높을수록 온도를 약간 낮춰도 됨 (나누기가 아닌 곱하기 보정)
    final efficiencyFactor = ovenEfficiency > 1.0 ? 0.95 : 1.0; // 고효율 오븐은 5% 낮춤

    // 현실적인 온도 프로파일: 초기 높음 → 중간 → 마지막 약간 낮춤
    final phase1Temp = (baseTemp + 10) *
        tempAdjustment *
        efficiencyFactor; // +20°C → +10°C로 수정
    final phase2Temp = baseTemp * tempAdjustment * efficiencyFactor;
    final phase3Temp =
        (baseTemp - 5) * tempAdjustment * efficiencyFactor; // -10°C → -5°C로 수정

    return {
      'phase1': {
        'temperature': phase1Temp.round().clamp(160, 220), // 온도 범위 제한
        'duration': 5,
        'description': '오븐 스프링 유도',
      },
      'phase2': {
        'temperature': phase2Temp.round().clamp(160, 200), // 온도 범위 제한
        'duration': 15,
        'description': '내부 익힘',
      },
      'phase3': {
        'temperature': phase3Temp.round().clamp(150, 190), // 온도 범위 제한
        'duration': 5, // 10분 → 5분으로 단축
        'description': '크러스트 완성',
      },
    };
  }

  /// 총 굽기 시간 계산 (현실적인 로직으로 수정)
  static int _calculateTotalBakingTime(
    Map<String, dynamic> baseConditions,
    Map<String, double> adjustments,
    Map<String, double> ovenCharacteristics,
    DoughStateAnalysisResult doughState,
  ) {
    final baseTime = baseConditions['baseTime'] as double;
    final timeAdjustment = adjustments['timeAdjustment']!;
    final ovenEfficiency = ovenCharacteristics['efficiency']!;

    // 오븐 효율이 높을수록 시간 단축 (나누기가 아닌 곱하기 보정)
    final efficiencyFactor = ovenEfficiency > 1.0 ? 0.9 : 1.0; // 고효율 오븐은 10% 단축

    final adjustedTime = baseTime * timeAdjustment * efficiencyFactor;
    return adjustedTime.round().clamp(15, 45); // 15-45분 범위로 제한
  }

  /// 스팀 설정 계산 (현실적인 로직으로 수정)
  static Map<String, dynamic> _calculateSteamSettings(
    String breadType,
    DoughStateAnalysisResult doughState,
    Map<String, double> ovenCharacteristics,
    double environmentHumidity,
  ) {
    final steamCapability = ovenCharacteristics['steamCapability']!;

    // 가정용 오븐은 스팀 기능이 제한적
    if (steamCapability < 0.5) {
      return {
        'duration': 0,
        'amount': 0,
        'method': '물그릇 사용 권장',
      };
    }

    // 빵 종류별 기본 스팀 설정 (현실적인 값)
    double baseSteamTime = 3.0; // 5분 → 3분으로 단축
    double baseSteamAmount = 20.0; // 50% → 20%로 감소

    if (breadType.toLowerCase().contains('baguette') ||
        breadType.toLowerCase().contains('바게트')) {
      baseSteamTime = 8.0; // 15분 → 8분으로 단축
      baseSteamAmount = 40.0; // 80% → 40%로 감소
    }

    // 환경 습도가 높으면 스팀 감소
    final humidityFactor = environmentHumidity > 70 ? 0.7 : 1.0;

    final finalSteamTime =
        (baseSteamTime * steamCapability * humidityFactor).round();
    final finalSteamAmount =
        (baseSteamAmount * steamCapability * humidityFactor).round();

    return {
      'duration': finalSteamTime.clamp(0, 10), // 최대 10분
      'amount': finalSteamAmount.clamp(0, 50), // 최대 50%
      'method': finalSteamTime > 0 ? '초기 스팀 분사' : '스팀 없음',
    };
  }

  /// 굽기 성공 예측 지수 계산
  static double _calculateSuccessPrediction(
    DoughStateAnalysisResult doughState,
    Map<String, dynamic> temperatureProfile,
    int totalBakingTime,
    Map<String, double> ovenCharacteristics,
  ) {
    final doughScore = [
          doughState.glutenStrengthIndex / 15.0,
          doughState.fermentationProgress,
          doughState.gasRetentionIndex,
          doughState.elasticityIndex,
        ].reduce((a, b) => a + b) /
        4;

    final ovenScore = [
          ovenCharacteristics['efficiency']!,
          ovenCharacteristics['uniformity']!,
          ovenCharacteristics['temperatureStability']!,
        ].reduce((a, b) => a + b) /
        3;

    final conditionScore =
        totalBakingTime > 10 && totalBakingTime < 90 ? 1.0 : 0.8;

    final overallScore =
        (doughScore * 0.4) + (ovenScore * 0.3) + (conditionScore * 0.3);
    return overallScore.clamp(0.0, 1.0);
  }
}

/// 최적 굽기 결과 클래스
class OptimalBakingResult {
  final Map<String, dynamic> temperatureProfile;
  final int totalBakingTime;
  final Map<String, dynamic> steamSettings;
  final double successPrediction;
  final String ovenType;
  final String breadType;
  final String doughStateScore;
  final DateTime calculationTimestamp;

  OptimalBakingResult({
    required this.temperatureProfile,
    required this.totalBakingTime,
    required this.steamSettings,
    required this.successPrediction,
    required this.ovenType,
    required this.breadType,
    required this.doughStateScore,
    required this.calculationTimestamp,
  });

  /// 빈 결과 생성 (오류 시 사용)
  factory OptimalBakingResult.empty() {
    return OptimalBakingResult(
      temperatureProfile: {},
      totalBakingTime: 30,
      steamSettings: {},
      successPrediction: 0.0,
      ovenType: "알 수 없음",
      breadType: "알 수 없음",
      doughStateScore: "분석 불가",
      calculationTimestamp: DateTime.now(),
    );
  }

  /// 성공 예측 텍스트
  String get successPredictionText {
    if (successPrediction >= 0.9)
      return "매우 높음 (${(successPrediction * 100).toStringAsFixed(0)}%)";
    if (successPrediction >= 0.7)
      return "높음 (${(successPrediction * 100).toStringAsFixed(0)}%)";
    if (successPrediction >= 0.5)
      return "보통 (${(successPrediction * 100).toStringAsFixed(0)}%)";
    if (successPrediction >= 0.3)
      return "낮음 (${(successPrediction * 100).toStringAsFixed(0)}%)";
    return "매우 낮음 (${(successPrediction * 100).toStringAsFixed(0)}%)";
  }

  /// 온도 프로파일 요약 텍스트
  String get temperatureProfileSummary {
    if (temperatureProfile.isEmpty) return "계산 불가";

    final phase1 = temperatureProfile['phase1'] as Map<String, dynamic>? ?? {};
    final phase2 = temperatureProfile['phase2'] as Map<String, dynamic>? ?? {};
    final phase3 = temperatureProfile['phase3'] as Map<String, dynamic>? ?? {};

    return "${phase1['temperature'] ?? 0}°C → ${phase2['temperature'] ?? 0}°C → ${phase3['temperature'] ?? 0}°C";
  }

  /// 스팀 설정 요약 텍스트
  String get steamSettingsSummary {
    if (steamSettings.isEmpty) return "스팀 없음";

    final duration = steamSettings['duration'] as int? ?? 0;
    final amount = steamSettings['amount'] as int? ?? 0;

    if (duration == 0) return "스팀 없음";
    return "${duration}분간 ${amount}% 스팀";
  }
}

/// Phase 4 확장: 재료 효과를 고려한 최적 굽기 엔진
extension OptimalBakingEngineWithEffects on OptimalBakingEngine {
  /// 재료 효과를 고려한 최적 굽기 조건 계산 (Phase 4 확장 기능)
  static Future<OptimalBakingResult>
      calculateOptimalBakingWithIngredientEffects({
    required DoughStateAnalysisResult doughState,
    required List<Map<String, dynamic>> ingredients,
    required String ovenType,
    required String breadType,
    ComprehensiveIngredientAnalysis? ingredientAnalysis,
    String? recipeTitle,
    double environmentTemperature = 25.0,
    double environmentHumidity = 65.0,
    String? breadTypeOverride,
    Duration? cacheExpiration,
  }) async {
    try {
      // 1. 재료 분석 수행 (제공되지 않은 경우)
      final analysis = ingredientAnalysis ??
          await _performIngredientAnalysisForBaking(
            ingredients: ingredients,
            breadType: breadTypeOverride ?? breadType,
            recipeTitle: recipeTitle,
            cacheExpiration: cacheExpiration,
          );

      // 2. 재료 효과 기반 조정 계수 계산
      final ingredientAdjustments = _calculateIngredientEffectAdjustments(
        ingredientEffects: analysis.fermentationEffects,
        mixingEffects: analysis.mixingEffects,
        doughEffects: analysis.doughEffects,
      );

      // 3. 기존 계산 수행
      final baseResult = calculateOptimalBaking(
        doughState: doughState,
        ingredients: ingredients,
        ovenType: ovenType,
        breadType: breadType,
        recipeTitle: recipeTitle,
        environmentTemperature: environmentTemperature,
        environmentHumidity: environmentHumidity,
      );

      // 4. 재료 효과 기반 최적화 적용
      final optimizedResult = _applyIngredientEffectOptimizations(
        baseResult: baseResult,
        ingredientAdjustments: ingredientAdjustments,
        ingredientEffects: analysis.fermentationEffects,
        mixingEffects: analysis.mixingEffects,
        doughEffects: analysis.doughEffects,
        doughState: doughState,
      );

      return optimizedResult;
    } catch (e) {
      developer.log('❌ [OPTIMAL BAKING ENGINE] 재료 효과 분석 실패: $e');
      // 폴백: 기본 계산
      return calculateOptimalBaking(
        doughState: doughState,
        ingredients: ingredients,
        ovenType: ovenType,
        breadType: breadType,
        recipeTitle: recipeTitle,
        environmentTemperature: environmentTemperature,
        environmentHumidity: environmentHumidity,
      );
    }
  }

  /// 굽기용 재료 분석 수행 헬퍼
  static Future<ComprehensiveIngredientAnalysis>
      _performIngredientAnalysisForBaking({
    required List<Map<String, dynamic>> ingredients,
    required String breadType,
    String? recipeTitle,
    Duration? cacheExpiration,
  }) async {
    try {
      // IngredientAnalysisHub를 통한 통합 분석
      final cachedAnalysis = CachedIngredientAnalysis(
        AnalysisCacheManager.instance,
        IngredientAnalysisHub.instance,
      );

      // List<Map<String, dynamic>>을 UnifiedRecipe로 변환 (간단한 변환)
      final unifiedIngredients = ingredients.map((ing) {
        return UnifiedIngredient(
          id: 'temp_${ing['name'].hashCode}',
          name: ing['name'] as String,
          amount: (ing['amount'] as num).toDouble(),
          unit: ing['unit'] as String,
          properties: ing['properties'] as Map<String, dynamic>? ?? {},
        );
      }).toList();

      final unifiedRecipe = UnifiedRecipe(
        id: 'baking_recipe_${DateTime.now().millisecondsSinceEpoch}',
        title: recipeTitle ?? '굽기 분석용 레시피',
        ingredients: unifiedIngredients,
        processes: [],
        metadata: {'breadType': breadType},
      );

      final analysis = await cachedAnalysis.analyzeWithCache(
        ingredients: unifiedRecipe.ingredients,
        breadType: breadType,
        recipeTitle: recipeTitle ?? unifiedRecipe.title,
        cacheExpiration: cacheExpiration,
      );

      return analysis;
    } catch (e) {
      developer.log('❌ [BAKING ANALYSIS] 분석 실패: $e');
      throw Exception('굽기용 재료 분석 수행 중 오류 발생: $e');
    }
  }

  /// 재료 효과 기반 조정 계수 계산
  static Map<String, double> _calculateIngredientEffectAdjustments({
    required Map<String, dynamic> ingredientEffects,
    required Map<String, dynamic> mixingEffects,
    required Map<String, dynamic> doughEffects,
  }) {
    // 시럽의 갈변 효과 (browningEffect) - 온도 조정
    final browningEffect =
        ingredientEffects['browningEffect'] as double? ?? 1.0;
    final temperatureAdjustment = browningEffect > 1.1
        ? 0.95
        : // 갈변 효과 좋음: 온도 낮춤
        browningEffect < 0.9
            ? 1.05
            : // 갈변 효과 약함: 온도 높임
            1.0;

    // 지방의 굽기 효과 (bakingEffect) - 시간 조정
    final bakingEffect = mixingEffects['bakingEffect'] as double? ?? 1.0;
    final timeAdjustment = bakingEffect > 1.1
        ? 0.9
        : // 겉바속촉 효과 좋음: 시간 단축
        bakingEffect < 0.9
            ? 1.1
            : // 겉바속촉 효과 약함: 시간 연장
            1.0;

    // 글루텐 형성 효과 (glutenImpact) - 온도/시간 복합 조정
    final glutenImpact = mixingEffects['glutenImpact'] as double? ?? 1.0;
    final glutenAdjustment = glutenImpact > 1.1
        ? 0.97
        : // 글루텐 강함: 약간 낮은 온도
        glutenImpact < 0.9
            ? 1.03
            : // 글루텐 약함: 약간 높은 온도
            1.0;

    // 가스 유지력 효과 (gasRetentionEffect) - 스팀 조정
    final gasRetentionEffect =
        doughEffects['gasRetentionEffect'] as double? ?? 1.0;
    final steamAdjustment = gasRetentionEffect > 1.1
        ? 0.9
        : // 가스 유지력 좋음: 스팀 감소
        gasRetentionEffect < 0.9
            ? 1.1
            : // 가스 유지력 약함: 스팀 증가
            1.0;

    return {
      'temperatureAdjustment': temperatureAdjustment * glutenAdjustment,
      'timeAdjustment': timeAdjustment,
      'steamAdjustment': steamAdjustment,
      'browningEffect': browningEffect,
      'bakingEffect': bakingEffect,
      'glutenImpact': glutenImpact,
      'gasRetentionEffect': gasRetentionEffect,
    };
  }

  /// 재료 효과 기반 최적화 적용
  static OptimalBakingResult _applyIngredientEffectOptimizations({
    required OptimalBakingResult baseResult,
    required Map<String, double> ingredientAdjustments,
    required Map<String, dynamic> ingredientEffects,
    required Map<String, dynamic> mixingEffects,
    required Map<String, dynamic> doughEffects,
    required DoughStateAnalysisResult doughState,
  }) {
    // 1. 온도 프로파일 최적화
    final optimizedTemperatureProfile = _optimizeTemperatureProfileWithEffects(
      baseResult.temperatureProfile,
      ingredientAdjustments,
      doughState,
    );

    // 2. 굽기 시간 최적화
    final optimizedBakingTime = _optimizeBakingTimeWithEffects(
      baseResult.totalBakingTime,
      ingredientAdjustments,
      doughState,
    );

    // 3. 스팀 설정 최적화
    final optimizedSteamSettings = _optimizeSteamSettingsWithEffects(
      baseResult.steamSettings,
      ingredientAdjustments,
      doughEffects,
    );

    // 4. 성공 예측 향상
    final optimizedSuccessPrediction = _enhanceSuccessPredictionWithEffects(
      baseResult.successPrediction,
      ingredientAdjustments,
      doughState,
    );

    // 5. 최적화 추천사항 생성
    final optimizationRecommendations =
        _generateBakingOptimizationRecommendations(
      ingredientAdjustments,
      ingredientEffects,
      mixingEffects,
      doughEffects,
    );

    return OptimalBakingResult(
      temperatureProfile: optimizedTemperatureProfile,
      totalBakingTime: optimizedBakingTime,
      steamSettings: optimizedSteamSettings,
      successPrediction: optimizedSuccessPrediction,
      ovenType: baseResult.ovenType,
      breadType: baseResult.breadType,
      doughStateScore: baseResult.doughStateScore,
      calculationTimestamp: DateTime.now(),
      // Phase 4 확장 데이터 추가
      optimizationMetadata: {
        'ingredientAdjustments': ingredientAdjustments,
        'optimizationRecommendations': optimizationRecommendations,
        'effectsApplied': true,
      },
    );
  }

  /// 효과 기반 온도 프로파일 최적화
  static Map<String, dynamic> _optimizeTemperatureProfileWithEffects(
    Map<String, dynamic> baseProfile,
    Map<String, double> adjustments,
    DoughStateAnalysisResult doughState,
  ) {
    final optimizedProfile = <String, dynamic>{};
    final tempAdjustment = adjustments['temperatureAdjustment']!;
    final browningEffect = adjustments['browningEffect']!;

    for (final phase in ['phase1', 'phase2', 'phase3']) {
      final basePhase = baseProfile[phase] as Map<String, dynamic>? ?? {};
      if (basePhase.isEmpty) continue;

      final baseTemp = basePhase['temperature'] as int;
      final duration = basePhase['duration'] as int;

      // 단계별 온도 조정
      double phaseTempAdjustment = tempAdjustment;
      if (phase == 'phase1' && browningEffect > 1.1) {
        // 초기 단계에서 갈변 효과가 좋으면 온도를 낮춰서 제어
        phaseTempAdjustment *= 0.97;
      } else if (phase == 'phase3' && browningEffect < 0.9) {
        // 마지막 단계에서 갈변 효과가 약하면 온도를 높여서 보완
        phaseTempAdjustment *= 1.03;
      }

      final optimizedTemp =
          (baseTemp * phaseTempAdjustment).round().clamp(150, 220);

      optimizedProfile[phase] = {
        'temperature': optimizedTemp,
        'duration': duration,
        'description': basePhase['description'],
        'effectAdjustment': phaseTempAdjustment,
      };
    }

    return optimizedProfile;
  }

  /// 효과 기반 굽기 시간 최적화
  static int _optimizeBakingTimeWithEffects(
    int baseTime,
    Map<String, double> adjustments,
    DoughStateAnalysisResult doughState,
  ) {
    final timeAdjustment = adjustments['timeAdjustment']!;
    final bakingEffect = adjustments['bakingEffect']!;

    // 기본 시간 조정
    double optimizedTime = baseTime * timeAdjustment;

    // 지방의 굽기 효과에 따른 추가 조정
    if (bakingEffect > 1.1) {
      // 겉바속촉 효과가 좋음: 시간을 단축하되 최소 시간 유지
      optimizedTime *= 0.95;
    } else if (bakingEffect < 0.9) {
      // 겉바속촉 효과가 약함: 시간을 늘림
      optimizedTime *= 1.05;
    }

    // 반죽 상태 고려
    if (doughState.fermentationProgress > 0.8) {
      // 발효가 충분히 진행됨: 시간 단축
      optimizedTime *= 0.95;
    } else if (doughState.fermentationProgress < 0.5) {
      // 발효가 부족함: 시간 연장
      optimizedTime *= 1.05;
    }

    return optimizedTime.round().clamp(15, 60); // 15-60분 범위로 제한
  }

  /// 효과 기반 스팀 설정 최적화
  static Map<String, dynamic> _optimizeSteamSettingsWithEffects(
    Map<String, dynamic> baseSteamSettings,
    Map<String, double> adjustments,
    Map<String, dynamic> doughEffects,
  ) {
    final steamAdjustment = adjustments['steamAdjustment']!;
    final gasRetentionEffect = adjustments['gasRetentionEffect']!;

    final optimizedSettings = Map<String, dynamic>.from(baseSteamSettings);

    // 스팀 시간 조정
    if (optimizedSettings.containsKey('duration')) {
      final baseDuration = optimizedSettings['duration'] as int;
      final optimizedDuration =
          (baseDuration * steamAdjustment).round().clamp(0, 15);
      optimizedSettings['duration'] = optimizedDuration;
    }

    // 스팀 양 조정
    if (optimizedSettings.containsKey('amount')) {
      final baseAmount = optimizedSettings['amount'] as int;
      final amountAdjustment = gasRetentionEffect > 1.1
          ? 0.9
          : // 가스 유지력 좋음: 스팀 감소
          gasRetentionEffect < 0.9
              ? 1.1
              : // 가스 유지력 약함: 스팀 증가
              1.0;
      final optimizedAmount =
          (baseAmount * amountAdjustment).round().clamp(0, 80);
      optimizedSettings['amount'] = optimizedAmount;
    }

    // 효과 기반 설명 추가
    if (gasRetentionEffect > 1.1) {
      optimizedSettings['effectNote'] = '가스 유지력이 우수하여 스팀을 적게 사용';
    } else if (gasRetentionEffect < 0.9) {
      optimizedSettings['effectNote'] = '가스 유지력이 약하여 스팀을 늘려 보완';
    }

    return optimizedSettings;
  }

  /// 효과 기반 성공 예측 향상
  static double _enhanceSuccessPredictionWithEffects(
    double basePrediction,
    Map<String, double> adjustments,
    DoughStateAnalysisResult doughState,
  ) {
    double enhancedPrediction = basePrediction;

    // 시럽의 갈변 효과 고려
    final browningEffect = adjustments['browningEffect']!;
    if (browningEffect > 1.1) {
      enhancedPrediction += 0.05; // 갈변 효과 좋음: 성공률 증가
    } else if (browningEffect < 0.9) {
      enhancedPrediction -= 0.05; // 갈변 효과 약함: 성공률 감소
    }

    // 지방의 굽기 효과 고려
    final bakingEffect = adjustments['bakingEffect']!;
    if (bakingEffect > 1.1) {
      enhancedPrediction += 0.05; // 겉바속촉 효과 좋음: 성공률 증가
    } else if (bakingEffect < 0.9) {
      enhancedPrediction -= 0.05; // 겉바속촉 효과 약함: 성공률 감소
    }

    // 글루텐 형성 효과 고려
    final glutenImpact = adjustments['glutenImpact']!;
    if (glutenImpact > 1.1) {
      enhancedPrediction += 0.03; // 글루텐 형성 좋음: 성공률 증가
    } else if (glutenImpact < 0.9) {
      enhancedPrediction -= 0.03; // 글루텐 형성 약함: 성공률 감소
    }

    return enhancedPrediction.clamp(0.0, 1.0);
  }

  /// 굽기 최적화 추천사항 생성
  static List<String> _generateBakingOptimizationRecommendations(
    Map<String, double> adjustments,
    Map<String, dynamic> ingredientEffects,
    Map<String, dynamic> mixingEffects,
    Map<String, dynamic> doughEffects,
  ) {
    final recommendations = <String>[];

    // 시럽 효과 기반 추천
    final browningEffect = adjustments['browningEffect']!;
    if (browningEffect > 1.1) {
      recommendations.add('시럽의 갈변 효과가 우수하므로 초기 온도를 낮춰 과도한 갈변을 방지하세요');
    } else if (browningEffect < 0.9) {
      recommendations.add('시럽의 갈변 효과가 약하므로 마지막 단계 온도를 높여 충분한 갈변을 유도하세요');
    }

    // 지방 효과 기반 추천
    final bakingEffect = adjustments['bakingEffect']!;
    if (bakingEffect > 1.1) {
      recommendations.add('지방의 겉바속촉 효과가 우수하므로 굽기 시간을 5-10% 단축할 수 있습니다');
    } else if (bakingEffect < 0.9) {
      recommendations.add('지방의 겉바속촉 효과가 약하므로 굽기 시간을 5-10% 연장하세요');
    }

    // 글루텐 효과 기반 추천
    final glutenImpact = adjustments['glutenImpact']!;
    if (glutenImpact > 1.1) {
      recommendations.add('글루텐 형성이 우수하므로 오븐 스프링을 극대화할 수 있습니다');
    } else if (glutenImpact < 0.9) {
      recommendations.add('글루텐 형성이 약하므로 온도를 안정적으로 유지하세요');
    }

    // 가스 유지력 효과 기반 추천
    final gasRetentionEffect = adjustments['gasRetentionEffect']!;
    if (gasRetentionEffect > 1.1) {
      recommendations.add('가스 유지력이 우수하므로 최적의 부피 확보가 가능합니다');
    } else if (gasRetentionEffect < 0.9) {
      recommendations.add('가스 유지력이 약하므로 스팀을 늘려 부피 손실을 보완하세요');
    }

    return recommendations;
  }
}
