/// 빵 분석 시스템 통합 인터페이스 타입 정의
/// 각 모듈이 통합 분석 결과를 효과적으로 활용할 수 있도록 하는 인터페이스

// ComprehensiveIngredientAnalysis 타입 import 추가
import 'comprehensive_types.dart';
import '../types/unified_types.dart';
import '../../services/ingredient_analysis_hub_v2.dart';
import '../../services/analysis_cache_manager.dart';

/// 재료 분석 결과를 사용하는 모듈 인터페이스
abstract class IngredientAnalysisConsumer {
  /// 통합 분석 결과를 활용하여 모듈별 계산 수행
  Future<Map<String, dynamic>> calculateWithIngredientEffects(
      Map<String, dynamic> inputs,
      ComprehensiveIngredientAnalysis ingredientAnalysis);

  /// 모듈이 필요로 하는 효과 데이터 키들
  List<String> get requiredEffectKeys;

  /// 모듈별 효과 가중치 (중요도에 따른 가중치)
  Map<String, double> get effectWeights;
}

/// 믹싱 모듈 인터페이스
abstract class MixingAnalysisConsumer implements IngredientAnalysisConsumer {
  @override
  Future<Map<String, dynamic>> calculateWithIngredientEffects(
      Map<String, dynamic> inputs,
      ComprehensiveIngredientAnalysis ingredientAnalysis);

  @override
  List<String> get requiredEffectKeys => [
        'glutenFormationImpact',
        'hydrationAdjustment',
        'mixingTimeAdjustment',
        'speedProfileAdjustment',
      ];

  @override
  Map<String, double> get effectWeights => {
        'glutenFormationImpact': 0.8,
        'hydrationAdjustment': 0.6,
        'mixingTimeAdjustment': 0.7,
        'speedProfileAdjustment': 0.5,
      };
}

/// 반죽 모듈 인터페이스
abstract class DoughAnalysisConsumer implements IngredientAnalysisConsumer {
  @override
  Future<Map<String, dynamic>> calculateWithIngredientEffects(
      Map<String, dynamic> inputs,
      ComprehensiveIngredientAnalysis ingredientAnalysis);

  @override
  List<String> get requiredEffectKeys => [
        'elasticityModifier',
        'extensibilityModifier',
        'gasRetentionModifier',
        'doughTemperatureModifier',
      ];

  @override
  Map<String, double> get effectWeights => {
        'elasticityModifier': 0.7,
        'extensibilityModifier': 0.8,
        'gasRetentionModifier': 0.6,
        'doughTemperatureModifier': 0.5,
      };
}

/// 발효 모듈 인터페이스
abstract class FermentationAnalysisConsumer
    implements IngredientAnalysisConsumer {
  @override
  Future<Map<String, dynamic>> calculateWithIngredientEffects(
      Map<String, dynamic> inputs,
      ComprehensiveIngredientAnalysis ingredientAnalysis);

  @override
  List<String> get requiredEffectKeys => [
        'osmoticStressLevel',
        'yeastActivityModifier',
        'fermentationTimeModifier',
        'humidityRequirement',
      ];

  @override
  Map<String, double> get effectWeights => {
        'osmoticStressLevel': 0.9,
        'yeastActivityModifier': 0.8,
        'fermentationTimeModifier': 0.7,
        'humidityRequirement': 0.6,
      };
}

/// 굽기 모듈 인터페이스
abstract class BakingAnalysisConsumer implements IngredientAnalysisConsumer {
  @override
  Future<Map<String, dynamic>> calculateWithIngredientEffects(
      Map<String, dynamic> inputs,
      ComprehensiveIngredientAnalysis ingredientAnalysis);

  @override
  List<String> get requiredEffectKeys => [
        'temperatureAdjustment',
        'bakingTimeModifier',
        'steamRequirement',
        'crustColorModifier',
      ];

  @override
  Map<String, double> get effectWeights => {
        'temperatureAdjustment': 0.8,
        'bakingTimeModifier': 0.7,
        'steamRequirement': 0.5,
        'crustColorModifier': 0.6,
      };
}

/// 모듈 등록 인터페이스
abstract class IngredientAnalysisModuleRegistry {
  /// 모듈 등록
  void registerModule(String moduleId, IngredientAnalysisConsumer module);

  /// 모듈 조회
  IngredientAnalysisConsumer? getModule(String moduleId);

  /// 모든 등록된 모듈 조회
  Map<String, IngredientAnalysisConsumer> getAllModules();

  /// 모듈 제거
  void unregisterModule(String moduleId);
}

