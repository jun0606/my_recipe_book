/// 스마트 발효 타이머 서비스
/// 시나리오 기반 자동 설정, 실시간 진행률 추적, 단계별 알림 제공
/// Phase 3: 실시간 분석 통합 - AI 기반 발효 상태 진단 및 동적 조정

import 'dart:async';
import 'dart:math' as math;
import '../models/fermentation_scenario.dart';
import '../models/sous_chef_models.dart';
import 'real_time_fermentation_analyzer.dart';
import 'fermentation_diagnostic_system.dart' as diagnostic;
import 'fermentation_notification_service.dart';

/// 타이머 상태
enum TimerState {
  stopped,    // 정지
  running,    // 실행 중
  paused,     // 일시정지
  completed,  // 완료
}

/// 타이머 이벤트 타입
enum TimerEventType {
  started,        // 시작
  paused,         // 일시정지
  resumed,        // 재시작
  stopped,        // 정지
  completed,      // 완료
  stageChanged,   // 단계 변경
  progressUpdate, // 진행률 업데이트
  warning,        // 경고 (과발효 위험 등)
}

/// 타이머 이벤트
class TimerEvent {
  final TimerEventType type;
  final String message;
  final double progress;
  final FermentationStage? currentStage;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  TimerEvent({
    required this.type,
    required this.message,
    required this.progress,
    this.currentStage,
    DateTime? timestamp,
    this.data,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// 스마트 발효 타이머
class SmartFermentationTimer {
  static final SmartFermentationTimer _instance = SmartFermentationTimer._internal();
  factory SmartFermentationTimer() => _instance;
  SmartFermentationTimer._internal();

  // 타이머 상태
  TimerState _state = TimerState.stopped;
  Timer? _timer;
  
  // 시나리오 및 설정
  FermentationScenario? _currentScenario;
  List<FermentationStage> _stages = [];
  int _currentStageIndex = 0;
  
  // 시간 추적
  DateTime? _startTime;
  DateTime? _pauseTime;
  Duration _pausedDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;
  Duration _currentStageDuration = Duration.zero;
  
  // 환경 정보
  double _environmentTemperature = 26.0;
  double _environmentHumidity = 60.0;
  double _altitude = 0.0;
  
  // Phase 3: 실시간 분석 통합
  Timer? _analysisTimer;
  diagnostic.FermentationDiagnosis? _currentDiagnosis;
  double _currentTemp = 26.0;
  double _currentHumidity = 60.0;
  
  // 알림 서비스
  final FermentationNotificationService _notificationService = 
      FermentationNotificationService();
  
  // 체크포인트 알림 중복 방지
  final Set<String> _checkpointNotified = <String>{};
  
  // 이벤트 스트림
  final StreamController<TimerEvent> _eventController = StreamController<TimerEvent>.broadcast();
  Stream<TimerEvent> get eventStream => _eventController.stream;

  // Getters
  TimerState get state => _state;
  FermentationScenario? get currentScenario => _currentScenario;
  FermentationStage? get currentStage => _stages.isNotEmpty && _currentStageIndex < _stages.length 
      ? _stages[_currentStageIndex] : null;
  int get currentStageIndex => _currentStageIndex;
  Duration get totalDuration => _totalDuration;
  Duration get currentStageDuration => _currentStageDuration;
  
  // Phase 3: 실시간 분석 Getters
  diagnostic.FermentationDiagnosis? get currentDiagnosis => _currentDiagnosis;
  double get currentTemperature => _currentTemp;
  double get currentHumidity => _currentHumidity;

  /// 시나리오 설정 및 타이머 초기화
  void setupScenario({
    required FermentationScenario scenario,
    double environmentTemperature = 26.0,
    double environmentHumidity = 60.0,
    double altitude = 0.0,
  }) {
    // 기존 타이머 정지
    stop();
    
    _currentScenario = scenario;
    _stages = scenario.selectedStages;
    _currentStageIndex = 0;
    _environmentTemperature = environmentTemperature;
    _environmentHumidity = environmentHumidity;
    _altitude = altitude;
    
    // Phase 3: 현재 환경 조건 초기화
    _currentTemp = environmentTemperature;
    _currentHumidity = environmentHumidity;
    
    // 환경 조건에 따른 시간 자동 조정 (시나리오에서 이미 조정됨)
    // _adjustTimesForEnvironment(); // 중복 조정 방지를 위해 비활성화
    
    // 디버그: 시나리오 설정 정보 출력
    print('🎯 스마트 타이머 시나리오 설정:');
    print('   - 시나리오: ${_getScenarioName()}');
    print('   - 총 예상 시간: ${_calculateTotalEstimatedTime().inMinutes}분');
    print('   - 단계별 시간:');
    for (final stage in _stages) {
      final config = _currentScenario!.stageConfigs[stage];
      if (config != null) {
        print('     * ${_getStageName(stage)}: ${config.duration.toInt()}분 (${config.temperature}°C, ${config.humidity}%)');
      }
    }
    
    _emitEvent(TimerEvent(
      type: TimerEventType.stageChanged,
      message: '발효 시나리오가 설정되었습니다: ${_getScenarioName()}',
      progress: 0.0,
      currentStage: currentStage,
      data: {
        'scenario': scenario.scenarioType.name,
        'stages': _stages.map((s) => s.name).toList(),
        'totalEstimatedTime': _calculateTotalEstimatedTime(),
      },
    ));
  }

  /// 타이머 시작
  Future<void> start() async {
    if (_currentScenario == null || _stages.isEmpty) {
      throw Exception('시나리오를 먼저 설정해주세요');
    }

    if (_state == TimerState.paused) {
      resume();
      return;
    }

    _state = TimerState.running;
    _startTime = DateTime.now();
    _pausedDuration = Duration.zero;
    _currentStageIndex = 0;
    
    _startTimer();
    
    // Phase 3: 실시간 분석 시작
    _startRealTimeAnalysis();
    
    // 알림 서비스 초기화 및 시작 알림
    await _notificationService.initialize();
    await _notificationService.notifyStageStart(
      stageName: _getStageName(currentStage!),
      duration: _getCurrentStageTargetDuration(),
    );
    
    _emitEvent(TimerEvent(
      type: TimerEventType.started,
      message: '발효 타이머가 시작되었습니다',
      progress: 0.0,
      currentStage: currentStage,
      data: {
        'stage': currentStage?.name,
        'stageDuration': _getCurrentStageTargetDuration().inMinutes,
      },
    ));
  }

  /// 타이머 일시정지
  void pause() {
    if (_state != TimerState.running) return;
    
    _state = TimerState.paused;
    _pauseTime = DateTime.now();
    _timer?.cancel();
    
    _emitEvent(TimerEvent(
      type: TimerEventType.paused,
      message: '타이머가 일시정지되었습니다',
      progress: _calculateCurrentProgress(),
      currentStage: currentStage,
    ));
  }

  /// 타이머 재시작
  void resume() {
    if (_state != TimerState.paused || _pauseTime == null) return;
    
    _state = TimerState.running;
    _pausedDuration += DateTime.now().difference(_pauseTime!);
    _pauseTime = null;
    
    _startTimer();
    
    _emitEvent(TimerEvent(
      type: TimerEventType.resumed,
      message: '타이머가 재시작되었습니다',
      progress: _calculateCurrentProgress(),
      currentStage: currentStage,
    ));
  }

  /// 타이머 정지
  void stop() {
    _state = TimerState.stopped;
    _timer?.cancel();
    _timer = null;
    _startTime = null;
    _pauseTime = null;
    _pausedDuration = Duration.zero;
    _currentStageIndex = 0;
    
    // Phase 3: 실시간 분석 정지
    _stopRealTimeAnalysis();
    
    // 체크포인트 상태 초기화
    _checkpointNotified.clear();
    
    _emitEvent(TimerEvent(
      type: TimerEventType.stopped,
      message: '타이머가 정지되었습니다',
      progress: 0.0,
      currentStage: null,
    ));
  }

  /// 다음 단계로 수동 진행
  void nextStage() {
    if (_currentStageIndex < _stages.length - 1) {
      _currentStageIndex++;
      _resetCurrentStageTime();
      
      _emitEvent(TimerEvent(
        type: TimerEventType.stageChanged,
        message: '다음 단계로 진행합니다: ${_getStageName(currentStage!)}',
        progress: _calculateTotalProgress(),
        currentStage: currentStage,
        data: {
          'stage': currentStage?.name,
          'stageDuration': _getCurrentStageTargetDuration().inMinutes,
        },
      ));
    }
  }

  /// 이전 단계로 되돌리기
  void previousStage() {
    if (_currentStageIndex > 0) {
      _currentStageIndex--;
      _resetCurrentStageTime();
      
      _emitEvent(TimerEvent(
        type: TimerEventType.stageChanged,
        message: '이전 단계로 되돌립니다: ${_getStageName(currentStage!)}',
        progress: _calculateTotalProgress(),
        currentStage: currentStage,
        data: {
          'stage': currentStage?.name,
          'stageDuration': _getCurrentStageTargetDuration().inMinutes,
        },
      ));
    }
  }

  /// 현재 단계 시간 수정
  void adjustCurrentStageTime(Duration newDuration) {
    if (_currentScenario == null || currentStage == null) return;
    
    final config = _currentScenario!.stageConfigs[currentStage!];
    if (config != null) {
      final newConfig = config.copyWith(duration: newDuration.inMinutes.toDouble());
      _currentScenario!.stageConfigs[currentStage!] = newConfig;
      
      _emitEvent(TimerEvent(
        type: TimerEventType.progressUpdate,
        message: '${_getStageName(currentStage!)} 시간이 ${newDuration.inMinutes}분으로 조정되었습니다',
        progress: _calculateCurrentProgress(),
        currentStage: currentStage,
        data: {
          'newDuration': newDuration.inMinutes,
          'adjustment': 'manual',
        },
      ));
    }
  }

  /// 현재 진행률 (전체)
  double getTotalProgress() => _calculateTotalProgress();

  /// 현재 단계 진행률
  double getCurrentStageProgress() => _calculateCurrentProgress();

  /// 남은 시간 (전체)
  Duration getRemainingTime() {
    final totalTarget = _calculateTotalEstimatedTime();
    final elapsed = _getElapsedTime();
    final remaining = totalTarget - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// 현재 단계 남은 시간
  Duration getCurrentStageRemainingTime() {
    final stageTarget = _getCurrentStageTargetDuration();
    final stageElapsed = _getCurrentStageElapsedTime();
    final remaining = stageTarget - stageElapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Phase 3: 환경 조건 업데이트
  void updateEnvironmentalConditions({
    required double temperature,
    required double humidity,
  }) {
    _currentTemp = temperature;
    _currentHumidity = humidity;
    
    // 즉시 분석 수행
    if (_state == TimerState.running) {
      _performRealTimeAnalysis();
    }
    
    _emitEvent(TimerEvent(
      type: TimerEventType.progressUpdate,
      message: '환경 조건이 업데이트되었습니다 (${temperature.toStringAsFixed(1)}°C, ${humidity.toStringAsFixed(0)}%)',
      progress: _calculateTotalProgress(),
      currentStage: currentStage,
      data: {
        'temperature': temperature,
        'humidity': humidity,
        'environmentUpdate': true,
      },
    ));
  }
  
  /// Phase 3: 실시간 발효 진행률 계산 (환경 조건 반영)
  double getRealTimeProgress() {
    if (_startTime == null || currentStage == null) return 0.0;
    
    return RealTimeFermentationAnalyzer.calculateRealTimeProgress(
      elapsedTime: _getElapsedTime().inMinutes.toDouble(),
      totalTime: _calculateTotalEstimatedTime().inMinutes.toDouble(),
      currentTemp: _currentTemp,
      currentHumidity: _currentHumidity,
      targetTemp: _environmentTemperature,
      targetHumidity: _environmentHumidity,
    );
  }
  
  /// Phase 3: 조정된 완료 시간 계산
  Duration getAdjustedCompletionTime() {
    if (_startTime == null) return Duration.zero;
    
    final adjustedMinutes = RealTimeFermentationAnalyzer.calculateAdjustedCompletionTime(
      originalTime: _calculateTotalEstimatedTime().inMinutes.toDouble(),
      currentTemp: _currentTemp,
      currentHumidity: _currentHumidity,
      targetTemp: _environmentTemperature,
      targetHumidity: _environmentHumidity,
      elapsedTime: _getElapsedTime().inMinutes.toDouble(),
    );
    
    return Duration(minutes: adjustedMinutes.toInt());
  }

  /// 리소스 정리
  void dispose() {
    _timer?.cancel();
    _analysisTimer?.cancel();
    _eventController.close();
  }

  // Private Methods

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateProgress();
    });
  }

  void _updateProgress() {
    if (_state != TimerState.running) return;

    final currentProgress = _calculateCurrentProgress();
    final totalProgress = _calculateTotalProgress();
    
    // 진행률 업데이트 이벤트 (10초마다)
    if (DateTime.now().second % 10 == 0) {
      _emitEvent(TimerEvent(
        type: TimerEventType.progressUpdate,
        message: '발효 진행 중... ${(totalProgress * 100).toStringAsFixed(1)}%',
        progress: totalProgress,
        currentStage: currentStage,
        data: {
          'stageProgress': currentProgress,
          'totalProgress': totalProgress,
          'remainingTime': getRemainingTime().inMinutes,
        },
      ));
    }

    // 체크포인트 알림 체크
    _checkCheckpoints(currentProgress);

    // 단계 완료 체크
    if (currentProgress >= 1.0) {
      _completeCurrentStage();
    }

    // 과발효 경고 체크
    _checkOverfermentationWarning(currentProgress);
  }

  void _completeCurrentStage() async {
    final completedStage = currentStage;
    
    if (_currentStageIndex < _stages.length - 1) {
      // 단계 완료 알림
      await _notificationService.notifyStageComplete(
        stageName: _getStageName(completedStage!),
        nextStageName: _getStageName(_stages[_currentStageIndex + 1]),
      );
      
      // 다음 단계로 진행
      _currentStageIndex++;
      _resetCurrentStageTime();
      
      // 다음 단계 시작 알림
      await _notificationService.notifyStageStart(
        stageName: _getStageName(currentStage!),
        duration: _getCurrentStageTargetDuration(),
      );
      
      _emitEvent(TimerEvent(
        type: TimerEventType.stageChanged,
        message: '${_getStageName(completedStage)} 완료! 다음 단계: ${_getStageName(currentStage!)}',
        progress: _calculateTotalProgress(),
        currentStage: currentStage,
        data: {
          'completedStage': completedStage.name,
          'nextStage': currentStage?.name,
        },
      ));
    } else {
      // 전체 완료
      _state = TimerState.completed;
      _timer?.cancel();
      
      // 전체 완료 알림
      await _notificationService.notifyFermentationComplete();
      
      _emitEvent(TimerEvent(
        type: TimerEventType.completed,
        message: '🎉 모든 발효 단계가 완료되었습니다!',
        progress: 1.0,
        currentStage: completedStage,
        data: {
          'totalTime': _getElapsedTime().inMinutes,
          'scenario': _currentScenario?.scenarioType.name,
        },
      ));
    }
  }

  void _checkOverfermentationWarning(double progress) async {
    // 110% 진행 시 과발효 경고
    if (progress > 1.1) {
      // 과발효 경고 알림
      await _notificationService.notifyWarning(
        message: '과발효 위험! 즉시 다음 단계로 진행하세요',
        urgent: progress > 1.2, // 120% 이상이면 긴급
      );
      
      _emitEvent(TimerEvent(
        type: TimerEventType.warning,
        message: '⚠️ 과발효 위험! 즉시 다음 단계로 진행하세요',
        progress: progress,
        currentStage: currentStage,
        data: {
          'warningType': 'overfermentation',
          'overagePercent': ((progress - 1.0) * 100).toStringAsFixed(1),
        },
      ));
    }
  }

  /// 체크포인트 알림 체크
  void _checkCheckpoints(double progress) async {
    if (currentStage == null) return;
    
    // 각 단계별 체크포인트 정의
    List<double> checkpoints = [];
    String checkpointMessage = '';
    
    switch (currentStage!) {
      case FermentationStage.bulk:
        checkpoints = [0.3, 0.6]; // 30%, 60% 지점
        if (progress >= 0.3 && progress < 0.35) {
          checkpointMessage = '1차 발효 30% - 첫 번째 폴딩을 실시하세요';
        } else if (progress >= 0.6 && progress < 0.65) {
          checkpointMessage = '1차 발효 60% - 두 번째 폴딩을 실시하세요';
        }
        break;
        
      case FermentationStage.finalProof:
        checkpoints = [0.7, 0.9]; // 70%, 90% 지점
        if (progress >= 0.7 && progress < 0.75) {
          checkpointMessage = '최종 발효 70% - 오븐 예열을 시작하세요';
        } else if (progress >= 0.9 && progress < 0.95) {
          checkpointMessage = '최종 발효 90% - 손가락 테스트를 준비하세요';
        }
        break;
        
      case FermentationStage.overnight:
        checkpoints = [0.5]; // 50% 지점
        if (progress >= 0.5 && progress < 0.55) {
          checkpointMessage = '오버나이트 발효 중간 점검 - 상태를 확인하세요';
        }
        break;
        
      default:
        return; // 다른 단계는 체크포인트 없음
    }
    
    // 체크포인트 알림 발송
    if (checkpointMessage.isNotEmpty && !_checkpointNotified.contains(checkpointMessage)) {
      await _notificationService.notifyCheckpoint(message: checkpointMessage);
      _checkpointNotified.add(checkpointMessage);
      
      _emitEvent(TimerEvent(
        type: TimerEventType.progressUpdate,
        message: '📋 $checkpointMessage',
        progress: progress,
        currentStage: currentStage,
        data: {
          'checkpointType': 'stage_checkpoint',
          'checkpointMessage': checkpointMessage,
        },
      ));
    }
  }

  double _calculateCurrentProgress() {
    if (_startTime == null || currentStage == null) return 0.0;
    
    final elapsed = _getCurrentStageElapsedTime();
    final target = _getCurrentStageTargetDuration();
    
    return target.inSeconds > 0 ? elapsed.inSeconds / target.inSeconds : 0.0;
  }

  double _calculateTotalProgress() {
    if (_stages.isEmpty) return 0.0;
    
    double totalProgress = 0.0;
    final totalStages = _stages.length;
    
    // 완료된 단계들
    totalProgress += _currentStageIndex / totalStages;
    
    // 현재 단계 진행률
    totalProgress += _calculateCurrentProgress() / totalStages;
    
    return totalProgress.clamp(0.0, 1.0);
  }

  Duration _getElapsedTime() {
    if (_startTime == null) return Duration.zero;
    
    final now = _state == TimerState.paused ? _pauseTime! : DateTime.now();
    return now.difference(_startTime!) - _pausedDuration;
  }

  Duration _getCurrentStageElapsedTime() {
    // 현재 단계에서만의 경과 시간 계산
    final totalElapsed = _getElapsedTime();
    
    // 이전 단계들의 총 시간 계산
    Duration previousStagesTime = Duration.zero;
    for (int i = 0; i < _currentStageIndex; i++) {
      final stage = _stages[i];
      final config = _currentScenario?.stageConfigs[stage];
      if (config != null) {
        previousStagesTime += Duration(minutes: config.duration.toInt());
      }
    }
    
    return totalElapsed - previousStagesTime;
  }

  Duration _getCurrentStageTargetDuration() {
    if (currentStage == null) return Duration.zero;
    
    final config = _currentScenario?.stageConfigs[currentStage!];
    return config != null ? Duration(minutes: config.duration.toInt()) : Duration.zero;
  }

  Duration _calculateTotalEstimatedTime() {
    Duration total = Duration.zero;
    for (final stage in _stages) {
      final config = _currentScenario?.stageConfigs[stage];
      if (config != null) {
        total += Duration(minutes: config.duration.toInt());
      }
    }
    return total;
  }

  void _resetCurrentStageTime() {
    // 현재 단계 시작 시간을 현재 시간으로 조정
    if (_startTime != null) {
      Duration previousStagesTime = Duration.zero;
      for (int i = 0; i < _currentStageIndex; i++) {
        final stage = _stages[i];
        final config = _currentScenario?.stageConfigs[stage];
        if (config != null) {
          previousStagesTime += Duration(minutes: config.duration.toInt());
        }
      }
      _startTime = DateTime.now().subtract(previousStagesTime + _pausedDuration);
    }
  }

  // 환경 조건에 따른 시간 조정 (중복 조정 방지를 위해 비활성화)
  // 시나리오 생성 시 이미 환경 조건이 반영되므로 여기서 추가 조정하지 않음
  void _adjustTimesForEnvironment() {
    // 중복 조정 방지를 위해 비활성화
    // 시나리오에서 이미 환경 조건을 반영한 시간이 설정됨
    return;
    
    /*
    if (_currentScenario == null) return;
    
    // 환경 조건에 따른 시간 보정 계수 계산
    final tempFactor = _calculateTemperatureFactor(_environmentTemperature);
    final humidityFactor = _calculateHumidityFactor(_environmentHumidity);
    final altitudeFactor = _calculateAltitudeFactor(_altitude);
    
    final adjustmentFactor = tempFactor * humidityFactor * altitudeFactor;
    
    // 각 단계별 시간 조정
    for (final stage in _stages) {
      final config = _currentScenario!.stageConfigs[stage];
      if (config != null) {
        final adjustedDuration = config.duration / adjustmentFactor;
        _currentScenario!.stageConfigs[stage] = config.copyWith(
          duration: adjustedDuration.clamp(5.0, 1440.0), // 최소 5분, 최대 24시간
        );
      }
    }
    */
  }

  double _calculateTemperatureFactor(double temp) {
    // 26°C를 기준으로 온도 보정
    const optimalTemp = 26.0;
    if (temp > optimalTemp) {
      return 1.0 + (temp - optimalTemp) * 0.05; // 온도 높으면 발효 빨라짐
    } else {
      return 1.0 - (optimalTemp - temp) * 0.03; // 온도 낮으면 발효 느려짐
    }
  }

  double _calculateHumidityFactor(double humidity) {
    // 65%를 기준으로 습도 보정
    const optimalHumidity = 65.0;
    final diff = (humidity - optimalHumidity).abs();
    return 1.0 + diff * 0.002; // 습도 차이가 클수록 약간 느려짐
  }

  double _calculateAltitudeFactor(double altitude) {
    // 고도가 높을수록 기압이 낮아져 발효 빨라짐
    return 1.0 + altitude * 0.00005;
  }

  String _getScenarioName() {
    if (_currentScenario == null) return '알 수 없음';
    
    switch (_currentScenario!.scenarioType) {
      case FermentationScenarioType.standard:
        return '표준 발효';
      case FermentationScenarioType.detailed:
        return '상세 단계별 발효';
      case FermentationScenarioType.longFermentation:
        return '장시간 발효';
      case FermentationScenarioType.single:
        return '단일 단계 발효';
      case FermentationScenarioType.custom:
        return '사용자 정의 발효';
      default:
        return '기본 발효';
    }
  }

  String _getStageName(FermentationStage stage) {
    switch (stage) {
      case FermentationStage.bulk:
        return '1차 발효';
      case FermentationStage.secondary:
        return '2차 발효';
      case FermentationStage.divided:
        return '분할 후 휴지';
      case FermentationStage.shaped:
        return '성형 후 휴지';
      case FermentationStage.finalProof:
        return '최종 발효';
      case FermentationStage.overnight:
        return '오버나이트 발효';
      case FermentationStage.coldRetard:
        return '냉장 숙성';
    }
  }

  void _emitEvent(TimerEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }
  
  // Phase 3: 실시간 분석 관련 Private Methods
  
  /// 실시간 분석 시작
  void _startRealTimeAnalysis() {
    _stopRealTimeAnalysis(); // 기존 타이머 정리
    
    // 초기 분석 수행
    _performRealTimeAnalysis();
    
    // 30초마다 분석 수행
    _analysisTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _performRealTimeAnalysis();
    });
  }
  
