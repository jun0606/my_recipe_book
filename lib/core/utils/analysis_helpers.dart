/// 분석 시스템 공통 헬퍼 클래스
/// 중복 코드 제거 및 안전한 데이터 처리를 위한 유틸리티 클래스

import 'dart:convert';
import 'dart:math' as math;
import '../../services/environment_defaults_calculator.dart';
import '../../services/ingredient_analyzer.dart';

/// 분석 헬퍼 클래스
class AnalysisHelpers {
  /// 안전한 double 변환
  static double safeToDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;

    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? defaultValue;
    }

    return defaultValue;
  }

  /// 안전한 int 변환
  static int safeToInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;

    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? defaultValue;
    }

    return defaultValue;
  }

  /// 안전한 String 변환
  static String safeToString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  /// 안전한 JSON 파싱
  static T? safeJsonDecode<T>(
      String jsonString, T Function(Map<String, dynamic>) fromJson) {
    try {
      final Map<String, dynamic> data =
          jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(data);
    } catch (e) {
      print('JSON 파싱 실패: $e');
      return null;
    }
  }

  /// 안전한 Map 변환
  static Map<String, dynamic> safeToMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  /// 안전한 List 변환
  static List<Map<String, dynamic>> safeToListOfMaps(dynamic value) {
    if (value is List<Map<String, dynamic>>) return value;
    if (value is List) {
      return value.map((item) => safeToMap(item)).toList();
    }
    return [];
  }

  /// 단위 변환 (그램으로) - IngredientAnalyzer 활용
  static double convertToGrams(
      double amount, String unit, String ingredientName) {
    // IngredientAnalyzer의 convertToGrams 메소드 활용 (중복 제거)
    return IngredientAnalyzer.convertToGrams(amount, unit, ingredientName);
  }

  /// 캐시 키 생성
  static String generateCacheKey(dynamic data, [String prefix = '']) {
    final hash = data.hashCode.abs();
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return '${prefix}_${hash}_$timestamp';
  }

  /// 값 범위 제한
  static double clamp(double value,
      {double min = 0.0, double max = double.infinity}) {
    return math.max(min, math.min(max, value));
  }

  /// 백분율 값 검증
  static double validatePercentage(double value) {
    return clamp(value, min: 0.0, max: 100.0);
  }

  /// 시간 값 검증 (분 단위)
  static int validateMinutes(int value) {
    return clamp(value.toDouble(), min: 1.0, max: 480.0).toInt(); // 1분 ~ 8시간
  }

  /// 온도 값 검증 (°C)
  static double validateTemperature(double value) {
    return clamp(value, min: 0.0, max: 300.0);
  }

  /// 습도 값 검증 (%)
  static double validateHumidity(double value) {
    return clamp(value, min: 0.0, max: 100.0);
  }

  /// 속도 값 정규화
  static String normalizeSpeed(dynamic speed) {
    if (speed == null) return '중속';

    final speedStr = speed.toString().toLowerCase();
    if (speedStr.contains('저속') ||
        speedStr.contains('low') ||
        speedStr == '1') {
      return '저속';
    } else if (speedStr.contains('고속') ||
        speedStr.contains('high') ||
        speedStr == '3') {
      return '고속';
    } else {
      return '중속';
    }
  }

  /// 믹서 타입 정규화
  static String? normalizeMixerType(String? rawType) {
    if (rawType == null) return null;

    switch (rawType.toLowerCase()) {
      case 'home':
      case '가정용':
      case 'domestic':
        return '가정용';
      case 'commercial':
      case '상업용':
      case 'business':
        return '상업용';
      case 'professional':
      case '전문가용':
      case 'expert':
        return '전문가용';
      default:
        return null;
    }
  }

  /// 에러 처리 헬퍼
  static void logError(String operation, dynamic error, [dynamic data]) {
    print('[$operation] 오류 발생: $error');
    if (data != null) {
      print('[$operation] 관련 데이터: $data');
    }
  }

  /// 안전한 비동기 실행
  static Future<T?> safeAsync<T>(
    Future<T> Function() operation, {
    T? defaultValue,
    String operationName = '비동기 작업',
  }) async {
    try {
      return await operation();
    } catch (e) {
      logError(operationName, e);
      return defaultValue;
    }
  }

  /// 데이터 검증 헬퍼
  static bool isValidNumber(dynamic value) {
    if (value == null) return false;
    if (value is num) return value.isFinite;
    if (value is String) return double.tryParse(value) != null;
    return false;
  }

  /// 빈 값 체크
  static bool isEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    if (value is List) return value.isEmpty;
    if (value is Map) return value.isEmpty;
    return false;
  }

  /// 기본값 제공
  static T defaultValue<T>(T? value, T defaultVal) {
    return value ?? defaultVal;
  }
}

