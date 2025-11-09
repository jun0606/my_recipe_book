/// 분석 메타데이터를 나타내는 모델 클래스
///
/// 분석 과정에서 수집되는 성능 메트릭, 디버깅 정보,
/// 실행 통계 등을 포함합니다.
class AnalysisMetadata {
  /// 요청 ID
  final String requestId;

  /// 분석 시작 시간
  final DateTime startTime;

  /// 분석 종료 시간
  final DateTime endTime;

  /// 총 처리 시간 (밀리초)
  final int processingTime;

  /// 실행된 모듈 목록과 각각의 실행 시간
  final Map<String, int> moduleExecutionTimes;

  /// 메모리 사용량 정보
  final MemoryUsageInfo memoryUsage;

  /// 캐시 사용 통계
  final CacheStatistics cacheStats;

  /// 오류 및 경고 로그
  final List<LogEntry> logs;

  /// 성능 메트릭
  final PerformanceMetrics performance;

  /// 디버그 정보 (디버그 모드에서만)
  final Map<String, dynamic> debugInfo;

  /// 분석 버전 정보
  final String analysisVersion;

  /// 시스템 정보
  final SystemInfo systemInfo;

  const AnalysisMetadata({
    required this.requestId,
    required this.startTime,
    required this.endTime,
    required this.processingTime,
    required this.moduleExecutionTimes,
    required this.memoryUsage,
    required this.cacheStats,
    required this.logs,
    required this.performance,
    this.debugInfo = const {},
    this.analysisVersion = '1.0.0',
    required this.systemInfo,
  });

  /// 빈 메타데이터 생성 (오류 시 사용)
  factory AnalysisMetadata.empty(String requestId) {
    final now = DateTime.now();
    return AnalysisMetadata(
      requestId: requestId,
      startTime: now,
      endTime: now,
      processingTime: 0,
      moduleExecutionTimes: {},
      memoryUsage: MemoryUsageInfo.empty(),
      cacheStats: CacheStatistics.empty(),
      logs: [],
      performance: PerformanceMetrics.empty(),
      systemInfo: SystemInfo.current(),
    );
  }

  /// 분석 시작 시 메타데이터 생성
  factory AnalysisMetadata.start(String requestId) {
    final now = DateTime.now();
    return AnalysisMetadata(
      requestId: requestId,
      startTime: now,
      endTime: now, // 임시값, 완료 시 업데이트
      processingTime: 0,
      moduleExecutionTimes: {},
      memoryUsage: MemoryUsageInfo.current(),
      cacheStats: CacheStatistics.empty(),
      logs: [],
      performance: PerformanceMetrics.empty(),
      systemInfo: SystemInfo.current(),
    );
  }

  /// 분석 완료 시 메타데이터 업데이트
  AnalysisMetadata complete({
    required Map<String, int> moduleExecutionTimes,
    required List<LogEntry> logs,
    required CacheStatistics cacheStats,
    Map<String, dynamic> debugInfo = const {},
  }) {
    final endTime = DateTime.now();
    final processingTime = endTime.difference(startTime).inMilliseconds;

    return AnalysisMetadata(
      requestId: requestId,
      startTime: startTime,
      endTime: endTime,
      processingTime: processingTime,
      moduleExecutionTimes: moduleExecutionTimes,
      memoryUsage: MemoryUsageInfo.current(),
      cacheStats: cacheStats,
      logs: logs,
      performance: PerformanceMetrics.calculate(
        processingTime: processingTime,
        moduleExecutionTimes: moduleExecutionTimes,
        memoryUsage: MemoryUsageInfo.current(),
      ),
      debugInfo: debugInfo,
      analysisVersion: analysisVersion,
      systemInfo: systemInfo,
    );
  }

