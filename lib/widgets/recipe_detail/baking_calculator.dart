import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import '../../models/enhanced_recipe.dart'; // Temporarily disabled
import '../../models/recipe.dart';
import '../../models/ingredient.dart';
// import '../../widgets/modular_calculator/calculator_module.dart'; // 사용하지 않음
import '../../utils/unit_converter.dart';
import '../../models/sous_chef_models.dart';
import '../../services/sous_chef_engine.dart';
import '../sous_chef/sous_chef_options_sheet.dart';
import '../sous_chef/comparison_card.dart';
import '../sous_chef/sous_chef_info_card.dart';
// 발효 기능이 Sous Chef로 통합되어 더 이상 필요하지 않음

/// 베이킹 레시피 전용 간소화된 계산기
class BakingCalculator extends StatefulWidget {
  final Recipe recipe;
  final Function(List<Ingredient>) onIngredientsCalculated;
  final Function(double) onMultiplierChanged;
  final Function(String)? onModeChanged;
  final Function(Map<String, dynamic>)? onSplitResultChanged;

  const BakingCalculator({
    Key? key,
    required this.recipe,
    required this.onIngredientsCalculated,
    required this.onMultiplierChanged,
    this.onModeChanged,
    this.onSplitResultChanged,
  }) : super(key: key);

  @override
  State<BakingCalculator> createState() => _BakingCalculatorState();
}

class _BakingCalculatorState extends State<BakingCalculator> {
  double _scaleFactor = 1.0;
  String _calculationMode = 'split_weight'; // 'split_weight', 'split_count', 'percentage'
  final TextEditingController _targetWeightController = TextEditingController();
  final TextEditingController _splitCountController = TextEditingController();
  final TextEditingController _optimizedQuantityController = TextEditingController();
  final TextEditingController _flourAmountController = TextEditingController();
  
  double _currentTotalWeight = 0.0;
  bool _showAdvancedSettings = false;
  
  // 분할 무게 계산 관련
  bool _isFixedOriginalMode = true; // 원본 레시피 무게 고정 모드
  int _possibleSplits = 0;
  double _remainingWeight = 0.0;
  bool _showOptimizationDialog = false;
  double _suggestedOptimalQuantity = 1.0;
  
  // 베이커스 퍼센트 관련
  double _originalBaseAmount = 0.0;
  int _selectedBaseIngredientIndex = 0; // 인덱스 기반으로 변경
  Map<String, double> _bakersPercentages = {};
  
  // 사용자 입력 추적
  bool _userModifiedTargetWeight = false;
  bool _programmaticallyUpdating = false;
  String? _lastUserInputValue; // 사용자가 마지막으로 입력한 값 저장
  
  // 분할 수량 모드 설정
  bool _isEqualSplit = true; // 균등 분할 모드
  
  // 고급 무게 설정
  bool _considerLoss = false; // 손실률 고려
  bool _considerMoistureEvaporation = false; // 수분 증발 계산
  double _lossPercentage = 5.0; // 기본 손실률 5%
  double _moistureEvaporationRate = 10.0; // 기본 수분 증발률 10%
  double _bakingTemperature = 180.0; // 굽기 온도 (°C)
  double _bakingTime = 30.0; // 굽기 시간 (분)
  
  // 추가 컨트롤러들
  final TextEditingController _lossPercentageController = TextEditingController();
  final TextEditingController _moistureRateController = TextEditingController();
  final TextEditingController _bakingTempController = TextEditingController();
  final TextEditingController _bakingTimeController = TextEditingController();
  
  // Sous Chef 모드 관련
  SousChefRecipeState? _sousChefState;
  final SousChefEngine _sousChefEngine = SousChefEngine();
  bool _isSousChefActive = false;

  @override
  void initState() {
    super.initState();
    print('initState 호출 - 플래그 초기값: $_userModifiedTargetWeight');
    
    // TextEditingController에 리스너 추가
    _targetWeightController.addListener(() {
      if (!_programmaticallyUpdating) {
        print('사용자가 값 변경 감지: ${_targetWeightController.text}');
        _userModifiedTargetWeight = true;
        _lastUserInputValue = _targetWeightController.text; // 사용자 입력값 저장
        print('_userModifiedTargetWeight 설정: $_userModifiedTargetWeight, 저장된 값: $_lastUserInputValue');
      }
    });
    
    // 고급 설정 컨트롤러 초기화
    _lossPercentageController.text = _lossPercentage.toString();
    _moistureRateController.text = _moistureEvaporationRate.toString();
    _bakingTempController.text = _bakingTemperature.toString();
    _bakingTimeController.text = _bakingTime.toString();
    
    _initializeCalculator();
  }
  
  void _initializeCalculator() {
    _calculateCurrentWeight();
    _initializeBakersPercentage();
    _initializeDefaultValues();
    
    // 초기화 후 상태 업데이트 (setState 제거 - 이미 _initializeDefaultValues에서 필요한 업데이트 완료)
    // if (mounted) {
    //   setState(() {});
    // }
  }

  void _initializeDefaultValues() {
    // 기본 개수 계산 (공통으로 사용)
    final defaultSplitCount = widget.recipe.baseServings > 0 ? widget.recipe.baseServings : 1;
    
    // 디버깅: 원본 레시피 정보 출력
    print('=== 베이킹 계산기 초기화 호출됨 ===');
    print('- targetSplitAmount: ${widget.recipe.targetSplitAmount}');
    print('- baseServings: ${widget.recipe.baseServings}');
    print('- defaultSplitCount: $defaultSplitCount');
    print('- _currentTotalWeight: $_currentTotalWeight');
    print('- _userModifiedTargetWeight: $_userModifiedTargetWeight');
    print('- 현재 입력칸 값: ${_targetWeightController.text}');
    
    // 분할 무게 모드: 사용자가 수정하지 않은 경우에만 기본값 설정
    if (!_userModifiedTargetWeight || _lastUserInputValue == null) {
      double weightPerPiece;
      if (widget.recipe.targetSplitAmount != null && widget.recipe.targetSplitAmount! > 0) {
        // 원본 레시피에 분할 무게가 설정되어 있으면 그 값을 사용
        weightPerPiece = widget.recipe.targetSplitAmount!;
        print('- 원본 레시피 분할 무게 사용: $weightPerPiece');
      } else {
        // 원본 레시피에 분할 무게가 없으면 총 무게 ÷ 기본 개수로 계산
        final totalWeight = _currentTotalWeight > 0 ? _currentTotalWeight : _calculateFallbackWeight();
        weightPerPiece = totalWeight / defaultSplitCount;
        print('- 계산된 개당 무게 사용: $weightPerPiece (총무게: $totalWeight ÷ 개수: $defaultSplitCount)');
      }
      _programmaticallyUpdating = true;
      _targetWeightController.text = weightPerPiece.toStringAsFixed(0);
      _programmaticallyUpdating = false;
      print('- 최종 입력칸 값: ${_targetWeightController.text}');
    } else {
      print('- 사용자가 수정한 값 유지: ${_targetWeightController.text}');
      // 사용자가 입력한 값으로 복원
      if (_lastUserInputValue != null && _targetWeightController.text != _lastUserInputValue) {
        print('- 사용자 입력값으로 복원: $_lastUserInputValue');
        _programmaticallyUpdating = true;
        _targetWeightController.text = _lastUserInputValue!;
        _programmaticallyUpdating = false;
      }
    }
    
    // 분할 수량 모드: 레시피 기본 인분을 기본값으로 설정
    _splitCountController.text = defaultSplitCount.toString();
    
    // 최적화 수량: 1개를 기본값으로 설정
    _optimizedQuantityController.text = '1';
    
    // 베이커스 퍼센트 모드: 원본 밀가루 양을 기본값으로 설정 (이미 _initializeBakersPercentage에서 처리됨)
  }
  
