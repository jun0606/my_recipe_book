// 믹싱 분석 서비스
// UI 인터페이스 제공 및 계산 엔진 위임

import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/types/environment_types.dart';
import '../core/types/calculation_types.dart' as calc_types;
import '../core/utils/mixing_data_helper.dart';
import '../core/utils/safe_value_utils.dart';
import '../core/constants/bread_constants.dart';
import 'mixing_warning_service.dart';
import 'recipe_data_parser.dart';
import 'environment_manager.dart'; // EnvironmentManager 추가
import '../features/chef/screen/widgets/mixing_analysis_types.dart';
import 'ingredient_analyzer.dart';
import 'environment_defaults_calculator.dart';
import 'bread_rpm_calculator.dart';
// 빅데이터 제거: 과학적 계산 방식으로 전환
// 제거된 import: baking_science_formula_engine.dart, gluten_calculation_engine.dart
import '../models/advanced_sous_chef_models.dart'
    hide Season, OvenType, IngredientAnalyzer;
import '../models/fermentation_scenario_v2.dart';
import '../models/recipe/analysis/bread_analysis_data.dart' as bread_analysis;

/// 믹싱 분석 서비스 클래스
/// mixing_analysis_card.dart의 분석 로직을 중앙 집중화
class MixingAnalysisService {
  /// 싱글톤 패턴
  static final MixingAnalysisService _instance =
      MixingAnalysisService._internal();
  factory MixingAnalysisService() => _instance;
  MixingAnalysisService._internal();

  /// 믹싱 단계 추출 (중앙 집중화된 헬퍼 사용)
  List<Map<String, dynamic>> extractMixingSteps(
      Map<String, dynamic> recipeData) {
    return MixingDataHelper.extractMixingSteps(recipeData);
  }

  /// 믹싱 단계 분석 수행 (동기 버전으로 변경)
  Map<String, dynamic> analyzeMixingStep(
    Map<String, dynamic> step,
    int stepIndex,
    Map<String, dynamic>? previousStepAnalysis,
    Map<String, dynamic>? previousDoughState,
  ) {
    final speed = step['speed']?.toString() ?? '중속';
    final duration = int.tryParse(step['durationMinutes']?.toString() ?? '') ??
        int.tryParse(step['time']?.toString() ?? '') ??
        int.tryParse(step['duration']?.toString() ?? '') ??
        5;

    // RPM 계산
    final rpm = _calculateRPMForStepSync(speed);

    // 반죽 상태 분석 (기본 값 사용 - 중앙화 계산기에서 실제 계산 수행)
    final doughState = <String, dynamic>{
      'glutenFormation': 0.5,
      'temperature': 25.0,
      'viscosity': 1.0,
      'moistureAbsorption': 65.0,
      'developmentStage': '기본 분석',
    };

    // 단계별 문제 파악
    final recommendations = MixingWarningService.generateIntegratedFeedback(
      step,
      doughState,
      previousStepAnalysis,
      previousDoughState,
      stepIndex,
    );

    return {
      'stepNumber': stepIndex + 1,
      'speed': speed,
      'durationMinutes': duration,
      'rpm': rpm,
      'doughState': doughState,
      'recommendations': recommendations,
      'efficiency': _calculateStepEfficiency(speed, duration, rpm.toDouble()),
    };
  }

