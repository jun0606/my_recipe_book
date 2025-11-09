// 믹싱 단계별 카드 컴포넌트
// 개별 믹싱 단계의 UI를 담당하는 컴포넌트

import 'dart:convert';
import 'package:flutter/material.dart';
import 'mixing_analysis_types.dart' as mat;
import 'mixing_analysis_utils.dart';
import '../../../../core/utils/safe_value_utils.dart';
import '../../../../services/environment_defaults_calculator.dart';
import '../../../../services/ingredient_analyzer.dart';
import '../../../../services/recipe_data_parser.dart';

/// 믹싱 단계별 카드 위젯
class MixingStepCard extends StatefulWidget {
  final mat.MixingStep step;
  final mat.MixingStepAnalysis? stepAnalysis;
  final bool isExpanded;
  final VoidCallback onToggle;
  final int stepIndex;
  final double baseMoisture; // 초기 수분율 추가
  final Map<String, dynamic>? recipeData; // 레시피 데이터 추가

  const MixingStepCard({
    super.key,
    required this.step,
    required this.stepAnalysis, // ✅ 필수 파라미터로 변경 (동적 온도 보장)
    required this.isExpanded,
    required this.onToggle,
    required this.stepIndex,
    required this.baseMoisture, // 필수 파라미터로 추가
    this.recipeData, // 레시피 데이터 추가
  });

  @override
  State<MixingStepCard> createState() => _MixingStepCardState();
}

