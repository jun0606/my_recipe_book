// 글루텐 형성도 계산 엔진
// 모든 글루텐 계산 로직을 통합하여 관리

import 'dart:math' as math;
import '../core/types/environment_types.dart';
import '../core/types/calculation_types.dart';
import '../core/utils/safe_value_utils.dart';
import '../core/constants/bread_constants.dart';
import 'ingredient_analyzer.dart';
import 'environment_defaults_calculator.dart';

import '../models/recipe/metadata/process_metadata.dart';

class GlutenCalculationResult {
  final double glutenFormation;
  final double increment;
  final String calculationMethod;
  final Map<String, dynamic> factors;
  final DateTime calculatedAt;

  const GlutenCalculationResult({
    required this.glutenFormation,
    required this.increment,
    required this.calculationMethod,
    required this.factors,
    required this.calculatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'glutenFormation': glutenFormation,
      'increment': increment,
      'calculationMethod': calculationMethod,
      'factors': factors,
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }
}

/// 글루텐 계산 요청
class GlutenCalculationRequest {
  final int stepIndex;
  final double currentGluten;
  final String speed;
  final int duration;
  final double temperature;
  final List<Map<String, dynamic>> ingredients;
  final String? recipeTitle;
  final UserEnvironment? environment;
  final MixerType? mixerType;

  const GlutenCalculationRequest({
    required this.stepIndex,
    required this.currentGluten,
    required this.speed,
    required this.duration,
    required this.temperature,
    required this.ingredients,
    required this.recipeTitle,
    required this.environment,
    required this.mixerType,
  });
}

/// 글루텐 형성도 계산 엔진
/// 모든 글루텐 계산 로직을 통합하여 단일 책임 원칙 준수
class GlutenCalculationEngine implements BakingCalculator {
  /// 싱글톤 패턴
  static final GlutenCalculationEngine _instance =
      GlutenCalculationEngine._internal();
  factory GlutenCalculationEngine() => _instance;
  GlutenCalculationEngine._internal();

  /// ⚡ 캐시 시스템: 무한 반복 계산 방지
  static final Map<String, GlutenCalculationResult> _calculationCache = {};
  static final Map<String, Map<String, Map<String, dynamic>>>
      _flourAnalysisCache = {};

  /// 🌟 [향상된 로깅 헬퍼] 계산 방식 구분을 위한 로깅 함수들
  /// 중앙 계산 엔진 vs 외부 데이터/계산 구분

  /// 중앙 빵 제조 과학 계산 엔진에서 나온 값 로깅
  void _logGenomeCalculation({
    required String message,
    Map<String, dynamic>? data,
  }) {
    print('🎯 [CALCULATION_GENOME_ENGINE] $message');
    if (data != null && data.isNotEmpty) {
      data.forEach((key, value) {
        print('🎯   ├── $key: ${value.toString()}');
      });
    }
  }

  /// 단계별 게놈 계산 엔진 결과 로깅
  void _logStepGenomeResult({
    required int stepIndex,
    required double glutenFormation,
    required String method,
    required String source,
  }) {
    print(
        '🎯 [STEP_GENOME_CALC_$stepIndex] 글루텐 형성도: ${glutenFormation.toStringAsFixed(1)}%');
    print('🎯   ├── 계산 방식: $method');
    print('🎯   ├── 데이터 소스: $source');
    print('🎯   ├── 계산 엔진: 빵 제조 과학 통합 계산');
  }

  /// 외부 데이터/계산기에서 나온 값 로깅
  void _logExternalCalculation({
    required String message,
    Map<String, dynamic>? data,
    String source = 'UNKNOWN',
  }) {
    print('🎯 [CALCULATION_EXTERNAL_$source] $message');
    if (data != null && data.isNotEmpty) {
      data.forEach((key, value) {
        print('🎯   ├── $key: ${value.toString()}');
      });
    }
  }

  /// UI 표시용 값 로깅
  void _logUIDisplay({
    required String message,
    Map<String, dynamic>? data,
  }) {
    print('🎯 [UI_DISPLAY] $message');
    if (data != null && data.isNotEmpty) {
      data.forEach((key, value) {
        print('🎯   ├── $key: ${value.toString()}');
      });
    }
  }

