// lib/core/utils/mixing_calculator_integrator.dart
// 믹싱 계산기 통합기 - 파싱 데이터와 계산 로직 통합

import '../../models/recipe.dart';
import '../types/mixing_aliases.dart';
import '../../../features/chef/module/bread/types/unified_types.dart'
    as unified;
import 'mixing_data_extractor.dart';
import 'mixing_type_validator.dart';

/// 믹싱 계산기 통합기
/// 파싱된 데이터와 계산 로직을 통합하여 정확한 믹싱 분석을 수행

class MixingCalculatorIntegrator {
  // 메인 통합 계산 엔트리 포인트
  static CalculationResult<MixingProfileData> calculateWithParsedData(
    unified.UnifiedRecipe recipe, {
    Map<String, dynamic>? environmentData,
    Map<String, dynamic>? constraints,
  }) {
    try {
      // 1. 파싱 데이터 추출
      final extractionResult = MixingDataExtractor.extractFromRecipe(recipe);

      if (!extractionResult.isSuccessful || extractionResult.data == null) {
        // 파싱 실패 시 계산 기반 폴백
        return _fallbackToCalculatedProfile(
            recipe, environmentData, constraints);
      }

      final parsedData = extractionResult.data!;

      // 2. 파싱 데이터 검증
      final validation = ParsingDataValidator.validateParsedData(parsedData);
      if (!validation.isValid) {
        return CalculationResult.error(
          '파싱 데이터 검증 실패: ${validation.errorMessage}',
          calculationName: 'mixing_parsing_validation',
        );
      }

      // 3. 파싱 데이터를 프로파일로 변환
      final conversionResult = MixingTypeAdapter.convertToProfileData(
        {'processes': parsedData.processes.map((p) => p.toJson()).toList()},
        source: TimeDataSource.parsed,
        confidence: parsedData.confidence,
      );

      if (!conversionResult.isSuccessful || conversionResult.data == null) {
        return _fallbackToCalculatedProfile(
            recipe, environmentData, constraints);
      }

      final profileData = conversionResult.data!;

      // 4. 프로파일 검증 및 최적화
      final optimizedProfile = _optimizeProfileWithEnvironment(
          profileData, environmentData, constraints);

      // 5. 최종 검증
      final finalValidation =
          MixingTypeValidator.validateMixingData(optimizedProfile, '최종 프로파일');

      if (finalValidation.isValid) {
        return CalculationResult.success(
          optimizedProfile,
          calculationName: 'mixing_integrated_calculation',
        );
      } else {
        return CalculationResult.error(
          '최종 프로파일 검증 실패: ${finalValidation.errorMessage}',
          calculationName: 'mixing_final_validation',
        );
      }
    } catch (e) {
      return CalculationResult.error(
        '믹싱 계산 통합 실패: $e',
        calculationName: 'mixing_integration_error',
      );
    }
  }

  // 계산 기반 폴백 프로파일 생성
  static CalculationResult<MixingProfileData> _fallbackToCalculatedProfile(
    unified.UnifiedRecipe recipe,
    Map<String, dynamic>? environmentData,
    Map<String, dynamic>? constraints,
  ) {
    try {
      // 기본 계산 기반 프로파일 생성
      final calculatedProfile =
          _createCalculatedProfile(recipe, environmentData);

      // 환경 및 제약 조건 적용
      final adjustedProfile = _applyEnvironmentAdjustments(
          calculatedProfile, environmentData, constraints);

      return CalculationResult.success(
        adjustedProfile,
        calculationName: 'mixing_calculated_fallback',
      );
    } catch (e) {
      // 최종 폴백: 기본 프로파일
      return CalculationResult.success(
        MixingProfileData.defaultProfile(),
        calculationName: 'mixing_default_fallback',
      );
    }
  }

