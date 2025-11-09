// 믹싱 분석 헤더 컴포넌트
// MixingAnalysisCard의 헤더 부분을 담당하는 컴포넌트

import 'package:flutter/material.dart';
import 'mixing_analysis_types.dart';

/// 믹싱 분석 헤더 위젯
class MixingAnalysisHeader extends StatelessWidget {
  final bool isAnalyzing;
  final VoidCallback onAnalyzePressed;
  final MixingAnalysisResult? analysisResult;

  const MixingAnalysisHeader({
    super.key,
    required this.isAnalyzing,
    required this.onAnalyzePressed,
    this.analysisResult,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 제목과 분석 버튼
            Row(
              children: [
                const Text(
                  '빵 믹싱 분석',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: isAnalyzing ? null : onAnalyzePressed,
                  icon: isAnalyzing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  tooltip: '분석 실행',
                ),
              ],
            ),

            // 분석 결과 요약 (있는 경우)
            if (analysisResult != null) ...[
              const SizedBox(height: 16),
              _buildAnalysisSummary(),
            ],
          ],
        ),
      ),
    );
  }

  /// 분석 결과 요약 빌드
  Widget _buildAnalysisSummary() {
    final result = analysisResult!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF81C784)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '믹싱 프로세스 종합 평가',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const Spacer(),
              if (result.overallScore > 0) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: result.performanceColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(result.overallScore * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // 기본 메트릭들
          Row(
            children: [
              Expanded(
                child: _buildSummaryMetric(
                  '총 시간',
                  '${result.totalTime}분',
                  Icons.timer,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryMetric(
                  '단계 수',
                  '${result.stepCount}개',
                  Icons.format_list_numbered,
                  Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _buildSummaryMetric(
                  '평균 글루텐',
                  '${(result.averageGlutenFormation * 100).toStringAsFixed(0)}%',
                  Icons.grain,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryMetric(
                  '효율성',
                  '${(result.efficiency * 100).toStringAsFixed(0)}%',
                  Icons.trending_up,
                  Colors.purple,
                ),
              ),
            ],
          ),

          // 성능 등급 표시
          if (result.performanceGrade.isNotEmpty) ...[
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: result.performanceColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: result.performanceColor.withOpacity(0.3)),
                ),
                child: Text(
                  '성능 등급: ${result.performanceGrade}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: result.performanceColor,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 요약 메트릭 빌드
  Widget _buildSummaryMetric(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 믹싱 분석 진행 상태 표시 위젯
class MixingAnalysisProgress extends StatelessWidget {
  final AnalysisProgress progress;

  const MixingAnalysisProgress({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    if (progress.status == AnalysisStatus.idle) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    progress.message,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (progress.status == AnalysisStatus.analyzing) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(_getStatusColor()),
                    ),
                  ),
                ],
              ],
            ),

            if (progress.status == AnalysisStatus.analyzing) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress.progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
              ),
              const SizedBox(height: 4),
              Text(
                '${(progress.progress * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: _getStatusColor(),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // 소요 시간 표시
            if (progress.duration != null) ...[
              const SizedBox(height: 8),
              Text(
                '소요 시간: ${progress.duration!.inSeconds}초',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 상태별 아이콘
  IconData _getStatusIcon() {
    switch (progress.status) {
      case AnalysisStatus.analyzing:
        return Icons.hourglass_top;
      case AnalysisStatus.completed:
        return Icons.check_circle;
      case AnalysisStatus.error:
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  /// 상태별 색상
  Color _getStatusColor() {
    switch (progress.status) {
      case AnalysisStatus.analyzing:
        return Colors.blue;
      case AnalysisStatus.completed:
        return Colors.green;
      case AnalysisStatus.error:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// 믹싱 분석 통계 카드
class MixingAnalysisStats extends StatelessWidget {
  final MixingAnalysisResult result;

  const MixingAnalysisStats({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '분석 통계',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),

            // 통계 그리드
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildStatCard(
                  '총 믹싱 시간',
                  '${result.totalTime}분',
                  Icons.timer,
                  Colors.blue,
                ),
                _buildStatCard(
                  '단계 수',
                  '${result.stepCount}개',
                  Icons.format_list_numbered,
                  Colors.green,
                ),
                _buildStatCard(
                  '평균 글루텐 형성',
                  '${(result.averageGlutenFormation * 100).toStringAsFixed(1)}%',
                  Icons.grain,
                  Colors.orange,
                ),
                _buildStatCard(
                  '프로세스 효율성',
                  '${(result.efficiency * 100).toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.purple,
                ),
                _buildStatCard(
                  '종합 점수',
                  '${(result.overallScore * 100).toStringAsFixed(1)}%',
                  Icons.assessment,
                  result.performanceColor,
                ),
                _buildStatCard(
                  '성능 등급',
                  result.performanceGrade,
                  Icons.grade,
                  result.performanceColor,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 추가 정보
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '추가 정보',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '분석 버전: ${result.analysisVersion}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '데이터 활용률: ${result.dataUtilizationRate}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '분석 시간: ${result.analysisTimestamp}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
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

  /// 통계 카드 빌드
  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
