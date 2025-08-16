/// 발효기 설정 가이드 위젯 - 과학적 최적화 UI
/// 레시피 분석을 통해 최적의 온도, 습도, 시간을 제공

import 'package:flutter/material.dart';
import '../../services/fermenter_optimization_guide.dart';
import '../../models/fermentation_scenario_v2.dart';
import '../../models/sous_chef_models.dart';

class FermenterSettingsGuideWidget extends StatefulWidget {
  final RecipeAnalysis recipe;
  final FermentationStageType stageType;
  final Function(FermenterOptimalSettings) onSettingsApplied;

  const FermenterSettingsGuideWidget({
    Key? key,
    required this.recipe,
    required this.stageType,
    required this.onSettingsApplied,
  }) : super(key: key);

  @override
  State<FermenterSettingsGuideWidget> createState() => _FermenterSettingsGuideWidgetState();
}

class _FermenterSettingsGuideWidgetState extends State<FermenterSettingsGuideWidget> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  FermenterOptimalSettings? _optimalSettings;
  bool _isLoading = true;
  bool _showAdvancedSettings = false;
  
  // 사용자 조정 가능한 설정값
  double _temperatureAdjustment = 0.0;
  double _humidityAdjustment = 0.0;
  double _timeMultiplier = 1.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _calculateOptimalSettings();
  }

  Future<void> _calculateOptimalSettings() async {
    try {
      final settings = FermenterOptimizationGuide.calculateOptimalSettings(
        recipe: widget.recipe,
        stageType: widget.stageType,
      );
      
      setState(() {
        _optimalSettings = settings;
        _isLoading = false;
      });
      
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('설정 계산 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_getStageTitle()} 최적 설정'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _optimalSettings == null
              ? _buildErrorState()
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildSettingsContent(),
                ),
      bottomNavigationBar: _optimalSettings != null
          ? _buildBottomActionBar()
          : null,
    );
  }

  Widget _buildSettingsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),
          _buildOptimalSettingsCard(),
          const SizedBox(height: 16),
          _buildScientificExplanationCard(),
          const SizedBox(height: 16),
          _buildAdjustmentCard(),
          const SizedBox(height: 16),
          _buildWarningsCard(),
          const SizedBox(height: 16),
          _buildTipsCard(),
          const SizedBox(height: 80), // 하단 버튼 공간
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.green.shade700, Colors.green.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getStageIcon(),
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getStageTitle(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStageDescription(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimalSettingsCard() {
    final adjustedSettings = _getAdjustedSettings();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  '최적 설정값',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '과학적 근거',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 온도 설정
            _buildSettingItem(
              icon: Icons.thermostat,
              title: '온도',
              value: '${adjustedSettings.temperature.toStringAsFixed(1)}°C',
              originalValue: _optimalSettings!.temperature != adjustedSettings.temperature
                  ? '(원래: ${_optimalSettings!.temperature.toStringAsFixed(1)}°C)'
                  : null,
              color: Colors.red,
              description: '발효 속도와 품질을 결정하는 핵심 요소',
            ),
            
            const Divider(height: 32),
            
            // 습도 설정
            _buildSettingItem(
              icon: Icons.water_drop,
              title: '습도',
              value: '${adjustedSettings.humidity.toStringAsFixed(0)}%',
              originalValue: _optimalSettings!.humidity != adjustedSettings.humidity
                  ? '(원래: ${_optimalSettings!.humidity.toStringAsFixed(0)}%)'
                  : null,
              color: Colors.blue,
              description: '반죽 표면 건조를 방지하고 발효 환경 유지',
            ),
            
            const Divider(height: 32),
            
            // 시간 설정
            _buildSettingItem(
              icon: Icons.timer,
              title: '시간',
              value: _formatDuration(adjustedSettings.duration),
              originalValue: _optimalSettings!.duration != adjustedSettings.duration
                  ? '(원래: ${_formatDuration(_optimalSettings!.duration)})'
                  : null,
              color: Colors.orange,
              description: '레시피와 환경에 최적화된 발효 시간',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String value,
    String? originalValue,
    required Color color,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (originalValue != null) ...[
                const SizedBox(height: 2),
                Text(
                  originalValue,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScientificExplanationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.science, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  '과학적 근거',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._optimalSettings!.explanations.entries.map((entry) => 
              _buildExplanationItem(entry.key, entry.value)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationItem(String key, String explanation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            key,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            explanation,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustmentCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune, color: Colors.indigo),
                const SizedBox(width: 8),
                const Text(
                  '미세 조정',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showAdvancedSettings = !_showAdvancedSettings;
                    });
                  },
                  child: Text(_showAdvancedSettings ? '간단히 보기' : '고급 설정'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_showAdvancedSettings) ...[
              // 온도 조정
              _buildAdjustmentSlider(
                title: '온도 조정',
                value: _temperatureAdjustment,
                min: -5.0,
                max: 5.0,
                divisions: 20,
                unit: '°C',
                onChanged: (value) {
                  setState(() {
                    _temperatureAdjustment = value;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // 습도 조정
              _buildAdjustmentSlider(
                title: '습도 조정',
                value: _humidityAdjustment,
                min: -10.0,
                max: 10.0,
                divisions: 20,
                unit: '%',
                onChanged: (value) {
                  setState(() {
                    _humidityAdjustment = value;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // 시간 배율
              _buildAdjustmentSlider(
                title: '시간 배율',
                value: _timeMultiplier,
                min: 0.5,
                max: 2.0,
                divisions: 15,
                unit: 'x',
                onChanged: (value) {
                  setState(() {
                    _timeMultiplier = value;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // 리셋 버튼
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _temperatureAdjustment = 0.0;
                      _humidityAdjustment = 0.0;
                      _timeMultiplier = 1.0;
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('기본값으로 리셋'),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '개인 취향이나 특별한 환경에 맞춰 설정을 미세 조정할 수 있습니다. '
                  '고급 설정을 열어 온도, 습도, 시간을 조절해보세요.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdjustmentSlider({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${value >= 0 ? '+' : ''}${value.toStringAsFixed(1)}$unit',
              style: TextStyle(
                color: value == 0 ? Colors.grey : Colors.indigo,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildWarningsCard() {
    if (_optimalSettings!.warnings.isEmpty) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  '주의사항',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._optimalSettings!.warnings.map((warning) => 
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange.shade700, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warning,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    if (_optimalSettings!.tips.isEmpty) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tips_and_updates, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  '프로 팁',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._optimalSettings!.tips.map((tip) => 
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.green.shade700, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                _showPreviewDialog();
              },
              icon: const Icon(Icons.preview),
              label: const Text('미리보기'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                final adjustedSettings = _getAdjustedSettings();
                widget.onSettingsApplied(adjustedSettings);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check),
              label: const Text('설정 적용'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '설정을 계산할 수 없습니다',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '레시피 정보를 확인하고 다시 시도해주세요',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _calculateOptimalSettings();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  FermenterOptimalSettings _getAdjustedSettings() {
    if (_optimalSettings == null) return _optimalSettings!;
    
    return FermenterOptimalSettings(
      temperature: _optimalSettings!.temperature + _temperatureAdjustment,
      humidity: _optimalSettings!.humidity + _humidityAdjustment,
      duration: Duration(
        minutes: (_optimalSettings!.duration.inMinutes * _timeMultiplier).round(),
      ),
      explanations: _optimalSettings!.explanations,
      warnings: _optimalSettings!.warnings,
      tips: _optimalSettings!.tips,
    );
  }

  String _getStageTitle() {
    switch (widget.stageType) {
      case FermentationStageType.primary:
        return '1차 발효';
      case FermentationStageType.finalProofing:
        return '최종 발효';
      case FermentationStageType.storage:
        return '보관';
      case FermentationStageType.rest:
        return '휴지';
      default:
        return '발효';
    }
  }

  String _getStageDescription() {
    switch (widget.stageType) {
      case FermentationStageType.primary:
        return '반죽의 기본 부피를 만드는 중요한 단계';
      case FermentationStageType.finalProofing:
        return '최종 모양과 질감을 완성하는 단계';
      case FermentationStageType.storage:
        return '장기간 보관을 위한 최적 조건';
      case FermentationStageType.rest:
        return '글루텐 이완을 위한 휴지 단계';
      default:
        return '발효 과정';
    }
  }

  IconData _getStageIcon() {
    switch (widget.stageType) {
      case FermentationStageType.primary:
        return Icons.play_circle;
      case FermentationStageType.finalProofing:
        return Icons.check_circle;
      case FermentationStageType.storage:
        return Icons.storage;
      case FermentationStageType.rest:
        return Icons.pause_circle;
      default:
        return Icons.circle;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}시간 ${minutes}분';
    } else {
      return '${minutes}분';
    }
  }

  void _showPreviewDialog() {
    final adjustedSettings = _getAdjustedSettings();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_getStageTitle()} 설정 미리보기'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('온도: ${adjustedSettings.temperature.toStringAsFixed(1)}°C'),
            Text('습도: ${adjustedSettings.humidity.toStringAsFixed(0)}%'),
            Text('시간: ${_formatDuration(adjustedSettings.duration)}'),
            const SizedBox(height: 16),
            const Text(
              '이 설정으로 발효기를 설정하시겠습니까?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onSettingsApplied(adjustedSettings);
              Navigator.pop(context);
            },
            child: const Text('적용'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('발효기 설정 도움말'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '과학적 근거',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• 온도: 이스트 활동과 발효 속도를 조절\n'
                '• 습도: 반죽 표면 건조 방지\n'
                '• 시간: 레시피와 환경에 최적화',
              ),
              SizedBox(height: 16),
              Text(
                '미세 조정',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• 개인 취향에 맞게 설정 조절 가능\n'
                '• 환경 차이를 보정할 때 유용\n'
                '• 경험에 따른 개선 가능',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}