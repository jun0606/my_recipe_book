import 'package:my_recipe_book/models/analysis_request.dart';

/// 분석 모듈의 표준 인터페이스
/// 
/// 모든 분석 모듈은 이 인터페이스를 구현해야 하며,
/// 플러그인 아키텍처를 통해 동적으로 로드될 수 있습니다.
abstract class AnalysisModule {
  /// 모듈의 고유 이름
  String get name;
  
  /// 모듈 버전
  String get version;
  
  /// 모듈 설명
  String get description;
  
  /// 실행 우선순위 (낮을수록 먼저 실행)
  int get priority;
  
  /// 의존성 모듈 목록 (이 모듈들이 먼저 실행되어야 함)
  List<String> get dependencies;
  
  /// 모듈 카테고리
  AnalysisModuleCategory get category;
  
  /// 모듈이 활성화되어 있는지 여부
  bool get isEnabled;
  
  /// 모듈이 초기화되었는지 여부
  bool get isInitialized;

  /// 모듈 초기화
  /// 
  /// 모듈이 처음 로드될 때 호출되며,
  /// 필요한 리소스를 준비하고 설정을 로드합니다.
  Future<void> initialize();

  /// 모듈 정리
  /// 
  /// 모듈이 언로드될 때 호출되며,
  /// 사용한 리소스를 정리합니다.
  Future<void> dispose();

  /// 분석 실행
  /// 
  /// 주어진 요청에 대해 분석을 수행하고 결과를 반환합니다.
  /// 
  /// [request] 분석 요청 객체
  /// 
  /// Returns: 분석 결과 데이터
  /// Throws: [AnalysisException] 분석 중 오류 발생 시
  Future<Map<String, dynamic>> analyze(AnalysisRequest request);

  /// 요청 처리 가능 여부 확인
  /// 
  /// 주어진 요청을 이 모듈이 처리할 수 있는지 확인합니다.
  /// 
  /// [request] 분석 요청 객체
  /// 
  /// Returns: 처리 가능하면 true, 그렇지 않으면 false
  bool canHandle(AnalysisRequest request);

  /// 모듈 설정 업데이트
  /// 
  /// 런타임에 모듈 설정을 변경할 때 사용합니다.
  /// 
  /// [config] 새로운 설정 맵
  Future<void> updateConfiguration(Map<String, dynamic> config);

  /// 모듈 상태 확인
  /// 
  /// 모듈의 현재 상태와 건강성을 확인합니다.
  /// 
  /// Returns: 모듈 상태 정보
  Future<ModuleHealthStatus> checkHealth();

  /// 예상 처리 시간 계산
  /// 
  /// 주어진 요청에 대한 예상 처리 시간을 밀리초 단위로 반환합니다.
  /// 
  /// [request] 분석 요청 객체
  /// 
  /// Returns: 예상 처리 시간 (밀리초)
  int estimateProcessingTime(AnalysisRequest request);

  /// 예상 메모리 사용량 계산
  /// 
  /// 주어진 요청에 대한 예상 메모리 사용량을 바이트 단위로 반환합니다.
  /// 
  /// [request] 분석 요청 객체
  /// 
  /// Returns: 예상 메모리 사용량 (바이트)
  int estimateMemoryUsage(AnalysisRequest request);

  /// 모듈 메타데이터 반환
  /// 
  /// 모듈에 대한 상세 정보를 반환합니다.
  /// 
  /// Returns: 모듈 메타데이터
  AnalysisModuleMetadata getMetadata();
}

/// 분석 모듈 카테고리
enum AnalysisModuleCategory {
  /// 레시피 분석
  recipe('레시피 분석'),
  
  /// 재료 분석
  ingredient('재료 분석'),
  
  /// 환경 분석
  environment('환경 분석'),
  
  /// 영양 분석
  nutrition('영양 분석'),
  
  /// 비용 분석
  cost('비용 분석'),
  
  /// 알레르기 분석
  allergy('알레르기 분석'),
  
  /// 발효 분석
  fermentation('발효 분석'),
  
  /// 베이킹 과학 분석
  bakingScience('베이킹 과학'),
  
  /// 식감 분석
  texture('식감 분석'),
  
  /// 맛 분석
  flavor('맛 분석'),
  
  /// 환경 영향 분석
  environmentalImpact('환경 영향'),
  
  /// 기타
  other('기타');

  const AnalysisModuleCategory(this.displayName);
  
