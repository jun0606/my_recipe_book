import 'package:flutter/material.dart';
import '../utils/recipe_calculator.dart';

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
  List<Map<String, dynamic>> get calculatedIngredients => _calculatedIngredients;
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
    _calculatedIngredients = RecipeCalculator.calculateIngredients(
      _originalIngredients, 
      _currentMultiplier
    );
    notifyListeners();
  }
  
  void calculateByMultiplier(double multiplier) {
    if (multiplier <= 0) return;
    
    _currentMultiplier = multiplier;
    _calculatedIngredients = RecipeCalculator.calculateIngredients(
      _originalIngredients, 
      _currentMultiplier
    );
    notifyListeners();
  }
  
  void calculateBySplitAmount(double splitAmount, String splitAmountUnit) {
    final totalWeight = RecipeCalculator.calculateTotalIngredientWeight(_originalIngredients);
    final result = RecipeCalculator.calculateSplitByAmount(
      totalWeight, 
      splitAmount, 
      splitAmountUnit
    );
    
    if (result['success'] == true) {
      _calculatedSplitCount = result['splitCount'];
      _calculatedRemainingWeight = result['remainingWeight'];
      notifyListeners();
    }
  }
  
  void calculateBySplitCount(int splitCount) {
    final totalWeight = RecipeCalculator.calculateTotalIngredientWeight(_originalIngredients);
    final result = RecipeCalculator.calculateSplitByCount(
      totalWeight, 
      splitCount
    );
    
    if (result['success'] == true) {
      _calculatedSplitAmount = result['splitAmount'];
      _calculatedRemainingWeight = result['remainingWeight'];
      notifyListeners();
    }
  }
  
  void calculateByNewSplitCount(
    int newSplitCount, 
    double originalSplitAmount, 
    int originalSplitCount, 
    bool keepOriginalSplitWeight
  ) {
    final totalWeight = RecipeCalculator.calculateTotalIngredientWeight(_originalIngredients);
    final result = RecipeCalculator.calculateNewSplitCount(
      totalWeight,
      originalSplitAmount,
      originalSplitCount,
      newSplitCount,
      keepOriginalSplitWeight
    );
    
    if (result['success'] == true) {
      _currentMultiplier = result['ratio'];
      _calculatedSplitAmount = result['splitAmount'];
      _calculatedSplitCount = result['splitCount'];
      _calculatedRemainingWeight = result['remainingWeight'];
      _calculatedIngredients = RecipeCalculator.calculateIngredients(
        _originalIngredients, 
        _currentMultiplier
      );
      notifyListeners();
    }
  }
  
  void setKeepOriginalSplitWeight(bool value) {
    _keepOriginalSplitWeight = value;
    notifyListeners();
  }
  
  void reset() {
    _currentMultiplier = 1.0;
    _calculatedIngredients = List<Map<String, dynamic>>.from(_originalIngredients);
    _calculatedSplitAmount = null;
    _calculatedSplitCount = null;
    _calculatedRemainingWeight = null;
    notifyListeners();
  }
}