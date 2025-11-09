// 제네릭 기반 분석 컨트롤러
// Week 2: 컨트롤러 패턴 적용

import '../types/comprehensive_types.dart';

/// 분석 컨트롤러의 기본 인터페이스
abstract class BaseAnalysisController<TInput, TOutput> {
  /// 분석 실행
  Future<AnalysisResult<TOutput>> analyze(TInput input);

  /// 입력 데이터 검증
  bool validateInput(TInput input);

  /// 기본 설정 가져오기
  AnalysisSettings get defaultSettings;

  /// 컨트롤러 이름
  String get controllerName;

  /// 지원하는 분석 타입
  List<String> get supportedAnalysisTypes;

  /// 성능 메트릭스
  AnalysisMetrics get metrics => AnalysisMetrics.empty();

  /// 캐시 지원 여부
  bool get supportsCaching => false;

  /// 초기화
  Future<void> initialize() async {}

  /// 정리
  Future<void> dispose() async {}
}

/// 분석 메트릭스 클래스
class AnalysisMetrics {
  final int totalRequests;
  final int successfulRequests;
  final int failedRequests;
  final Duration averageProcessingTime;
  final Duration maxProcessingTime;
  final Duration minProcessingTime;
  final double cacheHitRate;
  final int cacheSize;

  const AnalysisMetrics({
    required this.totalRequests,
    required this.successfulRequests,
    required this.failedRequests,
    required this.averageProcessingTime,
    required this.maxProcessingTime,
    required this.minProcessingTime,
    required this.cacheHitRate,
    required this.cacheSize,
  });

  factory AnalysisMetrics.empty() {
    return const AnalysisMetrics(
      totalRequests: 0,
      successfulRequests: 0,
      failedRequests: 0,
      averageProcessingTime: Duration.zero,
      maxProcessingTime: Duration.zero,
      minProcessingTime: Duration.zero,
      cacheHitRate: 0.0,
      cacheSize: 0,
    );
  }

  double get successRate =>
      totalRequests > 0 ? successfulRequests / totalRequests : 0.0;

  AnalysisMetrics copyWith({
    int? totalRequests,
    int? successfulRequests,
    int? failedRequests,
    Duration? averageProcessingTime,
    Duration? maxProcessingTime,
    Duration? minProcessingTime,
    double? cacheHitRate,
    int? cacheSize,
  }) {
    return AnalysisMetrics(
      totalRequests: totalRequests ?? this.totalRequests,
      successfulRequests: successfulRequests ?? this.successfulRequests,
      failedRequests: failedRequests ?? this.failedRequests,
      averageProcessingTime:
          averageProcessingTime ?? this.averageProcessingTime,
      maxProcessingTime: maxProcessingTime ?? this.maxProcessingTime,
      minProcessingTime: minProcessingTime ?? this.minProcessingTime,
      cacheHitRate: cacheHitRate ?? this.cacheHitRate,
      cacheSize: cacheSize ?? this.cacheSize,
    );
  }
}

/// 재료 분석 컨트롤러
abstract class IngredientAnalysisController extends BaseAnalysisController<
    AnalysisRequest, ComprehensiveIngredientAnalysis> {
  @override
  String get controllerName => 'IngredientAnalysisController';

  @override
  List<String> get supportedAnalysisTypes => ['syrup', 'fat', 'special_dough'];

  @override
  AnalysisSettings get defaultSettings => const AnalysisSettings();

  /// 시럽 분석
  Future<AnalysisResult<SyrupAnalysisResult>> analyzeSyrup(
    List<Map<String, dynamic>> ingredients,
  );

  /// 지방 분석
  Future<AnalysisResult<FatAnalysisResult>> analyzeFat(
    List<Map<String, dynamic>> ingredients,
  );

  /// 특수 반죽 감지
  Future<AnalysisResult<SpecialDoughDetectionResult>> detectSpecialDough(
    List<Map<String, dynamic>> ingredients,
  );

  /// 통합 효과 계산
  Future<AnalysisResult<Map<String, dynamic>>> calculateIntegratedEffects(
    SyrupAnalysisResult syrupAnalysis,
    FatAnalysisResult fatAnalysis,
    SpecialDoughDetectionResult specialDoughDetection,
  );
}

