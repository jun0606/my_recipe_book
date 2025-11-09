// 믹싱 분석 카드 위젯
// 리펙토링된 간단하고 효율적인 UI 컴포넌트

import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/types/environment_types.dart';
import '../types/screen_types.dart';
import 'mixing_analysis_controller.dart';

/// 믹싱 분석 카드 위젯
/// 계산 로직을 서비스로 분리하고 UI만 담당
class MixingAnalysisCard extends StatefulWidget {
  final Map<String, dynamic> recipeData;
  final UserEnvironment environment;
  final AnalysisSettings settings;
  final Function(Map<String, dynamic>)? onAnalysisComplete;

  const MixingAnalysisCard({
    super.key,
    required this.recipeData,
    required this.environment,
    required this.settings,
    this.onAnalysisComplete,
  });

  @override
  State<MixingAnalysisCard> createState() => _MixingAnalysisCardState();
}

class _MixingAnalysisCardState extends State<MixingAnalysisCard> {
  late MixingAnalysisController _controller;
  List<Map<String, dynamic>> _mixingSteps = [];
  Map<String, dynamic>? _analysisResult;
  List<String> _temperatureWarnings = []; // 온도 경고 추가

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didUpdateWidget(MixingAnalysisCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.environment != widget.environment ||
        oldWidget.settings != widget.settings) {
      _performAnalysis();
    }
  }

  void _initializeData() {
    _controller = MixingAnalysisController(
      recipeData: widget.recipeData,
      environment: widget.environment,
      settings: widget.settings,
      onAnalysisComplete: _handleAnalysisComplete,
    );
    _controller.addListener(_onControllerUpdate);
    _performAnalysis();
  }

  /// 분석 완료 콜백 처리 (온도 경고 포함)
  void _handleAnalysisComplete(Map<String, dynamic> result) {
    setState(() {
      _temperatureWarnings =
          result['temperatureWarnings'] as List<String>? ?? [];
    });

    // 원래 콜백 호출
    if (widget.onAnalysisComplete != null) {
      widget.onAnalysisComplete!(result);
    }
  }

  void _onControllerUpdate() {
    setState(() {
      // 디버깅: 컨트롤러의 데이터 상태 확인
      print(
          '🔍 [UI Update] 컨트롤러 stepAnalyses 길이: ${_controller.stepAnalyses.length}');
      print('🔍 [UI Update] 컨트롤러 isAnalyzing: ${_controller.isAnalyzing}');
      print(
          '🔍 [UI Update] 컨트롤러 mixingSteps 길이: ${_controller.mixingSteps.length}');

      if (_controller.stepAnalyses.isNotEmpty) {
        // 컨트롤러의 stepAnalyses에서 누적 계산된 데이터를 사용하여 mixingSteps 업데이트
        _mixingSteps = _controller.stepAnalyses.asMap().entries.map((entry) {
          final index = entry.key;
          final analysis = entry.value;

          print('📊 [UI Update] 단계 ${index + 1} 분석 데이터:');
          print('   - 글루텐 형성도: ${analysis.doughState.glutenFormation}');
          print('   - 속도: ${analysis.speed}');
          print('   - 시간: ${analysis.durationMinutes}분');
          print('   - 효율성: ${analysis.efficiency}');

          // 누적 상태 계산 결과를 포함하여 Map 생성
          return {
            'stepNumber': analysis.stepNumber,
            'speed': analysis.speed,
            'durationMinutes': analysis.durationMinutes,
            'comment': '', // 기본값
            'temperature': analysis.doughState.temperature,
            'doughState': {
              'glutenFormation': analysis.doughState.glutenFormation,
              'temperature': analysis.doughState.temperature,
              'viscosity': analysis.doughState.viscosity,
              'moistureAbsorption': analysis.doughState.moistureAbsorption,
              'developmentStage': analysis.doughState.developmentStage,
              'currentStep': analysis.doughState.currentStep,
            },
            'cumulativeDoughState': {
              'glutenFormation': analysis.doughState.glutenFormation,
              'temperature': analysis.doughState.temperature,
              'viscosity': analysis.doughState.viscosity,
              'moistureAbsorption': analysis.doughState.moistureAbsorption,
              'developmentStage': analysis.doughState.developmentStage,
              'currentStep': analysis.doughState.currentStep,
            },
            'isFinalStep': index == _controller.stepAnalyses.length - 1,
            'efficiency': analysis.efficiency, // 효율성 정보 추가
          };
        }).toList();

        print('✅ [UI Update] _mixingSteps 업데이트 완료: ${_mixingSteps.length}개 단계');

        // 각 단계별 데이터 검증
        for (int i = 0; i < _mixingSteps.length; i++) {
          final step = _mixingSteps[i];
          final glutenFormation =
              step['cumulativeDoughState']?['glutenFormation'] ?? 0.0;
          print('🔍 [UI Update] 단계 ${i + 1} 최종 글루텐 형성도: $glutenFormation');
        }
      } else {
        print('⚠️ [UI Update] 컨트롤러 stepAnalyses가 비어있음 - 기본 데이터 사용');

        // 분석이 아직 완료되지 않은 경우, 컨트롤러의 기본 mixingSteps 사용
        if (_controller.mixingSteps.isNotEmpty) {
          _mixingSteps = _controller.mixingSteps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;

            return {
              'stepNumber': step.stepNumber,
              'speed': step.speed,
              'durationMinutes': step.durationMinutes,
              'comment': step.comment ?? '',
              'temperature': step.temperature ?? 25.0,
              'doughState': {
                'glutenFormation': 0.0, // 기본값
                'temperature': step.temperature ?? 25.0,
                'viscosity': 1.0,
                'moistureAbsorption': 65.0,
                'developmentStage': '분석중',
                'currentStep': step.stepNumber,
              },
              'cumulativeDoughState': {
                'glutenFormation': 0.0, // 기본값
                'temperature': step.temperature ?? 25.0,
                'viscosity': 1.0,
                'moistureAbsorption': 65.0,
                'developmentStage': '분석중',
                'currentStep': step.stepNumber,
              },
              'isFinalStep': index == _controller.mixingSteps.length - 1,
              'efficiency': 0.5, // 기본값
            };
          }).toList();

          print(
              '✅ [UI Update] 기본 mixingSteps로 업데이트: ${_mixingSteps.length}개 단계');
        } else {
          _mixingSteps = [];
          print('⚠️ [UI Update] 컨트롤러 mixingSteps도 비어있음');
        }
      }

      _analysisResult = _controller.analysisResult?.toJson();

      print(
          '🔍 [UI Update] _analysisResult: ${_analysisResult != null ? '있음' : '없음'}');
      print('🔍 [UI Update] 최종 _mixingSteps 길이: ${_mixingSteps.length}');
    });
  }

  Future<void> _performAnalysis() async {
    await _controller.performAnalysis();
  }

  /// 총 재료량 계산
  int _calculateTotalIngredientWeight() {
    try {
      final ingredientsRaw = widget.recipeData['ingredients'];

      if (ingredientsRaw == null) {
        return 500; // 기본값
      }

      // List 형태 처리
      if (ingredientsRaw is List) {
        return _calculateFromList(ingredientsRaw);
      }

      // String 형태 처리 (JSON 문자열)
      if (ingredientsRaw is String) {
        return _calculateFromString(ingredientsRaw);
      }

      // 기타 형태는 기본값 반환
      return 500;
    } catch (e) {
      return 500; // 오류 시 기본값
    }
  }

  /// List 형태 재료량 계산
  int _calculateFromList(List ingredients) {
    int totalWeight = 0;

    for (final ingredient in ingredients) {
      if (ingredient is Map<String, dynamic>) {
        final amount = ingredient['amount'];
        final unit = ingredient['unit'] as String?;

        // amount가 num 타입인지 확인
        if (amount is num && unit == 'g') {
          totalWeight += amount.toInt();
        }
        // amount가 String 타입인 경우 (예: "500")
        else if (amount is String && unit == 'g') {
          final parsedAmount = int.tryParse(amount);
          if (parsedAmount != null) {
            totalWeight += parsedAmount;
          }
        }
      }
    }

    return totalWeight > 0 ? totalWeight : 500;
  }

  /// String 형태 재료량 계산
  int _calculateFromString(String ingredientsText) {
    try {
      // JSON 문자열인 경우 파싱 시도
      final jsonData = jsonDecode(ingredientsText);
      if (jsonData is List) {
        return _calculateFromList(jsonData);
      }
    } catch (e) {
      // JSON 파싱 실패 시 텍스트 파싱
      return _parseWeightFromText(ingredientsText);
    }

    return 500;
  }

  /// 텍스트에서 무게 파싱
  int _parseWeightFromText(String text) {
    final lines = text.split('\n');
    int totalWeight = 0;

    for (final line in lines) {
      // "강력분 500g" 형태 파싱
      final weightMatch = RegExp(r'(\d+)g').firstMatch(line);
      if (weightMatch != null) {
        final weight = int.tryParse(weightMatch.group(1) ?? '0') ?? 0;
        totalWeight += weight;
      }
    }

    return totalWeight > 0 ? totalWeight : 500;
  }

  /// 평균 반죽온도 계산
  double _calculateAverageDoughTemperature() {
    if (_mixingSteps.isEmpty) {
      return widget.environment.temperature ?? 25.0;
    }

    double totalTemp = 0.0;
    int validSteps = 0;

    for (final step in _mixingSteps) {
      final doughState = step['doughState'] as Map<String, dynamic>?;
      if (doughState != null) {
        final temp = doughState['temperature'] as double?;
        if (temp != null) {
          totalTemp += temp;
          validSteps++;
        }
      }
    }

    // 유효한 단계가 없으면 환경온도 반환
    if (validSteps == 0) {
      return widget.environment.temperature ?? 25.0;
    }

    return totalTemp / validSteps;
  }

  /// 글루텐 형성도에 따른 색상 반환
  Color _getGlutenColor(double glutenFormation) {
    if (glutenFormation >= 0.8) return Colors.green.shade600;
    if (glutenFormation >= 0.6) return Colors.blue.shade600;
    if (glutenFormation >= 0.4) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  /// 점수에 따른 색상 반환
  Color _getScoreColor(double score) {
    if (score >= 0.8) return Colors.green.shade600;
    if (score >= 0.6) return Colors.blue.shade600;
    if (score >= 0.4) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  /// 온도에 따른 색상 반환
  Color _getTemperatureColor(double temperature) {
    if (temperature >= 20 && temperature <= 30) return Colors.green.shade600;
    if (temperature >= 15 && temperature <= 35) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  /// 점도에 따른 색상 반환
  Color _getViscosityColor(double viscosity) {
    if (viscosity >= 0.8 && viscosity <= 1.2) return Colors.green.shade600;
    if (viscosity >= 0.5 && viscosity <= 1.5) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  /// 수분량 계산 (총 누적 열 기반)
  double _calculateMoisturePercentage(double totalHeat) {
    // 총 누적 열을 수분 백분율로 변환
    // 기본 수분량 70%에서 열 발생에 따라 감소
    double moisturePercent = 70.0 - (totalHeat * 1.5);

    // 수분량 범위 제한 (50% ~ 80%)
    return moisturePercent.clamp(50.0, 80.0);
  }

  /// 수분 상태에 따른 색상 반환
  Color _getMoistureColor(String status) {
    switch (status) {
      case '수분 충분':
        return Colors.green.shade600;
      case '수분 적정':
        return Colors.blue.shade600;
      case '수분 부족':
        return Colors.orange.shade600;
      case '수분 손실':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  /// 수분 퍼센트에 따른 색상 반환
  Color _getMoistureColorByPercentage(double percentage) {
    if (percentage >= 70) return Colors.green.shade600; // 수분 충분
    if (percentage >= 65) return Colors.blue.shade600; // 수분 적정
    if (percentage >= 60) return Colors.orange.shade600; // 수분 부족
    return Colors.red.shade600; // 수분 손실
  }

  /// 총 누적 열 계산
  double _calculateTotalAccumulatedHeat() {
    double totalHeat = 0.0;

    for (final step in _mixingSteps) {
      final speed = step['speed'] as String? ?? '중속';
      final duration = step['durationMinutes'] as int? ?? 5;

      // 속도별 기본 열 발생량
      double heatGeneration = 0.6;
      switch (speed) {
        case '저속':
          heatGeneration *= 0.7;
          break;
        case '중속':
          heatGeneration *= 1.0;
          break;
        case '고속':
          heatGeneration *= 1.5;
          break;
      }

      // 시간 보정
      if (duration < 3) {
        heatGeneration *= 0.8;
      }

      totalHeat += heatGeneration * duration;
    }

    return totalHeat;
  }

  /// 점도 값에 따른 레이블 반환
  String _getViscosityLabel(double viscosity) {
    if (viscosity >= 0.5 && viscosity < 0.8) {
      return '매우 묽은 반죽';
    } else if (viscosity >= 0.8 && viscosity < 1.2) {
      return '적정 점도';
    } else if (viscosity >= 1.2 && viscosity < 1.5) {
      return '약간 단단한 반죽';
    } else if (viscosity >= 1.5 && viscosity < 2.0) {
      return '단단한 반죽';
    } else if (viscosity >= 2.0 && viscosity <= 2.5) {
      return '매우 단단한 반죽';
    } else {
      return '범위 외';
    }
  }

  /// 메트릭 표시 위젯 빌더
  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 메트릭 카드 빌더 (개선된 버전)
  Widget _buildMetricCard(String label, String value, Color color) {
    // 메트릭 타입에 따른 아이콘 결정
    IconData getMetricIcon() {
      if (label.contains('시간')) return Icons.schedule_rounded;
      if (label.contains('글루텐')) return Icons.grass_rounded;
      if (label.contains('수분')) return Icons.water_drop_rounded;
      if (label.contains('온도')) return Icons.thermostat_rounded;
      return Icons.analytics_rounded;
    }

    // 값에서 숫자 추출 (프로그레스 바용)
    double getProgressValue() {
      if (label.contains('글루텐')) {
        final percentMatch = RegExp(r'(\d+)%').firstMatch(value);
        if (percentMatch != null) {
          return int.parse(percentMatch.group(1)!) / 100.0;
        }
      }
      return 0.0; // 기본값
    }

    final progressValue = getProgressValue();
    final hasProgress = progressValue > 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 아이콘과 값
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                getMetricIcon(),
                size: 20,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 프로그레스 바 (글루텐 형성도에만 표시)
          if (hasProgress) ...[
            SizedBox(
              width: 60,
              height: 4,
              child: LinearProgressIndicator(
                value: progressValue,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 6),
          ],
          // 라벨
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.green.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            if (_analysisResult != null) ...[
              _buildAnalysisResult(),
              const SizedBox(height: 20),
            ],
            if (_mixingSteps.isNotEmpty) _buildExpandableMixingSteps(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    // 재료량 계산
    final totalWeight = _calculateTotalIngredientWeight();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                size: 32,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '믹싱 분석',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _performAnalysis,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                  ),
                  tooltip: '분석 실행',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 재료량 및 환경 정보
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.scale_rounded,
                  size: 18,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 8),
                Text(
                  '${totalWeight}g',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.thermostat_rounded,
                  size: 18,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.environment.temperature?.toStringAsFixed(0) ?? '25'}°C',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (widget.environment.humidity != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.water_drop_rounded,
                    size: 18,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.environment.humidity!.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResult() {
    if (_analysisResult == null) return const SizedBox.shrink();

    final score = _analysisResult!['overallScore'] as double? ?? 0.0;
    final grade = _analysisResult!['performanceGrade'] as String? ?? '평가중';
    final color = _getScoreColor(score);

    // 컨트롤러의 분석 결과에서 제안사항 가져오기
    final suggestions =
        _analysisResult!['processOptimizationSuggestions'] as List<String>? ??
            [];

    // 추가 메트릭 데이터
    final totalTime = _analysisResult!['totalTime'] as int? ?? 0;
    final avgGluten =
        _analysisResult!['averageGlutenFormation'] as double? ?? 0.0;
    final efficiency = _analysisResult!['efficiency'] as double? ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 섹션
          Row(
            children: [
              Icon(Icons.check_circle, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '믹싱 분석 완료',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      '종합 점수: ${(score * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: color.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 주요 메트릭 그리드
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  '🕒 총 시간',
                  '${totalTime}분',
                  Colors.blue.shade600,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard(
                  '🌾 글루텐 발달',
                  '${(avgGluten * 100).toStringAsFixed(0)}%',
                  _getGlutenColor(avgGluten),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  '💧 수분',
                  '${_calculateMoisturePercentage(_calculateTotalAccumulatedHeat()).toStringAsFixed(0)}%',
                  _getMoistureColorByPercentage(_calculateMoisturePercentage(
                      _calculateTotalAccumulatedHeat())),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard(
                  '🌡️ 반죽온도',
                  '${_calculateAverageDoughTemperature().toStringAsFixed(0)}°C',
                  _getTemperatureColor(_calculateAverageDoughTemperature()),
                ),
              ),
            ],
          ),

          // 현재 상태보고 섹션 (접기 가능)
          if (suggestions.isNotEmpty || _temperatureWarnings.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: ExpansionTile(
                title: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '📊 현재 상태',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    if (_temperatureWarnings.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '경고',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 일반 제안사항
                        if (suggestions.isNotEmpty) ...[
                          ...suggestions.map((suggestion) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '•',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        suggestion,
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          if (_temperatureWarnings.isNotEmpty)
                            const SizedBox(height: 8),
                        ],
                        // 온도 경고 (별도 섹션)
                        if (_temperatureWarnings.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.thermostat,
                                      size: 14,
                                      color: Colors.red.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '온도 경고',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ..._temperatureWarnings
                                    .map((warning) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 2),
                                          child: Text(
                                            warning,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.red.shade700,
                                            ),
                                          ),
                                        )),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                initiallyExpanded: true, // 현재 상태는 기본적으로 펼쳐서 중요 정보 표시
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.white,
                collapsedBackgroundColor: Colors.blue.shade50,
                iconColor: Colors.blue.shade600,
                collapsedIconColor: Colors.blue.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 접기 가능한 믹싱 단계 섹션
  Widget _buildExpandableMixingSteps() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(
              Icons.list_alt_rounded,
              size: 20,
              color: Colors.green.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              '믹싱 단계별 분석',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_mixingSteps.length}단계',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _mixingSteps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;
                return _buildMixingStepCard(
                  stepIndex: index,
                  step: step,
                  totalSteps: _mixingSteps.length,
                );
              }).toList(),
            ),
          ),
        ],
        initiallyExpanded: false, // 기본적으로 접힌 상태
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.grey.shade50,
        iconColor: Colors.green.shade600,
        collapsedIconColor: Colors.green.shade600,
      ),
    );
  }

  Widget _buildMixingSteps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '믹싱 단계별 분석',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        ..._mixingSteps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          return _buildMixingStepCard(
            stepIndex: index,
            step: step,
            totalSteps: _mixingSteps.length,
          );
        }),
      ],
    );
  }

  Widget _buildMixingStepCard({
    required int stepIndex,
    required Map<String, dynamic> step,
    required int totalSteps,
  }) {
    final speed = step['speed'] as String? ?? '중속';
    final duration = step['durationMinutes'] as int? ??
        step['time'] as int? ??
        step['duration'] as int? ??
        10;

    // 누적 상태 우선 사용, 없으면 기본 분석 데이터 사용
    final cumulativeDoughState =
        step['cumulativeDoughState'] as Map<String, dynamic>?;
    final isFinalStep = step['isFinalStep'] as bool? ?? false;

    // 기본 효율성 계산 (컨트롤러의 데이터가 없을 경우)
    final efficiency = 0.5; // 기본값

    // 누적 상태 또는 기본 상태 사용
    final doughState = cumulativeDoughState ?? <String, dynamic>{};

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 단계 헤더
            Row(
              children: [
                Text(
                  '믹싱 단계 ${stepIndex + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getScoreColor(efficiency).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${(efficiency * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: _getScoreColor(efficiency),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 기본 메트릭 (RPM 제거)
            Row(
              children: [
                Expanded(
                  child: _buildMetric('믹싱 속도', speed, Colors.blue.shade600),
                ),
                Expanded(
                  child: _buildMetric(
                      '작업 시간', '${duration}분', Colors.orange.shade600),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 반죽 상태 메트릭
            Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    '글루텐 발달',
                    '${((doughState['glutenFormation'] as double? ?? 0.0) * 100).toStringAsFixed(0)}%',
                    _getGlutenColor(
                        doughState['glutenFormation'] as double? ?? 0.0),
                  ),
                ),
                Expanded(
                  child: _buildMetric(
                    '반죽 온도',
                    '${(doughState['temperature'] as double? ?? 25.0).toStringAsFixed(0)}°C',
                    _getTemperatureColor(
                        doughState['temperature'] as double? ?? 25.0),
                  ),
                ),
                Expanded(
                  child: _buildMetric(
                    '반죽 점도',
                    '${(doughState['viscosity'] as double? ?? 1.0).toStringAsFixed(1)} (${_getViscosityLabel(doughState['viscosity'] as double? ?? 1.0)})',
                    _getViscosityColor(
                        doughState['viscosity'] as double? ?? 1.0),
                  ),
                ),
              ],
            ),

            // 최종 단계 강조 표시
            if (isFinalStep) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '🎯 최종 글루텐 형성도: ${((doughState['glutenFormation'] as double? ?? 0.0) * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 반죽 발달 단계 표시
            if (doughState['developmentStage'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '반죽 발달: ${doughState['developmentStage'] as String}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],

            // 진행 상황 표시 (최종 단계가 아닌 경우)
            if (!isFinalStep && cumulativeDoughState != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 12,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '진행률: ${((stepIndex + 1) / totalSteps * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    super.dispose();
  }
}
