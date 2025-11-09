// lib/core/utils/mixing_type_validator.dart
// 믹싱 분석 타입 검증 시스템

import '../../../features/chef/module/bread/services/bread_mixing_analyzer.dart'
    as bma;
import '../../../features/chef/module/bread/models/bread_analysis_data.dart'
    as bad;
import '../types/mixing_aliases.dart';
import '../types/unified_types.dart' as unified;

/// 믹싱 분석 타입 검증 시스템
/// 모든 믹싱 관련 데이터의 타입 안전성을 보장

class MixingTypeValidator {
  // 메인 검증 엔트리 포인트
  static ValidationResult validateMixingData(dynamic data, String context) {
    if (data == null) {
      return ValidationResult.error('$context: 데이터가 null입니다');
    }

    // 타입별 검증
    if (data is unified.BreadMixingAnalysisData) {
      return _validateUnifiedBreadMixingAnalysisData(data, context);
    } else if (data is bma.MixingAnalysisData) {
      return _validateLegacyMixingAnalysisData(data, context);
    } else if (data is bad.MixingAnalysisData) {
      return _validateBreadAnalysisMixingData(data, context);
    } else if (data is MixingProfileData) {
      return _validateMixingProfileData(data, context);
    } else if (data is MixingStepData) {
      return _validateMixingStepData(data, context);
    } else if (data is Map<String, dynamic>) {
      return _validateMapData(data, context);
    } else {
      return ValidationResult.error(
          '$context: 지원되지 않는 타입 - ${data.runtimeType}');
    }
  }

  // Unified BreadMixingAnalysisData 검증
  static ValidationResult _validateUnifiedBreadMixingAnalysisData(
    unified.BreadMixingAnalysisData data,
    String context,
  ) {
    final issues = <String>[];

    // 필드 검증
    if (data.glutenFormationIndex.isNaN ||
        data.glutenFormationIndex.isInfinite) {
      issues.add('글루텐 형성 지수가 유효하지 않음');
    }

    if (data.optimalMixingTime < 0 || data.optimalMixingTime > 60) {
      issues.add('최적 믹싱 시간이 범위를 벗어남');
    }

    if (data.successProbability.isNaN ||
        data.successProbability.isInfinite ||
        data.successProbability < 0 ||
        data.successProbability > 1) {
      issues.add('성공 확률이 유효하지 않음');
    }

    // moistureAbsorptionRate 범위 검증
    if (data.moistureAbsorptionRate < 0 || data.moistureAbsorptionRate > 1) {
      issues.add('수분 흡수율이 범위를 벗어남');
    }

    return issues.isEmpty
        ? ValidationResult.success()
        : ValidationResult.error('$context 검증 실패: ${issues.join(", ")}');
  }

  // Legacy MixingAnalysisData 검증
  static ValidationResult _validateLegacyMixingAnalysisData(
    bma.MixingAnalysisData data,
    String context,
  ) {
    final issues = <String>[];

    if (data.optimizedMixingTime < 0 || data.optimizedMixingTime > 60) {
      issues.add('최적화 믹싱 시간이 범위를 벗어남');
    }

    if (data.successProbability < 0 || data.successProbability > 100) {
      issues.add('성공 확률이 범위를 벗어남');
    }

    if (data.doughType.isEmpty) {
      issues.add('반죽 타입이 비어있음');
    }

    // glutenFormationIndex 범위 검증
    if (data.glutenFormationIndex < 0 || data.glutenFormationIndex > 1) {
      issues.add('글루텐 형성 지수가 범위를 벗어남');
    }

    return issues.isEmpty
        ? ValidationResult.success()
        : ValidationResult.error('$context 검증 실패: ${issues.join(", ")}');
  }

  // Bread Analysis MixingData 검증
  static ValidationResult _validateBreadAnalysisMixingData(
    bad.MixingAnalysisData data,
    String context,
  ) {
    final issues = <String>[];

    if (data.mixingIntensity < 0 || data.mixingIntensity > 1) {
      issues.add('믹싱 강도가 범위를 벗어남');
    }

    // mixingDuration 범위 검증
    if (data.mixingDuration < 1 || data.mixingDuration > 60) {
      issues.add('믹싱 시간이 범위를 벗어남');
    }

    return issues.isEmpty
        ? ValidationResult.success()
        : ValidationResult.error('$context 검증 실패: ${issues.join(", ")}');
  }

