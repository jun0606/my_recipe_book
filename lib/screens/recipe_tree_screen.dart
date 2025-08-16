import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../services/recipe_derivation_service.dart';
import '../widgets/recipe_tree/recipe_tree_item.dart';
import '../utils/error_handler.dart';

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

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<RecipeProvider>(context, listen: false);
    _derivationService = RecipeDerivationService(provider);
    _loadRecipeTree();
  }

  Future<void> _loadRecipeTree() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // 초기 레시피 ID 확인
      if (widget.initialRecipe.id == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = '레시피 ID가 유효하지 않습니다.';
        });
        return;
      }
      
      // 레시피 트리 구성
      final tree = await _derivationService.buildRecipeTree(widget.initialRecipe);
      
      if (mounted) {
        setState(() {
          _treeRecipes = tree;
          _isLoading = false;
        });
      }
    } catch (e) {
      ErrorHandler.logError('RecipeTreeScreen', '레시피 트리 로딩 중 오류', e);
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
        body: Center(child: Text('레시피 계보 정보가 없습니다.')),
      );
    }

    // 최소 깊이 계산 (들여쓰기용)
    int minDepth = _treeRecipes.map((e) => e['depth'] as int).reduce((a, b) => a < b ? a : b);

    return Scaffold(
      appBar: AppBar(title: Text('레시피 계보')),
      body: ListView.builder(
        itemCount: _treeRecipes.length,
        itemBuilder: (context, index) {
          // 안전한 인덱스 체크
          if (index < 0 || index >= _treeRecipes.length) {
            return SizedBox.shrink();
          }
          
          final entry = _treeRecipes[index];
          final Recipe recipe = entry['recipe'] as Recipe;
          final int depth = entry['depth'] as int;
          final int normalizedDepth = depth - minDepth;
          
          // 다음 항목이 자식인지 확인 (세로선 그리기용)
          bool hasChild = false;
          if (index + 1 < _treeRecipes.length) {
            final nextDepth = _treeRecipes[index + 1]['depth'] as int;
            hasChild = nextDepth > depth;
          }
          
          return RecipeTreeItem(
            recipe: recipe,
            initialRecipe: widget.initialRecipe,
            depth: depth,
            normalizedDepth: normalizedDepth,
            hasChild: hasChild,
          );
        },
      ),
    );
  }
}