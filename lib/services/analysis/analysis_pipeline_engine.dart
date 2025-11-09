import 'package:my_recipe_book/interfaces/analysis_module.dart';
import 'package:my_recipe_book/models/analysis_request.dart';
import 'package:my_recipe_book/models/analysis_result.dart';
import 'package:my_recipe_book/models/analysis_metadata.dart';
import 'package:my_recipe_book/models/analysis_status.dart';
import 'package:my_recipe_book/services/analysis/module_registry.dart';
import 'package:my_recipe_book/services/analysis/analysis_cache.dart'; // AnalysisCache 의존성 추가
import 'package:my_recipe_book/services/analysis/cache_key_generator.dart'; // CacheKeyGenerator 의존성 추가
import 'package:my_recipe_book/services/analysis/error_handler.dart'; // ErrorHandler 의존성 추가

/// 분석 파이프라인 엔진
///
/// 등록된 분석 모듈들을 조합하여 분석 요청을 처리하고 결과를 반환합니다.
class AnalysisPipelineEngine {
  final ModuleRegistry? _moduleRegistry;
  final AnalysisCache? _cache; // 캐시 의존성
  final CacheKeyGenerator? _cacheKeyGenerator; // 캐시 키 생성기 의존성
  final ErrorHandler? _errorHandler; // 오류 처리기 의존성

  /// AnalysisPipelineEngine의 생성자.
  /// 필요한 의존성들을 옵셔널하게 주입받습니다.
  AnalysisPipelineEngine([
    this._moduleRegistry,
    this._cache,
    this._cacheKeyGenerator,
    this._errorHandler,
  ]);

  /// 분석 요청을 처리하고 종합적인 분석 결과를 반환합니다.
  Future<AnalysisResult> analyze(AnalysisRequest request) async {
    final startTime = DateTime.now();
    final results = <String, dynamic>{};
    final warnings = <String>[];
    String? errorMessage;
    AnalysisStatus status = AnalysisStatus.pending;
    bool fromCache = false;
    String? cacheKey;

    try {
      // 1. 요청 유효성 검증
      if (!request.isValid()) {
        // Changed to request.isValid()
        throw ArgumentError('유효하지 않은 분석 요청입니다.');
      }

      // 2. 캐시 확인 (옵셔널 체크)
      if (_cacheKeyGenerator != null && _cache != null) {
        cacheKey = _cacheKeyGenerator?.generateCacheKey(request);
        if (cacheKey != null) {
          final cachedResult = await _cache?.get(cacheKey);
          if (cachedResult != null) {
            fromCache = true;
            status = AnalysisStatus.completed;
            return cachedResult.copyWith(fromCache: true); // 캐시된 결과 반환
          }
        }
      }

      // 3. 활성화된 모듈 목록 가져오기 (옵셔널 체크)
      final enabledModules =
          _moduleRegistry?.getEnabledModules(request.options.enabledModules) ??
              [];

      // 4. 모듈 실행 순서 결정 (의존성 및 우선순위 기반)
      final executionOrder =
          _moduleRegistry?.resolveExecutionOrder(enabledModules) ?? [];

      // 5. 각 모듈 실행
      for (final module in executionOrder) {
        if (module.canHandle(request)) {
          try {
            final moduleResult = await module.analyze(request);
            results[module.name] = moduleResult;
          } catch (e) {
            // 모든 예외를 일반적인 예외로 처리
            warnings.add('모듈 ${module.name} 처리 중 경고: $e');
            // 오류 처리기가 있는 경우 사용
            if (_errorHandler != null) {
              try {
                final errorResult = await _errorHandler?.handleModuleError(
                    module, e, request, 1); // 첫 시도
                if (errorResult?['retry_needed'] == true) {
                  errorMessage =
                      '모듈 ${module.name} 실행 중 재시도 필요: ${errorResult?['error']}';
                  status = AnalysisStatus.partial_failure;
                  warnings.add(errorMessage!);
                }
              } catch (handlerError) {
                // 오류 처리기 자체 오류는 무시하고 기본 처리
              }
            }
          }
        }
      }

      status = AnalysisStatus.completed;
    } catch (e) {
      errorMessage = '분석 파이프라인 실행 중 오류가 발생했습니다: $e';
      status = AnalysisStatus.failed;
    } finally {
      final completedAt = DateTime.now();
      final processingTime = completedAt
          .difference(startTime)
          .inMilliseconds; // Changed to processingTime

      final metadata = AnalysisMetadata(
        requestId: request.id, // Added requestId
        startTime: startTime, // Added startTime
        endTime: completedAt, // Added endTime
        processingTime: processingTime, // Changed to processingTime
        moduleExecutionTimes: {}, // Added moduleExecutionTimes
        memoryUsage:
            MemoryUsageInfo.empty(), // TODO: 메모리 사용량 추적 (Task 3.3 또는 4.1)
        cacheStats: CacheStatistics.empty(), // 캐시 통계 (빈 객체로 설정)
        logs: [], // TODO: 로깅 시스템 (Task 15)
        performance: PerformanceMetrics.empty(), // Added performance
        systemInfo: SystemInfo.current(), // Added systemInfo
      );

      final analysisResult = AnalysisResult(
        requestId: request.id,
        results: results,
        recommendations: [], // TODO: 추천 사항 생성 (RecipeAnalysisModule에서 생성)
        metadata: metadata,
        overallScore: 0.0, // TODO: 전체 점수 계산 (추후 모듈에서 통합)
        status: status,
        errorMessage: errorMessage,
        warnings: warnings,
        completedAt: completedAt,
        fromCache: fromCache,
      );

      // 분석 성공 시 결과 캐시에 저장
      if (status == AnalysisStatus.completed && cacheKey != null) {
        await _cache?.set(cacheKey!, analysisResult);
      }
      return analysisResult;
    }
  }
}
