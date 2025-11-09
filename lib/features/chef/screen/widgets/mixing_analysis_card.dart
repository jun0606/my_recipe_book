/// 믹싱 분석 카드 위젯
/// 컨트롤러 기반 단일 데이터 소스만 사용
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/types/environment_types.dart';
import '../../../../core/types/unified_types.dart';
import '../../../../services/ingredient_analyzer.dart';
import '../../../../services/recipe_data_parser.dart';
import '../../../../services/moisture_calculator.dart';
import '../../../../services/bread_calculator_service.dart';
import '../types/screen_types.dart' as st;
import 'mixing_analysis_controller.dart';
import 'mixing_analysis_utils.dart';
import 'mixing_analysis_types.dart' as mat;
import 'mixing_step_card_improved.dart';

/// 믹싱 분석 카드 위젯
/// ✅ 클린 아키텍처: 컨트롤러만 데이터 소스로 사용
class MixingAnalysisCard extends StatefulWidget {
  final Map<String, dynamic> recipeData;
  final UserEnvironment environment;
  final st.AnalysisSettings settings;
  final void Function(AnalysisResult)? onAnalysisComplete;
  final MixingAnalysisController? externalController;

  const MixingAnalysisCard({
    super.key,
    required this.recipeData,
    required this.environment,
    required this.settings,
    this.onAnalysisComplete,
    this.externalController,
  });

  @override
  State<MixingAnalysisCard> createState() => _MixingAnalysisCardState();
}

class _MixingAnalysisCardState extends State<MixingAnalysisCard> {
  /// ✅ 컨트롤러 안전 관리: 강력한 초기화로 null 방지 (fermentation 컨트롤러 패턴)
  MixingAnalysisController? _controller;

  /// ✅ 컨트롤러 기반 게터들 (안전하게 null 검증)
  List<mat.MixingStep> get _mixingSteps => _controller?.mixingSteps ?? [];
  List<mat.MixingStepAnalysis> get _stepAnalyses =>
      _controller?.stepAnalyses ?? [];
  st.MixingAnalysisResult? get _analysisResult => _controller?.analysisResult;