  // 기본 계산 프로파일 생성
  static MixingProfileData _createCalculatedProfile(
    unified.UnifiedRecipe recipe,
    Map<String, dynamic>? environmentData,
  ) {
    // 재료 기반 기본 프로파일 생성
    final flourAmount = _estimateFlourAmount(recipe);
    final waterAmount = _estimateWaterAmount(recipe);
    final hydrationLevel = flourAmount > 0 ? waterAmount / flourAmount : 0.65;

    // 수분 함량에 따른 단계 수 결정
    final stepCount = _determineStepCount(hydrationLevel);
    final steps = <MixingStepData>[];
    int totalTime = 0;

    for (int i = 0; i < stepCount; i++) {
      final stepData =
          _createCalculatedStep(i + 1, stepCount, hydrationLevel, flourAmount);
      steps.add(stepData);
      totalTime += stepData.durationMinutes;
    }

    return MixingProfileData(
      steps: steps,
      totalTime: totalTime,
      primarySource: TimeDataSource.calculated,
      confidence: 0.7, // 계산 기반 중간 신뢰도
    );
  }

  // 단계별 계산된 데이터 생성
  static MixingStepData _createCalculatedStep(
    int stepNumber,
    int totalSteps,
    double hydrationLevel,
    double flourAmount,
  ) {
    // 단계별 속도 결정
    final speed = _determineStepSpeed(stepNumber, totalSteps, hydrationLevel);

    // 단계별 시간 계산
    final baseTime = _calculateBaseTime(flourAmount, stepNumber, totalSteps);
    final adjustedTime = _adjustTimeForHydration(baseTime, hydrationLevel);

    // 목적 추론
    final purpose = _inferCalculatedPurpose(stepNumber, hydrationLevel);

    return MixingStepData(
      stepNumber: stepNumber,
      speed: speed,
      durationMinutes: adjustedTime,
      purpose: purpose,
      source: TimeDataSource.calculated,
    );
  }

  // 환경 조정 적용
  static MixingProfileData _applyEnvironmentAdjustments(
    MixingProfileData profile,
    Map<String, dynamic>? environmentData,
    Map<String, dynamic>? constraints,
  ) {
    if (environmentData == null && constraints == null) {
      return profile;
    }

    final adjustedSteps = <MixingStepData>[];

    for (final step in profile.steps) {
      var adjustedTime = step.durationMinutes;
      var adjustedSpeed = step.speed;

      // 온도 조정
      if (environmentData?.containsKey('temperature') == true) {
        final temperature = environmentData!['temperature'] as num;
        adjustedTime =
            _adjustTimeForTemperature(adjustedTime, temperature.toDouble());
      }

      // 습도 조정
      if (environmentData?.containsKey('humidity') == true) {
        final humidity = environmentData!['humidity'] as num;
        adjustedTime =
            _adjustTimeForHumidity(adjustedTime, humidity.toDouble());
      }

      // 고도 조정
      if (environmentData?.containsKey('altitude') == true) {
        final altitude = environmentData!['altitude'] as num;
        adjustedTime =
            _adjustTimeForAltitude(adjustedTime, altitude.toDouble());
      }

      // 제약 조건 적용
      if (constraints?.containsKey('maxTime') == true) {
        final maxTime = constraints!['maxTime'] as int;
        if (adjustedTime > maxTime) {
          adjustedTime = maxTime;
        }
      }

      adjustedSteps.add(MixingStepData(
        stepNumber: step.stepNumber,
        speed: adjustedSpeed,
        durationMinutes: adjustedTime,
        purpose: step.purpose,
        source: TimeDataSource.adjusted,
      ));
    }

    final totalTime =
        adjustedSteps.fold(0, (sum, step) => sum + step.durationMinutes);

    return MixingProfileData(
      steps: adjustedSteps,
      totalTime: totalTime,
      primarySource: TimeDataSource.adjusted,
      confidence: profile.confidence * 0.9, // 조정으로 신뢰도 약간 감소
    );
  }