  double _calculateFallbackWeight() {
    // 단위 변환 없이 단순 합계로 폴백
    double total = 0.0;
    for (final ingredient in widget.recipe.ingredients) {
      final amount = ingredient.amount;
      total += amount;
    }
    return total;
  }

  @override
  void didUpdateWidget(BakingCalculator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 레시피 ID로 실제 변경 여부 확인
    final oldRecipeId = oldWidget.recipe.id;
    final newRecipeId = widget.recipe.id;
    
    print('didUpdateWidget 호출 - 이전 레시피 ID: $oldRecipeId, 현재 레시피 ID: $newRecipeId');
    
    if (oldRecipeId != newRecipeId) {
      print('레시피 변경됨 (ID 기준) - 플래그 리셋');
      _userModifiedTargetWeight = false; // 새 레시피일 때만 플래그 리셋
      _lastUserInputValue = null; // 저장된 사용자 입력값도 리셋
      _initializeCalculator();
    } else {
      print('동일한 레시피 (ID 기준) - 플래그 유지: $_userModifiedTargetWeight');
      // 동일한 레시피지만 재료가 변경되었을 수 있으므로 무게만 다시 계산
      final oldWeight = _currentTotalWeight;
      _calculateCurrentWeight();
      
      // 총 무게가 변경되었지만 사용자가 값을 수정한 경우, 사용자 값 유지
      if (oldWeight != _currentTotalWeight && _userModifiedTargetWeight) {
        print('총 무게 변경되었지만 사용자 입력값 유지');
      }
    }
  }

  @override
  void dispose() {
    _targetWeightController.dispose();
    _splitCountController.dispose();
    _optimizedQuantityController.dispose();
    _flourAmountController.dispose();
    _lossPercentageController.dispose();
    _moistureRateController.dispose();
    _bakingTempController.dispose();
    _bakingTimeController.dispose();
    super.dispose();
  }

  void _calculateCurrentWeight() {
    double total = 0.0;
    print('베이킹 계산기: 총 무게 계산 시작');
    
    for (final ingredient in widget.recipe.ingredients) {
      final amount = ingredient.amount;
      final unit = ingredient.unit;
      final name = ingredient.name;
      
      // 모든 재료를 표준 무게(그램)로 변환하여 합산
      final standardWeight = UnitConverter.getStandardWeight(amount, unit);
      total += standardWeight;
      
      print('재료: $name, 원본: ${amount}${unit}, 표준무게: ${standardWeight}g');
    }
    
    _currentTotalWeight = total;
    print('베이킹 계산기: 총 무게 = ${_currentTotalWeight}g');
  }

  void _initializeBakersPercentage() {
    if (widget.recipe.ingredients.isEmpty) {
      _selectedBaseIngredientIndex = 0;
      _originalBaseAmount = 100.0;
      _flourAmountController.text = '100';
      return;
    }

    // 기본 기준 재료 찾기 (밀가루 우선, 없으면 첫 번째 재료)
    int baseIndex = 0;
    for (int i = 0; i < widget.recipe.ingredients.length; i++) {
      final ingredient = widget.recipe.ingredients[i];
      final name = ingredient.name.toLowerCase();
      // Note: category is not available in Ingredient model, using empty string
      final category = '';
      
      if (name.contains('밀가루') || name.contains('flour') || category.contains('flour')) {
        baseIndex = i;
        break;
      }
    }
    
    _selectedBaseIngredientIndex = baseIndex;
    final baseIngredient = widget.recipe.ingredients[baseIndex];
    _originalBaseAmount = baseIngredient.amount;
    _flourAmountController.text = _originalBaseAmount.toStringAsFixed(0);
    
    print('베이커스 퍼센트 초기화: 인덱스 $_selectedBaseIngredientIndex, 무게 $_originalBaseAmount');
    
    _calculateBakersPercentages();
  }

  void _calculateBakersPercentages() {
    // 베이커스 퍼센트 계산
    _bakersPercentages.clear();
    for (final ingredient in widget.recipe.ingredients) {
      final name = ingredient.name;
      final amount = ingredient.amount;
      final percentage = _originalBaseAmount > 0 ? (amount / _originalBaseAmount * 100) : 0.0;
      _bakersPercentages[name] = percentage;
    }
  }

  void _onBaseIngredientIndexChanged(int? newIndex) {
    if (newIndex == null || 
        newIndex == _selectedBaseIngredientIndex || 
        newIndex >= widget.recipe.ingredients.length) return;
    
    final baseIngredient = widget.recipe.ingredients[newIndex];
    
    setState(() {
      _selectedBaseIngredientIndex = newIndex;
      _originalBaseAmount = baseIngredient.amount;
      _flourAmountController.text = _originalBaseAmount.toStringAsFixed(0);
    });
    
    _calculateBakersPercentages();
    _performCalculation();
  }

  void _performCalculation() {
    double newScaleFactor = 1.0;
    
    switch (_calculationMode) {
      case 'split_weight':
        _performSplitWeightCalculation();
        return; // 별도 처리하므로 여기서 리턴
      case 'split_count':
        _performSplitCountCalculation();
        return; // 별도 처리하므로 여기서 리턴
      case 'percentage':
        _performBakersPercentageCalculation();
        return; // 별도 처리하므로 여기서 리턴
    }

    if (newScaleFactor != _scaleFactor) {
      setState(() {
        _scaleFactor = newScaleFactor;
      });

      // 재료 계산 및 콜백 호출 (단위 유지)
      final updatedIngredients = widget.recipe.ingredients.map((ingredient) {
        final originalAmount = ingredient.amount;
        final unit = ingredient.unit;
        
        return Ingredient(
          name: ingredient.name,
          amount: originalAmount * _scaleFactor,
          unit: unit, // 원래 단위 유지
        );
      }).toList();

      widget.onIngredientsCalculated(updatedIngredients);
      widget.onMultiplierChanged(_scaleFactor);
    }
  }