/// 통합 분석 서비스 인터페이스
abstract class IntegratedAnalysisService {
  /// 재료 기반 통합 분석 수행
  Future<ComprehensiveIngredientAnalysis> analyzeIngredients(
    List<UnifiedIngredient> ingredients,
    String breadType, {
    String? recipeTitle,
    double flourWeight,
    double environmentTemperature,
    double doughTemperature,
  });

  /// 캐시를 활용한 분석 수행
  Future<ComprehensiveIngredientAnalysis> analyzeWithCache(
    List<UnifiedIngredient> ingredients,
    String breadType, {
    String? recipeTitle,
    double flourWeight,
    double environmentTemperature,
    double doughTemperature,
    Duration? cacheExpiration,
  });

  /// 특정 모듈에 대한 분석 수행
  Future<Map<String, dynamic>> analyzeForModule(
    String moduleId,
    Map<String, dynamic> inputs,
    List<UnifiedIngredient> ingredients,
    String breadType,
  );

  /// 캐시 무효화
  void invalidateCache(
    List<UnifiedIngredient> ingredients,
    String breadType,
    String? recipeTitle,
  );

  /// 캐시 통계 조회
  CacheStatistics getCacheStatistics();

  /// 분석 결과 디버그 출력
  void printAnalysisDebugInfo(ComprehensiveIngredientAnalysis analysis);
}

/// 효과 계산 헬퍼 클래스
class EffectCalculator {
  /// 효과 값 추출 및 검증
  static double extractEffectValue(
    Map<String, dynamic> effects,
    String effectKey,
    double defaultValue,
  ) {
    if (!effects.containsKey(effectKey)) {
      return defaultValue;
    }

    final value = effects[effectKey];
    if (value is num) {
      return value.toDouble();
    } else if (value is Map<String, dynamic>) {
      // 중첩된 효과 데이터의 경우 첫 번째 값 사용
      final firstValue = value.values.firstWhere(
        (v) => v is num,
        orElse: () => defaultValue,
      );
      return firstValue is num ? firstValue.toDouble() : defaultValue;
    }

    return defaultValue;
  }

  /// 효과 가중 평균 계산
  static double calculateWeightedAverage(
    Map<String, dynamic> effects,
    Map<String, double> weights,
  ) {
    double weightedSum = 0.0;
    double totalWeight = 0.0;

    for (final entry in weights.entries) {
      final effectKey = entry.key;
      final weight = entry.value;

      if (effects.containsKey(effectKey)) {
        final value = extractEffectValue(effects, effectKey, 1.0);
        weightedSum += value * weight;
        totalWeight += weight;
      }
    }

    return totalWeight > 0 ? weightedSum / totalWeight : 1.0;
  }

  /// 효과 범위 제한
  static double clampEffectValue(
    double value,
    double minValue,
    double maxValue,
  ) {
    return value.clamp(minValue, maxValue);
  }

  /// 효과 스케일링
  static double scaleEffectValue(
    double value,
    double originalMin,
    double originalMax,
    double targetMin,
    double targetMax,
  ) {
    if (originalMax == originalMin) return targetMin;

    final normalizedValue = (value - originalMin) / (originalMax - originalMin);
    return targetMin + normalizedValue * (targetMax - targetMin);
  }
}

/// 효과 검증 헬퍼 클래스
class EffectValidator {
  /// 효과 값 유효성 검증
  static bool isValidEffectValue(double value,
      {double min = -10.0, double max = 10.0}) {
    return value >= min && value <= max && value.isFinite && !value.isNaN;
  }

  /// 효과 맵 유효성 검증
  static bool isValidEffectMap(
      Map<String, dynamic> effects, List<String> requiredKeys) {
    for (final key in requiredKeys) {
      if (!effects.containsKey(key)) {
        return false;
      }

      final value = effects[key];
      if (value is! num || !isValidEffectValue(value.toDouble())) {
        return false;
      }
    }

    return true;
  }

  /// 효과 값 정규화
  static Map<String, dynamic> normalizeEffects(
    Map<String, dynamic> effects,
    Map<String, double> ranges, // key -> maxAbsValue
  ) {
    final normalized = <String, dynamic>{};

    effects.forEach((key, value) {
      if (value is num) {
        final maxAbsValue = ranges[key] ?? 2.0;
        final clampedValue = value.toDouble().clamp(-maxAbsValue, maxAbsValue);
        normalized[key] = clampedValue / maxAbsValue; // -1.0 ~ 1.0 범위로 정규화
      } else {
        normalized[key] = value;
      }
    });

    return normalized;
  }
}

