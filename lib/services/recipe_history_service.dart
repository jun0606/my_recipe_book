/// 레시피 히스토리 관리 서비스
/// 수쉐프 모드 사용 기록을 저장, 조회, 분석하는 서비스입니다.

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/recipe_history.dart';

class RecipeHistoryService {
  static const String _historyFileName = 'recipe_history.json';
  static const int _maxHistoryCount = 1000; // 최대 저장 개수

  static RecipeHistoryService? _instance;
  static RecipeHistoryService get instance =>
      _instance ??= RecipeHistoryService._();

  RecipeHistoryService._();

  List<RecipeHistory> _histories = [];
  bool _isLoaded = false;

  /// 히스토리 파일 경로
  Future<String> get _historyFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_historyFileName';
  }

  /// 히스토리 로드
  Future<void> loadHistories() async {
    if (_isLoaded) return;

    try {
      final filePath = await _historyFilePath;
      final file = File(filePath);

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final jsonList = json.decode(jsonString) as List;

        _histories = jsonList
            .map((json) => RecipeHistory.fromJson(json as Map<String, dynamic>))
            .toList();

        // 날짜순 정렬 (최신순)
        _histories.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }

      _isLoaded = true;
    } catch (e) {
      print('히스토리 로드 오류: $e');
      _histories = [];
      _isLoaded = true;
    }
  }

  /// 히스토리 저장
  Future<void> saveHistories() async {
    try {
      final filePath = await _historyFilePath;
      final file = File(filePath);

      final jsonList = _histories.map((history) => history.toJson()).toList();
      final jsonString = json.encode(jsonList);

      await file.writeAsString(jsonString);
    } catch (e) {
      print('히스토리 저장 오류: $e');
    }
  }

  /// 새 히스토리 추가
  Future<void> addHistory(RecipeHistory history) async {
    await loadHistories();

    _histories.insert(0, history); // 최신 항목을 맨 앞에 추가

    // 최대 개수 초과 시 오래된 항목 제거
    if (_histories.length > _maxHistoryCount) {
      _histories = _histories.take(_maxHistoryCount).toList();
    }

    await saveHistories();
  }

  /// 모든 히스토리 조회
  Future<List<RecipeHistory>> getAllHistories() async {
    await loadHistories();
    return List.unmodifiable(_histories);
  }

  /// 필터링된 히스토리 조회
  Future<List<RecipeHistory>> getFilteredHistories(
      RecipeHistoryFilter filter) async {
    await loadHistories();
    return _histories.where((history) => filter.matches(history)).toList();
  }

  /// 특정 레시피의 히스토리 조회
  Future<List<RecipeHistory>> getHistoriesByRecipe(String recipeTitle) async {
    await loadHistories();
    return _histories
        .where((history) => history.recipeTitle == recipeTitle)
        .toList();
  }

  /// 최근 히스토리 조회
  Future<List<RecipeHistory>> getRecentHistories({int limit = 10}) async {
    await loadHistories();
    return _histories.take(limit).toList();
  }

  /// 성공적인 최적화만 조회
  Future<List<RecipeHistory>> getSuccessfulOptimizations() async {
    await loadHistories();
    return _histories
        .where((history) => history.isSuccessfulOptimization)
        .toList();
  }

  /// 히스토리 통계 생성
  Future<RecipeHistoryStats> getStats() async {
    await loadHistories();
    return RecipeHistoryStats.fromHistories(_histories);
  }

  /// 특정 기간의 통계
  Future<RecipeHistoryStats> getStatsForPeriod(
      DateTime startDate, DateTime endDate) async {
    final filter = RecipeHistoryFilter(
      startDate: startDate,
      endDate: endDate,
    );
    final filteredHistories = await getFilteredHistories(filter);
    return RecipeHistoryStats.fromHistories(filteredHistories);
  }

  /// 히스토리 삭제
  Future<void> deleteHistory(String historyId) async {
    await loadHistories();
    _histories.removeWhere((history) => history.id == historyId);
    await saveHistories();
  }

  /// 모든 히스토리 삭제
  Future<void> clearAllHistories() async {
    _histories.clear();
    await saveHistories();
  }

  /// 히스토리 내보내기 (JSON)
  Future<String> exportHistories() async {
    await loadHistories();
    final jsonList = _histories.map((history) => history.toJson()).toList();
    return json.encode(jsonList);
  }

  /// 히스토리 가져오기 (JSON)
  Future<void> importHistories(String jsonString) async {
    try {
      final jsonList = json.decode(jsonString) as List;
      final importedHistories = jsonList
          .map((json) => RecipeHistory.fromJson(json as Map<String, dynamic>))
          .toList();

      // 기존 히스토리와 병합 (중복 제거)
      await loadHistories();
      final existingIds = _histories.map((h) => h.id).toSet();
      final newHistories =
          importedHistories.where((h) => !existingIds.contains(h.id)).toList();

      _histories.addAll(newHistories);
      _histories.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // 최대 개수 제한
      if (_histories.length > _maxHistoryCount) {
        _histories = _histories.take(_maxHistoryCount).toList();
      }

      await saveHistories();
    } catch (e) {
      throw Exception('히스토리 가져오기 실패: $e');
    }
  }

  /// 사용자 선호도 분석
  Future<Map<String, dynamic>> getUserPreferences() async {
    final stats = await getStats();

    return {
      'favoriteCategories': stats.categoryDistribution.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
        ..take(3).map((e) => e.key).toList(),
      'preferredEnvironment': stats.environmentalPreferences,
      'successRate': stats.successRate,
      'topImprovements': stats.topImprovements,
      'mostUsedType': stats.typeDistribution.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key
          .displayName,
    };
  }

  /// 추천 환경 조건
  Future<Map<String, double>> getRecommendedEnvironment({
    String? category,
    RecipeHistoryType? type,
  }) async {
    await loadHistories();

    var relevantHistories = _histories.where((h) => h.isSuccessfulOptimization);

    if (category != null) {
      relevantHistories =
          relevantHistories.where((h) => h.recipeCategory == category);
    }

    if (type != null) {
      relevantHistories = relevantHistories.where((h) => h.type == type);
    }

    final histories = relevantHistories.toList();

    if (histories.isEmpty) {
      return {'temperature': 26.0, 'humidity': 60.0, 'altitude': 0.0};
    }

    final tempSum = histories
        .map(
            (h) => h.environmentalConditions['temperature']?.toDouble() ?? 26.0)
        .reduce((a, b) => a + b);
    final humiditySum = histories
        .map((h) => h.environmentalConditions['humidity']?.toDouble() ?? 60.0)
        .reduce((a, b) => a + b);
    final altitudeSum = histories
        .map((h) => h.environmentalConditions['altitude']?.toDouble() ?? 0.0)
        .reduce((a, b) => a + b);

    return {
      'temperature': tempSum / histories.length,
      'humidity': humiditySum / histories.length,
      'altitude': altitudeSum / histories.length,
    };
  }

  /// 유사한 레시피 히스토리 찾기
  Future<List<RecipeHistory>> findSimilarHistories(
    String recipeTitle,
    String category, {
    int limit = 5,
  }) async {
    await loadHistories();

    final similar = _histories.where((history) {
      if (history.recipeTitle == recipeTitle) return false; // 동일한 레시피 제외

      // 카테고리가 같거나 제목에 유사한 키워드가 있는 경우
      if (history.recipeCategory == category) return true;

      final titleWords = recipeTitle.toLowerCase().split(' ');
      final historyTitleWords = history.recipeTitle.toLowerCase().split(' ');

      return titleWords.any((word) => historyTitleWords.contains(word));
    }).toList();

    // 성공적인 최적화를 우선으로 정렬
    similar.sort((a, b) {
      if (a.isSuccessfulOptimization && !b.isSuccessfulOptimization) return -1;
      if (!a.isSuccessfulOptimization && b.isSuccessfulOptimization) return 1;
      return b.improvementScore.compareTo(a.improvementScore);
    });

    return similar.take(limit).toList();
  }

  /// 월별 사용 통계
  Future<Map<String, int>> getMonthlyUsageStats() async {
    await loadHistories();

    final monthlyStats = <String, int>{};

    for (final history in _histories) {
      final monthKey =
          '${history.timestamp.year}-${history.timestamp.month.toString().padLeft(2, '0')}';
      monthlyStats[monthKey] = (monthlyStats[monthKey] ?? 0) + 1;
    }

    return monthlyStats;
  }

  /// 개선 트렌드 분석
  Future<Map<String, List<double>>> getImprovementTrends() async {
    await loadHistories();

    final trends = <String, List<double>>{
      'texture': [],
      'flavor': [],
      'appearance': [],
      'overall': [],
    };

    for (final history in _histories.reversed) {
      // 시간순으로 정렬
      final textureImprovement =
          history.afterStatus.textureScore - history.beforeStatus.textureScore;
      final flavorImprovement =
          history.afterStatus.flavorScore - history.beforeStatus.flavorScore;
      final appearanceImprovement = history.afterStatus.appearanceScore -
          history.beforeStatus.appearanceScore;

      trends['texture']!.add(textureImprovement);
      trends['flavor']!.add(flavorImprovement);
      trends['appearance']!.add(appearanceImprovement);
      trends['overall']!.add(history.improvementScore);
    }

    return trends;
  }
}
