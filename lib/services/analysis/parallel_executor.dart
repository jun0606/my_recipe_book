import 'dart:async';
import 'dart:collection';
import 'dart:isolate';
import 'package:my_recipe_book/interfaces/analysis_module.dart';
import 'package:my_recipe_book/models/analysis_request.dart';

/// 병렬 실행기
/// 
/// 분석 모듈들을 병렬로 실행하고 리소스를 관리합니다.
class ParallelExecutor {
  final int maxConcurrentTasks;
  final Duration taskTimeout;
  final ResourceManager _resourceManager;
  
  // 실행 상태 관리
  final Map<String, TaskExecution> _activeTasks = {};
  final Queue<PendingTask> _taskQueue = Queue<PendingTask>();
  int _runningTasks = 0;
  
  ParallelExecutor({
    this.maxConcurrentTasks = 4,
    this.taskTimeout = const Duration(seconds: 30),
    ResourceManager? resourceManager,
  }) : _resourceManager = resourceManager ?? ResourceManager();

  /// 병렬 실행
  Future<Map<String, Map<String, dynamic>>> executeInParallel(
    List<BaseAnalysisModule> modules,
    AnalysisRequest request,
    {Map<String, dynamic>? sharedContext}
  ) async {
    final results = <String, Map<String, dynamic>>{};
    final errors = <String, Object>{};
    final completers = <String, Completer<Map<String, dynamic>>>{};
    
    // 각 모듈에 대한 Completer 생성
    for (final module in modules) {
      completers[module.name] = Completer<Map<String, dynamic>>();
    }
    
    // 모든 작업을 큐에 추가
    for (final module in modules) {
      final task = PendingTask(
        id: _generateTaskId(),
        module: module,
        request: request,
        completer: completers[module.name]!,
        sharedContext: sharedContext ?? {},
      );
      _taskQueue.add(task);
    }
    
    // 병렬 실행 시작
    _processTaskQueue();
    
    // 모든 작업 완료 대기
    final futures = completers.values.map((completer) => completer.future);
    final moduleResults = await Future.wait(futures, eagerError: false);
    
    // 결과 매핑
    int index = 0;
    for (final module in modules) {
      try {
        results[module.name] = moduleResults[index];
      } catch (e) {
        errors[module.name] = e;
      }
      index++;
    }
    
    // 오류가 있으면 로그 출력
    if (errors.isNotEmpty) {
      print('병렬 실행 중 오류 발생: $errors');
    }
    
    return results;
  }

  /// 작업 큐 처리
  void _processTaskQueue() {
    while (_taskQueue.isNotEmpty && _runningTasks < maxConcurrentTasks) {
      final task = _taskQueue.removeFirst();
      _executeTask(task);
    }
  }

  /// 개별 작업 실행
  Future<void> _executeTask(PendingTask task) async {
    _runningTasks++;
    _activeTasks[task.id] = TaskExecution(
      id: task.id,
      moduleName: task.module.name,
      startTime: DateTime.now(),
    );
    
    try {
      // 리소스 할당
      final resourceToken = await _resourceManager.allocateResources(
        task.module.estimateMemoryUsage(task.request),
        1, // CPU 코어 1개
      );
      
      try {
        // 타임아웃과 함께 모듈 실행
        final result = await task.module.analyze(task.request).timeout(taskTimeout);
        
        // 공유 컨텍스트 업데이트
        task.sharedContext[task.module.name] = result;
        
        task.completer.complete(result);
        
      } finally {
        // 리소스 해제
        _resourceManager.releaseResources(resourceToken);
      }
      
    } catch (e) {
      task.completer.completeError(e);
    } finally {
      _runningTasks--;
      _activeTasks.remove(task.id);
      
      // 대기 중인 작업이 있으면 계속 처리
      _processTaskQueue();
    }
  }

  /// 작업 ID 생성
  String _generateTaskId() {
    return 'task_${DateTime.now().millisecondsSinceEpoch}_${_runningTasks}';
  }

  /// 실행 중인 작업 수
  int get runningTaskCount => _runningTasks;
  
  /// 대기 중인 작업 수
  int get pendingTaskCount => _taskQueue.length;
  