  /// 실시간 분석 정지
  void _stopRealTimeAnalysis() {
    _analysisTimer?.cancel();
    _analysisTimer = null;
    _currentDiagnosis = null;
  }
  
  /// 실시간 분석 수행
  void _performRealTimeAnalysis() {
    if (_state != TimerState.running || currentStage == null) return;
    
    try {
      // 발효 상태 진단
      final diagnosis = diagnostic.FermentationDiagnosticSystem.diagnoseFermentationState(
        elapsedTime: _getElapsedTime().inMinutes.toDouble(),
        totalTime: _calculateTotalEstimatedTime().inMinutes.toDouble(),
        currentTemp: _currentTemp,
        currentHumidity: _currentHumidity,
        targetTemp: _environmentTemperature,
        targetHumidity: _environmentHumidity,
        stage: currentStage!,
      );
      
      _currentDiagnosis = diagnosis;
      
      // 진단 결과에 따른 이벤트 발생
      _handleDiagnosisResults(diagnosis);
      
      // 동적 시간 조정 검토
      _considerDynamicAdjustment(diagnosis);
      
    } catch (e) {
      // 분석 오류 시 로그만 남기고 계속 진행
      print('실시간 분석 오류: $e');
    }
  }
  
  /// 진단 결과 처리
  void _handleDiagnosisResults(diagnostic.FermentationDiagnosis diagnosis) {
    // 위험 상태 알림
    if (diagnosis.riskAssessment.overallRisk == diagnostic.RiskLevel.high) {
      _emitEvent(TimerEvent(
        type: TimerEventType.warning,
        message: '⚠️ ${diagnosis.riskAssessment.risks.first.description}',
        progress: _calculateTotalProgress(),
        currentStage: currentStage,
        data: {
          'riskLevel': 'high',
          'diagnosis': diagnosis.overallState.name,
          'confidence': diagnosis.confidence,
        },
      ));
    }
    
    // 조치 필요 시 알림
    if (diagnosis.actionRecommendations.any((action) => action.priority == diagnostic.Priority.high)) {
      final urgentAction = diagnosis.actionRecommendations.firstWhere(
        (action) => action.priority == diagnostic.Priority.high
      );
      
      _emitEvent(TimerEvent(
        type: TimerEventType.warning,
        message: '🔧 ${urgentAction.title}: ${urgentAction.description}',
        progress: _calculateTotalProgress(),
        currentStage: currentStage,
        data: {
          'actionRequired': true,
          'actionType': urgentAction.type.name,
          'actionTitle': urgentAction.title,
        },
      ));
    }
    
    // 상태 변화 알림 (이전 진단과 비교)
    if (_shouldNotifyStateChange(diagnosis)) {
      _emitEvent(TimerEvent(
        type: TimerEventType.progressUpdate,
        message: '📊 발효 상태: ${_getStateDescription(diagnosis.overallState)} (신뢰도: ${(diagnosis.confidence * 100).toStringAsFixed(0)}%)',
        progress: _calculateTotalProgress(),
        currentStage: currentStage,
        data: {
          'diagnosis': diagnosis.overallState.name,
          'confidence': diagnosis.confidence,
          'realTimeAnalysis': true,
        },
      ));
    }
  }
  
