import 'dart:async';
import 'dart:collection';
import 'package:my_recipe_book/interfaces/analysis_module.dart';
import 'package:my_recipe_book/models/analysis_request.dart';
import 'package:my_recipe_book/models/analysis_result.dart';
import 'package:my_recipe_book/models/analysis_metadata.dart';
import 'package:my_recipe_book/services/analysis/module_registry.dart';

/// 분석 파이프라인 실행 엔진
/// 
/// 여러 분석 모듈들을 조합하여 순차적 또는 병렬로 실행하고
/// 결과를 통합하여 반환하는 핵심 엔진입니다.
class AnalysisPipelineEngine {
  final ModuleRegistry _moduleRegistry;
  final Map<String, dynamic> _configuration;
  final List<PipelineExecutionListener> _listeners = [];
  
  // 실행 상태 관리
  bool _isRunning = false;
  String? _currentExecutionId;
  final Map<String, PipelineExecution> _activeExecutions = {};
  
  AnalysisPipelineEngine({
    required ModuleRegistry moduleRegistry,
    Map<String, dynamic>? configuration,
  }) : _moduleRegistry = moduleRegistry,
       _configuration = configuration ?? _getDefaultConfiguration();

  /// 기본 설정
  static Map<String, dynamic> _getDefaultConfiguration() {
    return {
      'max_concurrent_modules': 3,
      'execution_timeout_ms': 30000, // 30초
      'enable_parallel_execution': true,
      'enable_result_caching': true,
      'enable_performance_monitoring': true,
      'retry_failed_modules': true,
      'max_retry_attempts': 2,
      'partial_failure_threshold': 0.5, // 50% 이상 성공하면 부분 성공
    };
  }

  /// 파이프라인 실행
  Future<AnalysisResult> execute(AnalysisRequest request) async {
    final executionId = _generateExecutionId();
    _currentExecutionId = executionId;
    
    final execution = PipelineExecution(
      id: executionId,
      request: request,
      startTime: DateTime.now(),
    );
    
    _activeExecutions[executionId] = execution;
    _isRunning = true;
    
    try {
      _notifyListeners(PipelineEvent.started(executionId, request));
      
      // 1. 실행 가능한 모듈들 식별
      final availableModules = await _identifyAvailableModules(request);
      execution.availableModules = availableModules;
      
      if (availableModules.isEmpty) {
        throw PipelineExecutionException(
          '실행 가능한 분석 모듈이 없습니다.',
          executionId: executionId,
        );
      }
      
      // 2. 의존성 그래프 생성
      final dependencyGraph = _buildDependencyGraph(availableModules);
      execution.dependencyGraph = dependencyGraph;
      
      // 3. 실행 계획 수립
      final executionPlan = _createExecutionPlan(dependencyGraph, request);
      execution.executionPlan = executionPlan;
      
      _notifyListeners(PipelineEvent.planCreated(executionId, executionPlan));
      
      // 4. 모듈 실행
      final results = await _executeModules(execution);
      
      // 5. 결과 통합
      final finalResult = await _integrateResults(results, request, execution);
      
      execution.endTime = DateTime.now();
      execution.result = finalResult;
      
      _notifyListeners(PipelineEvent.completed(executionId, finalResult));
      
      return finalResult;
      
    } catch (e) {
      execution.endTime = DateTime.now();
      execution.error = e;
      
      _notifyListeners(PipelineEvent.failed(executionId, e));
      
      if (e is PipelineExecutionException) {
        rethrow;
      } else {
        throw PipelineExecutionException(
          '파이프라인 실행 중 오류가 발생했습니다: $e',
          executionId: executionId,
          cause: e is Exception ? e : Exception(e.toString()),
        );
      }
    } finally {
      _isRunning = false;
      _currentExecutionId = null;
      _activeExecutions.remove(executionId);
    }
  }