  /// 활성 작업 목록
  List<String> get activeTaskIds => _activeTasks.keys.toList();
  
  /// 작업 정보 조회
  TaskExecution? getTaskExecution(String taskId) {
    return _activeTasks[taskId];
  }

  /// 모든 작업 취소
  Future<void> cancelAllTasks() async {
    // 대기 중인 작업들 취소
    while (_taskQueue.isNotEmpty) {
      final task = _taskQueue.removeFirst();
      task.completer.completeError(TaskCancelledException('작업이 취소되었습니다.'));
    }
    
    // 실행 중인 작업들은 자연스럽게 완료되도록 대기
    // (Isolate 기반 실행의 경우 강제 종료 가능)
  }

  /// 리소스 정리
  Future<void> dispose() async {
    await cancelAllTasks();
    await _resourceManager.dispose();
    _activeTasks.clear();
  }
}

/// 리소스 관리자
class ResourceManager {
  final int maxMemoryMB;
  final int maxCpuCores;
  
  int _allocatedMemoryMB = 0;
  int _allocatedCores = 0;
  final Map<String, ResourceAllocation> _allocations = {};
  final Queue<ResourceRequest> _pendingRequests = Queue<ResourceRequest>();

  ResourceManager({
    this.maxMemoryMB = 512, // 512MB
    this.maxCpuCores = 4,
  });

  /// 리소스 할당
  Future<ResourceToken> allocateResources(int memoryBytes, int cpuCores) async {
    final memoryMB = (memoryBytes / (1024 * 1024)).ceil();
    final tokenId = _generateTokenId();
    
    // 리소스 가용성 확인
    if (_allocatedMemoryMB + memoryMB > maxMemoryMB || 
        _allocatedCores + cpuCores > maxCpuCores) {
      
      // 대기열에 추가
      final completer = Completer<ResourceToken>();
      _pendingRequests.add(ResourceRequest(
        tokenId: tokenId,
        memoryMB: memoryMB,
        cpuCores: cpuCores,
        completer: completer,
      ));
      
      return completer.future;
    }
    
    // 즉시 할당
    return _performAllocation(tokenId, memoryMB, cpuCores);
  }

  /// 실제 리소스 할당
  ResourceToken _performAllocation(String tokenId, int memoryMB, int cpuCores) {
    _allocatedMemoryMB += memoryMB;
    _allocatedCores += cpuCores;
    
    final allocation = ResourceAllocation(
      tokenId: tokenId,
      memoryMB: memoryMB,
      cpuCores: cpuCores,
      allocationTime: DateTime.now(),
    );
    
    _allocations[tokenId] = allocation;
    
    return ResourceToken(tokenId, this);
  }

  /// 리소스 해제
  void releaseResources(ResourceToken token) {
    final allocation = _allocations.remove(token.id);
    if (allocation != null) {
      _allocatedMemoryMB -= allocation.memoryMB;
      _allocatedCores -= allocation.cpuCores;
      
      // 대기 중인 요청 처리
      _processPendingRequests();
    }
  }

  /// 대기 중인 요청 처리
  void _processPendingRequests() {
    while (_pendingRequests.isNotEmpty) {
      final request = _pendingRequests.first;
      
      if (_allocatedMemoryMB + request.memoryMB <= maxMemoryMB && 
          _allocatedCores + request.cpuCores <= maxCpuCores) {
        
        _pendingRequests.removeFirst();
        final token = _performAllocation(request.tokenId, request.memoryMB, request.cpuCores);
        request.completer.complete(token);
      } else {
        break; // 리소스 부족으로 더 이상 처리 불가
      }
    }
  }

  /// 토큰 ID 생성
  String _generateTokenId() {
    return 'token_${DateTime.now().millisecondsSinceEpoch}_${_allocations.length}';
  }

  /// 리소스 사용 현황
  ResourceUsage getCurrentUsage() {
    return ResourceUsage(
      allocatedMemoryMB: _allocatedMemoryMB,
      maxMemoryMB: maxMemoryMB,
      allocatedCores: _allocatedCores,
      maxCores: maxCpuCores,
      activeAllocations: _allocations.length,
      pendingRequests: _pendingRequests.length,
      memoryUtilization: (_allocatedMemoryMB / maxMemoryMB) * 100,
      cpuUtilization: (_allocatedCores / maxCpuCores) * 100,
    );
  }

