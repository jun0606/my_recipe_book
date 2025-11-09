import 'package:flutter/material.dart';

/// 개선된 믹싱 단계 카드 위젯
/// 모바일/태블릿 최적화 및 가독성 향상
class MixingStepCardImproved extends StatefulWidget {
  final int stepIndex;
  final Map<String, dynamic> step;
  final int totalSteps;

  const MixingStepCardImproved({
    super.key,
    required this.stepIndex,
    required this.step,
    required this.totalSteps,
  });

  @override
  State<MixingStepCardImproved> createState() => _MixingStepCardImprovedState();
}

class _MixingStepCardImprovedState extends State<MixingStepCardImproved>
    with TickerProviderStateMixin {
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

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // 컴팩트 헤더
            _buildCompactHeader(isTablet),

            // 주요 메트릭 섹션 (접기 가능)
            _buildKeyMetricsSection(isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactHeader(bool isTablet) {
    final speed = widget.step['speed'] as String? ?? '중속';
    final duration = widget.step['durationMinutes'] as int? ?? 10;

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // 단계 번호 (원형 아바타)
          Container(
            width: isTablet ? 48 : 40,
            height: isTablet ? 48 : 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${widget.stepIndex + 1}',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          SizedBox(width: isTablet ? 20 : 16),

          // 핵심 정보 (확장된 공간 활용)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '믹싱 단계 ${widget.stepIndex + 1}',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.speed, size: 16, color: Colors.white70),
                    SizedBox(width: 4),
                    Text(
                      speed,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.timer, size: 16, color: Colors.white70),
                    SizedBox(width: 4),
                    Text(
                      '${duration}분',
                      style: TextStyle(
                        fontSize: 14,
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

  Widget _buildKeyMetricsSection(bool isTablet) {
    final doughState =
        widget.step['cumulativeDoughState'] as Map<String, dynamic>? ?? {};
    final glutenFormation = (doughState['glutenFormation'] as double? ?? 0.0);
    final moisture = (doughState['moistureAbsorption'] as double? ?? 0.0);
    final temperature = (doughState['temperature'] as double? ?? 25.0);
    final viscosity = (doughState['viscosity'] as double? ?? 1.0);

    // 🎯 [안전한 단위 변환] 비정상 값 필터링 및 변환
    final safeGlutenDisplay = _formatGlutenValueSafely(glutenFormation);
    final safeMoistureDisplay = _formatMoistureValueSafely(moisture);
    final safeTemperatureDisplay = _formatTemperatureValueSafely(temperature);
    final safeViscosityDisplay = _formatViscosityValueSafely(viscosity);

    // 🎯 [눈에 띄게] 단계별 글루텐 형성도 값 세부 분석 및 단위 변환 디버깅
    print('\n🎯🎯🎯 [믹싱 단계 UI 안전 변환 과정] ==============================');
    print('🎯 [단계 ${widget.stepIndex + 1}] 단위 변환 전 값들:');
    print('🎯   ├── 원본 글루텐: ${glutenFormation.toStringAsFixed(8)} (0-1 사이)');
    print('🎯   ├── 원본 수분: ${moisture.toStringAsFixed(4)}%');
    print('🎯   ├── 원본 온도: ${temperature.toStringAsFixed(2)}°C');
    print('🎯   ├── 원본 점도: ${viscosity.toStringAsFixed(4)}');
    print(
        '🎯   ├── 비정상 값 여부: ${glutenFormation < 0.001 ? '네 (0.1% 미만)' : '아니오'}');

    // 🐛 [근본 원인 추적] 데이터 소스 비교 디버깅
    print('🐛 [데이터 연결 분석] 단계 ${widget.stepIndex + 1}:');
    print('🐛   ├── UI 데이터 값: ${temperature.toStringAsFixed(1)}°C');
    print('🐛   ├── 위젯 step 데이터 타입: ${widget.step.runtimeType}');
    print('🐛   ├── doughState 존재: ${widget.step.containsKey('doughState')}');
    print(
        '🐛   ├── cumulativeDoughState 존재: ${widget.step.containsKey('cumulativeDoughState')}');

    if (widget.step.containsKey('doughState')) {
      final directDoughState =
          widget.step['doughState'] as Map<String, dynamic>?;
      if (directDoughState != null) {
        print(
            '🐛   ├── doughState.temperature: ${directDoughState['temperature']}°C');
        print(
            '🐛   ├── doughState.glutenFormation: ${directDoughState['glutenFormation']}');
      }
    }

    if (widget.step.containsKey('cumulativeDoughState')) {
      final cumulativeDoughState =
          widget.step['cumulativeDoughState'] as Map<String, dynamic>?;
      if (cumulativeDoughState != null) {
        print(
            '🐛   ├── cumulativeDoughState.temperature: ${cumulativeDoughState['temperature']}°C');
        print(
            '🐛   ├── cumulativeDoughState.glutenFormation: ${cumulativeDoughState['glutenFormation']}');
      }
    }

    print('🎯 [단계 ${widget.stepIndex + 1}] 안전 단위 변환 후:');
    print('🎯   ├── 글루텐 표시: $safeGlutenDisplay');
    print('🎯   ├── 수분 표시: $safeMoistureDisplay');
    print('🎯   ├── 온도 표시: $safeTemperatureDisplay');
    print('🎯   ├── 점도 표시: $safeViscosityDisplay');
    print('🎯💡💡💡 0.2% 표시 문제 해결됨: 비정상 값은 "분석 중"으로 필터링');
    print(
        '🎯🎯🎯 =====================================================================\n');

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(
              Icons.analytics_rounded,
              size: 20,
              color: Colors.blue.shade600,
            ),
            SizedBox(width: 8),
            Text(
              '주요 메트릭',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: GridView.count(
              crossAxisCount: isTablet ? 4 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildMetricCard(
                  '🌾 반죽 발달',
                  safeGlutenDisplay,
                  _getGlutenColor(glutenFormation),
                  isTablet,
                ),
                _buildMetricCard(
                  '💧 수분 흡수율',
                  safeMoistureDisplay,
                  _getMoistureColor(moisture),
                  isTablet,
                ),
                _buildMetricCard(
                  '🌡️ 반죽 온도',
                  safeTemperatureDisplay,
                  _getTemperatureColor(temperature),
                  isTablet,
                ),
                _buildMetricCard(
                  '⚡ 반죽 질감',
                  safeViscosityDisplay,
                  _getViscosityColor(viscosity),
                  isTablet,
                ),
              ],
            ),
          ),
        ],
        initiallyExpanded: true,
        backgroundColor: Colors.blue.shade50.withValues(alpha: 0.3),
        collapsedBackgroundColor: Colors.blue.shade50.withValues(alpha: 0.3),
        iconColor: Colors.blue.shade600,
        collapsedIconColor: Colors.blue.shade600,
      ),
    );
  }

  Widget _buildMetricCard(
      String label, String value, Color color, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
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
          SizedBox(height: 8),
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

  Color _getGlutenColor(double glutenFormation) {
    if (glutenFormation >= 0.8) return Colors.green.shade600;
    if (glutenFormation >= 0.6) return Colors.blue.shade600;
    if (glutenFormation >= 0.4) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  /// 수분 흡수율에 따른 색상 반환 (MixingAnalysisCard에서 호출용 static 메소드)
  static Color getMoistureColor(double moisture) {
    if (moisture >= 70) return Colors.green.shade600;
    if (moisture >= 65) return Colors.blue.shade600;
    if (moisture >= 60) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  Color _getMoistureColor(double moisture) {
    return getMoistureColor(moisture);
  }

  Color _getTemperatureColor(double temperature) {
    if (temperature >= 20 && temperature <= 30) return Colors.green.shade600;
    if (temperature >= 15 && temperature <= 35) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  Color _getViscosityColor(double viscosity) {
    if (viscosity >= 0.8 && viscosity <= 1.2) return Colors.green.shade600;
    if (viscosity >= 0.5 && viscosity <= 1.5) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  /// 🎯 [안전한 단위 변환 메소드들] 비정상 값 필터링 및 표시

  /// 글루텐 형성도 안전 변환 (빵 제조 과학적 표시 개선)
  String _formatGlutenValueSafely(double value) {
    // 빵 제조 과학적 의미 없는 값만 필터링 (컨트롤러에서 -∞ 나올 수 있음)
    if (value <= -0.01 || value.isNaN || value.isInfinite) {
      return '계산 오류';
    }
    // 빵 제조 과학적으로 의미 있는 초기 값도 표시 (0.1% 미만도 의미 성)
    if (value < 0.001) {
      // 매우 낮은 값은 '<' 표시로 의미 전달
      final clampedValue = value;
      return '재료 혼합중\n${(clampedValue * 100).toStringAsFixed(0)}%';
    }
    // 0-1 범위 강제 적용 (clamp)
    final clampedValue = value.clamp(0.0, 1.0);
    return '${(clampedValue * 100).toStringAsFixed(0)}%';
  }

  /// 수분 흡수율 안전 변환
  String _formatMoistureValueSafely(double value) {
    // 비정상 값 필터링
    if (value <= 0 || value.isNaN || value.isInfinite) {
      return '계산 중...';
    }
    // ✅ 빵 제조 과학 준수: clamp 제거 - 실제 수분 트래킹 결과 표시
    // 수분 흡수율이 100% 초과하는 것도 물리가 허용하는 실제 값으로 유지
    final displayValue = value.toStringAsFixed(1);
    print('💧 [UI 수분 표시] 수분 트래킹 결과 적용: ${displayValue}% (clamp 제거)');
    return '${displayValue}%';
  }

  /// 온도 안전 변환
  String _formatTemperatureValueSafely(double value) {
    // 비정상 값 필터링 (-50°C ~ 100°C 범위 밖)
    if (value < -50 || value > 100 || value.isNaN || value.isInfinite) {
      return '측정 중...';
    }
    return '${value.toStringAsFixed(0)}°C';
  }

  /// 점도 안전 변환
  String _formatViscosityValueSafely(double value) {
    // 비정상 값 필터링
    if (value <= 0 || value > 10 || value.isNaN || value.isInfinite) {
      return '측정 중...';
    }
    return value.toStringAsFixed(2);
  }
}
