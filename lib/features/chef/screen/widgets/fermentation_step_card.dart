import 'package:flutter/material.dart';

/// 발효 단계별 기본 정보 카드 위젯
/// 레시피의 발효 단계 기본 정보를 표시 (온도, 습도, 시간)
/// 계산 결과는 FermentationAnalysisCard의 분석 결과 섹션에서 표시됨
class FermentationStepCard extends StatefulWidget {
  final int stepIndex;
  final Map<String, dynamic> step;
  final int totalSteps;

  const FermentationStepCard({
    super.key,
    required this.stepIndex,
    required this.step,
    required this.totalSteps,
  });

  @override
  State<FermentationStepCard> createState() => _FermentationStepCardState();
}

class _FermentationStepCardState extends State<FermentationStepCard>
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
        child: _buildCompactHeader(isTablet), // ✅ 계산 결과 메트릭 섹션 제거
      ),
    );
  }

  Widget _buildCompactHeader(bool isTablet) {
    final stepNumber =
        widget.step['stepNumber'] as int? ?? widget.stepIndex + 1;
    final temperature = widget.step['targetTemperature'] as double? ?? 25.0;
    final humidity = widget.step['targetHumidity'] as int? ?? 70;
    final durationHours = widget.step['durationHours'] as double? ?? 2.0;

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
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
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$stepNumber',
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
                  '발효 단계 $stepNumber',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.thermostat_rounded,
                        size: 16, color: Colors.white70),
                    SizedBox(width: 4),
                    Text(
                      '${temperature.toStringAsFixed(0)}°C',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.water_drop_rounded,
                        size: 16, color: Colors.white70),
                    SizedBox(width: 4),
                    Text(
                      '${humidity}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.timer_rounded, size: 16, color: Colors.white70),
                    SizedBox(width: 4),
                    Text(
                      _formatTimeDisplay(durationHours),
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

  // 시간 표시 포맷
  String _formatTimeDisplay(double hours) {
    if (hours >= 1.0) {
      return '${hours.toStringAsFixed(0)}시간';
    } else {
      final minutes = (hours * 60).round();
      return '${minutes}분';
    }
  }
}
