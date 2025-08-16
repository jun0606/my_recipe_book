import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/fermentation_diagnostic_system.dart' as diagnostic;
import '../../services/real_time_fermentation_analyzer.dart';
import '../../models/fermentation_scenario.dart';
import '../../models/sous_chef_models.dart';

/// 실시간 발효 피드백 위젯
/// 발효 진행 중 실시간으로 상태를 분석하고 피드백을 제공하는 UI
class RealTimeFeedbackWidget extends StatefulWidget {
  final double elapsedTime;
  final double totalTime;
  final double currentTemp;
  final double currentHumidity;
  final double targetTemp;
  final double targetHumidity;
  final FermentationStage stage;
  final VoidCallback? onAdjustmentNeeded;
  final Function(String)? onStatusUpdate;

  const RealTimeFeedbackWidget({
    super.key,
    required this.elapsedTime,
    required this.totalTime,
    required this.currentTemp,
    required this.currentHumidity,
    required this.targetTemp,
    required this.targetHumidity,
    required this.stage,
    this.onAdjustmentNeeded,
    this.onStatusUpdate,
  });

  @override
  State<RealTimeFeedbackWidget> createState() => _RealTimeFeedbackWidgetState();
}

class _RealTimeFeedbackWidgetState extends State<RealTimeFeedbackWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  
  diagnostic.FermentationDiagnosis? _currentDiagnosis;
  Timer? _analysisTimer;
  
  @override
  void initState() {
    super.initState();
    
    // 애니메이션 컨트롤러 초기화
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));
    
    _pulseController.repeat(reverse: true);
    
    // 빌드 완료 후 초기 분석 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performAnalysis();
      _startPeriodicAnalysis();
    });
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    _analysisTimer?.cancel();
    super.dispose();
  }
  
  @override
  void didUpdateWidget(RealTimeFeedbackWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 환경 조건이 변경되면 즉시 재분석
    if (oldWidget.currentTemp != widget.currentTemp ||
        oldWidget.currentHumidity != widget.currentHumidity ||
        oldWidget.elapsedTime != widget.elapsedTime) {
      _performAnalysis();
    }
  }
  
  void _startPeriodicAnalysis() {
    _analysisTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _performAnalysis();
    });
  }
  
  void _performAnalysis() {
    final diagnosis = diagnostic.FermentationDiagnosticSystem.diagnoseFermentationState(
      elapsedTime: widget.elapsedTime,
      totalTime: widget.totalTime,
      currentTemp: widget.currentTemp,
      currentHumidity: widget.currentHumidity,
      targetTemp: widget.targetTemp,
      targetHumidity: widget.targetHumidity,
      stage: widget.stage,
    );
    
    setState(() {
      _currentDiagnosis = diagnosis;
    });
    
    // 진행률 애니메이션 업데이트
    double progress = widget.elapsedTime / widget.totalTime;
    _progressController.animateTo(progress.clamp(0.0, 1.0));
    
    // 상태 업데이트 콜백 호출 (안전하게 처리)
    if (widget.onStatusUpdate != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onStatusUpdate!(_getStatusMessage(diagnosis));
        }
      });
    }
    
    // 조정 필요 시 콜백 호출 (안전하게 처리)
    if (diagnosis.riskAssessment.overallRisk == diagnostic.RiskLevel.high && 
        widget.onAdjustmentNeeded != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onAdjustmentNeeded!();
        }
      });
    }
  }
  
  String _getStatusMessage(diagnostic.FermentationDiagnosis diagnosis) {
    switch (diagnosis.overallState) {
      case FermentationState.optimal:
        return '발효가 완벽하게 진행되고 있습니다';
      case FermentationState.readyToBake:
        return '발효가 완료되어 굽기 준비가 되었습니다';
      case FermentationState.underFermented:
        return '발효가 부족합니다. 더 기다려주세요';
      case FermentationState.overFermented:
        return '과발효 위험! 즉시 다음 단계로 진행하세요';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_currentDiagnosis == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상태 헤더
          _buildStatusHeader(),
          const SizedBox(height: 16),
          
          // 진행률 표시
          _buildProgressSection(),
          const SizedBox(height: 16),
          
          // 환경 조건 상태
          _buildEnvironmentalStatus(),
          const SizedBox(height: 16),
          
          // 실시간 조언
          _buildRealTimeAdvice(),
          const SizedBox(height: 16),
          
          // 위험 평가
          if (_currentDiagnosis!.riskAssessment.risks.isNotEmpty)
            _buildRiskAssessment(),
          
          const SizedBox(height: 16),
          
          // 조치 방안
          _buildActionRecommendations(),
        ],
      ),
    );
  }
  
  Widget _buildStatusHeader() {
    final diagnosis = _currentDiagnosis!;
    Color statusColor = _getStatusColor(diagnosis.overallState);
    IconData statusIcon = _getStatusIcon(diagnosis.overallState);
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Icon(
                    statusIcon,
                    size: 32,
                    color: statusColor,
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getStatusTitle(diagnosis.overallState),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '신뢰도: ${(diagnosis.confidence * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (diagnosis.diagnosticNotes.isNotEmpty)
                    Text(
                      diagnosis.diagnosticNotes.first,
                      style: const TextStyle(fontSize: 14),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressSection() {
    double currentProgress = widget.elapsedTime / widget.totalTime;
    double realTimeProgress = RealTimeFermentationAnalyzer.calculateRealTimeProgress(
      elapsedTime: widget.elapsedTime,
      totalTime: widget.totalTime,
      currentTemp: widget.currentTemp,
      currentHumidity: widget.currentHumidity,
      targetTemp: widget.targetTemp,
      targetHumidity: widget.targetHumidity,
    );
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '발효 진행률',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // 시간 기반 진행률
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('시간 진행률'),
                Text('${(currentProgress * 100).toStringAsFixed(1)}%'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: currentProgress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            
            const SizedBox(height: 12),
            
            // 실제 발효 진행률
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('실제 발효율'),
                Text('${(realTimeProgress * 100).toStringAsFixed(1)}%'),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: (realTimeProgress * _progressAnimation.value).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    realTimeProgress > currentProgress ? Colors.orange : Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEnvironmentalStatus() {
    final envAnalysis = _currentDiagnosis!.environmentalAnalysis;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '환경 조건',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // 온도 상태
            _buildEnvironmentalItem(
              '온도',
              '${widget.currentTemp.toStringAsFixed(1)}°C',
              '목표: ${widget.targetTemp.toStringAsFixed(1)}°C',
              envAnalysis.temperatureStatus,
              envAnalysis.temperatureScore,
            ),
            
            const SizedBox(height: 8),
            
            // 습도 상태
            _buildEnvironmentalItem(
              '습도',
              '${widget.currentHumidity.toStringAsFixed(0)}%',
              '목표: ${widget.targetHumidity.toStringAsFixed(0)}%',
              envAnalysis.humidityStatus,
              envAnalysis.humidityScore,
            ),
            
            // 환경 문제점
            if (envAnalysis.issues.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                '주의사항',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 4),
              ...envAnalysis.issues.map((issue) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 2),
                child: Row(
                  children: [
                    const Icon(Icons.warning, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Expanded(child: Text(issue, style: const TextStyle(fontSize: 12))),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildEnvironmentalItem(
    String label,
    String current,
    String target,
    String status,
    double score,
  ) {
    Color statusColor = score > 0.8 ? Colors.green :
                       score > 0.6 ? Colors.orange : Colors.red;
    
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label),
        ),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(current, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(target, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildRealTimeAdvice() {
    final efficiency = RealTimeFermentationAnalyzer.analyzeFermentationEfficiency(
      elapsedTime: widget.elapsedTime,
      expectedTime: widget.totalTime,
      currentTemp: widget.currentTemp,
      currentHumidity: widget.currentHumidity,
      targetTemp: widget.targetTemp,
      targetHumidity: widget.targetHumidity,
    );
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber),
                const SizedBox(width: 8),
                const Text(
                  '실시간 조언',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 발효 효율성
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '발효 속도: ${efficiency.status}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '효율성: ${(efficiency.efficiency * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // 추천사항
            ...efficiency.recommendations.map((recommendation) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.arrow_right, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRiskAssessment() {
    final riskAssessment = _currentDiagnosis!.riskAssessment;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning,
                  color: _getRiskColor(riskAssessment.overallRisk),
                ),
                const SizedBox(width: 8),
                Text(
                  '위험 평가',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getRiskColor(riskAssessment.overallRisk),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            ...riskAssessment.risks.map((risk) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getRiskColor(risk.level).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getRiskColor(risk.level).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    risk.description,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getRiskColor(risk.level),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    risk.impact,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '발생 확률: ${(risk.probability * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionRecommendations() {
    final actions = _currentDiagnosis!.actionRecommendations;
    
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.checklist, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  '권장 조치',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            ...actions.map((action) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: Icon(
                  _getActionIcon(action.type),
                  color: _getPriorityColor(action.priority),
                ),
                title: Text(
                  action.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getPriorityColor(action.priority),
                  ),
                ),
                subtitle: Text(action.description),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '구체적 단계:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...action.specificSteps.asMap().entries.map((entry) => 
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${entry.key + 1}. '),
                                Expanded(child: Text(entry.value)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
  
  // Helper methods
  Color _getStatusColor(FermentationState state) {
    switch (state) {
      case FermentationState.optimal:
        return Colors.green;
      case FermentationState.readyToBake:
        return Colors.blue;
      case FermentationState.underFermented:
        return Colors.orange;
      case FermentationState.overFermented:
        return Colors.red;
    }
  }
  
  IconData _getStatusIcon(FermentationState state) {
    switch (state) {
      case FermentationState.optimal:
        return Icons.check_circle;
      case FermentationState.readyToBake:
        return Icons.local_fire_department;
      case FermentationState.underFermented:
        return Icons.hourglass_empty;
      case FermentationState.overFermented:
        return Icons.warning;
    }
  }
  
  String _getStatusTitle(FermentationState state) {
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
  
  Color _getRiskColor(diagnostic.RiskLevel level) {
    switch (level) {
      case diagnostic.RiskLevel.high:
        return Colors.red;
      case diagnostic.RiskLevel.medium:
        return Colors.orange;
      case diagnostic.RiskLevel.low:
        return Colors.green;
    }
  }
  
  Color _getPriorityColor(diagnostic.Priority priority) {
    switch (priority) {
      case diagnostic.Priority.high:
        return Colors.red;
      case diagnostic.Priority.medium:
        return Colors.orange;
      case diagnostic.Priority.low:
        return Colors.blue;
    }
  }
  
  IconData _getActionIcon(diagnostic.ActionType type) {
    switch (type) {
      case diagnostic.ActionType.environmental:
        return Icons.thermostat;
      case diagnostic.ActionType.timing:
        return Icons.timer;
      case diagnostic.ActionType.technique:
        return Icons.pan_tool;
      case diagnostic.ActionType.monitoring:
        return Icons.visibility;
    }
  }
}