  /// 가장 오래 걸린 모듈 반환
  String? get slowestModule {
    if (moduleExecutionTimes.isEmpty) return null;

    return moduleExecutionTimes.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// 가장 빠른 모듈 반환
  String? get fastestModule {
    if (moduleExecutionTimes.isEmpty) return null;

    return moduleExecutionTimes.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;
  }

  /// 평균 모듈 실행 시간 계산
  double get averageModuleExecutionTime {
    if (moduleExecutionTimes.isEmpty) return 0.0;

    final total = moduleExecutionTimes.values.reduce((a, b) => a + b);
    return total / moduleExecutionTimes.length;
  }

  /// 오류 로그 개수
  int get errorCount => logs.where((log) => log.level == LogLevel.error).length;

  /// 경고 로그 개수
  int get warningCount =>
      logs.where((log) => log.level == LogLevel.warning).length;

  /// 성능 등급 계산
  String get performanceGrade {
    if (processingTime <= 5000) return 'A'; // 5초 이내
    if (processingTime <= 15000) return 'B'; // 15초 이내
    if (processingTime <= 30000) return 'C'; // 30초 이내
    return 'D'; // 30초 초과
  }

  /// 메모리 효율성 등급 계산
  String get memoryEfficiencyGrade {
    final peakMB = memoryUsage.peakUsage / (1024 * 1024);
    if (peakMB <= 50) return 'A';
    if (peakMB <= 100) return 'B';
    if (peakMB <= 200) return 'C';
    return 'D';
  }

  /// JSON으로 직렬화
  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'processingTime': processingTime,
      'moduleExecutionTimes': moduleExecutionTimes,
      'memoryUsage': memoryUsage.toJson(),
      'cacheStats': cacheStats.toJson(),
      'logs': logs.map((log) => log.toJson()).toList(),
      'performance': performance.toJson(),
      'debugInfo': debugInfo,
      'analysisVersion': analysisVersion,
      'systemInfo': systemInfo.toJson(),
    };
  }

  /// JSON에서 역직렬화
  factory AnalysisMetadata.fromJson(Map<String, dynamic> json) {
    return AnalysisMetadata(
      requestId: json['requestId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      processingTime: json['processingTime'] as int,
      moduleExecutionTimes:
          Map<String, int>.from(json['moduleExecutionTimes'] as Map),
      memoryUsage:
          MemoryUsageInfo.fromJson(json['memoryUsage'] as Map<String, dynamic>),
      cacheStats:
          CacheStatistics.fromJson(json['cacheStats'] as Map<String, dynamic>),
      logs: (json['logs'] as List)
          .map((log) => LogEntry.fromJson(log as Map<String, dynamic>))
          .toList(),
      performance: PerformanceMetrics.fromJson(
          json['performance'] as Map<String, dynamic>),
      debugInfo: json['debugInfo'] as Map<String, dynamic>? ?? {},
      analysisVersion: json['analysisVersion'] as String? ?? '1.0.0',
      systemInfo:
          SystemInfo.fromJson(json['systemInfo'] as Map<String, dynamic>),
    );
  }

  @override
  String toString() {
    return 'AnalysisMetadata('
        'requestId: $requestId, '
        'processingTime: ${processingTime}ms, '
        'modules: ${moduleExecutionTimes.length}, '
        'grade: $performanceGrade, '
        'errors: $errorCount, '
        'warnings: $warningCount'
        ')';
  }
}

/// 메모리 사용량 정보
class MemoryUsageInfo {
  /// 시작 시 메모리 사용량 (바이트)
  final int initialUsage;

  /// 최대 메모리 사용량 (바이트)
  final int peakUsage;

  /// 종료 시 메모리 사용량 (바이트)
  final int finalUsage;

  /// 메모리 사용량 변화 (바이트)
  final int memoryDelta;

  const MemoryUsageInfo({
    required this.initialUsage,
    required this.peakUsage,
    required this.finalUsage,
    required this.memoryDelta,
  });

  /// 빈 메모리 정보 생성
  factory MemoryUsageInfo.empty() {
    return const MemoryUsageInfo(
      initialUsage: 0,
      peakUsage: 0,
      finalUsage: 0,
      memoryDelta: 0,
    );
  }

  /// 현재 메모리 정보 생성 (실제 구현에서는 플랫폼별 메모리 측정 필요)
  factory MemoryUsageInfo.current() {
    // 실제 구현에서는 dart:io의 ProcessInfo 등을 사용
    final currentUsage = 50 * 1024 * 1024; // 50MB (예시)
    return MemoryUsageInfo(
      initialUsage: currentUsage,
      peakUsage: currentUsage,
      finalUsage: currentUsage,
      memoryDelta: 0,
    );
  }

