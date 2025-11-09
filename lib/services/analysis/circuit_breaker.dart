/// 회로 차단기 상태
enum CircuitState {
  closed, // 정상 상태: 모든 요청 허용
  open,   // 차단 상태: 모든 요청 거부, 일정 시간 후 halfOpen으로 전환
  halfOpen, // 절반 개방 상태: 제한된 요청 허용, 성공 시 closed, 실패 시 open
}

/// 회로 차단기 예외
class CircuitBreakerOpenException implements Exception {
  final String message;
  CircuitBreakerOpenException([this.message = 'Circuit breaker is open.']);

  @override
  String toString() => 'CircuitBreakerOpenException: $message';
}

/// 회로 차단기 구현
///
/// 시스템의 안정성을 높이기 위해 실패한 서비스 호출을 자동으로 차단하고,
/// 서비스가 복구될 시간을 제공한 후 다시 시도합니다.
class CircuitBreaker {
  CircuitState _state = CircuitState.closed;
  int _failureCount = 0;
  DateTime? _lastFailureTime;
  final int _failureThreshold; // 차단기로 전환될 실패 횟수
  final Duration _resetTimeout; // 차단기가 open 상태에서 halfOpen으로 전환될 시간

  CircuitBreaker({
    int failureThreshold = 5,
    Duration resetTimeout = const Duration(seconds: 30),
  })  : _failureThreshold = failureThreshold,
        _resetTimeout = resetTimeout;

  /// 현재 회로 차단기의 상태를 반환합니다.
  CircuitState get state => _state;

  /// 작업을 실행합니다.
  ///
  /// 회로 차단기 상태에 따라 작업을 허용하거나 거부합니다.
  Future<T> execute<T>(Future<T> Function() operation) async {
    if (_state == CircuitState.open) {
      if (_shouldAttemptReset()) {
        _state = CircuitState.halfOpen;
      } else {
        throw CircuitBreakerOpenException();
      }
    }

    try {
      final result = await operation();
      _onSuccess();
      return result;
    } catch (e) {
      _onFailure();
      rethrow;
    }
  }

  /// 작업 성공 시 호출됩니다.
  void _onSuccess() {
    _failureCount = 0;
    _state = CircuitState.closed;
    _lastFailureTime = null;
  }

  /// 작업 실패 시 호출됩니다.
  void _onFailure() {
    _failureCount++;
    _lastFailureTime = DateTime.now();
    if (_failureCount >= _failureThreshold) {
      _state = CircuitState.open;
      print('회로 차단기 OPEN: 실패 횟수 임계치 도달 (${_failureCount}/${_failureThreshold})');
    }
  }

  /// open 상태에서 halfOpen으로 전환할 시점인지 확인합니다.
  bool _shouldAttemptReset() {
    return _lastFailureTime != null &&
        DateTime.now().isAfter(_lastFailureTime!.add(_resetTimeout));
  }

  /// 회로 차단기를 강제로 닫습니다. (테스트 또는 수동 복구용)
  void reset() {
    _failureCount = 0;
    _state = CircuitState.closed;
    _lastFailureTime = null;
  }
}