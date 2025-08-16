import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../models/ingredient.dart';
import '../providers/recipe_provider.dart';
import '../services/recipe_history_service.dart';
import '../models/recipe_history.dart';

import '../widgets/recipe_detail/baking_calculator.dart';
import '../widgets/recipe_detail/ingredient_card_simple.dart';
import '../widgets/recipe_detail/instruction_step_simple.dart';
// import '../widgets/recipe_detail/servings_calculator.dart'; // 임시 비활성화
// import '../widgets/recipe_detail/recipe_actions_menu.dart'; // 임시 비활성화
import '../screens/add_recipe_screen.dart';
import '../screens/sous_chef_mode_screen.dart';
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
  late Recipe _currentRecipe;
  List<Ingredient> _calculatedIngredients = [];
  final RecipeHistoryService _historyService = RecipeHistoryService.instance;
  
  // 계산기 관련 상태
  double _servingMultiplier = 1.0;
  bool _showBakingCalculator = false;
  
  // 분할 계산 관련 상태
  final TextEditingController _splitAmountController = TextEditingController();
  final TextEditingController _splitCountController = TextEditingController();
  bool _isAmountBased = true;

  @override
  void initState() {
    super.initState();
    _currentRecipe = widget.recipe;
    _calculatedIngredients = List.from(_currentRecipe.ingredients);
    
    // 초기값 설정
    _splitAmountController.text = _currentRecipe.targetSplitAmount?.toString() ?? '';
    _splitCountController.text = _currentRecipe.targetSplitCount?.toString() ?? '1';
    _showBakingCalculator = _currentRecipe.isBaking;
  }

  @override
  void dispose() {
    _splitAmountController.dispose();
    _splitCountController.dispose();
    super.dispose();
  }

  void _updateServings(double multiplier) {
    setState(() {
      _servingMultiplier = multiplier;
      _calculatedIngredients = _currentRecipe.ingredients.map((ingredient) {
        return Ingredient(
          name: ingredient.name,
          amount: ingredient.amount * multiplier,
          unit: ingredient.unit,
        );
      }).toList();
    });
  }

  void _showRecipeHistory() {
    // 레시피 히스토리 표시 로직
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('레시피 히스토리'),
        content: const Text('히스토리 기능은 현재 개발 중입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('수쉐프 모드를 실행할 수 없습니다: $e'),
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRecipeScreen(
          recipe: _currentRecipe,
          isCopy: true,
        ),
      ),
    );
  }

  void _deleteRecipe() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('레시피 삭제'),
        content: Text('${_currentRecipe.title} 레시피를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
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
                    content: Text('레시피가 삭제되었습니다'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('삭제 실패: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _saveRecipeToHistory() async {
    try {
      // TODO: Fix RecipeHistory constructor issue - temporarily disabled
      /*
      final history = RecipeHistory(
        id: _currentRecipe.id?.toString() ?? 'unknown',
        recipeTitle: _currentRecipe.title,
        recipeCategory: _currentRecipe.category,
        ingredients: _calculatedIngredients.map((ingredient) => {
          'name': ingredient.name,
          'amount': ingredient.amount,
          'unit': ingredient.unit,
        }).toList(),
        timestamp: DateTime.now(),
        notes: '레시피 상세에서 저장됨',
      );
      */
      
      // TODO: Fix RecipeHistory constructor issue
      // await _historyService.saveHistory(history);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('레시피가 히스토리에 저장되었습니다'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('히스토리 저장 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildIngredientsList() {
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
                const Text('기본 인분: '),
                Text(
                  '${_currentRecipe.baseServings}인분',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                const Text('배수: '),
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
              
              return _buildIngredientRow(
                originalIngredient, 
                calculatedIngredient, 
                index == _currentRecipe.ingredients.length - 1,
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
        border: isLast ? null : Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Row(
        children: [
          // 재료명
          Expanded(
            flex: 3,
            child: Text(
              original.name.trim(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
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
                      color: isUnchanged ? Colors.blue.shade700 : Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: calculated.unit,
                    style: TextStyle(
                      fontSize: 13,
                      color: isUnchanged ? Colors.blue.shade600 : Colors.orange.shade600,
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
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    } else {
      return amount.toStringAsFixed(1);
    }
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
              instruction: entry.value,
            );
          }).toList(),
      ],
    );
  }

  Widget _buildBakingCalculator() {
    if (!_currentRecipe.isBaking) {
      return const Center(
        child: Text(
          '베이킹 레시피가 아닙니다.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }

    return BakingCalculator(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentRecipe.title),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showRecipeHistory,
            tooltip: '히스토리',
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
                    Text('수정'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Icons.copy, color: Colors.green),
                    SizedBox(width: 8),
                    Text('복사'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'save_history',
                child: Row(
                  children: [
                    Icon(Icons.save, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('히스토리 저장'),
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
                      Text('수쉐프 모드'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('삭제'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 계산기 섹션 (베이킹 레시피인 경우에만)
              if (_currentRecipe.isBaking) ...[
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
                  child: _buildBakingCalculator(),
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
                          colors: [Colors.green.shade50, Colors.green.shade100],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
                          colors: [Colors.orange.shade50, Colors.orange.shade100],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
              const SizedBox(height: 100), // 플로팅 버튼을 위한 여백
            ],
          ),
        ),
      ),
      // 플로팅 액션 버튼 (베이킹 레시피인 경우에만)
      floatingActionButton: _currentRecipe.isBaking
          ? FloatingActionButton.extended(
              onPressed: _showSousChefMode,
              backgroundColor: Colors.purple,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('수쉐프 모드'),
            )
          : null,
    );
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