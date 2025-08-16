import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/recipe.dart';
import '../models/history.dart';

class RecipeRepository {
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path, 'recipes.db');

    return openDatabase(
      path,
      version: 6,
      onCreate: _createTables,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        title TEXT, 
        category TEXT,
        ingredients TEXT, 
        instructions TEXT, 
        imagePath TEXT,
        baseServings INTEGER DEFAULT 1, 
        isBaking INTEGER DEFAULT 0,
        targetSplitAmount REAL,
        targetSplitCount INTEGER,
        calculatedRemainingWeight REAL,
        totalIngredientWeight REAL,
        parentId INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        recipeId INTEGER,
        action TEXT,
        timestamp TEXT,
        details TEXT,
        FOREIGN KEY (recipeId) REFERENCES recipes (id)
      )
    ''');
  }

  Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    // 데이터베이스 업그레이드 로직
  }

  // CRUD 작업들
  Future<List<Recipe>> getAllRecipes() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('recipes');
      return List.generate(maps.length, (i) => Recipe.fromJson(maps[i]));
    } catch (e) {
      throw Exception('레시피 목록을 불러오는데 실패했습니다: $e');
    }
  }

  Future<int> insertRecipe(Recipe recipe) async {
    try {
      final db = await database;
      return await db.insert('recipes', recipe.toJson());
    } catch (e) {
      throw Exception('레시피 저장에 실패했습니다: $e');
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    try {
      final db = await database;
      await db.update(
        'recipes',
        recipe.toJson(),
        where: 'id = ?',
        whereArgs: [recipe.id],
      );
    } catch (e) {
      throw Exception('레시피 수정에 실패했습니다: $e');
    }
  }

  Future<void> deleteRecipe(int id) async {
    try {
      final db = await database;
      await db.delete('recipes', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('레시피 삭제에 실패했습니다: $e');
    }
  }

  // History 관련 메서드들
  Future<List<History>> getRecipeHistory(int recipeId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'history',
        where: 'recipeId = ?',
        whereArgs: [recipeId],
        orderBy: 'timestamp DESC',
      );
      return List.generate(maps.length, (i) => History.fromJson(maps[i]));
    } catch (e) {
      throw Exception('히스토리를 불러오는데 실패했습니다: $e');
    }
  }

  Future<void> addHistory(History history) async {
    try {
      final db = await database;
      await db.insert('history', history.toJson());
    } catch (e) {
      throw Exception('히스토리 저장에 실패했습니다: $e');
    }
  }
}