  /// 메모리 사용량을 MB 단위로 반환
  double get initialUsageMB => initialUsage / (1024 * 1024);
  double get peakUsageMB => peakUsage / (1024 * 1024);
  double get finalUsageMB => finalUsage / (1024 * 1024);
  double get memoryDeltaMB => memoryDelta / (1024 * 1024);

  /// JSON으로 직렬화
  Map<String, dynamic> toJson() {
    return {
      'initialUsage': initialUsage,
      'peakUsage': peakUsage,
      'finalUsage': finalUsage,
      'memoryDelta': memoryDelta,
    };
  }

  /// JSON에서 역직렬화
  factory MemoryUsageInfo.fromJson(Map<String, dynamic> json) {
    return MemoryUsageInfo(
      initialUsage: json['initialUsage'] as int,
      peakUsage: json['peakUsage'] as int,
      finalUsage: json['finalUsage'] as int,
      memoryDelta: json['memoryDelta'] as int,
    );
  }

  @override
  String toString() {
    return 'Memory: ${peakUsageMB.toStringAsFixed(1)}MB peak, '
        '${memoryDeltaMB.toStringAsFixed(1)}MB delta';
  }
}

/// 캐시 통계 정보
class CacheStatistics {
  /// 캐시 히트 횟수
  final int hits;

  /// 캐시 미스 횟수
  final int misses;

  /// 캐시에서 가져온 데이터 크기 (바이트)
  final int bytesFromCache;

  /// 캐시에 저장한 데이터 크기 (바이트)
  final int bytesToCache;

  /// 캐시 작업 시간 (밀리초)
  final int cacheOperationTime;

  const CacheStatistics({
    required this.hits,
    required this.misses,
    required this.bytesFromCache,
    required this.bytesToCache,
    required this.cacheOperationTime,
  });

  /// 빈 캐시 통계 생성
  factory CacheStatistics.empty() {
    return const CacheStatistics(
      hits: 0,
      misses: 0,
      bytesFromCache: 0,
      bytesToCache: 0,
      cacheOperationTime: 0,
    );
  }

  /// 캐시 히트율 계산 (0-1)
  double get hitRate {
    final total = hits + misses;
    return total > 0 ? hits / total : 0.0;
  }

  /// 캐시 미스율 계산 (0-1)
  double get missRate => 1.0 - hitRate;

  /// 캐시 효율성 등급
  String get efficiencyGrade {
    if (hitRate >= 0.9) return 'A';
    if (hitRate >= 0.8) return 'B';
    if (hitRate >= 0.7) return 'C';
    return 'D';
  }

  /// JSON으로 직렬화
  Map<String, dynamic> toJson() {
    return {
      'hits': hits,
      'misses': misses,
      'bytesFromCache': bytesFromCache,
      'bytesToCache': bytesToCache,
      'cacheOperationTime': cacheOperationTime,
    };
  }

  /// JSON에서 역직렬화
  factory CacheStatistics.fromJson(Map<String, dynamic> json) {
    return CacheStatistics(
      hits: json['hits'] as int,
      misses: json['misses'] as int,
      bytesFromCache: json['bytesFromCache'] as int,
      bytesToCache: json['bytesToCache'] as int,
      cacheOperationTime: json['cacheOperationTime'] as int,
    );
  }

  @override
  String toString() {
    return 'Cache: ${(hitRate * 100).toStringAsFixed(1)}% hit rate, '
        '$hits hits, $misses misses';
  }
}

/// 로그 엔트리
class LogEntry {
  /// 로그 레벨
  final LogLevel level;

  /// 로그 메시지
  final String message;

  /// 로그 생성 시간
  final DateTime timestamp;

  /// 모듈 이름 (선택적)
  final String? moduleName;

  /// 추가 컨텍스트 정보
  final Map<String, dynamic> context;

  const LogEntry({
    required this.level,
    required this.message,
    required this.timestamp,
    this.moduleName,
    this.context = const {},
  });