  // MixingProfileData 검증
  static ValidationResult _validateMixingProfileData(
    MixingProfileData data,
    String context,
  ) {
    final issues = <String>[];

    if (data.steps.isEmpty) {
      issues.add('믹싱 단계가 비어있음');
    }

    if (data.totalTime < 0) {
      issues.add('총 시간이 음수임');
    }

    if (data.confidence < 0.0 || data.confidence > 1.0) {
      issues.add('신뢰도가 범위를 벗어남');
    }

    // 시간 일관성 검증
    if (!data.isTimeConsistent) {
      issues.add('총 시간과 단계별 시간 합계가 일치하지 않음');
    }

    // 각 단계 검증
    for (int i = 0; i < data.steps.length; i++) {
      final stepResult =
          _validateMixingStepData(data.steps[i], '$context.step${i + 1}');
      if (stepResult.hasError) {
        issues.add('단계 ${i + 1}: ${stepResult.errorMessage}');
      }
    }

    return issues.isEmpty
        ? ValidationResult.success()
        : ValidationResult.error('$context 검증 실패: ${issues.join(", ")}');
  }

  // MixingStepData 검증
  static ValidationResult _validateMixingStepData(
    MixingStepData data,
    String context,
  ) {
    final issues = <String>[];

    if (data.stepNumber < 1 || data.stepNumber > 10) {
      issues.add('단계 번호가 범위를 벗어남');
    }

    if (data.durationMinutes < 1 || data.durationMinutes > 30) {
      issues.add('시간이 범위를 벗어남');
    }

    if (data.speed.isEmpty) {
      issues.add('속도가 비어있음');
    }

    if (data.purpose.isEmpty) {
      issues.add('목적이 비어있음');
    }

    // 속도 유효성 검증
    const validSpeeds = ['저속', '중속', '고속'];
    if (!validSpeeds.contains(data.speed)) {
      issues.add('유효하지 않은 속도: ${data.speed}');
    }

    return issues.isEmpty
        ? ValidationResult.success()
        : ValidationResult.error('$context 검증 실패: ${issues.join(", ")}');
  }

  // Map 데이터 검증
  static ValidationResult _validateMapData(
    Map<String, dynamic> data,
    String context,
  ) {
    final requiredKeys = ['speedProfile', 'successProbability'];
    final missingKeys = requiredKeys.where((key) => !data.containsKey(key));

    if (missingKeys.isNotEmpty) {
      return ValidationResult.error(
          '$context: 필수 키 누락 - ${missingKeys.join(", ")}');
    }

    // successProbability 범위 검증
    final successProb = data['successProbability'];
    if (successProb is num && (successProb < 0 || successProb > 1)) {
      return ValidationResult.error('$context: 성공 확률이 범위를 벗어남');
    }

    // speedProfile 구조 검증
    final speedProfile = data['speedProfile'];
    if (speedProfile is! Map<String, dynamic>) {
      return ValidationResult.error('$context: speedProfile이 올바른 형식이 아님');
    }

    return ValidationResult.success();
  }

  // 프로세스 시퀀스 검증
  static ValidationResult validateProcessSequence(
      List<MixingStepData> processes) {
    if (processes.isEmpty) {
      return ValidationResult.success();
    }

    final issues = <String>[];

    // 속도 전환 검증 (일반적으로 저속 → 중속 → 고속 순서)
    for (int i = 1; i < processes.length; i++) {
      final currentSpeed = processes[i].speed;
      final previousSpeed = processes[i - 1].speed;

      // 고속에서 저속으로 돌아가는 것은 비정상
      if (previousSpeed == '고속' && currentSpeed == '저속') {
        issues
            .add('프로세스 ${i + 1}: ${previousSpeed} → ${currentSpeed} 전환은 비정상적');
      }

      // 저속에서 고속으로 바로 뛰는 것은 경고
      if (previousSpeed == '저속' &&
          currentSpeed == '고속' &&
          processes.length > 2) {
        issues.add(
            '프로세스 ${i + 1}: ${previousSpeed} → ${currentSpeed} 전환은 중간 단계 필요');
      }
    }

    // 시간 합리성 검증
    final totalTime =
        processes.fold(0, (sum, process) => sum + process.durationMinutes);
    if (totalTime < 3) {
      issues.add('총 믹싱 시간이 너무 짧음 (${totalTime}분)');
    } else if (totalTime > 45) {
      issues.add('총 믹싱 시간이 너무 김 (${totalTime}분)');
    }

    return issues.isEmpty
        ? ValidationResult.success()
        : ValidationResult.error('프로세스 시퀀스 검증 실패: ${issues.join(", ")}');
  }