  final String displayName;
}

/// 모듈 건강 상태
class ModuleHealthStatus {
  /// 건강한 상태인지 여부
  final bool isHealthy;
  
  /// 상태 메시지
  final String message;
  
  /// 마지막 확인 시간
  final DateTime lastChecked;
  
  /// 추가 진단 정보
  final Map<String, dynamic> diagnostics;

  const ModuleHealthStatus({
    required this.isHealthy,
    required this.message,
    required this.lastChecked,
    this.diagnostics = const {},
  });

  /// 건강한 상태 생성
  factory ModuleHealthStatus.healthy([String? message]) {
    return ModuleHealthStatus(
      isHealthy: true,
      message: message ?? '모듈이 정상적으로 작동 중입니다.',
      lastChecked: DateTime.now(),
    );
  }

  /// 비건강한 상태 생성
  factory ModuleHealthStatus.unhealthy(String message, [Map<String, dynamic>? diagnostics]) {
    return ModuleHealthStatus(
      isHealthy: false,
      message: message,
      lastChecked: DateTime.now(),
      diagnostics: diagnostics ?? {},
    );
  }

  @override
  String toString() {
    return 'ModuleHealth(${isHealthy ? "HEALTHY" : "UNHEALTHY"}: $message)';
  }
}

/// 분석 모듈 메타데이터
class AnalysisModuleMetadata {
  /// 모듈 이름
  final String name;
  
  /// 모듈 버전
  final String version;
  
  /// 모듈 설명
  final String description;
  
  /// 모듈 작성자
  final String author;
  
  /// 모듈 카테고리
  final AnalysisModuleCategory category;
  
  /// 지원하는 기능 목록
  final List<String> supportedFeatures;
  
  /// 필요한 권한 목록
  final List<String> requiredPermissions;
  
  /// 설정 스키마
  final Map<String, dynamic> configurationSchema;
  
  /// 생성 시간
  final DateTime createdAt;
  
  /// 마지막 업데이트 시간
  final DateTime updatedAt;