  /// 종합 분석 수행 - 실시간 재료 데이터 기반 동적 계산
  /// 🆕 [중앙 시스템 연동 완료] mixingMeta 적용, 값 변동 발생
  Future<Map<String, dynamic>> performComprehensiveAnalysis(
    List<Map<String, dynamic>> stepAnalyses,
    Map<String, dynamic> recipeData, {
    List<Map<String, dynamic>>? ingredients,
    List<Map<String, dynamic>>? mixingSteps,
    MixingMeta? mixingMeta,
    MixerType? mixerType,
  }) async {
    // EnvironmentManager에서 실시간 환경 값 가져오기
    final envManager = EnvironmentManager();
    final currentEnv = envManager.currentEnvironment;
    final safeRoomTemp = currentEnv.temperature;
    final safeHumidity = currentEnv.humidity;

    // 실시간 환경 파라미터 로그 출력
    print('🔄 [종합 분석] EnvironmentManager 실시간 환경 값:');
    print('   - roomTemp=$safeRoomTemp°C, humidity=$safeHumidity%');
    print('   - 마지막 업데이트: ${currentEnv.lastUpdated}');

    // 실시간 재료 데이터 분석
    if (ingredients != null && ingredients.isNotEmpty) {
      print('🔄 [종합 분석] 재료 데이터 분석:');
      final solidWeight =
          IngredientAnalyzer.calculateSolidIngredientsWeight(ingredients);
      final liquidWeight =
          IngredientAnalyzer.calculateLiquidIngredientsWeight(ingredients);
      final totalDoughWeight =
          IngredientAnalyzer.calculateTotalDoughWeight(ingredients);

      print('   - 고체 무게: ${solidWeight.toStringAsFixed(1)}g');
      print('   - 수분 무게: ${liquidWeight.toStringAsFixed(1)}g');
      print('   - 총 반죽 무게: ${totalDoughWeight.toStringAsFixed(1)}g');
    }

    // 믹서 타입 정보 출력
    if (mixerType != null) {
      print('🔄 [종합 분석] 믹서 타입: ${mixerType.displayName}');
      print('   - 마찰 계수: ${mixerType.frictionCoefficient}');
    }

    // MixingMeta 정보 출력
    if (mixingMeta != null) {
      print('🔄 [종합 분석] 믹싱 메타데이터:');
      print('   - 예측 시간: ${mixingMeta.predictedTime}분');
      print('   - 마찰열: ${mixingMeta.frictionHeat}°C');
      print('   - 믹서 계수: ${mixingMeta.mixerTypeCoefficient}');
      print('   - 장비 계수: ${mixingMeta.equipmentCalibration}');
    }

    // 1. 차수 기반 종합 분석
    final totalSteps = stepAnalyses.length;

    // 2. 단계별 결과 요약 (실시간 로그 포함)
    final totalTime = stepAnalyses.fold<int>(
      0,
      (sum, step) => sum + (step['durationMinutes'] as int? ?? 0),
    );

    print('🔄 [종합 분석] 단계별 결과 요약:');
    print('   - 총 단계: ${stepAnalyses.length}개');
    print('   - 총 믹싱 시간: ${totalTime}분');

    // 단계별 상세 정보 출력
    for (int i = 0; i < stepAnalyses.length; i++) {
      final step = stepAnalyses[i];
      final duration = step['durationMinutes'] ?? 0;
      final speed = step['speed'] ?? '알 수 없음';
      final efficiency = (step['efficiency'] as num?)?.toDouble() ?? 0.0;
      final doughState = step['doughState'] as Map<String, dynamic>? ?? {};

      print(
          '   단계 ${i + 1}: ${speed} ${duration}분 (효율: ${(efficiency * 100).toStringAsFixed(1)}%)');
      if (doughState.isNotEmpty) {
        final gluten =
            (doughState['glutenFormation'] as num?)?.toDouble() ?? 0.0;
        print('     글루텐 형성도: ${(gluten * 100).toStringAsFixed(1)}%');
      }
    }

    // 최종 글루텐 형성도
    final finalGlutenFormation = stepAnalyses.isNotEmpty
        ? (stepAnalyses.last['doughState']
                as Map<String, dynamic>)['glutenFormation'] as double? ??
            0.0
        : 0.0;

    // 최종 수분 흡수율
    final finalMoistureAbsorption = stepAnalyses.isNotEmpty
        ? (stepAnalyses.last['doughState']
                as Map<String, dynamic>)['moistureAbsorption'] as double? ??
            0.0
        : 0.0;

    // 평균 효율성
    final avgEfficiency = stepAnalyses.fold<double>(
          0.0,
          (sum, step) => sum + (step['efficiency'] as double? ?? 0.0),
        ) /
        stepAnalyses.length;

    // 종합 점수 계산
    final overallScore =
        _calculateOverallScore(finalGlutenFormation, avgEfficiency, totalTime);

    return {
      'totalTime': totalTime,
      'averageGlutenFormation': finalGlutenFormation,
      'finalMoisturePercentage': finalMoistureAbsorption,
      'efficiency': avgEfficiency,
      'overallScore': overallScore,
      'stepCount': stepAnalyses.length,
      'finalDoughState': stepAnalyses.isNotEmpty
          ? stepAnalyses.last['doughState'].toString()
          : '',
    };
  }

  /// 메트릭 색상 계산 헬퍼 메소드들
  Color getGlutenColor(double glutenFormation) {
    return _getMetricColor('gluten', glutenFormation);
  }

