/// 성능 메트릭 수집기
///
/// 분석 파이프라인의 다양한 성능 지표를 수집하고 관리합니다.
class AnalysisMetrics {
  // 요청 카운터
  static int _requestCounter = 0;
  static void incrementRequestCounter() => _requestCounter++;
  static int get requestCounter => _requestCounter;

  // 처리 시간 (히스토그램 대신 간단한 평균 및 최대값)
  static final List<int> _processingDurations = [];
  static void recordProcessingDuration(int durationMs) => _processingDurations.add(durationMs);
  static double get averageProcessingDuration => _processingDurations.isEmpty ? 0.0 : _processingDurations.reduce((a, b) => a + b) / _processingDurations.length;
  static int get maxProcessingDuration => _processingDurations.isEmpty ? 0 : _processingDurations.reduce((a, b) => a > b ? a : b);

  // 캐시 히트율 (InMemoryCache에서 통계 가져옴)
  static double _cacheHitRate = 0.0;
  static void updateCacheHitRate(double rate) => _cacheHitRate = rate;
  static double get cacheHitRate => _cacheHitRate;

  // 모듈 실행 시간 (모듈별로 기록)
  static final Map<String, List<int>> _moduleExecutionTimes = {};
  static void recordModuleExecutionTime(String moduleName, int durationMs) {
    _moduleExecutionTimes.putIfAbsent(moduleName, () => []).add(durationMs);
  }
  static Map<String, double> get averageModuleExecutionTimes {
    final Map<String, double> avgTimes = {};
    _moduleExecutionTimes.forEach((moduleName, durations) {
      avgTimes[moduleName] = durations.isEmpty ? 0.0 : durations.reduce((a, b) => a + b) / durations.length;
    });
    return avgTimes;
  }

  // 오류 카운터
  static int _errorCounter = 0;
  static void incrementErrorCounter() => _errorCounter++;
  static int get errorCounter => _errorCounter;

  /// 모든 메트릭을 초기화합니다.
  static void resetAll() {
    _requestCounter = 0;
    _processingDurations.clear();
    _cacheHitRate = 0.0;
    _moduleExecutionTimes.clear();
    _errorCounter = 0;
  }

  /// 현재 모든 메트릭 상태를 Map 형태로 반환합니다.
  static Map<String, dynamic> getAllMetrics() {
    return {
      'request_counter': requestCounter,
      'average_processing_duration_ms': averageProcessingDuration,
      'max_processing_duration_ms': maxProcessingDuration,
      'cache_hit_rate': cacheHitRate,
      'average_module_execution_times_ms': averageModuleExecutionTimes,
      'error_counter': errorCounter,
    };
  }
}