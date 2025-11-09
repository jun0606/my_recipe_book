/// 반죽 상태 상세 분석기
/// 종합 제빵 과학 통합 계산식을 기반으로 반죽의 모든 상태를 분석

import 'dart:math' as math;
import '../services/ingredient_analyzer.dart';
import '../services/fermentation_calculator.dart';

/// 믹싱 단계 데이터 모델
class MixingStep {
  final int stepNumber; // 단계 번호 (1차, 2차, 3차...)
  final String speed; // 속도 (저속/중속/고속)
  final double durationMinutes; // 시간 (분)
  final double targetGluten; // 목표 글루텐 지수
  final String purpose; // 단계 목적
  final double temperature; // 단계별 목표 온도 (°C)

  const MixingStep({
    required this.stepNumber,
    required this.speed,
    required this.durationMinutes,
    this.targetGluten = 0.0,
    this.purpose = '',
    this.temperature = 25.0,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'stepNumber': stepNumber,
      'speed': speed,
      'durationMinutes': durationMinutes,
      'targetGluten': targetGluten,
      'purpose': purpose,
      'temperature': temperature,
    };
  }

  /// Map으로 변환 (toJson과 동일)
  Map<String, dynamic> toMap() {
    return toJson();
  }

  /// JSON에서 생성
  factory MixingStep.fromJson(Map<String, dynamic> json) {
    return MixingStep(
      stepNumber: json['stepNumber'] ?? 1,
      speed: json['speed'] ?? '중속',
      durationMinutes: (json['durationMinutes'] as num?)?.toDouble() ?? 10.0,
      targetGluten: (json['targetGluten'] as num?)?.toDouble() ?? 0.0,
      purpose: json['purpose'] ?? '',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 25.0,
    );
  }
}

/// 믹서 종류별 특성
class MixerCharacteristics {
  final String type;
  final double efficiency; // 효율 (0.0-1.0)
  final double maxRPM; // 최대 RPM
  final double heatGeneration; // 열 발생 계수
  final List<String> supportedSpeeds; // 지원 속도 목록

  const MixerCharacteristics({
    required this.type,
    required this.efficiency,
    required this.maxRPM,
    required this.heatGeneration,
    required this.supportedSpeeds,
  });

  /// 믹서 타입별 특성 데이터베이스
  static const Map<String, MixerCharacteristics> mixerDatabase = {
    'stand': MixerCharacteristics(
      type: 'stand',
      efficiency: 0.9,
      maxRPM: 800,
      heatGeneration: 1.0,
      supportedSpeeds: ['저속', '중속', '고속'],
    ),
    'hand': MixerCharacteristics(
      type: 'hand',
      efficiency: 0.6,
      maxRPM: 400,
      heatGeneration: 1.3,
      supportedSpeeds: ['저속', '중속'],
    ),
    'bread_machine': MixerCharacteristics(
      type: 'bread_machine',
      efficiency: 0.8,
      maxRPM: 600,
      heatGeneration: 0.8,
      supportedSpeeds: ['저속', '중속', '고속'],
    ),
    'planetary': MixerCharacteristics(
      type: 'planetary',
      efficiency: 0.95,
      maxRPM: 1000,
      heatGeneration: 1.1,
      supportedSpeeds: ['저속', '중속', '고속'],
    ),
    'spiral': MixerCharacteristics(
      type: 'spiral',
      efficiency: 0.85,
      maxRPM: 700,
      heatGeneration: 0.9,
      supportedSpeeds: ['저속', '중속', '고속'],
    ),
  };

  /// 믹서 타입으로부터 특성 가져오기
  static MixerCharacteristics getMixerCharacteristics(String mixerType) {
    return mixerDatabase[mixerType.toLowerCase()] ??
        mixerDatabase['stand']!; // 기본값: 스탠드 믹서
  }
}

class DoughStateAnalyzer {
  /// 로깅을 위한 분석 세션 ID
  static String? _currentAnalysisSessionId;

  /// 로깅 헬퍼
  static void _log(String message, {String? level = 'INFO', dynamic data}) {
    final timestamp = DateTime.now().toIso8601String();
    final sessionId = _currentAnalysisSessionId ?? 'unknown';
    final logMessage =
        '[$timestamp] [DoughStateAnalyzer] [$sessionId] [$level] $message';

    if (data != null) {
      print('$logMessage | Data: $data');
    } else {
      print(logMessage);
    }
  }

  /// 분석 세션 시작 로깅
  static void _startAnalysisSession() {
    _currentAnalysisSessionId =
        'dough_analysis_session_${DateTime.now().millisecondsSinceEpoch}';
    _log('=== 반죽 상태 분석 세션 시작 ===', level: 'START');
  }

  /// 분석 세션 종료 로깅
  static void _endAnalysisSession({String? result = 'unknown', dynamic error}) {
    if (error != null) {
      _log('=== 반죽 상태 분석 세션 실패 ===', level: 'ERROR', data: error);
    } else {
      _log('=== 반죽 상태 분석 세션 완료 ===',
          level: 'SUCCESS', data: {'result': result});
    }
    _currentAnalysisSessionId = null;
  }

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

