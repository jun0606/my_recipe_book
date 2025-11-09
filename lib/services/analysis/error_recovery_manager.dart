import 'dart:async';
import 'dart:math' as math;
import 'package:my_recipe_book/interfaces/analysis_module.dart';
import 'package:my_recipe_book/models/analysis_request.dart';

/// 오류 처리 및 복구 관리자
///
/// 분석 파이프라인에서 발생하는 오류를 처리하고 복구 전략을 실행합니다.
/// 재시도, 폴백, 회로 차단기, 부분 복구 등 다양한 전략을 지원합니다.
class ErrorRecoveryManager {
  final Map<String, RecoveryStrategy> _recoveryStrategies = {};
  final Map<String, ErrorHistory> _errorHistory = {};
  final List<ErrorRecoveryListener> _listeners = [];

  // 설정
  final int _maxRetryAttempts;
  final Duration _baseRetryDelay;
  final double _backoffMultiplier;
  final Duration _circuitBreakerTimeout;
  final int _circuitBreakerFailureThreshold;
  final bool _enableFallbackExecution;
  final bool _enablePartialRecovery;

  // 회로 차단기 상태
  final Map<String, CircuitBreakerState> _circuitBreakers = {};

  ErrorRecoveryManager({
    int maxRetryAttempts = 3,
    Duration baseRetryDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
    Duration circuitBreakerTimeout = const Duration(minutes: 5),
    int circuitBreakerFailureThreshold = 5,
    bool enableFallbackExecution = true,
    bool enablePartialRecovery = true,
  })  : _maxRetryAttempts = maxRetryAttempts,
        _baseRetryDelay = baseRetryDelay,
        _backoffMultiplier = backoffMultiplier,
        _circuitBreakerTimeout = circuitBreakerTimeout,
        _circuitBreakerFailureThreshold = circuitBreakerFailureThreshold,
        _enableFallbackExecution = enableFallbackExecution,
        _enablePartialRecovery = enablePartialRecovery {
    _initializeDefaultStrategies();
  }

  /// 기본 복구 전략 초기화
  void _initializeDefaultStrategies() {
    // 재시도 전략
    _recoveryStrategies['retry'] = RetryStrategy(
      maxAttempts: _maxRetryAttempts,
      baseDelay: _baseRetryDelay,
      backoffMultiplier: _backoffMultiplier,
    );

    // 폴백 전략
    _recoveryStrategies['fallback'] = FallbackStrategy();

    // 부분 복구 전략
    _recoveryStrategies['partial_recovery'] = PartialRecoveryStrategy();

    // 회로 차단기 전략
    _recoveryStrategies['circuit_breaker'] = CircuitBreakerStrategy(
      failureThreshold: _circuitBreakerFailureThreshold,
      timeout: _circuitBreakerTimeout,
    );

    // 격리 전략
    _recoveryStrategies['isolation'] = IsolationStrategy();
  }

  /// 모듈 실행 (오류 처리 포함)
  Future<Map<String, dynamic>> executeWithRecovery(
      BaseAnalysisModule module, AnalysisRequest request,
      {Map<String, dynamic>? context}) async {
    final moduleName = module.name;
    final executionId = _generateExecutionId();

    // 회로 차단기 확인
    if (_isCircuitBreakerOpen(moduleName)) {
      throw ModuleExecutionException(
        '모듈 "$moduleName"의 회로 차단기가 열려있습니다.',
        moduleName: moduleName,
        errorType: ErrorType.circuitBreakerOpen,
      );
    }

    final execution = ErrorRecoveryExecution(
      id: executionId,
      moduleName: moduleName,
      request: request,
      context: context ?? {},
      startTime: DateTime.now(),
    );

    try {
      _notifyListeners(ErrorRecoveryEvent.executionStarted(execution));

      final result = await _executeWithStrategies(module, request, execution);

      execution.endTime = DateTime.now();
      execution.success = true;
      execution.result = result;

      // 성공 시 회로 차단기 리셋
      _recordSuccess(moduleName);

      _notifyListeners(ErrorRecoveryEvent.executionSucceeded(execution));
      return result;
    } catch (e) {
      execution.endTime = DateTime.now();
      execution.success = false;
      execution.error = e;

      // 오류 기록
      _recordError(moduleName, e, execution);

      _notifyListeners(ErrorRecoveryEvent.executionFailed(execution));
      rethrow;
    }
  }