  // 프로파일 최적화 (파싱 데이터와 계산 데이터 통합)
  static MixingProfileData _optimizeProfileWithEnvironment(
    MixingProfileData profile,
    Map<String, dynamic>? environmentData,
    Map<String, dynamic>? constraints,
  ) {
    // 환경 데이터를 고려한 최적화
    var optimizedProfile = profile;

    // 환경 조정 적용
    optimizedProfile = _applyEnvironmentAdjustments(
        optimizedProfile, environmentData, constraints);

    // 프로세스 시퀀스 최적화
    optimizedProfile = _optimizeProcessSequence(optimizedProfile);

    // 시간 분배 최적화
    optimizedProfile = _optimizeTimeDistribution(optimizedProfile);

    return optimizedProfile;
  }

  // 프로세스 시퀀스 최적화
  static MixingProfileData _optimizeProcessSequence(MixingProfileData profile) {
    if (profile.steps.length <= 1) return profile;

    final optimizedSteps = List<MixingStepData>.from(profile.steps);

    // 속도 전환 최적화
    for (int i = 1; i < optimizedSteps.length; i++) {
      final currentStep = optimizedSteps[i];
      final previousStep = optimizedSteps[i - 1];

      // 고속에서 저속으로의 급격한 전환 방지
      if (previousStep.speed == '고속' && currentStep.speed == '저속') {
        // 중속 단계 삽입 고려
        if (profile.steps.length < 4) {
          // 최대 4단계로 제한
          optimizedSteps.insert(
              i,
              MixingStepData(
                stepNumber: currentStep.stepNumber,
                speed: '중속',
                durationMinutes: 2, // 짧은 중속 단계
                purpose: '속도 전환 완화',
                source: TimeDataSource.adjusted,
              ));

          // 이후 단계들의 번호 재조정
          for (int j = i + 1; j < optimizedSteps.length; j++) {
            optimizedSteps[j] = MixingStepData(
              stepNumber: optimizedSteps[j].stepNumber + 1,
              speed: optimizedSteps[j].speed,
              durationMinutes: optimizedSteps[j].durationMinutes,
              purpose: optimizedSteps[j].purpose,
              source: optimizedSteps[j].source,
            );
          }
          break; // 한 번에 하나의 최적화만 수행
        }
      }
    }

    final totalTime =
        optimizedSteps.fold(0, (sum, step) => sum + step.durationMinutes);

    return MixingProfileData(
      steps: optimizedSteps,
      totalTime: totalTime,
      primarySource: TimeDataSource.adjusted,
      confidence: profile.confidence * 0.95, // 최적화로 신뢰도 약간 감소
    );
  }

  // 시간 분배 최적화
  static MixingProfileData _optimizeTimeDistribution(
      MixingProfileData profile) {
    final steps = profile.steps;
    if (steps.isEmpty) return profile;

    // 총 시간 재분배 (각 단계가 적절한 시간을 갖도록)
    final optimizedSteps = <MixingStepData>[];

    for (int i = 0; i < steps.length; i++) {
      final originalStep = steps[i];
      var optimizedTime = originalStep.durationMinutes;

      // 첫 단계: 충분한 초기 혼합 시간 확보
      if (i == 0) {
        optimizedTime = optimizedTime.clamp(3, 8);
      }
      // 중간 단계: 주요 발달 시간
      else if (i < steps.length - 1) {
        optimizedTime = optimizedTime.clamp(5, 15);
      }
      // 마지막 단계: 마무리 시간
      else {
        optimizedTime = optimizedTime.clamp(1, 6);
      }

      optimizedSteps.add(MixingStepData(
        stepNumber: originalStep.stepNumber,
        speed: originalStep.speed,
        durationMinutes: optimizedTime,
        purpose: originalStep.purpose,
        source: TimeDataSource.adjusted,
      ));
    }

    final totalTime =
        optimizedSteps.fold(0, (sum, step) => sum + step.durationMinutes);

    return MixingProfileData(
      steps: optimizedSteps,
      totalTime: totalTime,
      primarySource: TimeDataSource.adjusted,
      confidence: profile.confidence * 0.98, // 시간 최적화로 신뢰도 약간 감소
    );
  }

