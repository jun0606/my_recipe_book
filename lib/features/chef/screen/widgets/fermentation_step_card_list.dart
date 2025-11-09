import 'package:flutter/material.dart';
import 'fermentation_analysis_types.dart';
import '../../../../services/fermentation_calculator.dart';

/// 발효 단계 목록 위젯 (믹싱 단계 목록과 동일한 패턴으로 State 관리 추가)
class FermentationStepCardList extends StatefulWidget {
  final List<FermentationStepAnalysis> stepAnalyses;

  const FermentationStepCardList({
    super.key,
    required this.stepAnalyses,
  });

  @override
  State<FermentationStepCardList> createState() =>
      _FermentationStepCardListState();
}

class _FermentationStepCardListState extends State<FermentationStepCardList> {
  /// 각 단계의 확장 상태를 관리하는 리스트
  late List<bool> _expandedStates;

  @override
  void initState() {
    super.initState();
    // 초기에는 모든 단계가 확장 상태로 시작 (믹싱 패턴과 동일)
    _expandedStates = List.filled(widget.stepAnalyses.length, true);
  }

  @override
  void didUpdateWidget(FermentationStepCardList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 위젯 업데이트 시 단계 수 변동 처리
    if (oldWidget.stepAnalyses.length != widget.stepAnalyses.length) {
      setState(() {
        _expandedStates = List.filled(widget.stepAnalyses.length, true);
      });
    }
  }

  /// 특정 단계의 확장 상태를 토글하는 함수
  void _onToggleExpanded(int index) {
    setState(() {
      if (index < _expandedStates.length) {
        _expandedStates[index] = !_expandedStates[index];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '발효 단계별 분석',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        ...widget.stepAnalyses.asMap().entries.map((entry) {
          final index = entry.key;
          final stepAnalysis = entry.value;
          final isExpanded =
              index < _expandedStates.length ? _expandedStates[index] : false;

          return FermentationStepCard(
            stepAnalysis: stepAnalysis,
            isExpanded: isExpanded,
            onToggle: () => _onToggleExpanded(index),
            stepIndex: index,
            totalSteps: widget.stepAnalyses.length,
          );
        }),
      ],
    );
  }
}

/// 발효 단계별 카드 위젯 (믹싱 단계 카드 패턴 적용)
class FermentationStepCard extends StatefulWidget {
  final FermentationStepAnalysis stepAnalysis;
  final bool isExpanded;
  final VoidCallback onToggle;
  final int stepIndex;
  final int totalSteps;

  const FermentationStepCard({
    super.key,
    required this.stepAnalysis,
    required this.isExpanded,
    required this.onToggle,
    required this.stepIndex,
    required this.totalSteps,
  });