  /// 전략을 사용한 실행
  Future<Map<String, dynamic>> _executeWithStrategies(
    BaseAnalysisModule module,
    AnalysisRequest request,
    ErrorRecoveryExecution execution,
  ) async {
    final strategies = _selectStrategies(module, execution);

    for (final strategy in strategies) {
      try {
        execution.appliedStrategies.add(strategy.name);
        _notifyListeners(
            ErrorRecoveryEvent.strategyApplied(execution, strategy.name));

        final result = await strategy.execute(module, request, execution);

        _notifyListeners(
            ErrorRecoveryEvent.strategySucceeded(execution, strategy.name));
        return result;
      } catch (e) {
        execution.strategyErrors[strategy.name] = e;
        _notifyListeners(
            ErrorRecoveryEvent.strategyFailed(execution, strategy.name, e));

        // 마지막 전략이 아니면 다음 전략 시도
        if (strategy != strategies.last) {
          continue;
        }

        // 모든 전략 실패
        throw RecoveryFailedException(
          '모든 복구 전략이 실패했습니다.',
          moduleName: module.name,
          appliedStrategies: execution.appliedStrategies,
          strategyErrors: execution.strategyErrors,
          originalError: e,
        );
      }
    }

    throw RecoveryFailedException(
      '적용할 복구 전략이 없습니다.',
      moduleName: module.name,
    );
  }

  /// 복구 전략 선택
  List<RecoveryStrategy> _selectStrategies(
    BaseAnalysisModule module,
    ErrorRecoveryExecution execution,
  ) {
    final strategies = <RecoveryStrategy>[];
    final moduleName = module.name;
    final errorHistory = _errorHistory[moduleName];

    // 오류 이력 기반 전략 선택
    if (errorHistory != null) {
      final recentErrors = errorHistory.getRecentErrors(Duration(minutes: 10));

      if (recentErrors.length >= _circuitBreakerFailureThreshold) {
        // 회로 차단기 전략
        strategies.add(_recoveryStrategies['circuit_breaker']!);
      } else if (recentErrors.any((e) => e.errorType == ErrorType.timeout)) {
        // 타임아웃 오류가 있으면 재시도 전략
        strategies.add(_recoveryStrategies['retry']!);
      } else if (recentErrors
          .any((e) => e.errorType == ErrorType.resourceExhaustion)) {
        // 리소스 부족 시 격리 전략
        strategies.add(_recoveryStrategies['isolation']!);
      }
    }

    // 기본 전략들
    if (strategies.isEmpty) {
      strategies.add(_recoveryStrategies['retry']!);
    }

    if (_enableFallbackExecution) {
      strategies.add(_recoveryStrategies['fallback']!);
    }

    if (_enablePartialRecovery) {
      strategies.add(_recoveryStrategies['partial_recovery']!);
    }

    return strategies;
  }

  /// 회로 차단기 상태 확인
  bool _isCircuitBreakerOpen(String moduleName) {
    final state = _circuitBreakers[moduleName];
    if (state == null) return false;

    if (state.state == CircuitState.open) {
      // 타임아웃 확인
      if (DateTime.now().difference(state.lastFailureTime) >
          _circuitBreakerTimeout) {
        // 반열림 상태로 전환
        state.state = CircuitState.halfOpen;
        return false;
      }
      return true;
    }

    return false;
  }

  /// 성공 기록
  void _recordSuccess(String moduleName) {
    final state = _circuitBreakers[moduleName];
    if (state != null) {
      state.consecutiveFailures = 0;
      state.state = CircuitState.closed;
    }
  }