  /// 실행 가능한 모듈들 식별
  Future<List<BaseAnalysisModule>> _identifyAvailableModules(AnalysisRequest request) async {
    final allModules = _moduleRegistry.getAllModules();
    final availableModules = <BaseAnalysisModule>[];
    
    for (final module in allModules) {
      try {
        if (await module.canHandle(request)) {
          availableModules.add(module);
        }
      } catch (e) {
        // 모듈 확인 중 오류 발생 시 로그만 남기고 계속 진행
        print('모듈 ${module.name} 확인 중 오류: $e');
      }
    }
    
    // 우선순위 순으로 정렬
    availableModules.sort((a, b) => a.priority.compareTo(b.priority));
    
    return availableModules;
  }

  /// 의존성 그래프 생성
  DependencyGraph _buildDependencyGraph(List<BaseAnalysisModule> modules) {
    final graph = DependencyGraph();
    
    // 모든 모듈을 노드로 추가
    for (final module in modules) {
      graph.addNode(module.name, module);
    }
    
    // 의존성 관계 추가
    for (final module in modules) {
      for (final dependency in module.dependencies) {
        if (graph.hasNode(dependency)) {
          graph.addEdge(dependency, module.name);
        }
      }
    }
    
    // 순환 의존성 검사
    if (graph.hasCycle()) {
      throw PipelineExecutionException(
        '모듈 간 순환 의존성이 발견되었습니다.',
        details: {'modules': modules.map((m) => m.name).toList()},
      );
    }
    
    return graph;
  }

  /// 실행 계획 수립
  ExecutionPlan _createExecutionPlan(DependencyGraph graph, AnalysisRequest request) {
    final plan = ExecutionPlan();
    
    if (_configuration['enable_parallel_execution'] == true) {
      // 병렬 실행 계획
      final levels = graph.getTopologicalLevels();
      
      for (int i = 0; i < levels.length; i++) {
        final level = levels[i];
        final stage = ExecutionStage(
          stageNumber: i + 1,
          modules: level.map((name) => graph.getNode(name)!).toList(),
          canRunInParallel: level.length > 1,
        );
        plan.stages.add(stage);
      }
    } else {
      // 순차 실행 계획
      final sortedModules = graph.topologicalSort();
      
      for (int i = 0; i < sortedModules.length; i++) {
        final moduleName = sortedModules[i];
        final module = graph.getNode(moduleName)!;
        final stage = ExecutionStage(
          stageNumber: i + 1,
          modules: [module],
          canRunInParallel: false,
        );
        plan.stages.add(stage);
      }
    }
    
    // 실행 시간 추정
    plan.estimatedDuration = _estimateExecutionTime(plan, request);
    
    return plan;
  }

  /// 실행 시간 추정
  Duration _estimateExecutionTime(ExecutionPlan plan, AnalysisRequest request) {
    int totalTime = 0;
    
    for (final stage in plan.stages) {
      if (stage.canRunInParallel) {
        // 병렬 실행 시 가장 오래 걸리는 모듈 시간
        int maxTime = 0;
        for (final module in stage.modules) {
          final moduleTime = module.estimateProcessingTime(request);
          if (moduleTime > maxTime) {
            maxTime = moduleTime;
          }
        }
        totalTime += maxTime;
      } else {
        // 순차 실행 시 모든 모듈 시간 합계
        for (final module in stage.modules) {
          totalTime += module.estimateProcessingTime(request);
        }
      }
    }
    
    return Duration(milliseconds: totalTime);
  }

  /// 모듈들 실행
  Future<Map<String, Map<String, dynamic>>> _executeModules(PipelineExecution execution) async {
    final results = <String, Map<String, dynamic>>{};
    final plan = execution.executionPlan!;
    
    for (final stage in plan.stages) {
      _notifyListeners(PipelineEvent.stageStarted(execution.id, stage));
      
      if (stage.canRunInParallel && stage.modules.length > 1) {
        // 병렬 실행
        final stageResults = await _executeStageInParallel(stage, execution);
        results.addAll(stageResults);
      } else {
        // 순차 실행
        final stageResults = await _executeStageSequentially(stage, execution);
        results.addAll(stageResults);
      }
      
      _notifyListeners(PipelineEvent.stageCompleted(execution.id, stage));
    }
    
    return results;
  }