  // 헬퍼 메서드들

  // 단계 수 결정
  static int _determineStepCount(double hydrationLevel) {
    if (hydrationLevel > 0.75) return 3; // 고수분: 3단계
    if (hydrationLevel > 0.68) return 3; // 중수분: 3단계
    if (hydrationLevel > 0.6) return 2; // 중저수분: 2단계
    return 2; // 저수분: 2단계
  }

  // 단계별 속도 결정
  static String _determineStepSpeed(
      int stepNumber, int totalSteps, double hydrationLevel) {
    if (totalSteps == 2) {
      return stepNumber == 1 ? '저속' : '중속';
    } else if (totalSteps == 3) {
      switch (stepNumber) {
        case 1:
          return '저속';
        case 2:
          return '중속';
        case 3:
          return hydrationLevel > 0.7 ? '중속' : '고속';
        default:
          return '중속';
      }
    }
    return '중속';
  }

  // 기본 시간 계산
  static int _calculateBaseTime(
      double flourAmount, int stepNumber, int totalSteps) {
    // 밀가루 100g당 기본 시간
    final baseTimePer100g = 0.8; // 분
    final totalBaseTime = (flourAmount / 100 * baseTimePer100g).round();

    // 단계별 시간 분배
    if (totalSteps == 2) {
      return stepNumber == 1
          ? (totalBaseTime * 0.4).round()
          : (totalBaseTime * 0.6).round();
    } else if (totalSteps == 3) {
      switch (stepNumber) {
        case 1:
          return (totalBaseTime * 0.3).round();
        case 2:
          return (totalBaseTime * 0.5).round();
        case 3:
          return (totalBaseTime * 0.2).round();
        default:
          return 5;
      }
    }

    return 5; // 기본값
  }

  // 수분 함량에 따른 시간 조정
  static int _adjustTimeForHydration(int baseTime, double hydrationLevel) {
    var adjustedTime = baseTime;

    if (hydrationLevel > 0.75) {
      adjustedTime = (adjustedTime * 1.3).round(); // 고수분: 시간 증가
    } else if (hydrationLevel > 0.68) {
      adjustedTime = (adjustedTime * 1.1).round(); // 중수분: 약간 증가
    } else if (hydrationLevel < 0.6) {
      adjustedTime = (adjustedTime * 0.8).round(); // 저수분: 시간 감소
    }

    return adjustedTime.clamp(1, 30);
  }

  // 계산된 목적 추론
  static String _inferCalculatedPurpose(int stepNumber, double hydrationLevel) {
    switch (stepNumber) {
      case 1:
        return '초기 혼합 및 글루텐 형성';
      case 2:
        if (hydrationLevel > 0.7) {
          return '글루텐 네트워크 강화';
        } else {
          return '반죽 발달 및 강도 향상';
        }
      case 3:
        return '최종 혼합 및 가스 함입';
      default:
        return '믹싱 단계';
    }
  }

  // 환경 조정 헬퍼들
  static int _adjustTimeForTemperature(int time, double temperature) {
    if (temperature < 20) {
      return (time * 1.2).round(); // 차가움: 시간 증가
    } else if (temperature > 28) {
      return (time * 0.9).round(); // 더움: 시간 감소
    }
    return time;
  }

  static int _adjustTimeForHumidity(int time, double humidity) {
    if (humidity > 75) {
      return (time * 1.1).round(); // 습함: 시간 증가
    } else if (humidity < 50) {
      return (time * 0.95).round(); // 건조: 시간 약간 감소
    }
    return time;
  }

  static int _adjustTimeForAltitude(int time, double altitude) {
    if (altitude > 1000) {
      return (time * 1.15).round(); // 고지대: 시간 증가
    }
    return time;
  }

  // 재료 양 추정 헬퍼들
  static double _estimateFlourAmount(unified.UnifiedRecipe recipe) {
    return recipe.ingredients
        .where((ing) =>
            ing.name.toLowerCase().contains('밀가루') ||
            ing.name.toLowerCase().contains('flour') ||
            ing.properties['type'] == 'flour')
        .fold(0.0, (sum, ing) => sum + (ing.amount ?? 0.0));
  }