  /// 리소스 정리
  Future<void> dispose() async {
    // 모든 대기 요청 취소
    while (_pendingRequests.isNotEmpty) {
      final request = _pendingRequests.removeFirst();
      request.completer.completeError(ResourceAllocationException('리소스 관리자가 종료되었습니다.'));
    }
    
    _allocations.clear();
    _allocatedMemoryMB = 0;
    _allocatedCores = 0;
  }
}

/// 의존성 그래프 분석기
class DependencyAnalyzer {
  /// 실행 순서 최적화
  static List<List<BaseAnalysisModule>> optimizeExecutionOrder(List<BaseAnalysisModule> modules) {
    final dependencyMap = <String, Set<String>>{};
    final moduleMap = <String, BaseAnalysisModule>{};
    
    // 의존성 맵 구성
    for (final module in modules) {
      moduleMap[module.name] = module;
      dependencyMap[module.name] = Set.from(module.dependencies);
    }
    
    final levels = <List<BaseAnalysisModule>>[];
    final processed = <String>{};
    
    while (processed.length < modules.length) {
      final currentLevel = <BaseAnalysisModule>[];
      
      // 현재 레벨에서 실행 가능한 모듈들 찾기
      for (final module in modules) {
        if (processed.contains(module.name)) continue;
        
        final dependencies = dependencyMap[module.name] ?? <String>{};
        final canExecute = dependencies.every((dep) => processed.contains(dep));
        
        if (canExecute) {
          currentLevel.add(module);
        }
      }
      
      if (currentLevel.isEmpty) {
        // 순환 의존성 또는 해결할 수 없는 의존성
        final remaining = modules.where((m) => !processed.contains(m.name)).toList();
        throw DependencyResolutionException(
          '해결할 수 없는 의존성이 있습니다.',
          details: {'remaining_modules': remaining.map((m) => m.name).toList()},
        );
      }
      
      levels.add(currentLevel);
      
      // 처리된 모듈들 마킹
      for (final module in currentLevel) {
        processed.add(module.name);
      }
    }
    
    return levels;
  }

  /// 병목 지점 식별
  static List<BottleneckAnalysis> identifyBottlenecks(
    List<BaseAnalysisModule> modules,
    AnalysisRequest request
  ) {
    final bottlenecks = <BottleneckAnalysis>[];
    
    // 각 모듈의 예상 실행 시간 계산
    final moduleTimings = <String, int>{};
    for (final module in modules) {
      moduleTimings[module.name] = module.estimateProcessingTime(request);
    }
    
    // 의존성 체인별 총 시간 계산
    final dependencyChains = _findDependencyChains(modules);
    
    for (final chain in dependencyChains) {
      int totalTime = 0;
      String? slowestModule;
      int slowestTime = 0;
      
      for (final moduleName in chain) {
        final moduleTime = moduleTimings[moduleName] ?? 0;
        totalTime += moduleTime;
        
        if (moduleTime > slowestTime) {
          slowestTime = moduleTime;
          slowestModule = moduleName;
        }
      }
      
      // 병목 지점 식별 (체인 시간의 50% 이상을 차지하는 모듈)
      if (slowestModule != null && slowestTime > totalTime * 0.5) {
        bottlenecks.add(BottleneckAnalysis(
          moduleName: slowestModule,
          estimatedTime: slowestTime,
          chainTotalTime: totalTime,
          bottleneckPercentage: (slowestTime / totalTime) * 100,
          dependencyChain: List.from(chain),
          severity: _calculateBottleneckSeverity(slowestTime, totalTime),
        ));
      }
    }
    
    return bottlenecks;
  }

