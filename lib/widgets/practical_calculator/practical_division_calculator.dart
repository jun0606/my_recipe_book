import 'package:flutter/material.dart';
import '../../models/practical_recipe.dart';
import '../../services/division_calculation_engine.dart';

/// 실용적 분할 계산기 위젯
/// "5개 → 6개" 스타일의 직관적인 계산 인터페이스
class PracticalDivisionCalculator extends StatefulWidget {
  final PracticalRecipe initialRecipe;
  final Function(DivisionResult)? onCalculationComplete;

  const PracticalDivisionCalculator({
    super.key,
    required this.initialRecipe,
    this.onCalculationComplete,
  });

  @override
  State<PracticalDivisionCalculator> createState() => _PracticalDivisionCalculatorState();
}

class _PracticalDivisionCalculatorState extends State<PracticalDivisionCalculator> {
  late PracticalRecipe _currentRecipe;
  final TextEditingController _targetCountController = TextEditingController();
  DivisionResult? _lastResult;
  bool _isCalculating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentRecipe = widget.initialRecipe;
    _targetCountController.text = (_currentRecipe.originalYield).toString();
  }

  @override
  void dispose() {
    _targetCountController.dispose();
    super.dispose();
  }

  /// 분할 계산 실행
  Future<void> _performCalculation() async {
    final targetCountText = _targetCountController.text.trim();
    if (targetCountText.isEmpty) {
      setState(() {
        _errorMessage = '목표 개수를 입력해주세요';
      });
      return;
    }

    final targetCount = int.tryParse(targetCountText);
    if (targetCount == null || targetCount <= 0) {
      setState(() {
        _errorMessage = '올바른 개수를 입력해주세요 (1개 이상)';
      });
      return;
    }

    setState(() {
      _isCalculating = true;
      _errorMessage = null;
    });

    try {
      final result = await DivisionCalculationEngine.calculateDivision(
        originalRecipe: _currentRecipe,
        targetCount: targetCount,
      );

      setState(() {
        _lastResult = result;
        _isCalculating = false;
      });

      // 콜백 호출
      if (widget.onCalculationComplete != null) {
        widget.onCalculationComplete!(result);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isCalculating = false;
      });
    }
  }

  /// 레시피 초기화
  void _resetCalculation() {
    setState(() {
      _targetCountController.text = _currentRecipe.originalYield.toString();
      _lastResult = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                const Icon(Icons.calculate, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  '간단 분할 계산기',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 현재 레시피 정보
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '현재 레시피: ${_currentRecipe.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '원래 개수: ${_currentRecipe.originalYield}개',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  Text(
                    '총 무게: ${_currentRecipe.originalTotalWeight.toStringAsFixed(1)}g',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 계산 입력
            Row(
              children: [
                Text(
                  '${_currentRecipe.originalYield}개 →',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _targetCountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '목표 개수',
                      suffixText: '개',
                      border: const OutlineInputBorder(),
                      errorText: _errorMessage,
                    ),
                    onSubmitted: (_) => _performCalculation(),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isCalculating ? null : _performCalculation,
                  child: _isCalculating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('계산'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 계산 결과
            if (_lastResult != null) ...[
              Container(
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
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          '계산 완료!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_lastResult?.originalCount ?? 0}개 → ${_lastResult?.targetCount ?? 0}개',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text('배율: ${(_lastResult?.scalingMultiplier ?? 0.0).toStringAsFixed(2)}배'),
                    Text('총 무게: ${(_lastResult?.totalWeight ?? 0.0).toStringAsFixed(1)}g'),
                    Text('개당 무게: ${(_lastResult?.weightPerPiece ?? 0.0).toStringAsFixed(1)}g'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 조정된 재료 목록
              const Text(
                '조정된 재료',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...(_lastResult?.adjustedIngredients ?? []).map((ingredient) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(ingredient['name'] as String),
                      Text(
                        '${(ingredient['amount'] as double).toStringAsFixed(1)} ${ingredient['unit'] as String}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],

            // 초기화 버튼
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _resetCalculation,
                  child: const Text('초기화'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}