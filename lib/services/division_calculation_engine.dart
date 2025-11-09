import '../models/practical_recipe.dart';

/// 분할 계산 엔진
/// "5개 → 6개" 같은 직관적인 분할 계산을 처리하는 핵심 엔진
class DivisionCalculationEngine {
  /// 간단한 분할 계산 (호환성을 위한 래퍼)
  static Future<DivisionResult> calculateDivision({
    required PracticalRecipe originalRecipe,
    required int targetCount,
  }) async {
    return calculateByCount(
      originalRecipe: originalRecipe,
      targetCount: targetCount,
    );
  }

  /// 개수 기반 분할 계산
  /// 예: "5개 나오는 레시피를 6개로 만들고 싶어요"
  static DivisionResult calculateByCount({
    required PracticalRecipe originalRecipe,
    required int targetCount,
  }) {
    // 입력값 검증
    if (targetCount <= 0) {
      throw ArgumentError('목표 개수는 1개 이상이어야 합니다');
    }

    // 과도한 배수 경고 (10배 이상)
    final scaleFactor = targetCount / originalRecipe.originalYield;
    if (scaleFactor > 10) {
      throw ArgumentError('너무 많은 양입니다 (${scaleFactor.toStringAsFixed(1)}배). '
          '정말 ${targetCount}개를 만드시겠습니까?');
    }

    // 레시피 스케일링
    final scaledRecipe = originalRecipe.scaleByCount(targetCount);

    // 남은 재료 계산 (실제로는 정확히 나누어떨어지므로 남은 재료 없음)
    final remainder = <String, double>{};

    return DivisionResult(
      originalRecipe: originalRecipe,
      scaledRecipe: scaledRecipe,
      remainder: remainder,
      scaleFactor: scaleFactor,
      calculationType: 'count',
      calculatedAt: DateTime.now(),
    );
  }

  /// 무게 기반 분할 계산
  /// 예: "총 1000g 나오는 레시피를 1200g으로 만들고 싶어요"
  static DivisionResult calculateByWeight({
    required PracticalRecipe originalRecipe,
    required double targetWeight,
  }) {
    // 입력값 검증
    if (targetWeight <= 0) {
      throw ArgumentError('목표 무게는 0보다 커야 합니다');
    }

    // 과도한 배수 경고
    final scaleFactor = targetWeight / originalRecipe.originalTotalWeight;
    if (scaleFactor > 10) {
      throw ArgumentError('너무 많은 양입니다 (${scaleFactor.toStringAsFixed(1)}배). '
          '정말 ${targetWeight.toStringAsFixed(0)}g을 만드시겠습니까?');
    }

    // 레시피 스케일링
    final scaledRecipe = originalRecipe.scaleByWeight(targetWeight);

    // 남은 재료 계산 (무게 기반에서는 정확히 나누어떨어짐)
    final remainder = <String, double>{};

    return DivisionResult(
      originalRecipe: originalRecipe,
      scaledRecipe: scaledRecipe,
      remainder: remainder,
      scaleFactor: scaleFactor,
      calculationType: 'weight',
      calculatedAt: DateTime.now(),
    );
  }

  /// 실제 분할 개수 기반 남은 재료 계산
  /// 예: "6개로 계산했는데 실제로는 5개만 만들었어요"
  static DivisionResult calculateWithActualDivision({
    required PracticalRecipe originalRecipe,
    required int targetCount,
    required int actualCount,
  }) {
    // 입력값 검증
    if (targetCount <= 0 || actualCount <= 0) {
      throw ArgumentError('개수는 1개 이상이어야 합니다');
    }

    if (actualCount > targetCount) {
      throw ArgumentError('실제 개수가 목표 개수보다 클 수 없습니다');
    }

    // 목표 개수로 스케일링된 레시피
    final scaledRecipe = originalRecipe.scaleByCount(targetCount);

    // 실제 사용된 재료 계산
    final actualUsageRatio = actualCount / targetCount;
    final remainder = <String, double>{};

    for (final ingredient in scaledRecipe.ingredients) {
      final usedAmount = (ingredient['amount'] as double) * actualUsageRatio;
      final remainingAmount = (ingredient['amount'] as double) - usedAmount;

      if (remainingAmount > 0.1) {
        // 0.1g 이상만 표시
        remainder[ingredient['name'] as String] = remainingAmount;
      }
    }

    return DivisionResult(
      originalRecipe: originalRecipe,
      scaledRecipe: scaledRecipe,
      remainder: remainder,
      scaleFactor: targetCount / originalRecipe.originalYield,
      calculationType: 'count_with_remainder',
      calculatedAt: DateTime.now(),
    );
  }