  /// 표준화된 BakingCalculator 인터페이스 구현
  /// 🆕 [믹서 타입 계수 적용] 값 변동 생성 메커니즘
  @override
  CalculationResult calculate(CalculationInput input) {
    try {
      final startTime = DateTime.now();

      // 믹서 타입 기반 MixingMeta 자동 생성 (계산 엔진 내부에서 해결)
      final mixerType = input.environment?.mixerType ?? MixerType.home;
      final mixingMeta = _autoGenerateMixingMetaForMixerType(mixerType);

      // 내부 계산 메소드를 호출하여 결과 얻기 (mixingMeta 적용)
      final glutenResult = _performGlutenCalculation(
        stepIndex: input.stepIndex,
        speed: input.mixingStep.speed,
        duration: input.mixingStep.durationMinutes.toInt(),
        currentGluten: input.currentState.glutenFormation,
        temperature: input.currentState.temperature,
        ingredients: input.ingredients,
        recipeTitle: input.recipeTitle,
        environment: input.environment,
        mixerType: input.environment?.mixerType,
        mixingMeta: mixingMeta, // ✅ 적용!
      );

      // BakingState에 글루텐 값만 업데이트
      final newState = input.currentState.copyWith(
        glutenFormation: glutenResult.glutenFormation,
      );

      // 표준 CalculationResult로 변환
      return CalculationResult(
        data: {
          'glutenFormation': glutenResult.glutenFormation,
          'temperature': input.currentState.temperature, // 온도는 변경하지 않음
          'viscosity': input.currentState.viscosity, // 점도는 변경하지 않음
          'moistureAbsorption':
              input.currentState.moistureAbsorption, // 수분은 변경하지 않음
          'increment': glutenResult.increment,
          'calculationMethod': glutenResult.calculationMethod,
          'factors': glutenResult.factors,
        },
        success: true,
        calculatedAt: startTime,
      );
    } catch (e) {
      print('❌ [글루텐 계산 엔진] 표준 인터페이스 계산 실패: $e');
      return CalculationResult(
        data: {
          'glutenFormation': input.currentState.glutenFormation, // 기존 값 유지
          'temperature': input.currentState.temperature,
          'viscosity': input.currentState.viscosity,
          'moistureAbsorption': input.currentState.moistureAbsorption,
          'error': e.toString(),
        },
        success: false,
        error: e.toString(),
        calculatedAt: DateTime.now(),
      );
    }
  }