  static double _estimateWaterAmount(unified.UnifiedRecipe recipe) {
    return recipe.ingredients
        .where((ing) =>
            ing.name.toLowerCase().contains('물') ||
            ing.name.toLowerCase().contains('water') ||
            ing.properties['type'] == 'water')
        .fold(0.0, (sum, ing) => sum + (ing.amount ?? 0.0));
  }
}

// 통합 계산 결과
class IntegratedMixingResult {
  final MixingProfileData profile;
  final CalculationResult<MixingProfileData> calculationResult;
  final ValidationResult validationResult;
  final String dataSource; // 'parsed', 'calculated', 'mixed'
  final double integrationConfidence;

  const IntegratedMixingResult({
    required this.profile,
    required this.calculationResult,
    required this.validationResult,
    required this.dataSource,
    required this.integrationConfidence,
  });

  bool get isSuccessful =>
      calculationResult.isSuccessful && validationResult.isValid;
  bool get isHighConfidence => integrationConfidence > 0.8;
}

// 통합 계산 헬퍼
class MixingIntegrationHelper {
  static Future<IntegratedMixingResult> integrateMixingAnalysis(
    unified.UnifiedRecipe recipe, {
    Map<String, dynamic>? environmentData,
    Map<String, dynamic>? constraints,
    bool preferParsedData = true,
  }) async {
    // 통합 계산 수행
    final calculationResult =
        MixingCalculatorIntegrator.calculateWithParsedData(
      recipe,
      environmentData: environmentData,
      constraints: constraints,
    );

    if (!calculationResult.isSuccessful || calculationResult.data == null) {
      // 계산 실패 시 기본 결과 생성
      final defaultProfile = MixingProfileData.defaultProfile();
      return IntegratedMixingResult(
        profile: defaultProfile,
        calculationResult: calculationResult,
        validationResult: MixingTypeValidator.validateMixingData(
            defaultProfile, 'default_fallback'),
        dataSource: 'default',
        integrationConfidence: 0.3,
      );
    }

    final profile = calculationResult.data!;

    // 최종 검증
    final validation =
        MixingTypeValidator.validateMixingData(profile, 'integrated_result');

    // 데이터 소스 및 신뢰도 결정
    final dataSource = _determineDataSource(profile);
    final confidence = _calculateIntegrationConfidence(
        profile, calculationResult, validation, preferParsedData);

    return IntegratedMixingResult(
      profile: profile,
      calculationResult: calculationResult,
      validationResult: validation,
      dataSource: dataSource,
      integrationConfidence: confidence,
    );
  }

  static String _determineDataSource(MixingProfileData profile) {
    final sources = profile.steps.map((step) => step.source).toSet();

    if (sources.contains(TimeDataSource.parsed) && sources.length == 1) {
      return 'parsed';
    } else if (sources.contains(TimeDataSource.calculated) &&
        sources.length == 1) {
      return 'calculated';
    } else {
      return 'mixed';
    }
  }

  static double _calculateIntegrationConfidence(
    MixingProfileData profile,
    CalculationResult<MixingProfileData> calculation,
    ValidationResult validation,
    bool preferParsedData,
  ) {
    double confidence = profile.confidence;

    // 계산 성공도 반영
    if (calculation.isSuccessful) {
      confidence *= 1.1;
    } else {
      confidence *= 0.7;
    }

    // 검증 성공도 반영
    if (validation.isValid) {
      confidence *= 1.05;
    } else {
      confidence *= 0.8;
    }

    // 데이터 소스 선호도 반영
    final dataSource = _determineDataSource(profile);
    if (preferParsedData && dataSource == 'parsed') {
      confidence *= 1.2;
    } else if (!preferParsedData && dataSource == 'calculated') {
      confidence *= 1.1;
    }

    return confidence.clamp(0.0, 1.0);
  }
}
