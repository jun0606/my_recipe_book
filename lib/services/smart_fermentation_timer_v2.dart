/// 스마트 발효 타이머 V2 - 새로운 시나리오 기반 시스템
/// AI 생성 시나리오의 모든 단계를 자동으로 관리하고 제어하는 핵심 타이머

import 'dart:async';
import 'dart:math' as math;
import '../models/fermentation_scenario_v2.dart';
import '../models/environmental_conditions.dart';
import '../models/sous_chef_models.dart';
import 'fermentation_notification_service.dart';

/// 타이머 상태
enum TimerStateV2 {
  stopped,    // 정지
  running,    // 실행 중
  paused,     // 일시정지
  completed,  // 완료
  error,      // 오류
}

/// 타이머 이벤트 타입
enum TimerEventTypeV2 {
  started,        // 시작
  paused,         // 일시정지
  resumed,        // 재시작
  stopped,        // 정지
  completed,      // 완료
  stageChanged,   // 단계 변경
  progressUpdate, // 진행률 업데이트
  warning,        // 경고
  instruction,    // 사용자 지침
  automation,     // 자동화 실행
  environmentChanged, // 환경 변화
}

/// 타이머 이벤트 V2
class TimerEventV2 {
  final TimerEventTypeV2 type;
  final String message;
  final double progress;
  final FermentationStageV2? currentStage;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  TimerEventV2({
    required this.type,
    required this.message,
    required this.progress,
    this.currentStage,
    DateTime? timestamp,
    this.data,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// 스마트 발효 타이머 V2
class SmartFermentationTimerV2 {
  static final SmartFermentationTimerV2 _instance = SmartFermentationTimerV2._internal();
  factory SmartFermentationTimerV2() => _instance;
  SmartFermentationTimerV2._internal();

  // 타이머 상태
  TimerStateV2 _state = TimerStateV2.stopped;
  Timer? _timer;
  Timer? _automationTimer;
  
  // 시나리오 및 설정
  FermentationScenarioV2? _currentScenario;
  List<FermentationStageV2> _stages = [];
  int _currentStageIndex = 0;
  
  // 시간 추적
  DateTime? _startTime;
  DateTime? _pauseTime;
  Duration _pausedDuration = Duration.zero;
  
  // 환경 조건
  EnvironmentalConditions? _environmentalConditions;
  
  // 알림 서비스
  final FermentationNotificationService _notificationService = 
      FermentationNotificationService();
  
  // 실행된 자동화 액션 추적
  final Set<String> _executedAutomations = <String>{};
  final Set<String> _executedInstructions = <String>{};
  
  // 이벤트 스트림
  final StreamController<TimerEventV2> _eventController = StreamController<TimerEventV2>.broadcast();
  Stream<TimerEventV2> get eventStream => _eventController.stream;

  // Getters
  TimerStateV2 get state => _state;
  FermentationScenarioV2? get currentScenario => _currentScenario;
  FermentationStageV2? get currentStage => _stages.isNotEmpty && _currentStageIndex < _stages.length 
      ? _stages[_currentStageIndex] : null;
  int get currentStageIndex => _currentStageIndex;
  List<FermentationStageV2> get stages => List.unmodifiable(_stages);
  EnvironmentalConditions? get environmentalConditions => _environmentalConditions;

  /// 시나리오 시작
  Future<void> startScenario(FermentationScenarioV2 scenario) async {
    // 기존 타이머 정지
    await stop();
    
    _currentScenario = scenario;
    _stages = scenario.stages;
    _currentStageIndex = 0;
    _environmentalConditions = scenario.environmentalConditions;
    
    // 상태 초기화
    _executedAutomations.clear();
    _executedInstructions.clear();
    
    _state = TimerStateV2.running;
    _startTime = DateTime.now();
    _pausedDuration = Duration.zero;
    
    // 타이머 시작
    _startTimer();
    _startAutomationTimer();
    
    // 알림 서비스 초기화
    await _notificationService.initialize();
    
    // 시작 이벤트 발생
    _emitEvent(TimerEventV2(
      type: TimerEventTypeV2.started,
      message: '${scenario.name} 시작됨',
      progress: 0.0,
      currentStage: currentStage,
      data: {
        'scenarioId': scenario.id,
        'scenarioName': scenario.name,
        'totalDuration': scenario.totalDuration.inMinutes,
        'stageCount': _stages.length,
      },
    ));

    // 첫 번째 단계 시작 처리
    await _handleStageStart();
  }

  /// 타이머 일시정지
  Future<void> pause() async {
    if (_state != TimerStateV2.running) return;
    
    _state = TimerStateV2.paused;
    _pauseTime = DateTime.now();
    _timer?.cancel();
    _automationTimer?.cancel();
    
    _emitEvent(TimerEventV2(
      type: TimerEventTypeV2.paused,
      message: '타이머 일시정지됨',
      progress: getTotalProgress(),
      currentStage: currentStage,
    ));
  }

  /// 타이머 재시작
  Future<void> resume() async {
    if (_state != TimerStateV2.paused || _pauseTime == null) return;
    
    _state = TimerStateV2.running;
    _pausedDuration += DateTime.now().difference(_pauseTime!);
    _pauseTime = null;
    
    _startTimer();
    _startAutomationTimer();
    
    _emitEvent(TimerEventV2(
      type: TimerEventTypeV2.resumed,
      message: '타이머 재시작됨',
      progress: getTotalProgress(),
      currentStage: currentStage,
    ));
  }

  /// 타이머 정지
  Future<void> stop() async {
    _state = TimerStateV2.stopped;
    _timer?.cancel();
    _automationTimer?.cancel();
    _timer = null;
    _automationTimer = null;
    _startTime = null;
    _pauseTime = null;
    _pausedDuration = Duration.zero;
    _currentStageIndex = 0;
    
    // 상태 초기화
    _executedAutomations.clear();
    _executedInstructions.clear();
    
    _emitEvent(TimerEventV2(
      type: TimerEventTypeV2.stopped,
      message: '타이머 정지됨',
      progress: 0.0,
      currentStage: null,
    ));
  }

  /// 다음 단계로 수동 진행
  Future<void> nextStage() async {
    if (_currentStageIndex < _stages.length - 1) {
      _currentStageIndex++;
      await _handleStageStart();
      
      _emitEvent(TimerEventV2(
        type: TimerEventTypeV2.stageChanged,
        message: '다음 단계로 진행: ${currentStage!.name}',
        progress: getTotalProgress(),
        currentStage: currentStage,
        data: {
          'stageIndex': _currentStageIndex,
          'stageName': currentStage!.name,
          'manual': true,
        },
      ));
    }
  }

  /// 이전 단계로 되돌리기
  Future<void> previousStage() async {
    if (_currentStageIndex > 0) {
      _currentStageIndex--;
      await _handleStageStart();
      
      _emitEvent(TimerEventV2(
        type: TimerEventTypeV2.stageChanged,
        message: '이전 단계로 되돌림: ${currentStage!.name}',
        progress: getTotalProgress(),
        currentStage: currentStage,
        data: {
          'stageIndex': _currentStageIndex,
          'stageName': currentStage!.name,
          'manual': true,
        },
      ));
    }
  }

  /// 환경 조건 업데이트
  Future<void> updateEnvironmentalConditions(EnvironmentalConditions newConditions) async {
    if (_currentScenario == null) return;
    
    final oldConditions = _environmentalConditions;
    _environmentalConditions = newConditions;
    
    // 환경 변화 분석
    final tempChange = oldConditions != null 
        ? (newConditions.temperature - oldConditions.temperature).abs()
        : 0.0;
    final humidityChange = oldConditions != null
        ? (newConditions.humidity - oldConditions.humidity).abs()
        : 0.0;
    
    // 큰 변화가 있는 경우 시나리오 재계산 제안
    if (tempChange > 5.0 || humidityChange > 15.0) {
      _emitEvent(TimerEventV2(
        type: TimerEventTypeV2.environmentChanged,
        message: '환경 조건이 크게 변화했습니다. 시나리오 재계산을 고려하세요.',
        progress: getTotalProgress(),
        currentStage: currentStage,
        data: {
          'temperatureChange': tempChange,
          'humidityChange': humidityChange,
          'newTemperature': newConditions.temperature,
          'newHumidity': newConditions.humidity,
          'significant': true,
        },
      ));
    } else {
      _emitEvent(TimerEventV2(
        type: TimerEventTypeV2.environmentChanged,
        message: '환경 조건 업데이트됨 (${newConditions.temperature.toStringAsFixed(1)}°C, ${newConditions.humidity.toStringAsFixed(0)}%)',
        progress: getTotalProgress(),
        currentStage: currentStage,
        data: {
          'temperatureChange': tempChange,
          'humidityChange': humidityChange,
          'newTemperature': newConditions.temperature,
          'newHumidity': newConditions.humidity,
          'significant': false,
        },
      ));
    }
  }

  /// 현재 단계 시간 조정
  Future<void> adjustCurrentStageTime(Duration newDuration) async {
    if (currentStage == null) return;
    
    final oldDuration = currentStage!.duration;
    final adjustedStage = FermentationStageV2(
      name: currentStage!.name,
      type: currentStage!.type,
      duration: newDuration,
      temperature: currentStage!.temperature,
      humidity: currentStage!.humidity,
      instructions: currentStage!.instructions,
      automations: currentStage!.automations,
      alerts: currentStage!.alerts,
      description: currentStage!.description,
      metadata: {
        ...currentStage!.metadata,
        'adjusted': true,
        'originalDuration': oldDuration.inMinutes,
        'adjustedAt': DateTime.now().toIso8601String(),
      },
    );
    
    _stages[_currentStageIndex] = adjustedStage;
    
    _emitEvent(TimerEventV2(
      type: TimerEventTypeV2.progressUpdate,
      message: '${currentStage!.name} 시간이 ${newDuration.inMinutes}분으로 조정됨',
      progress: getTotalProgress(),
      currentStage: currentStage,
      data: {
        'oldDuration': oldDuration.inMinutes,
        'newDuration': newDuration.inMinutes,
        'adjustment': newDuration.inMinutes - oldDuration.inMinutes,
      },
    ));
  }

  /// 전체 진행률 계산
  double getTotalProgress() {
    if (_currentScenario == null || _startTime == null) return 0.0;
    
    final elapsed = _getElapsedTime();
    return _currentScenario!.getProgress(elapsed);
  }

  /// 현재 단계 진행률 계산
  double getCurrentStageProgress() {
    if (currentStage == null || _startTime == null) return 0.0;
    
    final stageElapsed = _getCurrentStageElapsedTime();
    final stageDuration = currentStage!.duration;
    
    return stageDuration.inSeconds > 0 
        ? (stageElapsed.inSeconds / stageDuration.inSeconds).clamp(0.0, 1.0)
        : 0.0;
  }

  /// 남은 시간 계산
  Duration getRemainingTime() {
    if (_currentScenario == null || _startTime == null) return Duration.zero;
    
    final elapsed = _getElapsedTime();
    return _currentScenario!.getRemainingTime(elapsed);
  }

  /// 현재 단계 남은 시간
  Duration getCurrentStageRemainingTime() {
    if (currentStage == null || _startTime == null) return Duration.zero;
    
    final stageElapsed = _getCurrentStageElapsedTime();
    final remaining = currentStage!.duration - stageElapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// 리소스 정리
  void dispose() {
    _timer?.cancel();
    _automationTimer?.cancel();
    _eventController.close();
  }

  // Private Methods

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateProgress();
    });
  }

  void _startAutomationTimer() {
    _automationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkAutomations();
    });
  }

  void _updateProgress() {
    if (_state != TimerStateV2.running) return;

    final currentProgress = getCurrentStageProgress();
    final totalProgress = getTotalProgress();
    
    // 진행률 업데이트 이벤트 (30초마다)
    if (DateTime.now().second % 30 == 0) {
      _emitEvent(TimerEventV2(
        type: TimerEventTypeV2.progressUpdate,
        message: '발효 진행 중... ${(totalProgress * 100).toStringAsFixed(1)}%',
        progress: totalProgress,
        currentStage: currentStage,
        data: {
          'stageProgress': currentProgress,
          'totalProgress': totalProgress,
          'remainingTime': getRemainingTime().inMinutes,
          'currentStageRemainingTime': getCurrentStageRemainingTime().inMinutes,
        },
      ));
    }

    // 단계 완료 체크
    if (currentProgress >= 1.0) {
      _completeCurrentStage();
    }

    // 과발효 경고 체크
    _checkOverfermentationWarning(currentProgress);
  }

  void _checkAutomations() {
    if (_state != TimerStateV2.running || currentStage == null) return;
    
    final stageElapsed = _getCurrentStageElapsedTime();
    
    // 자동화 액션 체크
    for (final automation in currentStage!.automations) {
      final automationKey = '${_currentStageIndex}_${automation.target.name}_${automation.executeAt.inSeconds}';
      
      if (!_executedAutomations.contains(automationKey) && 
          stageElapsed >= automation.executeAt) {
        _executeAutomation(automation);
        _executedAutomations.add(automationKey);
      }
    }
    
    // 사용자 지침 체크
    for (final instruction in currentStage!.instructions) {
      final instructionKey = '${_currentStageIndex}_${instruction.action}_${instruction.timing.inSeconds}';
      
      if (!_executedInstructions.contains(instructionKey) && 
          stageElapsed >= instruction.timing) {
        _showInstruction(instruction);
        _executedInstructions.add(instructionKey);
      }
    }
  }

  Future<void> _executeAutomation(AutomationAction automation) async {
    switch (automation.target) {
      case AutomationTarget.timer:
        // 타이머 관련 자동화는 이미 처리됨
        break;
        
      case AutomationTarget.notification:
        final message = automation.settings['message'] as String? ?? '알림';
        await _notificationService.notifyGeneral(message: message);
        break;
        
      case AutomationTarget.temperature:
        // 온도 제어 (스마트 장비 연동 시)
        final temperature = automation.settings['temperature'] as double?;
        if (temperature != null) {
          _emitEvent(TimerEventV2(
            type: TimerEventTypeV2.automation,
            message: '온도를 ${temperature.toStringAsFixed(0)}°C로 설정하세요',
            progress: getTotalProgress(),
            currentStage: currentStage,
            data: {
              'automationType': 'temperature',
              'targetTemperature': temperature,
            },
          ));
        }
        break;
        
      case AutomationTarget.humidity:
        // 습도 제어 (스마트 장비 연동 시)
        final humidity = automation.settings['humidity'] as double?;
        if (humidity != null) {
          _emitEvent(TimerEventV2(
            type: TimerEventTypeV2.automation,
            message: '습도를 ${humidity.toStringAsFixed(0)}%로 설정하세요',
            progress: getTotalProgress(),
            currentStage: currentStage,
            data: {
              'automationType': 'humidity',
              'targetHumidity': humidity,
            },
          ));
        }
        break;
        
      case AutomationTarget.equipment:
        // 장비 제어
        final equipmentAction = automation.settings['action'] as String? ?? '장비 조작';
        _emitEvent(TimerEventV2(
          type: TimerEventTypeV2.automation,
          message: equipmentAction,
          progress: getTotalProgress(),
          currentStage: currentStage,
          data: {
            'automationType': 'equipment',
            'action': equipmentAction,
          },
        ));
        break;
    }
  }

  Future<void> _showInstruction(UserInstruction instruction) async {
    // 우선순위에 따른 알림 방식 결정
    final isUrgent = instruction.priority == InstructionPriority.critical;
    
    await _notificationService.notifyInstruction(
      instruction: instruction.action,
      description: instruction.description,
      urgent: isUrgent,
    );
    
    _emitEvent(TimerEventV2(
      type: TimerEventTypeV2.instruction,
      message: instruction.action,
      progress: getTotalProgress(),
      currentStage: currentStage,
      data: {
        'instructionType': 'user_action',
        'priority': instruction.priority.name,
        'description': instruction.description,
        'equipmentTarget': instruction.equipmentTarget,
      },
    ));
  }

  Future<void> _completeCurrentStage() async {
    final completedStage = currentStage;
    
    if (_currentStageIndex < _stages.length - 1) {
      // 단계 완료 알림
      await _notificationService.notifyStageComplete(
        stageName: completedStage!.name,
        nextStageName: _stages[_currentStageIndex + 1].name,
      );
      
      // 다음 단계로 진행
      _currentStageIndex++;
      await _handleStageStart();
      
      _emitEvent(TimerEventV2(
        type: TimerEventTypeV2.stageChanged,
        message: '${completedStage.name} 완료! 다음 단계: ${currentStage!.name}',
        progress: getTotalProgress(),
        currentStage: currentStage,
        data: {
          'completedStage': completedStage.name,
          'nextStage': currentStage!.name,
          'automatic': true,
        },
      ));
    } else {
      // 전체 완료
      _state = TimerStateV2.completed;
      _timer?.cancel();
      _automationTimer?.cancel();
      
      // 전체 완료 알림
      await _notificationService.notifyFermentationComplete();
      
      _emitEvent(TimerEventV2(
        type: TimerEventTypeV2.completed,
        message: '🎉 ${_currentScenario!.name} 완료!',
        progress: 1.0,
        currentStage: completedStage,
        data: {
          'totalTime': _getElapsedTime().inMinutes,
          'scenarioName': _currentScenario!.name,
          'completedStages': _stages.length,
        },
      ));
    }
  }

  Future<void> _handleStageStart() async {
    if (currentStage == null) return;
    
    // 단계 시작 알림
    await _notificationService.notifyStageStart(
      stageName: currentStage!.name,
      duration: currentStage!.duration,
    );
    
    // 단계별 알림 설정에 따른 추가 알림
    if (currentStage!.alerts.enabled) {
      await _notificationService.notifyGeneral(
        message: currentStage!.alerts.message,
      );
    }
    
    // 즉시 실행되는 지침들 처리
    for (final instruction in currentStage!.instructions) {
      if (instruction.timing == Duration.zero) {
        await _showInstruction(instruction);
        final instructionKey = '${_currentStageIndex}_${instruction.action}_0';
        _executedInstructions.add(instructionKey);
      }
    }
    
    // 즉시 실행되는 자동화 액션들 처리
    for (final automation in currentStage!.automations) {
      if (automation.executeAt == Duration.zero) {
        await _executeAutomation(automation);
        final automationKey = '${_currentStageIndex}_${automation.target.name}_0';
        _executedAutomations.add(automationKey);
      }
    }
  }

  void _checkOverfermentationWarning(double progress) {
    // 110% 진행 시 과발효 경고
    if (progress > 1.1) {
      final overagePercent = ((progress - 1.0) * 100).toStringAsFixed(1);
      
      _emitEvent(TimerEventV2(
        type: TimerEventTypeV2.warning,
        message: '⚠️ 과발효 위험! (${overagePercent}% 초과) 즉시 다음 단계로 진행하세요',
        progress: progress,
        currentStage: currentStage,
        data: {
          'warningType': 'overfermentation',
          'overagePercent': overagePercent,
          'urgent': progress > 1.2,
        },
      ));
    }
  }

  Duration _getElapsedTime() {
    if (_startTime == null) return Duration.zero;
    
    final now = _state == TimerStateV2.paused ? _pauseTime! : DateTime.now();
    return now.difference(_startTime!) - _pausedDuration;
  }

  Duration _getCurrentStageElapsedTime() {
    final totalElapsed = _getElapsedTime();
    
    // 이전 단계들의 총 시간 계산
    Duration previousStagesTime = Duration.zero;
    for (int i = 0; i < _currentStageIndex; i++) {
      previousStagesTime += _stages[i].duration;
    }
    
    final stageElapsed = totalElapsed - previousStagesTime;
    return stageElapsed.isNegative ? Duration.zero : stageElapsed;
  }

  void _emitEvent(TimerEventV2 event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }
}