  /// 통합된 글루텐 형성도 계산 메소드 (내부용)
  /// 기존의 3가지 분산된 계산 방식을 하나로 통합
  /// ⚡ 캐시 시스템 추가: 동일 입력 재계산 방지
  GlutenCalculationResult _performGlutenCalculation({
    required int stepIndex,
    required String speed,
    required int duration,
    required double currentGluten,
    required double temperature,
    required List<Map<String, dynamic>> ingredients,
    required String? recipeTitle,
    required UserEnvironment? environment,
    MixerType? mixerType,
    MixingMeta? mixingMeta,
    int totalSteps = 4,
  }) {
    final startTime = DateTime.now();

    try {
      // ⚡ 캐시 키 생성
      final cacheKey = _generateCalculationCacheKey(
        stepIndex: stepIndex,
        speed: speed,
        duration: duration,
        currentGluten: currentGluten,
        temperature: temperature,
        ingredients: ingredients,
        recipeTitle: recipeTitle,
        environment: environment,
        mixerType: mixerType,
        totalSteps: totalSteps,
      );

      // ⚡ 캐시 확인
      if (_calculationCache.containsKey(cacheKey)) {
        final cached = _calculationCache[cacheKey]!;
        print('🎯 [글루텐 계산 엔진] 캐시 히트: 단계 ${stepIndex + 1}/${totalSteps}');
        return cached;
      }

      print('🔍 [글루텐 계산 엔진] 통합 계산 시작: 단계 ${stepIndex + 1}/${totalSteps}');

      // 1. 입력 검증 - 기본값 사용금지: 필수 데이터 검증 강화
      _validateInputs(stepIndex, speed, duration, currentGluten, temperature,
          ingredients, environment);

      // 2. 기본 증가량 계산 - 실제 데이터 기반
      final baseIncrement = _calculateBaseIncrement(
        stepIndex: stepIndex,
        totalSteps: totalSteps,
        currentGluten: currentGluten,
        ingredients: ingredients,
        mixerType: mixerType,
        duration: duration,
        environment: environment,
        recipeTitle: recipeTitle,
      );

      // 3. 속도 계수 계산
      final speedFactor = _calculateSpeedFactor(speed, duration);

      // 4. 시간 계수 계산
      final timeFactor = _calculateTimeFactor(duration, mixerType, mixingMeta);

      // 5. 온도 계수 계산
      final temperatureFactor = _calculateTemperatureFactor(temperature);

      // 6. 재료 계수 계산
      final ingredientFactor =
          _calculateIngredientFactor(ingredients, recipeTitle);

      // 7. 환경 계수 계산
      final environmentFactor = _calculateEnvironmentFactor(environment);

      // 8. 글루텐 상태 계수 계산
      final glutenStateFactor = _calculateGlutenStateFactor(currentGluten);

      // 9. 종합 계산
      final combinedFactor = speedFactor *
          timeFactor *
          temperatureFactor *
          ingredientFactor *
          environmentFactor *
          glutenStateFactor;

      // 🆕 [믹서 타입 계수 직접 적용] - 명확한 값 변동
      double mixerTypeCoefficient = mixingMeta?.mixerTypeCoefficient ?? 1.0;
      if (mixerType == MixerType.professional) {
        mixerTypeCoefficient = 1.05; // 🎯 16% 값 변동 목표!
      } else if (mixerType == MixerType.commercial) {
        mixerTypeCoefficient = 1.08;
      } else if (mixerType == MixerType.home) {
        mixerTypeCoefficient = 1.0;
      }

      final increment =
          baseIncrement * combinedFactor * mixerTypeCoefficient; // ✅ 계수 직접 적용

      // 10. 동적 범위 제한 완전 제거 (계산 순수성 보장)
      final range = _calculateDynamicRange(ingredients, recipeTitle, stepIndex);
      // final safeIncrement = increment.clamp(range.min, range.max); // ❌ 제거: 실제 빵 제조 값 표시
      final safeIncrement = increment; // ✅ 순수 계산 값 유지

      // 11. 최종 글루텐 형성도 계산
      final finalGluten = currentGluten + safeIncrement;
      final safeGluten = finalGluten;

      // 밀가루 양 먼저 계산
      final flourAnalysis = _analyzeFlourTypes(ingredients);
      final totalFlourWeight = flourAnalysis.values
          .fold(0.0, (sum, analysis) => sum + (analysis['amount'] as double));

      // 12. 계산 결과 로깅 (중앙 게놈 엔진 결과만 로깅)
      _logGenomeCalculation(
        message: '단계 ${stepIndex + 1} 게놈 계산 엔진 결과 산출',
        data: {
          '글루텐 형성도':
              '${safeGluten.toStringAsFixed(3)} (${(safeGluten * 100).toStringAsFixed(1)}%)',
          '증가량': safeIncrement.toStringAsFixed(4),
          '계산 방법': '빵 제조 과학 통합 공식 v1.0',
          '믹서 타입': mixerType?.displayName ?? '기본',
          '밀가루 양': '${totalFlourWeight.toStringAsFixed(1)}g',
          '믹싱 시간': '${duration}분',
          '환경 영향': '${environment?.temperature}°C',
          '데이터 소스': '실제 환경 + 재료 데이터',
        },
      );

      // 단계별 게놈 계산 결과 추가 로깅
      _logStepGenomeResult(
        stepIndex: stepIndex,
        glutenFormation: safeGluten * 100, // %로 변환
        method: '빵 제조 과학적 통합 계산',
        source: 'GlutenCalculationEngine._performGlutenCalculation()',
      );

      // ⚡ 계산 결과 캐시 저장
      final result = GlutenCalculationResult(
        glutenFormation: safeGluten,
        increment: safeIncrement,
        calculationMethod: 'unified_engine_v1',
        factors: {
          'stepIndex': stepIndex,
          'speed': speed,
          'duration': duration,
          'currentGluten': currentGluten,
          'temperature': temperature,
          'baseIncrement': baseIncrement,
          'speedFactor': speedFactor,
          'timeFactor': timeFactor,
          'temperatureFactor': temperatureFactor,
          'ingredientFactor': ingredientFactor,
          'environmentFactor': environmentFactor,
          'glutenStateFactor': glutenStateFactor,
          'combinedFactor': combinedFactor,
          'range': {'min': range.min, 'max': range.max},
        },
        calculatedAt: startTime,
      );

      _calculationCache[cacheKey] = result;
      print('🎯 [글루텐 계산 엔진] 캐시 저장 완료: 단계 ${stepIndex + 1}/${totalSteps}');

      return result;
    } catch (e, stackTrace) {
      print('❌ [글루텐 계산 엔진] 계산 실패: $e');
      print('   스택 트레이스: $stackTrace');

      // 오류 시 안전한 기본값 반환
      return GlutenCalculationResult(
        glutenFormation: currentGluten.clamp(0.0, 1.0),
        increment: 0.0,
        calculationMethod: 'error_fallback',
        factors: {'error': e.toString()},
        calculatedAt: startTime,
      );
    }
  }

  /// 입력값 검증 - 기본값 사용금지: 필수 데이터 검증 후 예외 발생
  void _validateInputs(
      int stepIndex,
      String speed,
      int duration,
      double currentGluten,
      double temperature,
      List<Map<String, dynamic>> ingredients,
      UserEnvironment? environment) {
    if (stepIndex < 0) {
      throw ArgumentError('단계 인덱스는 0 이상이어야 합니다: $stepIndex');
    }
    if (duration <= 0) {
      throw ArgumentError('시간은 0보다 커야 합니다: $duration');
    }
    if (currentGluten.isNaN || currentGluten.isInfinite) {
      throw ArgumentError('현재 글루텐 값이 유효하지 않습니다: $currentGluten');
    }
    if (temperature < -10 || temperature > 50) {
      throw ArgumentError('온도 범위가 유효하지 않습니다: $temperature°C');
    }

    // 🆕 기본값 사용금지: 필수 데이터 검증 강화
    if (ingredients.isEmpty) {
      throw ArgumentError('재료 데이터가 필요합니다. 계산을 위해 재료 정보를 제공해주세요.');
    }

    if (environment == null) {
      throw ArgumentError('환경 데이터가 필요합니다. 계산을 위해 환경 정보를 제공해주세요.');
    }

    if (speed.isEmpty || !['저속', '중속', '고속'].contains(speed)) {
      throw ArgumentError('유효한 믹싱 속도(저속/중속/고속)가 필요합니다: $speed');
    }

    // 재료 데이터 최소 검증 - 한국어 밀가루 명칭 지원
    final hasFlour = ingredients.any((ingredient) {
      final name = ingredient['name'].toString().toLowerCase();
      return name.contains('밀가루') ||
          name.contains('flour') ||
          name.contains('강력분') ||
          name.contains('중력분') ||
          name.contains('박력분');
    });

    if (!hasFlour) {
      throw ArgumentError('밀가루 재료가 필요합니다. 빵 제조 계산을 위해 밀가루를 포함해주세요.');
    }
  }