  void _performSplitWeightCalculation() {
    final targetWeight = double.tryParse(_targetWeightController.text) ?? 0.0;
    if (targetWeight <= 0 || _currentTotalWeight <= 0) return;

    // 손실률과 수분 증발을 고려한 조정된 무게 계산
    final adjustedTotalWeight = _calculateAdjustedWeight(_currentTotalWeight);

    if (_isFixedOriginalMode) {
      // 기능 1: 원본 레시피 무게 고정 모드
      _calculateFixedOriginalMode(targetWeight, adjustedTotalWeight);
    } else {
      // 기능 2: 원본 레시피 무게 비고정 모드
      _calculateScalableMode(targetWeight, adjustedTotalWeight);
    }
  }

  /// 손실률과 수분 증발을 고려한 조정된 무게 계산
  double _calculateAdjustedWeight(double originalWeight) {
    double adjustedWeight = originalWeight;
    
    // 1. 손실률 고려 (일반적인 제조 과정에서의 손실)
    if (_considerLoss) {
      final lossRate = double.tryParse(_lossPercentageController.text) ?? _lossPercentage;
      adjustedWeight = adjustedWeight * (1 + lossRate / 100);
    }
    
    // 2. 수분 증발 계산 (베이킹 과정에서의 수분 손실)
    if (_considerMoistureEvaporation) {
      final moistureRate = _calculateMoistureEvaporationRate();
      adjustedWeight = adjustedWeight * (1 + moistureRate / 100);
    }
    
    return adjustedWeight;
  }

  /// 온도와 시간을 고려한 수분 증발률 계산 (전문가 수준)
  double _calculateMoistureEvaporationRate() {
    final baseRate = double.tryParse(_moistureRateController.text) ?? _moistureEvaporationRate;
    final temperature = double.tryParse(_bakingTempController.text) ?? _bakingTemperature;
    final time = double.tryParse(_bakingTimeController.text) ?? _bakingTime;
    
    // 전문가 공식: 기본 증발률 × 온도 계수 × 시간 계수
    // 온도 계수: 160°C 기준으로 10°C마다 5% 증가
    final tempFactor = 1 + ((temperature - 160) / 10) * 0.05;
    
    // 시간 계수: 30분 기준으로 10분마다 3% 증가
    final timeFactor = 1 + ((time - 30) / 10) * 0.03;
    
    // 최종 증발률 = 기본률 × 온도계수 × 시간계수
    final finalRate = baseRate * tempFactor * timeFactor;
    
    // 최대 30%로 제한 (현실적인 범위)
    return finalRate.clamp(0.0, 30.0);
  }

  void _calculateFixedOriginalMode(double targetWeight, double adjustedTotalWeight) {
    // 분할 가능한 수량 계산 (조정된 무게 사용)
    final possibleSplits = (adjustedTotalWeight / targetWeight).floor();
    final remainingWeight = adjustedTotalWeight - (possibleSplits * targetWeight);
    
    // 손실률과 수분 증발을 고려한 배수 계산
    final adjustmentFactor = adjustedTotalWeight / _currentTotalWeight;
    
    setState(() {
      _possibleSplits = possibleSplits;
      _remainingWeight = remainingWeight;
      _scaleFactor = adjustmentFactor; // 조정 배수 적용
    });

    // 분할 결과 콜백 호출
    if (widget.onSplitResultChanged != null) {
      widget.onSplitResultChanged!({
        'mode': 'fixed',
        'targetWeight': targetWeight,
        'totalWeight': adjustedTotalWeight,
        'possibleSplits': possibleSplits,
        'remainingWeight': remainingWeight,
        'scaleFactor': _scaleFactor,
      });
    }

    // 재료 계산 (조정 배수 적용, 단위 포함)
    final updatedIngredients = widget.recipe.ingredients.map((ingredient) {
      final originalAmount = ingredient.amount;
      final unit = ingredient.unit;
      
      return Ingredient(
        name: ingredient.name,
        amount: originalAmount * _scaleFactor,
        unit: unit, // 원래 단위 유지
      );
    }).toList();
    
    widget.onIngredientsCalculated(updatedIngredients);
    widget.onMultiplierChanged(_scaleFactor);
  }

  void _calculateScalableMode(double targetWeight, double adjustedTotalWeight) {
    final scaleFactor = targetWeight / adjustedTotalWeight;
    
    // 최적 수량 제안 (사용자가 원하는 개수에 맞춰 전체 레시피 조정)
    final suggestedQuantity = double.tryParse(_optimizedQuantityController.text) ?? 1.0;
    final finalScaleFactor = (targetWeight * suggestedQuantity) / adjustedTotalWeight;
    
    setState(() {
      _scaleFactor = finalScaleFactor;
      _suggestedOptimalQuantity = suggestedQuantity;
    });

    // 분할 결과 콜백 호출
    if (widget.onSplitResultChanged != null) {
      widget.onSplitResultChanged!({
        'mode': 'scalable',
        'targetWeight': targetWeight,
        'totalWeight': adjustedTotalWeight * finalScaleFactor,
        'optimizedQuantity': suggestedQuantity,
        'scaleFactor': finalScaleFactor,
      });
    }

    // 재료 계산 및 콜백 호출 (단위 유지)
    final updatedIngredients = widget.recipe.ingredients.map((ingredient) {
      final originalAmount = ingredient.amount;
      final unit = ingredient.unit;
      
      return Ingredient(
        name: ingredient.name,
        amount: originalAmount * _scaleFactor,
        unit: unit, // 원래 단위 유지
      );
    }).toList();

    widget.onIngredientsCalculated(updatedIngredients);
    widget.onMultiplierChanged(_scaleFactor);
  }

  void _performBakersPercentageCalculation() {
    final newBaseAmount = double.tryParse(_flourAmountController.text) ?? _originalBaseAmount;
    if (newBaseAmount <= 0 || _originalBaseAmount <= 0) return;

    final baseScaleFactor = newBaseAmount / _originalBaseAmount;
    
    setState(() {
      _scaleFactor = baseScaleFactor;
    });

    // 베이커스 퍼센트에 따라 재료 계산 (단위 유지)
    final updatedIngredients = widget.recipe.ingredients.map((ingredient) {
      final name = ingredient.name;
      final unit = ingredient.unit;
      final percentage = _bakersPercentages[name] ?? 0.0;
      final newAmount = newBaseAmount * (percentage / 100);
      
      return Ingredient(
        name: ingredient.name,
        amount: newAmount,
        unit: unit, // 원래 단위 유지
      );
    }).toList();

    widget.onIngredientsCalculated(updatedIngredients);
    widget.onMultiplierChanged(_scaleFactor);
  }

