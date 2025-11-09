import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/recipe.dart';
import '../../../../providers/recipe_provider.dart';
import '../../../../services/recipe_derivation_service.dart';
import '../widgets/recipe_tree/recipe_tree_item.dart';
import 'dart:developer' as developer;

class RecipeTreeScreen extends StatefulWidget {
  final Recipe initialRecipe;

  RecipeTreeScreen({required this.initialRecipe});

  @override
  _RecipeTreeScreenState createState() => _RecipeTreeScreenState();
}

class _RecipeTreeScreenState extends State<RecipeTreeScreen> {
  List<Map<String, dynamic>> _treeRecipes = []; // Recipe와 depth를 함께 저장
  bool _isLoading = true;
  String _errorMessage = '';
  late RecipeDerivationService _derivationService;

  // 스크롤 컨트롤러
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<RecipeProvider>(context, listen: false);
    _derivationService = RecipeDerivationService(provider);
    _loadRecipeTree();
  }

  double _calculateTreeWidth(int minDepth) {
    if (_treeRecipes.isEmpty) return 400.0;

    // 최대 깊이 계산
    int maxDepth = _treeRecipes
        .map((e) => e['depth'] as int)
        .reduce((a, b) => a > b ? a : b);

    int maxNormalizedDepth = maxDepth - minDepth;

    // 트리 전체 너비 계산: (최대 깊이 + 1) * 카드 너비 + 간격
    return (maxNormalizedDepth + 1) * 320.0 + 40.0;
  }

  Future<void> _loadRecipeTree() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 초기 레시피 ID 확인
      developer.log(
          'RecipeTreeScreen: 초기 레시피 - ID: ${widget.initialRecipe.id}, 제목: ${widget.initialRecipe.title}, parentId: ${widget.initialRecipe.parentId}');

      if (widget.initialRecipe.id == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = '레시피 ID가 유효하지 않습니다.';
        });
        return;
      }

      // 현재 데이터베이스의 모든 레시피 상태 확인
      final provider = Provider.of<RecipeProvider>(context, listen: false);
      developer
          .log('RecipeTreeScreen: 현재 레시피 목록 (${provider.recipes.length}개):');
      for (var recipe in provider.recipes) {
        developer.log(
            '  - ID: ${recipe.id}, 제목: ${recipe.title}, parentId: ${recipe.parentId}');
      }

      // 레시피 트리 구성
      developer.log('RecipeTreeScreen: buildRecipeTree 호출 시작');
      final tree =
          await _derivationService.buildRecipeTree(widget.initialRecipe);
      developer
          .log('RecipeTreeScreen: buildRecipeTree 결과 - 트리 크기: ${tree.length}');

      for (var entry in tree) {
        final recipe = entry['recipe'] as Recipe;
        final depth = entry['depth'] as int;
        developer.log(
            '  - 깊이 $depth: ${recipe.title} (ID: ${recipe.id}, parentId: ${recipe.parentId})');
      }

      if (mounted) {
        setState(() {
          _treeRecipes = tree;
          _isLoading = false;
        });
        developer.log(
            'RecipeTreeScreen: 트리 로딩 완료 - 표시할 항목 수: ${_treeRecipes.length}');
      }
    } catch (e) {
      developer.log('RecipeTreeScreen: 레시피 트리 로딩 중 오류', error: e);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '레시피 계보를 불러오는 중 오류가 발생했습니다.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('레시피 계보')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('레시피 계보')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text(_errorMessage, style: TextStyle(fontSize: 16)),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadRecipeTree,
                child: Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    if (_treeRecipes.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('레시피 계보')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_tree_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 16),
              Text(
                '레시피 계보 정보가 없습니다',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '이 레시피에서 파생된 레시피가 없습니다.\n복제 메뉴에서 "파생 레시피"를 선택하여\n새로운 변형 레시피를 만들어보세요.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back),
                label: Text('돌아가기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 최소 깊이 계산 (들여쓰기용)
    int minDepth = _treeRecipes
        .map((e) => e['depth'] as int)
        .reduce((a, b) => a < b ? a : b);

    developer.log('RecipeTreeScreen: 최소 깊이 계산 - minDepth: $minDepth');

    return Scaffold(
      appBar: AppBar(title: Text('레시피 계보')),
      body: SingleChildScrollView(
        controller: _horizontalController, // 수평 스크롤 컨트롤러
        scrollDirection: Axis.horizontal, // 수평 스크롤 추가
        child: SingleChildScrollView(
          controller: _verticalController, // 수직 스크롤 컨트롤러
          scrollDirection: Axis.vertical, // 수직 스크롤
          child: Container(
            width: _calculateTreeWidth(minDepth), // 트리 전체 너비 계산
            height: _treeRecipes.length * 130.0 + 100, // 카드 높이 + 간격 (100 + 30)
            child: Stack(
              children: [
                // 연결선 그리기
                Positioned.fill(
                  child: CustomPaint(
                    painter: ConnectionPainter(
                      treeRecipes: _treeRecipes,
                      initialRecipe: widget.initialRecipe,
                      horizontalOffset: _horizontalController.hasClients
                          ? _horizontalController.offset
                          : 0.0,
                      verticalOffset: _verticalController.hasClients
                          ? _verticalController.offset
                          : 0.0,
                    ),
                  ),
                ),

                // 카드들 배치
                ...List.generate(_treeRecipes.length, (index) {
                  final entry = _treeRecipes[index];
                  final Recipe recipe = entry['recipe'] as Recipe;
                  final int depth = entry['depth'] as int;
                  final int normalizedDepth = depth - minDepth;

                  // 좌표 계산 (간격 최적화)
                  final double x =
                      normalizedDepth * 320.0 + 20.0; // 카드 너비 300 + 간격 20
                  final double y =
                      index * 130.0 + 20.0; // 카드 높이 + 간격 (100 + 30)

                  developer.log(
                      'RecipeTreeScreen: Stack item $index - 레시피: ${recipe.title} (ID: ${recipe.id}), x: $x, y: $y');

                  return Positioned(
                    left: x,
                    top: y,
                    child: RecipeTreeItem(
                      recipe: recipe,
                      initialRecipe: widget.initialRecipe,
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