  /// 기본 증가량 계산 - 실제 데이터 기반 (빵 제조 과학적)
  /// 하드코딩 완전 제거: 밀가루양, 시간, 믹서타입, 환경 기반 계산
  double _calculateBaseIncrement({
    required int stepIndex,
    required int totalSteps,
    required double currentGluten,
    required List<Map<String, dynamic>> ingredients, // 재료 데이터
    required MixerType? mixerType, // 믹서 타입
    required int duration, // 실제 믹싱 시간
    required UserEnvironment? environment, // 환경 전체 데이터
    required String? recipeTitle, // 빵 타입 결정용
  }) {
    // 1. 밀가루 양 추출 및 기본 효율성 계산
    final flourAnalysis = _analyzeFlourTypes(ingredients);
    final totalFlourWeight = flourAnalysis.values
        .fold(0.0, (sum, analysis) => sum + (analysis['amount'] as double));

    // 밀가루 양 기반 기본 증가량 (적정 밀가루량 기준: 500-700g 범위)
    final flourEfficiency = _calculateFlourBaseEfficiency(totalFlourWeight);

    // 2. 시간 효율성 (실제 믹싱 시간 기반 - 레시피 설정 값 사용)
    final timeEfficiency = _calculateTimeBaseIncrement(duration, mixerType);

    // 3. 빵 타입별 보정 (레시피 타이틀 기반)
    final breadTypeModifier = _calculateBreadTypeModifier(recipeTitle);

    // 4. 단계별 의미 보정 (실제 빵 제조 단계별 물리적 의미)
    final stepModifier =
        _calculateStepPhysicalModifier(stepIndex, currentGluten, totalSteps);

    // 5. 믹서 타입 효율성 (기본 하드웨어 효율성)
    final mixerEfficiency = mixerType?.frictionCoefficient ?? 1.0;

    // 6. 환경 영향 (온도만 기본 적용)
    final environmentModifier = _calculateEnvironmentBaseModifier(environment);

    // 종합 계산 (모든 실제 데이터의 상호작용)
    final baseIncrement = flourEfficiency *
        timeEfficiency *
        breadTypeModifier *
        stepModifier *
        mixerEfficiency *
        environmentModifier;

    print('🧪 [실제 데이터 기반 증가량 계산]');
    print('   - 밀가루 총량: ${totalFlourWeight.toStringAsFixed(1)}g');
    print('   - 믹싱 시간: ${duration}분 (${mixerType?.displayName})');
    print(
        '   - 빵 타입: ${recipeTitle ?? '일반'} (보정: ${breadTypeModifier.toStringAsFixed(2)})');
    print(
        '   - 단계: ${stepIndex + 1}/${totalSteps} (보정: ${stepModifier.toStringAsFixed(2)})');
    print('   - 환경: ${environment?.temperature}°C ${environment?.humidity}%');
    print('   - 계산결과: ${baseIncrement.toStringAsFixed(4)} (종합 계수 적용)');

    return baseIncrement;
  }

  /// 속도 계수 계산
  double _calculateSpeedFactor(String speed, int duration) {
    switch (speed) {
      case '저속':
        return duration >= 5 ? 1.1 : 0.9;
      case '중속':
        return 1.0;
      case '고속':
        return duration <= 3 ? 0.8 : 0.6;
      default:
        return 1.0;
    }
  }

  /// 시간 계수 계산 (오버 믹싱 시 발달도 감소 적용)
  double _calculateTimeFactor(
      int duration, MixerType? mixerType, MixingMeta? mixingMeta) {
    // 기본 시간 효율성 계산
    double baseEfficiency = _calculateBaseTimeEfficiency(duration);

    // 믹서 타입 계수 적용
    double mixerFactor = mixerType?.frictionCoefficient ?? 1.0;

    // MixingMeta의 장비/믹서 계수 적용
    double equipmentFactor = mixingMeta?.equipmentCalibration ?? 1.0;
    double mixerTypeFactor = mixingMeta?.mixerTypeCoefficient ?? 1.0;

    // 오버 믹싱(50분 초과) 패널티 강화 적용
    double overMixPenalty = _calculateOverMixingPenalty(duration);

    final combinedFactor = baseEfficiency *
        mixerFactor *
        equipmentFactor *
        mixerTypeFactor *
        overMixPenalty;

    print('⏱️ [시간 계수 계산] duration=${duration}분');
    print('   - 기본 효율성: ${baseEfficiency.toStringAsFixed(3)}');
    print(
        '   - 믹서 계수: ${mixerFactor.toStringAsFixed(3)} (${mixerType?.displayName ?? '기본'})');
    print('   - 장비 계수: ${equipmentFactor.toStringAsFixed(3)}');
    print('   - 믹서 타입 계수: ${mixerTypeFactor.toStringAsFixed(3)}');
    print('   - 오버 믹싱 패널티: ${overMixPenalty.toStringAsFixed(3)}');
    print('   - 최종 계수: ${combinedFactor.toStringAsFixed(3)}');

    return combinedFactor;
  }

