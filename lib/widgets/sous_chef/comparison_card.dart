// 비교 카드 - 기존값과 조정값 비교 표시

import 'package:flutter/material.dart';
import '../../models/sous_chef_models.dart';

class ComparisonCard extends StatelessWidget {
  final Map<String, double> originalValues;
  final AdjustmentResult adjustmentResult;
  final Function() onApply;
  final Function() onCancel;

  const ComparisonCard({
    Key? key,
    required this.originalValues,
    required this.adjustmentResult,
    required this.onApply,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildConfidenceScore(),
                    const SizedBox(height: 16),
                    _buildComparisonTable(),
                    const SizedBox(height: 16),
                    _buildExplanations(),
                    if (adjustmentResult.warnings.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildWarnings(),
                    ],
                  ],
                ),
              ),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(Icons.compare_arrows, color: Colors.blue.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '레시피 조정 결과',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                Text(
                  'Sous Chef가 제안하는 최적화된 값입니다',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceScore() {
    final score = adjustmentResult.confidenceScore;
    final scorePercent = (score * 100).toInt();
    
    Color scoreColor;
    String scoreText;
    
    if (score >= 0.8) {
      scoreColor = Colors.green;
      scoreText = '높음';
    } else if (score >= 0.6) {
      scoreColor = Colors.orange;
      scoreText = '보통';
    } else {
      scoreColor = Colors.red;
      scoreText = '낮음';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scoreColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scoreColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.psychology, color: scoreColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '신뢰도: $scoreText ($scorePercent%)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
                Text(
                  '이 조정값들의 예상 성공률입니다',
                  style: TextStyle(
                    fontSize: 11,
                    color: scoreColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          CircularProgressIndicator(
            value: score,
            backgroundColor: scoreColor.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
            strokeWidth: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable() {
    final adjustments = adjustmentResult.adjustments;
    if (adjustments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600),
            const SizedBox(width: 8),
            const Text('조정이 필요한 항목이 없습니다.'),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                const Expanded(flex: 2, child: Text('항목', style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(flex: 2, child: Text('기존값', style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(flex: 2, child: Text('조정값', style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(flex: 2, child: Text('변화량', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          ...adjustments.entries.map((entry) => _buildComparisonRow(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String key, double adjustment) {
    final originalValue = originalValues[key] ?? 0.0;
    final adjustedValue = originalValue + adjustment;
    final changePercent = originalValue != 0 ? (adjustment / originalValue * 100) : 0.0;
    
    final labels = {
      'moisture': '수분율 (%)',
      'temperature': '온도 (°C)',
      'fermentationTime': '발효시간 (분)',
      'bakingTime': '굽기시간 (분)',
      'leavening': '팽창제 (%)',
    };

    final units = {
      'moisture': '%',
      'temperature': '°C',
      'fermentationTime': '분',
      'bakingTime': '분',
      'leavening': '%',
    };

    final label = labels[key] ?? key;
    final unit = units[key] ?? '';
    
    Color changeColor = adjustment > 0 ? Colors.red.shade600 : Colors.blue.shade600;
    if (adjustment.abs() < 0.1) changeColor = Colors.grey.shade600;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${originalValue.toStringAsFixed(1)}$unit',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${adjustedValue.toStringAsFixed(1)}$unit',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: changeColor,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(
                  adjustment > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12,
                  color: changeColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${adjustment > 0 ? '+' : ''}${changePercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: changeColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanations() {
    if (adjustmentResult.explanations.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue.shade700, size: 16),
              const SizedBox(width: 6),
              Text(
                '조정 이유',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...adjustmentResult.explanations.map((explanation) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    explanation,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildWarnings() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.amber.shade700, size: 16),
              const SizedBox(width: 6),
              Text(
                '주의사항',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...adjustmentResult.warnings.map((warning) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.amber.shade700,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    warning,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber.shade700,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade400),
              ),
              child: const Text('취소'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('최종 적용'),
            ),
          ),
        ],
      ),
    );
  }
}