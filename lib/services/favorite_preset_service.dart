// 즐겨찾기 프리셋 관리 서비스
// 사용자의 즐겨찾기 프리셋을 저장, 조회, 관리하는 서비스입니다.

library favorite_preset_service;

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/favorite_preset.dart';
import '../models/recipe_history.dart';
import 'recipe_history_service.dart';

class FavoritePresetService {
  static const String _favoritesFileName = 'favorite_presets.json';
  static const int _maxFavoritesCount = 100; // 최대 즐겨찾기 개수

  static FavoritePresetService? _instance;
  static FavoritePresetService get instance =>
      _instance ??= FavoritePresetService._();

  FavoritePresetService._();

  List<FavoritePreset> _favorites = [];
  bool _isLoaded = false;

  /// 즐겨찾기 파일 경로
  Future<String> get _favoritesFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_favoritesFileName';
  }

  /// 즐겨찾기 로드
  Future<void> loadFavorites() async {
    if (_isLoaded) return;

    try {
      final filePath = await _favoritesFilePath;
      final file = File(filePath);

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final jsonList = json.decode(jsonString) as List;

        _favorites = jsonList
            .map(
                (json) => FavoritePreset.fromJson(json as Map<String, dynamic>))
            .toList();

        // 인기도순 정렬
        _sortFavorites(FavoritePresetSortOption.popularity);
      }

      _isLoaded = true;
    } catch (e) {
      print('즐겨찾기 로드 오류: $e');
      _favorites = [];
      _isLoaded = true;
    }
  }

  /// 즐겨찾기 저장
  Future<void> saveFavorites() async {
    try {
      final filePath = await _favoritesFilePath;
      final file = File(filePath);

      final jsonList = _favorites.map((favorite) => favorite.toJson()).toList();
      final jsonString = json.encode(jsonList);

      await file.writeAsString(jsonString);
    } catch (e) {
      print('즐겨찾기 저장 오류: $e');
    }
  }

  /// 즐겨찾기 추가
  Future<void> addFavorite(FavoritePreset favorite) async {
    await loadFavorites();

    // 중복 확인
    final existingIndex = _favorites.indexWhere((f) =>
        f.originalPresetId == favorite.originalPresetId &&
        f.name == favorite.name);

    if (existingIndex != -1) {
      // 기존 즐겨찾기 업데이트
      _favorites[existingIndex] = favorite;
    } else {
      // 새 즐겨찾기 추가
      _favorites.insert(0, favorite);

      // 최대 개수 초과 시 오래된 항목 제거
      if (_favorites.length > _maxFavoritesCount) {
        _favorites = _favorites.take(_maxFavoritesCount).toList();
      }
    }

    await saveFavorites();
  }

  /// 표준 프리셋을 즐겨찾기에 추가
  Future<void> addStandardPresetToFavorites(
    dynamic standardPreset, {
    Map<String, dynamic>? environmentalConditions,
    Map<String, dynamic>? customizations,
  }) async {
    final favorite = FavoritePreset.fromStandardPreset(
      standardPreset,
      environmentalConditions: environmentalConditions,
      customizations: customizations,
    );

    await addFavorite(favorite);
  }

  /// 커스텀 프리셋 생성 및 추가
  Future<void> createCustomPreset({
    required String name,
    required String description,
    required String category,
    required Map<String, dynamic> presetData,
    required Map<String, dynamic> environmentalConditions,
    List<String>? tags,
    Map<String, dynamic>? customizations,
  }) async {
    final customPreset = FavoritePreset.createCustom(
      name: name,
      description: description,
      category: category,
      presetData: presetData,
      environmentalConditions: environmentalConditions,
      tags: tags,
      customizations: customizations,
    );

    await addFavorite(customPreset);
  }

  /// 모든 즐겨찾기 조회
  Future<List<FavoritePreset>> getAllFavorites() async {
    await loadFavorites();
    return List.unmodifiable(_favorites);
  }

  /// 필터링된 즐겨찾기 조회
  Future<List<FavoritePreset>> getFilteredFavorites(
      FavoritePresetFilter filter) async {
    await loadFavorites();
    return _favorites.where((favorite) => filter.matches(favorite)).toList();
  }

  /// 카테고리별 즐겨찾기 조회
  Future<List<FavoritePreset>> getFavoritesByCategory(String category) async {
    await loadFavorites();
    return _favorites
        .where((favorite) => favorite.category == category)
        .toList();
  }

  /// 인기 즐겨찾기 조회
  Future<List<FavoritePreset>> getPopularFavorites({int limit = 10}) async {
    await loadFavorites();
    final sorted = List<FavoritePreset>.from(_favorites)
      ..sort((a, b) => b.popularityScore.compareTo(a.popularityScore));
    return sorted.take(limit).toList();
  }

  /// 최근 사용한 즐겨찾기 조회
  Future<List<FavoritePreset>> getRecentlyUsedFavorites(
      {int limit = 10}) async {
    await loadFavorites();
    final recent = _favorites.where((f) => f.isRecentlyUsed).toList()
      ..sort((a, b) => b.lastUsedAt.compareTo(a.lastUsedAt));
    return recent.take(limit).toList();
  }

  /// 성공적인 즐겨찾기 조회
  Future<List<FavoritePreset>> getSuccessfulFavorites() async {
    await loadFavorites();
    return _favorites.where((favorite) => favorite.isSuccessful).toList();
  }

  /// 즐겨찾기 사용 기록 업데이트
  Future<void> updateFavoriteUsage(
    String favoriteId, {
    double? successRate,
    double? improvementScore,
  }) async {
    await loadFavorites();

    final index = _favorites.indexWhere((f) => f.id == favoriteId);
    if (index != -1) {
      _favorites[index] = _favorites[index].updateUsage(
        newSuccessRate: successRate,
        newImprovementScore: improvementScore,
      );
      await saveFavorites();
    }
  }

  /// 즐겨찾기 수정
  Future<void> updateFavorite(FavoritePreset updatedFavorite) async {
    await loadFavorites();

    final index = _favorites.indexWhere((f) => f.id == updatedFavorite.id);
    if (index != -1) {
      _favorites[index] = updatedFavorite;
      await saveFavorites();
    }
  }

  /// 즐겨찾기 삭제
  Future<void> deleteFavorite(String favoriteId) async {
    await loadFavorites();
    _favorites.removeWhere((favorite) => favorite.id == favoriteId);
    await saveFavorites();
  }

  /// 모든 즐겨찾기 삭제
  Future<void> clearAllFavorites() async {
    _favorites.clear();
    await saveFavorites();
  }

  /// 즐겨찾기 정렬
  void _sortFavorites(FavoritePresetSortOption sortOption) {
    switch (sortOption) {
      case FavoritePresetSortOption.popularity:
        _favorites
            .sort((a, b) => b.popularityScore.compareTo(a.popularityScore));
        break;
      case FavoritePresetSortOption.recentlyUsed:
        _favorites.sort((a, b) => b.lastUsedAt.compareTo(a.lastUsedAt));
        break;
      case FavoritePresetSortOption.successRate:
        _favorites.sort((a, b) => b.successRate.compareTo(a.successRate));
        break;
      case FavoritePresetSortOption.improvementScore:
        _favorites.sort((a, b) =>
            b.averageImprovementScore.compareTo(a.averageImprovementScore));
        break;
      case FavoritePresetSortOption.usageCount:
        _favorites.sort((a, b) => b.usageCount.compareTo(a.usageCount));
        break;
      case FavoritePresetSortOption.name:
        _favorites.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
  }

  /// 정렬된 즐겨찾기 조회
  Future<List<FavoritePreset>> getSortedFavorites(
      FavoritePresetSortOption sortOption) async {
    await loadFavorites();
    final sorted = List<FavoritePreset>.from(_favorites);

    switch (sortOption) {
      case FavoritePresetSortOption.popularity:
        sorted.sort((a, b) => b.popularityScore.compareTo(a.popularityScore));
        break;
      case FavoritePresetSortOption.recentlyUsed:
        sorted.sort((a, b) => b.lastUsedAt.compareTo(a.lastUsedAt));
        break;
      case FavoritePresetSortOption.successRate:
        sorted.sort((a, b) => b.successRate.compareTo(a.successRate));
        break;
      case FavoritePresetSortOption.improvementScore:
        sorted.sort((a, b) =>
            b.averageImprovementScore.compareTo(a.averageImprovementScore));
        break;
      case FavoritePresetSortOption.usageCount:
        sorted.sort((a, b) => b.usageCount.compareTo(a.usageCount));
        break;
      case FavoritePresetSortOption.name:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return sorted;
  }

  /// 즐겨찾기 통계 생성
  Future<FavoritePresetStats> getStats() async {
    await loadFavorites();
    return FavoritePresetStats.fromPresets(_favorites);
  }

  /// 히스토리 기반 자동 즐겨찾기 추천
  Future<List<Map<String, dynamic>>> getAutoFavoriteRecommendations() async {
    try {
      final histories =
          await RecipeHistoryService.instance.getSuccessfulOptimizations();
      final recommendations = <Map<String, dynamic>>[];

      // 성공적인 히스토리를 분석하여 추천
      final categorySuccess = <String, List<RecipeHistory>>{};

      for (final history in histories) {
        if (!categorySuccess.containsKey(history.recipeCategory)) {
          categorySuccess[history.recipeCategory] = [];
        }
        categorySuccess[history.recipeCategory]!.add(history);
      }

      // 각 카테고리별로 가장 성공적인 패턴 찾기
      for (final entry in categorySuccess.entries) {
        final category = entry.key;
        final categoryHistories = entry.value;

        if (categoryHistories.length >= 3) {
          // 최소 3번 이상 성공
          // 가장 일관된 환경 조건 찾기
          final avgTemp = categoryHistories
                  .map((h) =>
                      h.environmentalConditions['temperature']?.toDouble() ??
                      26.0)
                  .reduce((a, b) => a + b) /
              categoryHistories.length;

          final avgHumidity = categoryHistories
                  .map((h) =>
                      h.environmentalConditions['humidity']?.toDouble() ?? 60.0)
                  .reduce((a, b) => a + b) /
              categoryHistories.length;

          final avgAltitude = categoryHistories
                  .map((h) =>
                      h.environmentalConditions['altitude']?.toDouble() ?? 0.0)
                  .reduce((a, b) => a + b) /
              categoryHistories.length;

          final avgImprovement = categoryHistories
                  .map((h) => h.improvementScore)
                  .reduce((a, b) => a + b) /
              categoryHistories.length;

          recommendations.add({
            'category': category,
            'name': '$category 최적 환경',
            'description': '성공적인 $category 레시피들의 최적 환경 조건',
            'environmentalConditions': {
              'temperature': avgTemp.round(),
              'humidity': avgHumidity.round(),
              'altitude': avgAltitude.round(),
            },
            'successCount': categoryHistories.length,
            'averageImprovement': avgImprovement,
            'confidence': _calculateConfidence(categoryHistories),
          });
        }
      }

      // 신뢰도순으로 정렬
      recommendations.sort((a, b) =>
          (b['confidence'] as double).compareTo(a['confidence'] as double));

      return recommendations.take(5).toList();
    } catch (e) {
      print('자동 추천 생성 오류: $e');
      return [];
    }
  }

  /// 신뢰도 계산
  double _calculateConfidence(List<RecipeHistory> histories) {
    if (histories.isEmpty) return 0.0;

    final avgImprovement =
        histories.map((h) => h.improvementScore).reduce((a, b) => a + b) /
            histories.length;

    final consistency = _calculateConsistency(histories);
    final sampleSize = (histories.length / 10.0).clamp(0.0, 1.0);

    return (avgImprovement * 0.4 + consistency * 0.4 + sampleSize * 0.2)
        .clamp(0.0, 1.0);
  }

  /// 일관성 계산
  double _calculateConsistency(List<RecipeHistory> histories) {
    if (histories.length < 2) return 0.0;

    final improvements = histories.map((h) => h.improvementScore).toList();
    final mean = improvements.reduce((a, b) => a + b) / improvements.length;

    final variance = improvements
            .map((score) => (score - mean) * (score - mean))
            .reduce((a, b) => a + b) /
        improvements.length;

    final standardDeviation = variance > 0 ? variance : 0.0;

    // 표준편차가 낮을수록 일관성이 높음
    return (1.0 - standardDeviation.clamp(0.0, 1.0)).clamp(0.0, 1.0);
  }

  /// 즐겨찾기 내보내기
  Future<String> exportFavorites() async {
    await loadFavorites();
    final jsonList = _favorites.map((favorite) => favorite.toJson()).toList();
    return json.encode(jsonList);
  }

  /// 즐겨찾기 가져오기
  Future<void> importFavorites(String jsonString) async {
    try {
      final jsonList = json.decode(jsonString) as List;
      final importedFavorites = jsonList
          .map((json) => FavoritePreset.fromJson(json as Map<String, dynamic>))
          .toList();

      await loadFavorites();

      // 기존 즐겨찾기와 병합 (중복 제거)
      final existingIds = _favorites.map((f) => f.id).toSet();
      final newFavorites =
          importedFavorites.where((f) => !existingIds.contains(f.id)).toList();

      _favorites.addAll(newFavorites);
      _sortFavorites(FavoritePresetSortOption.popularity);

      // 최대 개수 제한
      if (_favorites.length > _maxFavoritesCount) {
        _favorites = _favorites.take(_maxFavoritesCount).toList();
      }

      await saveFavorites();
    } catch (e) {
      throw Exception('즐겨찾기 가져오기 실패: $e');
    }
  }

  /// 특정 프리셋이 즐겨찾기에 있는지 확인
  Future<bool> isFavorite(String presetId) async {
    await loadFavorites();
    return _favorites
        .any((f) => f.originalPresetId == presetId || f.id == presetId);
  }

  /// 즐겨찾기 검색
  Future<List<FavoritePreset>> searchFavorites(String query) async {
    await loadFavorites();

    if (query.isEmpty) return _favorites;

    final lowerQuery = query.toLowerCase();

    return _favorites.where((favorite) {
      return favorite.name.toLowerCase().contains(lowerQuery) ||
          favorite.description.toLowerCase().contains(lowerQuery) ||
          favorite.category.toLowerCase().contains(lowerQuery) ||
          favorite.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// 사용하지 않는 즐겨찾기 정리
  Future<void> cleanupUnusedFavorites({int daysThreshold = 30}) async {
    await loadFavorites();

    final cutoffDate = DateTime.now().subtract(Duration(days: daysThreshold));

    _favorites.removeWhere((favorite) =>
        favorite.usageCount <= 1 && favorite.lastUsedAt.isBefore(cutoffDate));

    await saveFavorites();
  }

  /// 즐겨찾기 복제
  Future<void> duplicateFavorite(String favoriteId, {String? newName}) async {
    await loadFavorites();

    final original = _favorites.firstWhere((f) => f.id == favoriteId);
    final duplicate = FavoritePreset.createCustom(
      name: newName ?? '${original.name} (복사본)',
      description: original.description,
      category: original.category,
      presetData: Map<String, dynamic>.from(original.presetData),
      environmentalConditions:
          Map<String, dynamic>.from(original.environmentalConditions),
      tags: List<String>.from(original.tags),
      customizations: Map<String, dynamic>.from(original.customizations),
    );

    await addFavorite(duplicate);
  }
}
