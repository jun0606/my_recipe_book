import 'dart:io';
import 'package:flutter/material.dart';
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
      instructions: List<Map<String, dynamic>>.from(original.instructions),
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
      instructions: List<Map<String, dynamic>>.from(original.instructions),
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
  Future<List<Map<String, dynamic>>> buildRecipeTree(
      Recipe initialRecipe) async {
    List<Map<String, dynamic>> tree = [];
    Set<int> ancestorVisitedIds = {}; // 루트 조상 찾기용 방문 ID 추적 (순환 참조 방지)

    debugPrint(
        'RecipeDerivationService: buildRecipeTree 시작 - 초기 레시피: ${initialRecipe.title} (ID: ${initialRecipe.id}, parentId: ${initialRecipe.parentId})');

    if (initialRecipe.id == null) {
      debugPrint('RecipeDerivationService: 초기 레시피 ID가 null이므로 단일 항목 반환');
      return [
        {'recipe': initialRecipe, 'depth': 0}
      ];
    }

    // 루트 조상 찾기 (순환 참조 방지)
    Recipe rootRecipe = initialRecipe;
    int currentDepth = 0;

    debugPrint('RecipeDerivationService: 루트 조상 찾기 시작');
    while (rootRecipe.parentId != null) {
      debugPrint(
          'RecipeDerivationService: 현재 레시피 parentId: ${rootRecipe.parentId}');

      // 순환 참조 감지 (이미 방문한 ID)
      if (ancestorVisitedIds.contains(rootRecipe.parentId)) {
        debugPrint('⏹️ 순환 참조 감지: 레시피 ${rootRecipe.parentId}가 이미 방문됨');
        break;
      }
      ancestorVisitedIds.add(rootRecipe.parentId!);

      final parent = await _recipeProvider.getRecipeById(rootRecipe.parentId!);
      debugPrint(
          'RecipeDerivationService: 부모 레시피 조회 결과 - ${parent?.title ?? 'null'} (ID: ${parent?.id})');

      if (parent != null) {
        rootRecipe = parent;
        currentDepth--;
        debugPrint(
            'RecipeDerivationService: 루트 조상 업데이트 - ${rootRecipe.title}, 깊이: $currentDepth');
      } else {
        debugPrint('RecipeDerivationService: 부모 레시피를 찾을 수 없음, 루프 종료');
        break;
      }
    }

    debugPrint(
        'RecipeDerivationService: 최종 루트 레시피 - ${rootRecipe.title} (ID: ${rootRecipe.id}), 시작 깊이: $currentDepth');

    // 트리 구성 (재귀 함수 활용) - 새로운 visitedIds 사용
    debugPrint('RecipeDerivationService: 재귀 트리 구성 시작');
    Set<int> treeVisitedIds = {}; // 트리 구성용 별도 방문 ID 추적
    await _buildTreeRecursively(rootRecipe, tree, treeVisitedIds, currentDepth);

    debugPrint('RecipeDerivationService: 트리 구성 완료 - 총 ${tree.length}개 항목');
    return tree;
  }

  /// 재귀적으로 레시피 트리 구성
  Future<void> _buildTreeRecursively(Recipe recipe,
      List<Map<String, dynamic>> tree, Set<int> visitedIds, int depth) async {
    if (recipe.id == null || visitedIds.contains(recipe.id)) {
      debugPrint(
          'RecipeDerivationService: _buildTreeRecursively - 레시피 ID가 null이거나 이미 방문됨: ${recipe.title} (ID: ${recipe.id})');
      return;
    }

    visitedIds.add(recipe.id!);
    tree.add({'recipe': recipe, 'depth': depth});
    debugPrint(
        'RecipeDerivationService: 트리에 추가 - ${recipe.title} (깊이: $depth)');

    // 파생 레시피 가져오기
    debugPrint('RecipeDerivationService: 파생 레시피 조회 시작 - 부모 ID: ${recipe.id}');
    final children = await _recipeProvider.getDerivedRecipes(recipe.id!);
    debugPrint(
        'RecipeDerivationService: 파생 레시피 조회 결과 - ${children.length}개 발견');

    for (var child in children) {
      debugPrint(
          'RecipeDerivationService: 자식 레시피 - ${child.title} (ID: ${child.id}, parentId: ${child.parentId})');
      if (child.id != null && !visitedIds.contains(child.id)) {
        debugPrint('RecipeDerivationService: 자식 레시피 재귀 호출 - ${child.title}');
        await _buildTreeRecursively(child, tree, visitedIds, depth + 1);
      } else {
        debugPrint('RecipeDerivationService: 자식 레시피 건너뜀 - 이미 방문했거나 ID가 null');
      }
    }

    debugPrint(
        'RecipeDerivationService: _buildTreeRecursively 완료 - ${recipe.title}의 자식 처리 완료');
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