  /// 의존성 체인 찾기
  static List<List<String>> _findDependencyChains(List<BaseAnalysisModule> modules) {
    final chains = <List<String>>[];
    final moduleMap = <String, BaseAnalysisModule>{};
    
    for (final module in modules) {
      moduleMap[module.name] = module;
    }
    
    // 루트 모듈들 (의존성이 없는 모듈들)부터 시작
    final rootModules = modules.where((m) => m.dependencies.isEmpty).toList();
    
    for (final rootModule in rootModules) {
      final chain = <String>[];
      _buildChain(rootModule.name, moduleMap, chain, <String>{});
      if (chain.isNotEmpty) {
        chains.add(chain);
      }
    }
    
    return chains;
  }

  /// 체인 구성
  static void _buildChain(
    String moduleName,
    Map<String, BaseAnalysisModule> moduleMap,
    List<String> currentChain,
    Set<String> visited
  ) {
    if (visited.contains(moduleName)) return;
    
    visited.add(moduleName);
    currentChain.add(moduleName);
    
    final module = moduleMap[moduleName];
    if (module != null) {
      // 이 모듈에 의존하는 다른 모듈들 찾기
      final dependentModules = moduleMap.values
          .where((m) => m.dependencies.contains(moduleName))
          .toList();
      
      for (final dependentModule in dependentModules) {
        _buildChain(dependentModule.name, moduleMap, currentChain, visited);
      }
    }
  }

  /// 병목 심각도 계산
  static BottleneckSeverity _calculateBottleneckSeverity(int moduleTime, int totalTime) {
    final percentage = (moduleTime / totalTime) * 100;
    
    if (percentage >= 80) return BottleneckSeverity.critical;
    if (percentage >= 60) return BottleneckSeverity.high;
    if (percentage >= 40) return BottleneckSeverity.medium;
    return BottleneckSeverity.low;
  }

  /// 실행 통계
  ParallelExecutionStatistics getStatistics() {
    final activeTasks = _activeTasks.values.toList();
    
    return ParallelExecutionStatistics(
      maxConcurrentTasks: maxConcurrentTasks,
      runningTasks: _runningTasks,
      pendingTasks: _taskQueue.length,
      activeTasks: activeTasks,
      resourceUsage: _resourceManager.getCurrentUsage(),
      averageTaskDuration: _calculateAverageTaskDuration(activeTasks),
    );
  }

  /// 평균 작업 시간 계산
  Duration? _calculateAverageTaskDuration(List<TaskExecution> tasks) {
    if (tasks.isEmpty) return null;
    
    final completedTasks = tasks.where((t) => t.endTime != null).toList();
    if (completedTasks.isEmpty) return null;
    
    int totalMilliseconds = 0;
    for (final task in completedTasks) {
      totalMilliseconds += task.endTime!.difference(task.startTime).inMilliseconds;
    }
    
    return Duration(milliseconds: totalMilliseconds ~/ completedTasks.length);
  }

  /// 정리
  Future<void> dispose() async {
    await cancelAllTasks();
    await _resourceManager.dispose();
  }

  /// 모든 작업 취소
  Future<void> cancelAllTasks() async {
    // 대기 중인 작업들 취소
    while (_taskQueue.isNotEmpty) {
      final task = _taskQueue.removeFirst();
      task.completer.completeError(TaskCancelledException('모든 작업이 취소되었습니다.'));
    }
    
    // 실행 중인 작업들은 자연스럽게 완료되기를 기다림
    // 필요시 강제 종료 로직 추가 가능
  }
}

/// 대기 중인 작업
class PendingTask {
  final String id;
  final BaseAnalysisModule module;
  final AnalysisRequest request;
  final Completer<Map<String, dynamic>> completer;
  final Map<String, dynamic> sharedContext;

  PendingTask({
    required this.id,
    required this.module,
    required this.request,
    required this.completer,
    required this.sharedContext,
  });
}

/// 작업 실행 정보
class TaskExecution {
  final String id;
  final String moduleName;
  final DateTime startTime;
  DateTime? endTime;
  Object? error;

  TaskExecution({
    required this.id,
    required this.moduleName,
    required this.startTime,
  });

  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }
}

/// 리소스 할당 정보
class ResourceAllocation {
  final String tokenId;
  final int memoryMB;
  final int cpuCores;
  final DateTime allocationTime;

  ResourceAllocation({
    required this.tokenId,
    required this.memoryMB,
    required this.cpuCores,
    required this.allocationTime,
  });
}

