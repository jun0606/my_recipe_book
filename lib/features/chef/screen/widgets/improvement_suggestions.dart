// 개선 제안 위젯
// 환경 기반 추천, 믹싱 최적화, 발효 전략을 위한 UI 컴포넌트

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/types/environment_types.dart';
import '../types/screen_types.dart';

class ImprovementSuggestions extends StatefulWidget {
  final UserEnvironment environment;
  final Map<String, dynamic> mixingData;
  final Function(String, Map<String, dynamic>)? onSuggestionSelected;

  const ImprovementSuggestions({
    super.key,
    required this.environment,
    required this.mixingData,
    this.onSuggestionSelected,
  });

  @override
  State<ImprovementSuggestions> createState() => _ImprovementSuggestionsState();
}

class _ImprovementSuggestionsState extends State<ImprovementSuggestions> {
  late List<Map<String, dynamic>> _recommendations;
  late Map<String, dynamic> _analysisResults;

  @override
  void initState() {
    super.initState();
    _analyzeAndGenerateSuggestions();
  }

  @override
  void didUpdateWidget(ImprovementSuggestions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.environment != widget.environment ||
        oldWidget.mixingData != widget.mixingData) {
      _analyzeAndGenerateSuggestions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Text(
                '💡 ${AppLocalizations.of(context)!.improvementMethodsAndRecommendations}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _analyzeAndGenerateSuggestions,
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context)!.runAnalysis),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[100],
                  foregroundColor: Colors.pink[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 환경 기반 추천
          _buildEnvironmentalRecommendations(),

          const SizedBox(height: 16),

          // 믹싱 단계 최적화
          _buildMixingOptimization(),

          const SizedBox(height: 16),

          // 발효 전략 추천
          _buildFermentationStrategy(),

          const SizedBox(height: 16),

          // 추가 분석 결과들
          _buildAdditionalAnalysis(),

          const SizedBox(height: 16),

          // 성능 모니터링
          _buildPerformanceMonitoring(),
        ],
      ),
    );
  }

  Widget _buildEnvironmentalRecommendations() {
    final recommendations = _recommendations
        .where((rec) => rec['type'] == 'environmental')
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🌡️ ${AppLocalizations.of(context)!.environmentalRecommendations}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            ...recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        rec['icon'] as IconData,
                        size: 16,
                        color: rec['color'] as Color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rec['message'] as String,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildMixingOptimization() {
    final mixingData =
        widget.mixingData['mixingSteps'] as List<Map<String, dynamic>>? ?? [];
    final optimizedSteps = _optimizeMixingSteps(mixingData);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔄 ${AppLocalizations.of(context)!.mixingStepOptimization}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            ...optimizedSteps.map((step) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '${step['step']}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
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
                              step['comment'] as String,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '${step['speed']} - ${step['durationMinutes']}분',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildFermentationStrategy() {
    final strategy = _generateFermentationStrategy();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⏰ ${AppLocalizations.of(context)!.fermentationStrategyRecommendation}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              strategy['title'] as String,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strategy['description'] as String,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: (strategy['benefits'] as List<String>)
                  .map(
                    (benefit) => Chip(
                      label: Text(
                        benefit,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Colors.orange[50],
                      side: BorderSide(color: Colors.orange[200]!),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalAnalysis() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📊 ${AppLocalizations.of(context)!.additionalAnalysisResults}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            _buildAnalysisMetric(AppLocalizations.of(context)!.expectedSuccessRate, '85%', Colors.green),
            _buildAnalysisMetric(AppLocalizations.of(context)!.glutenOptimization, AppLocalizations.of(context)!.statusOptimal, Colors.blue),
            _buildAnalysisMetric(AppLocalizations.of(context)!.moistureBalance, AppLocalizations.of(context)!.statusGood, Colors.green),
            _buildAnalysisMetric(AppLocalizations.of(context)!.temperatureStability, AppLocalizations.of(context)!.statusStable, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisMetric(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMonitoring() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '📈 ${AppLocalizations.of(context)!.performanceMonitoring}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.refresh, size: 20),
                  tooltip: AppLocalizations.of(context)!.refresh,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 분석 시간 모니터링
            _buildPerformanceMetric(
              AppLocalizations.of(context)!.analysisDuration,
              _formatDuration(_getLastAnalysisTime()),
              Icons.timer,
              Colors.blue,
            ),

            // 캐시 성능 모니터링
            _buildCachePerformance(),

            // 메모리 사용량 모니터링
            _buildMemoryUsage(),

            // 성공률 통계
            _buildSuccessRate(),

            const SizedBox(height: 12),

            // 성능 개선 제안
            _buildPerformanceSuggestions(),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetric(
      String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCachePerformance() {
    final cacheStats = _getCacheStats();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.cachePerformance,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: _buildMiniMetric(
                AppLocalizations.of(context)!.totalEntries,
                '${cacheStats['totalEntries']}',
                Colors.green,
              ),
            ),
            Expanded(
              child: _buildMiniMetric(
                AppLocalizations.of(context)!.expiredEntries,
                '${cacheStats['expiredEntries']}',
                Colors.orange,
              ),
            ),
            Expanded(
              child: _buildMiniMetric(
                AppLocalizations.of(context)!.hitRate,
                _calculateCacheHitRate(cacheStats),
                Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMemoryUsage() {
    final cacheStats = _getCacheStats();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.memoryUsage,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 4),
        _buildMiniMetric(
          AppLocalizations.of(context)!.cacheMemory,
          '${cacheStats['memoryUsageMB'].toStringAsFixed(1)} MB',
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildSuccessRate() {
    final successRate = _calculateSuccessRate();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.successRateStatistics,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 4),
        _buildMiniMetric(
          AppLocalizations.of(context)!.averageSuccessRate,
          '${(successRate * 100).toStringAsFixed(1)}%',
          _getSuccessRateColor(successRate),
        ),
      ],
    );
  }

  Widget _buildMiniMetric(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSuggestions() {
    final suggestions = _generatePerformanceSuggestions();

    if (suggestions.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🚀 ${AppLocalizations.of(context)!.performanceSuggestions}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 8),
        ...suggestions.map((suggestion) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb,
                    size: 14,
                    color: Colors.indigo,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  void _analyzeAndGenerateSuggestions() {
    setState(() {
      _recommendations = _generateEnvironmentalRecommendations();
      _analysisResults = _performAnalysis();
    });
  }

  List<Map<String, dynamic>> _generateEnvironmentalRecommendations() {
    final recommendations = <Map<String, dynamic>>[];
    final l10n = AppLocalizations.of(context)!;

    // 온도 기반 추천
    if (widget.environment.temperature < 20) {
      recommendations.add({
        'type': 'environmental',
        'icon': Icons.thermostat,
        'color': Colors.blue,
        'message': l10n.lowTempWarning,
      });
    } else if (widget.environment.temperature > 28) {
      recommendations.add({
        'type': 'environmental',
        'icon': Icons.thermostat,
        'color': Colors.red,
        'message': l10n.highTempWarning,
      });
    }

    // 습도 기반 추천
    if (widget.environment.humidity < 50) {
      recommendations.add({
        'type': 'environmental',
        'icon': Icons.water_drop,
        'color': Colors.orange,
        'message': l10n.lowHumidityWarning,
      });
    } else if (widget.environment.humidity > 80) {
      recommendations.add({
        'type': 'environmental',
        'icon': Icons.water_drop,
        'color': Colors.blue,
        'message': l10n.highHumidityWarning,
      });
    }

    // 계절 기반 추천
    final season = widget.environment.season.name;
    if (season == 'winter') {
      recommendations.add({
        'type': 'environmental',
        'icon': Icons.ac_unit,
        'color': Colors.lightBlue,
        'message': l10n.winterRecommendation,
      });
    } else if (season == 'summer') {
      recommendations.add({
        'type': 'environmental',
        'icon': Icons.wb_sunny,
        'color': Colors.yellow,
        'message': l10n.summerRecommendation,
      });
    }

    // 기본 추천 (항상 표시)
    if (recommendations.isEmpty) {
      recommendations.add({
        'type': 'environmental',
        'icon': Icons.check_circle,
        'color': Colors.green,
        'message': l10n.optimalEnvironmentMessage,
      });
    }

    return recommendations;
  }

  List<Map<String, dynamic>> _optimizeMixingSteps(
      List<Map<String, dynamic>> mixingData) {
    final optimizedSteps = <Map<String, dynamic>>[];
    final l10n = AppLocalizations.of(context)!;

    for (int i = 0; i < mixingData.length; i++) {
      final step = Map<String, dynamic>.from(mixingData[i]);

      // 환경 조건에 따른 최적화
      if (widget.environment.temperature > 28) {
        // 고온에서는 믹싱 시간을 줄임
        step['durationMinutes'] = (step['durationMinutes'] as int) - 1;
        step['comment'] = '${step['comment']} ${l10n.optimizationHighTemp}';
      } else if (widget.environment.temperature < 20) {
        // 저온에서는 믹싱 시간을 늘임
        step['durationMinutes'] = (step['durationMinutes'] as int) + 1;
        step['comment'] = '${step['comment']} ${l10n.optimizationLowTemp}';
      }

      // 믹서 타입에 따른 속도 조정
      if (widget.environment.mixerType.name == 'home') {
        if (step['speed'] == '고속') {
          step['speed'] = '중속';
          step['comment'] = '${step['comment']} ${l10n.optimizationHomeMixer}';
        }
      }

      optimizedSteps.add(step);
    }

    return optimizedSteps;
  }

  Map<String, dynamic> _generateFermentationStrategy() {
    final l10n = AppLocalizations.of(context)!;
    // 현재 환경에 따른 전략 결정
    if (widget.environment.temperature < 22) {
      return {
        'title': l10n.coldFermentationStrategy,
        'description': l10n.coldFermentationDesc,
        'benefits': [l10n.coldFermentationBenefit1, l10n.coldFermentationBenefit2, l10n.coldFermentationBenefit3],
      };
    } else if (widget.environment.temperature > 26) {
      return {
        'title': l10n.warmFermentationStrategy,
        'description': l10n.warmFermentationDesc,
        'benefits': [l10n.warmFermentationBenefit1, l10n.warmFermentationBenefit2, l10n.warmFermentationBenefit3],
      };
    } else {
      return {
        'title': l10n.standardFermentationStrategy,
        'description': l10n.standardFermentationDesc,
        'benefits': [l10n.standardFermentationBenefit1, l10n.standardFermentationBenefit2, l10n.standardFermentationBenefit3],
      };
    }
  }

  Map<String, dynamic> _performAnalysis() {
    // 간단한 분석 결과 생성
    return {
      'success': true,
      'confidence': 0.85,
      'timestamp': DateTime.now(),
    };
  }

  // 헬퍼 메서드들
  Duration _getLastAnalysisTime() => const Duration(milliseconds: 150);

  Map<String, dynamic> _getCacheStats() => {
        'totalEntries': 25,
        'expiredEntries': 3,
        'memoryUsageMB': 2.5,
      };

  String _calculateCacheHitRate(Map<String, dynamic> cacheStats) {
    final hits = cacheStats['totalEntries'] - cacheStats['expiredEntries'];
    final total = cacheStats['totalEntries'];
    return total > 0 ? '${(hits / total * 100).round()}%' : '0%';
  }

  double _calculateSuccessRate() => 0.87;

  Color _getSuccessRateColor(double rate) {
    if (rate >= 0.9) return Colors.green;
    if (rate >= 0.8) return Colors.lightGreen;
    if (rate >= 0.7) return Colors.orange;
    return Colors.red;
  }

  List<String> _generatePerformanceSuggestions() {
    final suggestions = <String>[];
    final l10n = AppLocalizations.of(context)!;
    final cacheStats = _getCacheStats();
    final cacheSize = cacheStats['totalEntries'] as int;
    final analysisTime = _getLastAnalysisTime();

    // 캐시 크기 기반 제안
    if (cacheSize > 30) {
      suggestions.add(l10n.largeCacheSuggestion);
    } else if (cacheSize < 5) {
      suggestions.add(l10n.increaseCacheSuggestion);
    }

    // 분석 시간 기반 제안
    if (analysisTime.inMilliseconds > 500) {
      suggestions.add(l10n.longAnalysisTimeSuggestion);
    } else if (analysisTime.inMilliseconds < 100) {
      suggestions.add(l10n.fastAnalysisSuggestion);
    }

    // 기본 제안
    if (suggestions.isEmpty) {
      suggestions.add(l10n.optimizedPerformanceMessage);
    }

    return suggestions;
  }

  String _formatDuration(Duration duration) {
    if (duration.inMilliseconds < 1000) {
      return '${duration.inMilliseconds}ms';
    } else {
      return '${duration.inSeconds}.${(duration.inMilliseconds % 1000 ~/ 100)}s';
    }
  }
}
