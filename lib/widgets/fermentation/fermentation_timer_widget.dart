import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/smart_fermentation_timer.dart';
import '../../models/fermentation_scenario.dart';
import '../../models/sous_chef_models.dart';
import '../../models/environmental_conditions.dart';
import 'advanced_scenario_selector.dart';
import 'real_time_feedback_widget.dart';
import 'notification_settings_widget.dart';
import '../../services/fermentation_notification_service.dart';

/// 스마트 발효 타이머 위젯
/// 실시간 진행률 표시, 시나리오 기반 자동 설정, 사용자 수정 가능
class FermentationTimerWidget extends StatefulWidget {
  final FermentationScenario? initialScenario;
  final double environmentTemperature;
  final double environmentHumidity;
  final double altitude;
  final List<Map<String, dynamic>> ingredients;
  final String? recipeTitle;
  final VoidCallback? onTimerComplete;
  
  // 쉐프 모드에서 전달받는 발효 설정 값들
  final double? targetFermentationTemperature;
  final double? targetFermentationHumidity;
  final double? targetFermentationTime;

  const FermentationTimerWidget({
    super.key,
    this.initialScenario,
    this.environmentTemperature = 26.0,
    this.environmentHumidity = 60.0,
    this.altitude = 0.0,
    this.ingredients = const [],
    this.recipeTitle,
    this.onTimerComplete,
    // 새로운 발효 설정 매개변수들
    this.targetFermentationTemperature,
    this.targetFermentationHumidity,
    this.targetFermentationTime,
  });

  @override
  State<FermentationTimerWidget> createState() => _FermentationTimerWidgetState();
}

class _FermentationTimerWidgetState extends State<FermentationTimerWidget> {
  late SmartFermentationTimer _timer;
  StreamSubscription<TimerEvent>? _timerSubscription;
  
  // 상태 변수
  TimerState _timerState = TimerState.stopped;
  double _totalProgress = 0.0;
  double _stageProgress = 0.0;
  FermentationStage? _currentStage;
  Duration _remainingTime = Duration.zero;
  Duration _stageRemainingTime = Duration.zero;
  String _statusMessage = '시나리오를 선택하고 타이머를 시작하세요';
  
  // 시나리오 선택
  FermentationScenario? _selectedScenario;
  List<FermentationScenario> _predefinedScenarios = [];
  
  // Phase 3: 실시간 분석 통합
  bool _showRealTimeFeedback = false;
  bool _showNotificationSettings = false;
  double _currentTemp = 26.0;
  double _currentHumidity = 60.0;
  
  // 알림 서비스
  final FermentationNotificationService _notificationService = 
      FermentationNotificationService();

  @override
  void initState() {
    super.initState();
    _timer = SmartFermentationTimer();
    _selectedScenario = widget.initialScenario;
    
    // 알림 서비스 초기화
    _initializeNotificationService();
    
    // Phase 3: 초기 환경 조건 설정
    _currentTemp = widget.environmentTemperature;
    _currentHumidity = widget.environmentHumidity;
    
    // 사용자 환경 조건과 레시피 정보를 기반으로 시나리오 생성
    print('🔍 FermentationTimerWidget 초기화:');
    print('   - 환경 온도: ${widget.environmentTemperature}°C');
    print('   - 환경 습도: ${widget.environmentHumidity}%');
    print('   - 고도: ${widget.altitude}m');
    print('   - 레시피 제목: ${widget.recipeTitle ?? "없음"}');
    print('   - 재료 개수: ${widget.ingredients.length}개');
    if (widget.ingredients.isNotEmpty) {
      print('   - 재료 목록: ${widget.ingredients.map((i) => i['name']).join(', ')}');
    }
    
    _predefinedScenarios = _createPredefinedScenarios(
      environmentTemperature: widget.environmentTemperature,
      environmentHumidity: widget.environmentHumidity,
      altitude: widget.altitude,
      ingredients: widget.ingredients,
      recipeTitle: widget.recipeTitle,
    );
    
    // 쉐프 모드에서 발효 설정이 전달된 경우 커스텀 시나리오 자동 생성
    if (widget.targetFermentationTemperature != null && 
        widget.targetFermentationHumidity != null && 
        widget.targetFermentationTime != null) {
      _createCustomScenarioFromChefMode();
    }
    
    // 초기 시나리오 설정
    if (_selectedScenario != null) {
      _setupScenario(_selectedScenario!);
    }
    
    // 타이머 이벤트 구독
    _timerSubscription = _timer.eventStream.listen(_handleTimerEvent);
  }

