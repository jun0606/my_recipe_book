import 'package:flutter/material.dart';

class RecipeCalculationProvider with ChangeNotifier {
  List<Map<String, dynamic>> _originalIngredients = [];
  List<Map<String, dynamic>> _calculatedIngredients = [];
  double _currentMultiplier = 1.0;

  // 베이킹 모드 관련 상태
  double? _calculatedSplitAmount;
  int? _calculatedSplitCount;
  double? _calculatedRemainingWeight;
  bool _keepOriginalSplitWeight = false;

  List<Map<String, dynamic>> get originalIngredients => _originalIngredients;
  List<Map<String, dynamic>> get calculatedIngredients =>
      _calculatedIngredients;
  double get currentMultiplier => _currentMultiplier;
  double? get calculatedSplitAmount => _calculatedSplitAmount;
  int? get calculatedSplitCount => _calculatedSplitCount;
  double? get calculatedRemainingWeight => _calculatedRemainingWeight;
  bool get keepOriginalSplitWeight => _keepOriginalSplitWeight;

  void setOriginalIngredients(List<Map<String, dynamic>> ingredients) {
    _originalIngredients = List<Map<String, dynamic>>.from(ingredients);
    _calculatedIngredients = List<Map<String, dynamic>>.from(ingredients);
    notifyListeners();
  }

  void calculateByServings(double baseServings, double desiredServings) {
    if (baseServings <= 0 || desiredServings <= 0) return;

    _currentMultiplier = desiredServings / baseServings;
    _calculatedIngredients =
        _calculateIngredientsWithMultiplier(_currentMultiplier);
    notifyListeners();
  }

  void calculateByMultiplier(double multiplier) {
    if (multiplier <= 0) return;

    _currentMultiplier = multiplier;
    _calculatedIngredients =
        _calculateIngredientsWithMultiplier(_currentMultiplier);
    notifyListeners();
  }

  void calculateBySplitAmount(double splitAmount, String splitAmountUnit) {
    // 간단한 분할 계산 - RecipeCalculator를 사용하지 않고 직접 계산
    final totalWeight = _calculateTotalWeight();
    final numSplits = (totalWeight / splitAmount).floor();
    final remainingWeight = totalWeight - (numSplits * splitAmount);

    _calculatedSplitCount = numSplits;
    _calculatedRemainingWeight = remainingWeight;
    _calculatedSplitAmount = splitAmount;
    notifyListeners();
  }

  void calculateBySplitCount(int splitCount) {
    // 간단한 분할 계산 - RecipeCalculator를 사용하지 않고 직접 계산
    final totalWeight = _calculateTotalWeight();
    final splitAmount = totalWeight / splitCount;
    final remainingWeight = 0.0; // 균등 분할이므로 나머지 없음

    _calculatedSplitAmount = splitAmount;
    _calculatedRemainingWeight = remainingWeight;
    _calculatedSplitCount = splitCount;
    notifyListeners();
  }

  void calculateByNewSplitCount(int newSplitCount, double originalSplitAmount,
      int originalSplitCount, bool keepOriginalSplitWeight) {
    // 간단한 계산 로직
    final totalWeight = _calculateTotalWeight();

    if (keepOriginalSplitWeight) {
      // 원래 무게 유지
      final newSplitAmount = totalWeight / newSplitCount;
      _currentMultiplier = newSplitAmount / originalSplitAmount;
      _calculatedSplitAmount = newSplitAmount;
      _calculatedSplitCount = newSplitCount;
      _calculatedRemainingWeight = 0.0;

      _calculatedIngredients =
          _calculateIngredientsWithMultiplier(_currentMultiplier);
    } else {
      // 개수에 따른 분할
      final newSplitAmount = totalWeight / newSplitCount;
      _calculatedSplitAmount = newSplitAmount;
      _calculatedSplitCount = newSplitCount;
      _calculatedRemainingWeight = 0.0;
    }

    notifyListeners();
  }

  /// 총 무게 계산 헬퍼 메소드
  double _calculateTotalWeight() {
    return _originalIngredients.fold(0.0, (total, ingredient) {
      final amount = (ingredient['amount'] as num?)?.toDouble() ?? 0.0;
      return total + amount;
    });
  }

  void setKeepOriginalSplitWeight(bool value) {
    _keepOriginalSplitWeight = value;
    notifyListeners();
  }

  void reset() {
    _currentMultiplier = 1.0;
    _calculatedIngredients =
        List<Map<String, dynamic>>.from(_originalIngredients);
    _calculatedSplitAmount = null;
    _calculatedSplitCount = null;
    _calculatedRemainingWeight = null;
    notifyListeners();
  }

  /// 재료에 승수 적용
  List<Map<String, dynamic>> _calculateIngredientsWithMultiplier(
      double multiplier) {
    return _originalIngredients.map((ingredient) {
      final amount = (ingredient['amount'] as num?)?.toDouble() ?? 0.0;
      return {
        ...ingredient,
        'amount': amount * multiplier,
        'originalAmount': amount,
        'multiplier': multiplier,
      };
    }).toList();
  }
}