  /// 오류 기록
  void _recordError(
      String moduleName, Object error, ErrorRecoveryExecution execution) {
    // 오류 이력 업데이트
    _errorHistory.putIfAbsent(moduleName, () => ErrorHistory(moduleName));
    _errorHistory[moduleName]!.addError(ErrorRecord(
      timestamp: DateTime.now(),
      error: error,
      errorType: _classifyError(error),
      executionId: execution.id,
      context: execution.context,
    ));

    // 회로 차단기 상태 업데이트
    final state = _circuitBreakers.putIfAbsent(
        moduleName, () => CircuitBreakerState(moduleName));
    state.consecutiveFailures++;
    state.lastFailureTime = DateTime.now();

    if (state.consecutiveFailures >= _circuitBreakerFailureThreshold) {
      state.state = CircuitState.open;
      _notifyListeners(ErrorRecoveryEvent.circuitBreakerOpened(moduleName));
    }
  }

  /// 오류 분류
  ErrorType _classifyError(Object error) {
    if (error is TimeoutException) {
      return ErrorType.timeout;
    } else if (error is OutOfMemoryError) {
      return ErrorType.resourceExhaustion;
    } else if (error.toString().contains('network') ||
        error.toString().contains('connection')) {
      return ErrorType.network;
    } else if (error is ArgumentError || error is FormatException) {
      return ErrorType.validation;
    } else if (error is StateError) {
      return ErrorType.state;
    } else {
      return ErrorType.unknown;
    }
  }

  /// 복구 전략 등록
  void registerStrategy(String name, RecoveryStrategy strategy) {
    _recoveryStrategies[name] = strategy;
  }

  /// 모듈별 오류 통계 조회
  ErrorStatistics getErrorStatistics(String moduleName) {
    final history = _errorHistory[moduleName];
    if (history == null) {
      return ErrorStatistics.empty(moduleName);
    }
    return history.getStatistics();
  }

  /// 전체 오류 통계 조회
  Map<String, ErrorStatistics> getAllErrorStatistics() {
    return _errorHistory
        .map((name, history) => MapEntry(name, history.getStatistics()));
  }

  /// 회로 차단기 상태 조회
  Map<String, CircuitBreakerState> getCircuitBreakerStates() {
    return Map.from(_circuitBreakers);
  }

  /// 회로 차단기 수동 리셋
  void resetCircuitBreaker(String moduleName) {
    final state = _circuitBreakers[moduleName];
    if (state != null) {
      state.state = CircuitState.closed;
      state.consecutiveFailures = 0;
      _notifyListeners(ErrorRecoveryEvent.circuitBreakerReset(moduleName));
    }
  }

  /// 오류 이력 정리
  void cleanupErrorHistory({Duration? olderThan}) {
    final cutoffTime = DateTime.now().subtract(olderThan ?? Duration(days: 7));

    for (final history in _errorHistory.values) {
      history.cleanup(cutoffTime);
    }

    // 빈 이력 제거
    _errorHistory.removeWhere((_, history) => history.isEmpty);
  }

  /// 실행 ID 생성
  String _generateExecutionId() {
    return 'recovery_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}';
  }

  /// 리스너 추가
  void addListener(ErrorRecoveryListener listener) {
    _listeners.add(listener);
  }

  /// 리스너 제거
  void removeListener(ErrorRecoveryListener listener) {
    _listeners.remove(listener);
  }

  /// 리스너들에게 이벤트 알림
  void _notifyListeners(ErrorRecoveryEvent event) {
    for (final listener in _listeners) {
      try {
        listener.onEvent(event);
      } catch (e) {
        print('오류 복구 리스너 알림 중 오류: $e');
      }
    }
  }

  /// 리소스 정리
  void dispose() {
    _errorHistory.clear();
    _circuitBreakers.clear();
    _listeners.clear();
  }
}

/// 복구 전략 인터페이스
abstract class RecoveryStrategy {
  String get name;