  /// 스테이지 병렬 실행
  Future<Map<String, Map<String, dynamic>>> _executeStageInParallel(
    ExecutionStage stage, 
    PipelineExecution execution
  ) async {
    final futures = <Future<MapEntry<String, Map<String, dynamic>>>>[];
    final maxConcurrent = _configuration['max_concurrent_modules'] as int;
    
    // 동시 실행 수 제한
    final semaphore = Semaphore(maxConcurrent);
    
    for (final module in stage.modules) {
      final future = semaphore.acquire().then((_) async {
        try {
          final result = await _executeModule(module, execution);
          return MapEntry(module.name, result);
        } finally {
          semaphore.release();
        }
      });
      futures.add(future);
    }
    
    final results = await Future.wait(futures);
    return Map.fromEntries(results);
  }

  /// 스테이지 순차 실행
  Future<Map<String, Map<String, dynamic>>> _executeStageSequentially(
    ExecutionStage stage, 
    PipelineExecution execution
  ) async {
    final results = <String, Map<String, dynamic>>{};
    
    for (final module in stage.modules) {
      final result = await _executeModule(module, execution);
      results[module.name] = result;
    }
    
    return results;
  }

  /// 개별 모듈 실행
  Future<Map<String, dynamic>> _executeModule(
    BaseAnalysisModule module, 
    PipelineExecution execution
  ) async {
    final startTime = DateTime.now();
    final timeout = Duration(milliseconds: _configuration['execution_timeout_ms'] as int);
    
    _notifyListeners(PipelineEvent.moduleStarted(execution.id, module.name));
    
    try {
      final result = await module.analyze(execution.request).timeout(timeout);
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      execution.moduleResults[module.name] = ModuleExecutionResult(
        moduleName: module.name,
        result: result,
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        success: true,
      );
      
      _notifyListeners(PipelineEvent.moduleCompleted(execution.id, module.name, result));
      
      return result;
      
    } catch (e) {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      execution.moduleResults[module.name] = ModuleExecutionResult(
        moduleName: module.name,
        result: {},
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        success: false,
        error: e,
      );
      
      _notifyListeners(PipelineEvent.moduleFailed(execution.id, module.name, e));
      
      // 재시도 로직
      if (_configuration['retry_failed_modules'] == true) {
        final maxRetries = _configuration['max_retry_attempts'] as int;
        return await _retryModule(module, execution, maxRetries);
      }
      
      rethrow;
    }
  }

  /// 모듈 재시도
  Future<Map<String, dynamic>> _retryModule(
    BaseAnalysisModule module, 
    PipelineExecution execution, 
    int maxRetries
  ) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        await Future.delayed(Duration(milliseconds: attempt * 1000)); // 지수 백오프
        
        _notifyListeners(PipelineEvent.moduleRetrying(execution.id, module.name, attempt));
        
        final result = await module.analyze(execution.request);
        
        _notifyListeners(PipelineEvent.moduleCompleted(execution.id, module.name, result));
        
