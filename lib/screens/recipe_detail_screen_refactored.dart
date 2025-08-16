import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
// import '../providers/cooking_mode_provider.dart'; // 베이킹 모드 제거됨
import '../widgets/recipe_detail/recipe_actions_menu.dart';
// import '../widgets/recipe_detail/baking_calculator_phase2.dart'; // 베이킹 모드 제거됨
import '../widgets/recipe_detail/history/history_tab.dart';
import '../widgets/common/language_selector.dart';

// 베이킹 모드 제거로 인해 사용 중단됨 - 대신 recipe_detail_screen.dart 사용
class RecipeDetailScreenRefactored extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreenRefactored({super.key, required this.recipe});

  @override
  _RecipeDetailScreenRefactoredState createState() =>
      _RecipeDetailScreenRefactoredState();
}

class _RecipeDetailScreenRefactoredState
    extends State<RecipeDetailScreenRefactored>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Recipe _currentRecipe;
  bool _isCookingMode = false;
  int _cookingModeStep = 0;
  bool _isIngredientPhase = true;
  final ScrollController _scrollController = ScrollController();
  late List<GlobalKey> _ingredientKeys;
  late List<GlobalKey> _instructionKeys;

  @override
  void initState() {
    super.initState();
    _currentRecipe = widget.recipe;
    _tabController = TabController(length: 3, vsync: this);
    _ingredientKeys =
        List.generate(_currentRecipe.ingredients.length, (_) => GlobalKey());
    _instructionKeys =
        List.generate(_currentRecipe.instructions.length, (_) => GlobalKey());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleCookingMode() {
    final cookingModeProvider =
        Provider.of<CookingModeProvider>(context, listen: false);
    cookingModeProvider.toggleCookingMode();

    setState(() {
      _isCookingMode = cookingModeProvider.isCookingMode;
      _cookingModeStep = cookingModeProvider.cookingModeStep;
      _isIngredientPhase = cookingModeProvider.isIngredientPhase;
    });

    if (_isCookingMode) {
      // 요리 모드 시작 시 레시피 탭으로 이동
      _tabController.animateTo(0);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('요리 모드가 시작되었습니다. 화면을 더블 탭하여 다음 단계로 이동하세요.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _resetCookingMode() {
    final cookingModeProvider =
        Provider.of<CookingModeProvider>(context, listen: false);
    cookingModeProvider.resetCookingMode();

    setState(() {
      _cookingModeStep = cookingModeProvider.cookingModeStep;
      _isIngredientPhase = cookingModeProvider.isIngredientPhase;
    });
  }

  void _handleDoubleTap() {
    if (!_isCookingMode) return;

    final cookingModeProvider =
        Provider.of<CookingModeProvider>(context, listen: false);
    cookingModeProvider.nextStep(
        _currentRecipe.ingredients.length, _currentRecipe.instructions.length);

    setState(() {
      _cookingModeStep = cookingModeProvider.cookingModeStep;
      _isIngredientPhase = cookingModeProvider.isIngredientPhase;
    });
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    if (!_isCookingMode) return;
    if (details.primaryVelocity! > 0) {
      final cookingModeProvider =
          Provider.of<CookingModeProvider>(context, listen: false);
      cookingModeProvider.previousStep(_currentRecipe.ingredients.length);

      setState(() {
        _cookingModeStep = cookingModeProvider.cookingModeStep;
        _isIngredientPhase = cookingModeProvider.isIngredientPhase;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final unitSystem = Provider.of<RecipeProvider>(context).unitSystem;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentRecipe.title),
        actions: [
          LanguageSelector(isDropdown: false),
          RecipeActionsMenu(
            recipe: _currentRecipe,
            onRecipeUpdated: (updatedRecipe) {
              if (updatedRecipe != null) {
                setState(() {
                  _currentRecipe = updatedRecipe;
                  _ingredientKeys = List.generate(
                      _currentRecipe.ingredients.length, (_) => GlobalKey());
                  _instructionKeys = List.generate(
                      _currentRecipe.instructions.length, (_) => GlobalKey());
                });
              }
            },
            onRecipeDeleted: () {
              Navigator.pop(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.restaurant_menu), text: '레시피'),
            Tab(icon: Icon(Icons.history), text: '히스토리'),
            Tab(icon: Icon(Icons.info), text: '정보'),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: isKeyboardVisible || _tabController.index != 0
          ? null
          : Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: _isCookingMode
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton.small(
                          heroTag: 'reset_cooking',
                          onPressed: _resetCookingMode,
                          tooltip: '처음부터 다시 시작',
                          child: Icon(Icons.refresh),
                        ),
                        SizedBox(height: 8),
                        FloatingActionButton(
                          heroTag: 'toggle_cooking_mode',
                          onPressed: _toggleCookingMode,
                          tooltip: '요리 모드 종료',
                          child: Icon(Icons.close),
                        ),
                      ],
                    )
                  : FloatingActionButton(
                      heroTag: 'start_cooking_mode',
                      onPressed: _toggleCookingMode,
                      tooltip: '요리 시작',
                      child: Icon(Icons.play_arrow),
                    ),
            ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 레시피 탭
          GestureDetector(
            onDoubleTap: _isCookingMode ? _handleDoubleTap : null,
            onHorizontalDragEnd:
                _isCookingMode ? _handleHorizontalDragEnd : null,
            child: _buildRecipeTab(),
          ),

          // 히스토리 탭
          HistoryTab(recipeId: _currentRecipe.id!),

          // 정보 탭
          _buildInfoTab(),
        ],
      ),
    );
  }

  Widget _buildRecipeTab() {
    final unitSystem = Provider.of<RecipeProvider>(context).unitSystem;

    return SingleChildScrollView(
      controller: _scrollController,
      physics: AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_currentRecipe.imagePath != null)
            Image.file(
              File(_currentRecipe.imagePath!),
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
          SizedBox(height: 16),
          Text('카테고리: ${_currentRecipe.category}',
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
          SizedBox(height: 16),
          Text(
              _currentRecipe.isBaking
                  ? '재료'
                  : '재료 (${_currentRecipe.baseServings}인분 기준)',
              style: Theme.of(context).textTheme.titleLarge),

          // 베이킹 모드일 때 베이킹 계산기 표시
          if (_currentRecipe.isBaking)
            Container(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  '베이킹 계산기는 현재 사용할 수 없습니다.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                isCookingMode: _isCookingMode,
                isIngredientPhase: _isIngredientPhase,
                cookingModeStep: _cookingModeStep,
                ingredientKeys: _ingredientKeys,
              ),
            ),

          // 조리법 섹션
          SizedBox(height: 20),
          Text('조리법', style: Theme.of(context).textTheme.titleLarge),
          ..._currentRecipe.instructions.asMap().entries.map((entry) {
            int idx = entry.key;
            String step = entry.value['text'];
            String? imagePath = entry.value['imagePath'];
            final isHighlighted = _isCookingMode &&
                !_isIngredientPhase &&
                _cookingModeStep == idx;
            return _buildHighlightedCard(
              isHighlighted: isHighlighted,
              child: Card(
                key: _instructionKeys[idx],
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                          backgroundColor: Colors.pink[300],
                          child: Text('${idx + 1}')),
                      title: Text(step),
                    ),
                    if (imagePath != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Image.file(File(imagePath),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover),
                      ),
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('레시피 정보', style: Theme.of(context).textTheme.titleLarge),
                  Divider(),
                  _buildInfoRow('ID', '${_currentRecipe.id}'),
                  _buildInfoRow('제목', _currentRecipe.title),
                  _buildInfoRow('카테고리', _currentRecipe.category),
                  _buildInfoRow('기본 인분', '${_currentRecipe.baseServings}인분'),
                  _buildInfoRow(
                      '베이킹 레시피', _currentRecipe.isBaking ? '예' : '아니오'),
                  _buildInfoRow(
                      '재료 수', '${_currentRecipe.ingredients.length}개'),
                  _buildInfoRow(
                      '조리 단계', '${_currentRecipe.instructions.length}단계'),
                  if (_currentRecipe.parentId != null)
                    _buildInfoRow('부모 레시피 ID', '${_currentRecipe.parentId}'),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          if (_currentRecipe.isBaking)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('베이킹 정보',
                        style: Theme.of(context).textTheme.titleLarge),
                    Divider(),
                    _buildInfoRow('총 재료 무게',
                        '${_currentRecipe.totalIngredientWeight?.toStringAsFixed(1) ?? "N/A"}g'),
                    _buildInfoRow('목표 분할 무게',
                        '${_currentRecipe.targetSplitAmount?.toStringAsFixed(1) ?? "N/A"}g'),
                    _buildInfoRow('목표 분할 수량',
                        '${_currentRecipe.targetSplitCount ?? "N/A"}개'),
                    _buildInfoRow('남은 재료 무게',
                        '${_currentRecipe.calculatedRemainingWeight?.toStringAsFixed(1) ?? "N/A"}g'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedCard(
      {required Widget child, required bool isHighlighted}) {
    if (!isHighlighted) return child;
    return Transform.scale(
      scale: 1.05,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.pink, width: 3),
          boxShadow: [
            BoxShadow(
                color: Colors.pink.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2)
          ],
        ),
        child: child,
      ),
    );
  }
}
