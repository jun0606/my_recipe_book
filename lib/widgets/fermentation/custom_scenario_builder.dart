/// 스마트 커스텀 발효 시나리오 생성 위젯
/// 사용자가 원하는 단계를 선택하면 레시피와 환경 데이터를 기반으로 자동 계산

import 'package:flutter/material.dart';
import '../../models/fermentation_scenario.dart';
import '../../models/sous_chef_models.dart';
import '../../models/environmental_conditions.dart';
import '../../services/smart_fermentation_calculator.dart';

class CustomScenarioBuilder extends StatefulWidget {
  final Function(FermentationScenario) onScenarioCreated;
  final List<Map<String, dynamic>> ingredients;
  final double environmentTemperature;
  final double environmentHumidity;
  final double altitude;
  final String? recipeTitle;

  const CustomScenarioBuilder({
    super.key,
    required this.onScenarioCreated,
    required this.ingredients,
    this.environmentTemperature = 26.0,
    this.environmentHumidity = 60.0,
    this.altitude = 0.0,
    this.recipeTitle,
  });

  @override
  State<CustomScenarioBuilder> createState() => _CustomScenarioBuilderState();
}

class _CustomScenarioBuilderState extends State<CustomScenarioBuilder> {
  // 선택 가능한 발효 단계들
  final List<FermentationStage> _availableStages = [
    FermentationStage.bulk,
    FermentationStage.secondary,
    FermentationStage.divided,
    FermentationStage.shaped,
    FermentationStage.finalProof,
    FermentationStage.overnight,
    FermentationStage.coldRetard,
  ];
  
  // 선택된 단계들
  List<FermentationStage> _selectedStages = [
    FermentationStage.bulk,
    FermentationStage.finalProof,
  ];
  
  // 계산된 시간들
  Map<FermentationStage, double> _calculatedTimes = {};
  