  Future<Map<String, dynamic>> execute(
    BaseAnalysisModule module,
    AnalysisRequest request,
    ErrorRecoveryExecution execution,
  );
}

/// 재시도 전략
class RetryStrategy implements RecoveryStrategy {
  @override
  String get name => 'retry';

  final int maxAttempts;
  final Duration baseDelay;
  final double backoffMultiplier;

  RetryStrategy({
    required this.maxAttempts,
    required this.baseDelay,
    required this.backoffMultiplier,
  });

  @override
  Future<Map<String, dynamic>> execute(
    BaseAnalysisModule module,
    AnalysisRequest request,
    ErrorRecoveryExecution execution,
  ) async {
    Object? lastError;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        if (attempt > 1) {
          final delay = Duration(
            milliseconds: (baseDelay.inMilliseconds *
                    math.pow(backoffMultiplier, attempt - 2))
                .round(),
          );
          await Future.delayed(delay);
        }

        execution.retryAttempts = attempt;
        return await module.analyze(request);
      } catch (e) {
        lastError = e;
        execution.retryErrors.add(e);

        if (attempt == maxAttempts) {
          throw RetryExhaustedException(
            '재시도 횟수($maxAttempts)를 초과했습니다.',
            moduleName: module.name,
            attempts: attempt,
            lastError: e,
          );
        }
      }
    }

    throw lastError ?? Exception('알 수 없는 오류');
  }
}

/// 폴백 전략
class FallbackStrategy implements RecoveryStrategy {
  @override
  String get name => 'fallback';

  @override
  Future<Map<String, dynamic>> execute(
    BaseAnalysisModule module,
    AnalysisRequest request,
    ErrorRecoveryExecution execution,
  ) async {
    // 폴백 결과 생성
    return _generateFallbackResult(module, request);
  }

  Map<String, dynamic> _generateFallbackResult(
      BaseAnalysisModule module, AnalysisRequest request) {
    return {
      'fallback': true,
      'module_name': module.name,
      'message': '기본 분석 결과를 제공합니다.',
      'confidence': 0.3,
      'basic_analysis': {
        'recipe_title': request.recipe.title,
        'ingredient_count': request.recipe.ingredients.length,
        'instruction_count': request.recipe.instructions.length,
        'estimated_difficulty': 'medium',
        'estimated_time': '30-60분',
      },
      'recommendations': [
        {
          'type': 'general',
          'title': '기본 베이킹 팁',
          'description': '재료를 정확히 계량하고 오븐을 미리 예열하세요.',
          'priority': 'medium',
        }
      ],
    };
  }
}

/// 부분 복구 전략
class PartialRecoveryStrategy implements RecoveryStrategy {
  @override
  String get name => 'partial_recovery';

  @override
  Future<Map<String, dynamic>> execute(
    BaseAnalysisModule module,
    AnalysisRequest request,
    ErrorRecoveryExecution execution,
  ) async {
    // 부분적인 분석 시도
    try {
      return await _attemptPartialAnalysis(module, request);
    } catch (e) {
      // 부분 분석도 실패하면 최소한의 결과 반환
      return _generateMinimalResult(module, request);
    }
  }

  Future<Map<String, dynamic>> _attemptPartialAnalysis(
      BaseAnalysisModule module, AnalysisRequest request) async {
    // 간단한 분석만 수행 (타임아웃 짧게 설정)
    return await module.analyze(request).timeout(Duration(seconds: 5));
  }

  Map<String, dynamic> _generateMinimalResult(
      BaseAnalysisModule module, AnalysisRequest request) {
    return {
      'partial_recovery': true,
      'module_name': module.name,
      'message': '부분적인 분석 결과입니다.',
      'confidence': 0.1,
      'basic_info': {
        'recipe_title': request.recipe.title,
        'analysis_status': 'partial',
      },
    };
  }
}

/// 회로 차단기 전략
class CircuitBreakerStrategy implements RecoveryStrategy {
  @override
  String get name => 'circuit_breaker';

