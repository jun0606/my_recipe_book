# 베이킹 계산기 고도화 구현 가이드

## Phase 1: 실시간 계산 및 UI 갱신 구현

### 1.1 디바운싱 시스템 구현

```dart
// lib/mixins/real_time_calculation_mixin.dart
mixin RealTimeCalculationMixin {
  Timer? _debounceTimer;
  
  void debounceCalculation(VoidCallback calculation, {int milliseconds = 300}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: milliseconds), calculation);
  }
  
  void dispose() {
    _debounceTimer?.cancel();
  }
}
```

### 1.2 실시간 갱신 Provider 수정

```dart
// BakingCalculationProvider에 추가
class BakingCalculationProvider extends ChangeNotifier with RealTimeCalculationMixin {
  void setScaleWithDebounce(double scale) {
    _scale = scale;
    debounceCalculation(() {
      _calculate();
      notifyListeners();
    });
  }
}
```

### 1.3 초기화 기능 구현

```dart
// lib/widgets/recipe_detail/baking_calculator/reset_button.dart
class ResetButton extends StatelessWidget {
  final BakingCalculationProvider provider;
  
  const ResetButton({Key? key, required this.provider}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      child: IconButton(
        icon: Icon(Icons.refresh),
        tooltip: '초기화',
        onPressed: () => _showResetDialog(context),
      ),
    );
  }
  
  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('계산값 초기화'),
        content: Text('모든 계산값을 원본 레시피 상태로 초기화하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.resetToOriginal();
              Navigator.pop(context);
              _showResetAnimation(context);
            },
            child: Text('초기화'),
          ),
        ],
      ),
    );
  }
  
  void _showResetAnimation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(strokeWidth: 2),
            SizedBox(width: 16),
            Text('초기화 중...'),
          ],
        ),
        duration: Duration(milliseconds: 800),
      ),
    );
  }
}
```

## Phase 2: 반올림 기능 및 정보 개선

### 2.1 반올림 설정 서비스

```dart
// lib/services/rounding_preferences_service.dart
class RoundingPreferencesService {
  static const String _keyRoundingEnabled = 'rounding_enabled';
  static const String _keyDecimalPlaces = 'decimal_places';
  
  Future<bool> getRoundingEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRoundingEnabled) ?? true;
  }
  
  Future<void> setRoundingEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRoundingEnabled, enabled);
  }
  
  Future<int> getDecimalPlaces() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyDecimalPlaces) ?? 1;
  }
  
  Future<void> setDecimalPlaces(int places) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDecimalPlaces, places);
  }
  
  double roundValue(double value, int decimalPlaces, bool enabled) {
    if (!enabled) return value;
    final factor = pow(10, decimalPlaces);
    return (value * factor).round() / factor;
  }
}
```

### 2.2 개선된 재료 카드

```dart
// lib/widgets/recipe_detail/baking_calculator/enhanced_ingredient_card.dart
class EnhancedIngredientCard extends StatelessWidget {
  final Map<String, dynamic> ingredient;
  final Map<String, dynamic>? originalIngredient;
  final bool showTotalWeight;
  final bool isHighlighted;
  final GlobalKey? itemKey;
  
  const EnhancedIngredientCard({
    Key? key,
    required this.ingredient,
    this.originalIngredient,
    this.showTotalWeight = true,
    this.isHighlighted = false,
    this.itemKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentAmount = double.tryParse(ingredient['amount'].toString()) ?? 0.0;
    final originalAmount = originalIngredient != null 
        ? double.tryParse(originalIngredient!['amount'].toString()) ?? 0.0 
        : currentAmount;
    
    return Card(
      key: itemKey,
      elevation: isHighlighted ? 8 : 2,
      color: isHighlighted ? Colors.pink.shade50 : null,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ingredient['name'] ?? '',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            if (showTotalWeight) ...[
              _buildAmountRow('총 필요량', currentAmount, originalAmount, ingredient['unit']),
              _buildAmountRow('1개당', currentAmount / _getSplitCount(), null, ingredient['unit'], isSecondary: true),
            ] else ...[
              _buildAmountRow('1개당', currentAmount, originalAmount, ingredient['unit']),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildAmountRow(String label, double amount, double? originalAmount, String unit, {bool isSecondary = false}) {
    Color amountColor = Colors.black;
    if (originalAmount != null && amount != originalAmount) {
      amountColor = amount > originalAmount ? Colors.green : Colors.red;
    }
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isSecondary ? 12 : 14,
              color: isSecondary ? Colors.grey[600] : Colors.black,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(1)}$unit',
            style: TextStyle(
              fontSize: isSecondary ? 12 : 14,
              fontWeight: isSecondary ? FontWeight.normal : FontWeight.bold,
              color: isSecondary ? Colors.grey[600] : amountColor,
            ),
          ),
        ],
      ),
    );
  }
  
  int _getSplitCount() {
    // Provider에서 현재 분할 수량 가져오기
    return 1; // 임시값
  }
}
```

### 2.3 색상 코딩된 결과 카드

