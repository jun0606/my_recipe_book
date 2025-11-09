// lib/widgets/analysis/bread_analysis_cards/mixing_analysis_card.dart
// 반죽 분석 카드 위젯

import 'package:flutter/material.dart';
import '../../../../../models/recipe.dart';

/// 반죽 분석 정보를 표시하는 카드 위젯
class MixingAnalysisCard extends StatelessWidget {
  final double? doughTemperature;
  final double? roomTemperature;
  final int? mixingTime;
  final String? doughStage;
  final double? glutenDevelopment;
  final Recipe? recipe;
  final Map<String, dynamic>? userData;
  final String? title;
  final bool? enableRPMMode;
  final bool? enableEffectsVisualization;
  final bool? enableRealTimeFeedback;

  const MixingAnalysisCard({
    super.key,
    this.doughTemperature,
    this.roomTemperature,
    this.mixingTime,
    this.doughStage,
    this.glutenDevelopment,
    this.recipe,
    this.userData,
    this.title,
    this.enableRPMMode,
    this.enableEffectsVisualization,
    this.enableRealTimeFeedback,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant_menu, color: Colors.brown),
                const SizedBox(width: 8),
                Text(
                  '반죽 분석',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 온도 분석
            if (doughTemperature != null && roomTemperature != null) ...[
              _buildAnalysisRow(
                '반죽 온도',
                '${doughTemperature!.toStringAsFixed(1)}°C',
                _getTemperatureColor(doughTemperature!),
              ),
              const SizedBox(height: 8),
              _buildAnalysisRow(
                '실내 온도',
                '${roomTemperature!.toStringAsFixed(1)}°C',
                Colors.blue,
              ),
              const SizedBox(height: 8),
              _buildAnalysisRow(
                '온도 차이',
                '${(doughTemperature! - roomTemperature!).toStringAsFixed(1)}°C',
                _getTemperatureDifferenceColor(
                    doughTemperature! - roomTemperature!),
              ),
              const SizedBox(height: 16),
            ],

            // 반죽 단계
            if (doughStage != null) ...[
              _buildAnalysisRow(
                '반죽 단계',
                doughStage!,
                _getStageColor(doughStage!),
              ),
              const SizedBox(height: 8),
            ],

            // 혼합 시간
            if (mixingTime != null) ...[
              _buildAnalysisRow(
                '혼합 시간',
                '${mixingTime!}분',
                mixingTime! >= 10 && mixingTime! <= 20
                    ? Colors.green
                    : Colors.orange,
              ),
              const SizedBox(height: 8),
            ],

            // 글루텐 발달
            if (glutenDevelopment != null) ...[
              _buildAnalysisRow(
                '글루텐 발달',
                '${glutenDevelopment!.toStringAsFixed(1)}%',
                glutenDevelopment! >= 80 ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 16),
            ],

            // 조언
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '💡 이상적인 반죽 온도: 24-26°C, 혼합 시간: 12-18분',
                style: TextStyle(fontSize: 12, color: Colors.amber),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Color _getTemperatureColor(double temperature) {
    if (temperature >= 24 && temperature <= 26) {
      return Colors.green;
    } else if (temperature >= 20 && temperature <= 30) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Color _getTemperatureDifferenceColor(double difference) {
    final absDiff = difference.abs();
    if (absDiff <= 2) {
      return Colors.green;
    } else if (absDiff <= 5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Color _getStageColor(String stage) {
    switch (stage.toLowerCase()) {
      case '완성':
      case 'completed':
        return Colors.green;
      case '중간':
      case 'developing':
        return Colors.orange;
      case '초기':
      case 'initial':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