        return result;
        
      } catch (e) {
        if (attempt == maxRetries) {
          _notifyListeners(PipelineEvent.moduleFailedPermanently(execution.id, module.name, e));
          rethrow;
        }
      }
    }
    
    throw Exception('재시도 실패');
  }

  /// 결과 통합
  Future<AnalysisResult> _integrateResults(
    Map<String, Map<String, dynamic>> moduleResults,
    AnalysisRequest request,
    PipelineExecution execution
  ) async {
    final successfulResults = <String, Map<String, dynamic>>{};
    final failedModules = <String>[];
    
    // 성공/실패 분류
    for (final entry in execution.moduleResults.entries) {
      if (entry.value.success) {
        successfulResults[entry.key] = entry.value.result;
      } else {
        failedModules.add(entry.key);
      }
    }
    
    // 부분 실패 처리
    final successRate = successfulResults.length / execution.moduleResults.length;
    final threshold = _configuration['partial_failure_threshold'] as double;
    
    AnalysisResultStatus status;
    if (failedModules.isEmpty) {
      status = AnalysisResultStatus.success;
    } else if (successRate >= threshold) {
      status = AnalysisResultStatus.partialSuccess;
    } else {
      status = AnalysisResultStatus.failure;
    }
    
    // 메타데이터 생성
    final metadata = AnalysisMetadata(
      executionId: execution.id,
      startTime: execution.startTime,
      endTime: execution.endTime ?? DateTime.now(),
      totalDuration: (execution.endTime ?? DateTime.now()).difference(execution.startTime),
      moduleCount: execution.moduleResults.length,
      successfulModules: successfulResults.keys.toList(),
      failedModules: failedModules,
      performanceMetrics: _generatePerformanceMetrics(execution),
    );
    
    return AnalysisResult(
      status: status,
      results: successfulResults,
      metadata: metadata,
      request: request,
      recommendations: _generateRecommendations(successfulResults, request),
      errors: _collectErrors(execution),
    );
  }

  /// 성능 메트릭 생성
  Map<String, dynamic> _generatePerformanceMetrics(PipelineExecution execution) {
    final metrics = <String, dynamic>{};
    
    // 전체 실행 시간
    final totalDuration = (execution.endTime ?? DateTime.now()).difference(execution.startTime);
    metrics['total_execution_time_ms'] = totalDuration.inMilliseconds;
    
    // 모듈별 실행 시간
    final moduleTimings = <String, int>{};
    for (final entry in execution.moduleResults.entries) {
      moduleTimings[entry.key] = entry.value.duration.inMilliseconds;
    }
    metrics['module_timings'] = moduleTimings;
    
    // 성공률
    final successCount = execution.moduleResults.values.where((r) => r.success).length;
    metrics['success_rate'] = successCount / execution.moduleResults.length;
    
    // 메모리 사용량 추정
    int totalMemory = 0;
    for (final module in execution.availableModules ?? []) {
      totalMemory += module.estimateMemoryUsage(execution.request);
    }
    metrics['estimated_memory_usage_bytes'] = totalMemory;
    
    return metrics;
  }

  /// 추천 사항 생성
  List<Map<String, dynamic>> _generateRecommendations(
    Map<String, Map<String, dynamic>> results,
    AnalysisRequest request
  ) {
    final recommendations = <Map<String, dynamic>>[];
    
    // 각 모듈의 추천 사항 수집
    for (final entry in results.entries) {
      final moduleResult = entry.value;
      if (moduleResult.containsKey('recommendations')) {
        final moduleRecommendations = moduleResult['recommendations'] as List?;
        if (moduleRecommendations != null) {
          for (final rec in moduleRecommendations) {
            if (rec is Map<String, dynamic>) {
              rec['source_module'] = entry.key;
              recommendations.add(rec);
            }
          }
        }
      }
    }
    
    // 우선순위별 정렬
    recommendations.sort((a, b) {
      final priorityA = _getPriorityValue(a['priority'] as String? ?? 'low');
      final priorityB = _getPriorityValue(b['priority'] as String? ?? 'low');
      return priorityB.compareTo(priorityA);
    });
    
    return recommendations;
  }

  /// 우선순위 값 변환
  int _getPriorityValue(String priority) {
    switch (priority.toLowerCase()) {
      case 'high': return 3;
      case 'medium': return 2;
      case 'low': return 1;
      default: return 1;
    }
  }

  /// 오류 수집
  List<Map<String, dynamic>> _collectErrors(PipelineExecution execution) {
    final errors = <Map<String, dynamic>>[];
    
    for (final entry in execution.moduleResults.entries) {
      if (!entry.value.success && entry.value.error != null) {
        errors.add({
          'module': entry.key,
          'error': entry.value.error.toString(),
          'timestamp': entry.value.endTime.toIso8601String(),
        });
      }
    }
    
    return errors;
  }

  /// 실행 ID 생성
  String _generateExecutionId() {
    return 'exec_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(6)}';
  }

  /// 랜덤 문자열 생성
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(length, (index) => chars[(random + index) % chars.length]).join();
  }

  /// 리스너 추가
  void addListener(PipelineExecutionListener listener) {
    _listeners.add(listener);
  }

  /// 리스너 제거
  void removeListener(PipelineExecutionListener listener) {
    _listeners.remove(listener);
  }

  /// 리스너들에게 이벤트 알림
  void _notifyListeners(PipelineEvent event) {
    for (final listener in _listeners) {
      try {
        listener.onEvent(event);
      } catch (e) {
        print('리스너 알림 중 오류: $e');
      }
    }
  }

  /// 현재 실행 상태
  bool get isRunning => _isRunning;
  
  /// 현재 실행 ID
  String? get currentExecutionId => _currentExecutionId;
  
  /// 활성 실행 목록
  List<String> get activeExecutionIds => _activeExecutions.keys.toList();
  
  /// 실행 정보 조회
  PipelineExecution? getExecution(String executionId) {
    return _activeExecutions[executionId];
  }

  /// 실행 취소
  Future<void> cancelExecution(String executionId) async {
    final execution = _activeExecutions[executionId];
    if (execution != null) {
      execution.cancelled = true;
      _notifyListeners(PipelineEvent.cancelled(executionId));
    }
  }

  /// 리소스 정리
  Future<void> dispose() async {
    _listeners.clear();
    _activeExecutions.clear();
    _isRunning = false;
    _currentExecutionId = null;
  }
}
/// 의존
성 그래프
class DependencyGraph {
  final Map<String, BaseAnalysisModule> _nodes = {};
  final Map<String, Set<String>> _edges = {};
  final Map<String, Set<String>> _reverseEdges = {};