  /// 동적 조정 검토
  void _considerDynamicAdjustment(diagnostic.FermentationDiagnosis diagnosis) {
    // 환경 조건이 크게 벗어난 경우 시간 조정 제안
    final envAnalysis = diagnosis.environmentalAnalysis;
    
    if (envAnalysis.temperatureScore < 0.6 || envAnalysis.humidityScore < 0.6) {
      final adjustedTime = getAdjustedCompletionTime();
      final originalTime = getRemainingTime();
      final timeDifference = adjustedTime.inMinutes - originalTime.inMinutes;
      
      if (timeDifference.abs() > 10) { // 10분 이상 차이나는 경우
        _emitEvent(TimerEvent(
          type: TimerEventType.progressUpdate,
          message: '⏱️ 환경 조건에 따라 예상 완료 시간이 ${timeDifference > 0 ? '+' : ''}${timeDifference}분 조정되었습니다',
          progress: _calculateTotalProgress(),
          currentStage: currentStage,
          data: {
            'timeAdjustment': timeDifference,
            'adjustedCompletionTime': adjustedTime.inMinutes,
            'reason': 'environmental_conditions',
          },
        ));
      }
    }
  }
  
  /// 상태 변화 알림 필요 여부 판단
  bool _shouldNotifyStateChange(diagnostic.FermentationDiagnosis diagnosis) {
    // 첫 번째 진단이거나 상태가 변경된 경우
    return _currentDiagnosis == null || 
           _currentDiagnosis!.overallState != diagnosis.overallState;
  }
  
  /// 상태 설명 반환
  String _getStateDescription(FermentationState state) {
    switch (state) {
      case FermentationState.optimal:
        return '최적 상태';
      case FermentationState.readyToBake:
        return '굽기 준비 완료';
      case FermentationState.underFermented:
        return '발효 부족';
      case FermentationState.overFermented:
        return '과발효 위험';
    }
  }
}