    // 믹싱 관련 신규 파라미터
    String mixerType =
        'stand', // 믹서 종류 (stand, hand, bread_machine, planetary, spiral)
    List<MixingStep> mixingSteps = const [], // 믹싱 단계들
    double currentMixingSpeedRPM = 0.0, // 현재 믹싱 속도 (RPM)
    double currentMixingTime = 0.0, // 현재 믹싱 시간 (분)
  }) {
    _startAnalysisSession();

    try {
      _log('반죽 상태 분석 시작', data: {
        'recipe_title': recipeTitle,
        'ingredients_count': ingredients.length,
        'mixer_type': mixerType,
        'mixing_steps_count': mixingSteps.length,
        'environment_temp': environmentTemperature,
        'environment_humidity': environmentHumidity,
        'fermentation_time': fermentationTime,
        'season': season,
      });

      // 1. 기본 재료 분석
      _log('기본 재료 분석 시작');
      final flourIngredients = IngredientAnalyzer.findFlourIngredients(
          ingredients,
          recipeTitle: recipeTitle);
      final liquidIngredients = IngredientAnalyzer.findLiquidIngredients(
          ingredients,
          recipeTitle: recipeTitle);
      final yeastIngredients = IngredientAnalyzer.findYeastIngredients(
          ingredients,
          recipeTitle: recipeTitle);
      final saltIngredients = IngredientAnalyzer.findSaltIngredients(
          ingredients,
          recipeTitle: recipeTitle);

      _log('기본 재료 분석 완료', data: {
        'flour_count': flourIngredients.length,
        'liquid_count': liquidIngredients.length,
        'yeast_count': yeastIngredients.length,
        'salt_count': saltIngredients.length,
      });

      // 2. 기본 비율 계산
      _log('기본 비율 계산 시작');
      final hydrationLevel = IngredientAnalyzer.calculateHydration(ingredients,
              recipeTitle: recipeTitle) /
          100.0;
      final yeastPercentage = IngredientAnalyzer.calculateYeastPercentage(
              ingredients,
              recipeTitle: recipeTitle) /
          100.0;
      final saltPercentage = IngredientAnalyzer.calculateSaltPercentage(
              ingredients,
              recipeTitle: recipeTitle) /
          100.0;

      _log('기본 비율 계산 완료', data: {
        'hydration_level': hydrationLevel,
        'yeast_percentage': yeastPercentage,
        'salt_percentage': saltPercentage,
      });

      // 3. 믹서 종류별 효율 보정 계산
      _log('믹서 특성 계산');
      final mixerCharacteristics =
          MixerCharacteristics.getMixerCharacteristics(mixerType);

      _log('믹서 특성 계산 완료', data: {
        'mixer_efficiency': mixerCharacteristics.efficiency,
        'mixer_max_rpm': mixerCharacteristics.maxRPM,
      });

      // 4. 믹싱 단계별 글루텐 발달 계산
      _log('믹싱 단계별 글루텐 발달 계산 시작');
      final mixingAnalysis = _analyzeMixingSteps(
          mixingSteps,
          currentMixingSpeedRPM,
          currentMixingTime,
          mixerCharacteristics,
          ingredients,
          recipeTitle);

      _log('믹싱 단계별 글루텐 발달 계산 완료', data: {
        'total_gluten_development': mixingAnalysis['totalGlutenDevelopment'],
        'total_heat_generation': mixingAnalysis['totalHeatGeneration'],
      });

      // 5. 글루텐 강도 지수 계산 (종합 제빵 과학 통합 계산식 + 믹싱 보정 + 환경 조건)
      _log('글루텐 강도 지수 계산 시작');
      final glutenStrengthIndex = _calculateGlutenStrengthIndex(
        ingredients,
        recipeTitle,
        mixingAnalysis,
        environmentTemperature: environmentTemperature,
        environmentHumidity: environmentHumidity,
        altitude: altitude,
      );

      _log('글루텐 강도 지수 계산 완료', data: {
        'gluten_strength_index': glutenStrengthIndex,
      });

      // 6. 반죽 물리화학 계수 계산
      _log('반죽 물리화학 계수 계산');
      final doughPhysicochemicalFactor = _calculateDoughPhysicochemicalFactor(
          ingredients, environmentTemperature, recipeTitle);

      // 7. 미생물 활성 계수 계산
      _log('미생물 활성 계수 계산');
      final microbialActivityFactor = _calculateMicrobialActivityFactor(
          ingredients, environmentTemperature, recipeTitle);

      // 8. 환경 기후 계수 계산 (기후학)
      _log('환경 기후 계수 계산');
      final environmentalFactor = _calculateEnvironmentalFactor(
          environmentTemperature, environmentHumidity, altitude, season);

      _log('기본 계수 계산 완료', data: {
        'physicochemical_factor': doughPhysicochemicalFactor,
        'microbial_factor': microbialActivityFactor,
        'environmental_factor': environmentalFactor,
      });

      // 9. 반죽 밀도 계산 (물리학)
      _log('반죽 밀도 계산');
      final doughDensity = _calculateDoughDensity(
          ingredients, doughWeight, doughVolume, hydrationLevel, recipeTitle);

      // 10. 발효 진행도 분석 (중앙화된 FermentationCalculator에서 가져오기)
      _log('발효 진행도 분석 - 중앙화로부터 진행률 가져오기');
      final fermentationProgress =
          _getFermentationProgressFromCentralizedResult();

      // 11. 가스 보유력 지수 (물리화학)
      _log('가스 보유력 지수 계산');
      final gasRetentionIndex = _calculateGasRetentionIndex(
          glutenStrengthIndex, hydrationLevel, fermentationProgress);

      // 12. 반죽 탄성 지수 (물리학)
      _log('반죽 탄성 지수 계산');
      final elasticityIndex = _calculateElasticityIndex(
          glutenStrengthIndex, hydrationLevel, saltPercentage);

      // 13. 점성 지수 계산 (유체역학)
      _log('점성 지수 계산');
      final viscosityIndex = _calculateViscosityIndex(
          hydrationLevel, glutenStrengthIndex, doughTemperature);

      // 14. 표면 장력 계수 (물리화학)
      _log('표면 장력 계수 계산');
      final surfaceTensionFactor =
          _calculateSurfaceTensionFactor(hydrationLevel);

      // 15. 열전달 특성 분석 (물리학)
      _log('열전달 특성 분석');
      final heatTransferCharacteristics = _analyzeHeatTransferCharacteristics(
          doughDensity, hydrationLevel, gasRetentionIndex);

      // 16. 반죽 질감 분석 (종합)
      _log('반죽 질감 분석');
      final textureAnalysis = _analyzeTextureCharacteristics(
          hydrationLevel,
          glutenStrengthIndex,
          fermentationProgress,
          environmentTemperature,
          environmentHumidity);

      // 17. 표면 상태 분석
      _log('표면 상태 분석');
      final surfaceCondition = _analyzeSurfaceCondition(
          hydrationLevel, fermentationProgress, environmentHumidity);

      // 18. 반죽 안정성 지수 계산
      _log('반죽 안정성 지수 계산');
      final stabilityIndex = _calculateStabilityIndex(
          glutenStrengthIndex,
          fermentationProgress,
          gasRetentionIndex,
          elasticityIndex,
          environmentalFactor);

      _log('모든 분석 완료', data: {
        'gas_retention_index': gasRetentionIndex,
        'elasticity_index': elasticityIndex,
        'viscosity_index': viscosityIndex,
        'stability_index': stabilityIndex,
        'overall_dough_state': _calculateOverallState(glutenStrengthIndex,
            fermentationProgress, gasRetentionIndex, elasticityIndex),
      });

      final result = DoughStateAnalysisResult(
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

      _endAnalysisSession(result: 'dough_analysis_completed');
      return result;
    } catch (e) {
      _log('반죽 상태 분석 오류', level: 'ERROR', data: {
        'error': e.toString(),
        'recipe_title': recipeTitle,
        'ingredients_count': ingredients.length,
        'mixer_type': mixerType,
      });
      _endAnalysisSession(error: {
        'error_message': e.toString(),
        'phase': 'dough_state_analysis',
      });
      return DoughStateAnalysisResult.empty();
    }
  }

  /// 종합 반죽 상태 계산 헬퍼
  static String _calculateOverallState(double glutenIndex,
      double fermentationProgress, double gasRetention, double elasticity) {
    final scores = [
      glutenIndex / 15.0,
      fermentationProgress,
      gasRetention,
      elasticity,
    ];

    final averageScore = scores.reduce((a, b) => a + b) / scores.length;

    if (averageScore >= 0.8) return "최적 상태";
    if (averageScore >= 0.6) return "양호한 상태";
    if (averageScore >= 0.4) return "보통 상태";
    if (averageScore >= 0.2) return "개선 필요";
    return "문제 있음";
  }

  /// 믹싱 단계별 글루텐 발달 분석
  static Map<String, dynamic> _analyzeMixingSteps(
      List<MixingStep> mixingSteps,
      double currentMixingSpeedRPM,
      double currentMixingTime,
      MixerCharacteristics mixerCharacteristics,
      List<Map<String, dynamic>> ingredients,
      String? recipeTitle) {
    double totalGlutenDevelopment = 0.0;
    double totalHeatGeneration = 0.0;
    double efficiencyFactor = mixerCharacteristics.efficiency;

    for (final step in mixingSteps) {
      // 단계별 글루텐 발달 계산
      double stepGlutenDevelopment = _calculateStepGlutenDevelopment(
          step, mixerCharacteristics, ingredients, recipeTitle);

      // 단계별 열 발생 계산
      double stepHeat = _calculateStepHeatGeneration(
          step, mixerCharacteristics, currentMixingTime);

      totalGlutenDevelopment += stepGlutenDevelopment;
      totalHeatGeneration += stepHeat;
    }

    // 현재 믹싱 상태 반영
    if (currentMixingSpeedRPM > 0 && currentMixingTime > 0) {
      double currentGlutenDevelopment = _calculateCurrentMixingDevelopment(
          currentMixingSpeedRPM,
          currentMixingTime,
          mixerCharacteristics,
          ingredients,
          recipeTitle);
      totalGlutenDevelopment +=
          currentGlutenDevelopment * 0.5; // 현재 진행중인 믹싱 50% 반영
    }

    return {
      'totalGlutenDevelopment': totalGlutenDevelopment.clamp(0.0, 20.0),
      'totalHeatGeneration': totalHeatGeneration,
      'mixerEfficiency': efficiencyFactor,
      'mixingStepsCount': mixingSteps.length,
    };
  }

  /// 단계별 글루텐 발달 계산
  static double _calculateStepGlutenDevelopment(
      MixingStep step,
      MixerCharacteristics mixerCharacteristics,
      List<Map<String, dynamic>> ingredients,
      String? recipeTitle) {
    // 기본 글루텐 발달 계수
    double baseDevelopment = 1.0;

    // 속도별 글루텐 발달 효율
    double speedFactor = _getSpeedGlutenFactor(step.speed);

    // 시간 효율 (적정 시간 범위에서 최대 효율)
    double timeFactor = _getTimeEfficiencyFactor(step.durationMinutes);

    // 믹서 효율 반영
    double mixerFactor = mixerCharacteristics.efficiency;

    // 재료 상태 반영
    double ingredientFactor =
        _calculateIngredientMixingFactor(ingredients, recipeTitle);

    return baseDevelopment *
        speedFactor *
        timeFactor *
        mixerFactor *
        ingredientFactor;
  }

  /// 단계별 열 발생 계산
  static double _calculateStepHeatGeneration(MixingStep step,
      MixerCharacteristics mixerCharacteristics, double currentMixingTime) {
    double baseHeat = 2.0; // 기본 온도 상승 (°C)

    // 속도별 열 발생
    double speedHeatFactor = _getSpeedHeatFactor(step.speed);

    // 시간별 열 누적
    double timeHeatFactor = math.min(step.durationMinutes / 10.0, 2.0);

    // 믹서 열 발생 계수
    double mixerHeatFactor = mixerCharacteristics.heatGeneration;

    return baseHeat * speedHeatFactor * timeHeatFactor * mixerHeatFactor;
  }

  /// 현재 믹싱 진행 상태 글루텐 발달 계산
  static double _calculateCurrentMixingDevelopment(
      double currentMixingSpeedRPM,
      double currentMixingTime,
      MixerCharacteristics mixerCharacteristics,
      List<Map<String, dynamic>> ingredients,
      String? recipeTitle) {
    // RPM을 속도 단계로 변환
    String speedLevel =
        _convertRPMToSpeedLevel(currentMixingSpeedRPM, mixerCharacteristics);

    // 현재 진행률 계산 (0.0-1.0)
    double progressRatio = math.min(currentMixingTime / 10.0, 1.0); // 10분 기준

    // 글루텐 발달 계산
    double glutenDevelopment = _getSpeedGlutenFactor(speedLevel) *
        progressRatio *
        mixerCharacteristics.efficiency;

    return glutenDevelopment;
  }

  /// 속도별 글루텐 발달 계수
  static double _getSpeedGlutenFactor(String speed) {
    switch (speed.toLowerCase()) {
      case '저속':
        return 0.7; // 저속: 부드러운 글루텐 형성
      case '중속':
        return 1.0; // 중속: 최적 글루텐 발달
      case '고속':
        return 0.8; // 고속: 빠른 발달이지만 손상 위험
      default:
        return 0.8;
    }
  }

  /// 속도별 열 발생 계수
  static double _getSpeedHeatFactor(String speed) {
    switch (speed.toLowerCase()) {
      case '저속':
        return 0.6; // 저속: 낮은 열 발생
      case '중속':
        return 1.0; // 중속: 보통 열 발생
      case '고속':
        return 1.5; // 고속: 높은 열 발생
      default:
        return 1.0;
    }
  }

  /// 시간 효율 계수 계산
  static double _getTimeEfficiencyFactor(double durationMinutes) {
    if (durationMinutes < 2) return 0.3; // 너무 짧음
    if (durationMinutes <= 8) return 1.0; // 최적 범위
    if (durationMinutes <= 15) return 0.9; // 약간 긴 편
    return 0.7; // 너무 김
  }

  /// 재료 상태별 믹싱 효율 계산
  static double _calculateIngredientMixingFactor(
      List<Map<String, dynamic>> ingredients, String? recipeTitle) {
    double factor = 1.0;

    // 수분율에 따른 효율
    final hydrationLevel = IngredientAnalyzer.calculateHydration(ingredients,
            recipeTitle: recipeTitle) /
        100.0;
    if (hydrationLevel > 0.7) {
      factor *= 0.9; // 고수분: 믹싱 어려움
    } else if (hydrationLevel < 0.5) {
      factor *= 1.1; // 저수분: 믹싱 용이
    }

    // 지방 함량에 따른 효율
    final fatPercentage = _calculateFatPercentage(ingredients, recipeTitle);
    if (fatPercentage > 10) {
      factor *= 0.8; // 고지방: 글루텐 형성 방해
    }

    return factor;
  }

  /// RPM을 속도 레벨로 변환
  static String _convertRPMToSpeedLevel(
      double rpm, MixerCharacteristics mixerCharacteristics) {
    double maxRPM = mixerCharacteristics.maxRPM;

    if (rpm < maxRPM * 0.3) return '저속';
    if (rpm < maxRPM * 0.7) return '중속';
    return '고속';
  }

  /// 글루텐 강도 지수 계산
  /// 공식: (밀가루 단백질% × 1.2) + (소금% × 0.7) - (지방% × 0.5) - (설탕% × 0.3)
  /// 특수 재료 및 반죽 방법 보정 적용 + 믹싱 분석 결과 반영 + 환경 조건 반영
  static double _calculateGlutenStrengthIndex(
    List<Map<String, dynamic>> ingredients,
    String? recipeTitle,
    Map<String, dynamic> mixingAnalysis, {
    double environmentTemperature = 25.0,
    double environmentHumidity = 65.0,
    double altitude = 0.0,
  }) {
    final flourIngredients = IngredientAnalyzer.findFlourIngredients(
        ingredients,
        recipeTitle: recipeTitle);
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
      } else if (name.contains('호밀') || name.contains('rye')) {
        proteinPercentage = 9.0; // 호밀분 단백질 함량
        break;
      } else if (name.contains('통밀') || name.contains('whole wheat')) {
        proteinPercentage = 14.0; // 통밀분 단백질 함량
        break;
      }
    }

    final saltPercentage = IngredientAnalyzer.calculateSaltPercentage(
        ingredients,
        recipeTitle: recipeTitle);
    final fatPercentage = _calculateFatPercentage(ingredients, recipeTitle);
    final sugarPercentage = _calculateSugarPercentage(ingredients, recipeTitle);

    // 기본 글루텐 지수 계산
    double glutenIndex = (proteinPercentage * 1.2) +
        (saltPercentage * 0.7) -
        (fatPercentage * 0.5) -
        (sugarPercentage * 0.3);

    // 특수 재료 및 반죽 방법 보정 적용
    glutenIndex +=
        _calculateSpecialIngredientCorrection(ingredients, recipeTitle);
    glutenIndex += _calculateDoughMethodCorrection(ingredients, recipeTitle);

    // 믹싱 분석 결과 반영
    if (mixingAnalysis.isNotEmpty) {
      final totalGlutenDevelopment =
          (mixingAnalysis['totalGlutenDevelopment'] as num?)?.toDouble() ?? 0.0;
      final mixerEfficiency =
          (mixingAnalysis['mixerEfficiency'] as num?)?.toDouble() ?? 1.0;

      // 믹싱으로 발달된 글루텐을 전체 지수에 반영
      glutenIndex += totalGlutenDevelopment * 0.3; // 믹싱 기여도 30%
      glutenIndex *= mixerEfficiency; // 믹서 효율 반영
    }

    // 환경 조건에 따른 글루텐 형성 효율 보정
    final temperatureEfficiency =
        _calculateTemperatureEfficiency(environmentTemperature);
    final humidityEfficiency =
        _calculateHumidityEfficiency(environmentHumidity);
    final altitudeEfficiency = _calculateAltitudeEfficiency(altitude);

    glutenIndex *=
        temperatureEfficiency * humidityEfficiency * altitudeEfficiency;

    return glutenIndex.clamp(0.0, 20.0);
  }

  /// 믹싱 완료 후 예상 반죽 온도 계산
  static double _calculateFinalDoughTemperature(
      double initialDoughTemperature,
      double waterTemperature,
      double totalHeatGeneration,
      double doughWeight,
      List<Map<String, dynamic>> ingredients,
      String? recipeTitle) {
    // 반죽 열용량 계산 (cal/g°C)
    final flourWeight = _calculateFlourWeight(ingredients, recipeTitle);
    final waterWeight = flourWeight * 0.65; // 수분율 65% 가정
    const double flourSpecificHeat = 0.4; // 밀가루 비열
    const double waterSpecificHeat = 1.0; // 물 비열

    // 전체 반죽 열용량
    final totalHeatCapacity = (flourWeight * flourSpecificHeat) +
        (waterWeight * waterSpecificHeat) +
        (doughWeight * 0.3); // 기타 재료

    // 온도 상승 계산
    final temperatureRise = totalHeatGeneration / totalHeatCapacity;

    // 초기 온도와 물 온도의 평균으로 시작
    final averageInitialTemp =
        (initialDoughTemperature + waterTemperature) / 2.0;

    // 최종 온도 = 초기 평균 온도 + 믹싱으로 인한 온도 상승
    final finalTemperature = averageInitialTemp + temperatureRise;

    return finalTemperature.clamp(15.0, 40.0); // 현실적인 온도 범위 제한
  }

  /// 특수 재료 보정 계산
  static double _calculateSpecialIngredientCorrection(
      List<Map<String, dynamic>> ingredients, String? recipeTitle) {
    double correction = 0.0;
    final flourWeight = _calculateFlourWeight(ingredients, recipeTitle);

    if (flourWeight == 0) return 0.0;

    for (final ingredient in ingredients) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final amount = ingredient['amount'] as double? ?? 0.0;
      final unit = ingredient['unit'] as String? ?? 'g';
      final weightInGrams = IngredientAnalyzer.convertToGrams(
          amount, unit, ingredient['name'] as String? ?? '');
      final percentage = (weightInGrams / flourWeight) * 100;

      // 르방 (유청 단백질) - 글루텐 강화
      if (name.contains('르방') || name.contains('유청') || name.contains('whey')) {
        correction += percentage * 0.8; // 글루텐 강화 효과
      }

      // 비타민 C (아스코르빈산) - 글루텐 강화
      else if (name.contains('비타민c') ||
          name.contains('아스코르빈산') ||
          name.contains('vitamin c') ||
          name.contains('ascorbic acid')) {
        correction += percentage * 2.0; // 강력한 글루텐 강화 효과
      }

      // 구연산 - 글루텐 약화
      else if (name.contains('구연산') || name.contains('citric acid')) {
        correction -= percentage * 0.5; // 글루텐 약화 효과
      }

      // 초산 - 글루텐 약화 (사워도우)
      else if (name.contains('초산') ||
          name.contains('acetic acid') ||
          name.contains('식초') ||
          name.contains('vinegar')) {
        correction -= percentage * 0.3; // 글루텐 약화 효과
      }

      // 효소제 (프로테아제) - 글루텐 약화
      else if (name.contains('프로테아제') ||
          name.contains('protease') ||
          name.contains('효소')) {
        correction -= percentage * 1.5; // 글루텐 분해 효과
      }

      // 꿀 및 시럽류 - 글루텐 약화 (점도가 높아 수화 방해)
      else if (name.contains('꿀') ||
          name.contains('honey') ||
          name.contains('시럽') ||
          name.contains('syrup') ||
          name.contains('물엿') ||
          name.contains('maltose') ||
          name.contains('메이플') ||
          name.contains('maple') ||
          name.contains('아가베') ||
          name.contains('agave')) {
        correction -= percentage * 0.4; // 점성으로 인한 글루텐 형성 저해
      }

      // 고농도 당분 (과당, 포도당) - 글루텐 약화
      else if (name.contains('과당') ||
          name.contains('fructose') ||
          name.contains('포도당') ||
          name.contains('glucose') ||
          name.contains('콘 시럽') ||
          name.contains('corn syrup')) {
        correction -= percentage * 0.5; // 고농도 당분의 글루텐 저해 효과
      }
    }

    return correction;
  }

  /// 반죽 방법 보정 계산
  static double _calculateDoughMethodCorrection(
      List<Map<String, dynamic>> ingredients, String? recipeTitle) {
    double correction = 0.0;

    // 탕종법 감지 (뜨거운 물 사용)
    final hasHotWater = ingredients.any((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      return name.contains('뜨거운') ||
          name.contains('탕종') ||
          name.contains('hot water') ||
          name.contains('boiling water');
    });

    if (hasHotWater) {
      correction += 2.0; // 탕종법 글루텐 강화 효과
    }

    // 사워도우 감지 (스타터나 천연 효모 관련)
    final hasSourdoughIngredients = ingredients.any((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      return name.contains('사워') ||
          name.contains('스타터') ||
          name.contains('천연효모') ||
          name.contains('sourdough') ||
          name.contains('starter') ||
          name.contains('levain');
    });

    if (hasSourdoughIngredients) {
      correction += 1.5; // 사워도우 글루텐 강화 효과
    }

    // 냉장 발효 감지 (레시피 제목으로 추정)
    if (recipeTitle != null) {
      final title = recipeTitle.toLowerCase();
      if (title.contains('냉장') ||
          title.contains('콜드') ||
          title.contains('cold') ||
          title.contains('retard')) {
        correction += 1.0; // 냉장 발효 글루텐 강화 효과
      }
    }

    return correction;
  }

  /// 반죽 물리화학 계수 계산
  /// 공식: [글루텐 형성 지수] × [수분 상태 계수] × [지방 영향 계수] × [열역학 전달 계수]
  static double _calculateDoughPhysicochemicalFactor(
      List<Map<String, dynamic>> ingredients,
      double temperature,
      String? recipeTitle) {
    final glutenFormationIndex =
        _calculateGlutenStrengthIndex(ingredients, recipeTitle, {});

    // 수분 상태 계수
    final waterHardness = 150.0; // 일반적인 물 경도 (ppm)
    final waterTemperatureDeviation = (temperature - 20.0).abs();
    final moistureStateFactor =
        1 + (waterHardness * 0.0002) + (waterTemperatureDeviation * 0.01);

    // 지방 영향 계수
    final fatPercentage = _calculateFatPercentage(ingredients, recipeTitle);
    final solidFatPercentage = fatPercentage * 0.7; // 고체 지방 추정
    final liquidFatPercentage = fatPercentage * 0.3; // 액체 지방 추정
    final fatInfluenceFactor =
        1 - (solidFatPercentage * 0.02) - (liquidFatPercentage * 0.01);

    // 열역학 전달 계수 (반죽 크기 추정)
    final flourWeight = _calculateFlourWeight(ingredients, recipeTitle);
    final estimatedDoughSize =
        math.pow(flourWeight / 100, 1 / 3) * 10; // cm 단위 추정
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
      String? recipeTitle) {
    // 이스트 농도 계수
    final yeastPercentage = IngredientAnalyzer.calculateYeastPercentage(
            ingredients,
            recipeTitle: recipeTitle) /
        100.0;
    final standardYeastPercentage = 0.006; // 표준 이스트 비율 0.6%
    final yeastConcentrationFactor =
        math.pow(yeastPercentage / standardYeastPercentage, 0.8).toDouble();

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
    final sugarConcentrationFactor =
        1 - 0.2 * ((sugarPercentage - 4.0).abs() / 4.0);

    final microbialFactor = 1 /
        (yeastConcentrationFactor *
            temperatureActivityFactor *
            phInfluenceFactor *
            sugarConcentrationFactor);

    return microbialFactor.clamp(0.1, 3.0);
  }

  /// 환경 기후 계수 계산 (기후학)
  /// 공식: 1 + (습도 보정) + (기압 보정) + (계절 보정)
  static double _calculateEnvironmentalFactor(
      double temperature, double humidity, double altitude, String season) {
    // 습도 보정
    final humidityCorrection = (humidity - 65.0) * 0.005;

    // 기압 보정 (고도 기반)
    final standardPressure = 1013.0; // hPa
    final pressureAtAltitude =
        standardPressure * math.pow(1 - (0.0065 * altitude / 288.15), 5.255);
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

    final environmentalFactor =
        1 + humidityCorrection + pressureCorrection + seasonCorrection;
    return environmentalFactor.clamp(0.5, 2.0);
  }

  /// 반죽 밀도 계산 (물리학)
  static double _calculateDoughDensity(
      List<Map<String, dynamic>> ingredients,
      double doughWeight,
      double doughVolume,
      double hydrationLevel,
      String? recipeTitle) {
    if (doughWeight > 0 && doughVolume > 0) {
      return doughWeight / doughVolume; // g/cm³
    }

    // 추정 계산
    final flourWeight = _calculateFlourWeight(ingredients, recipeTitle);
    final totalWeight =
        flourWeight * (1 + hydrationLevel + 0.05); // 기타 재료 5% 추정

    // 수분율과 발효 상태에 따른 밀도 추정
    final baseDensity = 1.2; // g/cm³ (기본 반죽 밀도)
    final hydrationEffect = -0.3 * hydrationLevel; // 수분이 많을수록 밀도 감소
    final estimatedDensity = baseDensity + hydrationEffect;

    return estimatedDensity.clamp(0.8, 1.5);
  }

  /// 반죽 질감 특성 분석
  static String _analyzeTextureCharacteristics(
      double hydrationLevel,
      double glutenStrengthIndex,
      double fermentationProgress,
      double environmentTemperature,
      double environmentHumidity) {
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
  static double _calculateGasRetentionIndex(double glutenStrengthIndex,
      double hydrationLevel, double fermentationProgress) {
    // 글루텐 망의 강도가 가스 보유력의 핵심
    final glutenFactor = glutenStrengthIndex / 15.0; // 정규화

    // 적절한 수분율이 가스 보유에 도움
    final hydrationFactor = hydrationLevel > 0.6
        ? (1.0 - (hydrationLevel - 0.6).abs() * 2)
        : hydrationLevel / 0.6;

    // 발효 진행도에 따른 가스 생성량
    final fermentationFactor = fermentationProgress;

    final gasRetention = glutenFactor * hydrationFactor * fermentationFactor;
    return gasRetention.clamp(0.0, 1.0);
  }

  /// 반죽 탄성 지수 계산
  static double _calculateElasticityIndex(double glutenStrengthIndex,
      double hydrationLevel, double saltPercentage) {
    // 글루텐 강도가 탄성의 기본
    final glutenFactor = glutenStrengthIndex / 15.0;

    // 수분율이 탄성에 미치는 영향
    final hydrationFactor = hydrationLevel > 0.7
        ? (1.0 - (hydrationLevel - 0.7) * 2)
        : hydrationLevel / 0.7;

    // 소금이 글루텐 강화에 미치는 영향
    final saltFactor = saltPercentage > 0.015
        ? 1.0 + (saltPercentage - 0.015) * 10
        : saltPercentage / 0.015;

    final elasticity = glutenFactor * hydrationFactor * saltFactor;
    return elasticity.clamp(0.0, 1.0);
  }

  /// 표면 상태 분석
  static String _analyzeSurfaceCondition(double hydrationLevel,
      double fermentationProgress, double environmentHumidity) {
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

  /// 온도 효율 계산 (글루텐 형성 최적 온도 범위: 20-30°C)
  static double _calculateTemperatureEfficiency(double temperature) {
    const double optimalTemp = 25.0; // 최적 온도
    const double optimalRange = 5.0; // 최적 범위 (±5°C)

    if (temperature >= optimalTemp - optimalRange &&
        temperature <= optimalTemp + optimalRange) {
      return 1.0; // 최적 범위
    } else if (temperature >= optimalTemp - optimalRange * 2 &&
        temperature <= optimalTemp + optimalRange * 2) {
      return 0.8; // 허용 범위
    } else {
      return 0.6; // 좋지 않은 범위
    }
  }

  /// 습도 효율 계산 (글루텐 형성 최적 습도: 60-70%)
  static double _calculateHumidityEfficiency(double humidity) {
    const double optimalHumidity = 65.0; // 최적 습도
    const double optimalRange = 10.0; // 최적 범위 (±10%)

    if (humidity >= optimalHumidity - optimalRange &&
        humidity <= optimalHumidity + optimalRange) {
      return 1.0; // 최적 범위
    } else if (humidity >= optimalHumidity - optimalRange * 2 &&
        humidity <= optimalHumidity + optimalRange * 2) {
      return 0.8; // 허용 범위
    } else {
      return 0.6; // 좋지 않은 범위
    }
  }

  /// 고도 효율 계산 (해발고도에 따른 기압 영향)
  static double _calculateAltitudeEfficiency(double altitude) {
    // 해수면 기압: 1013.25 hPa
    // 고도 100m당 기압 약 12 hPa 감소
    const double seaLevelPressure = 1013.25;
    const double pressureDecreasePer100m = 12.0;

    // 고도에 따른 기압 계산
    final pressure =
        seaLevelPressure - (altitude / 100) * pressureDecreasePer100m;

    // 최적 기압 범위: 950-1050 hPa
    if (pressure >= 950 && pressure <= 1050) {
      return 1.0; // 최적 범위
    } else if (pressure >= 900 && pressure <= 1100) {
      return 0.9; // 허용 범위
    } else {
      return 0.7; // 좋지 않은 범위
    }
  }

  /// 중앙화된 FermentationCalculator로부터 안전하게 발효 진행률을 가져옵니다
  /// 기본값 없이 실제 중앙화 데이터를 사용 (혼란 방지)
  static double _getFermentationProgressFromCentralizedResult() {
    final fermentationResult =
        FermentationCalculator.getLastFermentationResult();
    if (fermentationResult == null) {
      _log('발효 분석 결과 없음 - 진행률 0으로 초기화 (중앙화 미설정 상태)');
      return 0.0; // 분석되지 않은 상태로 안전한 초기값
    }

    if (fermentationResult.stepResults.isEmpty) {
      _log('발효 단계 결과 없음 - 진행률 0으로 초기화 (단계 미완료 상태)');
      return 0.0; // 단계를 수행하지 않았거나 결과가 없는 상태
    }

    // 최종 단계의 진행률을 사용 (가장 최근 진행 상태 반영)
    final latestProgress =
        fermentationResult.stepResults.last.fermentationProgress;
    _log(
        '중앙화된 발효 진행률 적용: ${latestProgress.toStringAsFixed(3)} (단계수: ${fermentationResult.stepResults.length})');
    return latestProgress;
  }

  // === 헬퍼 메서드들 ===

  static double _calculateFatPercentage(
      List<Map<String, dynamic>> ingredients, String? recipeTitle) {
    final flourWeight = _calculateFlourWeight(ingredients, recipeTitle);
    if (flourWeight == 0) return 0.0;

    final fatIngredients = ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      return name.contains('버터') ||
          name.contains('butter') ||
          name.contains('기름') ||
          name.contains('oil') ||
          name.contains('마가린') ||
          name.contains('margarine');
    }).toList();

    double totalFat = 0.0;
    for (final fat in fatIngredients) {
      final amount = fat['amount'] as double? ?? 0.0;
      final unit = fat['unit'] as String? ?? 'g';
      totalFat += IngredientAnalyzer.convertToGrams(
          amount, unit, fat['name'] as String? ?? '');
    }

    return (totalFat / flourWeight) * 100;
  }

  static double _calculateSugarPercentage(
      List<Map<String, dynamic>> ingredients, String? recipeTitle) {
    final flourWeight = _calculateFlourWeight(ingredients, recipeTitle);
    if (flourWeight == 0) return 0.0;

    final sugarIngredients = ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      return name.contains('설탕') ||
          name.contains('sugar') ||
          name.contains('꿀') ||
          name.contains('honey') ||
          name.contains('시럽') ||
          name.contains('syrup') ||
          name.contains('물엿') ||
          name.contains('maltose') ||
          name.contains('메이플') ||
          name.contains('maple') ||
          name.contains('아가베') ||
          name.contains('agave') ||
          name.contains('코코넛 슈가') ||
          name.contains('coconut sugar') ||
          name.contains('흑설탕') ||
          name.contains('brown sugar') ||
          name.contains('조청') ||
          name.contains('rice syrup') ||
          name.contains('콘 시럽') ||
          name.contains('corn syrup') ||
          name.contains('과당') ||
          name.contains('fructose') ||
          name.contains('포도당') ||
          name.contains('glucose');
    }).toList();

    double totalSugar = 0.0;
    for (final sugar in sugarIngredients) {
      final amount = sugar['amount'] as double? ?? 0.0;
      final unit = sugar['unit'] as String? ?? 'g';
      final weightInGrams = IngredientAnalyzer.convertToGrams(
          amount, unit, sugar['name'] as String? ?? '');

      // 꿀과 시럽류는 점도가 높아 글루텐 형성에 더 큰 영향을 미침
      final name = (sugar['name'] as String? ?? '').toLowerCase();
      if (name.contains('꿀') ||
          name.contains('honey') ||
          name.contains('시럽') ||
          name.contains('syrup')) {
        // 꿀과 시럽류는 같은 무게 대비 글루텐 형성 저해 효과 1.2배
        totalSugar += weightInGrams * 1.2;
      } else {
        totalSugar += weightInGrams;
      }
    }

    return (totalSugar / flourWeight) * 100;
  }

  static double _calculateFlourWeight(
      List<Map<String, dynamic>> ingredients, String? recipeTitle) {
    final flourIngredients = IngredientAnalyzer.findFlourIngredients(
        ingredients,
        recipeTitle: recipeTitle);
    double totalWeight = 0.0;

    for (final flour in flourIngredients) {
      final amount = flour['amount'] as double? ?? 0.0;
      final unit = flour['unit'] as String? ?? 'g';
      totalWeight += IngredientAnalyzer.convertToGrams(
          amount, unit, flour['name'] as String? ?? '');
    }

    return totalWeight;
  }

  /// 점성 지수 계산 (유체역학)
  static double _calculateViscosityIndex(double hydrationLevel,
      double glutenStrengthIndex, double doughTemperature) {
    // 기본 점성 계산
    double baseViscosity = 1.0;

    // 수분율에 따른 점성
    final hydrationFactor = hydrationLevel > 0.7
        ? hydrationLevel * 1.5 // 고수분: 점성 증가
        : hydrationLevel * 1.0; // 저수분: 점성 감소

    // 글루텐 강도에 따른 점성
    final glutenFactor = glutenStrengthIndex / 15.0; // 정규화

    // 온도에 따른 점성 (온도가 높을수록 점성 감소)
    final temperatureFactor =
        math.max(0.5, 1.0 - (doughTemperature - 20.0) * 0.02);

    final viscosityIndex =
        baseViscosity * hydrationFactor * glutenFactor * temperatureFactor;
    return viscosityIndex.clamp(0.1, 3.0);
  }

  /// 표면 장력 계수 계산 (물리화학)
  static double _calculateSurfaceTensionFactor(double hydrationLevel) {
    // 수분율에 따른 표면 장력
    // 수분율이 높을수록 표면 장력이 낮아짐
    final surfaceTension = 1.0 - (hydrationLevel - 0.5) * 0.5;
    return surfaceTension.clamp(0.3, 1.0);
  }

  /// 열전달 특성 분석 (물리학)
  static Map<String, dynamic> _analyzeHeatTransferCharacteristics(
      double doughDensity, double hydrationLevel, double gasRetentionIndex) {
    // 열전달 효율 계산
    final heatTransferEfficiency = (1.0 / doughDensity) * hydrationLevel * 2.0;

    // 열 침투 시간 계산 (분)
    final heatPenetrationTime = doughDensity * 10.0 / (hydrationLevel + 0.1);

    // 가스 보유에 따른 열전달 보정
    final gasCorrection = 1.0 + gasRetentionIndex * 0.2;

    return {
      'heatTransferEfficiency': heatTransferEfficiency * gasCorrection,
      'heatPenetrationTime': heatPenetrationTime / gasCorrection,
      'thermalConductivity': heatTransferEfficiency * 0.1,
      'specificHeatCapacity': 2.5 + hydrationLevel * 0.5,
    };
  }

  /// 반죽 안정성 지수 계산
  static double _calculateStabilityIndex(
      double glutenStrengthIndex,
      double fermentationProgress,
      double gasRetentionIndex,
      double elasticityIndex,
      double environmentalFactor) {
    // 각 요소의 기여도
    final glutenContribution = glutenStrengthIndex / 15.0; // 글루텐 강도
    final fermentationContribution = fermentationProgress; // 발효 진행도
    final gasRetentionContribution = gasRetentionIndex; // 가스 보유력
    final elasticityContribution = elasticityIndex; // 탄성
    final environmentalContribution = environmentalFactor; // 환경 요인

    // 가중 평균 계산
    final stabilityIndex = (glutenContribution * 0.3 + // 글루텐: 30%
            fermentationContribution * 0.25 + // 발효: 25%
            gasRetentionContribution * 0.2 + // 가스 보유: 20%
            elasticityContribution * 0.15 + // 탄성: 15%
            environmentalContribution * 0.1 // 환경: 10%
        );

    return stabilityIndex.clamp(0.0, 1.0);
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
    if (glutenStrengthIndex >= 12.0)
      return "매우 강함 (${glutenStrengthIndex.toStringAsFixed(1)})";
    if (glutenStrengthIndex >= 8.0)
      return "강함 (${glutenStrengthIndex.toStringAsFixed(1)})";
    if (glutenStrengthIndex >= 5.0)
      return "보통 (${glutenStrengthIndex.toStringAsFixed(1)})";
    if (glutenStrengthIndex >= 2.0)
      return "약함 (${glutenStrengthIndex.toStringAsFixed(1)})";
    return "매우 약함 (${glutenStrengthIndex.toStringAsFixed(1)})";
  }

  /// 발효 진행도 텍스트
  String get fermentationProgressText {
    if (fermentationProgress >= 0.9)
      return "과발효 위험 (${(fermentationProgress * 100).toStringAsFixed(0)}%)";
    if (fermentationProgress >= 0.7)
      return "충분히 발효됨 (${(fermentationProgress * 100).toStringAsFixed(0)}%)";
    if (fermentationProgress >= 0.5)
      return "적당히 발효됨 (${(fermentationProgress * 100).toStringAsFixed(0)}%)";
    if (fermentationProgress >= 0.2)
      return "발효 진행 중 (${(fermentationProgress * 100).toStringAsFixed(0)}%)";
    return "발효 초기 (${(fermentationProgress * 100).toStringAsFixed(0)}%)";
  }

  /// 가스 보유력 텍스트
  String get gasRetentionText {
    if (gasRetentionIndex >= 0.8)
      return "우수 (${(gasRetentionIndex * 100).toStringAsFixed(0)}%)";
    if (gasRetentionIndex >= 0.6)
      return "양호 (${(gasRetentionIndex * 100).toStringAsFixed(0)}%)";
    if (gasRetentionIndex >= 0.4)
      return "보통 (${(gasRetentionIndex * 100).toStringAsFixed(0)}%)";
    if (gasRetentionIndex >= 0.2)
      return "부족 (${(gasRetentionIndex * 100).toStringAsFixed(0)}%)";
    return "매우 부족 (${(gasRetentionIndex * 100).toStringAsFixed(0)}%)";
  }

  /// 탄성 지수 텍스트
  String get elasticityText {
    if (elasticityIndex >= 0.8)
      return "매우 탄력적 (${(elasticityIndex * 100).toStringAsFixed(0)}%)";
    if (elasticityIndex >= 0.6)
      return "탄력적 (${(elasticityIndex * 100).toStringAsFixed(0)}%)";
    if (elasticityIndex >= 0.4)
      return "적당한 탄성 (${(elasticityIndex * 100).toStringAsFixed(0)}%)";
    if (elasticityIndex >= 0.2)
      return "탄성 부족 (${(elasticityIndex * 100).toStringAsFixed(0)}%)";
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
      doughPhysicochemicalFactor:
          json['doughPhysicochemicalFactor']?.toDouble() ?? 0.0,
      microbialActivityFactor:
          json['microbialActivityFactor']?.toDouble() ?? 0.0,
      environmentalFactor: json['environmentalFactor']?.toDouble() ?? 1.0,
      fermentationProgress: json['fermentationProgress']?.toDouble() ?? 0.0,
      gasRetentionIndex: json['gasRetentionIndex']?.toDouble() ?? 0.0,
      elasticityIndex: json['elasticityIndex']?.toDouble() ?? 0.0,
      viscosityIndex: json['viscosityIndex']?.toDouble() ?? 0.0,
      surfaceTensionFactor: json['surfaceTensionFactor']?.toDouble() ?? 1.0,
      doughDensity: json['doughDensity']?.toDouble() ?? 1.0,
      stabilityIndex: json['stabilityIndex']?.toDouble() ?? 0.0,
      heatTransferCharacteristics:
          Map<String, dynamic>.from(json['heatTransferCharacteristics'] ?? {}),
      textureAnalysis: json['textureAnalysis'] ?? "분석 불가",
      surfaceCondition: json['surfaceCondition'] ?? "분석 불가",
      hydrationLevel: json['hydrationLevel']?.toDouble() ?? 0.0,
      yeastPercentage: json['yeastPercentage']?.toDouble() ?? 0.0,
      saltPercentage: json['saltPercentage']?.toDouble() ?? 0.0,
      analysisTimestamp: DateTime.parse(
          json['analysisTimestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// 점성 지수 텍스트
  String get viscosityText {
    if (viscosityIndex >= 2.0)
      return "높음 (${viscosityIndex.toStringAsFixed(1)})";
    if (viscosityIndex >= 1.0)
      return "보통 (${viscosityIndex.toStringAsFixed(1)})";
    return "낮음 (${viscosityIndex.toStringAsFixed(1)})";
  }

  /// 안정성 지수 텍스트
  String get stabilityText {
    if (stabilityIndex >= 0.8)
      return "매우 안정 (${(stabilityIndex * 100).toStringAsFixed(0)}%)";
    if (stabilityIndex >= 0.6)
      return "안정 (${(stabilityIndex * 100).toStringAsFixed(0)}%)";
    if (stabilityIndex >= 0.4)
      return "보통 (${(stabilityIndex * 100).toStringAsFixed(0)}%)";
    return "불안정 (${(stabilityIndex * 100).toStringAsFixed(0)}%)";
  }

  /// 반죽 밀도 텍스트
  String get doughDensityText {
    return "${doughDensity.toStringAsFixed(2)} g/cm³";
  }

  /// 열전달 효율 텍스트
  String get heatTransferEfficiencyText {
    final efficiency =
        heatTransferCharacteristics['heatTransferEfficiency'] as double? ?? 0.0;
    if (efficiency >= 4.0) return "매우 높음 (${efficiency.toStringAsFixed(1)})";
    if (efficiency >= 3.0) return "높음 (${efficiency.toStringAsFixed(1)})";
    if (efficiency >= 2.0) return "보통 (${efficiency.toStringAsFixed(1)})";
    return "낮음 (${efficiency.toStringAsFixed(1)})";
  }

  /// 열 침투 시간 텍스트
  String get heatPenetrationTimeText {
    final time =
        heatTransferCharacteristics['heatPenetrationTime'] as double? ?? 0.0;
    return "${time.toStringAsFixed(0)}분";
  }
}
