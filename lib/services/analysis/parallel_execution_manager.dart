import 'dart:async';
import 'dart:collection';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:my_recipe_book/interfaces/analysis_module.dart';
import 'package:my_recipe_book/models/analysis_request.dart';

/// 고급 병렬 실행 관리자
///
/// 분석 모듈들의 병렬 실행을 최적화하고 관리합니다.
/// Isolate 기반 병렬 처리, 로드 밸런싱, 리소스 모니터링을 지원합니다.
class ParallelExecutionManager {
  final int _maxConcurrentTasks;
  final int _maxIsolates;
  final Duration _taskTimeout;
  final bool _enableLoadBalancing;
  final bool _enableResourceMonitoring;
  final bool _enableIsolateExecution;

  // 실행 상태 관리
  final Map<String, TaskExecution> _activeTasks = {};
  final Queue<PendingTask> _taskQueue = Queue<PendingTask>();
  final List<WorkerIsolate> _isolates = [];
  final ResourceMonitor _resourceMonitor = ResourceMonitor();

  // 통계 및 메트릭
  final ExecutionStatistics _statistics = ExecutionStatistics();

  ParallelExecutionManager({
    int maxConcurrentTasks = 4,
    int maxIsolates = 2,
    Duration taskTimeout = const Duration(seconds: 30),
    bool enableLoadBalancing = true,
    bool enableResourceMonitoring = true,
    bool enableIsolateExecution = true,
  })  : _maxConcurrentTasks = maxConcurrentTasks,
        _maxIsolates = maxIsolates,
        _taskTimeout = taskTimeout,
        _enableLoadBalancing = enableLoadBalancing,
        _enableResourceMonitoring = enableResourceMonitoring,
        _enableIsolateExecution = enableIsolateExecution;

  /// 초기화
  Future<void> initialize() async {
    if (_enableResourceMonitoring) {
      await _resourceMonitor.initialize();
    }

    if (_enableIsolateExecution) {
      // 워커 Isolate 생성
      for (int i = 0; i < _maxIsolates; i++) {
        final isolate = await _createWorkerIsolate(i);
        _isolates.add(isolate);
      }
    }
  }

  /// 워커 Isolate 생성
  Future<WorkerIsolate> _createWorkerIsolate(int id) async {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(
      _isolateEntryPoint,
      receivePort.sendPort,
    );

    final sendPort = await receivePort.first as SendPort;

    return WorkerIsolate(
      id: id,
      isolate: isolate,
      sendPort: sendPort,
      receivePort: receivePort,
      isAvailable: true,
      currentLoad: 0,
    );
  }

  /// Isolate 진입점
  static void _isolateEntryPoint(SendPort mainSendPort) {
    final receivePort = ReceivePort();
    mainSendPort.send(receivePort.sendPort);

    receivePort.listen((message) async {
      if (message is TaskMessage) {
        try {
          final result = await _executeTaskInIsolate(message);
          mainSendPort.send(TaskResult.success(message.taskId, result));
        } catch (e) {
          mainSendPort.send(TaskResult.error(message.taskId, e));
        }
      }
    });
  }