  @override
  State<FermentationStepCard> createState() => _FermentationStepCardState();
}

class _FermentationStepCardState extends State<FermentationStepCard>
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
  void didUpdateWidget(FermentationStepCard oldWidget) {
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
          // 헤더 부분 (항상 표시, 믹싱 패턴과 동일)
          _buildHeader(),
          // 확장된 내용 (토글 시 표시, 믹싱 패턴과 동일)
          _buildExpandableContent(),
        ],
      ),
    );
  }

  /// 카드 헤더 빌드 (믹싱 패턴 적용: InkWell + 토글 기능)
  Widget _buildHeader() {
    final analysis = widget.stepAnalysis;
    final progress = analysis.fermentationProgress;

    // 진행률에 따른 색상 변경 (발효 테마)
    Color headerColor;
    if (progress >= 0.8) {
      headerColor = Colors.green.shade600;
    } else if (progress >= 0.6) {
      headerColor = Colors.blue.shade600;
    } else if (progress >= 0.4) {
      headerColor = Colors.orange.shade600;
    } else {
      headerColor = Colors.red.shade600;
    }

    return InkWell(
      onTap: widget.onToggle,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: headerColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: Row(
          children: [
            // 단계 번호 표시 (믹싱 패턴과 동일)
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
                    analysis.stage.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${_formatDuration(analysis.duration)} · ${(analysis.temperature).toStringAsFixed(0)}°C',
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

            // 토글 아이콘 (믹싱 패턴과 동일)
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

  /// 확장 가능한 내용 빌드 (믹싱 패턴과 동일한 애니메이션 효과)
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
            // 상세 메트릭 정보 (2x2 그리드) - 기본 메트릭 제거됨
            _buildDetailedMetrics(),

            // 권장사항 (있는 경우에만)
            if (_hasRecommendations()) ...[
              const SizedBox(height: 12),
              _buildRecommendations(),
            ],
          ],
        ),
      ),
    );
  }

  /// 기본 메트릭 정보 빌드 (이스트 활성도, 산 생성 추세)
  Widget _buildBasicMetrics() {
    final analysis = widget.stepAnalysis;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // 1행: 이스트 활성도와 산 생성 추세
          Row(
            children: [
              Expanded(
                child: _buildSimpleMetric(
                  '이스트 활성도',
                  '${(analysis.yeastActivity * 100).toStringAsFixed(0)}%',
                  _getYeastActivityColor(analysis.yeastActivity),
                ),
              ),
              Expanded(
                child: _buildSimpleMetric(
                  '산 생성 추세',
                  'pH ${analysis.acidity.toStringAsFixed(1)}',
                  _getAcidityColor(analysis.acidity),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 2행: 부피 확장률과 진행률
          Row(
            children: [
              Expanded(
                child: _buildSimpleMetric(
                  '발효도',
                  VolumeExpansionCalculator.formatExpansion(
                      analysis.volumeIncrease,
                      showPercent: true),
                  VolumeExpansionCalculator.getExpansionColor(
                      VolumeExpansionCalculator.percentToExpansion(
                          analysis.volumeIncrease)),
                ),
              ),
              Expanded(
                child: _buildSimpleMetric(
                  '진행률',
                  '${(analysis.fermentationProgress * 100).toStringAsFixed(0)}%',
                  analysis.fermentationProgress >= 0.8
                      ? Colors.green.shade600
                      : analysis.fermentationProgress >= 0.6
                          ? Colors.blue.shade600
                          : analysis.fermentationProgress >= 0.4
                              ? Colors.orange.shade600
                              : Colors.red.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 상세 메트릭 정보 빌드 (미믹싱 패턴: 2x2 그리드)
  Widget _buildDetailedMetrics() {
    final analysis = widget.stepAnalysis;

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
                color: Colors.green,
              ),
              const SizedBox(width: 6),
              const Text(
                '상세 메트릭',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 믹싱 패턴과 동일하게 2x2 그리드 사용
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // 이스트 활성도 상세 정보 (기존 것 재사용)
              _buildDetailedMetric(
                '이스트 활성도',
                '${(analysis.yeastActivity).toStringAsFixed(1)}%',
                _getYeastActivityColor(analysis.yeastActivity),
                '적정 범위: 70-100%',
              ),

              // 산도 측정 상세 정보
              _buildDetailedMetric(
                '산도 (pH)',
                analysis.acidity.toStringAsFixed(2),
                _getAcidityColor(analysis.acidity),
                '적정 범위: 4.5-5.0',
              ),

              // 부피 확장률 상세 정보
              _buildDetailedMetric(
                '부피 확장률',
                VolumeExpansionCalculator.formatExpansion(
                    analysis.volumeIncrease,
                    showPercent: true),
                VolumeExpansionCalculator.getExpansionColor(
                    VolumeExpansionCalculator.percentToExpansion(
                        analysis.volumeIncrease)),
                '적정 범위: 120-180%',
              ),

              // 발효 진행률 상세 정보
              _buildDetailedMetric(
                '발효 진행률',
                '${(analysis.fermentationProgress).toStringAsFixed(1)}%',
                analysis.fermentationProgress >= 0.8
                    ? Colors.green.shade600
                    : analysis.fermentationProgress >= 0.6
                        ? Colors.blue.shade600
                        : analysis.fermentationProgress >= 0.4
                            ? Colors.orange.shade600
                            : Colors.red.shade600,
                '목표: 80% 이상',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 간단한 메트릭 위젯 생성 (기본 메트릭용)
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

  /// 상세 메트릭 위젯 생성 (그리드용) - 카드 중심 중앙 정렬
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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            range,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 권장사항 빌드
  Widget _buildRecommendations() {
    // 현재 fermentation_analysis_types.dart에는 권장사항 필드가 없는 것 같음
    // 임시로 간단한 권장사항 표시 (실제 데이터에 따라 조정 필요)
    final recommendations = _getRecommendations();

    if (recommendations.isEmpty) return const SizedBox.shrink();

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

  /// 권장사항이 있는지 확인
  bool _hasRecommendations() {
    return _getRecommendations().isNotEmpty;
  }

  /// 권장사항 목록 가져오기 (실제 구현 시 데이터에 맞게 조정)
  List<String> _getRecommendations() {
    final analysis = widget.stepAnalysis;
    final recommendations = <String>[];

    // 이스트 활성도 낮은 경우
    if (analysis.yeastActivity < 0.7) {
      recommendations.add('이스트 활성도가 낮음 - 온도 조절 또는 이스트 양 증가 고려');
    }

    // 산도가 낮은 경우 (과도한 산성)
    if (analysis.acidity < 4.0) {
      recommendations.add('산도가 낮음 - 발효 시간 연장 또는 온도 증가 고려');
    }

    // 산도가 높은 경우 (부족한 산성)
    if (analysis.acidity > 6.0) {
      recommendations.add('산도가 높음 - 발효 시간 단축 또는 온도 감소 고려');
    }

    // 부피 확장률 낮은 경우
    if (analysis.volumeIncrease < 120) {
      recommendations.add('부피 확장률 부족 - 발효 환경 개선 필요');
    }

    // 진행률 낮은 경우
    if (analysis.fermentationProgress < 0.8) {
      recommendations.add('발효 진행률 낮음 - 발효 시간 연장 또는 환경 최적화 필요');
    }

    return recommendations;
  }

  /// 이스트 활성도 기반 색상
  Color _getYeastActivityColor(double activity) {
    if (activity >= 0.8) return Colors.green.shade600;
    if (activity >= 0.6) return Colors.blue.shade600;
    if (activity >= 0.4) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  /// 산도 기반 색상 (최적 범위: pH 4.5-5.0)
  Color _getAcidityColor(double acidity) {
    if (acidity >= 4.5 && acidity <= 5.0) return Colors.green.shade600;
    if (acidity >= 4.0 && acidity <= 5.5) return Colors.blue.shade600;
    return Colors.red.shade600;
  }

  /// Duration 포맷팅 헬퍼 메소드
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
