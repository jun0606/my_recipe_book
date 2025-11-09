// lib/core/types/mixing_aliases.dart
// 믹싱 분석 타입 별칭 및 안전한 타입 시스템

import '../../../features/chef/module/bread/services/bread_mixing_analyzer.dart'
    as bma;
import '../../../features/chef/module/bread/models/bread_analysis_data.dart'
    as bad;
import 'unified_types.dart' as unified;

/// 믹싱 분석 관련 타입 별칭들
/// 동일 클래스명 충돌을 방지하고 타입 안전성을 보장

// 기본 타입 별칭
typedef MixingSpeedProfile = Map<String, dynamic>;
typedef MixingTimeData = Map<String, dynamic>;
typedef MixingAnalysisResult = Map<String, dynamic>;
typedef CalculatedMixingData = Map<String, dynamic>;

// 분석기별 타입 별칭 (충돌 방지)
typedef UnifiedBreadMixingAnalysis = unified.BreadMixingAnalysisData;
typedef LegacyMixingAnalysis = bma.MixingAnalysisData;
typedef BreadAnalysisMixingData = bad.MixingAnalysisData;

// 데이터 소스 타입
enum TimeDataSource {
  parsed, // 실제 파싱된 데이터
  calculated, // 계산된 데이터
  adjusted, // 조정된 데이터
  default_, // 기본값
  recommended, // 추천된 데이터
  intelligent, // 지능형 추천 데이터
}

// 검증 결과 타입
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult._(this.isValid, this.errorMessage);

  factory ValidationResult.success() => const ValidationResult._(true, null);
  factory ValidationResult.error(String message) =>
      ValidationResult._(false, message);

  bool get hasError => !isValid;
}

// 변환 결과 타입
class ConversionResult<T> {
  final bool isSuccessful;
  final T? data;
  final String? errorMessage;

  const ConversionResult._(this.isSuccessful, this.data, this.errorMessage);

  factory ConversionResult.success(T data) =>
      ConversionResult._(true, data, null);
  factory ConversionResult.error(String message) =>
      ConversionResult._(false, null, message);

  bool get hasError => !isSuccessful;
}

// 추출 결과 타입
class ExtractionResult<T> {
  final bool isSuccessful;
  final T? data;
  final String? errorMessage;

  const ExtractionResult._(this.isSuccessful, this.data, this.errorMessage);

  factory ExtractionResult.success(T data) =>
      ExtractionResult._(true, data, null);
  factory ExtractionResult.error(String message) =>
      ExtractionResult._(false, null, message);

  bool get hasError => !isSuccessful;
}

// 안전한 계산 결과 타입
class CalculationResult<T> {
  final bool isSuccessful;
  final T? data;
  final String? errorMessage;
  final String calculationName;

  const CalculationResult._(
      this.isSuccessful, this.data, this.errorMessage, this.calculationName);

  factory CalculationResult.success(T data,
          {String calculationName = 'unknown'}) =>
      CalculationResult._(true, data, null, calculationName);

  factory CalculationResult.error(String message,
          {String calculationName = 'unknown'}) =>
      CalculationResult._(false, null, message, calculationName);

  bool get hasError => !isSuccessful;
}

// 안전한 폴백 결과 타입
class GuardedResult<T> {
  final bool isSuccessful;
  final T? data;
  final String? reason;
  final String guardId;

  const GuardedResult._(
      this.isSuccessful, this.data, this.reason, this.guardId);

  factory GuardedResult.success(T data, {String guardId = 'unknown'}) =>
      GuardedResult._(true, data, null, guardId);

  factory GuardedResult.fallback(T data,
          {String? reason, String guardId = 'unknown'}) =>
      GuardedResult._(false, data, reason, guardId);

  bool get hasError => !isSuccessful;
}

// 타입 안전한 믹싱 단계 데이터
class MixingStepData {
  final int stepNumber;
  final String speed;
  final int durationMinutes;
  final String purpose;
  final TimeDataSource source;

  const MixingStepData({
    required this.stepNumber,
    required this.speed,
    required this.durationMinutes,
    required this.purpose,
    this.source = TimeDataSource.calculated,
  });

  // 타입 안전한 팩토리 메서드
  factory MixingStepData.fromParsedData(
    Map<String, dynamic> parsedData,
    int stepIndex,
  ) {
    return MixingStepData(
      stepNumber: stepIndex + 1,
      speed: _validateSpeed(parsedData['speed'] as String? ?? '중속'),
      durationMinutes: _validateDuration(parsedData['duration_minutes']),
      purpose: _inferPurpose(stepIndex + 1, parsedData),
      source: TimeDataSource.parsed,
    );
  }

  factory MixingStepData.fromCalculatedData(
    Map<String, dynamic> calculatedData,
    int stepIndex,
  ) {
    return MixingStepData(
      stepNumber: stepIndex + 1,
      speed: _validateSpeed(calculatedData['speed'] as String? ?? '중속'),
      durationMinutes:
          _validateDuration(calculatedData['duration'] as int? ?? 5),
      purpose: _inferPurpose(stepIndex + 1, calculatedData),
      source: TimeDataSource.calculated,
    );
  }

  // JSON 변환
  Map<String, dynamic> toJson() => {
        'stepNumber': stepNumber,
        'speed': speed,
        'durationMinutes': durationMinutes,
        'purpose': purpose,
        'source': source.name,
      };

  // 검증 메서드들
  bool get isValid =>
      stepNumber > 0 &&
      stepNumber <= 10 &&
      speed.isNotEmpty &&
      durationMinutes > 0 &&
      durationMinutes <= 30 &&
      purpose.isNotEmpty;