  final int failureThreshold;
  final Duration timeout;

  CircuitBreakerStrategy({
    required this.failureThreshold,
    required this.timeout,
  });

  @override
  Future<Map<String, dynamic>> execute(
    BaseAnalysisModule module,
    AnalysisRequest request,
    ErrorRecoveryExecution execution,
  ) async {
    throw CircuitBreakerOpenException(
      '회로 차단기가 열려있어 실행할 수 없습니다.',
      moduleName: module.name,
    );
  }
}

/// 격리 전략
class IsolationStrategy implements RecoveryStrategy {
  @override
  String get name => 'isolation';

  @override
  Future<Map<String, dynamic>> execute(
    BaseAnalysisModule module,
    AnalysisRequest request,
    ErrorRecoveryExecution execution,
  ) async {
    // 격리된 환경에서 실행 (리소스 제한)
    return await _executeInIsolation(module, request);
  }

  Future<Map<String, dynamic>> _executeInIsolation(
      BaseAnalysisModule module, AnalysisRequest request) async {
    // 실제 구현에서는 별도 Isolate나 제한된 리소스로 실행
    // 여기서는 타임아웃을 짧게 설정하여 시뮬레이션
    return await module.analyze(request).timeout(Duration(seconds: 10));
  }
}

/// 오류 복구 실행 정보
class ErrorRecoveryExecution {
  final String id;
  final String moduleName;
  final AnalysisRequest request;
  final Map<String, dynamic> context;
  final DateTime startTime;
  DateTime? endTime;
  bool success = false;
  Map<String, dynamic>? result;
  Object? error;

  final List<String> appliedStrategies = [];
  final Map<String, Object> strategyErrors = {};
  final List<Object> retryErrors = [];
  int retryAttempts = 0;

  ErrorRecoveryExecution({
    required this.id,
    required this.moduleName,
    required this.request,
    required this.context,
    required this.startTime,
  });

  Duration get duration => (endTime ?? DateTime.now()).difference(startTime);
}

/// 오류 기록
class ErrorRecord {
  final DateTime timestamp;
  final Object error;
  final ErrorType errorType;
  final String executionId;
  final Map<String, dynamic> context;

  ErrorRecord({
    required this.timestamp,
    required this.error,
    required this.errorType,
    required this.executionId,
    required this.context,
  });
}

/// 오류 이력
class ErrorHistory {
  final String moduleName;
  final List<ErrorRecord> _errors = [];

  ErrorHistory(this.moduleName);

  void addError(ErrorRecord error) {
    _errors.add(error);
  }

  List<ErrorRecord> getRecentErrors(Duration duration) {
    final cutoff = DateTime.now().subtract(duration);
    return _errors.where((e) => e.timestamp.isAfter(cutoff)).toList();
  }

  ErrorStatistics getStatistics() {
    if (_errors.isEmpty) {
      return ErrorStatistics.empty(moduleName);
    }

    final now = DateTime.now();
    final last24Hours =
        _errors.where((e) => now.difference(e.timestamp).inHours < 24).length;
    final lastHour =
        _errors.where((e) => now.difference(e.timestamp).inMinutes < 60).length;

    final errorTypeCounts = <ErrorType, int>{};
    for (final error in _errors) {
      errorTypeCounts[error.errorType] =
          (errorTypeCounts[error.errorType] ?? 0) + 1;
    }

    return ErrorStatistics(
      moduleName: moduleName,
      totalErrors: _errors.length,
      errorsLast24Hours: last24Hours,
      errorsLastHour: lastHour,
      errorTypeCounts: errorTypeCounts,
      firstErrorTime: _errors.first.timestamp,
      lastErrorTime: _errors.last.timestamp,
    );
  }

  void cleanup(DateTime cutoffTime) {
    _errors.removeWhere((e) => e.timestamp.isBefore(cutoffTime));
  }

  bool get isEmpty => _errors.isEmpty;
}