/// 빵 분석 모듈 인터페이스 (표준화)
abstract class BakingAnalysisModule {
  /// 모듈 타입
  String get moduleType;

  /// 모듈 표시 이름
  String get displayName;

  /// 모듈이 레시피를 처리할 수 있는지 확인
  bool canHandleRecipe(Map<String, dynamic> recipeData);

  /// 분석 수행
  Future<AnalysisResult> analyze(
      Map<String, dynamic> recipeData, Map<String, dynamic> environmentData);

  /// 분석 결과 UI 빌드
  dynamic buildAnalysisResult(AnalysisResult result);

  /// 지원되는 기능들
  List<String> get supportedFeatures;
}

/// 분석 결과 인터페이스
abstract class AnalysisResult {
  /// 성공 여부
  bool get isSuccess;

  /// 분석 데이터
  Map<String, dynamic> get data;

  /// 신뢰도 점수 (0.0 ~ 1.0)
  double get confidence;

  /// 분석에 걸린 시간
  Duration get analysisTime;

  /// 에러 메시지 (실패한 경우)
  String? get errorMessage;
}

/// 구체적인 빵 분석 결과 구현
class BreadAnalysisResult implements AnalysisResult {
  @override
  final bool isSuccess;
  @override
  final Map<String, dynamic> data;
  @override
  final double confidence;
  @override
  final Duration analysisTime;
  @override
  final String? errorMessage;

  const BreadAnalysisResult({
    required this.isSuccess,
    required this.data,
    required this.confidence,
    required this.analysisTime,
    this.errorMessage,
  });

  /// 성공 결과 생성
  factory BreadAnalysisResult.success({
    required Map<String, dynamic> data,
    required double confidence,
    required Duration analysisTime,
  }) {
    return BreadAnalysisResult(
      isSuccess: true,
      data: data,
      confidence: confidence,
      analysisTime: analysisTime,
      errorMessage: null,
    );
  }

  /// 실패 결과 생성
  factory BreadAnalysisResult.failure({
    required String errorMessage,
    required Duration analysisTime,
  }) {
    return BreadAnalysisResult(
      isSuccess: false,
      data: {},
      confidence: 0.0,
      analysisTime: analysisTime,
      errorMessage: errorMessage,
    );
  }
}

/// 분석 상수 클래스
class AnalysisConstants {
  // 기본 분석 값들
  static const double defaultGlutenIndex = 0.75;
  static const int defaultFermentationTime = 120; // 분
  static const double defaultSuccessProbability = 0.8;
  static const double defaultHydrationRate = 1.0;

  // 믹싱 기본값들
  static const int defaultMixingDuration = 8; // 분
  static const String defaultMixingSpeed = '중속';

  // 환경 기본값들 (동적 계산 적용 - 하드코딩 제거)
  static double get defaultTemperature =>
      EnvironmentDefaultsCalculator.getDefaultEnvironment().temperature;
  static double get defaultHumidity =>
      EnvironmentDefaultsCalculator.getDefaultEnvironment().humidity;
  static const double defaultAltitude = 0.0; // m

  // 도우 타입별 기본값들
  static const Map<String, Map<String, dynamic>> doughTypeDefaults = {
    'lean': {
      'glutenTarget': 0.8,
      'timeMultiplier': 1.0,
      'successProbability': 0.85,
    },
    'rich': {
      'glutenTarget': 0.7,
      'timeMultiplier': 1.2,
      'successProbability': 0.78,
    },
    'sourdough': {
      'glutenTarget': 0.75,
      'timeMultiplier': 1.5,
      'successProbability': 0.82,
    },
    'croissant': {
      'glutenTarget': 0.9,
      'timeMultiplier': 1.8,
      'successProbability': 0.75,
    },
    'brioche': {
      'glutenTarget': 0.65,
      'timeMultiplier': 1.3,
      'successProbability': 0.80,
    },
  };

  // 믹서 타입별 효율성
  static const Map<String, double> mixerEfficiency = {
    '가정용': 0.85,
    '상업용': 0.95,
    '전문가용': 1.0,
  };

  // 오븐 타입별 보정 계수
  static const Map<String, double> ovenCalibrationFactors = {
    'convection': 1.0,
    'conventional': 0.95,
    'deck': 1.2,
    'steam': 1.3,
    'home': 0.9,
  };

  // 계절별 보정 계수
  static const Map<String, double> seasonalFactors = {
    'spring': 0.0,
    'summer': -0.1,
    'autumn': 0.0,
    'winter': 0.1,
  };