class _MixingStepCardState extends State<MixingStepCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void didUpdateWidget(MixingStepCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isExpanded != widget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _heightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 헤더 부분 (항상 표시)
          _buildHeader(),
          // 확장된 내용 (토글 시 표시)
          _buildExpandableContent(),
        ],
      ),
    );
  }

  /// 카드 헤더 빌드
  Widget _buildHeader() {
    return InkWell(
      onTap: widget.onToggle,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _getStepColor(),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: Row(
          children: [
            // 단계 번호와 아이콘
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${widget.stepIndex + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 단계 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.step.comment.isNotEmpty
                        ? widget.step.comment
                        : '믹싱 단계 ${widget.stepIndex + 1}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        _getSpeedIcon(),
                        size: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.step.speed} · ${widget.step.durationMinutes}분',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 토글 아이콘
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                widget.isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 확장 가능한 내용 빌드
  Widget _buildExpandableContent() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ClipRect(
          child: Align(
            heightFactor: _heightAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 기본 메트릭 정보 (항상 표시)
            _buildBasicMetrics(),
            const SizedBox(height: 12),
            _buildDetailedMetrics(),

            // 권장사항
            if (widget.stepAnalysis?.recommendations.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              _buildRecommendations(),
            ],
          ],
        ),
      ),
    );
  }

  /// 기본 메트릭 정보 빌드
  Widget _buildBasicMetrics() {
    final analysis = widget.stepAnalysis;
    final doughState = analysis?.doughState;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // 1행: 속도와 시간
          Row(
            children: [
              Expanded(
                child: _buildSimpleMetric(
                  '속도',
                  analysis?.speed ?? '알 수 없음',
                  _getScoreColor(0.8),
                ),
              ),
              Expanded(
                child: _buildSimpleMetric(
                  '시간',
                  analysis != null ? '${analysis.durationMinutes}분' : '0분',
                  _getScoreColor(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 2행: 글루텐 형성과 상태
          Row(
            children: [
              Expanded(
                child: _buildSimpleMetric(
                  '글루텐 형성',
                  doughState != null
                      ? '${(doughState.glutenFormation * 100).toStringAsFixed(1)}%'
                      : '계산 중...',
                  doughState != null
                      ? _getGlutenColor(doughState.glutenFormation)
                      : Colors.grey.shade600,
                ),
              ),
              Expanded(
                child: _buildSimpleMetric(
                  '상태',
                  doughState?.developmentStage ?? '알 수 없음',
                  _getScoreColor(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 상세 메트릭 정보 빌드 (UI 구조 유지)
  Widget _buildDetailedMetrics() {
    final analysis = widget.stepAnalysis;
    final doughState = analysis?.doughState;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.science,
                size: 16,
                color: Color(0xFF2E7D32),
              ),
              const SizedBox(width: 6),
              const Text(
                '상세 메트릭',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 메트릭을 2x2 그리드로 배치하여 가독성 향상
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // 왼쪽 위: 수분 흡수율 - 완전 별도 위젯으로 분리
              _buildMoistureMetric(doughState),

              // 오른쪽 위: 점도 (개선된 표시)
              _buildViscosityMetric(doughState),

              // 왼쪽 아래: 온도
              _buildTemperatureMetric(doughState),

              // 오른쪽 아래: RPM
              _buildRPMMetric(analysis),
            ],
          ),
        ],
      ),
    );
  }

  /// 권장사항 빌드
  Widget _buildRecommendations() {
    final recommendations = widget.stepAnalysis?.recommendations ?? [];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '관측 현상',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 4),
          ...recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '• $rec',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF1976D2),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  /// 로딩 상태 빌드
  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: const Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text(
              '분석 중...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 수분 메트릭 별도 위젯 생성 (UI 구조 유지 보장)
  Widget _buildMoistureMetric(mat.DoughState? doughState) {
    try {
      // 데이터가 없거나 수분 값이 유효하지 않으면 기본값 표시
      if (doughState == null ||
          doughState.moistureAbsorption.isNaN ||
          doughState.moistureAbsorption <= 0) {
        print('⚠️ [수분 메트릭] 데이터 없음 또는 유효하지 않음, 기본값 표시');

        return _buildDetailedMetric(
          '수분 흡수율',
          '0.0%', // 계산값 없으면 0 표시
          Colors.grey.shade600,
          '적정 범위: 60.0-80.0%',
        );
      }

      final moistureText =
          _getMoistureDisplayText(doughState.moistureAbsorption);
      final moistureColor =
          _getMoistureDisplayColor(doughState.moistureAbsorption);
      final moistureRange =
          _getMoistureRangeText(doughState.moistureAbsorption);

      print(
          '🔍 [수분 메트릭] 값: $moistureText, 색상: $moistureColor, 범위: $moistureRange');

      return _buildDetailedMetric(
        '수분 흡수율',
        moistureText,
        moistureColor,
        moistureRange,
      );
    } catch (e) {
      print('❌ 수분 메트릭 생성 실패: $e');
      // 오류 시에도 UI 구조 유지 (0 표시)
      return _buildDetailedMetric(
        '수분 흡수율',
        '0.0%', // 오류 시 0 표시로 UI 구조 유지
        Colors.grey.shade600,
        '적정 범위: 60.0-80.0%',
      );
    }
  }

  /// 점도 메트릭 생성
  Widget _buildViscosityMetric(mat.DoughState? doughState) {
    try {
      if (doughState == null) {
        return _buildDetailedMetric(
          '점도',
          '0.0\n(알 수 없음)',
          Colors.grey.shade600,
          '적정: 1.5-2.0',
        );
      }

      final viscosityText =
          '${doughState.viscosity.toStringAsFixed(1)}\n(${_getViscosityStatus(doughState.viscosity)})';
      final viscosityColor = _getViscosityColor(doughState.viscosity);

      return _buildDetailedMetric(
        '점도',
        viscosityText,
        viscosityColor,
        '적정: 1.5-2.0',
      );
    } catch (e) {
      print('❌ 점도 메트릭 생성 실패: $e');
      return _buildDetailedMetric(
        '점도',
        '0.0\n(오류)',
        Colors.grey.shade600,
        '적정: 1.5-2.0',
      );
    }
  }

  /// 온도 메트릭 생성
  Widget _buildTemperatureMetric(mat.DoughState? doughState) {
    try {
      if (doughState == null) {
        return _buildDetailedMetric(
          '온도',
          '0.0°C',
          Colors.grey.shade600,
          _getTemperatureRangeText(),
        );
      }

      final temperatureText = '${doughState.temperature.toStringAsFixed(1)}°C';
      final temperatureColor = _getTemperatureColor(doughState.temperature);

      return _buildDetailedMetric(
        '온도',
        temperatureText,
        temperatureColor,
        _getTemperatureRangeText(),
      );
    } catch (e) {
      print('❌ 온도 메트릭 생성 실패: $e');
      return _buildDetailedMetric(
        '온도',
        '0.0°C',
        Colors.grey.shade600,
        _getTemperatureRangeText(),
      );
    }
  }

  /// RPM 메트릭 생성
  Widget _buildRPMMetric(mat.MixingStepAnalysis? analysis) {
    try {
      if (analysis == null) {
        return _buildDetailedMetric(
          'RPM',
          '0',
          Colors.grey.shade600,
          '회전 속도',
        );
      }

      final rpmText = '${analysis.rpm.toStringAsFixed(0)}';

      return _buildDetailedMetric(
        'RPM',
        rpmText,
        _getScoreColor(0.8),
        '회전 속도',
      );
    } catch (e) {
      print('❌ RPM 메트릭 생성 실패: $e');
      return _buildDetailedMetric(
        'RPM',
        '0',
        Colors.grey.shade600,
        '회전 속도',
      );
    }
  }

  /// 단계별 색상 결정
  Color _getStepColor() {
    switch (widget.stepIndex) {
      case 0:
        return const Color(0xFF4CAF50); // 초록색 - 1단계
      case 1:
        return const Color(0xFF2196F3); // 파란색 - 2단계
      case 2:
        return const Color(0xFFFF9800); // 주황색 - 3단계
      default:
        return const Color(0xFF9C27B0); // 보라색 - 추가 단계
    }
  }

  /// 속도별 아이콘 결정
  IconData _getSpeedIcon() {
    switch (widget.step.speed) {
      case '저속':
        return Icons.speed;
      case '중속':
        return Icons.trending_up;
      case '고속':
        return Icons.flash_on;
      default:
        return Icons.help_outline;
    }
  }

  /// 수분 흡수율 표시 텍스트 생성 (SafeValueFormatter 활용 - 거짓 정보 방지)
  String _getMoistureDisplayText(double moistureAbsorption) {
    // SafeValueFormatter를 활용하여 안전한 표시
    return SafeValueFormatter.formatMoisture(moistureAbsorption);
  }

  /// 수분 흡수율 표시 색상 결정
  Color _getMoistureDisplayColor(double moistureAbsorption) {
    if (moistureAbsorption.isNaN) {
      return Colors.grey.shade600;
    }
    return _getMoistureAbsorptionColor(
      moistureAbsorption,
      widget.baseMoisture,
      widget.stepIndex,
      widget.step.speed,
      widget.step.durationMinutes,
    );
  }

  /// 단계별 수분율 범위 텍스트 생성
  String _getMoistureRangeText(double moistureAbsorption) {
    if (moistureAbsorption.isNaN) {
      return '적정 범위: 60.0-80.0%';
    }

    final expectedRange = _calculateExpectedMoistureRange(
      moistureAbsorption,
      widget.stepIndex,
      widget.step.speed,
      widget.step.durationMinutes,
    );

    final minRange = expectedRange['min'] ?? (moistureAbsorption - 5.0);
    final maxRange = expectedRange['max'] ?? (moistureAbsorption + 5.0);

    return '적정 범위: ${minRange.toStringAsFixed(1)}-${maxRange.toStringAsFixed(1)}%';
  }

  /// 레시피에 액체 재료가 있는지 확인
  bool _hasLiquidIngredientsInRecipe() {
    if (widget.recipeData == null) return true; // 데이터 없어도 수분 표시 우선

    try {
      // IngredientAnalyzer를 활용하여 액체 재료 확인
      final liquidIngredients = IngredientAnalyzer.findLiquidIngredients(
        _getIngredientsFromRecipeData(widget.recipeData),
        recipeTitle: widget.recipeData!['title'] as String?,
      );
      return liquidIngredients.isNotEmpty;
    } catch (e) {
      print('액체 재료 확인 중 오류: $e');
      // 파싱 실패 시 수분 값 표시 우선 (true 반환)
      return true;
    }
  }

  /// 중앙 집중화된 RecipeDataParser 활용 (중복 제거)
  /// TODO: 모든 호출부를 RecipeDataParser.parseFromMap()으로 교체 후 제거
  @deprecated
  List<Map<String, dynamic>> _getIngredientsFromRecipeData([
    Map<String, dynamic>? recipeData,
  ]) {
    if (recipeData == null) {
      return [];
    }

    try {
      // RecipeDataParser를 활용하여 재료 데이터 추출
      final parsedData =
          RecipeDataParser().parseIngredientsForMoisture(recipeData);

      // 파싱된 데이터를 레거시 형식으로 변환
      final ingredients = <Map<String, dynamic>>[];

      // 밀가루 재료 추가
      final flourWeight =
          (parsedData['flourWeight'] as num?)?.toDouble() ?? 0.0;
      if (flourWeight > 0) {
        ingredients.add({'name': '밀가루', 'amount': flourWeight, 'unit': 'g'});
      }

      // 물 재료 추가
      final waterWeight =
          (parsedData['waterWeight'] as num?)?.toDouble() ?? 0.0;
      if (waterWeight > 0) {
        ingredients.add({'name': '물', 'amount': waterWeight, 'unit': 'g'});
      }

      // 우유 재료 추가
      final milkWeight = (parsedData['milkWeight'] as num?)?.toDouble() ?? 0.0;
      if (milkWeight > 0) {
        ingredients.add({'name': '우유', 'amount': milkWeight, 'unit': 'g'});
      }

      print('🔄 [MixingStepCard] 레거시 호환성 메소드 사용: ${ingredients.length}개 재료 변환');
      return ingredients;
    } catch (e) {
      print('❌ [MixingStepCard] 레거시 메소드 파싱 실패: $e');
      return [];
    }
  }

  /// 온도 범위 텍스트 생성 (컨셉 준수 - 동적 계산)
  String _getTemperatureRangeText() {
    try {
      // 빵 제조 과학에 따른 최적 믹싱 온도 범위: 22-30°C
      // EnvironmentDefaultsCalculator 활용하여 동적 계산
      final optimalTemp =
          EnvironmentDefaultsCalculator.getOptimalFermentationTemperature();

      // 믹싱 단계에 따른 온도 범위 조정
      final minTemp = (optimalTemp - 4.0).clamp(20.0, 35.0); // 최소 20°C
      final maxTemp = (optimalTemp + 2.0).clamp(20.0, 35.0); // 최대 35°C

      return '적정 범위: ${minTemp.toStringAsFixed(0)}-${maxTemp.toStringAsFixed(0)}°C';
    } catch (e) {
      print('온도 범위 계산 실패: $e');
      return '적정 범위: 22-30°C'; // fallback
    }
  }

  /// 간단한 메트릭 위젯 생성 (존재하지 않는 클래스 대체)
  Widget _buildSimpleMetric(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 점수 기반 색상 반환 (존재하지 않는 클래스 대체)
  Color _getScoreColor(double score) {
    if (score >= 0.8) return Colors.green.shade600;
    if (score >= 0.6) return Colors.blue.shade600;
    if (score >= 0.4) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  /// 글루텐 형성도 기반 색상 반환 (존재하지 않는 클래스 대체)
  Color _getGlutenColor(double glutenFormation) {
    if (glutenFormation >= 0.8) return Colors.green.shade600;
    if (glutenFormation >= 0.6) return Colors.blue.shade600;
    if (glutenFormation >= 0.4) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  /// 상세 메트릭 위젯 생성 (존재하지 않는 클래스 대체)
  Widget _buildDetailedMetric(
      String label, String value, Color color, String range) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            range,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// 점도 상태 텍스트 반환 (존재하지 않는 클래스 대체)
  String _getViscosityStatus(double viscosity) {
    if (viscosity >= 2.0) return '높음';
    if (viscosity >= 1.5) return '적정';
    if (viscosity >= 1.0) return '낮음';
    return '매우 낮음';
  }

  /// 점도 색상 반환 (존재하지 않는 클래스 대체)
  Color _getViscosityColor(double viscosity) {
    if (viscosity >= 1.5 && viscosity <= 2.0) return Colors.green.shade600;
    if (viscosity >= 1.0 && viscosity <= 2.5) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  /// 온도 색상 반환 (존재하지 않는 클래스 대체)
  Color _getTemperatureColor(double temperature) {
    if (temperature >= 20 && temperature <= 30) return Colors.green.shade600;
    if (temperature >= 15 && temperature <= 35) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  /// 수분 흡수율 색상 반환 (존재하지 않는 클래스 대체)
  Color _getMoistureAbsorptionColor(double moisture, double baseMoisture,
      int stepIndex, String speed, int duration) {
    // 간단한 색상 로직 (실제로는 더 복잡한 계산이 필요할 수 있음)
    if (moisture >= 60 && moisture <= 80) return Colors.green.shade600;
    if (moisture >= 50 && moisture <= 90) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  /// 예상 수분 범위 계산 (존재하지 않는 클래스 대체)
  Map<String, double> _calculateExpectedMoistureRange(
      double moisture, int stepIndex, String speed, int duration) {
    // 간단한 범위 계산
    return {
      'min': moisture - 5.0,
      'max': moisture + 5.0,
    };
  }
}

//// 믹싱 단계 목록 위젯
class MixingStepList extends StatelessWidget {
  final List<mat.MixingStep> steps;
  final List<mat.MixingStepAnalysis> stepAnalyses;
  final List<bool> expandedStates;
  final Function(int) onToggleExpanded;
  final double baseMoisture; // 초기 수분율 추가
  final Map<String, dynamic>? recipeData; // 레시피 데이터 추가

  const MixingStepList({
    super.key,
    required this.steps,
    required this.stepAnalyses,
    required this.expandedStates,
    required this.onToggleExpanded,
    required this.baseMoisture, // 필수 파라미터로 추가
    this.recipeData, // 레시피 데이터 추가
  });

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: 12),
        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final stepAnalysis =
              index < stepAnalyses.length ? stepAnalyses[index] : null;
          final isExpanded =
              index < expandedStates.length ? expandedStates[index] : false;

          return MixingStepCard(
            step: step,
            stepAnalysis: stepAnalysis,
            isExpanded: isExpanded,
            onToggle: () => onToggleExpanded(index),
            stepIndex: index,
            baseMoisture: baseMoisture, // 초기 수분율 전달
            recipeData: recipeData, // 레시피 데이터 전달
          );
        }),
      ],
    );
  }
}