/// 리소스 요청
class ResourceRequest {
  final String tokenId;
  final int memoryMB;
  final int cpuCores;
  final Completer<ResourceToken> completer;

  ResourceRequest({
    required this.tokenId,
    required this.memoryMB,
    required this.cpuCores,
    required this.completer,
  });
}

/// 리소스 토큰
class ResourceToken {
  final String id;
  final ResourceManager _manager;

  ResourceToken(this.id, this._manager);

  /// 리소스 해제
  void release() {
    _manager.releaseResources(this);
  }
}

/// 리소스 사용 현황
class ResourceUsage {
  final int allocatedMemoryMB;
  final int maxMemoryMB;
  final int allocatedCores;
  final int maxCores;
  final int activeAllocations;
  final int pendingRequests;
  final double memoryUtilization;
  final double cpuUtilization;

  ResourceUsage({
    required this.allocatedMemoryMB,
    required this.maxMemoryMB,
    required this.allocatedCores,
    required this.maxCores,
    required this.activeAllocations,
    required this.pendingRequests,
    required this.memoryUtilization,
    required this.cpuUtilization,
  });

  Map<String, dynamic> toMap() {
    return {
      'allocated_memory_mb': allocatedMemoryMB,
      'max_memory_mb': maxMemoryMB,
      'allocated_cores': allocatedCores,
      'max_cores': maxCores,
      'active_allocations': activeAllocations,
      'pending_requests': pendingRequests,
      'memory_utilization': memoryUtilization,
      'cpu_utilization': cpuUtilization,
    };
  }
}

/// 병목 분석 결과
class BottleneckAnalysis {
  final String moduleName;
  final int estimatedTime;
  final int chainTotalTime;
  final double bottleneckPercentage;
  final List<String> dependencyChain;
  final BottleneckSeverity severity;

  BottleneckAnalysis({
    required this.moduleName,
    required this.estimatedTime,
    required this.chainTotalTime,
    required this.bottleneckPercentage,
    required this.dependencyChain,
    required this.severity,
  });

  Map<String, dynamic> toMap() {
    return {
      'module_name': moduleName,
      'estimated_time_ms': estimatedTime,
      'chain_total_time_ms': chainTotalTime,
      'bottleneck_percentage': bottleneckPercentage,
      'dependency_chain': dependencyChain,
      'severity': severity.toString(),
    };
  }
}

/// 병목 심각도
enum BottleneckSeverity {
  low,
  medium,
  high,
  critical,
}

/// 병렬 실행 통계
class ParallelExecutionStatistics {
  final int maxConcurrentTasks;
  final int runningTasks;
  final int pendingTasks;
  final List<TaskExecution> activeTasks;
  final ResourceUsage resourceUsage;
  final Duration? averageTaskDuration;

  ParallelExecutionStatistics({
    required this.maxConcurrentTasks,
    required this.runningTasks,
    required this.pendingTasks,
    required this.activeTasks,
    required this.resourceUsage,
    this.averageTaskDuration,
  });

  Map<String, dynamic> toMap() {
    return {
      'max_concurrent_tasks': maxConcurrentTasks,
      'running_tasks': runningTasks,
      'pending_tasks': pendingTasks,
      'active_task_count': activeTasks.length,
      'resource_usage': resourceUsage.toMap(),
      'average_task_duration_ms': averageTaskDuration?.inMilliseconds,
    };
  }
}

/// 예외 클래스들
class TaskCancelledException implements Exception {
  final String message;
  TaskCancelledException(this.message);
  
  @override
  String toString() => 'TaskCancelledException: $message';
}

class ResourceAllocationException implements Exception {
  final String message;
  ResourceAllocationException(this.message);
  
  @override
  String toString() => 'ResourceAllocationException: $message';
}

class DependencyResolutionException implements Exception {
  final String message;
  final Map<String, dynamic>? details;
  
  DependencyResolutionException(this.message, {this.details});
  
  @override
  String toString() {
    final buffer = StringBuffer('DependencyResolutionException: $message');
    if (details != null && details!.isNotEmpty) {
      buffer.write('\nDetails: $details');
    }
    return buffer.toString();
  }
}