/// 오류 통계
class ErrorStatistics {
  final String moduleName;
  final int totalErrors;
  final int errorsLast24Hours;
  final int errorsLastHour;
  final Map<ErrorType, int> errorTypeCounts;
  final DateTime? firstErrorTime;
  final DateTime? lastErrorTime;

  ErrorStatistics({
    required this.moduleName,
    required this.totalErrors,
    required this.errorsLast24Hours,
    required this.errorsLastHour,
    required this.errorTypeCounts,
    this.firstErrorTime,
    this.lastErrorTime,
  });

  factory ErrorStatistics.empty(String moduleName) {
    return ErrorStatistics(
      moduleName: moduleName,
      totalErrors: 0,
      errorsLast24Hours: 0,
      errorsLastHour: 0,
      errorTypeCounts: {},
    );
  }

  double get errorRate24Hours => errorsLast24Hours / 24.0;
  double get errorRateLastHour => errorsLastHour / 1.0;

  Map<String, dynamic> toMap() {
    return {
      'module_name': moduleName,
      'total_errors': totalErrors,
      'errors_last_24_hours': errorsLast24Hours,
      'errors_last_hour': errorsLastHour,
      'error_rate_24_hours': errorRate24Hours,
      'error_rate_last_hour': errorRateLastHour,
      'error_type_counts':
          errorTypeCounts.map((k, v) => MapEntry(k.toString(), v)),
      'first_error_time': firstErrorTime?.toIso8601String(),
      'last_error_time': lastErrorTime?.toIso8601String(),
    };
  }
}

/// 회로 차단기 상태
class CircuitBreakerState {
  final String moduleName;
  CircuitState state = CircuitState.closed;
  int consecutiveFailures = 0;
  DateTime lastFailureTime = DateTime.now();

  CircuitBreakerState(this.moduleName);

  Map<String, dynamic> toMap() {
    return {
      'module_name': moduleName,
      'state': state.toString(),
      'consecutive_failures': consecutiveFailures,
      'last_failure_time': lastFailureTime.toIso8601String(),
    };
  }
}

/// 회로 상태
enum CircuitState {
  closed, // 정상
  open, // 차단됨
  halfOpen, // 반열림
}

/// 오류 타입
enum ErrorType {
  timeout,
  resourceExhaustion,
  network,
  validation,
  state,
  circuitBreakerOpen,
  unknown,
}

/// 오류 복구 이벤트
abstract class ErrorRecoveryEvent {
  final DateTime timestamp;

  ErrorRecoveryEvent() : timestamp = DateTime.now();

  static ErrorRecoveryEvent executionStarted(
          ErrorRecoveryExecution execution) =>
      ExecutionStartedEvent(execution);
  static ErrorRecoveryEvent executionSucceeded(
          ErrorRecoveryExecution execution) =>
      ExecutionSucceededEvent(execution);
  static ErrorRecoveryEvent executionFailed(ErrorRecoveryExecution execution) =>
      ExecutionFailedEvent(execution);
  static ErrorRecoveryEvent strategyApplied(
          ErrorRecoveryExecution execution, String strategyName) =>
      StrategyAppliedEvent(execution, strategyName);
  static ErrorRecoveryEvent strategySucceeded(
          ErrorRecoveryExecution execution, String strategyName) =>
      StrategySucceededEvent(execution, strategyName);
  static ErrorRecoveryEvent strategyFailed(ErrorRecoveryExecution execution,
          String strategyName, Object error) =>
      StrategyFailedEvent(execution, strategyName, error);
  static ErrorRecoveryEvent circuitBreakerOpened(String moduleName) =>
      CircuitBreakerOpenedEvent(moduleName);
  static ErrorRecoveryEvent circuitBreakerReset(String moduleName) =>
      CircuitBreakerResetEvent(moduleName);
}

class ExecutionStartedEvent extends ErrorRecoveryEvent {
  final ErrorRecoveryExecution execution;
  ExecutionStartedEvent(this.execution);
}

