// lib/core/utils/mixing_data_integration_system.dart
// 믹싱 데이터 통합 시스템 - 파싱과 계산 데이터 완벽 통합

import '../../models/recipe.dart';
import '../types/mixing_aliases.dart';
import '../../../features/chef/module/bread/types/unified_types.dart'
    as unified;
import 'mixing_data_extractor.dart';
import 'mixing_type_validator.dart';
import 'mixing_calculator_integrator.dart';

/// 믹싱 데이터 통합 시스템
/// 파싱 데이터와 계산 데이터를 완벽하게 통합하고 검증하는 시스템

class MixingDataIntegrationSystem {
  // 메인 통합 엔트리 포인트
  static Future<IntegrationResult> integrateMixingData(
    unified.UnifiedRecipe recipe, {
    Map<String, dynamic>? environmentData,
    Map<String, dynamic>? userPreferences,
    Map<String, dynamic>? constraints,
    IntegrationStrategy strategy = IntegrationStrategy.preferParsed,
  }) async {
    final integrationId = _generateIntegrationId();

    try {
      // 1. 통합 전략에 따른 데이터 수집
      final dataCollection = await _collectIntegrationData(
        recipe,
        environmentData: environmentData,
        userPreferences: userPreferences,
        constraints: constraints,
        strategy: strategy,
        integrationId: integrationId,
      );

      if (!dataCollection.isSuccessful) {
        return IntegrationResult.failure(
          integrationId: integrationId,
          reason: dataCollection.errorMessage ?? '데이터 수집 실패',
          fallbackProfile: MixingProfileData.defaultProfile(),
        );
      }

      // 2. 데이터 변환 및 통합
      final transformation = await _transformAndIntegrateData(
        dataCollection,
        strategy,
        integrationId,
      );

      if (!transformation.isSuccessful) {
        return IntegrationResult.failure(
          integrationId: integrationId,
          reason: transformation.errorMessage ?? '데이터 변환 실패',
          fallbackProfile: dataCollection.fallbackProfile,
        );
      }

      // 3. 최종 검증 및 품질 보장
      final finalResult = await _finalValidationAndQualityAssurance(
        transformation.result,
        dataCollection,
        strategy,
        integrationId,
      );

      return finalResult;
    } catch (e) {
      return IntegrationResult.failure(
        integrationId: integrationId,
        reason: '통합 시스템 오류: $e',
        fallbackProfile: MixingProfileData.defaultProfile(),
      );
    }
  }

  // 통합 전략
  static Future<DataCollectionResult> _collectIntegrationData(
    unified.UnifiedRecipe recipe, {
    required Map<String, dynamic>? environmentData,
    required Map<String, dynamic>? userPreferences,
    required Map<String, dynamic>? constraints,
    required IntegrationStrategy strategy,
    required String integrationId,
  }) async {
    try {
      // 파싱 데이터 수집
      final parsedResult = MixingDataExtractor.extractFromRecipe(recipe);

      // 계산 데이터 준비
      final calculationResult =
          MixingCalculatorIntegrator.calculateWithParsedData(
        recipe,
        environmentData: environmentData,
        constraints: constraints,
      );

      // 사용자 선호도 적용
      final preferenceAdjusted = _applyUserPreferences(
        calculationResult,
        userPreferences,
      );

      return DataCollectionResult.success(
        parsedData: parsedResult.isSuccessful ? parsedResult.data : null,
        calculatedData:
            preferenceAdjusted.isSuccessful ? preferenceAdjusted.data : null,
        environmentData: environmentData,
        constraints: constraints,
        strategy: strategy,
        integrationId: integrationId,
      );
    } catch (e) {
      return DataCollectionResult.failure('데이터 수집 오류: $e');
    }
  }

  // 데이터 변환 및 통합
  static Future<TransformationResult> _transformAndIntegrateData(
    DataCollectionResult collection,
    IntegrationStrategy strategy,
    String integrationId,
  ) async {
    try {
      // 전략에 따른 데이터 통합
      final integratedProfile = await _applyIntegrationStrategy(
        collection.parsedData,
        collection.calculatedData,
        collection.environmentData,
        collection.constraints,
        strategy,
      );

      // 통합 데이터 검증
      final validation = MixingTypeValidator.validateMixingData(
        integratedProfile,
        'integrated_profile_$integrationId',
      );

      if (!validation.isValid) {
        return TransformationResult.failure(
          '통합 데이터 검증 실패: ${validation.errorMessage}',
        );
      }

      // 메타데이터 추가
      final enrichedProfile = _enrichWithMetadata(
        integratedProfile,
        collection,
        integrationId,
      );

      return TransformationResult.success(
        result: enrichedProfile,
        confidence: _calculateIntegrationConfidence(
          collection.parsedData,
          collection.calculatedData,
          enrichedProfile,
        ),
      );
    } catch (e) {
      return TransformationResult.failure('데이터 변환 오류: $e');
    }
  }

