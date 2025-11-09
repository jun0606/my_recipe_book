import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/types/environment_types.dart';
import '../../features/chef/screen/widgets/fermentation_analysis_types.dart'
    as art;
import '../../services/ingredient_analyzer.dart'; // IngredientAnalyzer import

/// 발효 분석 헬퍼 유틸리티들 (중복 제거용)
class FermentationAnalysisHelpers {
  // 싱글턴 패턴 적용
  static final FermentationAnalysisHelpers _instance =
      FermentationAnalysisHelpers._internal();
  factory FermentationAnalysisHelpers() => _instance;
  FermentationAnalysisHelpers._internal();

  /// 🔍 범용 데이터 검증 헬퍼
  static double validateNumericValue(dynamic value, String fieldName,
      {double? fallback}) {
    if (value is num && value.toDouble().isFinite) {
      return value.toDouble();
    }
    if (fallback != null) {
      return fallback;
    }
    throw StateError(
        'Invalid numeric value for $fieldName: $value - contsep violation (basic values not allowed)');
  }

  static String validateStringValue(dynamic value, String fieldName,
      {String? fallback}) {
    if (value is String && value.isNotEmpty) {
      return value;
    }
    if (fallback != null) {
      return fallback;
    }
    throw StateError(
        'Invalid string value for $fieldName: $value - contsep violation (basic values not allowed)');
  }

  /// 🌡️ 믹싱 결과 데이터 추출 헬퍼 (다중 폴백 지원)
  static double extractNumericFromMixingResult(
    Map<String, dynamic> result,
    String primaryKey,
    UserEnvironment? environment, {
    String? stepAnalysesPath,
    double fallback = 0.0,
    double? environmentFallback,
  }) {
    // 1. 직접 필드 시도
    if (result.containsKey(primaryKey) && result[primaryKey] is num) {
      return validateNumericValue(result[primaryKey], primaryKey,
          fallback: fallback);
    }

    // 2. stepAnalyses에서 마지막 단계 추출
    if (stepAnalysesPath != null &&
        result.containsKey('stepAnalyses') &&
        result['stepAnalyses'] is List &&
        result['stepAnalyses'].isNotEmpty) {
      final lastStep = result['stepAnalyses'].last;
      if (lastStep is Map && lastStep.containsKey('doughState')) {
        final doughState = lastStep['doughState'] as Map?;
        if (doughState != null &&
            doughState.containsKey(stepAnalysesPath) &&
            doughState[stepAnalysesPath] is num) {
          return validateNumericValue(
              doughState[stepAnalysesPath], stepAnalysesPath,
              fallback: fallback);
        }
      }
    }

    // 3. 환경 기반 폴백
    if (environmentFallback != null && environment != null) {
      return environmentFallback;
    }

    return fallback;
  }

  /// 🏠 환경 데이터 헬퍼
  static bool isValidEnvironment(UserEnvironment? env) {
    return env?.temperature != null && env?.humidity != null;
  }

  static double getSafeTemperature(UserEnvironment? env,
      {double fallback = 26.0}) {
    return env?.temperature?.toDouble() ?? fallback;
  }

  static double getSafeHumidity(UserEnvironment? env,
      {double fallback = 60.0}) {
    return env?.humidity?.toDouble() ?? fallback;
  }

  /// 📝 표준화된 디버그 로깅
  static void logAnalysisStep(String operation, [Map<String, dynamic>? data]) {
    debugPrint('🔬 [빵 제조 과학 계산] $operation');
    if (data != null) {
      data.forEach((key, value) => debugPrint('   $key: $value'));
    }
  }

  static void logValidationStep(
      String context, Map<String, dynamic> validations) {
    debugPrint('✅ [컨트롤러 검증] $context:');
    validations.forEach((key, value) => debugPrint('   - $key: $value'));
  }

  static void logDataStatus(String context, Map<String, bool> statusMap) {
    debugPrint('🔍 [컨트롤러] $context:');
    statusMap.forEach(
        (key, hasData) => debugPrint('   - $key: ${hasData ? '있음' : '없음'}'));
  }

  /// ⏱️ 시간 변환 헬퍼
  static Duration hoursToDuration(double hours) {
    final wholeHours = hours.floor();
    final minutes = ((hours - wholeHours) * 60).round();
    return Duration(hours: wholeHours, minutes: minutes);
  }

  static double durationToHours(Duration duration) {
    return duration.inMinutes / 60.0;
  }

  static double safeDurationHours(dynamic value, {double fallback = 2.0}) {
    return validateNumericValue(value, 'durationHours', fallback: fallback);
  }

  /// 📊 메트릭 계산 헬퍼(중복 제거)
  static art.YeastActivityLevel determineYeastActivityLevel(
      double yeastActivity) {
    if (yeastActivity >= 0.8) return art.YeastActivityLevel.high;
    if (yeastActivity >= 0.5) return art.YeastActivityLevel.medium;
    if (yeastActivity >= 0.2) return art.YeastActivityLevel.low;
    return art.YeastActivityLevel.inactive;
  }

  static art.VolumeExpansion determineVolumeExpansion(double volumeIncrease) {
    if (volumeIncrease >= 80.0) return art.VolumeExpansion.excellent;
    if (volumeIncrease >= 50.0) return art.VolumeExpansion.excessive;
    if (volumeIncrease >= 30.0) return art.VolumeExpansion.moderate;
    return art.VolumeExpansion.minimal;
  }