  void _performSplitCountCalculation() {
    final desiredSplitCount = double.tryParse(_splitCountController.text) ?? 0.0;
    if (desiredSplitCount <= 0) return;

    // 원본 레시피의 분할 무게 정보 가져오기
    double originalWeightPerPiece;
    int originalSplitCount;
    
    if (widget.recipe.targetSplitAmount != null && widget.recipe.targetSplitAmount! > 0) {
      // 원본 레시피에 분할 무게가 설정되어 있으면 그 값을 사용
      originalWeightPerPiece = widget.recipe.targetSplitAmount!;
      originalSplitCount = (_currentTotalWeight / originalWeightPerPiece).round();
    } else {
      // 원본 레시피에 분할 무게가 없으면 기본 인분으로 계산
      originalSplitCount = widget.recipe.baseServings > 0 ? widget.recipe.baseServings : 1;
      originalWeightPerPiece = _currentTotalWeight / originalSplitCount;
    }
    
    // 사용자가 원하는 수량에 맞는 배수 계산
    // 개당 무게는 고정, 수량에 따라 전체 레시피 배수 조정
    final newScaleFactor = desiredSplitCount / originalSplitCount;
    
    setState(() {
      _scaleFactor = newScaleFactor;
    });

    // 재료 계산 및 콜백 호출 (단위 유지)
    final updatedIngredients = widget.recipe.ingredients.map((ingredient) {
      final originalAmount = ingredient.amount;
      final unit = ingredient.unit;
      
      return Ingredient(
        name: ingredient.name,
        amount: originalAmount * _scaleFactor,
        unit: unit, // 원래 단위 유지
      );
    }).toList();

    widget.onIngredientsCalculated(updatedIngredients);
    widget.onMultiplierChanged(_scaleFactor);
  }