  @override
  void didUpdateWidget(FermentationTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 환경 조건이 변경된 경우 시나리오 재생성
    if (widget.environmentTemperature != oldWidget.environmentTemperature ||
        widget.environmentHumidity != oldWidget.environmentHumidity ||
        widget.altitude != oldWidget.altitude) {
      
      // 타이머가 실행 중이 아닐 때만 재생성
      if (_timerState == TimerState.stopped) {
        _predefinedScenarios = _createPredefinedScenarios(
          environmentTemperature: widget.environmentTemperature,
          environmentHumidity: widget.environmentHumidity,
          altitude: widget.altitude,
          ingredients: widget.ingredients,
          recipeTitle: widget.recipeTitle,
        );
        
        // 현재 선택된 시나리오가 기본 시나리오 중 하나라면 업데이트
        if (_selectedScenario != null && _selectedScenario!.id != 'chef_mode_custom') {
          final updatedScenario = _predefinedScenarios.firstWhere(
            (scenario) => scenario.id == _selectedScenario!.id,
            orElse: () => _predefinedScenarios.first,
          );
          _selectedScenario = updatedScenario;
        }
      }
    }
    
    // 쉐프 모드 발효 설정이 변경된 경우 커스텀 시나리오 재생성
    if (widget.targetFermentationTemperature != oldWidget.targetFermentationTemperature ||
        widget.targetFermentationHumidity != oldWidget.targetFermentationHumidity ||
        widget.targetFermentationTime != oldWidget.targetFermentationTime) {
      
      // 타이머가 실행 중이 아닐 때만 재생성
      if (_timerState == TimerState.stopped) {
        if (widget.targetFermentationTemperature != null && 
            widget.targetFermentationHumidity != null && 
            widget.targetFermentationTime != null) {
          _createCustomScenarioFromChefMode();
        }
      }
    }
  }

  @override
  void dispose() {
    _timerSubscription?.cancel();
    super.dispose();
  }

  /// 알림 서비스 초기화
  Future<void> _initializeNotificationService() async {
    try {
      await _notificationService.initialize();
      print('✅ 발효 알림 서비스 초기화 완료');
    } catch (e) {
      print('❌ 발효 알림 서비스 초기화 실패: $e');
    }
  }

  void _setupScenario(FermentationScenario scenario) {

  /// 기본 발효 타이머 시작
  void _startBasicTimer() {
    // 기본 발효 시나리오 생성
    final basicScenario = FermentationScenario(
      id: 'basic',
      name: '기본 발효',
      description: '간단한 발효 설정',
      selectedStages: [FermentationStage.bulk],
      stageConfigs: {
        FermentationStage.bulk: FermentationStageConfig(
          duration: 90.0, // 90분
          temperature: widget.environmentTemperature + 2.0,
          humidity: widget.environmentHumidity + 10.0,
          notes: '기본 발효 설정',
        ),
      },
    );
    
    _setupScenario(basicScenario);
  }
    _timer.setupScenario(
      scenario: scenario,
      environmentTemperature: widget.environmentTemperature,
      environmentHumidity: widget.environmentHumidity,
      altitude: widget.altitude,
    );
    
    setState(() {
      _selectedScenario = scenario;
      _statusMessage = '시나리오 설정 완료: ${_getScenarioDisplayName(scenario)}';
    });
  }

