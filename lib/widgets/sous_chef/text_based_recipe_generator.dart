/// 텍스트 기반 역산 레시피 생성 위젯
/// 자연어 입력으로 원하는 특성의 레시피를 생성합니다.

import 'package:flutter/material.dart';
import '../../services/reverse_recipe_engine.dart';
import '../../services/recipe_preset_manager.dart';


class TextBasedRecipeGenerator extends StatefulWidget {
  final Function(ReverseRecipeResult) onRecipeGenerated;
  final Map<String, dynamic> environmentalConditions;

  const TextBasedRecipeGenerator({
    super.key,
    required this.onRecipeGenerated,
    required this.environmentalConditions,
  });

  @override
  State<TextBasedRecipeGenerator> createState() => _TextBasedRecipeGeneratorState();
}

class _TextBasedRecipeGeneratorState extends State<TextBasedRecipeGenerator> {
  final _textController = TextEditingController();
  final _flourWeightController = TextEditingController(text: '300');
  
  bool _isGenerating = false;
  List<RecipePreset> _recommendations = [];
  List<String> _suggestions = [];
  
  // 예시 텍스트들
  final List<String> _exampleTexts = [
    '촉촉하고 부드러운 식빵',
    '바삭한 크러스트의 하드브레드',
    '달콤하고 고소한 브리오슈',
    '쫄깃쫄깃한 우유식빵',
    '진한 갈색 크러스트의 통밀빵',
    '부드럽고 촉촉한 스펀지케이크',
    '바삭바삭한 버터쿠키',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _flourWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.purple.shade600),
                  const SizedBox(width: 8),
                  const Text(
                    '텍스트로 레시피 생성',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Text(
              '원하는 특성을 자연어로 설명하면 최적의 레시피를 생성해드립니다.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            
            // 텍스트 입력
            _buildTextInput(),
            const SizedBox(height: 16),
            
            // 예시 텍스트
            _buildExampleTexts(),
            const SizedBox(height: 16),
            
            // 추천 프리셋 (입력에 따라 동적으로 표시)
            if (_recommendations.isNotEmpty) ...[
              _buildRecommendations(),
              const SizedBox(height: 16),
            ],
            
            // 제안 사항
            if (_suggestions.isNotEmpty) ...[
              _buildSuggestions(),
              const SizedBox(height: 16),
            ],
            
            // 고급 설정
            _buildAdvancedSettings(),
            const SizedBox(height: 16),
            
            // 생성 버튼
            _buildGenerateButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// 텍스트 입력 필드
  Widget _buildTextInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '원하는 특성 설명',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _textController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '예: 촉촉하고 부드러운 식빵을 만들고 싶어요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: _textController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _textController.clear();
                      _updateRecommendations();
                    },
                  )
                : null,
          ),
          onChanged: (text) {
            _updateRecommendations();
          },
        ),
      ],
    );
  }

  /// 예시 텍스트
  Widget _buildExampleTexts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '예시',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _exampleTexts.map((example) {
            return ActionChip(
              label: Text(
                example,
                style: const TextStyle(fontSize: 12),
              ),
              onPressed: () {
                _textController.text = example;
                _updateRecommendations();
              },
              backgroundColor: Colors.grey.shade100,
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 추천 프리셋
  Widget _buildRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb, size: 16, color: Colors.amber.shade600),
            const SizedBox(width: 4),
            const Text(
              '추천 프리셋',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recommendations.length,
            itemBuilder: (context, index) {
              final preset = _recommendations[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 8),
                child: Card(
                  child: InkWell(
                    onTap: () => _usePreset(preset),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            preset.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            preset.description,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 12,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${preset.estimatedTime}분',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 제안 사항
  Widget _buildSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.tips_and_updates, size: 16, color: Colors.blue.shade600),
            const SizedBox(width: 4),
            const Text(
              '제안',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._suggestions.map((suggestion) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.arrow_right,
                  size: 16,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    suggestion,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// 고급 설정
  Widget _buildAdvancedSettings() {
    return ExpansionTile(
      title: const Text(
        '고급 설정',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 밀가루 무게 설정
              Row(
                children: [
                  const Expanded(
                    flex: 2,
                    child: Text(
                      '기준 밀가루 무게',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _flourWeightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        suffixText: 'g',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // 도움말
              Container(
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
                        Icon(Icons.info, size: 16, color: Colors.blue.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '도움말',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '• 밀가루 무게는 모든 재료량의 기준이 됩니다\n'
                      '• 300g은 약 6-8인분 식빵 기준입니다\n'
                      '• 더 많은 양이 필요하면 무게를 늘려주세요',
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 생성 버튼
  Widget _buildGenerateButton() {
    final hasText = _textController.text.trim().isNotEmpty;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: hasText && !_isGenerating ? _generateRecipe : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isGenerating
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
                  SizedBox(width: 8),
                  Text('레시피 생성 중...'),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome),
                  SizedBox(width: 8),
                  Text(
                    '레시피 생성하기',
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

  /// 추천 프리셋 업데이트
  void _updateRecommendations() {
    final text = _textController.text.trim();
    
    if (text.isEmpty) {
      setState(() {
        _recommendations = [];
        _suggestions = [];
      });
      return;
    }

    // 추천 프리셋 찾기
    final recommendations = RecipePresetManager.recommendPresets(text);
    
    // 제안 사항 생성
    final suggestions = _generateSuggestions(text);
    
    setState(() {
      _recommendations = recommendations.take(3).toList();
      _suggestions = suggestions;
    });
  }

  /// 제안 사항 생성
  List<String> _generateSuggestions(String text) {
    final suggestions = <String>[];
    
    if (text.length < 5) {
      suggestions.add('더 구체적인 설명을 입력해보세요. 예: "촉촉하고 부드러운 식빵"');
    }
    
    if (!text.contains(RegExp(r'촉촉|쫄깃|부드러|바삭|달콤|고소'))) {
      suggestions.add('원하는 식감이나 맛을 추가해보세요. 예: 촉촉한, 쫄깃한, 바삭한');
    }
    
    if (!text.contains(RegExp(r'식빵|케이크|쿠키|빵|브리오슈'))) {
      suggestions.add('베이킹 타입을 명시해보세요. 예: 식빵, 케이크, 쿠키');
    }
    
    if (suggestions.isEmpty) {
      suggestions.add('훌륭한 설명입니다! 레시피를 생성해보세요.');
    }
    
    return suggestions;
  }

  /// 프리셋 사용
  void _usePreset(RecipePreset preset) async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final flourWeight = double.tryParse(_flourWeightController.text) ?? 300.0;
      
      final result = await ReverseRecipeEngine.generateFromPreset(
        presetId: preset.id,
        environmentalConditions: widget.environmentalConditions,
        baseFlourWeight: flourWeight,
      );

      widget.onRecipeGenerated(result);
    } catch (e) {
      _showErrorDialog('프리셋 기반 레시피 생성 중 오류가 발생했습니다: $e');
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  /// 레시피 생성
  void _generateRecipe() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      final flourWeight = double.tryParse(_flourWeightController.text) ?? 300.0;
      
      final result = await ReverseRecipeEngine.generateFromText(
        targetDescription: text,
        environmentalConditions: widget.environmentalConditions,
        baseFlourWeight: flourWeight,
      );

      widget.onRecipeGenerated(result);
    } catch (e) {
      _showErrorDialog('텍스트 기반 레시피 생성 중 오류가 발생했습니다: $e');
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  /// 오류 다이얼로그 표시
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

/// 생성된 레시피 결과 표시 위젯
class GeneratedRecipeResultWidget extends StatelessWidget {
  final ReverseRecipeResult result;
  final VoidCallback? onApply;
  final VoidCallback? onRegenerate;

  const GeneratedRecipeResultWidget({
    super.key,
    required this.result,
    this.onApply,
    this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600),
                const SizedBox(width: 8),
                const Text(
                  '생성된 레시피',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '달성도: ${(result.achievementScore * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    color: result.achievementScore >= 0.8 
                        ? Colors.green.shade600 
                        : Colors.orange.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 재료 목록
            _buildIngredientsList(),
            const SizedBox(height: 16),
            
            // 베이커스 퍼센트
            _buildBakersPercentages(),
            const SizedBox(height: 16),
            
            // 예상 특성
            _buildPredictedStatus(),
            const SizedBox(height: 16),
            
            // 최적화 노트
            _buildOptimizationNotes(),
            const SizedBox(height: 16),
            
            // 액션 버튼
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  /// 재료 목록
  Widget _buildIngredientsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '재료',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ...result.generatedIngredients.map((ingredient) {
          final name = ingredient['name'] as String;
          final amount = ingredient['amount'] as double;
          final unit = ingredient['unit'] as String;
          final percentage = ingredient['bakersPercentage'] as double;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(name),
                ),
                Expanded(
                  child: Text(
                    '${amount.toStringAsFixed(1)}$unit',
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  child: Text(
                    '(${percentage.toStringAsFixed(1)}%)',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// 베이커스 퍼센트
  Widget _buildBakersPercentages() {
    return ExpansionTile(
      title: const Text(
        '베이커스 퍼센트',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: result.bakersPercentages.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    Expanded(child: Text(entry.key)),
                    Text('${entry.value.toStringAsFixed(1)}%'),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// 예상 특성
  Widget _buildPredictedStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '예상 특성',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('식감: ${result.predictedStatus.textureProfile.primary}'),
              Text('풍미: ${result.predictedStatus.flavorProfile.primary.join(', ')}'),
              Text('외관: ${result.predictedStatus.appearanceProfile.crustColor} 크러스트'),
            ],
          ),
        ),
      ],
    );
  }

  /// 최적화 노트
  Widget _buildOptimizationNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '최적화 노트',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ...result.optimizationNotes.map((note) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text(note, style: const TextStyle(fontSize: 14))),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// 액션 버튼
  Widget _buildActionButtons() {
    return Row(
      children: [
        if (onRegenerate != null)
          Expanded(
            child: OutlinedButton(
              onPressed: onRegenerate,
              child: const Text('다시 생성'),
            ),
          ),
        if (onRegenerate != null && onApply != null)
          const SizedBox(width: 8),
        if (onApply != null)
          Expanded(
            child: ElevatedButton(
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('레시피에 적용'),
            ),
          ),
      ],
    );
  }
}