  // 로딩 상태
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _calculateTimes();
  }

  /// 스마트 시간 계산
  void _calculateTimes() {
    setState(() {
      _isCalculating = true;
    });
    
    // 스마트 계산 엔진으로 시간 계산
    _calculatedTimes = SmartFermentationCalculator.calculateOptimalTimes(
      selectedStages: _selectedStages,
      ingredients: widget.ingredients,
      environmentTemperature: widget.environmentTemperature,
      environmentHumidity: widget.environmentHumidity,
      altitude: widget.altitude,
      recipeTitle: widget.recipeTitle,
    );
    
    setState(() {
      _isCalculating = false;
    });
  }

  /// 단계 선택/해제
  void _toggleStage(FermentationStage stage) {
    setState(() {
      if (_selectedStages.contains(stage)) {
        _selectedStages.remove(stage);
      } else {
        _selectedStages.add(stage);
      }
      
      // 단계 순서 정렬
      _selectedStages.sort((a, b) => _getStageOrder(a).compareTo(_getStageOrder(b)));
    });
    
    // 시간 재계산
    _calculateTimes();
  }

  /// 단계 순서 반환
  int _getStageOrder(FermentationStage stage) {
    switch (stage) {
      case FermentationStage.bulk:
        return 1;
      case FermentationStage.secondary:
        return 2;
      case FermentationStage.divided:
        return 3;
      case FermentationStage.shaped:
        return 4;
      case FermentationStage.overnight:
        return 5;
      case FermentationStage.coldRetard:
        return 6;
      case FermentationStage.finalProof:
        return 7;
    }
  }

  /// 시나리오 생성 및 저장
  void _createScenario() {
    if (_selectedStages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 하나의 발효 단계를 선택해주세요')),
      );
      return;
    }

    // 스테이지 설정 생성
    final stageConfigs = <FermentationStage, FermentationStageConfig>{};
    for (final stage in _selectedStages) {
      final duration = _calculatedTimes[stage] ?? 60.0;
      final temp = _getStageTemperature(stage);
      final humidity = _getStageHumidity(stage);
      
      stageConfigs[stage] = FermentationStageConfig(
        duration: duration,
        temperature: temp,
        humidity: humidity,
        notes: _getStageDescription(stage),
      );
    }

    // 시나리오 생성
    final scenario = FermentationScenario(
      id: 'smart_custom_${DateTime.now().millisecondsSinceEpoch}',
      name: '스마트 커스텀 시나리오',
      description: '레시피 기반 자동 계산된 발효 시간',
      selectedStages: _selectedStages,
      stageConfigs: stageConfigs,
      environmentalConditions: EnvironmentalConditions(
        temperature: widget.environmentTemperature,
        humidity: widget.environmentHumidity,
        altitude: widget.altitude,
      ),
    );

    widget.onScenarioCreated(scenario);
  }

  /// 단계별 온도 계산
  double _getStageTemperature(FermentationStage stage) {
    switch (stage) {
      case FermentationStage.bulk:
      case FermentationStage.secondary:
        return (widget.environmentTemperature + 2.0).clamp(24.0, 32.0);
      case FermentationStage.finalProof:
        return (widget.environmentTemperature + 4.0).clamp(26.0, 35.0);
      case FermentationStage.overnight:
        return (widget.environmentTemperature - 2.0).clamp(18.0, 24.0);
      case FermentationStage.coldRetard:
        return 4.0; // 냉장고 온도
      case FermentationStage.divided:
      case FermentationStage.shaped:
        return widget.environmentTemperature; // 실온
    }
  }

  /// 단계별 습도 계산
  double _getStageHumidity(FermentationStage stage) {
    switch (stage) {
      case FermentationStage.bulk:
      case FermentationStage.secondary:
        return (widget.environmentHumidity + 10.0).clamp(65.0, 85.0);
      case FermentationStage.finalProof:
        return (widget.environmentHumidity + 15.0).clamp(70.0, 90.0);
      case FermentationStage.coldRetard:
        return 85.0; // 냉장고 습도
      default:
        return (widget.environmentHumidity + 5.0).clamp(60.0, 80.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('스마트 발효 시나리오'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: _selectedStages.isNotEmpty ? _createScenario : null,
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text('완료', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _isCalculating 
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('레시피 분석 중...', style: TextStyle(fontSize: 16)),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildStageSelector(),
                const SizedBox(height: 24),
                if (_selectedStages.isNotEmpty) _buildTimePreview(),
              ],
            ),
          ),
    );
  }

  /// 헤더 섹션
  Widget _buildHeader() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.blue.shade600, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '스마트 발효 계산',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '원하는 발효 단계를 선택하면 레시피와 환경 조건을 분석해서\n최적의 발효 시간을 자동으로 계산해드립니다.',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '환경: ${widget.environmentTemperature.toInt()}°C, ${widget.environmentHumidity.toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
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

  /// 단계 선택기
  Widget _buildStageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '발효 단계 선택',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '원하는 발효 단계들을 선택하세요. 선택한 순서대로 진행됩니다.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableStages.map((stage) {
            final isSelected = _selectedStages.contains(stage);
            return FilterChip(
              selected: isSelected,
              label: Text(_getStageName(stage)),
              onSelected: (_) => _toggleStage(stage),
              selectedColor: Colors.blue.shade100,
              checkmarkColor: Colors.blue.shade600,
              backgroundColor: Colors.grey.shade100,
              labelStyle: TextStyle(
                color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 시간 미리보기
  Widget _buildTimePreview() {
    final totalMinutes = _calculatedTimes.values.fold(0.0, (sum, time) => sum + time);
    final totalHours = totalMinutes / 60;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '계산된 발효 시간',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '총 ${totalHours >= 1 ? '${totalHours.toStringAsFixed(1)}시간' : '${totalMinutes.toInt()}분'}',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: _selectedStages.asMap().entries.map((entry) {
              final index = entry.key;
              final stage = entry.value;
              final time = _calculatedTimes[stage] ?? 0;
              final isLast = index == _selectedStages.length - 1;
              
              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      _getStageName(stage),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${_getStageTemperature(stage).toInt()}°C, ${_getStageHumidity(stage).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        time >= 60 
                          ? '${(time / 60).toStringAsFixed(1)}시간'
                          : '${time.toInt()}분',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const SizedBox(width: 24),
                          Icon(Icons.arrow_downward, 
                               color: Colors.grey.shade400, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '다음 단계',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (!isLast) const SizedBox(height: 8),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// 단계 이름 반환
  String _getStageName(FermentationStage stage) {
    switch (stage) {
      case FermentationStage.bulk:
        return '1차 발효';
      case FermentationStage.secondary:
        return '2차 발효';
      case FermentationStage.divided:
        return '분할 휴지';
      case FermentationStage.shaped:
        return '성형 휴지';
      case FermentationStage.finalProof:
        return '최종 발효';
      case FermentationStage.overnight:
        return '오버나이트';
      case FermentationStage.coldRetard:
        return '냉장 숙성';
    }
  }

  /// 단계 설명 반환
  String _getStageDescription(FermentationStage stage) {
    switch (stage) {
      case FermentationStage.bulk:
        return '1차 발효 - 반죽이 1.5-2배 부풀 때까지';
      case FermentationStage.secondary:
        return '2차 발효 - 글루텐 구조 안정화';
      case FermentationStage.divided:
        return '분할 후 휴지 - 반죽 이완';
      case FermentationStage.shaped:
        return '성형 후 휴지 - 성형 스트레스 완화';
      case FermentationStage.finalProof:
        return '최종 발효 - 손가락 테스트로 확인';
      case FermentationStage.overnight:
        return '오버나이트 발효 - 장시간 저온 발효';
      case FermentationStage.coldRetard:
        return '냉장 숙성 - 풍미 발달';
    }
  }
}