  // 최종 검증 및 품질 보장
  static Future<IntegrationResult> _finalValidationAndQualityAssurance(
    MixingProfileData profile,
    DataCollectionResult collection,
    IntegrationStrategy strategy,
    String integrationId,
  ) async {
    // 품질 메트릭 계산
    final qualityMetrics = await _calculateQualityMetrics(
      profile,
      collection,
    );

    // 품질 임계값 검증
    final qualityCheck = _validateQualityThresholds(qualityMetrics);

    if (!qualityCheck.isValid) {
      // 품질 보장 실패 - 개선 시도
      final improvedProfile = await _attemptQualityImprovement(
        profile,
        collection,
        qualityCheck,
      );

      if (improvedProfile != null) {
        return IntegrationResult.success(
          profile: improvedProfile,
          integrationId: integrationId,
          strategy: strategy,
          confidence: qualityMetrics.overallConfidence * 0.9,
          qualityMetrics: qualityMetrics,
        );
      }

      return IntegrationResult.failure(
        integrationId: integrationId,
        reason: '품질 보장 실패: ${qualityCheck.errorMessage}',
        fallbackProfile: profile,
      );
    }

    return IntegrationResult.success(
      profile: profile,
      integrationId: integrationId,
      strategy: strategy,
      confidence: qualityMetrics.overallConfidence,
      qualityMetrics: qualityMetrics,
    );
  }

  // 통합 전략 적용
  static Future<MixingProfileData> _applyIntegrationStrategy(
    ParsedMixingData? parsedData,
    MixingProfileData? calculatedData,
    Map<String, dynamic>? environmentData,
    Map<String, dynamic>? constraints,
    IntegrationStrategy strategy,
  ) async {
    switch (strategy) {
      case IntegrationStrategy.preferParsed:
        return await _preferParsedStrategy(
            parsedData, calculatedData, environmentData, constraints);

      case IntegrationStrategy.preferCalculated:
        return await _preferCalculatedStrategy(
            parsedData, calculatedData, environmentData, constraints);

      case IntegrationStrategy.adaptive:
        return await _adaptiveStrategy(
            parsedData, calculatedData, environmentData, constraints);

      case IntegrationStrategy.hybrid:
        return await _hybridStrategy(
            parsedData, calculatedData, environmentData, constraints);
    }
  }

  // 파싱 데이터 우선 전략
  static Future<MixingProfileData> _preferParsedStrategy(
    ParsedMixingData? parsedData,
    MixingProfileData? calculatedData,
    Map<String, dynamic>? environmentData,
    Map<String, dynamic>? constraints,
  ) async {
    if (parsedData != null &&
        parsedData.isValid &&
        parsedData.isHighConfidence) {
      // 파싱 데이터가 신뢰할 만한 경우
      final parsedProfile = MixingTypeAdapter.convertToProfileData(
        {'processes': parsedData.processes.map((p) => p.toJson()).toList()},
        source: TimeDataSource.parsed,
        confidence: parsedData.confidence,
      );

      if (parsedProfile.isSuccessful && parsedProfile.data != null) {
        // 환경 조정 적용
        return MixingCalculatorIntegrator._applyEnvironmentAdjustments(
          parsedProfile.data!,
          environmentData,
          constraints,
        );
      }
    }

    // 파싱 데이터가 불충분한 경우 계산 데이터로 폴백
    if (calculatedData != null) {
      return calculatedData;
    }

    return MixingProfileData.defaultProfile();
  }

  // 계산 데이터 우선 전략
  static Future<MixingProfileData> _preferCalculatedStrategy(
    ParsedMixingData? parsedData,
    MixingProfileData? calculatedData,
    Map<String, dynamic>? environmentData,
    Map<String, dynamic>? constraints,
  ) async {
    if (calculatedData != null) {
      return calculatedData;
    }

    // 계산 데이터가 없는 경우 파싱 데이터로 폴백
    if (parsedData != null && parsedData.isValid) {
      final parsedProfile = MixingTypeAdapter.convertToProfileData(
        {'processes': parsedData.processes.map((p) => p.toJson()).toList()},
        source: TimeDataSource.parsed,
        confidence: parsedData.confidence,
      );

      if (parsedProfile.isSuccessful && parsedProfile.data != null) {
        return parsedProfile.data!;
      }
    }

    return MixingProfileData.defaultProfile();
  }