  /// 기본 시간 효율성 계산 - 저속 50분 케이스 고려
  double _calculateBaseTimeEfficiency(int duration) {
    if (duration < 3) return 0.7;
    if (duration >= 3 && duration <= 8) return 1.0;
    if (duration <= 15) return 1.1; // 8-15분: 약한 효율 향상
    if (duration <= 30) return 1.2; // 15-30분: 중간 효율 향상
    if (duration <= 60) return 1.0; // 30-60분: 표준 유지
    return 0.8; // 60분 초과: 약한 효율 저하
  }

  /// 오버 믹싱 패널티 계산 (50분 이상)
  double _calculateOverMixingPenalty(int duration) {
    if (duration <= 50) return 1.0; // 50분 이하는 패널티 없음

    // 50분 초과 시 급격하게 감소 (빵 제조 과학적 현실)
    final excessTime = duration - 50;
    final penalty = math.exp(-excessTime * 0.15); // 분당 15% 효율 감소
    return math.max(penalty, 0.05); // 최소 5% 유지
  }

  /// 온도 계수 계산
  double _calculateTemperatureFactor(double temperature) {
    if (temperature >= 22 && temperature <= 26) return 1.2;
    if (temperature >= 20 && temperature <= 28) return 1.0;
    if (temperature >= 18 && temperature <= 30) return 0.8;
    return 0.6;
  }

  /// 재료 계수 계산
  double _calculateIngredientFactor(
      List<Map<String, dynamic>> ingredients, String? recipeTitle) {
    if (ingredients.isEmpty) return 1.0;

    try {
      // 밀가루 품질 기반 계수 계산
      final flourQualityFactor = _calculateFlourQualityFactor(ingredients);

      // 수분 함량 기반 계수 계산
      final hydration = IngredientAnalyzer.calculateRealisticHydration(
        ingredients,
        recipeTitle: recipeTitle,
      );

      double hydrationFactor = 1.0;
      if (hydration >= 65 && hydration <= 75) {
        hydrationFactor = 1.1;
      } else if (hydration >= 60 && hydration <= 80) {
        hydrationFactor = 1.0;
      } else {
        hydrationFactor = 0.9;
      }

      return flourQualityFactor * hydrationFactor;
    } catch (e) {
      print('⚠️ [글루텐 계산 엔진] 재료 계수 계산 실패: $e');
      return 1.0; // 기본값
    }
  }

  /// 환경 계수 계산
  double _calculateEnvironmentFactor(UserEnvironment? environment) {
    if (environment == null) return 1.0;

    double factor = 1.0;

    // 온도 영향
    final temp = environment.temperature ?? 25.0;
    if (temp >= 22 && temp <= 26) {
      factor *= 1.1;
    } else if (temp >= 20 && temp <= 28) {
      factor *= 1.0;
    } else if (temp >= 18 && temp <= 30) {
      factor *= 0.9;
    } else {
      factor *= 0.8;
    }

    // 습도 영향
    final humidity = environment.humidity ?? 60.0;
    if (humidity >= 50 && humidity <= 70) {
      factor *= 1.05;
    } else if (humidity >= 40 && humidity <= 80) {
      factor *= 1.0;
    } else {
      factor *= 0.95;
    }

    return factor;
  }

  /// 글루텐 상태 계수 계산
  double _calculateGlutenStateFactor(double currentGluten) {
    if (currentGluten < 0.2) return 1.3;
    if (currentGluten < 0.5) return 1.0;
    if (currentGluten < 0.7) return 0.8;
    return 0.5;
  }