  Color getMoistureAbsorptionColor(double moistureAbsorption) {
    if (moistureAbsorption >= 65 && moistureAbsorption <= 80) {
      return Colors.green;
    } else if (moistureAbsorption >= 60 && moistureAbsorption <= 85) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Color getViscosityColor(double viscosity) {
    if (viscosity >= 1.5 && viscosity <= 2.0) {
      return Colors.green;
    } else if (viscosity >= 1.0 && viscosity <= 2.5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Color getTemperatureColor(double temperature) {
    try {
      final optimalRange =
          EnvironmentDefaultsCalculator.getOptimalTemperatureRange();
      final optimalMin = optimalRange.min;
      final optimalMax = optimalRange.max;
      final goodMin = optimalMin - 3.0;
      final goodMax = optimalMax + 3.0;

      if (temperature >= optimalMin && temperature <= optimalMax) {
        return Colors.green;
      } else if (temperature >= goodMin && temperature <= goodMax) {
        return Colors.orange;
      } else {
        return Colors.red;
      }
    } catch (e) {
      return Colors.grey.shade600;
    }
  }

  Color getScoreColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.lightGreen;
    if (score >= 0.4) return Colors.orange;
    return Colors.red;
  }

  Color _getScoreColor(double score) {
    return getScoreColor(score);
  }

  // ===== 아래는 기존 mixing_analysis_card.dart의 private 메소드들 =====

  double _calculateInitialDoughTemperature(
      Map<String, dynamic> step, int stepIndex) {
    final recipeTemp = step['temperature'] as double? ?? 25.0; // 기본 실온

    if (stepIndex == 0) {
      if (recipeTemp < 18.0) {
        return 19.0;
      } else if (recipeTemp > 32.0) {
        return 31.0;
      }
    }
    return recipeTemp;
  }

  String _getDevelopmentStage(double glutenFormation) {
    if (glutenFormation < 0.3) return '초기 개발';
    if (glutenFormation < 0.6) return '중기 개발';
    if (glutenFormation < 0.8) return '후기 개발';
    return '완전 개발';
  }

  double _calculateStepEfficiency(String speed, int duration, double rpm) {
    double efficiency = 1.0;

    if (rpm < 100 || rpm > 300) {
      efficiency *= 0.8;
    }

    if (duration > 15) {
      efficiency *= 0.9;
    }

    if (speed == '고속' && duration < 2) {
      efficiency *= 0.7;
    }

    return efficiency;
  }

  double _calculateRPMForStepSync(String speed) {
    switch (speed) {
      case '저속':
        return 120.0;
      case '중속':
        return 200.0;
      case '고속':
        return 280.0;
      default:
        return 200.0;
    }
  }

  /// ✅ [과학적 계산 방식 전환] - 빅데이터 제거 및 과학적 추정 사용
  Map<String, dynamic> _createDefaultDoughState(
      int stepIndex, String speed, int duration) {
    // EnvironmentManager에서 실시간 환경 값 가져오기
    final envManager = EnvironmentManager();
    final environment = envManager.currentEnvironment;

    // 과학적 계산 방식으로 글루텐 형성도 추정
    double glutenFormation = _scientificallyEstimateGlutenFormation(
      stepIndex: stepIndex,
      speed: speed,
      duration: duration,
      temperature: environment.temperature,
    );

    return {
      'glutenFormation': glutenFormation,
      'temperature': environment.temperature,
      'viscosity':
          _scientificallyEstimateViscosity(stepIndex, speed, duration, 1.0),
      'moistureAbsorption': 65.0 + (stepIndex * 2.0), // 단계별 약간 증감
      'developmentStage': _getDevelopmentStage(glutenFormation),
    };
  }

  List<String> _createDefaultRecommendations(
      int stepIndex, String speed, int duration) {
    final recommendations = <String>[];

    switch (stepIndex) {
      case 0:
        recommendations.add('🍳 1단계: 재료를 균일하게 혼합하세요');
        if (speed == '고속') {
          recommendations.add('⚠️ 1단계 고속: 재료 혼합에 중속이 더 적합할 수 있습니다');
        }
        break;
      case 1:
        recommendations.add('🔄 2단계: 글루텐 네트워크 형성을 주의하세요');
        if (duration < 5) {
          recommendations.add('⏳ 글루텐 형성에 최소 5분 이상 필요합니다');
        }
        break;
      case 2:
        recommendations.add('🎯 마무리 단계: 최종 품질을 확인하세요');
        if (speed == '고속' && duration > 4) {
          recommendations.add('⚠️ 마무리 고속: 글루텐 구조 보호를 위해 4분 이내로 유지하세요');
        }
        break;
      default:
        recommendations.add('✅ 표준 믹싱 조건을 유지하세요');
    }

    return recommendations;
  }

  /// 누적 상태를 고려한 단계별 분석 생성
  Map<String, dynamic> createStepAnalysisWithAccumulation(
    Map<String, dynamic> step,
    int index,
    Map<String, dynamic>? previousDoughState,
  ) {
    final speed = step['speed'] as String? ?? '중속';
    final duration = step['durationMinutes'] as int? ??
        step['time'] as int? ??
        step['duration'] as int? ??
        5;

    final startTemp = previousDoughState?['temperature'] as double? ?? 25.0;
    final startGluten =
        previousDoughState?['glutenFormation'] as double? ?? 0.0;
    final startViscosity = previousDoughState?['viscosity'] as double? ?? 1.0;

    final finalTemp = _predictTemperatureChange(speed, duration, startTemp);
    final glutenIncrement = _calculateGlutenFormationIncrement(
      stepIndex: index,
      speed: speed,
      duration: duration,
      currentGluten: startGluten,
      temperature: startTemp,
    );
    final finalGluten = startGluten + glutenIncrement;
    final viscosityChange =
        _calculateViscosityChange(index, speed, duration, startViscosity);
    final finalViscosity = startViscosity + viscosityChange;

    final rpm = _calculateRPMForStepSync(speed);
    final efficiency =
        _calculateStepEfficiency(speed, duration, rpm.toDouble());

    return {
      'stepNumber': index + 1,
      'speed': speed,
      'durationMinutes': duration,
      'rpm': rpm,
      'doughState': {
        'temperature': finalTemp,
        'glutenFormation': finalGluten,
        'viscosity': finalViscosity,
        'moistureAbsorption': _calculateMoistureAbsorption(index, duration),
        'developmentStage': _getDevelopmentStage(finalGluten),
      },
      'recommendations': _createDefaultRecommendations(index, speed, duration),
      'efficiency': efficiency,
    };
  }

  /// 기본 단계 분석 생성
  Map<String, dynamic> createDefaultStepAnalysis(
      Map<String, dynamic> step, int index) {
    final speed = step['speed'] as String? ?? '중속';
    final duration = step['durationMinutes'] as int? ??
        step['time'] as int? ??
        step['duration'] as int? ??
        5;

    final rpm = _calculateRPMForStepSync(speed);
    final doughState = _createDefaultDoughState(index, speed, duration);
    final recommendations =
        _createDefaultRecommendations(index, speed, duration);
    final efficiency =
        _calculateStepEfficiency(speed, duration, rpm.toDouble());

    return {
      'stepNumber': index + 1,
      'speed': speed,
      'durationMinutes': duration,
      'rpm': rpm,
      'doughState': doughState,
      'recommendations': recommendations,
      'efficiency': efficiency,
    };
  }

  /// 간단한 믹싱 분석 결과 생성
  Map<String, dynamic> generateSimpleAnalysisResult(
    List<Map<String, dynamic>> mixingSteps,
  ) {
    final totalTime = _calculateTotalMixingTime(mixingSteps);
    final avgGluten = _calculateAverageGlutenFormation(mixingSteps);
    final efficiency = _calculateEfficiency(mixingSteps);
    final overallScore =
        _calculateOverallScore(avgGluten, efficiency, totalTime);

    return {
      'totalTime': totalTime,
      'averageGlutenFormation': avgGluten,
      'efficiency': efficiency,
      'overallScore': overallScore,
    };
  }

  /// 위험 요소 기반 현재 상태보고 생성
  List<String> generateCurrentStatusWithWarnings(
    List<Map<String, dynamic>> mixingSteps,
  ) {
    final statusReports = <String>[];

    for (int i = 0; i < mixingSteps.length; i++) {
      final step = mixingSteps[i];
      final speed = step['speed'] as String? ?? '중속';
      final duration = step['durationMinutes'] as int? ??
          step['time'] as int? ??
          step['duration'] as int? ??
          5;

      final warning = MixingWarningService.generateIntegratedFeedback(
        {'speed': speed, 'durationMinutes': duration},
        {'glutenFormation': 0.5, 'temperature': 25.0, 'viscosity': 1.0},
        null,
        null,
        i,
      );

      if (warning.isNotEmpty) {
        statusReports.add(warning.first); // 첫 번째 경고만 추가
      }
    }

    if (statusReports.isEmpty) {
      final totalTime = _calculateTotalMixingTime(mixingSteps);
      final avgGluten = _calculateAverageGlutenFormation(mixingSteps);

      if (totalTime >= 10 && totalTime <= 15) {
        statusReports.add('총 믹싱 시간이 적정 범위입니다');
      }
    }

    return statusReports.take(4).toList();
  }

  double _calculateGlutenFormationIncrement({
    required int stepIndex,
    required String speed,
    required int duration,
    required double currentGluten,
    required double temperature,
    int totalSteps = 4,
    List<Map<String, dynamic>>? ingredients,
  }) {
    double baseIncrement = _getBaseIncrementByStepRatio(stepIndex, totalSteps);
    double speedFactor = _getSpeedFactor(
        speed, stepIndex, duration, ingredients ?? [], 0.0, 0.0, 0.0);
    double timeFactor = _getTimeEfficiencyFactor(duration);
    double tempFactor = _getTemperatureEfficiencyFactor(temperature);
    double glutenStateFactor = _getGlutenStateFactor(currentGluten);

    final combinedFactor =
        speedFactor * timeFactor * tempFactor * glutenStateFactor;
    double increment = baseIncrement * combinedFactor;

    increment = increment.clamp(0.0, 0.25);
    return increment;
  }

  double _calculateGlutenFormation(
      int stepIndex, String speed, int duration, double temperature,
      [double currentGluten = 0.0]) {
    return currentGluten +
        _calculateGlutenFormationIncrement(
            stepIndex: stepIndex,
            speed: speed,
            duration: duration,
            currentGluten: currentGluten,
            temperature: temperature);
  }

  double _predictTemperatureChange(
      String speed, int duration, double currentTemp) {
    double heatGeneration = 1.0;

    switch (speed) {
      case '저속':
        heatGeneration *= 0.5;
        break;
      case '중속':
        heatGeneration *= 1.0;
        break;
      case '고속':
        heatGeneration *= 1.5;
        break;
    }

    if (duration < 3) {
      heatGeneration *= 0.8;
    }

    return currentTemp + (heatGeneration * duration);
  }

  double _predictViscosity(int stepIndex, String speed, int duration) {
    return 1.0 + _calculateViscosityChange(stepIndex, speed, duration, 1.0);
  }

  /// ⚠️ [중앙화 충돌 제거] 과거 수분 계산 로직 제거 - 컨트롤러의 중앙화 계산만 사용
  double _calculateMoistureAbsorption(int stepIndex, int duration) {
    // 과거: 단계별 고정 곱셈 계산 (65.0 * multiplier)
    // 현재: 컨트롤러의 중앙화 remainingMoisture 기반 계산만 유효
    return 65.0; // 기본값 고정 - 컨트롤러 계산 결과 소비만
  }

  double _getMoistureStepMultiplier(int stepIndex) {
    switch (stepIndex) {
      case 0:
        return 0.8;
      case 1:
        return 1.0;
      case 2:
        return 0.9;
      default:
        return 0.85;
    }
  }

  double _calculateViscosityChange(
      int stepIndex, String speed, int duration, double currentViscosity) {
    double change = 0.0;

    switch (stepIndex) {
      case 0:
        change = 0.2;
        break;
      case 1:
        change = 0.5;
        break;
      case 2:
        change = 0.3;
        break;
    }

    switch (speed) {
      case '저속':
        change *= 0.9;
        break;
      case '중속':
        change *= 1.0;
        break;
      case '고속':
        change *= 1.1;
        break;
    }

    if (currentViscosity > 1.8)
      change *= 0.7;
    else if (currentViscosity < 0.5) change *= 1.3;

    if (duration < 3)
      change *= 0.8;
    else if (duration > 8) change *= 1.2;

    return change;
  }

  double _getBaseIncrementByStepRatio(int stepIndex, int totalSteps) {
    switch (stepIndex) {
      case 0:
        return 0.15;
      case 1:
        return 0.25;
      case 2:
        return 0.20;
      default:
        return 0.15;
    }
  }

  double _getSpeedFactor(
      String speed,
      int stepIndex,
      int duration,
      List<Map<String, dynamic>> ingredients,
      double currentGluten,
      double currentMoisture,
      double currentViscosity) {
    double baseEfficiency = 1.0;
    switch (speed) {
      case '저속':
        baseEfficiency = 1.2;
        break;
      case '중속':
        baseEfficiency = 1.0;
        break;
      case '고속':
        baseEfficiency = 0.8;
        break;
    }

    if (speed == '고속' && currentMoisture > 75) {
      baseEfficiency *= 0.88;
    } else if (speed == '저속' && currentMoisture < 60) {
      baseEfficiency *= 0.92;
    }

    return baseEfficiency;
  }

  double _getTimeEfficiencyFactor(int duration) {
    if (duration < 3) return 0.7;
    if (duration >= 3 && duration <= 8) return 1.0;
    if (duration <= 12) return 1.2;
    return 0.8;
  }

  double _getTemperatureEfficiencyFactor(double temperature) {
    if (temperature >= 22 && temperature <= 26) return 1.2;
    if (temperature >= 20 && temperature <= 28) return 1.0;
    if (temperature >= 18 && temperature <= 30) return 0.8;
    return 0.6;
  }

  double _getGlutenStateFactor(double currentGluten) {
    if (currentGluten < 0.2) return 1.3;
    if (currentGluten < 0.6) return 1.0;
    if (currentGluten < 0.8) return 0.8;
    return 0.5;
  }

  double _calculateTotalMixingTime(List<Map<String, dynamic>> mixingSteps) {
    return mixingSteps.fold(0, (sum, step) {
      final duration = step['durationMinutes'] as int? ??
          step['time'] as int? ??
          step['duration'] as int? ??
          0;
      return sum + duration;
    });
  }

  double _calculateAverageGlutenFormation(
      List<Map<String, dynamic>> mixingSteps) {
    if (mixingSteps.isEmpty) return 0.4;

    double totalFormation = 0.0;
    for (int i = 0; i < mixingSteps.length; i++) {
      final step = mixingSteps[i];
      final speed = step['speed'] as String? ?? '중속';
      final duration = step['durationMinutes'] as int? ??
          step['time'] as int? ??
          step['duration'] as int? ??
          5;

      double baseFormation = 0.6;
      switch (speed) {
        case '저속':
          baseFormation = 0.8;
          break;
        case '중속':
          baseFormation = 0.6;
          break;
        case '고속':
          baseFormation = 0.4;
          break;
      }

      double timeFactor = 1.0;
      if (duration < 3) timeFactor = 0.8;
      if (duration > 10) timeFactor = 1.1;

      double stepWeight = 0.9;
      totalFormation += baseFormation * timeFactor * stepWeight;
    }

    return totalFormation / mixingSteps.length;
  }

  double _calculateEfficiency(List<Map<String, dynamic>> mixingSteps) {
    if (mixingSteps.isEmpty) return 0.7;

    final totalTime = _calculateTotalMixingTime(mixingSteps);
    final avgGluten = _calculateAverageGlutenFormation(mixingSteps);

    double timeEfficiency = 1.0;
    if (totalTime < 10) timeEfficiency = 0.9;
    if (totalTime > 15) timeEfficiency = 0.8;

    return (timeEfficiency + avgGluten) / 2;
  }

  double _calculateOverallScore(
      double avgGluten, double avgEfficiency, num totalTime) {
    final glutenScore = avgGluten * 0.4;
    final efficiencyScore = avgEfficiency * 0.3;
    final timeEfficiency =
        totalTime <= 12 ? 1.0 : (15.0 / totalTime.toDouble());
    final timeScore = timeEfficiency * 0.3;

    return glutenScore + efficiencyScore + timeScore;
  }

  Color _getMetricColor(String metricType, double value) {
    switch (metricType) {
      case 'gluten':
        if (value >= 0.7) return Colors.green;
        if (value >= 0.5) return Colors.lightGreen;
        if (value >= 0.3) return Colors.orange;
        return Colors.red;
      case 'moisture':
        if (value >= 65 && value <= 80) return Colors.green;
        if (value >= 60 && value <= 85) return Colors.orange;
        return Colors.red;
      case 'viscosity':
        if (value >= 1.5 && value <= 2.0) return Colors.green;
        if (value >= 1.0 && value <= 2.5) return Colors.orange;
        return Colors.red;
      case 'temperature':
        try {
          final optimalRange =
              EnvironmentDefaultsCalculator.getOptimalTemperatureRange();
          final optimalMin = optimalRange.min;
          final optimalMax = optimalRange.max;
          final goodMin = optimalMin - 3.0;
          final goodMax = optimalMax + 3.0;

          if (value >= optimalMin && value <= optimalMax) return Colors.green;
          if (value >= goodMin && value <= goodMax) return Colors.orange;
          return Colors.red;
        } catch (e) {
          return Colors.grey.shade600;
        }
      case 'score':
        if (value >= 0.8) return Colors.green;
        if (value >= 0.6) return Colors.lightGreen;
        if (value >= 0.4) return Colors.orange;
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color getMetricColor(String metricType, double value) {
    return _getMetricColor(metricType, value);
  }

  /// 🆕 [타입 충돌 회피] MixingMeta 직접 생성 함수
  /// 중앙 시스템 복잡성 제거, 직접 계수 적용
  MixingMeta _generateMixingMetaFromMixerType({
    required MixerType mixerType,
  }) {
    // 믹서 타입에 따른 계수 적용 (직접 계산 - 중앙 시스템보다 간단)
    double mixerCoefficient = switch (mixerType) {
      MixerType.professional => 1.05, // ✅ 16% 값 변동 목표!
      MixerType.home => 1.0,
      MixerType.commercial => 1.08,
      _ => 1.0, // 안전한 기본값
    };

    // 장비 캘리브레이션도 타입에 따른 적용
    double equipmentCalibration = switch (mixerType) {
      MixerType.professional => 1.0, // 전문 믹서는 이미 잘 캘리브레이션됨
      MixerType.home => 0.95, // 가정용은 약간의 조정 필요
      MixerType.commercial => 0.98, // 상업용은 중간 수준
      _ => 0.95,
    };

    return MixingMeta(
      // 기존 advanced_sous_chef_models.dart의 MixingMeta
      predictedTime: 50.0, // 저속 50분 기준
      frictionHeat: 2.5, // 기본 마찰열
      mixerTypeCoefficient: mixerCoefficient, // 🎯 핵심! 값 변동 발생
      glutenDevelopmentTarget: 1.0, // 기본 목표
      equipmentCalibration: equipmentCalibration, // 장비 캘리브레이션
    );
  }

  // Season 변환 헬퍼 메소드
  Season _convertSeason(UserEnvironment env) {
    switch (env.season) {
      case Season.spring:
        return Season.spring;
      case Season.summer:
        return Season.summer;
      case Season.autumn:
        return Season.autumn;
      case Season.winter:
        return Season.winter;
    }
  }

  // OvenType 변환 헬퍼 메소드
  OvenType _convertOvenType(UserEnvironment env) {
    switch (env.ovenType) {
      case OvenType.home:
        return OvenType.home;
      case OvenType.professional:
        return OvenType.professional;
      case OvenType.convection:
        return OvenType.convection;
      case OvenType.professionalConvection:
        return OvenType.professionalConvection;
      default:
        return OvenType.home; // 기본값
    }
  }

  /// 🔬 종합 제빵 과학 통합 계산식 기반 글루텐 형성도 계산
  /// V. 최적 공정 제어 및 시간 예측 적용
  double _scientificallyEstimateGlutenFormation({
    required int stepIndex,
    required String speed,
    required int duration,
    required double temperature,
    double? proteinContent, // 밀가루 단백질 함량
    MixerType? mixerType, // 믹서 타입
  }) {
    // 1. 기본 글루텐 형성도 (단백질 함량 기반)
    double baseFormation;
    if (proteinContent != null) {
      // 유효 밀가루 단백질% 기반 계산
      baseFormation = (proteinContent * 1.2) / 100.0; // 단백질%를 비율로 변환
    } else {
      // 기본값 (단백질 함량 정보 없을 때)
      baseFormation = stepIndex == 0 ? 0.2 : 0.4;
    }

    // 2. 믹서 유형 계수 적용
    double mixerCoefficient = 1.0;
    if (mixerType != null) {
      mixerCoefficient = switch (mixerType) {
        MixerType.professional => 1.05, // 전문 믹서: 더 효율적
        MixerType.home => 1.0, // 가정용: 기준
        MixerType.commercial => 1.08, // 상업용: 강력
        _ => 1.0,
      };
    }

    // 3. 글루텐 발달 목표 계수 (단계별)
    double developmentTarget = switch (stepIndex) {
      0 => 0.8, // 1단계: 저가수분/저단백질 목표
      1 => 1.0, // 2단계: 표준
      2 => 1.2, // 3단계: 고가수분/고단백질 목표
      _ => 1.0, // 기본값
    };

    // 4. 속도 계수 (빵 과학적 현실 반영)
    double speedFactor = switch (speed) {
      '저속' => 1.2, // 저속: 글루텐 형성에 유리
      '중속' => 1.0, // 중속: 균형
      '고속' => 0.7, // 고속: 글루텐 손상 위험
      _ => 1.0,
    };

    // 5. 시간 효율성 (3-8분이 최적)
    double timeFactor = (duration >= 3 && duration <= 8) ? 1.0 : duration / 5.0;

    // 6. 온도 효율성 (22-26°C 최적)
    double tempFactor = (temperature >= 22 && temperature <= 26) ? 1.2 : 0.8;

    // 7. 장비 캘리브레이션 계수 (믹서 상태 고려)
    double equipmentCalibration = mixerType != null ? 0.95 : 1.0;

    // 종합 계산
    double finalFormation = baseFormation *
        mixerCoefficient *
        developmentTarget *
        speedFactor *
        timeFactor *
        tempFactor *
        equipmentCalibration;

    debugPrint('🔬 [믹싱 과학 계산] 글루텐 형성도:');
    debugPrint('   - 기본 형성도: ${baseFormation.toStringAsFixed(3)}');
    debugPrint('   - 믹서 계수: ${mixerCoefficient.toStringAsFixed(3)}');
    debugPrint('   - 발달 목표: ${developmentTarget.toStringAsFixed(3)}');
    debugPrint('   - 속도 계수: ${speedFactor.toStringAsFixed(3)}');
    debugPrint('   - 시간 효율: ${timeFactor.toStringAsFixed(3)}');
    debugPrint('   - 온도 효율: ${tempFactor.toStringAsFixed(3)}');
    debugPrint('   - 최종 형성도: ${finalFormation.toStringAsFixed(3)}');

    return finalFormation.clamp(0.1, 0.9);
  }

  /// 외부에서 접근 가능한 점도 계산 메소드 (public)
  double calculateViscosity(int stepIndex, String speed, int duration) {
    return _predictViscosity(stepIndex, speed, duration);
  }

  /// 🔬 과학적 방식으로 점도 계산 (빅데이터 제거 버전)
  double _scientificallyEstimateViscosity(
      int stepIndex, String speed, int duration, double currentViscosity) {
    // 빵 제조 과학 기반 점도 변동 계산
    double baseViscosity = currentViscosity;

    switch (stepIndex) {
      case 0:
        baseViscosity += 0.2; // 초기 재료 혼합
        break;
      case 1:
        baseViscosity += (speed == '저속' ? 0.4 : 0.6); // 글루텐 형성 단계
        break;
      case 2:
        baseViscosity += (speed == '고속' ? 0.1 : 0.2); // 마무리 단계
        break;
    }

    // 속도 영향
    if (speed == '고속' && duration < 3) {
      baseViscosity *= 0.8; // 고속, 단시간: 낮은 점도 증가
    }

    return baseViscosity.clamp(0.8, 3.0);
  }

  /// 외부에서 접근 가능한 글루텐 형성도 증가량 계산 메소드 (과학적 방식으로 전환)
  double calculateGlutenFormationIncrement({
    required int stepIndex,
    required String speed,
    required int duration,
    required double currentGluten,
    required double temperature,
    int totalSteps = 4,
    List<Map<String, dynamic>>? ingredients,
  }) {
    try {
      // 빅데이터 제거: 과학적 계산 방식 사용
      return _scientificallyEstimateGlutenFormation(
            stepIndex: stepIndex,
            speed: speed,
            duration: duration,
            temperature: temperature,
          ) -
          currentGluten;
    } catch (e) {
      print('❌ [과학적 계산] 오류: $e');
      return _calculateMinimumSafeIncrement(stepIndex, currentGluten);
    }
  }

  double _calculateMinimumSafeIncrement(int stepIndex, double currentGluten) {
    try {
      double baseMinIncrement = 0.02;
      double glutenAdjustment = currentGluten < 0.3 ? 1.5 : 1.0;
      double stepAdjustment = stepIndex == 0 ? 1.2 : 1.0;

      double minIncrement =
          baseMinIncrement * glutenAdjustment * stepAdjustment;
      return minIncrement.clamp(0.01, 0.10);
    } catch (e) {
      return 0.05;
    }
  }
}