  /// 노드 추가
  void addNode(String name, BaseAnalysisModule module) {
    _nodes[name] = module;
    _edges[name] ??= <String>{};
    _reverseEdges[name] ??= <String>{};
  }

  /// 엣지 추가 (from -> to)
  void addEdge(String from, String to) {
    _edges[from]?.add(to);
    _reverseEdges[to]?.add(from);
  }

  /// 노드 존재 확인
  bool hasNode(String name) => _nodes.containsKey(name);

  /// 노드 조회
  BaseAnalysisModule? getNode(String name) => _nodes[name];

  /// 순환 의존성 검사
  bool hasCycle() {
    final visited = <String>{};
    final recursionStack = <String>{};

    for (final node in _nodes.keys) {
      if (_hasCycleUtil(node, visited, recursionStack)) {
        return true;
      }
    }
    return false;
  }

  bool _hasCycleUtil(String node, Set<String> visited, Set<String> recursionStack) {
    if (recursionStack.contains(node)) return true;
    if (visited.contains(node)) return false;

    visited.add(node);
    recursionStack.add(node);

    for (final neighbor in _edges[node] ?? <String>{}) {
      if (_hasCycleUtil(neighbor, visited, recursionStack)) {
        return true;
      }
    }

    recursionStack.remove(node);
    return false;
  }

  /// 위상 정렬
  List<String> topologicalSort() {
    final inDegree = <String, int>{};
    final queue = Queue<String>();
    final result = <String>[];

    // 진입 차수 계산
    for (final node in _nodes.keys) {
      inDegree[node] = _reverseEdges[node]?.length ?? 0;
      if (inDegree[node] == 0) {
        queue.add(node);
      }
    }

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      result.add(current);

      for (final neighbor in _edges[current] ?? <String>{}) {
        inDegree[neighbor] = (inDegree[neighbor] ?? 0) - 1;
        if (inDegree[neighbor] == 0) {
          queue.add(neighbor);
        }
      }
    }