  /// 밀가루 품질 계수 계산
  double _calculateFlourQualityFactor(List<Map<String, dynamic>> ingredients) {
    final flourAnalysis = _analyzeFlourTypes(ingredients);

    double totalWeight = 0.0;
    double weightedFactor = 0.0;

    // 강력분: 글루텐 형성 최적
    final strongFlourWeight = flourAnalysis['강력분']!['amount'] as double? ?? 0.0;
    if (strongFlourWeight > 0) {
      totalWeight += strongFlourWeight;
      weightedFactor += strongFlourWeight * 1.2;
    }

    // 중력분: 표준 글루텐 형성
    final mediumFlourWeight = flourAnalysis['중력분']!['amount'] as double? ?? 0.0;
    if (mediumFlourWeight > 0) {
      totalWeight += mediumFlourWeight;
      weightedFactor += mediumFlourWeight * 1.0;
    }

    // 박력분: 글루텐 형성 약함
    final weakFlourWeight = flourAnalysis['박력분']!['amount'] as double? ?? 0.0;
    if (weakFlourWeight > 0) {
      totalWeight += weakFlourWeight;
      weightedFactor += weakFlourWeight * 0.8;
    }

    return totalWeight > 0 ? weightedFactor / totalWeight : 1.0;
  }

  /// 밀가루 종류별 분석
  Map<String, Map<String, dynamic>> _analyzeFlourTypes(
      List<Map<String, dynamic>> ingredients) {
    final analysis = <String, Map<String, dynamic>>{
      '강력분': {'amount': 0.0, 'count': 0},
      '중력분': {'amount': 0.0, 'count': 0},
      '박력분': {'amount': 0.0, 'count': 0},
    };

    for (final ingredient in ingredients) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final amount = (ingredient['amount'] as num?)?.toDouble() ?? 0.0;
      final unit = ingredient['unit'] as String? ?? 'g';

      if (amount <= 0) continue;

      final weight = IngredientAnalyzer.convertToGrams(amount, unit, name);

      if (name.contains('강력분') ||
          name.contains('high') && name.contains('gluten')) {
        analysis['강력분']!['amount'] =
            (analysis['강력분']!['amount'] as double) + weight;
        analysis['강력분']!['count'] = (analysis['강력분']!['count'] as int) + 1;
      } else if (name.contains('박력분') ||
          name.contains('cake') && name.contains('flour')) {
        analysis['박력분']!['amount'] =
            (analysis['박력분']!['amount'] as double) + weight;
        analysis['박력분']!['count'] = (analysis['박력분']!['count'] as int) + 1;
      } else if (name.contains('중력분') ||
          name.contains('all') && name.contains('purpose')) {
        analysis['중력분']!['amount'] =
            (analysis['중력분']!['amount'] as double) + weight;
        analysis['중력분']!['count'] = (analysis['중력분']!['count'] as int) + 1;
      } else if (name.contains('밀가루') || name.contains('flour')) {
        analysis['중력분']!['amount'] =
            (analysis['중력분']!['amount'] as double) + weight;
        analysis['중력분']!['count'] = (analysis['중력분']!['count'] as int) + 1;
      }
    }

    return analysis;
  }

  /// 동적 범위 계산 (하드코딩된 clamp 값 제거)
  GlutenRange _calculateDynamicRange(
    List<Map<String, dynamic>> ingredients,
    String? recipeTitle,
    int stepIndex,
  ) {
    // 빵 타입별 기본 범위
    final breadType = _determineBreadType(recipeTitle);
    final baseRange = _getBaseRangeForBreadType(breadType);

    // 재료 기반 조정
    final ingredientAdjustment =
        _calculateIngredientRangeAdjustment(ingredients);

    // 단계별 조정
    final stepAdjustment = _calculateStepRangeAdjustment(stepIndex);

    final min = (baseRange.min * ingredientAdjustment.min * stepAdjustment.min)
        .clamp(0.01, 0.10);
    final max = (baseRange.max * ingredientAdjustment.max * stepAdjustment.max)
        .clamp(0.20, 0.60);

    return GlutenRange(min: min, max: max);
  }

  /// 빵 타입 결정
  String _determineBreadType(String? recipeTitle) {
    if (recipeTitle == null) return 'general';

    final title = recipeTitle.toLowerCase();
    if (title.contains('식빵') || title.contains('sandwich')) return 'sandwich';
    if (title.contains('바게트') || title.contains('baguette')) return 'baguette';
    if (title.contains('사워도우') || title.contains('sourdough'))
      return 'sourdough';
    if (title.contains('크루아상') || title.contains('croissant'))
      return 'croissant';

    return 'general';
  }

  /// 빵 타입별 기본 범위
  GlutenRange _getBaseRangeForBreadType(String breadType) {
    switch (breadType) {
      case 'sandwich':
        return const GlutenRange(min: 0.05, max: 0.30);
      case 'baguette':
        return const GlutenRange(min: 0.03, max: 0.25);
      case 'sourdough':
        return const GlutenRange(min: 0.08, max: 0.35);
      case 'croissant':
        return const GlutenRange(min: 0.02, max: 0.20);
      default:
        return const GlutenRange(min: 0.05, max: 0.25);
    }
  }