  // 속도 검증
  static String _validateSpeed(String speed) {
    const validSpeeds = ['저속', '중속', '고속'];
    return validSpeeds.contains(speed) ? speed : '중속';
  }

  // 시간 검증
  static int _validateDuration(dynamic duration) {
    if (duration is int && duration > 0 && duration <= 30) {
      return duration;
    }
    return 5; // 기본값
  }

  // 목적 추론
  static String _inferPurpose(int stepNumber, Map<String, dynamic> params) {
    // 차수별 기본 목적
    switch (stepNumber) {
      case 1:
        return '글루텐 형성 초기';
      case 2:
        return '글루텐 네트워크 강화';
      case 3:
        return '최종 혼합 및 가스 함입';
      default:
        return '믹싱 단계';
    }
  }
}

// 타입 안전한 믹싱 프로파일 데이터
class MixingProfileData {
  final List<MixingStepData> steps;
  final int totalTime;
  final TimeDataSource primarySource;
  final double confidence;

  const MixingProfileData({
    required this.steps,
    required this.totalTime,
    required this.primarySource,
    required this.confidence,
  });

  // 팩토리 메서드들
  factory MixingProfileData.fromParsedData(Map<String, dynamic> data) {
    final steps = <MixingStepData>[];
    int totalTime = 0;

    if (data.containsKey('processes') && data['processes'] is List) {
      final processes = data['processes'] as List;
      for (int i = 0; i < processes.length; i++) {
        final process = processes[i] as Map<String, dynamic>;
        final step = MixingStepData.fromParsedData(process, i);
        steps.add(step);
        totalTime += step.durationMinutes;
      }
    }

    return MixingProfileData(
      steps: steps,
      totalTime: totalTime,
      primarySource: TimeDataSource.parsed,
      confidence: data['confidence'] as double? ?? 0.9,
    );
  }

  factory MixingProfileData.fromCalculatedData(Map<String, dynamic> data) {
    final steps = <MixingStepData>[];
    int totalTime = 0;

    if (data.containsKey('stages') && data['stages'] is List) {
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
      primarySource: TimeDataSource.calculated,
      confidence: data['confidence'] as double? ?? 0.8,
    );
  }

  // 기본 프로파일 생성
  factory MixingProfileData.defaultProfile() {
    return const MixingProfileData(
      steps: [
        MixingStepData(
          stepNumber: 1,
          speed: '저속',
          durationMinutes: 5,
          purpose: '글루텐 형성 초기',
          source: TimeDataSource.default_,
        ),
        MixingStepData(
          stepNumber: 2,
          speed: '중속',
          durationMinutes: 5,
          purpose: '글루텐 네트워크 강화',
          source: TimeDataSource.default_,
        ),
        MixingStepData(
          stepNumber: 3,
          speed: '고속',
          durationMinutes: 3,
          purpose: '최종 혼합 및 가스 함입',
          source: TimeDataSource.default_,
        ),
      ],
      totalTime: 13,
      primarySource: TimeDataSource.default_,
      confidence: 0.5,
    );
  }

  // JSON 변환
  Map<String, dynamic> toJson() => {
        'steps': steps.map((step) => step.toJson()).toList(),
        'totalTime': totalTime,
        'primarySource': primarySource.name,
        'confidence': confidence,
      };

  // 검증
  bool get isValid =>
      steps.isNotEmpty &&
      totalTime > 0 &&
      confidence >= 0.0 &&
      confidence <= 1.0 &&
      steps.every((step) => step.isValid);

  // 계산된 총 시간과 실제 총 시간 일치 검증
  bool get isTimeConsistent {
    final calculatedTotal =
        steps.fold(0, (sum, step) => sum + step.durationMinutes);
    return calculatedTotal == totalTime;
  }
}

// 타입 안전한 계산 컨텍스트
class CalculationContext {
  final Map<String, dynamic> inputData;
  final Map<String, dynamic> environmentData;
  final Map<String, dynamic> constraints;
  final DateTime calculationTimestamp;
  final String calculationId;

  const CalculationContext({
    required this.inputData,
    required this.environmentData,
    required this.constraints,
    required this.calculationTimestamp,
    required this.calculationId,
  });

  // 검증
  bool get isValid =>
      inputData.isNotEmpty &&
      environmentData.isNotEmpty &&
      constraints.isNotEmpty &&
      calculationId.isNotEmpty;

  // 빈 컨텍스트 생성 (오류 시 사용)
  factory CalculationContext.empty() {
    return CalculationContext(
      inputData: {},
      environmentData: {},
      constraints: {},
      calculationTimestamp: DateTime.now(),
      calculationId: 'empty_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

// 타입 안전성 보장을 위한 헬퍼 클래스들
class TypeSafetyHelper {
  // 타입 안전한 값 추출
  static T? safeExtract<T>(
      Map<String, dynamic> data, String key, T? defaultValue) {
    try {
      final value = data[key];
      if (value is T) {
        return value;
      }
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  // 타입 안전한 리스트 추출
  static List<T> safeExtractList<T>(Map<String, dynamic> data, String key) {
    try {
      final value = data[key];
      if (value is List) {
        return value.whereType<T>().toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 타입 안전한 맵 추출
  static Map<String, dynamic> safeExtractMap(
      Map<String, dynamic> data, String key) {
    try {
      final value = data[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
      return {};
    } catch (e) {
      return {};
    }
  }
}