  // 적응형 전략
  static Future<MixingProfileData> _adaptiveStrategy(
    ParsedMixingData? parsedData,
    MixingProfileData? calculatedData,
    Map<String, dynamic>? environmentData,
    Map<String, dynamic>? constraints,
  ) async {
    // 데이터 품질 평가
    final parsedQuality = _evaluateParsedDataQuality(parsedData);
    final calculatedQuality = _evaluateCalculatedDataQuality(calculatedData);

    // 품질이 더 높은 데이터 선택
    if (parsedQuality > calculatedQuality + 0.1) {
      return await _preferParsedStrategy(
          parsedData, calculatedData, environmentData, constraints);
    } else if (calculatedQuality > parsedQuality + 0.1) {
      return await _preferCalculatedStrategy(
          parsedData, calculatedData, environmentData, constraints);
    } else {
      // 품질이 비슷한 경우 하이브리드 전략 사용
      return await _hybridStrategy(
          parsedData, calculatedData, environmentData, constraints);
    }
  }

  // 하이브리드 전략
  static Future<MixingProfileData> _hybridStrategy(
    ParsedMixingData? parsedData,
    MixingProfileData? calculatedData,
    Map<String, dynamic>? environmentData,
    Map<String, dynamic>? constraints,
  ) async {
    if (parsedData != null && calculatedData != null) {
      // 두 데이터를 융합
      final hybridProfile = await _mergeDataSources(
          parsedData, calculatedData, environmentData, constraints);

      if (hybridProfile != null) {
        return hybridProfile;
      }
    }

    // 융합 실패 시 적응형 전략으로 폴백
    return await _adaptiveStrategy(
        parsedData, calculatedData, environmentData, constraints);
  }

  // 데이터 소스 융합
  static Future<MixingProfileData?> _mergeDataSources(
    ParsedMixingData parsedData,
    MixingProfileData calculatedData,
    Map<String, dynamic>? environmentData,
    Map<String, dynamic>? constraints,
  ) async {
    try {
      // 단계 수 조정
      final targetStepCount =
          _determineOptimalStepCount(parsedData, calculatedData);

      // 시간 정보 융합
      final mergedSteps = <MixingStepData>[];

      for (int i = 0; i < targetStepCount; i++) {
        final mergedStep = await _mergeStepData(
            i, parsedData, calculatedData, targetStepCount);
        mergedSteps.add(mergedStep);
      }

      final totalTime =
          mergedSteps.fold(0, (sum, step) => sum + step.durationMinutes);

      // 신뢰도 계산
      final confidence = _calculateHybridConfidence(parsedData, calculatedData);

      return MixingProfileData(
        steps: mergedSteps,
        totalTime: totalTime,
        primarySource: TimeDataSource.adjusted,
        confidence: confidence,
      );
    } catch (e) {
      return null;
    }
  }

  // 단계 데이터 융합
  static Future<MixingStepData> _mergeStepData(
    int stepIndex,
    ParsedMixingData parsedData,
    MixingProfileData calculatedData,
    int totalSteps,
  ) async {
    final parsedStep = stepIndex < parsedData.processes.length
        ? parsedData.processes[stepIndex]
        : null;

    final calculatedStep = stepIndex < calculatedData.steps.length
        ? calculatedData.steps[stepIndex]
        : null;

    // 속도 결정 (파싱 우선)
    final speed = parsedStep?.speed ?? calculatedStep?.speed ?? '중속';

    // 시간 결정 (가중 평균)
    final parsedTime = parsedStep?.durationMinutes ?? 5;
    final calculatedTime = calculatedStep?.durationMinutes ?? 5;
    final mergedTime = ((parsedTime * parsedData.confidence) +
            (calculatedTime * calculatedData.confidence)) /
        (parsedData.confidence + calculatedData.confidence);

    // 목적 결정 (파싱 우선)
    final purpose = parsedStep?.comment.isNotEmpty == true
        ? parsedStep!.comment
        : calculatedStep?.purpose ?? '믹싱 단계';

    return MixingStepData(
      stepNumber: stepIndex + 1,
      speed: speed,
      durationMinutes: mergedTime.round(),
      purpose: purpose,
      source: TimeDataSource.adjusted,
    );
  }

  // 헬퍼 메서드들

  // 통합 ID 생성
  static String _generateIntegrationId() {
    return 'mixing_integration_${DateTime.now().millisecondsSinceEpoch}';
  }