  /// Isolate 내에서 태스크 실행
  static Future<Map<String, dynamic>> _executeTaskInIsolate(
      TaskMessage message) async {
    // 실제 구현에서는 모듈을 직렬화하여 전달하고 실행
    // 여기서는 시뮬레이션
    await Future.delayed(Duration(milliseconds: message.estimatedDuration));

    return {
      'module_name': message.moduleName,
      'execution_time': message.estimatedDuration,
      'result': 'simulated_result_${message.moduleName}',
      'isolate_execution': true,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// 병렬 실행
  Future<Map<String, Map<String, dynamic>>> executeInParallel(
    List<BaseAnalysisModule> modules,
    AnalysisRequest request,
  ) async {
    final results = <String, Map<String, dynamic>>{};
    final futures = <Future<void>>[];

    _statistics.startExecution(modules.length);

    try {
      // 모듈들을 태스크로 변환
      final tasks = modules
          .map((module) => PendingTask(
                id: _generateTaskId(),
                module: module,
                request: request,
                priority: _calculateTaskPriority(module, request),
                estimatedDuration: module.estimateProcessingTime(request),
                estimatedMemory: module.estimateMemoryUsage(request),
              ))
          .toList();

      // 우선순위 정렬
      tasks.sort((a, b) => b.priority.compareTo(a.priority));

      // 태스크 큐에 추가
      _taskQueue.addAll(tasks);

      // 병렬 실행 시작 (안전장치 추가)
      int loopCount = 0;
      const int maxIterations = 1000; // 최대 1000회 반복 (~10초)
      int noProgressCount = 0;
      int lastActiveTaskCount = _activeTasks.length;

      while ((_taskQueue.isNotEmpty || _activeTasks.isNotEmpty) &&
          loopCount < maxIterations) {
        await _processTaskQueue();
        await Future.delayed(Duration(milliseconds: 10));

        loopCount++;

        // 타임아웃된 태스크 정리 (매 10회마다)
        if (loopCount % 10 == 0) {
          _cleanupTimedOutTasks();
        }

        // 진척 확인 (매 50회마다)
        if (loopCount % 50 == 0) {
          if (_activeTasks.length == lastActiveTaskCount) {
            noProgressCount++;
            debugPrint('🔄 진척 없음 카운트: $noProgressCount/5');
            if (noProgressCount >= 5) {
              debugPrint('⏹️ 무한 루프 감지 - 강제 중단');
              break;
            }
          } else {
            noProgressCount = 0;
            lastActiveTaskCount = _activeTasks.length;
          }
        }
      }

      debugPrint('🔚 병렬 실행 완료: 반복횟수=$loopCount, 진척없음카운트=$noProgressCount');

      // 결과 수집
      for (final task in tasks) {
        final execution = _activeTasks[task.id];
        if (execution?.result != null) {
          results[task.module.name] = execution!.result!;
        }
      }

      _statistics.completeExecution(results.length);
      return results;
    } catch (e) {
      _statistics.failExecution(e);
      rethrow;
    }
  }

  /// 태스크 큐 처리
  Future<void> _processTaskQueue() async {
    while (_taskQueue.isNotEmpty && _canStartNewTask()) {
      final task = _taskQueue.removeFirst();
      await _startTask(task);
    }

    // 완료된 태스크 정리
    _cleanupCompletedTasks();
  }

  /// 새 태스크 시작 가능 여부 확인
  bool _canStartNewTask() {
    if (_activeTasks.length >= _maxConcurrentTasks) {
      return false;
    }

    if (_enableResourceMonitoring) {
      final resourceUsage = _resourceMonitor.getCurrentUsage();
      if (resourceUsage.memoryUsagePercent > 80 ||
          resourceUsage.cpuUsagePercent > 90) {
        return false;
      }
    }

    return true;
  }

  /// 태스크 시작
  Future<void> _startTask(PendingTask task) async {
    final execution = TaskExecution(
      taskId: task.id,
      module: task.module,
      request: task.request,
      startTime: DateTime.now(),
    );

    _activeTasks[task.id] = execution;

    // 실행 방식 결정
    if (_enableIsolateExecution && _shouldUseIsolate(task)) {
      await _executeInIsolate(task, execution);
    } else {
      await _executeInMainThread(task, execution);
    }
  }

  /// Isolate 사용 여부 결정
  bool _shouldUseIsolate(PendingTask task) {
    // CPU 집약적이거나 오래 걸리는 작업은 Isolate 사용
    return task.estimatedDuration > 1000 || // 1초 이상
        task.estimatedMemory > 10 * 1024 * 1024; // 10MB 이상
  }

  /// Isolate에서 실행
  Future<void> _executeInIsolate(
      PendingTask task, TaskExecution execution) async {
    final isolate = _selectBestIsolate(task);
    if (isolate == null) {
      // Isolate가 없으면 메인 스레드에서 실행
      await _executeInMainThread(task, execution);
      return;
    }

    execution.isolateId = isolate.id;
    isolate.isAvailable = false;
    isolate.currentLoad++;

    try {
      final taskMessage = TaskMessage(
        taskId: task.id,
        moduleName: task.module.name,
        requestData: _serializeRequest(task.request),
        estimatedDuration: task.estimatedDuration,
      );

      isolate.sendPort.send(taskMessage);

      // 결과 대기 (타임아웃 포함)
      final completer = Completer<Map<String, dynamic>>();
      late StreamSubscription subscription;

      subscription = isolate.receivePort.listen((message) {
        if (message is TaskResult && message.taskId == task.id) {
          subscription.cancel();
          if (message.isSuccess) {
            completer.complete(message.result);
          } else {
            completer.completeError(message.error!);
          }
        }
      });

      final result = await completer.future.timeout(_taskTimeout);
      execution.result = result;
      execution.endTime = DateTime.now();
      execution.success = true;
    } catch (e) {
      execution.error = e;
      execution.endTime = DateTime.now();
      execution.success = false;
    } finally {
      isolate.isAvailable = true;
      isolate.currentLoad--;
    }
  }

  /// 메인 스레드에서 실행
  Future<void> _executeInMainThread(
      PendingTask task, TaskExecution execution) async {
    try {
      final result =
          await task.module.analyze(task.request).timeout(_taskTimeout);
      execution.result = result;
      execution.endTime = DateTime.now();
      execution.success = true;
    } catch (e) {
      execution.error = e;
      execution.endTime = DateTime.now();
      execution.success = false;
    }
  }

  /// 최적의 Isolate 선택
  WorkerIsolate? _selectBestIsolate(PendingTask task) {
    if (!_enableLoadBalancing) {
      return _isolates.firstWhere((i) => i.isAvailable, orElse: () => null);
    }

    // 로드 밸런싱: 가장 부하가 적은 Isolate 선택
    WorkerIsolate? bestIsolate;
    int minLoad = double.maxFinite.toInt();

    for (final isolate in _isolates) {
      if (isolate.isAvailable && isolate.currentLoad < minLoad) {
        bestIsolate = isolate;
        minLoad = isolate.currentLoad;
      }
    }

    return bestIsolate;
  }

  /// 완료된 태스크 정리
  void _cleanupCompletedTasks() {
    final completedTasks = _activeTasks.entries
        .where((entry) => entry.value.isCompleted)
        .map((entry) => entry.key)
        .toList();

    for (final taskId in completedTasks) {
      final execution = _activeTasks.remove(taskId);
      if (execution != null) {
        _statistics.recordTaskCompletion(execution);
      }
    }
  }

  /// 태스크 우선순위 계산
  int _calculateTaskPriority(
      BaseAnalysisModule module, AnalysisRequest request) {
    int priority = module.priority * 10;

    // 의존성이 적은 모듈 우선
    priority += (10 - module.dependencies.length);

    // 빠른 모듈 우선
    final estimatedTime = module.estimateProcessingTime(request);
    if (estimatedTime < 500) priority += 5;

    return priority;
  }

  /// 요청 직렬화 (Isolate 전달용)
  Map<String, dynamic> _serializeRequest(AnalysisRequest request) {
    // 실제 구현에서는 AnalysisRequest를 직렬화
    return {
      'recipe_title': request.recipe.title,
      'ingredient_count': request.recipe.ingredients.length,
      'instruction_count': request.recipe.instructions.length,
      // 필요한 다른 필드들...
    };
  }

  /// 태스크 ID 생성
  String _generateTaskId() {
    return 'task_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}';
  }

  /// 현재 실행 상태 조회
  ParallelExecutionStatus getExecutionStatus() {
    return ParallelExecutionStatus(
      activeTasks: _activeTasks.length,
      queuedTasks: _taskQueue.length,
      availableIsolates: _isolates.where((i) => i.isAvailable).length,
      totalIsolates: _isolates.length,
      resourceUsage:
          _enableResourceMonitoring ? _resourceMonitor.getCurrentUsage() : null,
      statistics: _statistics.getSnapshot(),
    );
  }

  /// 실행 통계 조회
  ExecutionStatisticsSnapshot getStatistics() {
    return _statistics.getSnapshot();
  }

  /// 모든 태스크 취소
  Future<void> cancelAllTasks() async {
    // 큐에 있는 태스크들 제거
    _taskQueue.clear();

    // 실행 중인 태스크들 취소
    for (final execution in _activeTasks.values) {
      execution.cancelled = true;
    }
    _activeTasks.clear();
  }

  /// 리소스 정리
  Future<void> dispose() async {
    await cancelAllTasks();

    // Isolate들 종료
    for (final isolate in _isolates) {
      isolate.isolate.kill();
      isolate.receivePort.close();
    }
    _isolates.clear();

    if (_enableResourceMonitoring) {
      await _resourceMonitor.dispose();
    }
  }
}

/// 대기 중인 태스크
class PendingTask {
  final String id;
  final BaseAnalysisModule module;
  final AnalysisRequest request;
  final int priority;
  final int estimatedDuration;
  final int estimatedMemory;

  PendingTask({
    required this.id,
    required this.module,
    required this.request,
    required this.priority,
    required this.estimatedDuration,
    required this.estimatedMemory,
  });
}

/// 태스크 실행 정보
class TaskExecution {
  final String taskId;
  final BaseAnalysisModule module;
  final AnalysisRequest request;
  final DateTime startTime;
  DateTime? endTime;
  Map<String, dynamic>? result;
  Object? error;
  bool success = false;
  bool cancelled = false;
  int? isolateId;

  TaskExecution({
    required this.taskId,
    required this.module,
    required this.request,
    required this.startTime,
  });

  bool get isCompleted => endTime != null || cancelled;
  Duration get duration => (endTime ?? DateTime.now()).difference(startTime);
}

/// 워커 Isolate
class WorkerIsolate {
  final int id;
  final Isolate isolate;
  final SendPort sendPort;
  final ReceivePort receivePort;
  bool isAvailable;
  int currentLoad;

  WorkerIsolate({
    required this.id,
    required this.isolate,
    required this.sendPort,
    required this.receivePort,
    required this.isAvailable,
    required this.currentLoad,
  });
}

/// 태스크 메시지 (Isolate 간 통신)
class TaskMessage {
  final String taskId;
  final String moduleName;
  final Map<String, dynamic> requestData;
  final int estimatedDuration;

  TaskMessage({
    required this.taskId,
    required this.moduleName,
    required this.requestData,
    required this.estimatedDuration,
  });
}

/// 태스크 결과 (Isolate 간 통신)
class TaskResult {
  final String taskId;
  final bool isSuccess;
  final Map<String, dynamic>? result;
  final Object? error;

  TaskResult.success(this.taskId, this.result)
      : isSuccess = true,
        error = null;
  TaskResult.error(this.taskId, this.error)
      : isSuccess = false,
        result = null;
}

/// 리소스 모니터
class ResourceMonitor {
  Timer? _monitoringTimer;
  ResourceUsage _currentUsage = ResourceUsage();

  Future<void> initialize() async {
    _monitoringTimer = Timer.periodic(Duration(seconds: 1), (_) {
      _updateResourceUsage();
    });
  }

  void _updateResourceUsage() {
    // 실제 구현에서는 시스템 리소스 사용량 측정
    // 여기서는 시뮬레이션
    _currentUsage = ResourceUsage(
      memoryUsagePercent: math.Random().nextDouble() * 100,
      cpuUsagePercent: math.Random().nextDouble() * 100,
      availableMemoryMB: 1024 + math.Random().nextInt(1024),
    );
  }

  ResourceUsage getCurrentUsage() => _currentUsage;

  Future<void> dispose() async {
    _monitoringTimer?.cancel();
  }
}

/// 리소스 사용량
class ResourceUsage {
  final double memoryUsagePercent;
  final double cpuUsagePercent;
  final int availableMemoryMB;

  ResourceUsage({
    this.memoryUsagePercent = 0.0,
    this.cpuUsagePercent = 0.0,
    this.availableMemoryMB = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'memory_usage_percent': memoryUsagePercent,
      'cpu_usage_percent': cpuUsagePercent,
      'available_memory_mb': availableMemoryMB,
    };
  }
}

/// 실행 통계
class ExecutionStatistics {
  int _totalExecutions = 0;
  int _successfulExecutions = 0;
  int _failedExecutions = 0;
  int _totalTasksExecuted = 0;
  int _totalTasksSucceeded = 0;
  int _totalTasksFailed = 0;
  final List<Duration> _executionTimes = [];
  final List<Duration> _taskDurations = [];
  DateTime? _lastExecutionStart;

  void startExecution(int taskCount) {
    _totalExecutions++;
    _lastExecutionStart = DateTime.now();
  }

  void completeExecution(int successfulTasks) {
    _successfulExecutions++;
    if (_lastExecutionStart != null) {
      _executionTimes.add(DateTime.now().difference(_lastExecutionStart!));
    }
  }

  void failExecution(Object error) {
    _failedExecutions++;
    if (_lastExecutionStart != null) {
      _executionTimes.add(DateTime.now().difference(_lastExecutionStart!));
    }
  }

  void recordTaskCompletion(TaskExecution execution) {
    _totalTasksExecuted++;
    if (execution.success) {
      _totalTasksSucceeded++;
    } else {
      _totalTasksFailed++;
    }
    _taskDurations.add(execution.duration);
  }

  ExecutionStatisticsSnapshot getSnapshot() {
    return ExecutionStatisticsSnapshot(
      totalExecutions: _totalExecutions,
      successfulExecutions: _successfulExecutions,
      failedExecutions: _failedExecutions,
      totalTasksExecuted: _totalTasksExecuted,
      totalTasksSucceeded: _totalTasksSucceeded,
      totalTasksFailed: _totalTasksFailed,
      averageExecutionTime: _executionTimes.isNotEmpty
          ? Duration(
              milliseconds: _executionTimes
                      .map((d) => d.inMilliseconds)
                      .reduce((a, b) => a + b) ~/
                  _executionTimes.length)
          : Duration.zero,
      averageTaskDuration: _taskDurations.isNotEmpty
          ? Duration(
              milliseconds: _taskDurations
                      .map((d) => d.inMilliseconds)
                      .reduce((a, b) => a + b) ~/
                  _taskDurations.length)
          : Duration.zero,
      successRate:
          _totalExecutions > 0 ? _successfulExecutions / _totalExecutions : 0.0,
      taskSuccessRate: _totalTasksExecuted > 0
          ? _totalTasksSucceeded / _totalTasksExecuted
          : 0.0,
    );
  }
}

/// 실행 통계 스냅샷
class ExecutionStatisticsSnapshot {
  final int totalExecutions;
  final int successfulExecutions;
  final int failedExecutions;
  final int totalTasksExecuted;
  final int totalTasksSucceeded;
  final int totalTasksFailed;
  final Duration averageExecutionTime;
  final Duration averageTaskDuration;
  final double successRate;
  final double taskSuccessRate;

  ExecutionStatisticsSnapshot({
    required this.totalExecutions,
    required this.successfulExecutions,
    required this.failedExecutions,
    required this.totalTasksExecuted,
    required this.totalTasksSucceeded,
    required this.totalTasksFailed,
    required this.averageExecutionTime,
    required this.averageTaskDuration,
    required this.successRate,
    required this.taskSuccessRate,
  });

  Map<String, dynamic> toMap() {
    return {
      'total_executions': totalExecutions,
      'successful_executions': successfulExecutions,
      'failed_executions': failedExecutions,
      'total_tasks_executed': totalTasksExecuted,
      'total_tasks_succeeded': totalTasksSucceeded,
      'total_tasks_failed': totalTasksFailed,
      'average_execution_time_ms': averageExecutionTime.inMilliseconds,
      'average_task_duration_ms': averageTaskDuration.inMilliseconds,
      'success_rate': successRate,
      'task_success_rate': taskSuccessRate,
    };
  }
}

/// 병렬 실행 상태
class ParallelExecutionStatus {
  final int activeTasks;
  final int queuedTasks;
  final int availableIsolates;
  final int totalIsolates;
  final ResourceUsage? resourceUsage;
  final ExecutionStatisticsSnapshot statistics;

  ParallelExecutionStatus({
    required this.activeTasks,
    required this.queuedTasks,
    required this.availableIsolates,
    required this.totalIsolates,
    this.resourceUsage,
    required this.statistics,
  });

  Map<String, dynamic> toMap() {
    return {
      'active_tasks': activeTasks,
      'queued_tasks': queuedTasks,
      'available_isolates': availableIsolates,
      'total_isolates': totalIsolates,
      'resource_usage': resourceUsage?.toMap(),
      'statistics': statistics.toMap(),
    };
  }
}
