import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../models/history.dart';
import '../repositories/recipe_repository.dart';
import '../services/recipe_file_service.dart';

class RecipeProvider with ChangeNotifier {
  final RecipeRepository _repository = RecipeRepository();
  final RecipeFileService _fileService = RecipeFileService();

  List<Recipe> _recipes = [];
  List<History> _history = [];
  String _unitSystem = 'Korea';
  List<String> _categories = ['한식', '일식', '양식', '베이킹'];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Recipe> get recipes => _recipes;
  List<History> get history => _history;
  String get unitSystem => _unitSystem;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 초기화
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _loadRecipes();
      await _loadSettings();
      _clearError();
    } catch (e) {
      _setError('초기화 중 오류가 발생했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 레시피 관련 메서드들
  Future<void> _loadRecipes() async {
    _recipes = await _repository.getAllRecipes();
    notifyListeners();
  }

  Future<void> addRecipe(Recipe recipe) async {
    try {
      _setLoading(true);
      final id = await _repository.insertRecipe(recipe);
      recipe.id = id;
      _recipes.add(recipe);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('레시피 추가 중 오류가 발생했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    try {
      _setLoading(true);
      await _repository.updateRecipe(recipe);
      final index = _recipes.indexWhere((r) => r.id == recipe.id);
      if (index != -1) {
        _recipes[index] = recipe;
      }
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('레시피 수정 중 오류가 발생했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteRecipe(int id) async {
    try {
      _setLoading(true);
      await _repository.deleteRecipe(id);
      _recipes.removeWhere((recipe) => recipe.id == id);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('레시피 삭제 중 오류가 발생했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 설정 관련 메서드들
  Future<void> _loadSettings() async {
    _unitSystem = await _fileService.getUnitSystem();
    _categories = await _fileService.getCategories();
    notifyListeners();
  }

  Future<void> setUnitSystem(String unitSystem) async {
    try {
      await _fileService.setUnitSystem(unitSystem);
      _unitSystem = unitSystem;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('단위 시스템 설정 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> addCategory(String category) async {
    if (category.isNotEmpty && !_categories.contains(category)) {
      try {
        _categories.add(category);
        await _fileService.setCategories(_categories);
        _clearError();
        notifyListeners();
      } catch (e) {
        _setError('카테고리 추가 중 오류가 발생했습니다: $e');
      }
    }
  }

  // 히스토리 관련 메서드들
  Future<void> loadRecipeHistory(int recipeId) async {
    try {
      _history = await _repository.getRecipeHistory(recipeId);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('히스토리 로드 중 오류가 발생했습니다: $e');
    }
  }

  // 파일 관련 메서드들
  Future<String> exportRecipes() async {
    try {
      return await _fileService.exportRecipesToJson(_recipes);
    } catch (e) {
      _setError('레시피 내보내기 중 오류가 발생했습니다: $e');
      rethrow;
    }
  }

  Future<void> importRecipes(String filePath) async {
    try {
      _setLoading(true);
      final importedRecipes =
          await _fileService.importRecipesFromJson(filePath);

      for (final recipe in importedRecipes) {
        await _repository.insertRecipe(recipe);
      }

      await _loadRecipes();
      _clearError();
    } catch (e) {
      _setError('레시피 가져오기 중 오류가 발생했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 유틸리티 메서드들
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // 검색 및 필터링
  List<Recipe> searchRecipes(String query) {
    if (query.isEmpty) return _recipes;

    return _recipes.where((recipe) {
      return recipe.title.toLowerCase().contains(query.toLowerCase()) ||
          recipe.category.toLowerCase().contains(query.toLowerCase()) ||
          recipe.ingredients.any((ingredient) =>
              ingredient.toLowerCase().contains(query.toLowerCase()));
    }).toList();
  }

  List<Recipe> getRecipesByCategory(String category) {
    return _recipes.where((recipe) => recipe.category == category).toList();
  }
}
