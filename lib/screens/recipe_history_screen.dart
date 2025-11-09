import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/history.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../services/recipe_diff_service.dart';
import 'recipe_comparison_screen.dart';

class RecipeHistoryScreen extends StatefulWidget {
  final int recipeId;

  const RecipeHistoryScreen({
    Key? key,
    required this.recipeId,
  }) : super(key: key);

  @override
  State<RecipeHistoryScreen> createState() => _RecipeHistoryScreenState();
}

class _RecipeHistoryScreenState extends State<RecipeHistoryScreen> {
  List<History> _histories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<RecipeProvider>(context, listen: false);
      await provider.loadHistory(widget.recipeId);
      setState(() {
        _histories = provider.history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('히스토리 로드 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('레시피 수정 히스토리'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
            tooltip: '새로고침',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _histories.isEmpty
              ? _buildEmptyState()
              : _buildHistoryList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '수정 히스토리가 없습니다',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '레시피를 수정하면 변경사항이 여기에 기록됩니다',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _histories.length,
        itemBuilder: (context, index) {
          final history = _histories[index];
          final isFirst = index == 0;
          final isLast = index == _histories.length - 1;

          return _buildHistoryItem(history, isFirst, isLast);
        },
      ),
    );
  }

  Widget _buildHistoryItem(History history, bool isFirst, bool isLast) {
    final dateTime = DateTime.parse(history.modifiedDate);
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    final formattedTime = DateFormat('HH:mm').format(dateTime);

    // 변경사항 상세 분석
    final detailedChanges = _analyzeHistoryChanges(history);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타임라인 선과 점
          SizedBox(
            width: 60,
            child: Column(
              children: [
                // 날짜 표시 (첫 번째 항목만)
                if (isFirst) ...[
                  Text(
                    DateFormat('MM/dd').format(dateTime),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                ] else ...[
                  const SizedBox(height: 20),
                ],

                // 타임라인 점
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),

                // 타임라인 선 (마지막 항목이 아닐 때만)
                if (!isLast) ...[
                  Container(
                    width: 2,
                    height: 40,
                    color: Colors.blue.shade200,
                  ),
                ],
              ],
            ),
          ),

          // 히스토리 내용
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => _showHistoryDetail(history, detailedChanges),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 시간 표시
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedTime,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // 변경사항 요약
                      Text(
                        detailedChanges['summary'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 변경사항 개수 표시
                      _buildChangeCountBadges(detailedChanges),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeCountBadges(Map<String, dynamic> detailedChanges) {
    final badges = <Widget>[];

    final changeCounts = detailedChanges['changeCounts'] as Map<String, int>;

    if (changeCounts['basicInfo']! > 0) {
      badges.add(_buildBadge('기본정보', changeCounts['basicInfo']!, Colors.blue));
    }
    if (changeCounts['ingredients']! > 0) {
      badges.add(_buildBadge('재료', changeCounts['ingredients']!, Colors.green));
    }
    if (changeCounts['instructions']! > 0) {
      badges.add(
          _buildBadge('조리법', changeCounts['instructions']!, Colors.orange));
    }
    if (changeCounts['mixingSteps']! > 0) {
      badges
          .add(_buildBadge('믹싱', changeCounts['mixingSteps']!, Colors.purple));
    }
    if (changeCounts['fermentationSteps']! > 0) {
      badges.add(
          _buildBadge('발효', changeCounts['fermentationSteps']!, Colors.teal));
    }
    if (changeCounts['ovenSteps']! > 0) {
      badges.add(_buildBadge('오븐', changeCounts['ovenSteps']!, Colors.red));
    }

    if (badges.isEmpty) {
      return Text(
        '변경사항 없음',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade500,
        ),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: badges,
    );
  }

  Widget _buildBadge(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label ${count}개',
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Map<String, dynamic> _analyzeHistoryChanges(History history) {
    final result = <String, dynamic>{
      'summary': history.changes,
      'detailedChanges': <String, dynamic>{},
      'changeCounts': <String, int>{
        'basicInfo': 0,
        'ingredients': 0,
        'instructions': 0,
        'mixingSteps': 0,
        'fermentationSteps': 0,
        'ovenSteps': 0,
      },
    };

    // recipeState가 있는 경우 상세 비교 수행
    if (history.recipeState != null) {
      try {
        final oldRecipeJson = history.recipeState! as String;
        final oldRecipeMap = jsonDecode(oldRecipeJson) as Map<String, dynamic>;
        final oldRecipe = Recipe.fromJson(oldRecipeMap);

        // 현재 레시피 가져오기 (비교용)
        final provider = Provider.of<RecipeProvider>(context, listen: false);
        final currentRecipe = provider.recipes.firstWhere(
          (recipe) => recipe.id == widget.recipeId,
          orElse: () => oldRecipe, // 찾지 못하면 oldRecipe 사용
        );

        final diffResult =
            RecipeDiffService.compareRecipes(oldRecipe, currentRecipe);
        final summary = RecipeDiffService.summarizeChanges(diffResult);

        result['summary'] = summary.isNotEmpty ? summary : history.changes;
        result['detailedChanges'] = diffResult;

        // 변경사항 개수 계산
        final changeCounts = result['changeCounts'] as Map<String, int>;
        changeCounts['basicInfo'] = (diffResult['basicInfo'] as List).length;
        changeCounts['ingredients'] =
            (diffResult['ingredients'] as List).length;
        changeCounts['instructions'] =
            (diffResult['instructions'] as List).length;
        changeCounts['mixingSteps'] =
            (diffResult['mixingSteps'] as List).length;
        changeCounts['fermentationSteps'] =
            (diffResult['fermentationSteps'] as List).length;
        changeCounts['ovenSteps'] = (diffResult['ovenSteps'] as List).length;
      } catch (e) {
        print('히스토리 변경사항 분석 중 오류: $e');
        // 오류 발생 시 기본값 유지
      }
    }

    return result;
  }

  void _showHistoryDetail(
      History history, Map<String, dynamic> detailedChanges) {
    // 나란히 비교 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeComparisonScreen(
          history: history,
          recipeId: widget.recipeId,
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