    return result;
  }

  /// 위상 정렬 레벨별 분류 (병렬 실행용)
  List<List<String>> getTopologicalLevels() {
    final inDegree = <String, int>{};
    final levels = <List<String>>[];
    
    // 진입 차수 계산
    for (final node in _nodes.keys) {
      inDegree[node] = _reverseEdges[node]?.length ?? 0;
    }

    while (inDegree.isNotEmpty) {
      final currentLevel = <String>[];
      
      // 현재 레벨에서 실행 가능한 노드들 찾기
      final readyNodes = inDegree.entries
          .where((entry) => entry.value == 0)
          .map((entry) => entry.key)
          .toList();
      
      if (readyNodes.isEmpty) break;
      
      currentLevel.addAll(readyNodes);
      levels.add(currentLevel);
      
      // 현재 레벨 노드들 제거 및 진입 차수 업데이트
      for (final node in readyNodes) {
        inDegree.remove(node);
        for (final neighbor in _edges[node] ?? <String>{}) {
          if (inDegree.containsKey(neighbor)) {
            inDegree[neighbor] = (inDegree[neighbor] ?? 0) - 1;
          }
        }
      }
    }

    return levels;
  }
}

/// 실행 계획
class ExecutionPlan {
  final List<ExecutionStage> stages = [];
  Duration? estimatedDuration;
}

/// 실행 스테이지
class ExecutionStage {
  final int stageNumber;
  final List<BaseAnalysisModule> modules;
  final bool canRunInParallel;

  ExecutionStage({
    required this.stageNumber,
    required this.modules,
    required this.canRunInParallel,
  });
}

/// 파이프라인 실행 정보
class PipelineExecution {
  final String id;
  final AnalysisRequest request;
  final DateTime startTime;
  DateTime? endTime;
  bool cancelled = false;
  
  List<BaseAnalysisModule>? availableModules;
  DependencyGraph? dependencyGraph;
  ExecutionPlan? executionPlan;
  AnalysisResult? result;
  Object? error;
  
  final Map<String, ModuleExecutionResult> moduleResults = {};

  PipelineExecution({
    required this.id,
    required this.request,
    required this.startTime,
  });
}

/// 모듈 실행 결과
class ModuleExecutionResult {
  final String moduleName;
  final Map<String, dynamic> result;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final bool success;
  final Object? error;

  ModuleExecutionResult({
    required this.moduleName,
    required this.result,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.success,
    this.error,
  });
}

/// 세마포어 (동시 실행 수 제한)
class Semaphore {
  final int maxCount;
  int _currentCount;
  final Queue<Completer<void>> _waitQueue = Queue<Completer<void>>();

  Semaphore(this.maxCount) : _currentCount = maxCount;

  Future<void> acquire() async {
    if (_currentCount > 0) {
      _currentCount--;
      return;
    }

    final completer = Completer<void>();
    _waitQueue.add(completer);
    return completer.future;
  }

  void release() {
    if (_waitQueue.isNotEmpty) {
      final completer = _waitQueue.removeFirst();
      completer.complete();
    } else {
      _currentCount++;
    }
  }
}

/// 파이프라인 이벤트
abstract class PipelineEvent {
  final String executionId;
  final DateTime timestamp;

  PipelineEvent(this.executionId) : timestamp = DateTime.now();

  static PipelineEvent started(String executionId, AnalysisRequest request) =>
      PipelineStartedEvent(executionId, request);
  
  static PipelineEvent planCreated(String executionId, ExecutionPlan plan) =>
      PipelinePlanCreatedEvent(executionId, plan);
  
  static PipelineEvent stageStarted(String executionId, ExecutionStage stage) =>
      PipelineStageStartedEvent(executionId, stage);
  
  static PipelineEvent stageCompleted(String executionId, ExecutionStage stage) =>
      PipelineStageCompletedEvent(executionId, stage);
  
  static PipelineEvent moduleStarted(String executionId, String moduleName) =>
      PipelineModuleStartedEvent(executionId, moduleName);
  
  static PipelineEvent moduleCompleted(String executionId, String moduleName, Map<String, dynamic> result) =>
      PipelineModuleCompletedEvent(executionId, moduleName, result);
  