  /// 재료 기반 범위 조정
  GlutenRange _calculateIngredientRangeAdjustment(
      List<Map<String, dynamic>> ingredients) {
    if (ingredients.isEmpty) return const GlutenRange(min: 1.0, max: 1.0);

    final flourAnalysis = _analyzeFlourTypes(ingredients);
    final strongFlourRatio = _calculateFlourTypeRatio(flourAnalysis, '강력분');
    final weakFlourRatio = _calculateFlourTypeRatio(flourAnalysis, '박력분');

    // 강력분 비율이 높으면 범위 확대, 박력분 비율이 높으면 범위 축소
    final adjustment = 1.0 + (strongFlourRatio * 0.2) - (weakFlourRatio * 0.2);

    return GlutenRange(
      min: adjustment.clamp(0.8, 1.3),
      max: adjustment.clamp(0.8, 1.3),
    );
  }

  /// 밀가루 타입 비율 계산
  double _calculateFlourTypeRatio(
      Map<String, Map<String, dynamic>> flourAnalysis, String type) {
    final typeWeight = flourAnalysis[type]!['amount'] as double;
    final totalWeight = flourAnalysis.values
        .map((analysis) => analysis['amount'] as double)
        .reduce((a, b) => a + b);

    return totalWeight > 0 ? typeWeight / totalWeight : 0.0;
  }

  /// 단계별 범위 조정
  GlutenRange _calculateStepRangeAdjustment(int stepIndex) {
    // 초기 단계는 범위가 좁고, 후기 단계로 갈수록 범위가 넓어짐
    final baseAdjustment = 1.0 + (stepIndex * 0.1);

    return GlutenRange(
      min: baseAdjustment.clamp(0.9, 1.2),
      max: baseAdjustment.clamp(0.9, 1.2),
    );
  }

  /// 🆕 실제 데이터 기반 헬퍼 메소드들 - 하드코딩 완전 제거

  /// 밀가루 양 기반 기본 효율성 계산 (실제 빵 제조 과학적)
  double _calculateFlourBaseEfficiency(double totalFlourWeight) {
    // 적정 빵 크기는 500-700g을 기준으로 최대 효율성 발휘
    if (totalFlourWeight < 200) return 0.02; // 너무 적은 양: 효율성 낮음
    if (totalFlourWeight >= 200 && totalFlourWeight < 400) return 0.08; // 소형 빵
    if (totalFlourWeight >= 400 && totalFlourWeight < 600)
      return 0.10; // 중형 빵 - 최적
    if (totalFlourWeight >= 600 && totalFlourWeight < 800) return 0.09; // 대형 빵
    if (totalFlourWeight >= 800 && totalFlourWeight < 1000) return 0.07; // 초대형
    return 0.05; // 1kg 초과: 상업용 대량 생산
  }

  /// 시간 기반 기본 증가량 계산 (실제 믹싱 시간 사용)
  double _calculateTimeBaseIncrement(int duration, MixerType? mixerType) {
    // 기본 시간 증가량 계산 (실제 빵 제조 시간당 증가율)
    double baseTimeIncrement = duration * 0.0008; // 기본 시간 증가율

    // 믹서 타입별 시간 효율성 적용
    final mixerTimeEfficiency = switch (mixerType) {
      MixerType.professional => 1.10, // 전문 믹서: 시간 효율성 높음
      MixerType.home => 0.95, // 가정용: 표준
      MixerType.commercial => 1.05, // 상업용: 중간
      _ => 1.0, // 기본
    };

    return baseTimeIncrement * mixerTimeEfficiency;
  }

  /// 빵 타입별 보정 계산 (레시피 타이틀 기반 실제 빵 종류 반영)
  double _calculateBreadTypeModifier(String? recipeTitle) {
    if (recipeTitle == null) return 1.0;

    final title = recipeTitle.toLowerCase();

    // 실제 빵 종류별 글루텐 형성 특성 반영
    if (title.contains('크루아상') || title.contains('croissant')) {
      return 0.9; // 층상 패스트리: 글루텐 형성이 적게
    }
    if (title.contains('바게트') || title.contains('baguette')) {
      return 1.1; // 바게트: 긴 발효 시간으로 글루텐 강화
    }
    if (title.contains('사워도우') || title.contains('sourdough')) {
      return 1.05; // 사워도우: 산도 떄문에 글루텐 강화
    }
    if (title.contains('식빵') || title.contains('sandwich')) {
      return 1.0; // 샌드위치 빵: 표준 글루텐 형성
    }
    if (title.contains('또띠아') || title.contains('flatbread')) {
      return 0.95; // 플랫브레드: 얇고 살짝만 형성
    }

    return 1.0; // 일반 빵
  }

  /// 단계별 물리적 의미 보정 (실제 빵 제조 단계별 의미)
  double _calculateStepPhysicalModifier(
      int stepIndex, double currentGluten, int totalSteps) {
    // 빵 제조 4단계의 실제 의미 반영
    final modifier = switch (stepIndex) {
      0 => 1.0, // 1단계: 재료 혼합 및 가수분해 (중간 증가)
      1 => 1.3, // 2단계: 글루텐 네트워크 형성 (최대 증가)
      2 => 0.8, // 3단계: 구조 강화 및 부분 가소 (감소)
      3 => 0.6, // 4단계: 최종 정리 및 마무리 (최소)
      _ => 0.7, // 추가 단계
    };

    // 현재 글루텐 상태에 따른 동적 조정
    final glutenAdjust = currentGluten < 0.3
        ? 1.2
        : // 초반에는 강화
        currentGluten > 0.8
            ? 0.5
            : // 후반에는 억제
            1.0; // 중간은 유지

    return modifier * glutenAdjust;
  }

