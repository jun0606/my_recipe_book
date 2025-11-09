import '../models/enhanced_recipe.dart';
import '../models/environmental_conditions.dart';
import '../models/baking_calculation_result.dart';
import 'ingredient_analyzer.dart';

/// 환경 조건에 따른 레시피 조정을 담당하는 엔진
class EnvironmentalAdjustmentEngine {
  /// 최적 조건 계산 (수쉐프 모드용)
  Future<Map<String, dynamic>> calculateOptimalConditions(
    Map<String, dynamic> sousChefData,
    EnvironmentalConditions conditions,
  ) async {
    try {
      // 환경 조건 기반 최적화 계산
      final optimizedIngredients = <Map<String, dynamic>>[];
      final ingredients =
          sousChefData['ingredients'] as List<Map<String, dynamic>>;

      // 온도, 습도, 고도 조정 계수 계산
      final tempFactor = _calculateTemperatureFactor(conditions.temperature);
      final humidityFactor = _calculateHumidityFactor(conditions.humidity);
      final altitudeFactor = _calculateAltitudeFactor(conditions.altitude);

      // 재료별 최적화
      for (final ingredient in ingredients) {
        final name = ingredient['name'] as String? ?? '';
        final originalAmount = ingredient['amount'] as double? ?? 0.0;
        double optimizedAmount = originalAmount;

        // 재료별 환경 최적화
        if (IngredientAnalyzer.isFlour(name)) {
          optimizedAmount *= (1.0 + tempFactor * 0.02 + altitudeFactor * 0.03);
        } else if (_isLiquid(name)) {
          optimizedAmount *=
              (1.0 + humidityFactor * 0.01 + altitudeFactor * 0.02);
        } else if (_isLeavening(name)) {
          optimizedAmount *= (1.0 + altitudeFactor * 0.05 - tempFactor * 0.01);
        }

        optimizedIngredients.add({
          ...ingredient,
          'amount': optimizedAmount,
          'originalAmount': originalAmount,
          'adjustmentFactor': optimizedAmount / originalAmount,
        });
      }

      // 최적화 결과 반환
      return {
        'optimizedIngredients': optimizedIngredients,
        'adjustmentFactors': {
          'temperature': tempFactor,
          'humidity': humidityFactor,
          'altitude': altitudeFactor,
        },
        'recommendations': _generateRecommendations(conditions),
        'ovenType': conditions.ovenType,
        'optimizedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw EnvironmentalAdjustmentException('최적 조건 계산 중 오류가 발생했습니다: $e');
    }
  }

  /// 환경 조건에 따라 레시피 조정
  Future<EnvironmentalAdjustmentResult> adjustForEnvironment({
    required EnhancedRecipe recipe,
    required EnvironmentalConditions conditions,
  }) async {
    try {
      final adjustedIngredients = <Map<String, dynamic>>[];
      final calculations = <String, dynamic>{};
      final warnings = <ValidationWarning>[];
      final suggestions = <Suggestion>[];

      // 온도 조정 계수 계산
      final tempFactor = _calculateTemperatureFactor(conditions.temperature);
      final humidityFactor = _calculateHumidityFactor(conditions.humidity);
      final altitudeFactor = _calculateAltitudeFactor(conditions.altitude);

      // 재료별 조정
      for (final ingredient in recipe.ingredients) {
        final name = ingredient['name'] as String? ?? '';
        final originalAmount = ingredient['amount'] as double? ?? 0.0;
        double adjustedAmount = originalAmount;

        // 재료별 환경 조정
        if (_isFlour(name)) {
          adjustedAmount *= (1.0 + tempFactor * 0.02 + altitudeFactor * 0.03);
        } else if (_isLiquid(name)) {
          adjustedAmount *=
              (1.0 + humidityFactor * 0.01 + altitudeFactor * 0.02);
        } else if (_isLeavening(name)) {
          adjustedAmount *= (1.0 + altitudeFactor * 0.05 - tempFactor * 0.01);
        }

        adjustedIngredients.add({
          ...ingredient,
          'amount': adjustedAmount,
          'originalAmount': originalAmount,
          'adjustmentFactor': adjustedAmount / originalAmount,
        });
      }

      // 계산 정보 저장
      calculations['temperatureFactor'] = tempFactor;
      calculations['humidityFactor'] = humidityFactor;
      calculations['altitudeFactor'] = altitudeFactor;
      calculations['conditions'] = conditions.toJson();

      // 환경 조정 정보
      final adjustment = EnvironmentalAdjustment(
        adjustmentFactors: {
          'temperature': tempFactor,
          'humidity': humidityFactor,
          'altitude': altitudeFactor,
        },
        recommendations: _generateRecommendations(conditions),
        reason: _generateAdjustmentReason(conditions),
      );

      // 경고 및 제안 생성
      _generateWarningsAndSuggestions(conditions, warnings, suggestions);

      final adjustedRecipe = recipe.copyWith(
        ingredients: adjustedIngredients,
      );

      return EnvironmentalAdjustmentResult(
        adjustedRecipe: adjustedRecipe,
        adjustment: adjustment,
        calculations: calculations,
        warnings: warnings,
        suggestions: suggestions,
      );
    } catch (e) {
      throw EnvironmentalAdjustmentException('환경 조정 중 오류가 발생했습니다: $e');
    }
  }

  /// 온도 조정 계수 계산
  double _calculateTemperatureFactor(double temperature) {
    const standardTemp = 20.0;
    return (temperature - standardTemp) / 10.0;
  }

  /// 습도 조정 계수 계산
  double _calculateHumidityFactor(double humidity) {
    const standardHumidity = 60.0;
    return (humidity - standardHumidity) / 20.0;
  }

  /// 고도 조정 계수 계산
  double _calculateAltitudeFactor(double altitude) {
    return altitude / 1000.0; // 1000m당 1.0 계수
  }

  /// 밀가루 재료 판별
  bool _isFlour(String name) {
    return name.contains('밀가루') ||
        name.contains('flour') ||
        name.contains('가루');
  }

  /// 액체 재료 판별
  bool _isLiquid(String name) {
    return name.contains('물') ||
        name.contains('우유') ||
        name.contains('기름') ||
        name.contains('water') ||
        name.contains('milk') ||
        name.contains('oil');
  }

  /// 팽창제 재료 판별
  bool _isLeavening(String name) {
    return name.contains('이스트') ||
        name.contains('베이킹파우더') ||
        name.contains('소다') ||
        name.contains('yeast') ||
        name.contains('baking powder') ||
        name.contains('soda');
  }

  /// 권장사항 생성
  List<String> _generateRecommendations(EnvironmentalConditions conditions) {
    final recommendations = <String>[];

    if (conditions.temperature > 25) {
      recommendations.add('높은 온도로 인해 발효 시간을 단축하세요.');
      recommendations.add('반죽을 시원한 곳에서 작업하세요.');
    } else if (conditions.temperature < 15) {
      recommendations.add('낮은 온도로 인해 발효 시간을 연장하세요.');
      recommendations.add('따뜻한 곳에서 발효시키세요.');
    }

    if (conditions.humidity > 70) {
      recommendations.add('높은 습도로 인해 밀가루를 조금 더 추가하세요.');
    } else if (conditions.humidity < 40) {
      recommendations.add('낮은 습도로 인해 수분을 조금 더 추가하세요.');
    }

    if (conditions.altitude > 1000) {
      recommendations.add('고도가 높아 팽창제를 줄이고 액체를 늘리세요.');
      recommendations.add('오븐 온도를 15-25°C 높이세요.');
    }

    return recommendations;
  }

  /// 조정 이유 생성
  String _generateAdjustmentReason(EnvironmentalConditions conditions) {
    final reasons = <String>[];

    if (conditions.temperature != 20.0) {
      reasons.add('온도 ${conditions.temperature}°C');
    }
    if (conditions.humidity != 60.0) {
      reasons.add('습도 ${conditions.humidity}%');
    }
    if (conditions.altitude > 0) {
      reasons.add('고도 ${conditions.altitude}m');
    }

    if (reasons.isEmpty) {
      return '표준 환경 조건';
    }

    return '환경 조건 (${reasons.join(', ')})에 따른 자동 조정';
  }

  /// 경고 및 제안 생성
  void _generateWarningsAndSuggestions(
    EnvironmentalConditions conditions,
    List<ValidationWarning> warnings,
    List<Suggestion> suggestions,
  ) {
    // 극한 환경 경고
    if (conditions.temperature > 35 || conditions.temperature < 5) {
      warnings.add(ValidationWarning(
        level: ValidationLevel.warning,
        message: '극한 온도 조건입니다. 결과가 예상과 다를 수 있습니다.',
        category: 'environment',
      ));
    }

    if (conditions.humidity > 90 || conditions.humidity < 20) {
      warnings.add(ValidationWarning(
        level: ValidationLevel.warning,
        message: '극한 습도 조건입니다. 추가 조정이 필요할 수 있습니다.',
        category: 'environment',
      ));
    }

    // 계절별 제안
    if (conditions.season == 'summer') {
      suggestions.add(Suggestion(
        title: '여름철 베이킹 팁',
        description: '에어컨이 있는 시원한 곳에서 작업하고, 재료를 미리 차갑게 보관하세요.',
      ));
    } else if (conditions.season == 'winter') {
      suggestions.add(Suggestion(
        title: '겨울철 베이킹 팁',
        description: '실온에서 재료를 충분히 데우고, 발효 시간을 늘려주세요.',
      ));
    }
  }
}

/// 환경 조정 결과
class EnvironmentalAdjustmentResult {
  final EnhancedRecipe adjustedRecipe;
  final EnvironmentalAdjustment adjustment;
  final Map<String, dynamic> calculations;
  final List<ValidationWarning> warnings;
  final List<Suggestion> suggestions;

  const EnvironmentalAdjustmentResult({
    required this.adjustedRecipe,
    required this.adjustment,
    required this.calculations,
    required this.warnings,
    required this.suggestions,
  });
}

/// 환경 조정 예외
class EnvironmentalAdjustmentException implements Exception {
  final String message;
  const EnvironmentalAdjustmentException(this.message);

  @override
  String toString() => 'EnvironmentalAdjustmentException: $message';
}
