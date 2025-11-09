import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart' as excel;
// import 'package:archive/archive_io.dart'; // 사용하지 않음
import '../models/recipe.dart';
import '../repositories/local_storage_repository.dart';

class RecipeFileService {
  final LocalStorageRepository? _repository;

  RecipeFileService([this._repository]);

  // SharedPreferences 관련
  Future<String> getUnitSystem() async {
    try {
      return await _repository.loadPreference<String>('unitSystem') ?? 'Korea';
    } catch (e) {
      throw Exception('단위 시스템 설정을 불러오는데 실패했습니다: $e');
    }
  }

  Future<void> setUnitSystem(String unitSystem) async {
    try {
      await _repository.savePreference('unitSystem', unitSystem);
    } catch (e) {
      throw Exception('단위 시스템 설정 저장에 실패했습니다: $e');
    }
  }

  Future<List<String>> getCategories() async {
    try {
      return await _repository.loadPreference<List<String>>('categories') ??
          ['한식', '일식', '양식', '베이킹'];
    } catch (e) {
      throw Exception('카테고리 목록을 불러오는데 실패했습니다: $e');
    }
  }

  Future<void> setCategories(List<String> categories) async {
    try {
      await _repository.savePreference('categories', categories);
    } catch (e) {
      throw Exception('카테고리 목록 저장에 실패했습니다: $e');
    }
  }

  // 파일 백업/복원
  Future<String> exportRecipesToJson(List<Recipe> recipes) async {
    try {
      await _repository.saveModelList(
          'recipes_backup.json', recipes, (recipe) => recipe.toJson());

      final directory = await getApplicationDocumentsDirectory();
      return '${directory.path}/recipes_backup.json';
    } catch (e) {
      throw Exception('레시피 내보내기에 실패했습니다: $e');
    }
  }

  Future<List<Recipe>> importRecipesFromJson(String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final List<dynamic> jsonData = json.decode(jsonString);

      return jsonData.map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      throw Exception('레시피 가져오기에 실패했습니다: $e');
    }
  }

  // Excel 내보내기
  Future<String> exportRecipesToExcel(List<Recipe> recipes) async {
    try {
      final excel.Excel excelFile = excel.Excel.createExcel();
      final sheet = excelFile['Recipes'];

      // 헤더 추가
      sheet.appendRow([
        excel.TextCellValue('제목'),
        excel.TextCellValue('카테고리'),
        excel.TextCellValue('재료'),
        excel.TextCellValue('조리법'),
        excel.TextCellValue('기본 인분'),
      ]);

      // 데이터 추가
      for (final recipe in recipes) {
        sheet.appendRow([
          excel.TextCellValue(recipe.title),
          excel.TextCellValue(recipe.category),
          excel.TextCellValue(recipe.ingredients.join(', ')),
          excel.TextCellValue(recipe.instructions.join('\n')),
          excel.TextCellValue(recipe.baseServings.toString()),
        ]);
      }

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/recipes_export.xlsx');
      await file.writeAsBytes(excelFile.encode()!);

      return file.path;
    } catch (e) {
      throw Exception('Excel 내보내기에 실패했습니다: $e');
    }
  }

  // 이미지 파일 관리
  Future<String> saveRecipeImage(String imagePath, int recipeId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final recipeImagesDir = Directory('${directory.path}/recipe_images');

      if (!await recipeImagesDir.exists()) {
        await recipeImagesDir.create(recursive: true);
      }

      final sourceFile = File(imagePath);
      final targetPath = '${recipeImagesDir.path}/recipe_$recipeId.jpg';
      await sourceFile.copy(targetPath);

      return targetPath;
    } catch (e) {
      throw Exception('이미지 저장에 실패했습니다: $e');
    }
  }

  Future<void> deleteRecipeImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('이미지 삭제에 실패했습니다: $e');
    }
  }
}