  static PipelineEvent moduleFailed(String executionId, String moduleName, Object error) =>
      PipelineModuleFailedEvent(executionId, moduleName, error);
  
  static PipelineEvent moduleRetrying(String executionId, String moduleName, int attempt) =>
      PipelineModuleRetryingEvent(executionId, moduleName, attempt);
  
  static PipelineEvent moduleFailedPermanently(String executionId, String moduleName, Object error) =>
      PipelineModuleFailedPermanentlyEvent(executionId, moduleName, error);
  
  static PipelineEvent completed(String executionId, AnalysisResult result) =>
      PipelineCompletedEvent(executionId, result);
  
  static PipelineEvent failed(String executionId, Object error) =>
      PipelineFailedEvent(executionId, error);
  
  static PipelineEvent cancelled(String executionId) =>
      PipelineCancelledEvent(executionId);
}

class PipelineStartedEvent extends PipelineEvent {
  final AnalysisRequest request;
  PipelineStartedEvent(String executionId, this.request) : super(executionId);
}

class PipelinePlanCreatedEvent extends PipelineEvent {
  final ExecutionPlan plan;
  PipelinePlanCreatedEvent(String executionId, this.plan) : super(executionId);
}

class PipelineStageStartedEvent extends PipelineEvent {
  final ExecutionStage stage;
  PipelineStageStartedEvent(String executionId, this.stage) : super(executionId);
}

class PipelineStageCompletedEvent extends PipelineEvent {
  final ExecutionStage stage;
  PipelineStageCompletedEvent(String executionId, this.stage) : super(executionId);
}

class PipelineModuleStartedEvent extends PipelineEvent {
  final String moduleName;
  PipelineModuleStartedEvent(String executionId, this.moduleName) : super(executionId);
}

class PipelineModuleCompletedEvent extends PipelineEvent {
  final String moduleName;
  final Map<String, dynamic> result;
  PipelineModuleCompletedEvent(String executionId, this.moduleName, this.result) : super(executionId);
}

class PipelineModuleFailedEvent extends PipelineEvent {
  final String moduleName;
  final Object error;
  PipelineModuleFailedEvent(String executionId, this.moduleName, this.error) : super(executionId);
}

class PipelineModuleRetryingEvent extends PipelineEvent {
  final String moduleName;
  final int attempt;
  PipelineModuleRetryingEvent(String executionId, this.moduleName, this.attempt) : super(executionId);
}

class PipelineModuleFailedPermanentlyEvent extends PipelineEvent {
  final String moduleName;
  final Object error;
  PipelineModuleFailedPermanentlyEvent(String executionId, this.moduleName, this.error) : super(executionId);
}

class PipelineCompletedEvent extends PipelineEvent {
  final AnalysisResult result;
  PipelineCompletedEvent(String executionId, this.result) : super(executionId);
}

class PipelineFailedEvent extends PipelineEvent {
  final Object error;
  PipelineFailedEvent(String executionId, this.error) : super(executionId);
}

class PipelineCancelledEvent extends PipelineEvent {
  PipelineCancelledEvent(String executionId) : super(executionId);
}

/// 파이프라인 실행 리스너
abstract class PipelineExecutionListener {
  void onEvent(PipelineEvent event);
}

/// 파이프라인 실행 예외
class PipelineExecutionException implements Exception {
  final String message;
  final String? executionId;
  final Exception? cause;
  final Map<String, dynamic>? details;

  PipelineExecutionException(
    this.message, {
    this.executionId,
    this.cause,
    this.details,
  });

  @override
  String toString() {
    final buffer = StringBuffer('PipelineExecutionException: $message');
    if (executionId != null) {
      buffer.write(' (executionId: $executionId)');
    }
    if (cause != null) {
      buffer.write('\nCaused by: $cause');
    }
    if (details != null && details!.isNotEmpty) {
      buffer.write('\nDetails: $details');
    }
    return buffer.toString();
  }
}