  const AnalysisModuleMetadata({
    required this.name,
    required this.version,
    required this.description,
    required this.author,
    required this.category,
    required this.supportedFeatures,
    required this.requiredPermissions,
    required this.configurationSchema,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON으로 직렬화
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'version': version,
      'description': description,
      'author': author,
      'category': category.name,
      'supportedFeatures': supportedFeatures,
      'requiredPermissions': requiredPermissions,
      'configurationSchema': configurationSchema,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// JSON에서 역직렬화
  factory AnalysisModuleMetadata.fromJson(Map<String, dynamic> json) {
    return AnalysisModuleMetadata(
      name: json['name'] as String,
      version: json['version'] as String,
      description: json['description'] as String,
      author: json['author'] as String,
      category: AnalysisModuleCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => AnalysisModuleCategory.other),
      supportedFeatures: List<String>.from(json['supportedFeatures'] ?? []),
      requiredPermissions: List<String>.from(json['requiredPermissions'] ?? []),
      configurationSchema: json['configurationSchema'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'ModuleMetadata($name v$version, category: ${category.displayName})';
  }
}

/// 분석 모듈의 기본 구현을 제공하는 추상 클래스
/// 
/// 공통 기능을 구현하여 실제 모듈 구현을 단순화합니다.
abstract class BaseAnalysisModule implements AnalysisModule {
  final String _name;
  final String _version;
  final String _description;
  final int _priority;
  final List<String> _dependencies;
  final AnalysisModuleCategory _category;
  
  bool _isEnabled = true;
  bool _isInitialized = false;
  Map<String, dynamic> _configuration = {};

  BaseAnalysisModule({
    required String name,
    required String version,
    required String description,
    required int priority,
    required List<String> dependencies,
    required AnalysisModuleCategory category,
    Map<String, dynamic> initialConfiguration = const {},
  })  : _name = name,
        _version = version,
        _description = description,
        _priority = priority,
        _dependencies = dependencies,
        _category = category,
        _configuration = Map.from(initialConfiguration);

  @override
  String get name => _name;

  @override
  String get version => _version;

  @override
  String get description => _description;

  @override
  int get priority => _priority;

  @override
  List<String> get dependencies => List.unmodifiable(_dependencies);

  @override
  AnalysisModuleCategory get category => _category;

  @override
  bool get isEnabled => _isEnabled;

  @override
  bool get isInitialized => _isInitialized;

  /// 설정 값 가져오기
  T? getConfiguration<T>(String key, [T? defaultValue]) {
    final value = _configuration[key];
    return value is T ? value : defaultValue;
  }

  /// 설정 값 설정
  void setConfiguration(String key, dynamic value) {
    _configuration[key] = value;
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await onInitialize();
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    if (!_isInitialized) return;
    
    await onDispose();
    _isInitialized = false;
  }

  @override
  Future<void> updateConfiguration(Map<String, dynamic> config) async {
    _configuration.addAll(config);
    await onConfigurationUpdated(config);
  }

  @override
  Future<ModuleHealthStatus> checkHealth() async {
    if (!_isInitialized) {
      return ModuleHealthStatus.unhealthy('모듈이 초기화되지 않았습니다.');
    }
    
    if (!_isEnabled) {
      return ModuleHealthStatus.unhealthy('모듈이 비활성화되어 있습니다.');
    }
    
    return await performHealthCheck();
  }

  @override
  int estimateProcessingTime(AnalysisRequest request) {
    // 기본 추정치: 재료 수 * 100ms + 기본 1초
    return 1000 + (request.ingredients.length * 100);
  }

  @override
  int estimateMemoryUsage(AnalysisRequest request) {
    // 기본 추정치: 10MB + 재료당 1MB
    return (10 + request.ingredients.length) * 1024 * 1024;
  }

  @override
  AnalysisModuleMetadata getMetadata() {
    return AnalysisModuleMetadata(
      name: name,
      version: version,
      description: description,
      author: 'Unknown',
      category: category,
      supportedFeatures: getSupportedFeatures(),
      requiredPermissions: getRequiredPermissions(),
      configurationSchema: getConfigurationSchema(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 모듈별 초기화 로직 구현
  Future<void> onInitialize();

  /// 모듈별 정리 로직 구현
  Future<void> onDispose();

  /// 설정 업데이트 시 호출되는 콜백
  Future<void> onConfigurationUpdated(Map<String, dynamic> config) async {
    // 기본 구현은 아무것도 하지 않음
  }

  /// 모듈별 건강 상태 확인 로직
  Future<ModuleHealthStatus> performHealthCheck() async {
    return ModuleHealthStatus.healthy();
  }

  /// 지원하는 기능 목록 반환
  List<String> getSupportedFeatures() {
    return ['basic_analysis'];
  }

  /// 필요한 권한 목록 반환
  List<String> getRequiredPermissions() {
    return [];
  }

  /// 설정 스키마 반환
  Map<String, dynamic> getConfigurationSchema() {
    return {};
  }

  /// 모듈 활성화/비활성화
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  @override
  String toString() {
    return '$name v$version (${category.displayName})';
  }
}

/// 분석 예외 클래스
class AnalysisException implements Exception {
  /// 오류 메시지
  final String message;
  
  /// 오류 코드
  final String? code;
  
  /// 원인이 된 예외
  final Exception? cause;
  
  /// 모듈 이름
  final String? moduleName;

  const AnalysisException(
    this.message, {
    this.code,
    this.cause,
    this.moduleName,
  });

  @override
  String toString() {
    final modulePrefix = moduleName != null ? '[$moduleName] ' : '';
    final codePrefix = code != null ? '($code) ' : '';
    return 'AnalysisException: $modulePrefix$codePrefix$message';
  }
}

/// 모듈 로딩 예외
class ModuleLoadException extends AnalysisException {
  const ModuleLoadException(String message, {String? moduleName})
      : super(message, code: 'MODULE_LOAD_ERROR', moduleName: moduleName);
}

/// 모듈 초기화 예외
class ModuleInitializationException extends AnalysisException {
  const ModuleInitializationException(String message, {String? moduleName})
      : super(message, code: 'MODULE_INIT_ERROR', moduleName: moduleName);
}

/// 분석 처리 예외
class AnalysisProcessingException extends AnalysisException {
  const AnalysisProcessingException(String message, {String? moduleName, Exception? cause})
      : super(message, code: 'ANALYSIS_PROCESSING_ERROR', moduleName: moduleName, cause: cause);
}

/// 모듈 설정 예외
class ModuleConfigurationException extends AnalysisException {
  const ModuleConfigurationException(String message, {String? moduleName})
      : super(message, code: 'MODULE_CONFIG_ERROR', moduleName: moduleName);
}