  void _handleTimerEvent(TimerEvent event) {
    setState(() {
      _timerState = _timer.state;
      _totalProgress = _timer.getTotalProgress();
      _stageProgress = _timer.getCurrentStageProgress();
      _currentStage = _timer.currentStage;
      _remainingTime = _timer.getRemainingTime();
      _stageRemainingTime = _timer.getCurrentStageRemainingTime();
      _statusMessage = event.message;
    });

    // 알림 처리
    _handleNotifications(event);

    // 완료 시 콜백 호출
    if (event.type == TimerEventType.completed && widget.onTimerComplete != null) {
      widget.onTimerComplete!();
    }

    // 중요한 이벤트는 스낵바로 표시
    if (event.type == TimerEventType.stageChanged || 
        event.type == TimerEventType.completed ||
        event.type == TimerEventType.warning) {
      _showEventSnackBar(event);
    }
  }

  void _showEventSnackBar(TimerEvent event) {
    Color backgroundColor;
    IconData icon;
    
    switch (event.type) {
      case TimerEventType.completed:
        backgroundColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case TimerEventType.warning:
        backgroundColor = Colors.orange;
        icon = Icons.warning;
        break;
      case TimerEventType.stageChanged:
        backgroundColor = Colors.blue;
        icon = Icons.navigate_next;
        break;
      default:
        backgroundColor = Colors.grey;
        icon = Icons.info;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(event.message)),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 타이머 이벤트에 따른 알림 처리
  Future<void> _handleNotifications(TimerEvent event) async {
    try {
      switch (event.type) {
        case TimerEventType.started:
          if (_currentStage != null) {
            final stageName = _getStageName(_currentStage!);
            final duration = _timer.currentStageDuration;
            await _notificationService.notifyStageStart(
              stageName: stageName,
              duration: duration,
            );
            print('🔔 단계 시작 알림: $stageName (${duration.inMinutes}분)');
          }
          break;

        case TimerEventType.stageChanged:
          if (_currentStage != null) {
            final completedStage = _getPreviousStage(_currentStage!);
            final completedStageName = completedStage != null 
                ? _getStageName(completedStage) 
                : '이전 단계';
            final nextStageName = _getStageName(_currentStage!);
            
            await _notificationService.notifyStageComplete(
              stageName: completedStageName,
              nextStageName: nextStageName,
            );
            print('🔔 단계 완료 알림: $completedStageName → $nextStageName');
          }
          break;

        case TimerEventType.completed:
          await _notificationService.notifyFermentationComplete();
          print('🎉 발효 완료 알림');
          break;

        case TimerEventType.warning:
          await _notificationService.notifyWarning(
            message: event.message,
            urgent: true,
          );
          print('⚠️ 경고 알림: ${event.message}');
          break;

        default:
          // 기타 이벤트는 알림 없음
          break;
      }
    } catch (e) {
      print('❌ 알림 처리 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            _buildHeader(),
            const SizedBox(height: 20),
            
            // 시나리오 선택
            if (_timerState == TimerState.stopped) _buildScenarioSelector(),
            
            // 타이머 디스플레이
            if (_selectedScenario != null) ...[
              _buildTimerDisplay(),
              const SizedBox(height: 20),
              _buildControlButtons(),
              const SizedBox(height: 16),
              
              // Phase 3: 실시간 피드백 토글
              if (_timerState == TimerState.running) ...[
                _buildRealTimeFeedbackToggle(),
                const SizedBox(height: 16),
              ],
              
              // Phase 3: 실시간 피드백 또는 기본 단계 정보
              if (_showRealTimeFeedback && _timerState == TimerState.running)
                _buildRealTimeFeedback()
              else
                _buildStageInfo(),
            ],
            
            // 알림 설정
            if (_showNotificationSettings) ...[
              const SizedBox(height: 16),
              const NotificationSettingsWidget(),
            ],
            
            const SizedBox(height: 16),
            _buildStatusMessage(),
            const SizedBox(height: 20), // 하단 여백 추가
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.timer,
          size: 32,
          color: _getTimerColor(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '스마트 발효 타이머',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_selectedScenario != null)
                Text(
                  _getScenarioDisplayName(_selectedScenario!),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          tooltip: '더 많은 옵션',
          onSelected: (value) {
            switch (value) {
              case 'notifications':
                setState(() {
                  _showNotificationSettings = !_showNotificationSettings;
                });
                break;
              case 'stop':
                _timer.stop();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'notifications',
              child: Row(
                children: [
                  const Icon(Icons.notifications, size: 16),
                  const SizedBox(width: 8),
                  Text(_showNotificationSettings ? '알림 설정 숨기기' : '알림 설정'),
                ],
              ),
            ),
            if (_timerState != TimerState.stopped)
              const PopupMenuItem(
                value: 'stop',
                child: Row(
                  children: [
                    Icon(Icons.stop, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('타이머 정지', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildScenarioSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '발효 설정',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // 쉐프 모드 커스텀 시나리오 (있는 경우 우선 표시)
        if (_selectedScenario?.id == 'chef_mode_custom') ...[
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: Colors.orange.shade50,
            child: ListTile(
              dense: true,
              leading: Icon(Icons.star, color: Colors.orange.shade600, size: 20),
              title: Text(
                '🧑‍🍳 쉐프 모드 설정',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
              subtitle: Text(
                '${widget.targetFermentationTemperature?.toInt()}°C • ${widget.targetFermentationHumidity?.toInt()}% • ${widget.targetFermentationTime?.toInt()}분',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange.shade600,
                ),
              ),
              trailing: Icon(Icons.check_circle, color: Colors.orange.shade600, size: 20),
              onTap: () => _setupScenario(_selectedScenario!),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
        ],
        
        // 스크롤 가능한 시나리오 목록
        SizedBox(
          height: _selectedScenario?.id == 'chef_mode_custom' ? 200 : 300, // 쉐프 모드 시나리오가 있으면 높이 조정
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _predefinedScenarios.length,
            itemBuilder: (context, index) {
              final scenario = _predefinedScenarios[index];
              final isSelected = _selectedScenario?.id == scenario.id;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: isSelected ? Colors.blue.shade50 : null,
                child: ListTile(
                  dense: true,
                  leading: isSelected ? Icon(Icons.check_circle, color: Colors.blue.shade600, size: 20) : null,
                  title: Text(
                    _getScenarioDisplayName(scenario),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.blue.shade700 : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${scenario.selectedStages.length}단계 • ${scenario.totalEstimatedTime.toStringAsFixed(0)}분',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.blue.shade600 : null,
                        ),
                      ),
                      if (scenario.description != null && scenario.description!.isNotEmpty)
                        Text(
                          scenario.description!,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios, 
                    size: 16,
                    color: isSelected ? Colors.blue.shade600 : null,
                  ),
                  onTap: () => _setupScenario(scenario),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton.icon(
            onPressed: _showCustomScenarioDialog,
            icon: const Icon(Icons.add),
            label: const Text('커스텀 시나리오 만들기'),
          ),
        ),
      ],
    );
  }

  Widget _buildTimerDisplay() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 전체 진행률
            _buildProgressIndicator(
              '전체 진행률',
              _totalProgress,
              _formatDuration(_remainingTime),
              Colors.blue,
            ),
            const SizedBox(height: 16),
            
            // 현재 단계 진행률
            if (_currentStage != null)
              _buildProgressIndicator(
                _getStageName(_currentStage!),
                _stageProgress,
                _formatDuration(_stageRemainingTime),
                Colors.green,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(String title, double progress, String timeText, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
        const SizedBox(height: 4),
        Text(
          '남은 시간: $timeText',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        // 시작/일시정지/재시작 버튼
        ElevatedButton.icon(
          onPressed: _getMainButtonAction(),
          icon: Icon(_getMainButtonIcon(), size: 18),
          label: Text(_getMainButtonText()),
          style: ElevatedButton.styleFrom(
            backgroundColor: _getTimerColor(),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        
        // 이전 단계 버튼
        if (_timerState == TimerState.running && _timer.currentStageIndex > 0)
          OutlinedButton.icon(
            onPressed: _timer.previousStage,
            icon: const Icon(Icons.skip_previous, size: 16),
            label: const Text('이전'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        
        // 다음 단계 버튼
        if (_timerState == TimerState.running && _timer.currentStageIndex < _timer.currentScenario!.selectedStages.length - 1)
          OutlinedButton.icon(
            onPressed: _timer.nextStage,
            icon: const Icon(Icons.skip_next, size: 16),
            label: const Text('다음'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
      ],
    );
  }

  Widget _buildStageInfo() {
    if (_selectedScenario == null) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '발효 단계',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_timer.currentStageIndex + 1}/${_selectedScenario!.selectedStages.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 컴팩트한 단계 목록
            SizedBox(
              height: 150, // 최대 높이 제한
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _selectedScenario!.selectedStages.length,
                itemBuilder: (context, index) {
                  final stage = _selectedScenario!.selectedStages[index];
                  final config = _selectedScenario!.stageConfigs[stage];
                  final isActive = index == _timer.currentStageIndex;
                  final isCompleted = index < _timer.currentStageIndex;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          isCompleted ? Icons.check_circle : 
                          isActive ? Icons.radio_button_checked : 
                          Icons.radio_button_unchecked,
                          color: isCompleted ? Colors.green : 
                                 isActive ? Colors.blue : Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getStageName(stage),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                              color: isActive ? Colors.blue : null,
                            ),
                          ),
                        ),
                        Text(
                          '${config?.duration.toStringAsFixed(0) ?? '0'}분',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (isActive && _timerState == TimerState.running)
                          IconButton(
                            onPressed: () => _showTimeAdjustDialog(stage, config!),
                            icon: const Icon(Icons.edit, size: 12),
                            tooltip: '시간 조정',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _statusMessage,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods

  Color _getTimerColor() {
    switch (_timerState) {
      case TimerState.running:
        return Colors.green;
      case TimerState.paused:
        return Colors.orange;
      case TimerState.completed:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  VoidCallback? _getMainButtonAction() {
    switch (_timerState) {
      case TimerState.stopped:
        return _selectedScenario != null ? _timer.start : null;
      case TimerState.running:
        return _timer.pause;
      case TimerState.paused:
        return _timer.resume;
      case TimerState.completed:
        return _timer.stop;
    }
  }

  IconData _getMainButtonIcon() {
    switch (_timerState) {
      case TimerState.stopped:
        return Icons.play_arrow;
      case TimerState.running:
        return Icons.pause;
      case TimerState.paused:
        return Icons.play_arrow;
      case TimerState.completed:
        return Icons.refresh;
    }
  }

  String _getMainButtonText() {
    switch (_timerState) {
      case TimerState.stopped:
        return '시작';
      case TimerState.running:
        return '일시정지';
      case TimerState.paused:
        return '재시작';
      case TimerState.completed:
        return '다시 시작';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}시간 ${minutes}분';
    } else if (minutes > 0) {
      return '${minutes}분 ${seconds}초';
    } else {
      return '${seconds}초';
    }
  }

  String _getScenarioDisplayName(FermentationScenario scenario) {
    // 시나리오에 이름이 있으면 그것을 사용
    if (scenario.name != null && scenario.name!.isNotEmpty) {
      return scenario.name!;
    }
    
    // 기본 이름 사용
    switch (scenario.scenarioType) {
      case FermentationScenarioType.standard:
        return '표준 발효 (1차 + 최종)';
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

  /// 이전 단계 가져오기 (단계 완료 알림용)
  FermentationStage? _getPreviousStage(FermentationStage currentStage) {
    if (_selectedScenario == null) return null;
    
    final stages = _selectedScenario!.selectedStages;
    final currentIndex = stages.indexOf(currentStage);
    
    if (currentIndex > 0) {
      return stages[currentIndex - 1];
    }
    
    return null; // 첫 번째 단계인 경우
  }

  void _showCustomScenarioDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdvancedScenarioSelector(
          onScenarioSelected: (scenario) {
            _setupScenario(scenario);
            Navigator.pop(context);
          },
          ingredients: widget.ingredients,
          environmentTemperature: widget.environmentTemperature,
          environmentHumidity: widget.environmentHumidity,
          altitude: widget.altitude,
          recipeTitle: widget.recipeTitle,
        ),
      ),
    );
  }

  void _showTimeAdjustDialog(FermentationStage stage, FermentationStageConfig config) {
    final controller = TextEditingController(text: config.duration.toStringAsFixed(0));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_getStageName(stage)} 시간 조정'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '시간 (분)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              final newMinutes = double.tryParse(controller.text);
              if (newMinutes != null && newMinutes > 0) {
                _timer.adjustCurrentStageTime(Duration(minutes: newMinutes.toInt()));
                Navigator.pop(context);
              }
            },
            child: const Text('적용'),
          ),
        ],
      ),
    );
  }
  
  // Phase 3: 새로운 메서드들
  
  /// 실시간 피드백 토글 위젯
  Widget _buildRealTimeFeedbackToggle() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.analytics, color: Colors.blue),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                '실시간 분석',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Switch(
              value: _showRealTimeFeedback,
              onChanged: (value) {
                setState(() {
                  _showRealTimeFeedback = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
  
  /// 실시간 피드백 위젯
  Widget _buildRealTimeFeedback() {
    if (_currentStage == null) return const SizedBox.shrink();
    
    return RealTimeFeedbackWidget(
      elapsedTime: _getElapsedMinutes(),
      totalTime: _getTotalMinutes(),
      currentTemp: _currentTemp,
      currentHumidity: _currentHumidity,
      targetTemp: widget.environmentTemperature,
      targetHumidity: widget.environmentHumidity,
      stage: _currentStage!,
      onAdjustmentNeeded: () {
        // 조정 필요 시 알림 (안전하게)
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔧 환경 조건 조정이 필요합니다'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          });
        }
      },
      onStatusUpdate: (status) {
        // 상태 업데이트 시 처리 (안전하게)
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _statusMessage = status;
              });
            }
          });
        }
      },
    );
  }
  
  /// 환경 조건 업데이트
  void _updateEnvironmentalConditions(double temp, double humidity) {
    setState(() {
      _currentTemp = temp;
      _currentHumidity = humidity;
    });
    
    // 타이머에 환경 조건 업데이트
    _timer.updateEnvironmentalConditions(
      temperature: temp,
      humidity: humidity,
    );
  }
  
  /// 경과 시간 (분)
  double _getElapsedMinutes() {
    if (_timerState == TimerState.stopped) return 0.0;
    
    // 타이머에서 경과 시간 가져오기
    final remainingTime = _remainingTime;
    final totalTime = _getTotalMinutes();
    return totalTime - remainingTime.inMinutes.toDouble();
  }
  
  /// 총 예상 시간 (분)
  double _getTotalMinutes() {
    if (_selectedScenario == null) return 0.0;
    
    double total = 0.0;
    for (final stage in _selectedScenario!.selectedStages) {
      final config = _selectedScenario!.stageConfigs[stage];
      if (config != null) {
        total += config.duration;
      }
    }
    return total;
  }
  
  /// 간단한 발효 설정 생성 (기본 제공 시나리오 제거)
  static List<FermentationScenario> _createPredefinedScenarios({
    required double environmentTemperature,
    required double environmentHumidity,
    required double altitude,
    List<Map<String, dynamic>>? ingredients,
    String? recipeTitle,
  }) {
    // 기본 제공 시나리오 제거 - 빈 리스트 반환
    return [];
  }

  /// 쉐프 모드에서 전달받은 발효 설정으로 커스텀 시나리오 생성
  void _createCustomScenarioFromChefMode() {
    if (widget.targetFermentationTemperature == null || 
        widget.targetFermentationHumidity == null || 
        widget.targetFermentationTime == null) {
      return;
    }
    
    // 쉐프 모드 설정을 기반으로 커스텀 시나리오 생성
    final customScenario = FermentationScenario(
      id: 'chef_mode_custom',
      name: '쉐프 모드 설정',
      description: '쉐프 모드에서 설정한 발효 조건 (${widget.targetFermentationTemperature!.toInt()}°C, ${widget.targetFermentationHumidity!.toInt()}%, ${widget.targetFermentationTime!.toInt()}분)',
      selectedStages: [FermentationStage.bulk], // 기본적으로 1차 발효만
      stageConfigs: {
        FermentationStage.bulk: FermentationStageConfig(
          duration: widget.targetFermentationTime!,
          temperature: widget.targetFermentationTemperature!,
          humidity: widget.targetFermentationHumidity!,
          notes: '쉐프 모드 발효 설정',
        ),
      },
      environmentalConditions: EnvironmentalConditions(
        temperature: widget.environmentTemperature,
        humidity: widget.environmentHumidity,
        altitude: widget.altitude,
      ),
    );
    
    // 생성된 커스텀 시나리오를 선택된 시나리오로 설정
    setState(() {
      _selectedScenario = customScenario;
      _statusMessage = '쉐프 모드 발효 설정이 적용되었습니다 (${widget.targetFermentationTemperature!.toInt()}°C, ${widget.targetFermentationTime!.toInt()}분)';
    });
    
    print('🔧 쉐프 모드 커스텀 시나리오 생성됨:');
    print('   - 발효 온도: ${widget.targetFermentationTemperature}°C');
    print('   - 발효 습도: ${widget.targetFermentationHumidity}%');
    print('   - 발효 시간: ${widget.targetFermentationTime}분');
    print('   - 환경 온도: ${widget.environmentTemperature}°C');
    print('   - 환경 습도: ${widget.environmentHumidity}%');
    print('   - 고도: ${widget.altitude}m');
  }

  /// 레시피 정보 기반 발효 시간 조정 계산
  RecipeAdjustment _calculateRecipeBasedAdjustment(
    List<Map<String, dynamic>>? ingredients,
    String? recipeTitle,
  ) {
    print('🔍 레시피 조정 계산 시작:');
    print('   - 재료: ${ingredients?.length ?? 0}개');
    print('   - 레시피 제목: ${recipeTitle ?? "없음"}');
    
    if (ingredients == null || ingredients.isEmpty) {
      // 재료가 없어도 레시피 제목으로 조정 시도
      if (recipeTitle != null) {
        double titleTimeFactor = 1.0;
        List<String> titleReasons = [];
        
        final title = recipeTitle.toLowerCase();
        if (title.contains('바게트') || title.contains('baguette')) {
          titleTimeFactor *= 1.4;
          titleReasons.add('바게트 레시피');
        } else if (title.contains('식빵') || title.contains('토스트') || title.contains('bread')) {
          titleTimeFactor *= 1.1;
          titleReasons.add('식빵 레시피');
        } else if (title.contains('쫄깃')) {
          titleTimeFactor *= 1.2;
          titleReasons.add('쫄깃한 식감 레시피');
        } else if (title.contains('피자') || title.contains('pizza')) {
          titleTimeFactor *= 0.8;
          titleReasons.add('피자 레시피');
        }
        
        if (titleReasons.isNotEmpty) {
          titleTimeFactor = titleTimeFactor.clamp(0.5, 2.0);
          final result = RecipeAdjustment(
            timeFactor: titleTimeFactor,
            reason: titleReasons.join(', '),
          );
          print('   - 제목 기반 조정: ${result.timeFactor} (${result.reason})');
          return result;
        }
      }
      
      print('   - 결과: 기본 설정 (재료 정보 없음)');
      return RecipeAdjustment(
        timeFactor: 1.0,
        reason: '기본 설정 (재료 정보 없음)',
      );
    }

    double timeFactor = 1.0;
    List<String> reasons = [];

    // 밀가루 종류별 조정
    final flour = ingredients.firstWhere(
      (ingredient) => ingredient['name']?.toString().contains('밀가루') == true ||
                     ingredient['name']?.toString().contains('flour') == true,
      orElse: () => <String, dynamic>{},
    );
    
    if (flour.isNotEmpty) {
      final flourName = flour['name']?.toString().toLowerCase() ?? '';
      if (flourName.contains('강력분') || flourName.contains('bread')) {
        timeFactor *= 1.2; // 강력분은 발효 시간 20% 증가
        reasons.add('강력분 사용');
      } else if (flourName.contains('통밀') || flourName.contains('whole')) {
        timeFactor *= 1.3; // 통밀가루는 발효 시간 30% 증가
        reasons.add('통밀가루 사용');
      }
    }

    // 이스트 양에 따른 조정
    final yeast = ingredients.firstWhere(
      (ingredient) => ingredient['name']?.toString().contains('이스트') == true ||
                     ingredient['name']?.toString().contains('yeast') == true,
      orElse: () => <String, dynamic>{},
    );
    
    if (yeast.isNotEmpty) {
      final yeastAmount = double.tryParse(yeast['amount']?.toString() ?? '0') ?? 0;
      if (yeastAmount > 10) { // 10g 이상
        timeFactor *= 0.8; // 이스트 많으면 발효 시간 20% 단축
        reasons.add('이스트 다량 사용');
      } else if (yeastAmount < 5) { // 5g 미만
        timeFactor *= 1.3; // 이스트 적으면 발효 시간 30% 증가
        reasons.add('이스트 소량 사용');
      }
    }

    // 설탕/꿀 등 당분에 따른 조정
    final sugar = ingredients.firstWhere(
      (ingredient) => ingredient['name']?.toString().contains('설탕') == true ||
                     ingredient['name']?.toString().contains('꿀') == true ||
                     ingredient['name']?.toString().contains('sugar') == true ||
                     ingredient['name']?.toString().contains('honey') == true,
      orElse: () => <String, dynamic>{},
    );
    
    if (sugar.isNotEmpty) {
      timeFactor *= 0.9; // 당분이 있으면 발효 시간 10% 단축
      reasons.add('당분 첨가');
    }

    // 소금에 따른 조정
    final salt = ingredients.firstWhere(
      (ingredient) => ingredient['name']?.toString().contains('소금') == true ||
                     ingredient['name']?.toString().contains('salt') == true,
      orElse: () => <String, dynamic>{},
    );
    
    if (salt.isNotEmpty) {
      final saltAmount = double.tryParse(salt['amount']?.toString() ?? '0') ?? 0;
      if (saltAmount > 8) { // 8g 이상
        timeFactor *= 1.1; // 소금 많으면 발효 시간 10% 증가
        reasons.add('소금 다량');
      }
    }

    // 레시피 제목 기반 조정
    if (recipeTitle != null) {
      final title = recipeTitle.toLowerCase();
      if (title.contains('바게트') || title.contains('baguette')) {
        timeFactor *= 1.4; // 바게트는 긴 발효 필요
        reasons.add('바게트 레시피');
      } else if (title.contains('식빵') || title.contains('토스트') || title.contains('bread')) {
        timeFactor *= 1.1; // 식빵은 약간 긴 발효
        reasons.add('식빵 레시피');
      } else if (title.contains('쫄깃')) {
        timeFactor *= 1.2; // 쫄깃한 식감을 위한 긴 발효
        reasons.add('쫄깃한 식감 레시피');
      } else if (title.contains('피자') || title.contains('pizza')) {
        timeFactor *= 0.8; // 피자는 짧은 발효
        reasons.add('피자 레시피');
      }
    }

    // 최종 조정 (0.5 ~ 2.0 범위로 제한)
    timeFactor = timeFactor.clamp(0.5, 2.0);

    final result = RecipeAdjustment(
      timeFactor: timeFactor,
      reason: reasons.isEmpty ? '기본 설정 (조정 없음)' : reasons.join(', '),
    );
    
    print('   - 최종 시간 계수: ${result.timeFactor}');
    print('   - 조정 이유: ${result.reason}');
    
    return result;
  }
}

/// 레시피 기반 조정 결과
class RecipeAdjustment {
  final double timeFactor;
  final String reason;

  RecipeAdjustment({
    required this.timeFactor,
    required this.reason,
  });
}