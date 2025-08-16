import 'package:flutter/material.dart';
import '../models/practical_recipe.dart';
import '../widgets/practical_calculator/practical_division_calculator.dart';

/// 기본 계산기 테스트 화면 (간단 버전)
class BasicCalculatorTestScreen extends StatefulWidget {
  const BasicCalculatorTestScreen({super.key});

  @override
  State<BasicCalculatorTestScreen> createState() =>
      _BasicCalculatorTestScreenState();
}

class _BasicCalculatorTestScreenState extends State<BasicCalculatorTestScreen> {
  late PracticalRecipe _testRecipe;
  DivisionResult? _lastResult;

  @override
  void initState() {
    super.initState();
    try {
      _testRecipe = PracticalRecipe.sample();
    } catch (e) {
      // 샘플 레시피 생성 실패시 기본값 사용
      _testRecipe = PracticalRecipe(
        recipe: _createBasicRecipe(),
        originalYield: 1,
        originalTotalWeight: 100.0,
      );
    }
  }

  Recipe _createBasicRecipe() {
    return Recipe(
      title: '기본 레시피',
      category: '테스트',
      baseServings: 1,
      isBaking: false,
      ingredients: [
        {'name': '재료1', 'amount': 100.0, 'unit': 'g'},
      ],
      instructions: [
        {'step': 1, 'description': '기본 단계'},
          ],
          totalIngredientWeight: 100.0,
        ),
      );
    }
  }

  void _onCalculationComplete(DivisionResult result) {
    setState(() {
      _lastResult = result;
    });

    // 결과를 스낵바로 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '계산 완료: ${result.originalCount}개 → ${result.targetCount}개 (${result.scalingMultiplier.toStringAsFixed(2)}배)',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('실용적 레시피 계산기 테스트'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 간단한 분할 계산기
            PracticalDivisionCalculator(
              initialRecipe: _testRecipe,
              onCalculationComplete: _onCalculationComplete,
            ),

            // 계산 결과 상세 정보
            if (_lastResult != null) ...[
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '상세 계산 결과',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _buildResultRow(
                          '원래 개수', '${_lastResult?.originalCount ?? 0}개'),
                      _buildResultRow('목표 개수', '${_lastResult?.targetCount ?? 0}개'),
                      _buildResultRow('배율',
                          '${(_lastResult?.scalingMultiplier ?? 0.0).toStringAsFixed(2)}배'),
                      _buildResultRow('총 무게',
                          '${(_lastResult?.totalWeight ?? 0.0).toStringAsFixed(1)}g'),
                      _buildResultRow('개당 무게',
                          '${(_lastResult?.weightPerPiece ?? 0.0).toStringAsFixed(1)}g'),
                      _buildResultRow('계산 방식', _lastResult?.calculationType ?? '알 수 없음'),
                      _buildResultRow(
                          '계산 시간',
                          _lastResult?.calculatedAt
                              .toString()
                              .substring(0, 19) ?? '알 수 없음'),
                    ],
                  ),
                ),
              ),
            ],

            // 사용법 안내
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          '사용법',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildUsageStep('1', '현재 레시피의 원래 개수를 확인하세요'),
                    _buildUsageStep('2', '만들고 싶은 목표 개수를 입력하세요'),
                    _buildUsageStep('3', '계산 버튼을 누르거나 엔터를 치세요'),
                    _buildUsageStep('4', '조정된 재료량을 확인하세요'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline,
                              color: Colors.amber.shade700, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '팁: "5개 나오는 레시피를 6개로 만들고 싶어요" 같은 상황에 딱 맞는 계산기입니다!',
                              style: TextStyle(
                                color: Colors.amber.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade700),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageStep(String number, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