  /// ✅ 컨트롤러 데이터 직접 사용 (불필요한 게터 제거)

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(MixingAnalysisCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.environment != widget.environment ||
        oldWidget.settings != widget.settings) {
      _performAnalysis();
    }
  }

  /// ✅ 컨트롤러 초기화 (strong initialization - fermentation 컨트롤러 패턴 적용)
  void _initializeControllerSafely() {
    if (!mounted) return; // 위젯이 아직 mounted되지 않았으면 중단

    try {
      // 기존 컨트롤러 안전하게 정리
      final oldController = _controller;
      if (oldController != null) {
        oldController.removeListener(_onControllerUpdate);
        if (widget.externalController == null) {
          oldController.dispose();
        }
      }

      // 새 컨트롤러 생성 (절대 실패하지 않음)
      if (widget.externalController != null) {
        _controller = widget.externalController!;
        print('🔗 [MixingAnalysisCard] 외부 컨트롤러 연결 완료');
      } else {
        // 생성자에서 필요한 모든 파라미터 제공하여 null 방지
        _controller = MixingAnalysisController(
          recipeData: widget.recipeData,
          environment: widget.environment,
          settings: widget.settings,
          onAnalysisComplete: _handleAnalysisComplete,
        );
        print('🆕 [MixingAnalysisCard] 새 컨트롤러 생성 완료');
      }

      // 컨트롤러가 확실히 초기화됨을 보장
      if (_controller == null) {
        throw Exception('컨트롤러 초기화 실패 - null 컨트롤러');
      }

      // 리스너 설정
      _controller!.addListener(_onControllerUpdate);

      print('✅ [MixingAnalysisCard] 컨트롤러 초기화 완전 성공');

      // 바로 분석 시작 (초기화 종료 후)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performAnalysisSafely();
      });
    } catch (e) {
      print('❌ [MixingAnalysisCard] 컨트롤러 초기화 완전 실패: $e');
      // 컨트롤러 초기화 실패 시에도 setState 호출하여 UI 상태 갱신
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// ✅ 컨트롤러 초기화 (단일 데이터 소스) - 레거시 호환
  void _initializeController() {
    if (!mounted) return;
    _initializeControllerSafely();
  }

  /// 분석 완료 콜백 - 컨트롤러 위임
  void _handleAnalysisComplete(AnalysisResult result) {
    if (widget.onAnalysisComplete != null) {
      widget.onAnalysisComplete!(result);
    }
  }

  /// 컨트롤러 업데이트 핸들러 - UI 리빌드만
  void _onControllerUpdate() {
    if (!mounted) return;

    // 빌드 중에 setState() 호출 방지 - 프레임 끝으로 연기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  /// ✅ 안전한 분석 수행 (컨트롤러 null 검증)
  Future<void> _performAnalysisSafely() async {
    if (_controller == null) {
      print('⚠️ [MixingAnalysisCard] 컨트롤러가 초기화되지 않았습니다');
      return;
    }

    try {
      await _controller!.performAnalysis();
      // 분석 완료 후 UI 갱신은 컨트롤러 리스너가 자동으로 처리됨 (중복 방지)
      debugPrint('✅ [MixingAnalysisCard] 분석 수행 완료 - 리스너가 UI 업데이트 처리');
    } catch (e) {
      print('❌ [MixingAnalysisCard] 분석 수행 중 오류: $e');
    }
  }

  /// 레거시 호환 메소드
  Future<void> _performAnalysis() async => _performAnalysisSafely();

  @override
  Widget build(BuildContext context) {
    final hasAnalysisResult = _analysisResult != null;
    final hasMixingData = _mixingSteps.isNotEmpty;
    final isControllerReady = _controller != null;

    return Card(
      elevation: 4,
      shadowColor: Colors.green.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            if (!isControllerReady) ...[
              // 컨트롤러 초기화 중 표시
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '분석 엔진 초기화 중...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (!hasAnalysisResult && !hasMixingData) ...[
              // 분석 진행 중 표시 (분석을 위해서는 컨트롤러가 있어야 함)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '빵 제조 과학적 단계별 계산 수행 중...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // 분석 결과 표시 (결과가 있거나 뭔가 있을 때)
              if (hasAnalysisResult) ...[
                _buildAnalysisResult(),
                const SizedBox(height: 12),
              ],
              if (hasMixingData) ...[
                _buildExpandableMixingSteps(),
              ] else if (hasAnalysisResult) ...[
                // 분석 결과는 있지만 믹싱 데이터가 없을 때는 최소한의 UI 표시
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(
                    '믹싱 단계 데이터가 준비되는 중입니다...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final totalWeight = _calculateTotalIngredientWeight();

    return Container(
      padding: const EdgeInsets.all(8),
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
                size: 28,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '믹싱 분석',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    // 환경 시간 메트릭 추가
                    if (_controller?.stepAnalyses != null &&
                        _controller!.stepAnalyses.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '주요 메트릭: 총 혼합 ${_controller?.stepAnalyses?.fold(0, (sum, step) => sum + step.durationMinutes) ?? 0}분',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  onPressed: _performAnalysis,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                  ),
                  tooltip: '분석 실행',
                  iconSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.scale_rounded,
                  size: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 8),
                Text(
                  '${totalWeight}g',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.thermostat_rounded,
                  size: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.environment.temperature?.toStringAsFixed(0)}°C',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (widget.environment.humidity != null) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.water_drop_rounded,
                    size: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.environment.humidity!.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 13,
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

  /// ✅ 컨트롤러 데이터 직접 사용한 분석 결과 UI
  Widget _buildAnalysisResult() {
    if (_analysisResult == null) return const SizedBox.shrink();

    final score = _analysisResult!.overallScore;
    final grade = _getScoreGrade(score);
    final color = _getScoreColor(score);

    final suggestions = _analysisResult!.processOptimizationSuggestions;
    final totalTime = _analysisResult!.totalTime;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '믹싱 분석 완료',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      '종합 점수: ${(score * 100).toStringAsFixed(1)}% ($grade)',
                      style: TextStyle(
                        fontSize: 11,
                        color: color.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  '🕒 총 시간',
                  '${totalTime}분',
                  Colors.blue.shade600,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildMetricCard(
                  '🌾 글루텐 발달',
                  '${(_analysisResult!.averageGlutenFormation * 100).round()}%',
                  _getGlutenColor(_analysisResult!.averageGlutenFormation),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  '💧 수분',
                  '${_controller?.getFinalMoistureAbsorption().toStringAsFixed(1) ?? '0.0'}%',
                  _getMoistureColorByPercentage(
                      _controller?.getFinalMoistureAbsorption() ?? 0.0),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildMetricCard(
                  '🌡️ 반죽온도',
                  '${_analysisResult?.finalDoughTemperature?.toStringAsFixed(1) ?? 'N/A'}°C',
                  _getTemperatureColor(
                      _analysisResult?.finalDoughTemperature ?? 25.0),
                ),
              ),
            ],
          ),
          if (suggestions.isNotEmpty ||
              (_controller?.stepAnalyses.any((step) =>
                      step.doughState.temperature > 35.0 ||
                      step.doughState.temperature < 18.0) ??
                  false)) ...[
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: ExpansionTile(
                title: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '📊 현재 상태',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    if (_controller?.stepAnalyses.any((step) =>
                            step.doughState.temperature > 35.0 ||
                            step.doughState.temperature < 18.0) ??
                        false) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '경고',
                          style: TextStyle(
                            fontSize: 9,
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
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (suggestions.isNotEmpty) ...[
                          ...suggestions.map((suggestion) => Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '•',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        suggestion,
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          if (_controller?.stepAnalyses.any((step) =>
                                  step.doughState.temperature > 35.0 ||
                                  step.doughState.temperature < 18.0) ??
                              false)
                            const SizedBox(height: 6),
                        ],
                        if (_controller?.stepAnalyses.any((step) =>
                                step.doughState.temperature > 35.0 ||
                                step.doughState.temperature < 18.0) ??
                            false) ...[
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.thermostat,
                                      size: 12,
                                      color: Colors.red.shade600,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '온도 경고',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                ...(_controller?.stepAnalyses
                                        .where((step) =>
                                            step.doughState.temperature >
                                                35.0 ||
                                            step.doughState.temperature < 18.0)
                                        .map((step) =>
                                            '단계 ${step.stepNumber}: 반죽온도 ${_formatTemperatureValueSafely(step.doughState.temperature)} (권장: 20-30°C)')
                                        .map((warning) => Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 2),
                                              child: Text(
                                                warning,
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  color: Colors.red.shade700,
                                                ),
                                              ),
                                            )) ??
                                    []),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                initiallyExpanded: false,
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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

  /// ✅ 컨트롤러 데이터 직접 사용한 단계별 분석 UI
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
            padding: const EdgeInsets.all(12),
            child: Column(
              children: _stepAnalyses.isNotEmpty
                  ? _buildStepAnalysisWidgets()
                  : [
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            const SizedBox(height: 8),
                            Text(
                              '믹싱 분석 진행 중...',
                              style: TextStyle(color: Colors.blue.shade600),
                            ),
                            Text(
                              '단계별 계산을 수행하고 있습니다',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    ],
            ),
          ),
        ],
        initiallyExpanded: false,
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

  /// 메트릭 카드 빌더
  Widget _buildMetricCard(String label, String value, Color color) {
    final getMetricIcon = () {
      if (label.contains('시간')) return Icons.schedule_rounded;
      if (label.contains('글루텐')) return Icons.grass_rounded;
      if (label.contains('수분')) return Icons.water_drop_rounded;
      if (label.contains('온도')) return Icons.thermostat_rounded;
      return Icons.analytics_rounded;
    };

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(getMetricIcon(), size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 점수 등급 계산
  String _getScoreGrade(double score) {
    if (score >= 0.9) return '최상급';
    if (score >= 0.8) return '우수';
    if (score >= 0.7) return '양호';
    if (score >= 0.6) return '보통';
    return '개선 필요';
  }

  /// 글로텐 형성도에 따른 색상
  Color _getGlutenColor(double glutenFormation) {
    if (glutenFormation >= 0.8) return Colors.green.shade600;
    if (glutenFormation >= 0.6) return Colors.blue.shade600;
    if (glutenFormation >= 0.4) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  /// 점수에 따른 색상
  Color _getScoreColor(double score) {
    if (score >= 0.8) return Colors.green.shade600;
    if (score >= 0.6) return Colors.blue.shade600;
    if (score >= 0.4) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  /// 온도에 따른 색상
  Color _getTemperatureColor(double temperature) {
    if (temperature >= 20 && temperature <= 30) return Colors.green.shade600;
    if (temperature >= 15 && temperature <= 35) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  /// 수분 퍼센트에 따른 색상
  Color _getMoistureColorByPercentage(double percentage) {
    if (percentage >= 70) return Colors.green.shade600;
    if (percentage >= 65) return Colors.blue.shade600;
    if (percentage >= 60) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  /// 총 재료량 계산
  int _calculateTotalIngredientWeight() {
    try {
      final ingredientsRaw = widget.recipeData['ingredients'];

      if (ingredientsRaw == null) {
        return 500;
      }

      if (ingredientsRaw is List) {
        return _calculateFromList(ingredientsRaw);
      }

      if (ingredientsRaw is String) {
        try {
          final jsonData = jsonDecode(ingredientsRaw);
          if (jsonData is List) {
            return _calculateFromList(jsonData);
          }
        } catch (e) {
          return _parseWeightFromText(ingredientsRaw);
        }
      }

      return 500;
    } catch (e) {
      return 500;
    }
  }

  int _calculateFromList(List ingredients) {
    int totalWeight = 0;

    for (final ingredient in ingredients) {
      if (ingredient is Map<String, dynamic>) {
        final amount = ingredient['amount'];
        final unit = ingredient['unit'] as String?;

        if (amount is num && unit == 'g') {
          totalWeight += amount.toInt();
        } else if (amount is String && unit == 'g') {
          final parsedAmount = int.tryParse(amount);
          if (parsedAmount != null) {
            totalWeight += parsedAmount;
          }
        }
      }
    }

    return totalWeight > 0 ? totalWeight : 500;
  }

  int _parseWeightFromText(String text) {
    final lines = text.split('\n');
    int totalWeight = 0;

    for (final line in lines) {
      final weightMatch = RegExp(r'(\d+)g').firstMatch(line);
      if (weightMatch != null) {
        final weight = int.tryParse(weightMatch.group(1) ?? '0') ?? 0;
        totalWeight += weight;
      }
    }

    return totalWeight > 0 ? totalWeight : 500;
  }

  /// ✅ [제거됨] 최종 반죽온도 계산 - 컨트롤러에서만 가져오기
  /// UI 레이어에서는 계산 로직을 가지지 않음

  /// ✅ 실시간 단계별 분석 UI 위젯 생성 (부분 완료 단계 지원)
  List<Widget> _buildStepAnalysisWidgets() {
    final completedSteps = _stepAnalyses.length;
    final totalSteps = _mixingSteps.length;
    final widgets = <Widget>[];

    // 완료된 단계들 표시
    for (final analysis in _stepAnalyses) {
      widgets.add(MixingStepCardImproved(
        stepIndex: analysis.stepNumber - 1,
        step: <String, dynamic>{
          'stepNumber': analysis.stepNumber,
          'speed': analysis.speed,
          'durationMinutes': analysis.durationMinutes,
          'comment': '',
          'temperature': analysis.doughState.temperature,
          // 환경 데이터 추가 (습도 및 시간 정보 포함)
          'environment': {
            'humidity':
                widget.environment.humidity?.toStringAsFixed(1) ?? 'N/A',
            'mixingTime': '${analysis.durationMinutes}분',
          },
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
          'isFinalStep': analysis.stepNumber == totalSteps,
        },
        totalSteps: totalSteps,
      ));
    }

    // 남은 단계들은 "분석 대기 중"으로 표시 (실시간 업데이트 지원)
    if (_controller?.isAnalyzing ?? false) {
      for (int i = completedSteps; i < totalSteps; i++) {
        final stepNumber = i + 1;
        widgets.add(Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '$stepNumber',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '단계 $stepNumber',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.orange.shade400),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '빵 제조 과학적 계산 진행 중...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
      }
    }

    return widgets;
  }

  /// 안전한 온도 단위 변환
  String _formatTemperatureValueSafely(double value) {
    if (value < -50 || value > 100 || value.isNaN || value.isInfinite) {
      return '측정 중...';
    }
    return '${value.toStringAsFixed(0)}°C';
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerUpdate);
    if (widget.externalController == null) {
      _controller?.dispose();
    }
    super.dispose();
  }
}