class ExecutionSucceededEvent extends ErrorRecoveryEvent {
  final ErrorRecoveryExecution execution;
  ExecutionSucceededEvent(this.execution);
}

class ExecutionFailedEvent extends ErrorRecoveryEvent {
  final ErrorRecoveryExecution execution;
  ExecutionFailedEvent(this.execution);
}

class StrategyAppliedEvent extends ErrorRecoveryEvent {
  final ErrorRecoveryExecution execution;
  final String strategyName;
  StrategyAppliedEvent(this.execution, this.strategyName);
}

class StrategySucceededEvent extends ErrorRecoveryEvent {
  final ErrorRecoveryExecution execution;
  final String strategyName;
  StrategySucceededEvent(this.execution, this.strategyName);
}

class StrategyFailedEvent extends ErrorRecoveryEvent {
  final ErrorRecoveryExecution execution;
  final String strategyName;
  final Object error;
  StrategyFailedEvent(this.execution, this.strategyName, this.error);
}

class CircuitBreakerOpenedEvent extends ErrorRecoveryEvent {
  final String moduleName;
  CircuitBreakerOpenedEvent(this.moduleName);
}

class CircuitBreakerResetEvent extends ErrorRecoveryEvent {
  final String moduleName;
  CircuitBreakerResetEvent(this.moduleName);
}

/// 오류 복구 리스너
abstract class ErrorRecoveryListener {
  void onEvent(ErrorRecoveryEvent event);
}

/// 모듈 실행 예외
class ModuleExecutionException implements Exception {
  final String message;
  final String? moduleName;
  final ErrorType errorType;
  final Object? cause;

  ModuleExecutionException(
    this.message, {
    this.moduleName,
    this.errorType = ErrorType.unknown,
    this.cause,
  });

  @override
  String toString() {
    final buffer = StringBuffer('ModuleExecutionException: $message');
    if (moduleName != null) {
      buffer.write(' (module: $moduleName)');
    }
    if (cause != null) {
      buffer.write('\nCaused by: $cause');
    }
    return buffer.toString();
  }
}

/// 복구 실패 예외
class RecoveryFailedException implements Exception {
  final String message;
  final String? moduleName;
  final List<String>? appliedStrategies;
  final Map<String, Object>? strategyErrors;
  final Object? originalError;

  RecoveryFailedException(
    this.message, {
    this.moduleName,
    this.appliedStrategies,
    this.strategyErrors,
    this.originalError,
  });

  @override
  String toString() {
    final buffer = StringBuffer('RecoveryFailedException: $message');
    if (moduleName != null) {
      buffer.write(' (module: $moduleName)');
    }
    if (appliedStrategies != null && appliedStrategies!.isNotEmpty) {
      buffer.write('\nApplied strategies: ${appliedStrategies!.join(", ")}');
    }
    if (originalError != null) {
      buffer.write('\nOriginal error: $originalError');
    }
    return buffer.toString();
  }
}

/// 재시도 소진 예외
class RetryExhaustedException implements Exception {
  final String message;
  final String? moduleName;
  final int attempts;
  final Object? lastError;

  RetryExhaustedException(
    this.message, {
    this.moduleName,
    required this.attempts,
    this.lastError,
  });

  @override
  String toString() {
    final buffer = StringBuffer('RetryExhaustedException: $message');
    if (moduleName != null) {
      buffer.write(' (module: $moduleName)');
    }
    buffer.write(' (attempts: $attempts)');
    if (lastError != null) {
      buffer.write('\nLast error: $lastError');
    }
    return buffer.toString();
  }
}

/// 회로 차단기 열림 예외
class CircuitBreakerOpenException implements Exception {
  final String message;
  final String? moduleName;

  CircuitBreakerOpenException(this.message, {this.moduleName});

  @override
  String toString() {
    final buffer = StringBuffer('CircuitBreakerOpenException: $message');
    if (moduleName != null) {
      buffer.write(' (module: $moduleName)');
    }
    return buffer.toString();
  }
}
