import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../models/history.dart';
import '../models/ingredient.dart';
import '../providers/recipe_provider.dart';
import '../services/recipe_diff_service.dart';

/// 레시피 버전 비교 화면
/// 이전 버전과 현재 버전을 나란히 비교해서 보여줍니다.
class RecipeComparisonScreen extends StatefulWidget {
  final History history;
  final int recipeId;

  const RecipeComparisonScreen({
    Key? key,
    required this.history,
    required this.recipeId,
  }) : super(key: key);

  @override
  State<RecipeComparisonScreen> createState() => _RecipeComparisonScreenState();
}

class _RecipeComparisonScreenState extends State<RecipeComparisonScreen> {
  Recipe? _oldRecipe;
  Recipe? _currentRecipe;
  Map<String, dynamic>? _diffResult;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComparisonData();
  }

  Future<void> _loadComparisonData() async {
    setState(() => _isLoading = true);

    try {
      // 이전 레시피 로드
      if (widget.history.recipeState != null) {
        final oldRecipeJson = widget.history.recipeState! as String;
        final oldRecipeMap = jsonDecode(oldRecipeJson) as Map<String, dynamic>;
        _oldRecipe = Recipe.fromJson(oldRecipeMap);
      }

      // 현재 레시피 로드
      final provider = Provider.of<RecipeProvider>(context, listen: false);
      _currentRecipe = await provider.getRecipeById(widget.recipeId);

      // 변경사항 분석
      if (_oldRecipe != null && _currentRecipe != null) {
        _diffResult =
            RecipeDiffService.compareRecipes(_oldRecipe!, _currentRecipe!);
      }
    } catch (e) {
      print('비교 데이터 로드 중 오류: $e');
    } finally {
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_oldRecipe == null || _currentRecipe == null) {
  }

  Widget _buildComparisonView() {
    final dateTime = DateTime.parse(widget.history.modifiedDate);
    final formattedDateTime =
        DateFormat('yyyy년 MM월 dd일 HH:mm').format(dateTime);

    return Column(
      children: [
        // 헤더 정보
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Column(
            children: [
              Text(
                '수정 일시: $formattedDateTime',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildVersionHeader('이전 버전', Colors.grey.shade600),
                  ),
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.compare_arrows,
                      color: Colors.blue.shade600,
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: _buildVersionHeader('현재 버전', Colors.blue.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 비교 내용
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 비교
                  _buildTitleComparison(),

                  const SizedBox(height: 24),

                  // 재료 비교
                  _buildIngredientsComparison(),

                  const SizedBox(height: 24),

                  // 조리법 비교
                  _buildInstructionsComparison(),

                  // 베이킹 단계 비교 (베이킹 레시피인 경우)
                  if (_currentRecipe!.isBaking) ...[
                    const SizedBox(height: 24),
                    _buildBakingStepsComparison(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVersionHeader(String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTitleComparison() {
    final oldTitle = _oldRecipe!.title;
    final newTitle = _currentRecipe!.title;
    final isChanged = oldTitle != newTitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('🍞 레시피 제목'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildComparisonItem(
                oldTitle,
                isChanged && oldTitle != newTitle
                    ? ChangeType.modified
                    : ChangeType.unchanged,
                showLabel: false,
              ),
            ),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Icon(
                isChanged ? Icons.arrow_forward : Icons.check_circle,
                color: isChanged ? Colors.orange : Colors.green,
                size: 20,
              ),
            ),
            Expanded(
              child: _buildComparisonItem(
                newTitle,
                isChanged && oldTitle != newTitle
                    ? ChangeType.modified
                    : ChangeType.unchanged,
                showLabel: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIngredientsComparison() {
    final oldIngredients = _oldRecipe!.ingredients;
    final newIngredients = _currentRecipe!.ingredients;

    // 재료명을 키로 하는 맵 생성
    final oldMap = {for (var ing in oldIngredients) ing.name: ing};
    final newMap = {for (var ing in newIngredients) ing.name: ing};

    // 모든 재료명 수집 (중복 제거)
    final allNames = {...oldMap.keys, ...newMap.keys}.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('🥕 재료 목록'),
        const SizedBox(height: 12),
        ...allNames.map((name) {
          final oldIng = oldMap[name];
          final newIng = newMap[name];

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildIngredientItem(
                      oldIng, _getIngredientChangeType(oldIng, newIng, true)),
                ),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: _getChangeIcon(
                      _getIngredientChangeType(oldIng, newIng, false)),
                ),
                Expanded(
                  child: _buildIngredientItem(
                      newIng, _getIngredientChangeType(oldIng, newIng, false)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildIngredientItem(Ingredient? ingredient, ChangeType changeType) {
    if (ingredient == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '(없음)',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getChangeColor(changeType).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getChangeColor(changeType).withOpacity(0.3),
          width: changeType != ChangeType.unchanged ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ingredient.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: changeType == ChangeType.deleted
                  ? Colors.grey.shade600
                  : Colors.black87,
              decoration: changeType == ChangeType.deleted
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${ingredient.amount}${ingredient.unit}',
            style: TextStyle(
              fontSize: 12,
              color: changeType == ChangeType.deleted
                  ? Colors.grey.shade500
                  : Colors.grey.shade700,
              decoration: changeType == ChangeType.deleted
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsComparison() {
    final oldInstructions = _oldRecipe!.instructions;
    final newInstructions = _currentRecipe!.instructions;

    final maxLength = oldInstructions.length > newInstructions.length
        ? oldInstructions.length
        : newInstructions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('👨‍🍳 조리법'),
        const SizedBox(height: 12),
        ...List.generate(maxLength, (index) {
          final oldStep = index < oldInstructions.length
              ? oldInstructions[index]['description'] as String?
              : null;
          final newStep = index < newInstructions.length
              ? newInstructions[index]['description'] as String?
              : null;

          final changeType = _getStepChangeType(oldStep, newStep);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  alignment: Alignment.topCenter,
                  child: Text(
                    '${index + 1}.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildComparisonItem(
                    oldStep ?? '(없음)',
                    changeType,
                    showLabel: false,
                  ),
                ),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: _getChangeIcon(changeType),
                ),
                Expanded(
                  child: _buildComparisonItem(
                    newStep ?? '(없음)',
                    changeType,
                    showLabel: false,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBakingStepsComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('🔥 베이킹 단계'),
        const SizedBox(height: 12),

        // 믹싱 단계
        _buildBakingStepSection(
            '믹싱 단계', _oldRecipe!.mixingSteps, _currentRecipe!.mixingSteps),

        const SizedBox(height: 16),

        // 발효 단계
        _buildBakingStepSection('발효 단계', _oldRecipe!.fermentationSteps,
            _currentRecipe!.fermentationSteps),

        const SizedBox(height: 16),

        // 오븐 단계
        _buildBakingStepSection(
            '오븐 단계', _oldRecipe!.ovenSteps, _currentRecipe!.ovenSteps),
      ],
    );
  }

  Widget _buildBakingStepSection(
      String title,
      List<Map<String, dynamic>>? oldSteps,
      List<Map<String, dynamic>>? newSteps) {
    final oldList = oldSteps ?? [];
    final newList = newSteps ?? [];

    final maxLength =
        oldList.length > newList.length ? oldList.length : newList.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        ...List.generate(maxLength, (index) {
          final oldStep = index < oldList.length ? oldList[index] : null;
          final newStep = index < newList.length ? newList[index] : null;

          final changeType = _getBakingStepChangeType(oldStep, newStep);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildBakingStepItem(oldStep, changeType),
                ),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: _getChangeIcon(changeType),
                ),
                Expanded(
                  child: _buildBakingStepItem(newStep, changeType),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBakingStepItem(
      Map<String, dynamic>? step, ChangeType changeType) {
    if (step == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '(없음)',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      );
    }

    final description = step['description'] ?? '설명 없음';
    final time = step['time'];
    final temperature = step['temperature'];
    final humidity = step['humidity'];
    final speed = step['speed'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getChangeColor(changeType).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getChangeColor(changeType).withOpacity(0.3),
          width: changeType != ChangeType.unchanged ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: changeType == ChangeType.deleted
                  ? Colors.grey.shade600
                  : Colors.black87,
              decoration: changeType == ChangeType.deleted
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
          if (time != null ||
              temperature != null ||
              humidity != null ||
              speed != null) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (speed != null) _buildTag('속도: $speed', Colors.blue),
                if (time != null) _buildTag('시간: $time', Colors.grey),
                if (temperature != null)
                  _buildTag('${temperature}°C', Colors.orange),
                if (humidity != null) _buildTag('${humidity}%', Colors.teal),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildComparisonItem(String text, ChangeType changeType,
      {bool showLabel = true}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getChangeColor(changeType).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getChangeColor(changeType).withOpacity(0.3),
          width: changeType != ChangeType.unchanged ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLabel) ...[
            Row(
              children: [
                Icon(
                  _getChangeIconData(changeType),
                  size: 16,
                  color: _getChangeColor(changeType),
                ),
                const SizedBox(width: 4),
                Text(
                  _getChangeTypeText(changeType),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getChangeColor(changeType),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: changeType == ChangeType.deleted
                  ? Colors.grey.shade600
                  : Colors.black87,
              decoration: changeType == ChangeType.deleted
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  // 변경 타입 관련 헬퍼 메소드들
  ChangeType _getIngredientChangeType(
      Ingredient? oldIng, Ingredient? newIng, bool isOld) {
    if (isOld) {
      if (oldIng == null) return ChangeType.added;
      if (newIng == null) return ChangeType.deleted;
      if (oldIng.amount != newIng.amount || oldIng.unit != newIng.unit)
        return ChangeType.modified;
      return ChangeType.unchanged;
    } else {
      if (newIng == null) return ChangeType.deleted;
      if (oldIng == null) return ChangeType.added;
      if (oldIng.amount != newIng.amount || oldIng.unit != newIng.unit)
        return ChangeType.modified;
      return ChangeType.unchanged;
    }
  }

  ChangeType _getStepChangeType(String? oldStep, String? newStep) {
    if (oldStep == null && newStep != null) return ChangeType.added;
    if (oldStep != null && newStep == null) return ChangeType.deleted;
    if (oldStep != newStep) return ChangeType.modified;
    return ChangeType.unchanged;
  }

  ChangeType _getBakingStepChangeType(
      Map<String, dynamic>? oldStep, Map<String, dynamic>? newStep) {
    if (oldStep == null && newStep != null) return ChangeType.added;
    if (oldStep != null && newStep == null) return ChangeType.deleted;
    if (oldStep != null && newStep != null) {
      // 주요 필드 비교
      final fields = [
        'description',
        'time',
        'temperature',
        'humidity',
        'speed'
      ];
      for (final field in fields) {
        if (oldStep[field] != newStep[field]) return ChangeType.modified;
      }
    }
    return ChangeType.unchanged;
  }

  Color _getChangeColor(ChangeType type) {
    switch (type) {
      case ChangeType.added:
        return Colors.green;
      case ChangeType.deleted:
        return Colors.red;
      case ChangeType.modified:
        return Colors.orange;
      case ChangeType.unchanged:
        return Colors.grey;
    }
  }

  IconData _getChangeIconData(ChangeType type) {
    switch (type) {
      case ChangeType.added:
        return Icons.add_circle;
      case ChangeType.deleted:
        return Icons.remove_circle;
      case ChangeType.modified:
        return Icons.edit;
      case ChangeType.unchanged:
        return Icons.check_circle;
    }
  }

  Widget _getChangeIcon(ChangeType type) {
    return Icon(
      _getChangeIconData(type),
      color: _getChangeColor(type),
      size: 20,
    );
  }

  String _getChangeTypeText(ChangeType type) {
    switch (type) {
      case ChangeType.added:
        return '추가';
      case ChangeType.deleted:
        return '삭제';
      case ChangeType.modified:
        return '수정';
      case ChangeType.unchanged:
        return '변경없음';
    }
  }
}

/// 변경 타입 열거형
enum ChangeType {
  added, // 추가됨
  deleted, // 삭제됨
  modified, // 수정됨
  unchanged // 변경없음
}