/// 믹싱 분석 컨트롤러
abstract class MixingAnalysisController
    extends BaseAnalysisController<Map<String, dynamic>, MixingAnalysisResult> {
  @override
  String get controllerName => 'MixingAnalysisController';

  @override
  List<String> get supportedAnalysisTypes =>
      ['mixing_optimization', 'rpm_calculation'];

  @override
  AnalysisSettings get defaultSettings => const AnalysisSettings(
        enableRPMMode: true,
        enableRealTimeFeedback: true,
      );

  /// 믹싱 단계 최적화
  Future<AnalysisResult<List<Map<String, dynamic>>>> optimizeMixingSteps(
    List<Map<String, dynamic>> mixingSteps,
    ComprehensiveIngredientAnalysis ingredientAnalysis,
  );

  /// RPM 계산
  Future<AnalysisResult<Map<String, int>>> calculateRPMValues(
    List<Map<String, dynamic>> mixingSteps,
    String mixerType,
  );

  /// 믹싱 권장사항 생성
  Future<AnalysisResult<Map<String, dynamic>>> generateMixingRecommendations(
    MixingAnalysisResult analysisResult,
  );
}

/// 환경 분석 컨트롤러
abstract class EnvironmentAnalysisController extends BaseAnalysisController<
    Map<String, dynamic>, EnvironmentAnalysisResult> {
  @override
  String get controllerName => 'EnvironmentAnalysisController';

  @override
  List<String> get supportedAnalysisTypes =>
      ['temperature', 'humidity', 'seasonal'];

  @override
  AnalysisSettings get defaultSettings => const AnalysisSettings(
        enableRealTimeFeedback: true,
      );

  /// 온도 분석
  Future<AnalysisResult<Map<String, dynamic>>> analyzeTemperature(
    double temperature,
    String season,
  );

  /// 습도 분석
  Future<AnalysisResult<Map<String, dynamic>>> analyzeHumidity(
    double humidity,
    String season,
  );

  /// 계절별 최적화
  Future<AnalysisResult<Map<String, dynamic>>> analyzeSeasonalEffects(
    String season,
    Map<String, dynamic> environment,
  );
}

/// 캐싱을 지원하는 컨트롤러 믹스인
mixin CacheableAnalysisController<TInput, TOutput>
    on BaseAnalysisController<TInput, TOutput> {
  @override
  bool get supportsCaching => true;

  /// 캐시 키 생성
  String generateCacheKey(TInput input);

  /// 캐시에서 결과 조회
  Future<TOutput?> getCachedResult(String cacheKey);

  /// 결과를 캐시에 저장
  Future<void> cacheResult(String cacheKey, TOutput result);

  /// 캐시 정리
  Future<void> clearCache();

  /// 캐시 통계
  Future<Map<String, dynamic>> getCacheStats();
}

/// 로깅을 지원하는 컨트롤러 믹스인
mixin LoggableAnalysisController<TInput, TOutput>
    on BaseAnalysisController<TInput, TOutput> {
  /// 분석 시작 로깅
  void logAnalysisStart(TInput input, String requestId);

  /// 분석 완료 로깅
  void logAnalysisComplete(AnalysisResult<TOutput> result, String requestId);

  /// 분석 실패 로깅
  void logAnalysisFailure(
      String error, String requestId, Duration processingTime);

  /// 성능 메트릭스 로깅
  void logPerformanceMetrics(AnalysisMetrics metrics);
}

/// 검증을 지원하는 컨트롤러 믹스인
mixin ValidatableAnalysisController<TInput, TOutput>
    on BaseAnalysisController<TInput, TOutput> {
  /// 입력 데이터 사전 검증
  ValidationResult preValidateInput(TInput input);

  /// 출력 데이터 사후 검증
  ValidationResult postValidateOutput(TOutput output);

  /// 검증 규칙
  Map<String, ValidationRule> get validationRules;
}

