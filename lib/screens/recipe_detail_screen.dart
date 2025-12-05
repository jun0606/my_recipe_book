import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/recipe.dart';
import '../models/ingredient.dart';
import '../providers/recipe_provider.dart';
import '../services/recipe_history_service.dart';
import '../models/recipe_history.dart';

import '../../features/chef/widget/recipe_detail/ingredient_card_simple.dart';
import '../../features/chef/widget/recipe_detail/instruction_step_simple.dart';
import '../../features/chef/widget/recipe_detail/recipe_scaler.dart';
// import '../widgets/recipe_detail/servings_calculator.dart'; // 임시 비활성화
// import '../widgets/recipe_detail/recipe_actions_menu.dart'; // 임시 비활성화
import '../screens/add_recipe_screen.dart';
import '../screens/recipe_history_screen.dart';
import '../screens/special/tree/screen/recipe_tree_screen.dart';
import '../../features/chef/screen/sous_chef_mode_screen.dart';
import '../utils/unit_converter.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({
    Key? key,
    required this.recipe,
  }) : super(key: key);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  // Scaffold 접근용 GlobalKey
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Recipe _currentRecipe;
  List<Ingredient> _calculatedIngredients = [];
  final RecipeHistoryService _historyService = RecipeHistoryService.instance;

  // 계산기 관련 상태
  double _servingMultiplier = 1.0;
  bool _showBakingCalculator = false;

  // 가이드 관련 상태
  bool _isGuideActive = false;

  // 재료 가이드 포커싱 관련 상태
  int _currentIngredientIndex = 0;
  Set<int> _completedIngredients = {};

  // 자동 스크롤 관련
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _ingredientKeys = {};

  // 분할 계산 관련 상태
  final TextEditingController _splitAmountController = TextEditingController();
  final TextEditingController _splitCountController = TextEditingController();
  bool _isAmountBased = true;

  @override
  void initState() {
    super.initState();
    _currentRecipe = widget.recipe;
    _calculatedIngredients = List.from(_currentRecipe.ingredients);

    // 재료 Key 초기화
    for (int i = 0; i < _currentRecipe.ingredients.length; i++) {
      _ingredientKeys[i] = GlobalKey();
    }

    // 초기값 설정
    _splitAmountController.text =
        _currentRecipe.targetSplitAmount?.toString() ?? '';
    _splitCountController.text =
        _currentRecipe.targetSplitCount?.toString() ?? '1';
    _showBakingCalculator = _currentRecipe.isBaking;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _splitAmountController.dispose();
    _splitCountController.dispose();

    super.dispose();
  }

  void _updateServings(double multiplier) {
    setState(() {
      _servingMultiplier = multiplier;
      _calculatedIngredients = _currentRecipe.ingredients.map((ingredient) {
        return Ingredient(
          id: ingredient.id,
          name: ingredient.name,
          amount: ingredient.amount * multiplier,
          unit: ingredient.unit,
        );
      }).toList();
    });
  }

  void _showRecipeHistory() {
    // 레시피 히스토리 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeHistoryScreen(recipeId: _currentRecipe.id!),
      ),
    );
  }

  void _showRecipeTree() {
    // 레시피 파생도 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeTreeScreen(initialRecipe: _currentRecipe),
      ),
    );
  }

  void _showSousChefMode() async {
    try {
      // 수쉐프 모드로 이동
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SousChefModeScreen(
            recipeData: _currentRecipe.toJson(),
          ),
        ),
      );
    } catch (e) {
      print('수쉐프 모드 실행 중 오류: $e');
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.sousChefModeError(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editRecipe() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRecipeScreen(
          recipe: _currentRecipe,
        ),
      ),
    ).then((result) {
      if (result != null && result is Recipe) {
        setState(() {
          _currentRecipe = result;
          _calculatedIngredients = List.from(_currentRecipe.ingredients);
        });
      }
    });
  }

  void _copyRecipe() {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.copyRecipeMethodTitle),
          content: Text(l10n.copyRecipeMethodContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddRecipeScreen(
                      recipe: _currentRecipe,
                      isCopy: true,
                      isDerivedCopy: false,
                    ),
                  ),
                );
              },
              child: Text(l10n.simpleCopy),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddRecipeScreen(
                      recipe: _currentRecipe,
                      isCopy: false,
                      isDerivedCopy: true,
                    ),
                  ),
                );
              },
              child: Text(l10n.derivedRecipe),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteRecipe() {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.deleteRecipeTitle),
          content: Text(l10n.deleteRecipeContent(_currentRecipe.title)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await Provider.of<RecipeProvider>(context, listen: false)
                      .deleteRecipe(_currentRecipe.id!);
                  Navigator.pop(context); // 다이얼로그 닫기
                  Navigator.pop(context); // 상세 페이지 닫기
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(l10n.recipeDeleted),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.deleteFailed(e.toString())),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(l10n.delete, style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _saveRecipeToHistory() async {
    // 복잡한 RecipeHistory 모델 대신 간단하게만 저장 가능하도록 구현
    // 현재는 시뮬레이션으로 처리
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.recipeSaveNotReady),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildIngredientsList() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 인분 계산기 (일반 레시피인 경우에만)
        if (!_currentRecipe.isBaking) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Text(l10n.baseServings),
                Text(
                  '${_currentRecipe.baseServings}인분',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(l10n.multiplier),
                Text(
                  '${_servingMultiplier.toStringAsFixed(1)}배',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    if (_servingMultiplier > 0.5) {
                      _updateServings(_servingMultiplier - 0.5);
                    }
                  },
                  icon: const Icon(Icons.remove),
                  iconSize: 20,
                ),
                IconButton(
                  onPressed: () {
                    _updateServings(_servingMultiplier + 0.5);
                  },
                  icon: const Icon(Icons.add),
                  iconSize: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // 재료 비교 테이블
        _buildIngredientsTable(),

        // 베이킹 레시피 추가 정보 (베이킹 레시피인 경우에만)
        if (_currentRecipe.isBaking) ...[
          const SizedBox(height: 24),
          _buildBakingStepsSection(),
        ],
      ],
    );
  }

  Widget _buildIngredientsTable() {
    return Column(
      children: [
        // 테이블 헤더
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  '재료명',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '원래',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '계산됨',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '변화',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // 재료 목록
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: List.generate(_currentRecipe.ingredients.length, (index) {
              final originalIngredient = _currentRecipe.ingredients[index];
              final calculatedIngredient = _calculatedIngredients.length > index
                  ? _calculatedIngredients[index]
                  : originalIngredient;

              return Container(
                key: _ingredientKeys[index],
                child: _buildIngredientRow(
                  originalIngredient,
                  calculatedIngredient,
                  index == _currentRecipe.ingredients.length - 1,
                  index == _currentIngredientIndex && _isGuideActive,
                  _completedIngredients.contains(index),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientRow(
    Ingredient original,
    Ingredient calculated,
    bool isLast,
    bool isFocused,
    bool isCompleted,
  ) {
    final changePercent = original.amount != 0
        ? ((calculated.amount - original.amount) / original.amount * 100)
        : 0.0;

    final isIncreased = calculated.amount > original.amount;
    final isDecreased = calculated.amount < original.amount;
    final isUnchanged = calculated.amount == original.amount;

    Color changeColor = Colors.grey.shade400;
    IconData changeIcon = Icons.remove;

    if (isIncreased) {
      changeColor = Colors.red.shade700;
      changeIcon = Icons.trending_up;
    } else if (isDecreased) {
      changeColor = Colors.blue.shade700;
      changeIcon = Icons.trending_down;
    } else {
      changeColor = Colors.grey.shade400;
      changeIcon = Icons.remove;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isFocused
            ? Colors.yellow.shade100
            : isCompleted
                ? Colors.green.shade50
                : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isFocused
              ? Colors.yellow.shade400
              : isCompleted
                  ? Colors.green.shade300
                  : Colors.transparent,
          width: isFocused || isCompleted ? 2 : 0,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: Colors.yellow.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          if (isCompleted) ...[
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 20,
              ),
            ),
          ] else if (isFocused) ...[
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.yellow.shade800,
                size: 20,
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade300,
                ),
              ),
            ),
          ],
          Expanded(
            flex: 3,
            child: Text(
              original.name.trim(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isFocused
                    ? Colors.yellow.shade900
                    : isCompleted
                        ? Colors.green.shade700
                        : Colors.blue.shade700,
              ),
            ),
          ),
          // 원래 양
          Expanded(
            flex: 2,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: _formatAmount(original.amount),
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: original.unit,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 계산된 양
          Expanded(
            flex: 2,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: _formatAmount(calculated.amount),
                    style: TextStyle(
                      fontSize: 15,
                      color: isUnchanged
                          ? Colors.blue.shade700
                          : Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: calculated.unit,
                    style: TextStyle(
                      fontSize: 13,
                      color: isUnchanged
                          ? Colors.blue.shade600
                          : Colors.orange.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 변화 표시
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 아이콘
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: changeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    changeIcon,
                    color: changeColor,
                    size: 14,
                  ),
                ),
                // 퍼센트 (변화가 있을 때만)
                if (!isUnchanged) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatPercentage(changePercent),
                    style: TextStyle(
                      fontSize: 9,
                      color: changeColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    final provider = Provider.of<RecipeProvider>(context, listen: false);
    return UnitConverter.formatAmount(amount, provider.unitSystem);
  }

  String _formatPercentage(double percent) {
    final absPercent = percent.abs();
    final sign = percent >= 0 ? '+' : '';

    if (absPercent >= 1000) {
      // 1000% 이상인 경우 "10x" 형태로 표시
      final multiplier = (absPercent / 100).round();
      return '${sign}${multiplier}x';
    } else if (absPercent >= 100) {
      // 100% 이상인 경우 소수점 없이 표시
      return '${sign}${percent.round()}%';
    } else {
      // 100% 미만인 경우 소수점 없이 표시
      return '${sign}${percent.round()}%';
    }
  }

  Widget _buildInstructionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_currentRecipe.instructions.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                '조리법이 등록되지 않았습니다.',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                ),
              ),
            ),
          )
        else
          ..._currentRecipe.instructions.asMap().entries.map((entry) {
            return InstructionStep(
              stepNumber: entry.key + 1,
              instruction: entry.value['description'] as String,
            );
          }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_currentRecipe.title),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showRecipeHistory,
            tooltip: l10n.historyTooltip,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _editRecipe();
                  break;
                case 'copy':
                  _copyRecipe();
                  break;
                case 'tree':
                  _showRecipeTree();
                  break;
                case 'delete':
                  _deleteRecipe();
                  break;
                case 'save_history':
                  _saveRecipeToHistory();
                  break;
                case 'sous_chef':
                  _showSousChefMode();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(l10n.edit),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Icons.copy, color: Colors.green),
                    SizedBox(width: 8),
                    Text(l10n.copy),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'tree',
                child: Row(
                  children: [
                    Icon(Icons.account_tree, color: Colors.teal),
                    SizedBox(width: 8),
                    Text(l10n.derivedGraph),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'save_history',
                child: Row(
                  children: [
                    Icon(Icons.save, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(l10n.saveHistory),
                  ],
                ),
              ),
              if (_currentRecipe.isBaking)
                const PopupMenuItem(
                  value: 'sous_chef',
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.purple),
                      SizedBox(width: 8),
                      Text(l10n.sousChefMode),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text(l10n.delete),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: _isGuideActive ? _onScreenTap : null,
            behavior: HitTestBehavior.translucent,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.orange.shade50,
                    Colors.white,
                  ],
                ),
              ),
              child: SingleChildScrollView(
                controller: _scrollController,
                padding:
                    const EdgeInsets.fromLTRB(16, 16, 16, 120), // FAB 공간 확보
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. 계산기 섹션 (베이킹 레시피인 경우에만)
                    if (_currentRecipe.isBaking) ...[
                      RecipeScaler(
                        recipe: _currentRecipe,
                        onIngredientsCalculated: (ingredients) {
                          setState(() {
                            _calculatedIngredients = ingredients;
                          });
                        },
                        onMultiplierChanged: (multiplier) {
                          setState(() {
                            _servingMultiplier = multiplier;
                          });
                        },
                      ),
                      const SizedBox(height: 32),
                    ],

                    // 2. 재료 섹션
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 통합된 헤더
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.shade50,
                                  Colors.green.shade100
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.list_alt,
                                    color: Colors.green,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '재료',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 재료 내용
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: _buildIngredientsList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 3. 조리법 섹션
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 통합된 헤더
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.shade50,
                                  Colors.orange.shade100
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.receipt_long,
                                    color: Colors.orange,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '조리법',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 조리법 내용
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: _buildInstructionsList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 수쉐프 모드 FAB (베이킹 레시피인 경우)
          if (_currentRecipe.isBaking) _buildSousChefFAB(context),

          // 가이드 활성화 FAB
          _buildGuideFAB(),
        ],
      ),
    );
  }

  Widget _buildBakingStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 믹싱 단계
        _buildMixingStepsSection(),
        const SizedBox(height: 16),

        // 발효 단계
        _buildFermentationStepsSection(),
        const SizedBox(height: 16),

        // 오븐 단계
        _buildOvenStepsSection(),
      ],
    );
  }

  Widget _buildMixingStepsSection() {
    final mixingSteps = _currentRecipe.mixingSteps;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.blender,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '믹싱 단계',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 단계 내용 또는 미입력 안내
          if (mixingSteps == null || mixingSteps.isEmpty) ...[
            _buildEmptyStepsInfo(context, '믹싱', Colors.blue.shade600),
          ] else ...[
            _buildStepsList(mixingSteps, Colors.blue.shade600),
          ],
        ],
      ),
    );
  }

  Widget _buildFermentationStepsSection() {
    final fermentationSteps = _currentRecipe.fermentationSteps;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.schedule,
                  color: Colors.purple.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '발효 단계',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 단계 내용 또는 미입력 안내
          if (fermentationSteps == null || fermentationSteps.isEmpty) ...[
            _buildEmptyStepsInfo(context, '발효', Colors.purple.shade600),
          ] else ...[
            _buildStepsList(fermentationSteps, Colors.purple.shade600),
          ],
        ],
      ),
    );
  }

  Widget _buildOvenStepsSection() {
    final ovenSteps = _currentRecipe.ovenSteps;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.whatshot,
                  color: Colors.red.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '오븐 단계',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 단계 내용 또는 미입력 안내
          if (ovenSteps == null || ovenSteps.isEmpty) ...[
            _buildEmptyStepsInfo(context, '오븐', Colors.red.shade600),
          ] else ...[
            _buildStepsList(ovenSteps, Colors.red.shade600),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyStepsInfo(BuildContext context, String stepType, Color color) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.grey.shade600,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            '$stepType 정보가 입력되지 않았습니다',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '레시피 수정에서 $stepType 단계를 추가할 수 있습니다',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _editRecipe,
            icon: const Icon(Icons.edit, size: 16),
            label: Text(l10n.recipeEdit),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsList(List<Map<String, dynamic>> steps, Color color) {
    final stepCount = steps.length;

    // 3개 이상의 단계가 있으면 확장/축소 가능하도록
    if (stepCount > 3) {
      return ExpansionTile(
        title: Text(
          '$stepCount개 단계',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        children: steps.asMap().entries.map((entry) {
          final stepNumber = entry.key + 1;
          final step = entry.value;
          return _buildStepItem(step, stepNumber, color);
        }).toList(),
      );
    } else {
      // 3개 이하의 단계는 바로 표시
      return Column(
        children: steps.asMap().entries.map((entry) {
          final stepNumber = entry.key + 1;
          final step = entry.value;
          return _buildStepItem(step, stepNumber, color);
        }).toList(),
      );
    }
  }

  Widget _buildStepItem(
      Map<String, dynamic> step, int stepNumber, Color color) {
    // 유연한 키 처리 - 여러 키를 시도
    final description = step['description'] ??
        step['desc'] ??
        step['text'] ??
        step['instruction'] ??
        '설명 없음';

    final time = step['time'] ?? step['duration'];
    final temperature = step['temperature'] ?? step['temp'];
    final notes = step['notes'] ?? step['note'];

    // 믹싱 속도 정보 추가
    final speed = step['speed'] ?? step['mixing_speed'] ?? step['mixer_speed'];

    // 습도 정보 추가 (발효 단계용)
    final humidity = step['humidity'] ?? step['moisture'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 단계 번호와 설명
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$stepNumber',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          // 추가 정보 - 단계별로 다른 순서 적용
          if (time != null ||
              temperature != null ||
              speed != null ||
              humidity != null ||
              notes != null) ...[
            const SizedBox(height: 8),
            _buildStepInfoTags(step, color),
          ],
        ],
      ),
    );
  }

  Widget _buildStepInfoTags(Map<String, dynamic> step, Color color) {
    final time = step['time'] ?? step['duration'];
    final temperature = step['temperature'] ?? step['temp'];
    final notes = step['notes'] ?? step['note'];
    final speed = step['speed'] ?? step['mixing_speed'] ?? step['mixer_speed'];
    final humidity = step['humidity'] ?? step['moisture'];

    // 단계별로 다른 정보 순서 적용
    final List<Widget> tags = [];

    // 단계에 따라 다른 순서로 태그 추가
    if (color == Colors.purple.shade600) {
      // 발효 단계: 온도 → 습도 → 시간 순서
      if (temperature != null) {
        tags.add(_buildTemperatureTag(temperature));
      }
      if (humidity != null) {
        tags.add(_buildHumidityTag(humidity));
      }
      if (time != null) {
        tags.add(_buildTimeTag(time));
      }
    } else if (color == Colors.red.shade600) {
      // 오븐 단계: 온도 → 시간 순서
      if (temperature != null) {
        tags.add(_buildTemperatureTag(temperature));
      }
      if (time != null) {
        tags.add(_buildTimeTag(time));
      }
    } else {
      // 믹싱 단계: 속도 → 시간 → 온도 순서
      if (speed != null) {
        tags.add(_buildSpeedTag(speed));
      }
      if (time != null) {
        tags.add(_buildTimeTag(time));
      }
      if (temperature != null) {
        tags.add(_buildTemperatureTag(temperature));
      }
    }

    // 습도 태그 (발효 단계가 아니면서 습도가 있는 경우)
    if (color != Colors.purple.shade600 && humidity != null) {
      tags.add(_buildHumidityTag(humidity));
    }

    // 노트 태그 (항상 마지막)
    if (notes != null && notes.toString().isNotEmpty) {
      tags.add(_buildNotesTag(notes.toString()));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: tags,
    );
  }

  Widget _buildTimeTag(dynamic time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            time.toString(),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureTag(dynamic temperature) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.thermostat, size: 12, color: Colors.orange.shade600),
          const SizedBox(width: 4),
          Text(
            '$temperature°C',
            style: TextStyle(
              fontSize: 11,
              color: Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHumidityTag(dynamic humidity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.teal.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.water_drop, size: 12, color: Colors.teal.shade600),
          const SizedBox(width: 4),
          Text(
            '$humidity%',
            style: TextStyle(
              fontSize: 11,
              color: Colors.teal.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesTag(String notes) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.note, size: 12, color: Colors.blue.shade600),
          const SizedBox(width: 4),
          Text(
            notes,
            style: TextStyle(
              fontSize: 11,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedTag(dynamic speed) {
    // 속도 값에 따라 색상 결정
    Color tagColor;
    Color textColor;

    final speedStr = speed.toString().toLowerCase().trim();

    // 속도별 색상 매핑
    if (speedStr.contains('저속') || speedStr.contains('1단') || speedStr == '1') {
      // 저속: 파란색 (안전하고 부드러운 느낌)
      tagColor = Colors.blue.shade100;
      textColor = Colors.blue.shade700;
    } else if (speedStr.contains('중속') ||
        speedStr.contains('2단') ||
        speedStr == '2') {
      // 중속: 노란색 (중간 강도)
      tagColor = Colors.yellow.shade100;
      textColor = Colors.yellow.shade800;
    } else if (speedStr.contains('고속') ||
        speedStr.contains('3단') ||
        speedStr == '3' ||
        speedStr.contains('4단') ||
        speedStr == '4' ||
        speedStr.contains('5단') ||
        speedStr == '5') {
      // 고속: 빨간색 (강한 힘과 속도)
      tagColor = Colors.red.shade100;
      textColor = Colors.red.shade700;
    } else if (speedStr.contains('최고') ||
        speedStr.contains('최고속') ||
        speedStr.contains('터보') ||
        speedStr.contains('강력')) {
      // 최고속: 진한 빨간색 (최대 출력)
      tagColor = Colors.red.shade200;
      textColor = Colors.red.shade900;
    } else if (speedStr.contains('펄스') || speedStr.contains('간헐')) {
      // 펄스: 보라색 (특별한 동작)
      tagColor = Colors.purple.shade100;
      textColor = Colors.purple.shade700;
    } else if (speedStr.contains('계란') ||
        speedStr.contains('거품') ||
        speedStr.contains('휘핑') ||
        speedStr.contains('크림')) {
      // 계란/거품용: 연한 파란색 (부드러운 동작)
      tagColor = Colors.cyan.shade100;
      textColor = Colors.cyan.shade700;
    } else {
      // 기본값: 초록색 (일반적인 경우)
      tagColor = Colors.green.shade100;
      textColor = Colors.green.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tagColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tagColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.speed,
            size: 12,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            speed.toString(),
            style: TextStyle(
              fontSize: 11,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSousChefFAB(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Positioned(
      bottom: 16,
      right: 16,
      child: FloatingActionButton.extended(
        heroTag: 'sous_chef_fab',
        onPressed: _showSousChefMode,
        backgroundColor: Colors.purple,
        icon: const Icon(Icons.auto_awesome),
        label: Text(l10n.sousChefMode),
      ),
    );
  }

  Widget _buildGuideFAB() {
    return Positioned(
      bottom: 16,
      left: 16,
      child: FloatingActionButton.extended(
        heroTag: 'guide_fab',
        onPressed: _showIngredientGuide,
        backgroundColor: _isGuideActive ? Colors.green : Colors.blue,
        icon: Icon(_isGuideActive ? Icons.lightbulb : Icons.lightbulb_outline),
        label: Text(_isGuideActive ? '가이드 끄기' : '가이드 켜기'),
      ),
    );
  }

  // 재료 가이드 관련 메소드들
  void _showIngredientGuide() {
    if (_isGuideActive) {
      // 가이드 비활성화
      setState(() {
        _isGuideActive = false;
        _currentIngredientIndex = 0;
        _completedIngredients.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.guideDeactivated),
          backgroundColor: Colors.blue,
          action: SnackBarAction(
            label: l10n.view,
            textColor: Colors.white,
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
    } else {
      // 가이드 활성화: 즉시 첫 번째 재료로 포커스 및 스크롤
      _currentIngredientIndex = 0;
      _completedIngredients.clear();

      // 상태 업데이트 및 즉시 스크롤
      setState(() {
        _isGuideActive = true;
      });

      // 즉시 첫 번째 재료로 스크롤 (setState 전에 호출)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentIngredient();
      });
    }
  }

  void _showIngredientDialog(int index) {
    final l10n = AppLocalizations.of(context)!;
    if (index < 0 || index >= _calculatedIngredients.length) return;

    final ingredient = _calculatedIngredients[index];
    final guideText = _getIngredientGuide(ingredient);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ingredient.name),
        content: SingleChildScrollView(
          child: Text(guideText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
          if (index > 0)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showIngredientDialog(index - 1);
              },
              child: Text(l10n.previous),
            ),
          if (index < _calculatedIngredients.length - 1)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showIngredientDialog(index + 1);
              },
              child: Text(l10n.next),
            ),
        ],
      ),
    );
  }

  String _getIngredientGuide(Ingredient ingredient) {
    final name = ingredient.name.toLowerCase();

    String guide = '📝 ${ingredient.name}\n\n';

    // 재료별 가이드
    if (name.contains('밀가루') || name.contains('flour')) {
      guide += '🥯 빵의 주재료로 탄수화물을 제공하는 기름지 피드입니다.\n';
      guide += '• 계량 시 정확하게 스푼으로 평평하게 긁어서 측정하세요.\n';
      guide += '• 곰팡이 방지를 위해 건조한 곳에 보관하세요.\n';
      if (name.contains('중력') || name.contains('all-purpose')) {
        guide += '• 다양한 용도로 사용할 수 있는 범용 밀가루입니다.\n';
      }
    } else if (name.contains('이스트') || name.contains('yeast')) {
      guide += '🧫 빵을 부풀리는 역할을 하는 생명현상입니다.\n';
      guide += '• 너무 뜨거운 물에 넣으면 죽어버리니 주의하세요.\n';
      guide += '• 갓사용이 가장 좋으니 오래된 것은 사용하지 마세요.\n';
      guide += '• 온도에 따라 발효 속도가 크게 달라집니다.\n';
    } else if (name.contains('설탕') || name.contains('sugar')) {
      guide += '🍯 단맛을 내주고 색을 아름답게 하는 역할을 합니다.\n';
      guide += '• 빵의 색을 좋게 하고 식감도 부드러워집니다.\n';
      guide += '• 이스트의 먹이 역할을 하면서 발효를 돕습니다.\n';
      guide += '• 과도하게 넣으면 빵이 무거워지니 조심하세요.\n';
    } else if (name.contains('소금') || name.contains('salt')) {
      guide += '🧂 맛을 조절하고 글루텐 형성을 돕는 중요한 역할을 합니다.\n';
      guide += '• 빵의 풍미를 더해주고 이스트의 발효 속도를 조절합니다.\n';
      guide += '• 다른 재료들이 잘 섞이도록 하는 역할도 합니다.\n';
      guide += '• 너무 적으면 밋밋한 맛이 나고 너무 많으면 발효가 느려져요.\n';
    } else if (name.contains('물') || name.contains('water')) {
      guide += '💧 모든 재료들이 잘 섞일 수 있도록 도와주세요.\n';
      guide += '• 온도가 중요한데, 따뜻함이 이스트 활동을 도와줍니다.\n';
      guide += '• 너무 뜨거우면 이스트가 죽으니 적당한 온도로 맞추세요.\n';
      guide += '• 빵의 수분 함량을 결정짓는 중요한 요소입니다.\n';
    } else if (name.contains('버터') ||
        name.contains('butter') ||
        name.contains('기름')) {
      guide += '🧈 풍미와 부드러움을 더해주는 지용성 재료입니다.\n';
      guide += '• 빵의 식감을 부드럽고 풍미있게 만들어줍니다.\n';
      guide += '• 과도하게 넣으면 빵이 무거워지니 적절한 양을 사용하세요.\n';
      guide += '• 상온에서 촉촉하게 풀어주세요.\n';
    } else if (name.contains('계란') || name.contains('egg')) {
      guide += '🥚 영양성분을 풍부하게 하고 반죽의 결합력을 높여줍니다.\n';
      guide += '• 빵에 윤기와 맛을 더해주는 역할을 합니다.\n';
      guide += '• 계란은 부풀음을 도와주는 역할을 합니다.\n';
      guide += '• 상온에서 사용하는 것이 좋습니다.\n';
    } else if (name.contains('우유') || name.contains('milk')) {
      guide += '🥛 풍부한 맛과 영양을 더해주고 반죽을 부드럽게 만들어줍니다.\n';
      guide += '• 빵의 색을 좋게 하고 풍미를 더해주는 역할을 합니다.\n';
      guide += '• 우유 속 유당 분해로 자연스러운 당도를 제공합니다.\n';
      guide += '• 상온으로 맞추어 사용하세요.\n';
    } else {
      // 기본 가이드
      guide += '🌱 빵 제조에 중요한 재료입니다.\n';
      guide += '• 필요한 양만큼 정확히 계량하여 사용하세요.\n';
      guide += '• 다른 재료들과의 화학 반응을 고려하세요.\n';
      guide += '• 신선한 재료를 사용하는 것이 가장 좋습니다.\n';
    }

    return guide;
  }

  // 자동 스크롤 기능
  void _scrollToCurrentIngredient() {
    if (_ingredientKeys.containsKey(_currentIngredientIndex)) {
      final key = _ingredientKeys[_currentIngredientIndex];
      if (key?.currentContext != null) {
        final renderBox = key!.currentContext!.findRenderObject() as RenderBox;
        final position = renderBox.localToGlobal(Offset.zero).dy;

        // 화면 중앙에 재료를 위치시키기 위해 조정
        const appBarHeight = 56.0; // 일반적인 앱 바 높이
        final screenHeight = MediaQuery.of(context).size.height;
        final targetOffset = _scrollController.offset +
            position -
            appBarHeight -
            MediaQuery.of(context).padding.top -
            (screenHeight / 2) +
            50; // 화면 중앙으로 위치 조정

        _scrollController.animateTo(
          targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  // 화면 탭으로 다음 재료로 이동
  void _onScreenTap() {
    if (!_isGuideActive) return;

    // 현재 재료를 완료로 표시
    if (!_completedIngredients.contains(_currentIngredientIndex)) {
      setState(() {
        _completedIngredients.add(_currentIngredientIndex);
      });
    }

    // 다음 재료로 이동
    if (_currentIngredientIndex < _calculatedIngredients.length - 1) {
      setState(() {
        _currentIngredientIndex++;
      });

      // 다음 재료로 스크롤
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentIngredient();
      });
    } else {
      // 모든 재료 완료됨
      setState(() {
        _isGuideActive = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.allIngredientsAdded),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: l10n.complete,
            textColor: Colors.white,
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );

      // 상태 초기화
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          _currentIngredientIndex = 0;
          _completedIngredients.clear();
        });
      });
    }
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
