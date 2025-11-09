// Sous Chef 데이터베이스 서비스

import 'package:hive_flutter/hive_flutter.dart';
import '../models/sous_chef_models.dart';
// import '../models/fermentation_models.dart'; // 더 이상 사용하지 않음 - sous_chef_models.dart에 통합됨

class SousChefDatabase {
  static const String _presetsBoxName = 'sous_chef_presets';
  static const String _statesBoxName = 'sous_chef_states';

  static Box<SousChefPreset>? _presetsBox;
  static Box<SousChefRecipeState>? _statesBox;

  /// 데이터베이스 초기화
  static Future<void> initialize() async {
    await Hive.initFlutter();

    // 어댑터 등록
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(BakingTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SousChefPresetAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SousChefRecipeStateAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(AdjustmentHistoryEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(UserFeedbackAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(FeedbackResultAdapter());
    }

    // 발효 모델 어댑터들이 sous_chef_models.dart에 통합되어 더 이상 별도 등록이 필요하지 않음
    // 발효 관련 어댑터들은 SousChefModels의 일부로 자동 등록됨

    // 박스 열기
    _presetsBox = await Hive.openBox<SousChefPreset>(_presetsBoxName);
    _statesBox = await Hive.openBox<SousChefRecipeState>(_statesBoxName);
  }

  /// 프리셋 관련 메서드들
  static Box<SousChefPreset> get presetsBox {
    if (_presetsBox == null) {
      throw Exception(
          'SousChefDatabase not initialized. Call initialize() first.');
    }
    return _presetsBox!;
  }

  /// 레시피 상태 관련 메서드들
  static Box<SousChefRecipeState> get statesBox {
    if (_statesBox == null) {
      throw Exception(
          'SousChefDatabase not initialized. Call initialize() first.');
    }
    return _statesBox!;
  }

  // === 프리셋 관리 ===

  /// 모든 프리셋 가져오기
  static List<SousChefPreset> getAllPresets() {
    return presetsBox.values.toList();
  }

  /// 베이킹 타입별 프리셋 가져오기
  static List<SousChefPreset> getPresetsByBakingType(BakingType bakingType) {
    return presetsBox.values
        .where((preset) => _getPresetBakingType(preset) == bakingType)
        .toList();
  }

  /// 프리셋 저장
  static Future<void> savePreset(SousChefPreset preset) async {
    await presetsBox.put(preset.id, preset);
  }

  /// 프리셋 삭제
  static Future<void> deletePreset(String presetId) async {
    await presetsBox.delete(presetId);
  }

  /// 프리셋 사용 횟수 증가
  static Future<void> incrementPresetUsage(String presetId) async {
    final preset = presetsBox.get(presetId);
    if (preset != null) {
      final updatedPreset = SousChefPreset(
        id: preset.id,
        name: preset.name,
        colorTag: preset.colorTag,
        tags: preset.tags,
        options: preset.options,
        createdAt: preset.createdAt,
        usageCount: preset.usageCount + 1,
        successRate: preset.successRate,
      );
      await savePreset(updatedPreset);
    }
  }

  /// 프리셋 성공률 업데이트
  static Future<void> updatePresetSuccessRate(
      String presetId, double successRate) async {
    final preset = presetsBox.get(presetId);
    if (preset != null) {
      final updatedPreset = SousChefPreset(
        id: preset.id,
        name: preset.name,
        colorTag: preset.colorTag,
        tags: preset.tags,
        options: preset.options,
        createdAt: preset.createdAt,
        usageCount: preset.usageCount,
        successRate: successRate,
      );
      await savePreset(updatedPreset);
    }
  }

  // === 레시피 상태 관리 ===

  /// 레시피 상태 가져오기
  static SousChefRecipeState? getRecipeState(String recipeId) {
    return statesBox.get(recipeId);
  }

  /// 레시피 상태 저장
  static Future<void> saveRecipeState(SousChefRecipeState state) async {
    await statesBox.put(state.recipeId, state);
  }

  /// 레시피 상태 삭제
  static Future<void> deleteRecipeState(String recipeId) async {
    await statesBox.delete(recipeId);
  }

  /// 모든 레시피 상태 가져오기
  static List<SousChefRecipeState> getAllRecipeStates() {
    return statesBox.values.toList();
  }

  // === 유틸리티 메서드들 ===

  /// 프리셋에서 베이킹 타입 추출 (옵션에서 유추)
  static BakingType _getPresetBakingType(SousChefPreset preset) {
    // 프리셋 옵션을 분석하여 베이킹 타입 유추
    final options = preset.options;

    if (options.containsKey('fermentation')) {
      return BakingType.bread;
    } else if (options.containsKey('mixing')) {
      return BakingType.cake;
    } else if (options.containsKey('dough')) {
      return BakingType.cookie;
    } else if (options.containsKey('frying')) {
      return BakingType.fried;
    } else if (options.containsKey('freezing')) {
      return BakingType.iceCream;
    }

    return BakingType.etc;
  }

  /// 인기 프리셋 가져오기 (사용 횟수 기준)
  static List<SousChefPreset> getPopularPresets({int limit = 5}) {
    final presets = getAllPresets();
    presets.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    return presets.take(limit).toList();
  }

  /// 성공률 높은 프리셋 가져오기
  static List<SousChefPreset> getHighSuccessRatePresets({
    double minSuccessRate = 0.8,
    int limit = 5,
  }) {
    final presets = getAllPresets()
        .where((preset) => preset.successRate >= minSuccessRate)
        .toList();
    presets.sort((a, b) => b.successRate.compareTo(a.successRate));
    return presets.take(limit).toList();
  }

  /// 데이터베이스 정리 (사용하지 않는 데이터 삭제)
  static Future<void> cleanup() async {
    // 30일 이상 사용하지 않은 프리셋 삭제
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    final presetsToDelete = <String>[];

    for (final preset in getAllPresets()) {
      if (preset.createdAt.isBefore(cutoffDate) && preset.usageCount == 0) {
        presetsToDelete.add(preset.id);
      }
    }

    for (final presetId in presetsToDelete) {
      await deletePreset(presetId);
    }
  }

  /// 데이터베이스 닫기
  static Future<void> close() async {
    await _presetsBox?.close();
    await _statesBox?.close();
  }
}