/// 모듈 통합 헬퍼 클래스
class ModuleIntegrationHelper {
  /// 모듈별 효과 데이터 추출
  static Map<String, dynamic> extractModuleEffects(
    ComprehensiveIngredientAnalysis analysis,
    IngredientAnalysisConsumer module,
  ) {
    final effects = <String, dynamic>{};

    // 모듈별 효과 맵에서 데이터 추출
    final mixingEffects = analysis.mixingEffects;
    final doughEffects = analysis.doughEffects;
    final fermentationEffects = analysis.fermentationEffects;
    final bakingEffects = analysis.bakingEffects;

    // 모듈이 필요로 하는 효과들만 추출
    for (final effectKey in module.requiredEffectKeys) {
      if (mixingEffects.containsKey(effectKey)) {
        effects[effectKey] = mixingEffects[effectKey];
      } else if (doughEffects.containsKey(effectKey)) {
        effects[effectKey] = doughEffects[effectKey];
      } else if (fermentationEffects.containsKey(effectKey)) {
        effects[effectKey] = fermentationEffects[effectKey];
      } else if (bakingEffects.containsKey(effectKey)) {
        effects[effectKey] = bakingEffects[effectKey];
      }
    }

    return effects;
  }

  /// 모듈별 가중 평균 계산
  static double calculateModuleWeightedAverage(
    ComprehensiveIngredientAnalysis analysis,
    IngredientAnalysisConsumer module,
  ) {
    final effects = extractModuleEffects(analysis, module);
    return EffectCalculator.calculateWeightedAverage(
        effects, module.effectWeights);
  }

  /// 모듈별 효과 검증
  static bool validateModuleEffects(
    ComprehensiveIngredientAnalysis analysis,
    IngredientAnalysisConsumer module,
  ) {
    final effects = extractModuleEffects(analysis, module);
    return EffectValidator.isValidEffectMap(effects, module.requiredEffectKeys);
  }
}

/// 통합 분석 이벤트 클래스들
abstract class IngredientAnalysisEvent {
  final DateTime timestamp;
  final String analysisId;

  IngredientAnalysisEvent({
    required this.analysisId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class IngredientAnalysisStartedEvent extends IngredientAnalysisEvent {
  final List<UnifiedIngredient> ingredients;
  final String breadType;

  IngredientAnalysisStartedEvent({
    required super.analysisId,
    required this.ingredients,
    required this.breadType,
    super.timestamp,
  });
}

class IngredientAnalysisCompletedEvent extends IngredientAnalysisEvent {
  final ComprehensiveIngredientAnalysis analysisResult;

  IngredientAnalysisCompletedEvent({
    required super.analysisId,
    required this.analysisResult,
    super.timestamp,
  });
}

class IngredientAnalysisFailedEvent extends IngredientAnalysisEvent {
  final String errorMessage;
  final dynamic error;

  IngredientAnalysisFailedEvent({
    required super.analysisId,
    required this.errorMessage,
    this.error,
    super.timestamp,
  });
}

class ModuleAnalysisCompletedEvent extends IngredientAnalysisEvent {
  final String moduleId;
  final Map<String, dynamic> moduleResult;

  ModuleAnalysisCompletedEvent({
    required super.analysisId,
    required this.moduleId,
    required this.moduleResult,
    super.timestamp,
  });
}

/// 캐시 통계
abstract class CacheStatistics {
  int get totalEntries;
  int get expiredEntries;
  int get maxCacheSize;
  Duration get cacheDuration;
  double get averageAgeMinutes;
  double get memoryUsageMB;
}

/// 기본 캐시 통계 구현
class CacheStatisticsImpl implements CacheStatistics {
  @override
  final int totalEntries;
  @override
  final int expiredEntries;
  @override
  final int maxCacheSize;
  @override
  final Duration cacheDuration;
  @override
  final double averageAgeMinutes;
  @override
  final double memoryUsageMB;

  const CacheStatisticsImpl({
    required this.totalEntries,
    required this.expiredEntries,
    required this.maxCacheSize,
    required this.cacheDuration,
    required this.averageAgeMinutes,
    required this.memoryUsageMB,
  });

  factory CacheStatisticsImpl.fromMap(Map<String, dynamic> map) {
    return CacheStatisticsImpl(
      totalEntries: map['totalEntries'] ?? 0,
      expiredEntries: map['expiredEntries'] ?? 0,
      maxCacheSize: map['maxCacheSize'] ?? 50,
      cacheDuration: Duration(hours: map['cacheDurationHours'] ?? 24),
      averageAgeMinutes: (map['averageAgeMinutes'] as num?)?.toDouble() ?? 0.0,
      memoryUsageMB: (map['memoryUsageMB'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