  /// 최적 분할 제안
  /// 재료 낭비를 최소화하는 분할 방법 제안
  static List<OptimalDivisionSuggestion> suggestOptimalDivisions({
    required PracticalRecipe originalRecipe,
    required int minCount,
    required int maxCount,
  }) {
    final suggestions = <OptimalDivisionSuggestion>[];

    for (int count = minCount; count <= maxCount; count++) {
      final result = calculateByCount(
        originalRecipe: originalRecipe,
        targetCount: count,
      );

      // 효율성 점수 계산 (낭비가 적을수록 높은 점수)
      final wasteScore = _calculateWasteScore(result);
      final convenienceScore =
          _calculateConvenienceScore(count, originalRecipe.originalYield);
      final totalScore = (wasteScore + convenienceScore) / 2;

      suggestions.add(OptimalDivisionSuggestion(
        targetCount: count,
        result: result,
        wasteScore: wasteScore,
        convenienceScore: convenienceScore,
        totalScore: totalScore,
      ));
    }

    // 총점 기준으로 정렬
    suggestions.sort((a, b) => b.totalScore.compareTo(a.totalScore));

    return suggestions;
  }

  /// 재료 낭비 점수 계산 (0-100, 높을수록 좋음)
  static double _calculateWasteScore(DivisionResult result) {
    if (result.remainder.isEmpty) return 100.0;

    final totalOriginalWeight = result.scaledRecipe.totalIngredientWeight;
    final totalWasteWeight =
        result.remainder.values.fold(0.0, (sum, amount) => sum + amount);
    final wasteRatio = totalWasteWeight / totalOriginalWeight;

    return (1 - wasteRatio) * 100;
  }

  /// 편의성 점수 계산 (0-100, 높을수록 좋음)
  static double _calculateConvenienceScore(int targetCount, int originalCount) {
    final ratio = targetCount / originalCount;

    // 정수배는 높은 점수
    if (ratio == ratio.round()) {
      return 90.0 + (10.0 / ratio); // 작은 배수일수록 더 높은 점수
    }

    // 간단한 분수 (1.5배, 2.5배 등)는 중간 점수
    if ((ratio * 2) == (ratio * 2).round()) {
      return 70.0;
    }

    // 복잡한 비율은 낮은 점수
    return 50.0;
  }