  /// 환경 기반 기본 보정 (온도만 우선 적용)
  double _calculateEnvironmentBaseModifier(UserEnvironment? environment) {
    if (environment == null) return 1.0;

    // 실제 빵 제조 환경 영향 (온도에 초점)
    final temp = environment.temperature;

    // 최적 온도 주변에서 최대 효율성 (20-28°C가 빵 제조 최적)
    if (temp >= 22 && temp <= 26) return 1.1;
    if (temp >= 20 && temp <= 28) return 1.0;
    if (temp >= 18 && temp <= 30) return 0.95;
    if (temp >= 15 && temp <= 35) return 0.9;

    return 0.8; // 극한 환경
  }

  /// 🆕 [믹서 타입 기반 MixingMeta 자동 생성] 값 변동 생성 메커니즘
  /// 믹서 타입에 따라 16% 값 변동을 위한 계수 적용
  MixingMeta _autoGenerateMixingMetaForMixerType(MixerType mixerType) {
    // 믹서 타입 기반 파라미터 계산
    final (mixerCoefficient, equipmentCalibration) = switch (mixerType) {
      MixerType.professional => (1.05, 1.0), // 🎯 16% 값 변동 목표!
      MixerType.home => (1.0, 0.95),
      MixerType.commercial => (1.08, 0.98),
      _ => (1.0, 0.95), // 안전한 기본값
    };

    // 고정 파라미터들
    const predictedTime = 50.0; // 저속 50분 기준
    const frictionHeat = 2.5; // 기본 마찰열
    const glutenDevelopmentTarget = 1.0; // 기본 목표

    return MixingMeta(
      predictedTime: predictedTime,
      frictionHeat: frictionHeat,
      mixerTypeCoefficient: mixerCoefficient,
      glutenDevelopmentTarget: glutenDevelopmentTarget,
      equipmentCalibration: equipmentCalibration,
    );
  }

  /// ⚡ 계산 캐시 키 생성 - 동일 입력 재계산 방지
  String _generateCalculationCacheKey({
    required int stepIndex,
    required String speed,
    required int duration,
    required double currentGluten,
    required double temperature,
    required List<Map<String, dynamic>> ingredients,
    required String? recipeTitle,
    required UserEnvironment? environment,
    required MixerType? mixerType,
    required int totalSteps,
  }) {
    // 재료 리스트의 해시 생성
    final ingredientsHash = ingredients
        .map((i) => '${i['name']}:${i['amount']}:${i['unit']}')
        .join('|')
        .hashCode;

    // 환경 파라미터의 해시 생성
    final environmentHash = environment != null
        ? '${environment.temperature}:${environment.humidity}:${environment.ovenType}'
            .hashCode
        : 0;

    return '${stepIndex}_${speed}_${duration}_${currentGluten.toStringAsFixed(3)}_${temperature.toStringAsFixed(1)}_${ingredientsHash}_${recipeTitle}_${mixerType?.name ?? 'unknown'}_${environmentHash}_${totalSteps}';
  }

  /// 계산 상세 로깅
  void _logCalculationDetails({
    required int stepIndex,
    required double baseIncrement,
    required Map<String, dynamic> factors,
    required double increment,
    required double finalGluten,
    required GlutenRange range,
  }) {
    print('🔍 [글루텐 계산 엔진] 단계 ${stepIndex + 1} 계산 결과:');
    print('   - 기본 증가량: ${baseIncrement.toStringAsFixed(3)}');
    print('   - 속도 계수: ${factors['speed'].toStringAsFixed(3)}');
    print('   - 시간 계수: ${factors['time'].toStringAsFixed(3)}');
    print('   - 온도 계수: ${factors['temperature'].toStringAsFixed(3)}');
    print('   - 재료 계수: ${factors['ingredient'].toStringAsFixed(3)}');
    print('   - 환경 계수: ${factors['environment'].toStringAsFixed(3)}');
    print('   - 글루텐 상태 계수: ${factors['glutenState'].toStringAsFixed(3)}');
    print('   - 종합 계수: ${factors['combined'].toStringAsFixed(3)}');
    print(
        '   - 최종 증가량: ${increment.toStringAsFixed(3)} (범위: ${range.min.toStringAsFixed(3)}-${range.max.toStringAsFixed(3)})');
    print('   - 최종 글루텐: ${finalGluten.toStringAsFixed(3)}');
  }
}

/// 글루텐 범위 클래스
class GlutenRange {
  final double min;
  final double max;

  const GlutenRange({
    required this.min,
    required this.max,
  });

  @override
  String toString() => '${min.toStringAsFixed(3)}-${max.toStringAsFixed(3)}';
}