  // 데이터 변환 검증
  static ValidationResult validateDataConversion(
    dynamic inputData,
    dynamic outputData,
    String conversionType,
  ) {
    final issues = <String>[];

    // 입력 데이터 검증
    final inputValidation = validateMixingData(inputData, '입력 데이터');
    if (inputValidation.hasError) {
      issues.add('입력 데이터 검증 실패: ${inputValidation.errorMessage}');
    }

    // 출력 데이터 검증
    final outputValidation = validateMixingData(outputData, '출력 데이터');
    if (outputValidation.hasError) {
      issues.add('출력 데이터 검증 실패: ${outputValidation.errorMessage}');
    }

    // 변환 일관성 검증
    if (inputData is MixingProfileData && outputData is MixingProfileData) {
      if (inputData.totalTime != outputData.totalTime) {
        issues.add('총 시간이 변환 후 변경됨');
      }
    }

    return issues.isEmpty
        ? ValidationResult.success()
        : ValidationResult.error(
            '$conversionType 변환 검증 실패: ${issues.join(", ")}');
  }
}

// 타입 안전한 변환 어댑터
class MixingTypeAdapter {
  // 메인 변환 엔트리 포인트
  static ConversionResult<MixingProfileData> convertToProfileData(
    dynamic inputData, {
    TimeDataSource source = TimeDataSource.calculated,
    double confidence = 1.0,
  }) {
    try {
      final inputType = _identifyInputType(inputData);

      switch (inputType) {
        case 'BreadMixingAnalysisData':
          return ConversionResult.success(
              _convertFromUnifiedBreadMixingAnalysis(
                  inputData as unified.BreadMixingAnalysisData));

        case 'LegacyMixingAnalysisData':
          return ConversionResult.success(_convertFromLegacyMixingAnalysis(
              inputData as bma.MixingAnalysisData));

        case 'BreadAnalysisMixingData':
          return ConversionResult.success(_convertFromBreadAnalysisMixing(
              inputData as bad.MixingAnalysisData));

        case 'MixingProfileData':
          return ConversionResult.success(inputData as MixingProfileData);

        case 'Map':
          return ConversionResult.success(_convertFromMap(
              inputData as Map<String, dynamic>, source, confidence));

        default:
          return ConversionResult.error('지원되지 않는 입력 타입: $inputType');
      }
    } catch (e) {
      return ConversionResult.error('변환 중 오류 발생: $e');
    }
  }

  // 입력 타입 식별
  static String _identifyInputType(dynamic data) {
    if (data is unified.BreadMixingAnalysisData)
      return 'BreadMixingAnalysisData';
    if (data is bma.MixingAnalysisData) return 'LegacyMixingAnalysisData';
    if (data is bad.MixingAnalysisData) return 'BreadAnalysisMixingData';
    if (data is MixingProfileData) return 'MixingProfileData';
    if (data is Map<String, dynamic>) return 'Map';
    return 'Unknown';
  }

  // Unified BreadMixingAnalysisData 변환
  static MixingProfileData _convertFromUnifiedBreadMixingAnalysis(
    unified.BreadMixingAnalysisData data,
  ) {
    final speedProfile = data.speedProfile;
    final steps = <MixingStepData>[];
    int totalTime = 0;

    if (speedProfile.containsKey('stages') && speedProfile['stages'] is List) {
      final stagesData = speedProfile['stages'] as List;

      for (int i = 0; i < stagesData.length; i++) {
        final stageData = stagesData[i] as Map<String, dynamic>;
        final step = MixingStepData.fromCalculatedData(stageData, i);
        steps.add(step);
        totalTime += step.durationMinutes;
      }
    }

    return MixingProfileData(
      steps: steps,
      totalTime: totalTime,
      primarySource: TimeDataSource.calculated,
      confidence: 0.8,
    );
  }

  // Legacy MixingAnalysisData 변환
  static MixingProfileData _convertFromLegacyMixingAnalysis(
    bma.MixingAnalysisData data,
  ) {
    final speedProfile = data.speedProfile;
    final steps = <MixingStepData>[];
    int totalTime = 0;

    // 속도 프로파일 구조에 따라 변환
    if (speedProfile.containsKey('speedProgression')) {
      final speeds = speedProfile['speedProgression'] as List<dynamic>;
      final timePerSegment =
          (speedProfile['timePerSegment'] as num?)?.toInt() ?? 5;

      for (int i = 0; i < speeds.length; i++) {
        final step = MixingStepData(
          stepNumber: i + 1,
          speed: _convertSpeedLevel(speeds[i] as int),
          durationMinutes: timePerSegment,
          purpose: _getPurposeForSpeed(_convertSpeedLevel(speeds[i] as int)),
          source: TimeDataSource.calculated,
        );
        steps.add(step);
        totalTime += step.durationMinutes;
      }
    }

    return MixingProfileData(
      steps: steps,
      totalTime: totalTime,
      primarySource: TimeDataSource.calculated,
      confidence: 0.75,
    );
  }