  // 발효 방식별 기본값들
  static const Map<String, Map<String, dynamic>> fermentationDefaults = {
    'roomTemperature': {
      'temperature': 25.0,
      'humidity': 75.0,
      'timeMultiplier': 1.0,
    },
    'overnight': {
      'temperature': 4.0,
      'humidity': 85.0,
      'timeMultiplier': 2.0,
    },
    'fermenter': {
      'temperature': 25.0,
      'humidity': 75.0,
      'timeMultiplier': 0.8,
    },
    'natural': {
      'temperature': 20.0,
      'humidity': 70.0,
      'timeMultiplier': 1.5,
    },
  };

  // 분석 신뢰도 범위
  static const double minConfidence = 0.0;
  static const double maxConfidence = 1.0;

  // 시간 제한들
  static const int minMixingTime = 1; // 분
  static const int maxMixingTime = 30; // 분
  static const int minFermentationTime = 30; // 분
  static const int maxFermentationTime = 480; // 분 (8시간)

  // 온도 제한들
  static const double minTemperature = 0.0; // °C
  static const double maxTemperature = 300.0; // °C

  // 습도 제한들
  static const double minHumidity = 0.0; // %
  static const double maxHumidity = 100.0; // %
}

/// 데이터 검증 헬퍼 클래스
class ValidationHelpers {
  /// 믹싱 데이터 검증
  static List<Map<String, dynamic>> validateMixingData(
      List<Map<String, dynamic>> data) {
    final validated = <Map<String, dynamic>>[];

    for (int i = 0; i < data.length; i++) {
      final step = Map<String, dynamic>.from(data[i]);

      // 필수 필드 검증 및 기본값 설정
      step['step'] =
          AnalysisHelpers.safeToInt(step['step'], defaultValue: i + 1);
      step['speed'] = AnalysisHelpers.normalizeSpeed(step['speed']);
      step['durationMinutes'] = AnalysisHelpers.validateMinutes(
          AnalysisHelpers.safeToInt(step['durationMinutes'],
              defaultValue: AnalysisConstants.defaultMixingDuration));
      step['comment'] = AnalysisHelpers.safeToString(step['comment'],
          defaultValue: '믹싱 단계 ${i + 1}');

      // 선택적 필드
      step['targetGluten'] = AnalysisHelpers.safeToDouble(step['targetGluten']);
      step['temperature'] = AnalysisHelpers.validateTemperature(
          AnalysisHelpers.safeToDouble(step['temperature'],
              defaultValue: AnalysisConstants.defaultTemperature));

      validated.add(step);
    }

    // 검증 후에도 빈 리스트라면 최소 기본 단계 추가
    if (validated.isEmpty) {
      validated.add({
        'step': 1,
        'speed': AnalysisConstants.defaultMixingSpeed,
        'durationMinutes': AnalysisConstants.defaultMixingDuration,
        'comment': '기본 믹싱 단계 (자동 생성)',
      });
    }

    return validated;
  }

  /// 환경 데이터 검증
  static Map<String, dynamic> validateEnvironmentData(
      Map<String, dynamic> data) {
    return {
      'temperature': AnalysisHelpers.validateTemperature(
          AnalysisHelpers.safeToDouble(data['temperature'],
              defaultValue: AnalysisConstants.defaultTemperature)),
      'humidity': AnalysisHelpers.validateHumidity(AnalysisHelpers.safeToDouble(
          data['humidity'],
          defaultValue: AnalysisConstants.defaultHumidity)),
      'altitude': AnalysisHelpers.safeToDouble(data['altitude'],
          defaultValue: AnalysisConstants.defaultAltitude),
      'season':
          AnalysisHelpers.safeToString(data['season'], defaultValue: 'spring'),
      'ovenType': AnalysisHelpers.safeToString(data['ovenType'],
          defaultValue: 'convection'),
      'fermentationMethod': AnalysisHelpers.safeToString(
          data['fermentationMethod'],
          defaultValue: 'roomTemperature'),
    };
  }

  /// 재료 데이터 검증
  static Map<String, dynamic> validateIngredientData(
      Map<String, dynamic> data) {
    return {
      'name':
          AnalysisHelpers.safeToString(data['name'], defaultValue: 'Unknown'),
      'amount': AnalysisHelpers.safeToDouble(data['amount'], defaultValue: 0.0),
      'unit': AnalysisHelpers.safeToString(data['unit'], defaultValue: 'g'),
      'properties': AnalysisHelpers.safeToMap(data['properties']),
    };
  }
}
