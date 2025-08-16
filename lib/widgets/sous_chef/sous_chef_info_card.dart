// Sous Chef 정보 카드 - 적용된 설정 요약 표시

import 'package:flutter/material.dart';
import '../../models/sous_chef_models.dart';

class SousChefInfoCard extends StatelessWidget {
  final SousChefRecipeState state;
  final Function() onEdit;
  final Function() onDisable;

  const SousChefInfoCard({
    Key? key,
    required this.state,
    required this.onEdit,
    required this.onDisable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activePreset = state.activePresetId != null
        ? state.presets.where((p) => p.id == state.activePresetId).firstOrNull
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(activePreset),
          const SizedBox(height: 12),
          _buildAdjustmentsSummary(),
          const SizedBox(height: 12),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader(SousChefPreset? activePreset) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.purple.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.auto_fix_high,
            color: Colors.purple.shade700,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sous Chef 모드 활성',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
              Text(
                activePreset != null 
                    ? '프리셋: ${activePreset.name}'
                    : '사용자 정의 설정',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.purple.shade600,
                ),
              ),
            ],
          ),
        ),
        if (activePreset != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getPresetColor(activePreset.colorTag),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              activePreset.colorTag,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAdjustmentsSummary() {
    if (state.currentAdjustments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey.shade600, size: 16),
            const SizedBox(width: 8),
            const Text(
              '현재 적용된 조정값이 없습니다',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '적용된 조정값',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: state.currentAdjustments.entries
                .map((entry) => _buildAdjustmentChip(entry.key, entry.value))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustmentChip(String key, double value) {
    final labels = {
      'moisture': '수분',
      'temperature': '온도',
      'fermentationTime': '발효시간',
      'bakingTime': '굽기시간',
      'leavening': '팽창제',
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
    final isPositive = value > 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPositive ? Colors.red.shade100 : Colors.blue.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPositive ? Colors.red.shade300 : Colors.blue.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            size: 12,
            color: isPositive ? Colors.red.shade700 : Colors.blue.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            '$label ${isPositive ? '+' : ''}${value.toStringAsFixed(1)}$unit',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isPositive ? Colors.red.shade700 : Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('설정 수정'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.purple.shade700,
              side: BorderSide(color: Colors.purple.shade300),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: onDisable,
          icon: const Icon(Icons.close, size: 16),
          label: const Text('비활성화'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red.shade600,
            side: BorderSide(color: Colors.red.shade300),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ],
    );
  }

  Color _getPresetColor(String colorTag) {
    switch (colorTag.toLowerCase()) {
      case 'red':
        return Colors.red.shade600;
      case 'blue':
        return Colors.blue.shade600;
      case 'green':
        return Colors.green.shade600;
      case 'orange':
        return Colors.orange.shade600;
      case 'purple':
        return Colors.purple.shade600;
      case 'teal':
        return Colors.teal.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}