  // Bread Analysis MixingData 변환
  static MixingProfileData _convertFromBreadAnalysisMixing(
    bad.MixingAnalysisData data,
  ) {
    // 기본 단계 생성
    final steps = <MixingStepData>[
      MixingStepData(
        stepNumber: 1,
        speed: '중속',
        durationMinutes: data.mixingDuration,
        purpose: '기본 믹싱',
        source: TimeDataSource.calculated,
      ),
    ];

    return MixingProfileData(
      steps: steps,
      totalTime: data.mixingDuration,
      primarySource: TimeDataSource.calculated,
      confidence: 0.6,
    );
  }

  // Map 데이터 변환
  static MixingProfileData _convertFromMap(
    Map<String, dynamic> data,
    TimeDataSource source,
    double confidence,
  ) {
    final steps = <MixingStepData>[];
    int totalTime = 0;

    // processes 키에서 변환 시도
    if (data.containsKey('processes') && data['processes'] is List) {
      final processes = data['processes'] as List;
      for (int i = 0; i < processes.length; i++) {
        final process = processes[i] as Map<String, dynamic>;
        final step = MixingStepData.fromParsedData(process, i);
        steps.add(step);
        totalTime += step.durationMinutes;
      }
    }
    // stages 키에서 변환 시도
    else if (data.containsKey('stages') && data['stages'] is List) {
      final stages = data['stages'] as List;
      for (int i = 0; i < stages.length; i++) {
        final stage = stages[i] as Map<String, dynamic>;
        final step = MixingStepData.fromCalculatedData(stage, i);
        steps.add(step);
        totalTime += step.durationMinutes;
      }
    }

    return MixingProfileData(
      steps: steps,
      totalTime: totalTime,
      primarySource: source,
      confidence: confidence,
    );
  }

  // 속도 레벨 변환
  static String _convertSpeedLevel(int speedLevel) {
    switch (speedLevel) {
      case 1:
        return '저속';
      case 2:
        return '중속';
      case 3:
        return '고속';
      default:
        return '중속';
    }
  }

  // 속도별 목적 추론
  static String _getPurposeForSpeed(String speed) {
    switch (speed) {
      case '저속':
        return '글루텐 형성 초기';
      case '중속':
        return '글루텐 네트워크 강화';
      case '고속':
        return '최종 혼합 및 가스 함입';
      default:
        return '믹싱 단계';
    }
  }
}

// 안전한 계산 결과 헬퍼
class CalculationGuard {
  static GuardedResult<MixingProfileData> guardCalculation(
    CalculationResult<MixingProfileData> calculation,
    String guardId,
  ) {
    if (calculation.isSuccessful && calculation.data != null) {
      // 계산 성공 - 검증 수행
      final validation =
          MixingTypeValidator.validateMixingData(calculation.data!, guardId);

      if (validation.isValid) {
        return GuardedResult.success(calculation.data!, guardId: guardId);
      } else {
        return GuardedResult.fallback(
          MixingProfileData.defaultProfile(),
          reason: '계산 결과 검증 실패: ${validation.errorMessage}',
          guardId: guardId,
        );
      }
    } else {
      // 계산 실패 - 기본값 반환
      return GuardedResult.fallback(
        MixingProfileData.defaultProfile(),
        reason: '계산 실패: ${calculation.errorMessage}',
        guardId: guardId,
      );
    }
  }

  static GuardedResult<MixingProfileData> guardDataExtraction(
    ExtractionResult<MixingProfileData> extraction,
    String guardId,
  ) {
    if (extraction.isSuccessful && extraction.data != null) {
      // 추출 성공 - 검증 수행
      final validation =
          MixingTypeValidator.validateMixingData(extraction.data!, guardId);

      if (validation.isValid) {
        return GuardedResult.success(extraction.data!, guardId: guardId);
      } else {
        return GuardedResult.fallback(
          MixingProfileData.defaultProfile(),
          reason: '추출 결과 검증 실패: ${validation.errorMessage}',
          guardId: guardId,
        );
      }
    } else {
      // 추출 실패 - 기본값 반환
      return GuardedResult.fallback(
        MixingProfileData.defaultProfile(),
        reason: '추출 실패: ${extraction.errorMessage}',
        guardId: guardId,
      );
    }
  }
}