```dart
// lib/widgets/recipe_detail/baking_calculator/color_coded_result_card.dart
class ColorCodedResultCard extends StatelessWidget {
  final BakingCalculationResult result;
  final Recipe originalRecipe;
  final String unitSystem;
  
  const ColorCodedResultCard({
    Key? key,
    required this.result,
    required this.originalRecipe,
    required this.unitSystem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('계산 결과', style: Theme.of(context).textTheme.titleMedium),
                ResetButton(provider: Provider.of<BakingCalculationProvider>(context, listen: false)),
              ],
            ),
            Divider(),
            _buildColorCodedRow('총 무게', result.totalWeight, originalRecipe.totalIngredientWeight, unitSystem),
            _buildColorCodedRow('분할 무게', result.splitWeight, _getOriginalSplitWeight(), unitSystem),
            _buildColorCodedRow('분할 수량', result.splitCount.toDouble(), _getOriginalSplitCount().toDouble(), '개'),
            _buildColorCodedRow('배율', result.scale, 1.0, 'x'),
            if (result.remainingWeight > 0)
              _buildColorCodedRow('남은 재료', result.remainingWeight, 0.0, unitSystem),
            if (result.isOptimized)
              _buildOptimizedIndicator(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildColorCodedRow(String label, double currentValue, double? originalValue, String unit) {
    Color valueColor = Colors.black;
    IconData? changeIcon;
    
    if (originalValue != null && (currentValue - originalValue).abs() > 0.01) {
      if (currentValue > originalValue) {
        valueColor = Colors.green;
        changeIcon = Icons.arrow_upward;
      } else {
        valueColor = Colors.red;
        changeIcon = Icons.arrow_downward;
      }
    }
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              if (changeIcon != null) ...[
                Icon(changeIcon, size: 16, color: valueColor),
                SizedBox(width: 4),
              ],
              Text(
                '${currentValue.toStringAsFixed(2)}$unit',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildOptimizedIndicator() {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green),
          SizedBox(width: 4),
          Text('최적화 적용됨', style: TextStyle(color: Colors.green, fontSize: 12)),
        ],
      ),
    );
  }
  
  double? _getOriginalSplitWeight() => originalRecipe.targetSplitAmount;
  int _getOriginalSplitCount() => originalRecipe.targetSplitCount ?? 1;
}
```

## Phase 3: 모드 순서 커스터마이징

### 3.1 모드 설정 서비스

```dart
// lib/services/baking_mode_preferences_service.dart
class BakingModePreferencesService {
  static const String _keyModeOrder = 'baking_mode_order';
  
  static const List<BakingCalculationMode> _defaultOrder = [
    BakingCalculationMode.scaleAdjustment,
    BakingCalculationMode.splitByCount,
    BakingCalculationMode.splitByWeight,
    BakingCalculationMode.scaleAndSplit,
    BakingCalculationMode.dynamicComparison,
    BakingCalculationMode.optimalSplit,
  ];
  
  Future<List<BakingCalculationMode>> getModeOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final orderStrings = prefs.getStringList(_keyModeOrder);
    
    if (orderStrings == null) return _defaultOrder;
    
    try {
      return orderStrings
          .map((s) => BakingCalculationMode.values.firstWhere((mode) => mode.name == s))
          .toList();
    } catch (e) {
      return _defaultOrder;
    }
  }
  
  Future<void> saveModeOrder(List<BakingCalculationMode> order) async {
    final prefs = await SharedPreferences.getInstance();
    final orderStrings = order.map((mode) => mode.name).toList();
    await prefs.setStringList(_keyModeOrder, orderStrings);
  }
}
```

### 3.2 드래그 가능한 모드 선택기

```dart
// lib/widgets/recipe_detail/baking_calculator/draggable_mode_selector.dart
class DraggableModeSelector extends StatefulWidget {
  final BakingCalculationProvider provider;
  final BakingService bakingService;
  
  const DraggableModeSelector({
    Key? key,
    required this.provider,
    required this.bakingService,
  }) : super(key: key);

  @override
  State<DraggableModeSelector> createState() => _DraggableModeSelectorState();
}

class _DraggableModeSelectorState extends State<DraggableModeSelector> {
  late List<BakingCalculationMode> _modeOrder;
  final BakingModePreferencesService _preferencesService = BakingModePreferencesService();
  
  @override
  void initState() {
    super.initState();
    _loadModeOrder();
  }
  
  Future<void> _loadModeOrder() async {
    final order = await _preferencesService.getModeOrder();
    setState(() {
      _modeOrder = order;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (_modeOrder.isEmpty) {
      return CircularProgressIndicator();
    }
    
    return ReorderableListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _modeOrder.length,
      onReorder: _onReorder,
      itemBuilder: (context, index) {
        final mode = _modeOrder[index];
        final modeInfo = widget.bakingService.getModeInfo(mode);
        
        return Container(
          key: ValueKey(mode),
          margin: EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            avatar: Icon(modeInfo['icon']),
            label: Text(modeInfo['name']),
            selected: widget.provider.mode == mode,
            onSelected: (selected) {
              if (selected) {
                widget.provider.setMode(mode);
              }
            },
          ),
        );
      },
    );
  }
  
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final mode = _modeOrder.removeAt(oldIndex);
      _modeOrder.insert(newIndex, mode);
    });
    
    _preferencesService.saveModeOrder(_modeOrder);
  }
}
```

## 구현 체크리스트

### Phase 1 체크리스트
- [ ] RealTimeCalculationMixin 구현
- [ ] 디바운싱 시스템 적용
- [ ] 초기화 버튼 및 다이얼로그 구현
- [ ] 초기화 애니메이션 효과 추가
- [ ] 모든 계산 모드에서 실시간 갱신 검증

### Phase 2 체크리스트
- [ ] RoundingPreferencesService 구현
- [ ] 반올림 토글 위젯 구현
- [ ] EnhancedIngredientCard 구현
- [ ] ColorCodedResultCard 구현
- [ ] 색상 코딩 시스템 테스트

### Phase 3 체크리스트
- [ ] BakingModePreferencesService 구현
- [ ] DraggableModeSelector 구현
- [ ] 모드 순서 설정 화면 구현
- [ ] 목표 수량 계산기 제거
- [ ] UI 정리 및 최적화

이 가이드를 따라 단계별로 구현하면 베이킹 계산기의 사용성과 기능성이 크게 향상될 것입니다.