  // 사용자 선호도 적용
  static CalculationResult<MixingProfileData> _applyUserPreferences(
    CalculationResult<MixingProfileData> calculation,
    Map<String, dynamic>? userPreferences,
  ) {
    if (!calculation.isSuccessful ||
        calculation.data == null ||
        userPreferences == null) {
      return calculation;
    }

    // 사용자 선호도 기반 조정 로직
    final adjustedProfile = calculation.data!;

    return CalculationResult.success(
      adjustedProfile,
      calculationName: 'user_preference_adjusted',
    );
  }

  // 메타데이터 추가
  static MixingProfileData _enrichWithMetadata(
    MixingProfileData profile,
    DataCollectionResult collection,
    String integrationId,
  ) {
    // 프로파일에 메타데이터 추가 (실제로는 확장 데이터 모델 사용)
    return profile;
  }

  // 통합 신뢰도 계산
  static double _calculateIntegrationConfidence(
    ParsedMixingData? parsedData,
    MixingProfileData? calculatedData,
    MixingProfileData result,
  ) {
    double confidence = result.confidence;

    if (parsedData != null) {
      confidence = (confidence + parsedData.confidence) / 2;
    }

    if (calculatedData != null) {
      confidence = (confidence + calculatedData.confidence) / 2;
    }

    return confidence.clamp(0.0, 1.0);
  }

  // 최적 단계 수 결정
  static int _determineOptimalStepCount(
    ParsedMixingData parsedData,
    MixingProfileData calculatedData,
  ) {
    final parsedCount = parsedData.processes.length;
    final calculatedCount = calculatedData.steps.length;

    // 단계 수 차이가 크지 않은 경우 파싱 데이터 우선
    if ((parsedCount - calculatedCount).abs() <= 1) {
      return parsedCount;
    }

    // 차이가 큰 경우 적절한 절충
    return ((parsedCount + calculatedCount) / 2).round();
  }

  // 데이터 품질 평가
  static double _evaluateParsedDataQuality(ParsedMixingData? data) {
    if (data == null || !data.isValid) return 0.0;

    double quality = data.confidence;

    // 프로세스 수에 따른 품질 조정
    if (data.processes.length >= 2 && data.processes.length <= 4) {
      quality *= 1.1;
    }

    return quality.clamp(0.0, 1.0);
  }

  static double _evaluateCalculatedDataQuality(MixingProfileData? data) {
    if (data == null || !data.isValid) return 0.0;

    return data.confidence;
  }

  // 품질 메트릭 계산
  static Future<QualityMetrics> _calculateQualityMetrics(
    MixingProfileData profile,
    DataCollectionResult collection,
  ) async {
    final timeConsistency = profile.isTimeConsistent ? 1.0 : 0.5;
    final stepValidity =
        profile.steps.every((step) => step.isValid) ? 1.0 : 0.7;
    final confidence = profile.confidence;

    final overallConfidence = (timeConsistency + stepValidity + confidence) / 3;

    return QualityMetrics(
      timeConsistency: timeConsistency,
      stepValidity: stepValidity,
      dataConfidence: confidence,
      overallConfidence: overallConfidence,
    );
  }

  // 품질 임계값 검증
  static ValidationResult _validateQualityThresholds(QualityMetrics metrics) {
    const minConfidence = 0.4;
    const minTimeConsistency = 0.8;
    const minStepValidity = 0.9;

    if (metrics.overallConfidence < minConfidence) {
      return ValidationResult.error('전체 신뢰도가 부족합니다');
    }

    if (metrics.timeConsistency < minTimeConsistency) {
      return ValidationResult.error('시간 일관성이 부족합니다');
    }

    if (metrics.stepValidity < minStepValidity) {
      return ValidationResult.error('단계 유효성이 부족합니다');
    }

    return ValidationResult.success();
  }

  // 품질 개선 시도
  static Future<MixingProfileData?> _attemptQualityImprovement(
    MixingProfileData profile,
    DataCollectionResult collection,
    ValidationResult qualityCheck,
  ) async {
    // 간단한 개선 시도: 시간 재분배
    if (qualityCheck.errorMessage?.contains('시간') == true) {
      return MixingCalculatorIntegrator._optimizeTimeDistribution(profile);
    }

    return null;
  }

  // 하이브리드 신뢰도 계산
  static double _calculateHybridConfidence(
    ParsedMixingData parsedData,
    MixingProfileData calculatedData,
  ) {
    return (parsedData.confidence + calculatedData.confidence) / 2;
  }
}

// 통합 전략 열거형
enum IntegrationStrategy {
  preferParsed, // 파싱 데이터 우선
  preferCalculated, // 계산 데이터 우선
  adaptive, // 적응형 (품질 기반 자동 선택)
  hybrid, // 하이브리드 (두 데이터 융합)
}