  /// 계산 결과 검증
  static ValidationResult validateCalculation({
    required PracticalRecipe originalRecipe,
    required int targetCount,
  }) {
    final warnings = <String>[];
    final errors = <String>[];

    // 기본 검증
    if (targetCount <= 0) {
      errors.add('목표 개수는 1개 이상이어야 합니다');
      return ValidationResult(
          isValid: false, errors: errors, warnings: warnings);
    }

    final scaleFactor = targetCount / originalRecipe.originalYield;

    // 과도한 배수 경고
    if (scaleFactor > 5) {
      warnings
          .add('${scaleFactor.toStringAsFixed(1)}배는 꽤 많은 양입니다. 오븐 용량을 확인해주세요.');
    }

    if (scaleFactor > 10) {
      errors
          .add('${scaleFactor.toStringAsFixed(1)}배는 너무 많습니다. 10배 이하로 조정해주세요.');
    }

    // 너무 작은 양 경고
    if (scaleFactor < 0.5) {
      warnings.add(
          '${scaleFactor.toStringAsFixed(1)}배는 꽤 적은 양입니다. 재료 측정이 어려울 수 있어요.');
    }

    // 복잡한 비율 경고
    if (scaleFactor != scaleFactor.round() &&
        (scaleFactor * 2) != (scaleFactor * 2).round()) {
      warnings.add('복잡한 비율입니다. 재료 측정 시 주의해주세요.');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
}

/// 최적 분할 제안
class OptimalDivisionSuggestion {
  final int targetCount;
  final DivisionResult result;
  final double wasteScore;
  final double convenienceScore;
  final double totalScore;

  const OptimalDivisionSuggestion({
    required this.targetCount,
    required this.result,
    required this.wasteScore,
    required this.convenienceScore,
    required this.totalScore,
  });

  String get recommendation {
    if (totalScore >= 90) return '최고 추천';
    if (totalScore >= 80) return '추천';
    if (totalScore >= 70) return '괜찮음';
    if (totalScore >= 60) return '보통';
    return '비추천';
  }

  // 누락된 getter들 추가
  double get multiplier => result.scalingMultiplier;

  String get efficiencyGrade {
    if (totalScore >= 90) return 'A';
    if (totalScore >= 80) return 'B';
    if (totalScore >= 70) return 'C';
    if (totalScore >= 60) return 'D';
    return 'F';
  }

  String get reasonText {
    final reasons = <String>[];

    if (wasteScore >= 95) {
      reasons.add('재료 낭비 없음');
    } else if (wasteScore >= 80) {
      reasons.add('재료 낭비 적음');
    } else {
      reasons.add('재료 낭비 있음');
    }

    if (convenienceScore >= 85) {
      reasons.add('계산 간편');
    } else if (convenienceScore >= 70) {
      reasons.add('계산 보통');
    } else {
      reasons.add('계산 복잡');
    }

    return reasons.join(', ');
  }
}

/// 검증 결과
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;
}

/// 최적 분할 제안 생성을 위한 확장
extension DivisionCalculationEngineExtension on DivisionCalculationEngine {
  /// 최적 분할 제안
  static List<OptimalDivisionSuggestion> suggestOptimalDivisions({
    required PracticalRecipe originalRecipe,
    int minCount = 1,
    int maxCount = 20,
  }) {
    final suggestions = <OptimalDivisionSuggestion>[];

    for (int count = minCount; count <= maxCount; count++) {
      try {
        final result = DivisionCalculationEngine.calculateByCount(
          originalRecipe: originalRecipe,
          targetCount: count,
        );

        final wasteScore = _calculateWasteScore(result.scalingMultiplier);
        final convenienceScore = _calculateConvenienceScore(count);
        final totalScore = (100 - wasteScore) * 0.6 + convenienceScore * 0.4;

        suggestions.add(OptimalDivisionSuggestion(
          targetCount: count,
          result: result,
          wasteScore: wasteScore,
          convenienceScore: convenienceScore,
          totalScore: totalScore,
        ));
      } catch (e) {
        // 오류가 발생한 경우 건너뛰기
        continue;
      }
    }

    // 총점 순으로 정렬
    suggestions.sort((a, b) => b.totalScore.compareTo(a.totalScore));

    return suggestions.take(5).toList(); // 상위 5개만 반환
  }

  static double _calculateWasteScore(double scaleFactor) {
    // 1.0에 가까울수록 낭비가 적음
    return (scaleFactor - 1.0).abs() * 20;
  }

  static double _calculateConvenienceScore(int count) {
    // 5, 10, 15 등 5의 배수는 편리함
    if (count % 5 == 0) return 90;
    if (count % 2 == 0) return 80; // 짝수
    return 70; // 홀수
  }
}
