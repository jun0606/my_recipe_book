import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/practical_recipe.dart';
import '../../services/division_calculation_engine.dart';

/// 기본 분할 계산 위젯
/// "5개 나오는 레시피를 6개로 만들고 싶어요" 같은 직관적인 계산을 제공
class BasicDivisionCalculator extends StatefulWidget {
  final PracticalRecipe? initialRecipe;
  final Function(DivisionResult)? onCalculationComplete;

  const BasicDivisionCalculator({
    Key? key,
    this.initialRecipe,
    this.onCalculationComplete,
  }) : super(key: key);

  @override
  State<BasicDivisionCalculator> createState() =>
      _BasicDivisionCalculatorState();
}

class _BasicDivisionCalculatorState extends State<BasicDivisionCalculator>
    with TickerProviderStateMixin {
  final TextEditingController _originalCountController =
      TextEditingController();
  final TextEditingController _targetCountController = TextEditingController();
  final FocusNode _originalCountFocus = FocusNode();
  final FocusNode _targetCountFocus = FocusNode();

  PracticalRecipe? _selectedRecipe;
  DivisionResult? _calculationResult;
  bool _isCalculating = false;
  String? _errorMessage;

  late AnimationController _resultAnimationController;
  late Animation<double> _resultFadeAnimation;
  late Animation<Offset> _resultSlideAnimation;

  @override
  void initState() {
    super.initState();
    _selectedRecipe = widget.initialRecipe;

    // 애니메이션 컨트롤러 초기화
    _resultAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _resultFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _resultAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _resultSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _resultAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // 기본값 설정
    if (_selectedRecipe != null) {
      _originalCountController.text = (_selectedRecipe?.originalYield ?? 1).toString();
    }
  }

  @override
  void dispose() {
    _originalCountController.dispose();
    _targetCountController.dispose();
    _originalCountFocus.dispose();
    _targetCountFocus.dispose();
    _resultAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildRecipeSelector(),
            const SizedBox(height: 20),
            _buildCalculationInputs(),
            const SizedBox(height: 20),
            _buildCalculateButton(),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              _buildErrorMessage(),
            ],
            if (_calculationResult != null) ...[
              const SizedBox(height: 24),
              _buildResultSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.calculate,
            color: Colors.blue,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '기본 분할 계산',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '레시피 개수를 쉽게 조정해보세요',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300] ?? Colors.grey),
      ),
      child: Row(
        children: [
          Icon(
            Icons.book_outlined,
            color: Colors.grey[600],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _selectedRecipe != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedRecipe?.name ?? '레시피 없음',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '원래 ${_selectedRecipe?.originalYield ?? 0}개 나오는 레시피',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                : Text(
                    '레시피를 선택해주세요',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
          ),
          TextButton(
            onPressed: _showRecipeSelector,
            child: const Text('변경'),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationInputs() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[50] ?? Colors.blue.shade50,
            Colors.blue[25] ?? Colors.blue.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        children: [
          Text(
            '개수 조정하기',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildNumberInput(
                  controller: _originalCountController,
                  focusNode: _originalCountFocus,
                  label: '원래 개수',
                  hint: '5',
                  enabled: _selectedRecipe == null,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              Expanded(
                child: _buildNumberInput(
                  controller: _targetCountController,
                  focusNode: _targetCountFocus,
                  label: '만들고 싶은 개수',
                  hint: '6',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildQuickButtons(),
        ],
      ),
    );
  }

  Widget _buildNumberInput({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.blue[700],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: focusNode.hasFocus ? Colors.blue : Colors.grey[300]!,
              width: focusNode.hasFocus ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onChanged: (_) => _clearError(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickButtons() {
    if (_selectedRecipe == null) return const SizedBox.shrink();

    final originalCount = _selectedRecipe!.originalYield;
    final quickOptions = [
      originalCount * 2,
      originalCount * 3,
      (originalCount * 1.5).round(),
      originalCount + 1,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 선택',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.blue[700],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickOptions.map((count) {
            return InkWell(
              onTap: () {
                _targetCountController.text = count.toString();
                _clearError();
                HapticFeedback.lightImpact();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  '${count}개',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCalculateButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _canCalculate() ? _performCalculation : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: _isCalculating ? 0 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isCalculating
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    '계산 중...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calculate, size: 24),
                  SizedBox(width: 8),
                  Text(
                    '계산하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[600],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection() {
    return SlideTransition(
      position: _resultSlideAnimation,
      child: FadeTransition(
        opacity: _resultFadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green[50]!,
                Colors.green[25]!,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '계산 완료!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildScalingInfo(),
              const SizedBox(height: 16),
              _buildIngredientsList(),
              if (_calculationResult!.remainingIngredients.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildRemainingIngredients(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScalingInfo() {
    final multiplier = _calculationResult!.scalingMultiplier;
    final percentage = ((multiplier - 1) * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '배율: ${multiplier.toStringAsFixed(2)}배',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  percentage > 0
                      ? '${percentage}% 증가'
                      : '${percentage.abs()}% 감소',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_calculationResult!.originalCount}개 → ${_calculationResult!.targetCount}개',
              style: TextStyle(
                color: Colors.blue[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '조정된 재료량',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          const SizedBox(height: 12),
          ...(_calculationResult!.adjustedIngredients.map((ingredient) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      ingredient['name'] as String,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '${(ingredient['amount'] as double).toStringAsFixed(1)}${ingredient['unit'] as String}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            );
          }).toList()),
        ],
      ),
    );
  }

  Widget _buildRemainingIngredients() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.orange[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '남은 재료',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(_calculationResult!.remainingIngredients.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    '${entry.value.toStringAsFixed(1)}g',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
            );
          }).toList()),
          const SizedBox(height: 8),
          Text(
            '💡 남은 재료로 데코레이션을 만들어보세요!',
            style: TextStyle(
              fontSize: 13,
              color: Colors.orange[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  bool _canCalculate() {
    return _selectedRecipe != null &&
        _originalCountController.text.isNotEmpty &&
        _targetCountController.text.isNotEmpty &&
        !_isCalculating;
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  Future<void> _performCalculation() async {
    if (!_canCalculate()) return;

    setState(() {
      _isCalculating = true;
      _errorMessage = null;
    });

    try {
      final originalCount = int.parse(_originalCountController.text);
      final targetCount = int.parse(_targetCountController.text);

      // 입력값 검증
      if (originalCount <= 0 || targetCount <= 0) {
        throw Exception('개수는 1개 이상이어야 합니다');
      }

      if (targetCount > originalCount * 10) {
        throw Exception('너무 많은 양입니다. 10배 이하로 설정해주세요');
      }

      // 계산 수행
      final result = await DivisionCalculationEngine.calculateDivision(
        originalRecipe: _selectedRecipe!,
        targetCount: targetCount,
      );

      setState(() {
        _calculationResult = result;
        _isCalculating = false;
      });

      // 결과 애니메이션 시작
      _resultAnimationController.forward();

      // 햅틱 피드백
      HapticFeedback.mediumImpact();

      // 콜백 호출
      widget.onCalculationComplete?.call(result);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isCalculating = false;
      });

      HapticFeedback.lightImpact();
    }
  }

  void _showRecipeSelector() {
    // TODO: 레시피 선택 다이얼로그 구현
    // 현재는 임시 레시피로 설정
    setState(() {
      _selectedRecipe = PracticalRecipe.sample();
      _originalCountController.text = _selectedRecipe!.originalYield.toString();
    });
  }
}
