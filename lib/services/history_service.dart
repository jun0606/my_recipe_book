import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../models/recipe.dart';
import '../models/history.dart';

/// 히스토리 관련 서비스
class HistoryService {
  /// 데이터베이스 인스턴스
  final Future<Database> Function() _getDatabase;

  /// 생성자
  HistoryService(this._getDatabase);

  /// 히스토리 추가
  ///
  /// [recipeId] 레시피 ID
  /// [changes] 변경 사항 설명
  /// [oldRecipe] 변경 전 레시피 (null인 경우 새 레시피)
  ///
  /// 반환값: 추가된 히스토리 ID
  Future<int> addHistory(
      int recipeId, String changes, Recipe? oldRecipe) async {
    final db = await _getDatabase();

    String? oldRecipeStateJson;
    if (oldRecipe != null) {
      oldRecipeStateJson = jsonEncode(oldRecipe.toJson());
    }

    final history = History(
      recipeId: recipeId,
      modifiedDate: DateTime.now().toIso8601String(),
      changes: changes,
      recipeState: oldRecipeStateJson,
    );

    return await db.insert('history', history.toJson());
  }

  /// 레시피의 히스토리 목록 가져오기
  ///
  /// [recipeId] 레시피 ID
  ///
  /// 반환값: 히스토리 목록
  Future<List<History>> getHistoryByRecipeId(int recipeId) async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'history',
      where: 'recipeId = ?',
      whereArgs: [recipeId],
      orderBy: 'modifiedDate DESC',
    );

    return maps.map((map) => History.fromJson(map)).toList();
  }

  /// 히스토리에서 레시피 복원
  ///
  /// [historyId] 히스토리 ID
  ///
  /// 반환값: 복원된 레시피
  Future<Recipe?> restoreRecipeFromHistory(int historyId) async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'history',
      where: 'id = ?',
      whereArgs: [historyId],
    );

    if (maps.isEmpty) {
      return null;
    }

    final history = History.fromJson(maps.first);
    if (history.recipeState == null) {
      return null;
    }

    try {
      final Map<String, dynamic> recipeMap = jsonDecode(history.recipeState!);
      return Recipe.fromJson(recipeMap);
    } catch (e) {
      print('히스토리에서 레시피 복원 중 오류: $e');
      return null;
    }
  }

  /// 히스토리 삭제
  ///
  /// [historyId] 히스토리 ID
  ///
  /// 반환값: 삭제된 행 수
  Future<int> deleteHistory(int historyId) async {
    final db = await _getDatabase();
    return await db.delete(
      'history',
      where: 'id = ?',
      whereArgs: [historyId],
    );
  }

  /// 레시피의 모든 히스토리 삭제
  ///
  /// [recipeId] 레시피 ID
  ///
  /// 반환값: 삭제된 행 수
  Future<int> deleteAllHistoryByRecipeId(int recipeId) async {
    final db = await _getDatabase();
    return await db.delete(
      'history',
      where: 'recipeId = ?',
      whereArgs: [recipeId],
    );
  }

  /// 히스토리 변경 사항 분석
  ///
  /// [oldRecipe] 변경 전 레시피
  /// [newRecipe] 변경 후 레시피
  ///
  /// 반환값: 변경 사항 설명
  String analyzeChanges(Recipe oldRecipe, Recipe newRecipe) {
    final List<String> changes = [];

    // 제목 변경
    if (oldRecipe.title != newRecipe.title) {
      changes.add('제목 변경: "${oldRecipe.title}" → "${newRecipe.title}"');
    }

    // 카테고리 변경
    if (oldRecipe.category != newRecipe.category) {
      changes.add('카테고리 변경: "${oldRecipe.category}" → "${newRecipe.category}"');
    }

    // 기본 인분 변경
    if (oldRecipe.baseServings != newRecipe.baseServings) {
      changes.add(
          '기본 인분 변경: ${oldRecipe.baseServings} → ${newRecipe.baseServings}');
    }

    // 베이킹 여부 변경
    if (oldRecipe.isBaking != newRecipe.isBaking) {
      changes.add(
          '베이킹 여부 변경: ${oldRecipe.isBaking ? "예" : "아니오"} → ${newRecipe.isBaking ? "예" : "아니오"}');
    }

    // 재료 변경
    if (oldRecipe.ingredients.length != newRecipe.ingredients.length) {
      changes.add(
          '재료 수 변경: ${oldRecipe.ingredients.length}개 → ${newRecipe.ingredients.length}개');
    } else {
      int changedIngredients = 0;
      for (int i = 0; i < oldRecipe.ingredients.length; i++) {
        if (oldRecipe.ingredients[i].toString() !=
            newRecipe.ingredients[i].toString()) {
          changedIngredients++;
        }
      }
      if (changedIngredients > 0) {
        changes.add('재료 변경: $changedIngredients개');
      }
    }

    // 조리법 변경
    if (oldRecipe.instructions.length != newRecipe.instructions.length) {
      changes.add(
          '조리법 단계 변경: ${oldRecipe.instructions.length}단계 → ${newRecipe.instructions.length}단계');
    } else {
      int changedInstructions = 0;
      for (int i = 0; i < oldRecipe.instructions.length; i++) {
        if (oldRecipe.instructions[i].toString() !=
            newRecipe.instructions[i].toString()) {
          changedInstructions++;
        }
      }
      if (changedInstructions > 0) {
        changes.add('조리법 변경: $changedInstructions단계');
      }
    }

    // 이미지 변경
    if (oldRecipe.imagePath != newRecipe.imagePath) {
      changes.add('이미지 변경');
    }

    return changes.isEmpty ? '변경 사항 없음' : changes.join(', ');
  }
}
