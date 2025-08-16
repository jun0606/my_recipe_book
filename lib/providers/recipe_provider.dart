import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'package:excel/excel.dart' as excel;
import 'package:archive/archive_io.dart';
import '../models/recipe.dart';
import '../models/history.dart';

class RecipeProvider with ChangeNotifier {
  List<Recipe> _recipes = [];
  List<History> _history = [];
  String _unitSystem = 'Korea';
  List<String> _categories = ['한식', '일식', '양식', '베이킹'];
  bool _isLoading = false;

  RecipeProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    await loadCategories();
  }

  String? _errorMessage;

  // Getters
  List<Recipe> get recipes => _recipes;
  List<History> get history => _history;
  String get unitSystem => _unitSystem;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<Database> _getDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path, 'recipes.db');
    return openDatabase(
      path,
      version: 8,
      onCreate: (db, version) async {
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
            parentId INTEGER,
            fermentationSteps TEXT,
            ovenSteps TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE history (
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            recipeId INTEGER,
            modifiedDate TEXT, 
            changes TEXT, 
            recipeState TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE history ADD COLUMN recipeState TEXT');
        }
        if (oldVersion < 3) {
          await db.execute(
              'ALTER TABLE recipes ADD COLUMN baseServings INTEGER DEFAULT 1');
        }
        if (oldVersion < 4) {
          await db.execute(
              'ALTER TABLE recipes ADD COLUMN isBaking INTEGER DEFAULT 0');
        }
        if (oldVersion < 5) {
          await db
              .execute('ALTER TABLE recipes ADD COLUMN targetSplitAmount REAL');
          await db.execute(
              'ALTER TABLE recipes ADD COLUMN targetSplitCount INTEGER');
          await db.execute(
              'ALTER TABLE recipes ADD COLUMN calculatedRemainingWeight REAL');
          await db.execute(
              'ALTER TABLE recipes ADD COLUMN totalIngredientWeight REAL');
        }
        if (oldVersion < 6) {
          await db.execute('ALTER TABLE recipes ADD COLUMN parentId INTEGER');
        }
        if (oldVersion < 7) {
          // 버전 7: description, prepTime, cookTime, servings 컬럼 제거 (실제로는 무시)
          // SQLite에서는 컬럼 삭제가 어려우므로, toJson에서 제외하는 방식으로 처리
          print('Database upgraded to version 7: Removed unused columns from toJson');
        }
        if (oldVersion < 8) {
          // 버전 8: fermentationSteps, ovenSteps 컬럼 추가
          await db.execute('ALTER TABLE recipes ADD COLUMN fermentationSteps TEXT');
          await db.execute('ALTER TABLE recipes ADD COLUMN ovenSteps TEXT');
          print('Database upgraded to version 8: Added fermentationSteps and ovenSteps columns');
        }
      },
    );
  }

  Future<void> loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = prefs.getStringList('categories');
      if (categoriesJson != null && categoriesJson.isNotEmpty) {
        _categories = categoriesJson;
      } else {
        // 기본 카테고리 설정
        _categories = ['한식', '일식', '양식', '베이킹'];
        await prefs.setStringList('categories', _categories);
      }
    } catch (e) {
      _categories = ['한식', '일식', '양식', '베이킹'];
    }
    notifyListeners();
  }

  Future<void> addCategory(String category) async {
    if (category.isNotEmpty && !_categories.contains(category)) {
      _categories.add(category);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('categories', _categories);
      notifyListeners();
    }
  }

  Future<void> removeCategory(String category) async {
    final db = await _getDatabase();
    final recipesInCategory =
        await db.query('recipes', where: 'category = ?', whereArgs: [category]);
    if (recipesInCategory.isEmpty) {
      _categories.remove(category);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('categories', _categories);
      notifyListeners();
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    try {
      print(
          'RecipeProvider: addRecipe 호출됨 - 제목: ${recipe.title}, 부모 ID: ${recipe.parentId}');
      final db = await _getDatabase();

      final recipeMap = recipe.toJson();
      print('RecipeProvider: 추가할 레시피 맵 - $recipeMap');

      final id = await db.insert('recipes', recipeMap);
      print(
          'RecipeProvider: 레시피 추가 완료 - 새 ID: $id, 제목: ${recipe.title}, 부모 ID: ${recipe.parentId}');

      await loadRecipes();
      print('RecipeProvider: 레시피 목록 다시 로드됨. 총 레시피 수: ${_recipes.length}');
    } catch (e, stackTrace) {
      print('RecipeProvider: addRecipe 오류 발생 - $e');
      print('RecipeProvider: 스택 트레이스 - $stackTrace');
      rethrow; // 오류를 다시 던져서 호출자가 처리할 수 있도록 함
    }
  }

  Future<void> updateRecipe(Recipe recipe, String changes) async {
    try {
      print(
          'RecipeProvider: updateRecipe 호출됨 - ID: ${recipe.id}, 제목: ${recipe.title}, 부모 ID: ${recipe.parentId}');

      if (recipe.id == null) {
        print('RecipeProvider: 오류 - 레시피 ID가 null입니다. 업데이트할 수 없습니다.');
        throw Exception('레시피 ID가 null입니다. 업데이트할 수 없습니다.');
      }

      final db = await _getDatabase();
      final List<Map<String, dynamic>> oldRecipeMaps =
          await db.query('recipes', where: 'id = ?', whereArgs: [recipe.id]);

      if (oldRecipeMaps.isEmpty) {
        print('RecipeProvider: 오류 - ID ${recipe.id}인 레시피를 찾을 수 없습니다.');
        throw Exception('ID ${recipe.id}인 레시피를 찾을 수 없습니다.');
      }

      String? oldRecipeStateJson;
      final oldRecipe = Recipe.fromJson(oldRecipeMaps.first);
      oldRecipeStateJson = jsonEncode(oldRecipe.toJson());
      print(
          'RecipeProvider: 기존 레시피 정보 - ID: ${oldRecipe.id}, 제목: ${oldRecipe.title}, 부모 ID: ${oldRecipe.parentId}');

      final recipeMap = recipe.toJson();
      print('RecipeProvider: 업데이트할 레시피 맵 - $recipeMap');

      await db.update('recipes', recipeMap,
          where: 'id = ?', whereArgs: [recipe.id]);
      print(
          'RecipeProvider: 레시피 업데이트 완료 - ID: ${recipe.id}, 제목: ${recipe.title}, 부모 ID: ${recipe.parentId}');

      final history = History(
        recipeId: recipe.id!,
        modifiedDate: DateTime.now().toIso8601String(),
        changes: changes,
        recipeState: oldRecipeStateJson,
      );
      await db.insert('history', history.toJson());
      await loadRecipes();
      await loadHistory(recipe.id!);
    } catch (e, stackTrace) {
      print('RecipeProvider: updateRecipe 오류 발생 - $e');
      print('RecipeProvider: 스택 트레이스 - $stackTrace');
      rethrow; // 오류를 다시 던져서 호출자가 처리할 수 있도록 함
    }
  }

  Future<void> deleteRecipe(int recipeId) async {
    final db = await _getDatabase();
    final recipeMaps =
        await db.query('recipes', where: 'id = ?', whereArgs: [recipeId]);
    if (recipeMaps.isNotEmpty && recipeMaps.first['imagePath'] != null) {
      final imagePath = recipeMaps.first['imagePath'] as String;
      final imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    }
    await db.delete('recipes', where: 'id = ?', whereArgs: [recipeId]);
    await db.delete('history', where: 'recipeId = ?', whereArgs: [recipeId]);
    await loadRecipes();
  }

  Future<void> loadRecipes() async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('recipes');
    _recipes = maps.map((map) => Recipe.fromJson(map)).toList();
    notifyListeners();
    print('RecipeProvider: Loaded recipes. Total recipes: ${_recipes.length}');
  }

  Future<void> loadHistory(int recipeId) async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query('history', where: 'recipeId = ?', whereArgs: [recipeId]);
    _history = maps.map((map) => History.fromJson(map)).toList();
    notifyListeners();
  }

  Future<Recipe?> getRecipeById(int id) async {
    print('RecipeProvider: getRecipeById called with ID: $id');
    final db = await _getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query('recipes', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      final recipe = Recipe.fromJson(maps.first);
      print(
          'RecipeProvider: getRecipeById returning recipe: ${recipe.title} (ID: ${recipe.id}, ParentID: ${recipe.parentId})');
      return recipe;
    }
    print('RecipeProvider: getRecipeById returning null for ID: $id');
    return null;
  }

  Future<int> getDerivedCount(int parentId) async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query('recipes', where: 'parentId = ?', whereArgs: [parentId]);
    return maps.length;
  }

  Future<List<Recipe>> getDerivedRecipes(int parentId) async {
    try {
      final db = await _getDatabase();

      // 안전 검사: parentId가 유효한지 확인
      if (parentId <= 0) {
        print(
            'RecipeProvider: getDerivedRecipes - 유효하지 않은 parentId: $parentId');
        return [];
      }

      final List<Map<String, dynamic>> maps = await db
          .query('recipes', where: 'parentId = ?', whereArgs: [parentId]);
      print(
          'RecipeProvider: getDerivedRecipes for parentId $parentId returned ${maps.length} recipes.');

      // 파생 레시피 정보 로깅
      final List<Recipe> derivedRecipes = [];

      // 안전하게 각 맵을 Recipe 객체로 변환
      for (int i = 0; i < maps.length; i++) {
        try {
          final map = maps[i];
          final recipe = Recipe.fromJson(map);
          if (recipe.id != null) {
            print(
                'RecipeProvider: 파생 레시피 $i - ID: ${recipe.id}, 제목: ${recipe.title}, 부모 ID: ${recipe.parentId}');
            derivedRecipes.add(recipe);
          } else {
            print('RecipeProvider: 파생 레시피 $i - ID가 null입니다. 건너뜁니다.');
          }
        } catch (e) {
          print('RecipeProvider: 파생 레시피 $i 변환 중 오류 발생 - $e');
          // 오류가 발생한 레시피는 건너뜀
        }
      }

      print('RecipeProvider: 최종 파생 레시피 수: ${derivedRecipes.length}');
      return derivedRecipes;
    } catch (e, stackTrace) {
      print('RecipeProvider: getDerivedRecipes 오류 발생 - $e');
      print('RecipeProvider: 스택 트레이스 - $stackTrace');
      // 오류가 발생해도 빈 리스트를 반환하여 앱이 중단되지 않도록 함
      return [];
    }
  }

  Future<Recipe?> getParentRecipe(int recipeId) async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query('recipes', where: 'id = ?', whereArgs: [recipeId]);
    if (maps.isNotEmpty) {
      final recipe = Recipe.fromJson(maps.first);
      print(
          'RecipeProvider: getParentRecipe for recipeId $recipeId found recipe ${recipe.title} with parentId ${recipe.parentId}');
      if (recipe.parentId != null) {
        return getRecipeById(recipe.parentId!);
      }
    }
    print(
        'RecipeProvider: getParentRecipe for recipeId $recipeId returned null or no parentId.');
    return null;
  }

  Future<String> exportToExcel(Recipe recipe) async {
    try {
      var excelPackage = excel.Excel.createExcel();
      excel.Sheet sheet = excelPackage['Recipe'];
      sheet.appendRow(
          [excel.TextCellValue('제목'), excel.TextCellValue(recipe.title)]);
      sheet.appendRow(
          [excel.TextCellValue('카테고리'), excel.TextCellValue(recipe.category)]);
      sheet.appendRow([excel.TextCellValue('재료')]);
      sheet.appendRow([
        excel.TextCellValue('이름'),
        excel.TextCellValue('양'),
        excel.TextCellValue('단위')
      ]);
      for (var ingredient in recipe.ingredients) {
        sheet.appendRow([
          excel.TextCellValue(ingredient.name),
          excel.TextCellValue(ingredient.amount.toString()),
          excel.TextCellValue(ingredient.unit),
        ]);
      }
      sheet.appendRow([excel.TextCellValue('')]);
      sheet.appendRow([excel.TextCellValue('조리법')]);
      for (var step in recipe.instructions) {
        sheet.appendRow([excel.TextCellValue(step.toString())]);
      }
      final directory = await getApplicationDocumentsDirectory();
      final path = p.join(directory.path,
          '${recipe.title.replaceAll(' ', '_')}_${DateTime.now().toIso8601String().substring(0, 10)}.xlsx');
      final file = File(path);
      final encoded = excelPackage.encode();
      if (encoded == null) {
        throw Exception('Excel 파일 인코딩에 실패했습니다.');
      }
      await file.writeAsBytes(encoded);
      return path;
    } catch (e) {
      throw Exception('Excel 파일 생성 중 오류: $e');
    }
  }

  Future<void> setUnitSystem(String system) {
    _unitSystem = system;
    notifyListeners();
    return Future.value();
  }

  Future<void> deleteAllRecipes() async {
    final db = await _getDatabase();
    final recipeMaps = await db.query('recipes');
    for (var recipe in recipeMaps) {
      if (recipe['imagePath'] != null) {
        final imageFile = File(recipe['imagePath'] as String);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      }
    }
    await db.delete('recipes');
    await db.delete('history');
    await loadRecipes();
    _history = [];
    notifyListeners();
  }

  Future<String> exportAllRecipes() async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> recipeMaps = await db.query('recipes');
    final List<Map<String, dynamic>> historyMaps = await db.query('history');

    final List<Map<String, dynamic>> recipesWithImages = [];
    for (var recipeMap in recipeMaps) {
      final newRecipeMap = Map<String, dynamic>.from(recipeMap);
      if (newRecipeMap['imagePath'] != null) {
        final imageFile = File(newRecipeMap['imagePath']);
        if (await imageFile.exists()) {
          final imageBytes = await imageFile.readAsBytes();
          newRecipeMap['imageData'] = base64Encode(imageBytes);
        }
      }
      recipesWithImages.add(newRecipeMap);
    }

    final Map<String, dynamic> exportData = {
      'recipes': recipesWithImages,
      'history': historyMaps,
    };

    final jsonString = jsonEncode(exportData);
    final archive = Archive();
    archive.addFile(
        ArchiveFile('backup.json', jsonString.length, utf8.encode(jsonString)));

    try {
      final iconData = await rootBundle.load('assets/icon/dinner_dining.png');
      final iconBytes = iconData.buffer.asUint8List();
      archive.addFile(ArchiveFile('icon.png', iconBytes.length, iconBytes));
    } catch (e) {
      // 아이콘 파일을 찾지 못해도 백업은 계속 진행합니다.
      print('Could not find app icon: $e');
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path,
        'my_recipe_book_backup_${DateTime.now().toIso8601String().substring(0, 10)}.zip');
    final zipEncoder = ZipEncoder();
    final file = File(path);
    await file.writeAsBytes(zipEncoder.encode(archive)!);

    return path;
  }

  Future<void> importAllRecipes(String filePath) async {
    try {
      final inputStream = InputFileStream(filePath);
      final archive = ZipDecoder().decodeBuffer(inputStream);

      ArchiveFile? jsonFile;
      for (final file in archive.files) {
        if (file.name == 'backup.json') {
          jsonFile = file;
          break;
        }
      }

      if (jsonFile == null) {
        throw Exception('백업 파일에 backup.json이 포함되어 있지 않습니다.');
      }

      final String contents = utf8.decode(jsonFile.content);
      final Map<String, dynamic> importData = jsonDecode(contents);

      final db = await _getDatabase();
      await db.delete('recipes');
      await db.delete('history');

      final List<dynamic> recipesToImport = importData['recipes'] ?? [];
      for (var recipeMap in recipesToImport) {
        final newRecipeMap =
            Map<String, dynamic>.from(recipeMap as Map<String, dynamic>);
        if (newRecipeMap['imageData'] != null) {
          final imageBytes = base64Decode(newRecipeMap['imageData']);
          final directory = await getApplicationDocumentsDirectory();
          final imagePath = p.join(
              directory.path, '${DateTime.now().millisecondsSinceEpoch}.png');
          final imageFile = File(imagePath);
          await imageFile.writeAsBytes(imageBytes);
          newRecipeMap['imagePath'] = imagePath;
          newRecipeMap.remove('imageData');
        }
        await db.insert('recipes', newRecipeMap);
      }

      final List<dynamic> historyToImport = importData['history'] ?? [];
      for (var historyMap in historyToImport) {
        await db.insert('history', historyMap as Map<String, dynamic>);
      }

      await loadRecipes();
      notifyListeners();
    } catch (e) {
      throw Exception('레시피 데이터 복구 중 오류: $e');
    }
  }
}