  /// 📈 성공 확률 계산 헬퍼
  static double calculateSuccessProbability(double lastStepProgress) {
    logAnalysisStep('종결 단계 진행률 기반 성공 확률 계산',
        {'진행률': '${lastStepProgress.toStringAsFixed(1)}%'});
    return lastStepProgress; // 컨셉 준수: 데이터 오염 제거
  }

  /// 🎯 발효 단계 전략 판별 헬퍼
  static art.FermentationStage determineStageFromPosition(
      int stepNumber, int totalSteps) {
    final relativePosition = stepNumber / math.max(totalSteps, 1);
    if (stepNumber == 1 || relativePosition <= 0.25)
      return art.FermentationStage.primary;
    if (stepNumber <= 2 || relativePosition <= 0.75)
      return art.FermentationStage.secondary;
    return art.FermentationStage.final_;
  }

  /// 🥣 믹싱 상태 검증 헬퍼
  static void ensureMixingResultAvailable(Map<String, dynamic>? result) {
    if (result == null) {
      throw StateError(
          'Mixing result not available - data validation required before access');
    }
  }

  /// 🎨 유연한 단계 메모 생성
  static String generateStepNotes(int stepNumber, String baseNote) {
    return '$baseNote - 자동 중앙화';
  }

  /// ✅ 믹싱 단계 총시간 계산 (컨셉 준수: 데이터 기반) - 분 단위로 계산
  static double calculateTotalMixingHoursFromResult(
      Map<String, dynamic> mixingResult) {
    final stepAnalyses = mixingResult['stepAnalyses'] as List<dynamic>? ?? [];

    double totalMinutes = 0.0; // 분 단위로 계산
    for (final step in stepAnalyses) {
      if (step is Map<String, dynamic>) {
        final durationMinutes =
            (step['durationMinutes'] as num?)?.toDouble() ?? 0.0;
        totalMinutes += durationMinutes; // 분 단위 그대로 더함
      }
    }

    return totalMinutes > 0 ? totalMinutes : 0.0; // 분 단위를 그대로 반환
  }

  /// ✅ 믹싱 잔류 CO₂ 계산 (컨셉 100% 준수: 데이터 관계만 사용)
  static double calculateMixingResidualCO2({
    required Map<String, dynamic> mixingResult,
    required Map<String, dynamic> fermentationEnvironment,
    required List<Map<String, dynamic>> ingredients,
  }) {
    debugPrint('🧪 [믹싱 CO₂ 디버그] ===== 시작 =====');
    debugPrint('   - mixingResult null 여부: ${mixingResult == null}');
    if (mixingResult != null) {
      debugPrint('   - mixingResult type: ${mixingResult.runtimeType}');
      debugPrint('   - 전체 키들: ${mixingResult.keys.toList()}');
      debugPrint(
          '   - stepAnalyses 존재: ${mixingResult.containsKey('stepAnalyses')}');
      if (mixingResult.containsKey('stepAnalyses')) {
        final stepAnalyses =
            mixingResult['stepAnalyses'] as List<dynamic>? ?? [];
        debugPrint('   - stepAnalyses 길이: ${stepAnalyses.length}');
        if (stepAnalyses.isNotEmpty) {
          final firstStep = stepAnalyses.first as Map<String, dynamic>;
          debugPrint('   - 첫 단계 데이터: $firstStep');
          debugPrint(
              '   - durationMinutes 확인: ${firstStep.containsKey('durationMinutes')}');
          debugPrint('   - durationMinutes 값: ${firstStep['durationMinutes']}');
        }
      }

      // 다른 관련 키들도 확인
      debugPrint(
          '   - finalGlutenFormation 존재: ${mixingResult.containsKey('finalGlutenFormation')}');
      debugPrint(
          '   - finalTemperature 존재: ${mixingResult.containsKey('finalTemperature')}');
    }

    final totalMixingMinutes =
        calculateTotalMixingHoursFromResult(mixingResult);
    debugPrint('   - 총 믹싱 시간 계산: ${totalMixingMinutes}분');

    final yeastAmount = calculateYeastWeightFromIngredients(ingredients);
    debugPrint('   - 이스트 양: ${yeastAmount}g');

    debugPrint('🧪 [믹싱 CO₂ 디버그] ===== 종료 =====');

    // ✅ 컨셉 준수: 데이터 조건 불충족 → 0 반환 (계수·기본값 완전 제거)
    if (totalMixingMinutes <= 0 || yeastAmount <= 0) {
      return 0.0;
    }

    // ✅ 순수 데이터 관계만 사용: 이스트 중량 × 믹싱 시간
    // 모든 계수·임의적 수식·경험치 제거, 데이터 관계 그대로 표현
    final result = yeastAmount * totalMixingMinutes;
    debugPrint('   - 최종 CO₂ 잔류 계산: $result ml');
    return result; // 데이터 관계만: 새로운 데이터 기반 값 반환
  }

  /// 이스트 양 계산 (컨셉 준수: 재료 데이터 기반)
  static double calculateYeastWeightFromIngredients(
      List<Map<String, dynamic>> ingredients) {
    final yeastIngredients =
        IngredientAnalyzer.findYeastIngredients(ingredients);

    double totalYeastWeight = 0.0;
    for (final yeast in yeastIngredients) {
      totalYeastWeight += (yeast['amount'] as num?)?.toDouble() ?? 0.0;
    }

    return totalYeastWeight;
  }
}
