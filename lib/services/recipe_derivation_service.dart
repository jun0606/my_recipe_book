import 'dart:io';
import '../models/recipe.dart';
import '../models/ingredient.dart';
import '../providers/recipe_provider.dart';
import '../utils/image_utils.dart';

/// 레시피 파생 관계를 관리하는 서비스 클래스
class RecipeDerivationService {
  final RecipeProvider _recipeProvider;
  
  RecipeDerivationService(this._recipeProvider);
  
  /// 레시피 복사본 생성
  /// [original] 원본 레시피
  /// [withNewTitle] 제목에 "(복사본)" 추가 여부
  /// 반환값: 복사된 새 레시피 (아직 저장되지 않음)
  Future<Recipe> createCopy(Recipe original, {bool withNewTitle = true}) async {
    String? newImagePath;
    
    // 이미지 복사
    if (original.imagePath != null) {
      newImagePath = await ImageUtils.copyImageFile(original.imagePath!);
    }
    
    // 레시피 복사
    return Recipe(
      title: withNewTitle ? '${original.title} (복사본)' : original.title,
      category: original.category,
      ingredients: List<Ingredient>.from(original.ingredients),
      instructions: List<String>.from(original.instructions),
      imagePath: newImagePath,
      baseServings: original.baseServings,
      isBaking: original.isBaking,
      targetSplitAmount: original.targetSplitAmount,
      targetSplitCount: original.targetSplitCount,
      totalIngredientWeight: original.totalIngredientWeight,
      // 복사본은 parentId를 설정하지 않음
    );
  }
  
  /// 파생 레시피 생성
  /// [original] 원본 레시피
  /// [customTitle] 사용자 지정 제목 (없으면 "(파생)" 추가)
  /// 반환값: 파생된 새 레시피 (아직 저장되지 않음)
  Future<Recipe> createDerived(Recipe original, {String? customTitle}) async {
    String? newImagePath;
    
    // 이미지 복사
    if (original.imagePath != null) {
      newImagePath = await ImageUtils.copyImageFile(original.imagePath!);
    }
    
    final title = customTitle ?? '${original.title} (파생)';
    
    // 파생 레시피 생성
    return Recipe(
      title: title,
      category: original.category,
      ingredients: List<Ingredient>.from(original.ingredients),
      instructions: List<String>.from(original.instructions),
      imagePath: newImagePath,
      baseServings: original.baseServings,
      isBaking: original.isBaking,
      targetSplitAmount: original.targetSplitAmount,
      targetSplitCount: original.targetSplitCount,
      totalIngredientWeight: original.totalIngredientWeight,
      parentId: original.id, // 파생 관계 설정
    );
  }
  
  /// 레시피 계보 구성
  /// [initialRecipe] 시작 레시피
  /// 반환값: 레시피와 깊이 정보를 포함한 트리 구조
  Future<List<Map<String, dynamic>>> buildRecipeTree(Recipe initialRecipe) async {
    List<Map<String, dynamic>> tree = [];
    Set<int> visitedIds = {};
    
    if (initialRecipe.id == null) {
      return [{'recipe': initialRecipe, 'depth': 0}];
    }
    
    // 루트 조상 찾기
    Recipe rootRecipe = initialRecipe;
    int currentDepth = 0;
    
    while (rootRecipe.parentId != null) {
      final parent = await _recipeProvider.getRecipeById(rootRecipe.parentId!);
      if (parent != null) {
        rootRecipe = parent;
        currentDepth--;
      } else {
        break;
      }
    }
    
    // 트리 구성 (재귀 함수 활용)
    await _buildTreeRecursively(rootRecipe, tree, visitedIds, currentDepth);
    
    return tree;
  }
  
  /// 재귀적으로 레시피 트리 구성
  Future<void> _buildTreeRecursively(
    Recipe recipe, 
    List<Map<String, dynamic>> tree, 
    Set<int> visitedIds, 
    int depth
  ) async {
    if (recipe.id == null || visitedIds.contains(recipe.id)) return;
    
    visitedIds.add(recipe.id!);
    tree.add({'recipe': recipe, 'depth': depth});
    
    // 파생 레시피 가져오기
    final children = await _recipeProvider.getDerivedRecipes(recipe.id!);
    for (var child in children) {
      if (child.id != null && !visitedIds.contains(child.id)) {
        await _buildTreeRecursively(child, tree, visitedIds, depth + 1);
      }
    }
  }
  
  /// 레시피의 파생 개수 가져오기
  Future<int> getDerivedCount(Recipe recipe) async {
    if (recipe.id == null) return 0;
    return await _recipeProvider.getDerivedCount(recipe.id!);
  }
  
  /// 레시피의 파생 레시피 목록 가져오기
  Future<List<Recipe>> getDerivedRecipes(Recipe recipe) async {
    if (recipe.id == null) return [];
    return await _recipeProvider.getDerivedRecipes(recipe.id!);
  }
  
  /// 레시피의 부모 레시피 가져오기
  Future<Recipe?> getParentRecipe(Recipe recipe) async {
    if (recipe.id == null || recipe.parentId == null) return null;
    return await _recipeProvider.getRecipeById(recipe.parentId!);
  }
}