  /// 팩토리 생성자들
  factory LogEntry.debug(String message,
      {String? moduleName, Map<String, dynamic>? context}) {
    return LogEntry(
      level: LogLevel.debug,
      message: message,
      timestamp: DateTime.now(),
      moduleName: moduleName,
      context: context ?? {},
    );
  }

  factory LogEntry.info(String message,
      {String? moduleName, Map<String, dynamic>? context}) {
    return LogEntry(
      level: LogLevel.info,
      message: message,
      timestamp: DateTime.now(),
      moduleName: moduleName,
      context: context ?? {},
    );
  }

  factory LogEntry.warning(String message,
      {String? moduleName, Map<String, dynamic>? context}) {
    return LogEntry(
      level: LogLevel.warning,
      message: message,
      timestamp: DateTime.now(),
      moduleName: moduleName,
      context: context ?? {},
    );
  }

  factory LogEntry.error(String message,
      {String? moduleName, Map<String, dynamic>? context}) {
    return LogEntry(
      level: LogLevel.error,
      message: message,
      timestamp: DateTime.now(),
      moduleName: moduleName,
      context: context ?? {},
    );
  }

  /// JSON으로 직렬화
  Map<String, dynamic> toJson() {
    return {
      'level': level.name,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'moduleName': moduleName,
      'context': context,
    };
  }

  /// JSON에서 역직렬화
  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      level: LogLevel.values.firstWhere((l) => l.name == json['level'],
          orElse: () => LogLevel.info),
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      moduleName: json['moduleName'] as String?,
      context: json['context'] as Map<String, dynamic>? ?? {},
    );
  }

  @override
  String toString() {
    final modulePrefix = moduleName != null ? '[$moduleName] ' : '';
    return '${timestamp.toIso8601String()} ${level.name.toUpperCase()}: $modulePrefix$message';
  }
}

/// 로그 레벨
enum LogLevel {
  debug,
  info,
  warning,
  error;

  /// 심각도 점수 (높을수록 심각)
  int get severity {
    switch (this) {
      case debug:
        return 1;
      case info:
        return 2;
      case warning:
        return 3;
      case error:
        return 4;
    }
  }
}

/// 성능 메트릭
class PerformanceMetrics {
  /// 처리량 (초당 처리 항목 수)
  final double throughput;

  /// 평균 응답 시간 (밀리초)
  final double averageResponseTime;

  /// 95퍼센타일 응답 시간 (밀리초)
  final double p95ResponseTime;

  /// CPU 사용률 (0-1)
  final double cpuUsage;

  /// 메모리 효율성 점수 (0-100)
  final double memoryEfficiency;

  /// 전체 성능 점수 (0-100)
  final double overallScore;

  const PerformanceMetrics({
    required this.throughput,
    required this.averageResponseTime,
    required this.p95ResponseTime,
    required this.cpuUsage,
    required this.memoryEfficiency,
    required this.overallScore,
  });

  /// 빈 성능 메트릭 생성
  factory PerformanceMetrics.empty() {
    return const PerformanceMetrics(
      throughput: 0.0,
      averageResponseTime: 0.0,
      p95ResponseTime: 0.0,
      cpuUsage: 0.0,
      memoryEfficiency: 0.0,
      overallScore: 0.0,
    );
  }

