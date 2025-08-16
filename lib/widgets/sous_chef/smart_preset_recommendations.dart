import 'package:flutter/material.dart';
import '../../models/recipe.dart';
import '../../models/favorite_preset.dart';
import '../../services/smart_preset_recommender.dart';
import '../../services/favorite_preset_service.dart';

class SmartPresetRecommendations extends StatefulWidget {
  final Recipe recipe;
  final List<Map<String, dynamic>> calculatedIngredients;
  final Function(FavoritePreset) onPresetSelected;

  const SmartPresetRecommendations({
    super.key,
    required this.recipe,
    required this.calculatedIngredients,
    required this.onPresetSelected,
  });

  @override
  State<SmartPresetRecommendations> createState() => _SmartPresetRecommendationsState();
}

class _SmartPresetRecommendationsState extends State<SmartPresetRecommendations> {
  List<PresetRecommendation> _recommendations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final recommendations = await SmartPresetRecommender.instance.getRecommendationsForRecipe(
        widget.recipe,
        widget.calculatedIngredients,
      );

      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF9C27B0),
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'AI 스마트 프리셋 추천',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_isLoading) ...[
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('AI가 최적의 프리셋을 분석 중입니다...'),
                  ],
                ),
              ),
            ] else if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEF5350)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Color(0xFFE53935)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '추천을 불러오는 중 오류가 발생했습니다: $_error',
                        style: const TextStyle(color: Color(0xFFD32F2F)),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_recommendations.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBDBDBD)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: Color(0xFF757575)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('현재 레시피에 적합한 프리셋을 찾을 수 없습니다.'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ...(_recommendations.take(3).map((recommendation) => 
                _buildRecommendationCard(recommendation)
              )),
              
              const SizedBox(height: 12),
              
              Center(
                child: TextButton.icon(
                  onPressed: _loadRecommendations,
                  icon: const Icon(Icons.refresh),
                  label: const Text('추천 새로고침'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(PresetRecommendation recommendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _selectPreset(recommendation.preset),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getScoreColor(recommendation.score).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getScoreColor(recommendation.score).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: _getScoreColor(recommendation.score),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(recommendation.score * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getScoreColor(recommendation.score),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    Expanded(
                      child: Text(
                        recommendation.preset.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                Text(
                  recommendation.preset.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 8),
                
                if (recommendation.reason.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: recommendation.reason.split(', ').take(3).map((reason) => 
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          reason,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                      ),
                    ).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) return const Color(0xFF4CAF50);
    if (score >= 0.6) return const Color(0xFFFF9800);
    return const Color(0xFF757575);
  }

  void _selectPreset(FavoritePreset preset) async {
    await FavoritePresetService.instance.updateFavoriteUsage(preset.id);
    widget.onPresetSelected(preset);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${preset.name} 프리셋이 적용되었습니다'),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}