/// 검증 결과 클래스
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final Map<String, dynamic> details;

  const ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
    this.details = const {},
  });

  factory ValidationResult.valid() {
    return const ValidationResult(isValid: true);
  }

  factory ValidationResult.invalid(List<String> errors,
      [List<String> warnings = const []]) {
    return ValidationResult(
      isValid: false,
      errors: errors,
      warnings: warnings,
    );
  }

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
}

/// 검증 규칙 클래스
class ValidationRule {
  final String name;
  final bool required;
  final dynamic defaultValue;
  final List<String> allowedValues;
  final num? minValue;
  final num? maxValue;

  const ValidationRule({
    required this.name,
    this.required = false,
    this.defaultValue,
    this.allowedValues = const [],
    this.minValue,
    this.maxValue,
  });

  bool validate(dynamic value) {
    if (required && value == null) return false;
    if (value == null) return true;

    if (allowedValues.isNotEmpty && !allowedValues.contains(value)) {
      return false;
    }

    if (minValue != null && value is num && value < minValue!) {
      return false;
    }

    if (maxValue != null && value is num && value > maxValue!) {
      return false;
    }

    return true;
  }
}

/// 컨트롤러 팩토리 클래스
class AnalysisControllerFactory {
  static final Map<String, BaseAnalysisController> _controllers = {};

  /// 컨트롤러 등록
  static void registerController<TInput, TOutput>(
    String name,
    BaseAnalysisController<TInput, TOutput> controller,
  ) {
    _controllers[name] = controller;
  }

  /// 컨트롤러 조회
  static BaseAnalysisController? getController(String name) {
    return _controllers[name];
  }

  /// 모든 컨트롤러 조회
  static Iterable<BaseAnalysisController> getAllControllers() {
    return _controllers.values;
  }

  /// 컨트롤러 존재 여부 확인
  static bool hasController(String name) {
    return _controllers.containsKey(name);
  }

  /// 컨트롤러 제거
  static void unregisterController(String name) {
    _controllers.remove(name);
  }

  /// 모든 컨트롤러 초기화
  static Future<void> initializeAllControllers() async {
    for (final controller in _controllers.values) {
      await controller.initialize();
    }
  }

  /// 모든 컨트롤러 정리
  static Future<void> disposeAllControllers() async {
    for (final controller in _controllers.values) {
      await controller.dispose();
    }
    _controllers.clear();
  }
}

/// 컨트롤러 관리자 클래스
class AnalysisControllerManager {
  final List<BaseAnalysisController> _controllers = [];

  /// 컨트롤러 추가
  void addController(BaseAnalysisController controller) {
    _controllers.add(controller);
  }

  /// 컨트롤러 제거
  void removeController(BaseAnalysisController controller) {
    _controllers.remove(controller);
  }

  /// 타입별 컨트롤러 찾기
  BaseAnalysisController? findControllerByType(String analysisType) {
    return _controllers.firstWhere(
      (controller) => controller.supportedAnalysisTypes.contains(analysisType),
      orElse: () =>
          throw Exception('Controller not found for type: $analysisType'),
    );
  }

  /// 이름별 컨트롤러 찾기
  BaseAnalysisController? findControllerByName(String name) {
    return _controllers.firstWhere(
      (controller) => controller.controllerName == name,
      orElse: () => throw Exception('Controller not found with name: $name'),
    );
  }

  /// 모든 컨트롤러 상태 조회
  Map<String, dynamic> getControllerStatus() {
    return {
      'totalControllers': _controllers.length,
      'controllerNames': _controllers.map((c) => c.controllerName).toList(),
      'supportedTypes':
          _controllers.expand((c) => c.supportedAnalysisTypes).toSet().toList(),
      'cacheableControllers': _controllers
          .where((c) => c.supportsCaching)
          .map((c) => c.controllerName)
          .toList(),
    };
  }
}
