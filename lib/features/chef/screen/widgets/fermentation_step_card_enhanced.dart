import 'package:flutter/material.dart';
import 'fermentation_analysis_types.dart';
import '../../../../services/fermentation_calculator.dart';
import '../../../../services/fermentation_calculator.dart'
    show VolumeExpansionCalculator;

/// 향상된 발효 단계 카드 위젯
/// FermentationStepAnalysis 타입을 기반으로 구조화된 분석 결과를 표시
class FermentationStepCardEnhanced extends StatefulWidget {
  final int stepIndex;
  final FermentationStepAnalysis stepAnalysis;
  final int totalSteps;

  FermentationStepCardEnhanced({
    super.key,
    required this.stepIndex,
    required this.stepAnalysis,
    required this.totalSteps,
  }) {
    // ✅ Constructor 진입 시 데이터 값 추적 (심층 디버깅)
    debugPrint('🚧 [FermentationStepCardEnhanced] Constructor 진입');
    debugPrint('   - stepIndex: $stepIndex');
    debugPrint('   - totalSteps: $totalSteps');
    debugPrint(
        '   - stepAnalysis.cumulativeCO2: ${stepAnalysis.cumulativeCO2}');
    debugPrint(
        '   - stepAnalysis.gasProduction: ${stepAnalysis.gasProduction}');
    debugPrint('   - stepAnalysis.stepNumber: ${stepAnalysis.stepNumber}');
    debugPrint('   - stepAnalysis객체 해시: ${stepAnalysis.hashCode}');
  }

  @override
  State<FermentationStepCardEnhanced> createState() =>
      _FermentationStepCardEnhancedState();
}