  void _showOptimizationConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.auto_fix_high, color: Colors.orange.shade600),
            const SizedBox(width: 8),
            const Text('레시피 최적화'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '최적화하여 레시피를 다시 계산할까요?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '원본 레시피 수량: ',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      Text(
                        '${_calculateOriginalSplitCount()}개',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '최적 수량: ',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: _optimizedQuantityController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Text(
                        '개',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              final targetWeight = double.tryParse(_targetWeightController.text) ?? 0.0;
              final adjustedTotalWeight = _calculateAdjustedWeight(_currentTotalWeight);
              _calculateScalableMode(targetWeight, adjustedTotalWeight);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('최적화 적용'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.cake, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  '베이킹 전용 계산기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(width: 8),
                const Spacer(),
                // 아이콘만 사용하여 공간 절약
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showAdvancedSettings = !_showAdvancedSettings;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _showAdvancedSettings
                          ? Colors.orange.shade600
                          : Colors.orange.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.settings,
                      size: 16,
                      color: _showAdvancedSettings
                          ? Colors.white
                          : Colors.orange.shade700,
                    ),
                  ),
                ),

                // 발효 기능은 이제 Sous Chef에 통합됨
                // 고급 설정 톱니바퀴 버튼
                // GestureDetector(
                //   onTap: () {
                //     setState(() {
                //       _showAdvancedSettings = !_showAdvancedSettings;
                //     });
                //   },
                //   child: Container(
                //     padding: const EdgeInsets.all(6),
                //     decoration: BoxDecoration(
                //       color: _showAdvancedSettings 
                //           ? Colors.orange.shade600 
                //           : Colors.orange.shade300,
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                    
                //     child: Icon(
                //       Icons.settings,
                //       size: 16,
                //       color: _showAdvancedSettings 
                //           ? Colors.white 
                //           : Colors.orange.shade700,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          
          // 계산기 내용
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 현재 정보 표시
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        '현재 총 무게',
                        _formatTotalWeight(),
                        Icons.scale,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        '배수',
                        '${_scaleFactor.toStringAsFixed(2)}x',
                        Icons.close,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 계산 모드 선택
                Row(
                  children: [
                    _buildModeButton('분할 무게', 'split_weight', Icons.scale),
                    const SizedBox(width: 8),
                    _buildModeButton('분할 수량', 'split_count', Icons.content_cut),
                    const SizedBox(width: 8),
                    _buildModeButton('퍼센트', 'percentage', Icons.percent),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 입력 필드
                _buildInputSection(),
                const SizedBox(height: 16),
                
                // 분할 정보 표시 (분할 무게/수량 모드일 때)
                if (_calculationMode == 'split_weight' || _calculationMode == 'split_count')
                  _buildSplitInfoCard(),
                
                // 빠른 배수 버튼
                _buildQuickMultipliers(),
              ],
            ),
          ),

        ],
      ),
    );
  }

  // Sous Chef 관련 메서드들
  bool _shouldShowSousChefButton() {
    // 레시피에 bakingMode가 true로 설정되어 있는지 확인
    // 현재는 항상 true로 반환 (실제로는 레시피 메타데이터 확인)
    return true;
  }

  BakingType _getBakingTypeFromRecipe() {
    // 실제로는 레시피의 bakingType 메타데이터를 확인
    // 현재는 기본값으로 bread 반환
    return BakingType.bread;
  }

  void _showSousChefOptions() {
    final bakingType = _getBakingTypeFromRecipe();
    
    // 레시피 데이터 준비
    final recipeData = {
      'totalWeight': _currentTotalWeight,
      'ingredients': widget.recipe.ingredients,
      'bakingTemperature': _bakingTemperature,
      'bakingTime': _bakingTime,
    };
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SousChefOptionsSheet(
        bakingType: bakingType,
        currentState: _sousChefState,
        onOptionsSelected: _applySousChefOptions,
        recipeData: recipeData, // 레시피 데이터 전달
      ),
    );
  }

  void _applySousChefOptions(Map<String, dynamic> options) {
    // 1. Sous Chef 엔진으로 보정값 계산
    final bakingType = _getBakingTypeFromRecipe();
    final environmentData = options['environment'] ?? {};
    final recipeData = {
      'totalWeight': _currentTotalWeight,
      'ingredients': widget.recipe.ingredients,
    };

    final adjustmentResult = _sousChefEngine.calculateAdjustments(
      bakingType: bakingType,
      userInputs: options,
      environmentData: environmentData,
      recipeData: recipeData,
    );

    // 2. 비교 카드 표시
    _showComparisonCard(adjustmentResult, options);
  }

  void _showComparisonCard(AdjustmentResult adjustmentResult, Map<String, dynamic> options) {
    final originalValues = {
      'moisture': _moistureEvaporationRate,
      'temperature': _bakingTemperature,
      'fermentationTime': 60.0, // 기본 발효시간
    };

    showDialog(
      context: context,
      builder: (context) => ComparisonCard(
        originalValues: originalValues,
        adjustmentResult: adjustmentResult,
        onApply: () {
          Navigator.of(context).pop();
          _applyAdjustments(adjustmentResult, options);
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _applyAdjustments(AdjustmentResult adjustmentResult, Map<String, dynamic> options) {
    setState(() {
      _isSousChefActive = true;
      
      // 조정값들을 기존 설정에 적용
      final adjustments = adjustmentResult.adjustments;
      
      // 온도 조정
      if (adjustments.containsKey('temperature')) {
        _bakingTemperature += adjustments['temperature']!;
        _bakingTempController.text = _bakingTemperature.toString();
      }
      
      // 시간 조정
      if (adjustments.containsKey('time')) {
        _bakingTime += adjustments['time']!;
        _bakingTimeController.text = _bakingTime.toString();
      }
      
      // 수분 조정
      if (adjustments.containsKey('moisture') || adjustments.containsKey('hydration')) {
        _considerMoistureEvaporation = true;
        final moistureAdjustment = adjustments['moisture'] ?? adjustments['hydration'] ?? 0.0;
        _moistureEvaporationRate += moistureAdjustment;
        _moistureRateController.text = _moistureEvaporationRate.toString();
      }
      
      // 발효 시간 조정
      if (adjustments.containsKey('fermentation_time_multiplier')) {
        final multiplier = adjustments['fermentation_time_multiplier']!;
        // 발효 시간 관련 UI가 있다면 여기서 적용
        // 현재는 정보 표시용으로만 사용
      }
      
      // 재료 조정 (이스트, 소금 등)
      if (adjustments.containsKey('yeast_percentage') || 
          adjustments.containsKey('salt_percentage')) {
        _applyIngredientAdjustments(adjustments);
      }
      
      // Sous Chef 상태 업데이트
      _sousChefState = SousChefRecipeState(
        recipeId: widget.recipe.id?.toString() ?? 'unknown',
        bakingType: _getBakingTypeFromRecipe(),
        currentAdjustments: adjustments,
        adjustmentHistory: [
          AdjustmentHistoryEntry(
            timestamp: DateTime.now(),
            presetIdUsed: 'manual_adjustment',
            finalAdjustments: adjustments,
            userFeedback: null,
          ),
        ],
      );
    });

    // 계산 재실행
    _performCalculation();
    
    // 성공 메시지 표시
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sous Chef 조언이 레시피에 적용되었습니다'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// 재료 조정값 적용
  void _applyIngredientAdjustments(Map<String, double> adjustments) {
    final currentIngredients = widget.recipe.ingredients.map((ingredient) {
      final name = ingredient.name.toLowerCase();
      double newAmount = ingredient.amount;
      
      // 이스트 조정
      if (adjustments.containsKey('yeast_percentage') && 
          (name.contains('이스트') || name.contains('yeast'))) {
        final adjustment = adjustments['yeast_percentage']!;
        newAmount = ingredient.amount + adjustment;
        if (newAmount <= 0) newAmount = ingredient.amount;
      }
      
      // 소금 조정
      if (adjustments.containsKey('salt_percentage') && 
          (name.contains('소금') || name.contains('salt'))) {
        final adjustment = adjustments['salt_percentage']!;
        newAmount = ingredient.amount + adjustment;
        if (newAmount <= 0) newAmount = ingredient.amount;
      }
      
      // 수분 조정 (물, 우유 등)
      if (adjustments.containsKey('hydration') && 
          (name.contains('물') || name.contains('우유') || name.contains('milk') || name.contains('water'))) {
        final adjustment = adjustments['hydration']!;
        newAmount = ingredient.amount + (ingredient.amount * adjustment / 100);
        if (newAmount <= 0) newAmount = ingredient.amount;
      }
      
      return Ingredient(
        name: ingredient.name,
        amount: newAmount,
        unit: ingredient.unit,
      );
    }).toList();
    
    // 조정된 재료를 콜백으로 전달
    widget.onIngredientsCalculated(currentIngredients);
  }

  void _disableSousChef() {
    setState(() {
      _isSousChefActive = false;
      _sousChefState = null;
      
      // 기본값으로 복원
      _moistureEvaporationRate = 10.0;
      _bakingTemperature = 180.0;
      _moistureRateController.text = _moistureEvaporationRate.toString();
      _bakingTempController.text = _bakingTemperature.toString();
    });

    _performCalculation();
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.orange.shade600, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, String mode, IconData icon) {
    final isSelected = _calculationMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _calculationMode = mode;
          });
          // 모드 변경 콜백 호출
          if (widget.onModeChanged != null) {
            widget.onModeChanged!(_getCurrentModeLabel());
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange.shade600 : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? Colors.orange.shade600 : Colors.orange.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : Colors.orange.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.orange.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    switch (_calculationMode) {
      case 'split_weight':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _targetWeightController,
              decoration: InputDecoration(
                labelText: '개당 분할 무게 (g)',
                helperText: '원하는 분할 무게를 입력하세요',
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: Icon(Icons.scale, color: Colors.orange.shade600),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')), // 숫자와 소수점만 허용
                FilteringTextInputFormatter.deny(RegExp(r'^0+(?=.)')), // 앞의 0 제거 (소수점 앞 제외)
              ],
              onChanged: (value) {
                // 빈 값이거나 유효하지 않은 값일 때는 계산하지 않음
                if (value.isNotEmpty && double.tryParse(value) != null) {
                  _performCalculation();
                }
              },
            ),
            if (_showAdvancedSettings) ...[
              const SizedBox(height: 12),
              _buildAdvancedWeightSettings(),
            ],
          ],
        );
      case 'split_count':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _splitCountController,
              decoration: InputDecoration(
                labelText: '분할 수량 (개)',
                helperText: '몇 개로 나눌지 입력하세요',
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: Icon(Icons.content_cut, color: Colors.orange.shade600),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _performCalculation(),
            ),
            if (_showAdvancedSettings) ...[
              const SizedBox(height: 12),
              _buildAdvancedCountSettings(),
            ],
          ],
        );
      case 'percentage':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 기준 재료 선택 드롭다운
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: _buildSafeDropdown(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _flourAmountController,
              decoration: InputDecoration(
                labelText: '새로운 ${_getSelectedIngredientName()} 양 (g)',
                helperText: '원하는 ${_getSelectedIngredientName()} 양을 입력하세요',
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: Icon(Icons.percent, color: Colors.orange.shade600),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _performCalculation(),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.percent, color: Colors.orange.shade600),
                      const SizedBox(width: 8),
                      Text(
                        '베이커스 퍼센트 계산',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_getSelectedIngredientName()}을(를) 100%로 기준하여 다른 재료의 비율을 계산합니다',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (_showAdvancedSettings) ...[
              const SizedBox(height: 12),
              _buildBakersPercentageCalculator(),
            ],
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildQuickMultipliers() {
    final multipliers = [0.5, 1.0, 1.5, 2.0, 3.0];
    
    // 분할 무게 모드와 분할 수량 모드에서 빠른 배수 기능 비활성화
    final isDisabled = _calculationMode == 'split_weight' || _calculationMode == 'split_count';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '빠른 배수',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDisabled ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
            ),
            if (isDisabled) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.lock,
                size: 14,
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: 4),
              Text(
                _calculationMode == 'split_weight' ? '(무게 분할 모드)' : '(수량 분할 모드)',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: multipliers.map((multiplier) {
            final isSelected = (_scaleFactor - multiplier).abs() < 0.01;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: GestureDetector(
                  onTap: isDisabled ? null : () {
                    setState(() {
                      _scaleFactor = multiplier;
                    });
                    
                    // 입력 필드 업데이트 (분할 무게/수량 모드에서는 빠른 배수 비활성화)
                    if (_calculationMode == 'percentage') {
                      _flourAmountController.text = 
                          (_originalBaseAmount * multiplier).toStringAsFixed(0);
                    }
                    
                    _performCalculation();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isDisabled 
                          ? Colors.grey.shade200 
                          : (isSelected ? Colors.orange.shade600 : Colors.white),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isDisabled 
                            ? Colors.grey.shade300
                            : (isSelected ? Colors.orange.shade600 : Colors.orange.shade300),
                      ),
                    ),
                    child: Text(
                      '${multiplier}x',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDisabled 
                            ? Colors.grey.shade400
                            : (isSelected ? Colors.white : Colors.orange.shade600),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (isDisabled) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _calculationMode == 'split_weight' 
                        ? '무게 분할 모드에서는 정확한 계산을 위해 빠른 배수를 사용할 수 없습니다'
                        : '수량 분할 모드에서는 동적 계산을 위해 빠른 배수를 사용할 수 없습니다',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAdvancedWeightSettings() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '고급 무게 설정',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 8),
          
          // 원본 레시피 무게 고정/비고정 모드 선택
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isFixedOriginalMode = true;
                    });
                    _performCalculation();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: _isFixedOriginalMode ? Colors.orange.shade600 : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _isFixedOriginalMode ? Colors.orange.shade600 : Colors.orange.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock,
                          size: 14,
                          color: _isFixedOriginalMode ? Colors.white : Colors.orange.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '고정 모드',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _isFixedOriginalMode ? Colors.white : Colors.orange.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isFixedOriginalMode = false;
                    });
                    _showOptimizationConfirmDialog();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: !_isFixedOriginalMode ? Colors.orange.shade600 : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: !_isFixedOriginalMode ? Colors.orange.shade600 : Colors.orange.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_fix_high,
                          size: 14,
                          color: !_isFixedOriginalMode ? Colors.white : Colors.orange.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '최적화 모드',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: !_isFixedOriginalMode ? Colors.white : Colors.orange.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 전문가 설정들
          _buildLossRateSettings(),
          const SizedBox(height: 8),
          _buildMoistureEvaporationSettings(),
        ],
      ),
    );
  }

  Widget _buildLossRateSettings() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '손실률 고려',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              ),
            ),
            Switch(
              value: _considerLoss,
              onChanged: (value) {
                setState(() {
                  _considerLoss = value;
                });
                _performCalculation();
              },
              activeColor: Colors.orange.shade600,
            ),
          ],
        ),
        if (_considerLoss) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '손실률 설정 (%)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _lossPercentageController,
                  decoration: InputDecoration(
                    hintText: '예: 5.0 (5%)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 11),
                  onChanged: (value) {
                    final rate = double.tryParse(value);
                    if (rate != null) {
                      _lossPercentage = rate;
                      _performCalculation();
                    }
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  '• 일반적인 제조 손실률: 3-8%\n• 복잡한 공정: 8-15%\n• 초보자: 10-20%',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.orange.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMoistureEvaporationSettings() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '수분 증발 계산',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              ),
            ),
            Switch(
              value: _considerMoistureEvaporation,
              onChanged: (value) {
                setState(() {
                  _considerMoistureEvaporation = value;
                });
                _performCalculation();
              },
              activeColor: Colors.orange.shade600,
            ),
          ],
        ),
        if (_considerMoistureEvaporation) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '수분 증발 설정',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '기본 증발률 (%)',
                            style: TextStyle(fontSize: 9, color: Colors.blue.shade600),
                          ),
                          const SizedBox(height: 2),
                          TextField(
                            controller: _moistureRateController,
                            decoration: InputDecoration(
                              hintText: '10.0',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            ),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 10),
                            onChanged: (value) {
                              final rate = double.tryParse(value);
                              if (rate != null) {
                                _moistureEvaporationRate = rate;
                                _performCalculation();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '굽기 온도 (°C)',
                            style: TextStyle(fontSize: 9, color: Colors.blue.shade600),
                          ),
                          const SizedBox(height: 2),
                          TextField(
                            controller: _bakingTempController,
                            decoration: InputDecoration(
                              hintText: '180',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            ),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 10),
                            onChanged: (value) {
                              final temp = double.tryParse(value);
                              if (temp != null) {
                                _bakingTemperature = temp;
                                _performCalculation();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '굽기 시간 (분)',
                            style: TextStyle(fontSize: 9, color: Colors.blue.shade600),
                          ),
                          const SizedBox(height: 2),
                          TextField(
                            controller: _bakingTimeController,
                            decoration: InputDecoration(
                              hintText: '30',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            ),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 10),
                            onChanged: (value) {
                              final time = double.tryParse(value);
                              if (time != null) {
                                _bakingTime = time;
                                _performCalculation();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '계산된 증발률',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_calculateMoistureEvaporationRate().toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '• 빵류: 8-15% • 쿠키: 5-10% • 케이크: 10-18%\n• 높은 온도/긴 시간 = 더 많은 증발',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAdvancedCountSettings() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '고급 분할 설정',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '균등 분할',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                ),
              ),
              Switch(
                value: _isEqualSplit,
                onChanged: (value) {
                  setState(() {
                    _isEqualSplit = value;
                  });
                  // 균등 분할 설정 변경 시 재계산
                  _performCalculation();
                },
                activeColor: Colors.orange.shade600,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isEqualSplit) 
            Text(
              '개당 예상 무게: ${(_currentTotalWeight * _scaleFactor / (double.tryParse(_splitCountController.text) ?? 1)).toStringAsFixed(1)}g',
              style: TextStyle(
                fontSize: 11,
                color: Colors.orange.shade600,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    size: 14,
                    color: Colors.amber.shade600,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '비균등 분할: 개당 무게가 다를 수 있습니다',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.amber.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBakersPercentageCalculator() {
    final newBaseAmount = double.tryParse(_flourAmountController.text) ?? _originalBaseAmount;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '베이커스 퍼센트 분석',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '배수: ${_scaleFactor.toStringAsFixed(2)}x',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '기준: ${_getSelectedIngredientName()} ${_originalBaseAmount.toStringAsFixed(0)}g → ${newBaseAmount.toStringAsFixed(0)}g',
            style: TextStyle(
              fontSize: 11,
              color: Colors.orange.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            color: Colors.orange.shade300,
          ),
          const SizedBox(height: 8),
          ...widget.recipe.ingredients.map((ingredient) {
            final name = ingredient.name;
            final originalAmount = ingredient.amount;
            final percentage = _bakersPercentages[name] ?? 0.0;
            final newAmount = newBaseAmount * (percentage / 100);
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      name,
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${originalAmount.toStringAsFixed(0)}g',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                        decoration: TextDecoration.lineThrough,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${newAmount.toStringAsFixed(0)}g',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 8),
          Container(
            height: 1,
            color: Colors.orange.shade300,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '총 무게',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${_currentTotalWeight.toStringAsFixed(0)}g → ${(newBaseAmount * _bakersPercentages.values.fold(0.0, (sum, percentage) => sum + percentage) / 100).toStringAsFixed(0)}g',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCurrentModeLabel() {
    switch (_calculationMode) {
      case 'split_weight':
        return '분할 무게 기준';
      case 'split_count':
        return '분할 수량 기준';
      case 'percentage':
        return '베이커스 퍼센트 기준';
      default:
        return '기준';
    }
  }

  String _formatTotalWeight() {
    final optimal = UnitConverter.getOptimalDisplayUnit(_currentTotalWeight, 'g');
    final amount = optimal['amount'] as double;
    final unit = optimal['unit'] as String;
    
    if (amount >= 10) {
      return '${amount.toStringAsFixed(0)}$unit';
    } else {
      return '${amount.toStringAsFixed(1)}$unit';
    }
  }

  Widget _buildSplitInfoCard() {
    if (_currentTotalWeight <= 0) {
      return const SizedBox.shrink();
    }

    // 분할 무게 모드
    if (_calculationMode == 'split_weight') {
      final targetWeight = double.tryParse(_targetWeightController.text) ?? 0.0;
      if (targetWeight <= 0) return const SizedBox.shrink();
      
      // 손실률과 수분 증발을 고려한 조정된 무게 계산
      final adjustedTotalWeight = _calculateAdjustedWeight(_currentTotalWeight);
      
      // 고정 모드와 최적화 모드에 따른 계산
      if (_isFixedOriginalMode) {
        return _buildFixedModeSplitInfo(targetWeight, adjustedTotalWeight);
      } else {
        return _buildOptimizedModeSplitInfo(targetWeight, adjustedTotalWeight);
      }
    }
    
    // 분할 수량 모드
    else if (_calculationMode == 'split_count') {
      final splitCount = double.tryParse(_splitCountController.text) ?? 0.0;
      if (splitCount <= 0) return const SizedBox.shrink();
      
      return _buildCountModeSplitInfo(splitCount.toInt());
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildFixedModeSplitInfo(double targetWeight, double adjustedTotalWeight) {
    final possibleSplits = (adjustedTotalWeight / targetWeight).floor();
    final remainingWeight = adjustedTotalWeight - (possibleSplits * targetWeight);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              Icon(Icons.info_outline, color: Colors.blue.shade600, size: 16),
              const SizedBox(width: 6),
              Text(
                '분할 정보 (고정 모드)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSplitInfoItem(
                  '분할 가능 수량',
                  '${possibleSplits}개',
                  Icons.content_cut,
                  Colors.green.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSplitInfoItem(
                  '개당 무게',
                  '${targetWeight.toStringAsFixed(0)}g',
                  Icons.scale,
                  Colors.orange.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSplitInfoItem(
                  '총 무게',
                  '${adjustedTotalWeight.toStringAsFixed(0)}g',
                  Icons.fitness_center,
                  Colors.blue.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSplitInfoItem(
                  '남은 재료',
                  '${remainingWeight.toStringAsFixed(0)}g',
                  Icons.inventory_2,
                  remainingWeight > 0 ? Colors.amber.shade600 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          if (remainingWeight > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.amber.shade700, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${remainingWeight.toStringAsFixed(0)}g의 재료가 남습니다',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.amber.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptimizedModeSplitInfo(double targetWeight, double adjustedTotalWeight) {
    final optimizedQuantity = double.tryParse(_optimizedQuantityController.text) ?? 1.0;
    final scaledTotalWeight = adjustedTotalWeight * _scaleFactor;
    
    // 최적화 모드에서의 실제 계산
    // 목표: optimizedQuantity개를 각각 targetWeight로 만들기
    // 실제 분할 가능 수량 = 조정된 총 무게 ÷ 목표 개당 무게
    final actualPossibleSplits = (scaledTotalWeight / targetWeight).floor();
    final actualWeightPerPiece = scaledTotalWeight / optimizedQuantity; // 실제 제작할 개당 무게
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_fix_high, color: Colors.green.shade600, size: 16),
              const SizedBox(width: 6),
              Text(
                '최적화 정보',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSplitInfoItem(
                  '분할 가능 수량',
                  '${actualPossibleSplits}개',
                  Icons.content_cut,
                  Colors.green.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSplitInfoItem(
                  '목표 개당 무게',
                  '${targetWeight.toStringAsFixed(0)}g',
                  Icons.gps_fixed,
                  Colors.orange.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSplitInfoItem(
                  '제작 수량',
                  '${optimizedQuantity.toStringAsFixed(0)}개',
                  Icons.production_quantity_limits,
                  Colors.blue.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSplitInfoItem(
                  '실제 개당 무게',
                  '${actualWeightPerPiece.toStringAsFixed(0)}g',
                  Icons.scale,
                  Colors.purple.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSplitInfoItem(
                  '조정된 총 무게',
                  '${scaledTotalWeight.toStringAsFixed(0)}g',
                  Icons.fitness_center,
                  Colors.teal.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSplitInfoItem(
                  '남은 재료',
                  '${_calculateOptimizedRemainingWeight(scaledTotalWeight, targetWeight, actualPossibleSplits).toStringAsFixed(0)}g',
                  Icons.inventory_2,
                  _calculateOptimizedRemainingWeight(scaledTotalWeight, targetWeight, actualPossibleSplits) > 0 
                      ? Colors.amber.shade600 
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.green.shade700, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '레시피가 ${_scaleFactor.toStringAsFixed(2)}배로 조정됨',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (actualPossibleSplits != optimizedQuantity) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.amber.shade700, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '목표 개당 무게로는 ${actualPossibleSplits}개까지 분할 가능',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.amber.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                // 남은 재료 정보 추가
                if (_calculateOptimizedRemainingWeight(scaledTotalWeight, targetWeight, actualPossibleSplits) > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.inventory_2, color: Colors.amber.shade700, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${_calculateOptimizedRemainingWeight(scaledTotalWeight, targetWeight, actualPossibleSplits).toStringAsFixed(0)}g의 재료가 남습니다',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.amber.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountModeSplitInfo(int splitCount) {
    final totalScaledWeight = _currentTotalWeight * _scaleFactor;
    
    // 원본 레시피의 분할 정보 계산
    double originalWeightPerPiece;
    int originalSplitCount;
    
    if (widget.recipe.targetSplitAmount != null && widget.recipe.targetSplitAmount! > 0) {
      // 원본 레시피에 분할 무게가 설정되어 있으면 그 값을 사용
      originalWeightPerPiece = widget.recipe.targetSplitAmount!;
      originalSplitCount = (_currentTotalWeight / originalWeightPerPiece).round();
    } else {
      // 원본 레시피에 분할 무게가 없으면 기본 인분으로 계산
      originalSplitCount = widget.recipe.baseServings > 0 ? widget.recipe.baseServings : 1;
      originalWeightPerPiece = _currentTotalWeight / originalSplitCount;
    }
    
    // 개당 무게는 원본과 동일하게 유지 (고정값)
    final weightPerPiece = originalWeightPerPiece;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.green.shade600, size: 16),
              const SizedBox(width: 6),
              Text(
                '분할 정보 (수량 기준)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSplitInfoItem(
                  '분할 수량',
                  '${splitCount}개',
                  Icons.content_cut,
                  Colors.green.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSplitInfoItem(
                  '개당 무게',
                  '${weightPerPiece.toStringAsFixed(1)}g',
                  Icons.scale,
                  Colors.orange.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSplitInfoItem(
                  '총 무게',
                  '${totalScaledWeight.toStringAsFixed(0)}g',
                  Icons.fitness_center,
                  Colors.blue.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSplitInfoItem(
                  '원본 수량',
                  '${originalSplitCount}개',
                  Icons.receipt_long,
                  Colors.grey.shade600,
                ),
              ),
            ],
          ),


          // 원본 레시피 분할 정보 표시
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt_long, color: Colors.grey.shade600, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '원본 레시피 기준',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '• 개당 무게: ${originalWeightPerPiece.toStringAsFixed(1)}g (고정)',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  '• 원본 수량: ${originalSplitCount}개',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  '• 요청 수량: ${splitCount}개 (${_scaleFactor.toStringAsFixed(2)}배)',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          if (_scaleFactor != 1.0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade700, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '레시피 조정: 원본 ${originalSplitCount}개 → 요청 ${splitCount}개 (${_scaleFactor.toStringAsFixed(2)}배)\n개당 무게는 ${originalWeightPerPiece.toStringAsFixed(1)}g로 동일하게 유지됩니다',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }


  Widget _buildSplitInfoItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 편집 가능한 분할 정보 아이템 메서드 제거됨 - 분할 정보는 읽기 전용으로 변경
  // Widget _buildEditableSplitInfoItem(...) { ... }

  int _calculateOriginalSplitCount() {
    // 원본 레시피의 분할 가능한 수량 계산
    if (widget.recipe.targetSplitAmount != null && widget.recipe.targetSplitAmount! > 0) {
      // DB에 저장된 분할 무게가 있으면 그것으로 계산
      return (_currentTotalWeight / widget.recipe.targetSplitAmount!).floor();
    } else {
      // 분할 무게가 없으면 기본 인분 수 사용
      return widget.recipe.baseServings > 0 ? widget.recipe.baseServings : 1;
    }
  }

  double _calculateOptimizedRemainingWeight(double scaledTotalWeight, double targetWeight, int actualPossibleSplits) {
    // 최적화 모드에서 남은 재료 무게 계산
    // 조정된 총 무게에서 (분할 가능 수량 × 목표 개당 무게)를 뺀 값
    final usedWeight = actualPossibleSplits * targetWeight;
    return scaledTotalWeight - usedWeight;
  }

  String _getSelectedIngredientName() {
    if (widget.recipe.ingredients.isEmpty || 
        _selectedBaseIngredientIndex >= widget.recipe.ingredients.length) {
      return '기본재료';
    }
    
    final ingredient = widget.recipe.ingredients[_selectedBaseIngredientIndex];
    final name = ingredient.name;
    
    // 동일한 이름이 여러 개 있을 경우 인덱스 추가
    final sameNameCount = widget.recipe.ingredients
        .where((ing) => ing.name == name)
        .length;
    if (sameNameCount > 1) {
      final sameNameIndex = widget.recipe.ingredients
          .take(_selectedBaseIngredientIndex + 1)
          .where((ing) => ing.name == name)
          .length;
      return '$name #$sameNameIndex';
    }
    
    return name;
  }

  Widget _buildSafeDropdown() {
    // 재료가 없으면 빈 드롭다운 반환
    if (widget.recipe.ingredients.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        child: Text(
          '재료가 없습니다',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    // 현재 선택된 인덱스가 유효한지 확인
    if (_selectedBaseIngredientIndex >= widget.recipe.ingredients.length) {
      _selectedBaseIngredientIndex = 0;
    }

    return DropdownButtonFormField<int>(
      value: _selectedBaseIngredientIndex,
      decoration: InputDecoration(
        labelText: '기준 재료 선택',
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
      items: widget.recipe.ingredients.asMap().entries.map((entry) {
        final index = entry.key;
        final ingredient = entry.value;
        final name = ingredient.name;
        final amount = ingredient.amount;
        final unit = ingredient.unit;
        
        // UnitConverter 호출을 try-catch로 감싸서 안전하게 처리
        String formattedAmount;
        try {
          formattedAmount = UnitConverter.formatAmountWithOriginalUnit(amount, unit);
        } catch (e) {
          formattedAmount = '${amount.toStringAsFixed(1)}$unit';
        }
        
        // 동일한 이름이 여러 개 있을 경우 인덱스 추가
        String displayName = name;
        final sameNameCount = widget.recipe.ingredients
            .where((ing) => ing.name == name)
            .length;
        if (sameNameCount > 1) {
          final sameNameIndex = widget.recipe.ingredients
              .take(index + 1)
              .where((ing) => ing.name == name)
              .length;
          displayName = '$name #$sameNameIndex';
        }
        
        return DropdownMenuItem<int>(
          value: index,
          child: Text(
            '$displayName ($formattedAmount)',
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: _onBaseIngredientIndexChanged,
      icon: Icon(Icons.arrow_drop_down, color: Colors.orange.shade600),
    );
  }

  // 발효 전문가 기능이 Sous Chef로 통합되었습니다.
  // 더 이상 별도의 발효 버튼이 필요하지 않습니다.
  
  /*
  // 이전 발효 관련 메서드들 (더 이상 사용하지 않음)
  bool _shouldShowFermentationButton() {
    return false; // 발효 기능이 Sous Chef에 통합됨
  }

  void _showFermentationAdvisor() {
    // 발효 기능이 Sous Chef에 통합되어 더 이상 사용하지 않음
    // 대신 _showSousChefOptions()를 사용하세요
  }
  */
}