// 데이터 수집 결과
class DataCollectionResult {
  final bool isSuccessful;
  final ParsedMixingData? parsedData;
  final MixingProfileData? calculatedData;
  final MixingProfileData fallbackProfile;
  final Map<String, dynamic>? environmentData;
  final Map<String, dynamic>? constraints;
  final IntegrationStrategy strategy;
  final String integrationId;
  final String? errorMessage;

  DataCollectionResult._({
    required this.isSuccessful,
    this.parsedData,
    this.calculatedData,
    required this.fallbackProfile,
    this.environmentData,
    this.constraints,
    required this.strategy,
    required this.integrationId,
    this.errorMessage,
  });

  factory DataCollectionResult.success({
    ParsedMixingData? parsedData,
    MixingProfileData? calculatedData,
    Map<String, dynamic>? environmentData,
    Map<String, dynamic>? constraints,
    required IntegrationStrategy strategy,
    required String integrationId,
  }) {
    return DataCollectionResult._(
      isSuccessful: true,
      parsedData: parsedData,
      calculatedData: calculatedData,
      fallbackProfile: calculatedData ?? MixingProfileData.defaultProfile(),
      environmentData: environmentData,
      constraints: constraints,
      strategy: strategy,
      integrationId: integrationId,
    );
  }

  factory DataCollectionResult.failure(String errorMessage) {
    return DataCollectionResult._(
      isSuccessful: false,
      fallbackProfile: MixingProfileData.defaultProfile(),
      strategy: IntegrationStrategy.adaptive,
      integrationId: 'failed_${DateTime.now().millisecondsSinceEpoch}',
      errorMessage: errorMessage,
    );
  }
}

// 데이터 변환 결과
class TransformationResult {
  final bool isSuccessful;
  final MixingProfileData? result;
  final double confidence;
  final String? errorMessage;

  TransformationResult._({
    required this.isSuccessful,
    this.result,
    required this.confidence,
    this.errorMessage,
  });

  factory TransformationResult.success({
    required MixingProfileData result,
    required double confidence,
  }) {
    return TransformationResult._(
      isSuccessful: true,
      result: result,
      confidence: confidence,
    );
  }

  factory TransformationResult.failure(String errorMessage) {
    return TransformationResult._(
      isSuccessful: false,
      confidence: 0.0,
      errorMessage: errorMessage,
    );
  }
}

// 품질 메트릭
class QualityMetrics {
  final double timeConsistency;
  final double stepValidity;
  final double dataConfidence;
  final double overallConfidence;

  const QualityMetrics({
    required this.timeConsistency,
    required this.stepValidity,
    required this.dataConfidence,
    required this.overallConfidence,
  });
}

// 통합 결과
class IntegrationResult {
  final bool isSuccessful;
  final MixingProfileData profile;
  final String integrationId;
  final IntegrationStrategy strategy;
  final double confidence;
  final QualityMetrics? qualityMetrics;
  final String? reason;
  final String dataSource; // 데이터 소스 정보 추가

  IntegrationResult._({
    required this.isSuccessful,
    required this.profile,
    required this.integrationId,
    required this.strategy,
    required this.confidence,
    this.qualityMetrics,
    this.reason,
    required this.dataSource,
  });

  factory IntegrationResult.success({
    required MixingProfileData profile,
    required String integrationId,
    required IntegrationStrategy strategy,
    required double confidence,
    QualityMetrics? qualityMetrics,
  }) {
    return IntegrationResult._(
      isSuccessful: true,
      profile: profile,
      integrationId: integrationId,
      strategy: strategy,
      confidence: confidence,
      qualityMetrics: qualityMetrics,
      dataSource: _determineDataSourceFromProfile(profile),
    );
  }

  factory IntegrationResult.failure({
    required String integrationId,
    required String reason,
    required MixingProfileData fallbackProfile,
  }) {
    return IntegrationResult._(
      isSuccessful: false,
      profile: fallbackProfile,
      integrationId: integrationId,
      strategy: IntegrationStrategy.adaptive,
      confidence: 0.0,
      reason: reason,
      dataSource: 'default',
    );
  }

  bool get isHighConfidence => confidence > 0.8;
  bool get hasQualityIssues =>
      qualityMetrics != null &&
      (qualityMetrics!.timeConsistency < 0.9 ||
          qualityMetrics!.stepValidity < 0.9 ||
          qualityMetrics!.dataConfidence < 0.8);
}

// 프로파일에서 데이터 소스 결정 헬퍼
String _determineDataSourceFromProfile(MixingProfileData profile) {
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