  /// 성능 메트릭 계산
  factory PerformanceMetrics.calculate({
    required int processingTime,
    required Map<String, int> moduleExecutionTimes,
    required MemoryUsageInfo memoryUsage,
  }) {
    // 처리량 계산 (모듈 수 / 처리 시간)
    final throughput = moduleExecutionTimes.isNotEmpty
        ? (moduleExecutionTimes.length / (processingTime / 1000.0))
        : 0.0;

    // 평균 응답 시간
    final averageResponseTime = moduleExecutionTimes.isNotEmpty
        ? moduleExecutionTimes.values.reduce((a, b) => a + b) /
            moduleExecutionTimes.length.toDouble()
        : 0.0;

    // 95퍼센타일 계산 (간단한 근사치)
    final sortedTimes = moduleExecutionTimes.values.toList()..sort();
    final p95ResponseTime = sortedTimes.isNotEmpty
        ? sortedTimes[(sortedTimes.length * 0.95).floor()].toDouble()
        : 0.0;

    // CPU 사용률 (추정치)
    final cpuUsage =
        processingTime > 0 ? (processingTime / 30000.0).clamp(0.0, 1.0) : 0.0;

    // 메모리 효율성 (메모리 사용량이 적을수록 높은 점수)
    final memoryEfficiency = memoryUsage.peakUsageMB > 0
        ? (100.0 - (memoryUsage.peakUsageMB / 2.0)).clamp(0.0, 100.0)
        : 100.0;

    // 전체 성능 점수 계산
    final timeScore = processingTime <= 10000
        ? 100.0
        : (100.0 - (processingTime - 10000) / 1000.0).clamp(0.0, 100.0);
    final overallScore = (timeScore * 0.4 +
        memoryEfficiency * 0.3 +
        (100.0 - cpuUsage * 100.0) * 0.3);

    return PerformanceMetrics(
      throughput: throughput,
      averageResponseTime: averageResponseTime,
      p95ResponseTime: p95ResponseTime,
      cpuUsage: cpuUsage,
      memoryEfficiency: memoryEfficiency,
      overallScore: overallScore,
    );
  }

  /// JSON으로 직렬화
  Map<String, dynamic> toJson() {
    return {
      'throughput': throughput,
      'averageResponseTime': averageResponseTime,
      'p95ResponseTime': p95ResponseTime,
      'cpuUsage': cpuUsage,
      'memoryEfficiency': memoryEfficiency,
      'overallScore': overallScore,
    };
  }

  /// JSON에서 역직렬화
  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      throughput: (json['throughput'] as num).toDouble(),
      averageResponseTime: (json['averageResponseTime'] as num).toDouble(),
      p95ResponseTime: (json['p95ResponseTime'] as num).toDouble(),
      cpuUsage: (json['cpuUsage'] as num).toDouble(),
      memoryEfficiency: (json['memoryEfficiency'] as num).toDouble(),
      overallScore: (json['overallScore'] as num).toDouble(),
    );
  }

  @override
  String toString() {
    return 'Performance: ${overallScore.toStringAsFixed(1)}/100, '
        'Avg: ${averageResponseTime.toStringAsFixed(0)}ms, '
        'Memory: ${memoryEfficiency.toStringAsFixed(1)}%';
  }
}

/// 시스템 정보
class SystemInfo {
  /// 운영체제
  final String operatingSystem;

  /// 플랫폼 버전
  final String platformVersion;

  /// Dart 버전
  final String dartVersion;

  /// 사용 가능한 메모리 (바이트)
  final int availableMemory;

  /// CPU 코어 수
  final int cpuCores;

  /// 시스템 로케일
  final String locale;

  const SystemInfo({
    required this.operatingSystem,
    required this.platformVersion,
    required this.dartVersion,
    required this.availableMemory,
    required this.cpuCores,
    required this.locale,
  });

  /// 현재 시스템 정보 생성
  factory SystemInfo.current() {
    // 실제 구현에서는 dart:io의 Platform 클래스 사용
    return const SystemInfo(
      operatingSystem: 'Unknown',
      platformVersion: '1.0.0',
      dartVersion: '3.0.0',
      availableMemory: 8 * 1024 * 1024 * 1024, // 8GB
      cpuCores: 4,
      locale: 'ko_KR',
    );
  }

  /// JSON으로 직렬화
  Map<String, dynamic> toJson() {
    return {
      'operatingSystem': operatingSystem,
      'platformVersion': platformVersion,
      'dartVersion': dartVersion,
      'availableMemory': availableMemory,
      'cpuCores': cpuCores,
      'locale': locale,
    };
  }

  /// JSON에서 역직렬화
  factory SystemInfo.fromJson(Map<String, dynamic> json) {
    return SystemInfo(
      operatingSystem: json['operatingSystem'] as String,
      platformVersion: json['platformVersion'] as String,
      dartVersion: json['dartVersion'] as String,
      availableMemory: json['availableMemory'] as int,
      cpuCores: json['cpuCores'] as int,
      locale: json['locale'] as String,
    );
  }

  @override
  String toString() {
    return 'System: $operatingSystem, '
        'Memory: ${(availableMemory / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB, '
        'Cores: $cpuCores';
  }
}
