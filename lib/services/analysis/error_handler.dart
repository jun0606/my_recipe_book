import 'package:my_recipe_book/interfaces/analysis_module.dart';
import 'package:my_recipe_book/models/analysis_request.dart';
import 'package:my_recipe_book/models/analysis_result.dart';
import 'package:my_recipe_book/models/analysis_status.dart';
import 'package:my_recipe_book/models/analysis_metadata.dart'; // Import AnalysisMetadata
import 'package:my_recipe_book/services/analysis/circuit_breaker.dart'; // CircuitBreaker 의존성 추가

/// 오류 처리기
///
/// 분석 모듈 실행 중 발생하는 오류를 처리하고, 재시도 및 부분 실패 로직을 관리합니다.
class ErrorHandler {
  final int maxRetries; // 최대 재시도 횟수
  final CircuitBreaker _circuitBreaker; // 회로 차단기 인스턴스

  ErrorHandler({this.maxRetries = 3, CircuitBreaker? circuitBreaker})
      : _circuitBreaker = circuitBreaker ?? CircuitBreaker(); // 기본 CircuitBreaker 인스턴스 사용

  /// 모듈 실행 중 발생하는 오류를 처리합니다。
  Future<Map<String, dynamic>> handleModuleError(
    AnalysisModule module,
    dynamic error, // Exception 또는 Error 타입
    AnalysisRequest request,
    int currentAttempt,
  ) async {
    final moduleName = module.name;
    final errorMessage = error.toString();

    // 1. 오류 로깅
    print('오류 발생: 모듈 $moduleName, 오류: $errorMessage, 현재 시도: $currentAttempt');

    // CircuitBreaker가 open 상태이면 즉시 예외 반환
    if (_circuitBreaker.state == CircuitState.open) {
      return {
        'error': '회로 차단기가 열려있어 모듈 ${module.name} 실행을 중단합니다.',
        'status': AnalysisStatus.failed,
        'module_name': moduleName,
        'retry_needed': false,
      };
    }

    // 2. 재시도 로직
    if (_isRetryableError(error) && currentAttempt < maxRetries) {
      print('재시도: 모듈 $moduleName, ${currentAttempt + 1}번째 시도');
      await Future.delayed(Duration(seconds: 1 * currentAttempt)); // 지수 백오프
      // 재시도는 AnalysisPipelineEngine에서 직접 모듈을 다시 호출하도록 유도
      return {'retry_needed': true, 'error': errorMessage};
    }

    // 3. 부분 결과 반환 또는 오류 기록
    return {
      'error': errorMessage,
      'status': AnalysisStatus.failed,
      'module_name': moduleName,
      'retry_needed': false,
    };
  }

  /// 재시도 가능한 오류인지 판단합니다.
  bool _isRetryableError(dynamic error) {
    // 네트워크 오류, 타임아웃 등 일시적인 오류를 재시도 가능으로 판단
    // 실제 구현에서는 특정 예외 타입을 확인해야 함
    return error is AnalysisProcessingException || error is Exception; // 예시
  }

  /// AnalysisPipelineEngine에서 오류 발생 시 최종 결과에 반영하는 헬퍼 함수
  AnalysisResult createPartialFailureResult({
    required AnalysisRequest request,
    required String failedModuleName,
    required String errorMessage,
    Map<String, dynamic>? partialResults,
    List<String>? warnings,
  }) {
    return AnalysisResult(
      requestId: request.id,
      results: partialResults ?? {},
      recommendations: [],
      metadata: AnalysisMetadata.fromJson(request.metadata), // Changed to fromJson
      overallScore: 0.0,
      status: AnalysisStatus.partial_failure,
      errorMessage: '모듈 $failedModuleName 실행 중 오류 발생: $errorMessage',
      warnings: warnings ?? [],
      completedAt: DateTime.now(),
      fromCache: false,
    );
  }
}