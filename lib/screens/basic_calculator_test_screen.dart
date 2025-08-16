import 'package:flutter/material.dart';
import '../widgets/practical_calculator/basic_division_calculator.dart';
import '../models/practical_recipe.dart';
import '../services/division_calculation_engine.dart';

/// 기본 분할 계산기 테스트 화면
/// 개발 중 위젯을 테스트하기 위한 임시 화면
class BasicCalculatorTestScreen extends StatefulWidget {
  const BasicCalculatorTestScreen({Key? key}) : super(key: key);

  @override
  State<BasicCalculatorTestScreen> createState() =>
      _BasicCalculatorTestScreenState();
}

class _BasicCalculatorTestScreenState extends State<BasicCalculatorTestScreen> {
  DivisionResult? _lastResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('기본 분할 계산기 테스트'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 헤더 섹션
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue,
                    Colors.blue[300]!,
                  ],
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.calculate,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '실용적 레시피 계산기',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '드래그 앤 드롭으로 원하는 기능을 추가하세요',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // 기본 분할 계산기
            BasicDivisionCalculator(
              initialRecipe: PracticalRecipe.sample(),
              onCalculationComplete: (result) {
                setState(() {
                  _lastResult = result;
                });
                _showResultDialog(result);
              },
            ),

            // 추가 정보 섹션
            if (_lastResult != null) ...[
              _buildResultSummary(),
              _buildOptimalSuggestions(),
            ],

            // 기능 미리보기 섹션
            _buildFeaturePreview(),

            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showFeatureCustomization,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.tune),
        label: const Text('기능 설정'),
      ),
    );
  }

  Widget _buildResultSummary() {
    if (_lastResult == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                    Icons.analytics,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  '계산 결과 분석',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAnalysisRow(
              '총 무게',
              '${_lastResult!.totalWeight.toStringAsFixed(1)}g',
              Icons.scale,
            ),
            _buildAnalysisRow(
              '개당 무게',
              '${_lastResult!.weightPerPiece.toStringAsFixed(1)}g',
              Icons.pie_chart,
            ),
            _buildAnalysisRow(
              '비용 효율성',
              '${_lastResult!.costEfficiencyScore.toStringAsFixed(1)}점',
              Icons.trending_up,
            ),
            if (_lastResult!.suggestions.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                '💡 제안사항',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ..._lastResult!.suggestions.map((suggestion) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text(suggestion)),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimalSuggestions() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lightbulb,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  '최적 분할 제안',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<OptimalDivisionSuggestion>>(
              future: _getOptimalSuggestions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Text('오류: ${snapshot.error}');
                }

                final suggestions = snapshot.data ?? [];
                if (suggestions.isEmpty) {
                  return const Text('제안할 분할 방법이 없습니다.');
                }

                return Column(
                  children: suggestions.take(3).map((suggestion) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getGradeColor(suggestion.efficiencyGrade),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              suggestion.efficiencyGrade,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${suggestion.targetCount}개 (${suggestion.multiplier.toStringAsFixed(2)}배)',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '낭비 점수: ${suggestion.wasteScore.toStringAsFixed(1)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                _applyOptimalSuggestion(suggestion),
                            icon: const Icon(Icons.arrow_forward),
                            iconSize: 20,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturePreview() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎯 추가 가능한 기능들',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeaturePreviewItem(
              '배치 계산',
              '여러 제품을 동시에 생산할 때 필요한 재료 통합 계산',
              Icons.view_module,
              Colors.purple,
            ),
            _buildFeaturePreviewItem(
              '원가 계산',
              '재료비, 인건비, 간접비를 포함한 정확한 원가 분석',
              Icons.attach_money,
              Colors.teal,
            ),
            _buildFeaturePreviewItem(
              '성공률 추적',
              '베이킹 결과를 기록하고 실패 패턴을 분석',
              Icons.trending_up,
              Colors.pink,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showFeatureCustomization,
                icon: const Icon(Icons.add),
                label: const Text('기능 추가하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturePreviewItem(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.add_circle_outline,
            color: color,
            size: 20,
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.lightGreen;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.deepOrange;
      case 'F':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<List<OptimalDivisionSuggestion>> _getOptimalSuggestions() async {
    if (_lastResult == null) return [];

    return DivisionCalculationEngineExtension.suggestOptimalDivisions(
      originalRecipe: _lastResult!.originalRecipe,
      maxCount: _lastResult!.originalCount + 10,
    );
  }

  void _applyOptimalSuggestion(OptimalDivisionSuggestion suggestion) {
    // TODO: 제안된 분할을 적용하는 로직 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${suggestion.targetCount}개 분할을 적용했습니다'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showResultDialog(DivisionResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('계산 완료!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${result.originalCount}개 → ${result.targetCount}개',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('배율: ${result.scalingMultiplier.toStringAsFixed(2)}배'),
            Text('총 무게: ${result.totalWeight.toStringAsFixed(1)}g'),
            if (result.remainingIngredients.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                '남은 재료:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...result.remainingIngredients.entries.map((entry) {
                return Text(
                    '• ${entry.key}: ${entry.value.toStringAsFixed(1)}g');
              }).toList(),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showFeatureCustomization() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기능 커스터마이징'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('드래그 앤 드롭 기능 커스터마이징 화면이 여기에 표시됩니다.'),
            SizedBox(height: 16),
            Text('🚧 개발 중...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}