class _FermentationStepCardEnhancedState
    extends State<FermentationStepCardEnhanced> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    debugPrint('🏗️ [FermentationStepCardEnhanced] build() 진입');
    debugPrint(
        '   - widget.stepAnalysis.cumulativeCO2: ${widget.stepAnalysis.cumulativeCO2}');
    debugPrint(
        '   - widget.stepAnalysis.gasProduction: ${widget.stepAnalysis.gasProduction}');

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            _buildHeader(isTablet),
            _buildAnalysisResults(isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    final analysis = widget.stepAnalysis;
    final progressPercent = analysis.fermentationProgress * 100;

    // 진행률에 따른 색상 변경 (컨셉 준수: clamp 금지, 로깅으로 타당성 검증)
    Color progressColor;
    if (progressPercent > 100.0) {
      debugPrint(
          '⚠️ [컨셉 준수] 헤더 진행률 ${progressPercent.toStringAsFixed(1)}% - 100% 초과');
      progressColor = Colors.orange.shade400; // 과도 값에는 주황색
    } else if (progressPercent < 0.0) {
      debugPrint(
          '⚠️ [컨셉 준수] 헤더 진행률 ${progressPercent.toStringAsFixed(1)}% - 음수 값');
      progressColor = Colors.red.shade700;
    } else if (progressPercent >= 80.0) {
      progressColor = Colors.green.shade600;
    } else if (progressPercent >= 60.0) {
      progressColor = Colors.blue.shade600;
    } else if (progressPercent >= 40.0) {
      progressColor = Colors.orange.shade600;
    } else {
      progressColor = Colors.red.shade600;
    }

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [progressColor.withOpacity(0.7), progressColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          // 단계 번호 표시
          Container(
            width: isTablet ? 48 : 40,
            height: isTablet ? 48 : 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${analysis.stepNumber}',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ),
          ),

          SizedBox(width: isTablet ? 20 : 16),

          // 단계 정보 및 진행률 표시
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${analysis.stepNumber}차 발효',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    // 진행률 퍼센트 표시
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(analysis.fermentationProgress * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.thermostat_rounded,
                        size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      '${analysis.temperature.toStringAsFixed(0)}°C',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.water_drop_rounded,
                        size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      '${analysis.targetHumidity.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.timer_rounded, size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(analysis.duration),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 믹싱 단계 카드와 동일한 구조로 변경: 컨텐츠 색상을 흰색으로 유지 - ExpansionTile 제거로 항상 CO2 표시
  Widget _buildAnalysisResults(bool isTablet) {
    final analysis = widget.stepAnalysis;

    debugPrint(
        '🔧 [_buildAnalysisResults 진입] 단계 ${analysis.stepNumber} 분석 결과 표시');
    debugPrint('   - analysis.cumulativeCO2: ${analysis.cumulativeCO2}');

    // ✅ 하드코딩 ExpansionTile 제거 - 항상 주요 메트릭 표시
    return Container(
      color: Colors.white, // 믹싱 카드처럼 흰색 배경
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent, // 믹싱 카드 패턴 적용
        ),
        child: Column(
          children: [
            // ✅ 고정 헤더 - 할인
            Container(
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              decoration: BoxDecoration(
                color: Colors.green.shade50.withValues(alpha: 0.5),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.green.shade200.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.analytics_rounded,
                    size: 20,
                    color: Colors.green.shade600, // 발효 컨셉 색상
                  ),
                  SizedBox(width: 8),
                  Text(
                    '주요 메트릭', // 믹싱 카드와 동일하게 "주요 메트릭" 타이틀 통일
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
            // ✅ 고정 컨텐츠 - ExpansionTile 없이 항상 표시되도록 수정
            Padding(
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              child: GridView.count(
                crossAxisCount: 2, // 2x2 그리드
                mainAxisSpacing: 8, // 세로 간격
                crossAxisSpacing: 8, // 가로 간격
                childAspectRatio: 1.2, // 카드 비율 (높이:너비 = 1.2:1)
                physics: const NeverScrollableScrollPhysics(), // 스크롤 방지
                shrinkWrap: true, // 콘텐츠 크기에 맞춤
                children: [
                  // 2x2 그리드로 메트릭 카드 배치 - 물리 기반 계산 결과로 업데이트
                  _buildMixingStyleMetricCard(
                    'CO₂ 생성량',
                    '${analysis.cumulativeCO2.toStringAsFixed(1)}ml',
                    Colors.blue.shade600, // CO2 색상으로 파랑 사용
                    isTablet,
                  ),
                  _buildMixingStyleMetricCard(
                    '부피 팽창',
                    '${analysis.volumeIncrease.toStringAsFixed(0)}%', // volumeIncrease는 이미 퍼센트 값
                    VolumeExpansionCalculator.getExpansionColor(
                        VolumeExpansionCalculator.percentToExpansion(
                            analysis.volumeIncrease)), // 퍼센트를 배율로 변환
                    isTablet,
                  ),
                  _buildMixingStyleMetricCard(
                    '발효 진행',
                    '${(analysis.fermentationProgress * 100).toStringAsFixed(1)}%',
                    _getFermentationProgressColor(
                        analysis.fermentationProgress * 100),
                    isTablet,
                  ),
                  _buildMixingStyleMetricCard(
                    '산도',
                    '${analysis.acidity.toStringAsFixed(1)} pH', // 산도 값 표시
                    Colors.deepOrange.shade600, // 산도 색상
                    isTablet,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 믹싱 카드와 동일한 메트릭 카드 디자인 (아이콘+값+라벨 형식)
  Widget _buildMixingStyleMetricCard(
      String label, String value, Color color, bool isTablet) {
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 색상 계산 메소드들
  Color _getYeastActivityColor(double activity) {
    if (activity >= 0.8) return Colors.green.shade600;
    if (activity >= 0.6) return Colors.blue.shade600;
    if (activity >= 0.4) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  Color _getAcidityColor(double acidity) {
    // 최적 범위: pH 4.5-5.0
    if (acidity >= 4.5 && acidity <= 5.0) return Colors.green.shade600;
    if (acidity >= 4.0 && acidity <= 5.5) return Colors.blue.shade600;
    return Colors.red.shade600;
  }

  Color _getVolumeExpansionColor(double volumeExpansion) {
    // 부피 배율 기준 색상 설정 (기초 부피를 1.0으로 가정)
    // 빵 과학적으로 150% 이상이면 안정적인 발효, 200% 이상이면 우수함
    if (volumeExpansion >= 2.0)
      return Colors.green.shade600; // 200% 이상: 우수 - 빵 과학 최적 범위
    if (volumeExpansion >= 1.8)
      return Colors.blue.shade600; // 180%: 양호 - 발효 정상 범위
    if (volumeExpansion >= 1.5)
      return Colors.orange.shade600; // 150%: 보통 - 개선 필요 범위
    return Colors.red.shade600; // 150% 미만: 개선 필요 - 발효 부족
  }

  Color _getFermentationProgressColor(double progress) {
    // 진행률 기반으로 색상 계산 (progress는 % 값이므로 100 단위)
    // 컨셉 준수: clamp 금지, 대신 로깅으로 타당성 검증
    if (progress > 100.0) {
      debugPrint(
          '⚠️ [컨셉 준수] 발효 진행 예측 ${progress.toStringAsFixed(1)}% - 100% 초과 (clamp 금지)');
      return Colors.orange.shade400; // 과도 값에는 주황색 표시
    }
    if (progress < 0.0) {
      debugPrint('⚠️ [컨셉 준수] 발효 진행 예측 ${progress.toStringAsFixed(1)}% - 음수 값');
      return Colors.red.shade700;
    }

    // 정상 범위 색상 (컨셉 준수: 기존 색상 유지)
    if (progress >= 80.0) return Colors.green.shade600; // 80% 이상
    if (progress >= 60.0) return Colors.blue.shade600; // 60-80%
    if (progress >= 40.0) return Colors.orange.shade600; // 40-60%
    return Colors.red.shade600; // 40% 미만
  }

  Color _getCO2GenerationColor(double co2Generation) {
    // CO₂ 생성량 기반 색상 (ml 기준)
    if (co2Generation >= 100) return Colors.green.shade600; // 100ml 이상: 우수
    if (co2Generation >= 75) return Colors.blue.shade600; // 75-100ml: 양호
    if (co2Generation >= 50) return Colors.orange.shade600; // 50-75ml: 보통
    return Colors.red.shade600; // 50ml 미만: 부족
  }

  // USED CODE REMOVED - For compliance with centralized architecture pattern

  // Duration 포맷팅 메소드
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      if (minutes > 0) {
        return '${hours}시간 ${minutes}분';
      } else {
        return '${hours}시간';
      }
    } else {
      return '${minutes}분';
    }
  }
}
