import 'dart:convert'; // JSON 인코딩을 위해 필요

/// 로그 레벨
enum LogLevel {
  debug,
  info,
  warn,
  error,
  fatal,
}

/// 로거 서비스
///
/// 분석 파이프라인의 활동, 오류 및 성능 데이터를 기록합니다.
class LoggerService {
  final LogLevel _minLogLevel; // 최소 로깅 레벨

  LoggerService({this._minLogLevel = LogLevel.info});

  /// 로그 메시지를 기록합니다.
  ///
  /// [level] 로그 레벨
  /// [message] 로그 메시지
  /// [context] 추가 컨텍스트 정보 (예: 요청 ID, 모듈 이름)
  /// [error] 관련 오류 객체
  /// [stackTrace] 스택 트레이스
  void log(
    LogLevel level,
    String message, {
    Map<String, dynamic>? context,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (level.index < _minLogLevel.index) {
      return; // 설정된 최소 레벨보다 낮은 로그는 기록하지 않음
    }

    final logEntry = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'level': level.toString().split('.').last.toUpperCase(),
      'message': message,
    };

    if (context != null) {
      logEntry['context'] = context;
    }
    if (error != null) {
      logEntry['error'] = error.toString();
    }
    if (stackTrace != null) {
      logEntry['stackTrace'] = stackTrace.toString();
    }

    // JSON 형태로 출력 (실제 환경에서는 파일, 콘솔, 원격 서버 등으로 전송)
    print(jsonEncode(logEntry));

    // TODO: AnalysisMetadata의 logEntries에 추가하는 로직은 AnalysisPipelineEngine에서 LoggerService를 사용하여 구현
  }

  void debug(String message, {Map<String, dynamic>? context, dynamic error, StackTrace? stackTrace}) {
    log(LogLevel.debug, message, context: context, error: error, stackTrace: stackTrace);
  }

  void info(String message, {Map<String, dynamic>? context, dynamic error, StackTrace? stackTrace}) {
    log(LogLevel.info, message, context: context, error: error, stackTrace: stackTrace);
  }

  void warn(String message, {Map<String, dynamic>? context, dynamic error, StackTrace? stackTrace}) {
    log(LogLevel.warn, message, context: context, error: error, stackTrace: stackTrace);
  }

  void error(String message, {Map<String, dynamic>? context, dynamic error, StackTrace? stackTrace}) {
    log(LogLevel.error, message, context: context, error: error, stackTrace: stackTrace);
  }

  void fatal(String message, {Map<String, dynamic>? context, dynamic error, StackTrace? stackTrace}) {
    log(LogLevel.fatal, message, context: context, error: error, stackTrace: stackTrace);
  }
}