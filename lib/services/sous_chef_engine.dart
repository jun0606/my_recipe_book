// Sous Chef 지능형 보정 엔진

import '../models/sous_chef_models.dart';
import 'oven_characteristics_module.dart';
import 'fermentation_module.dart';

class SousChefEngine {
  final List<AdjustmentModule> _modules = [
    OvenCharacteristicsModule(),
    FermentationModule(),
  ];

  AdjustmentResult calculateAdjustments({
    required BakingType bakingType,
    required Map<String, dynamic> userInputs,
    required Map<String, dynamic> environmentData,
    required Map<String, dynamic> recipeData,
  }) {
    final applicableModules = _modules
        .where((module) => module.supportedTypes.contains(bakingType))
        .toList();

    final Map<String, double> totalAdjustments = {};
    final List<String> allWarnings = [];
    final List<String> allExplanations = [];

    // 각 모듈별 보정값 계산
    for (final module in applicableModules) {
      try {
        final moduleInputs = {
          ...userInputs,
          ...environmentData,
          ...recipeData,
        };

        final adjustments = module.calculate(moduleInputs);
        final explanations = module.getExplanations(moduleInputs);

        // 보정값 합산
        adjustments.forEach((key, value) {
          totalAdjustments[key] = (totalAdjustments[key] ?? 0.0) + value;
        });

        allExplanations.addAll(explanations);
      } catch (e) {
        allWarnings.add('${module.name} 모듈 계산 중 오류: $e');
      }
    }

    // 충돌 해결 및 검증
    final resolvedAdjustments = _resolveConflicts(totalAdjustments);
    final warnings = _validateAdjustments(resolvedAdjustments);
    allWarnings.addAll(warnings);

    return AdjustmentResult(
      adjustments: resolvedAdjustments,
      warnings: allWarnings,
      explanations: allExplanations,
      confidenceScore: _calculateConfidenceScore(resolvedAdjustments),
    );
  }

  Map<String, double> _resolveConflicts(Map<String, double> adjustments) {
    final resolved = Map<String, double>.from(adjustments);

    // 과도한 보정값 제한
    final limits = {
      'moisture': 15.0,
      'temperature': 50.0,
      'time': 200.0,
      'fermentationTime': 300.0,
    };

    resolved.forEach((key, value) {
      final limit = limits[key] ?? 20.0;
      if (value.abs() > limit) {
        resolved[key] = value.sign * limit;
      }
    });

    return resolved;
  }

  List<String> _validateAdjustments(Map<String, double> adjustments) {
    final warnings = <String>[];

    adjustments.forEach((key, value) {
      if (value.abs() > 10.0) {
        warnings.add('$key 보정값이 큽니다 (${value.toStringAsFixed(1)}%). 결과를 주의깊게 확인하세요.');
      }
    });

    return warnings;
  }

  double _calculateConfidenceScore(Map<String, double> adjustments) {
    // 보정값이 클수록 신뢰도 감소
    final totalAdjustment = adjustments.values
        .map((v) => v.abs())
        .fold(0.0, (a, b) => a + b);

    return (1.0 - (totalAdjustment / 100.0)).clamp(0.1, 1.0);
  }
}