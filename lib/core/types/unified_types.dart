// lib/core/types/unified_types.dart
// 통합 타입 시스템 - 모든 모듈에서 공통으로 사용하는 데이터 타입들

import 'dart:convert';
import 'package:my_recipe_book/core/types/environment_types.dart';
import 'package:my_recipe_book/core/communication/event_bus.dart';
import 'package:my_recipe_book/models/recipe.dart';
import 'package:my_recipe_book/models/ingredient.dart';

/// 통합 재료 타입
class UnifiedIngredient {
  final String id;
  final String name;
  final double amount;
  final String unit;
  final Map<String, dynamic> properties;

  const UnifiedIngredient({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
    required this.properties,
  });

  factory UnifiedIngredient.fromJson(Map<String, dynamic> json) {
    try {
      print(
          '📦 [UnifiedIngredient.fromJson] 시작 - ${json['name']}: ${json['amount']}${json['unit']}');

      final id = json['id'] as String? ?? '';
      final name = json['name'] as String? ?? 'Unknown';
      final amount =
          json['amount'] is num ? (json['amount'] as num).toDouble() : 0.0;
      final unit = json['unit'] as String? ?? 'g';
      final properties = Map<String, dynamic>.from(json['properties'] ?? {});

      print(
          '✅ [UnifiedIngredient.fromJson] 성공 - $name: ${amount.toStringAsFixed(1)}$unit');

      return UnifiedIngredient(
        id: id,
        name: name,
        amount: amount,
        unit: unit,
        properties: properties,
      );
    } catch (e) {
      print('❌ [UnifiedIngredient.fromJson] 실패: $e, JSON: $json');
      // 기본값으로 재료 생성
      return UnifiedIngredient(
        id: '',
        name: 'Unknown',
        amount: 0.0,
        unit: 'g',
        properties: {},
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'unit': unit,
      'properties': properties,
    };
  }

  @override
  String toString() => '$name: ${amount.toStringAsFixed(1)}$unit';
}

/// 통합 프로세스 타입
class UnifiedProcess {
  final String id;
  final String type; // 'mixing', 'fermentation', 'baking'
  final String name;
  final Duration duration;
  final Map<String, dynamic> parameters;

  const UnifiedProcess({
    required this.id,
    required this.type,
    required this.name,
    required this.duration,
    required this.parameters,
  });

  factory UnifiedProcess.fromJson(Map<String, dynamic> json) {
    return UnifiedProcess(
      id: json['id'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      duration: Duration(minutes: json['duration_minutes'] as int),
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'duration_minutes': duration.inMinutes,
      'parameters': parameters,
    };
  }

  @override
  String toString() => '$name (${duration.inMinutes}분)';
}

/// 장비 설정
class EquipmentConfig {
  final Map<String, dynamic> settings;

  const EquipmentConfig({
    required this.settings,
  });

  factory EquipmentConfig.defaultConfig() {
    return const EquipmentConfig(settings: {
      'mixerType': 'stand_mixer',
      'ovenType': 'convection',
      'mixerPower': 300,
      'ovenPower': 2000,
    });
  }

  factory EquipmentConfig.empty() {
    return const EquipmentConfig(settings: {});
  }

  factory EquipmentConfig.fromJson(Map<String, dynamic> json) {
    return EquipmentConfig(
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'settings': settings,
    };
  }
}

/// 레시피 메타데이터
class RecipeMetadata {
  final Map<String, dynamic> data;

  const RecipeMetadata({
    required this.data,
  });

  factory RecipeMetadata.empty() {
    return const RecipeMetadata(data: {});
  }

  factory RecipeMetadata.fromJson(Map<String, dynamic> json) {
    return RecipeMetadata(
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
    };
  }
}

/// 통합 레시피 타입
class UnifiedRecipe {
  final String id;
  final String title;
  final List<UnifiedIngredient> ingredients;
  final List<UnifiedProcess> processes;
  final EquipmentConfig equipment;
  final RecipeMetadata metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UnifiedRecipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.processes,
    required this.equipment,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  // 레거시 호환성을 위한 toRecipe 메소드
  Recipe toRecipe() {
    return Recipe(
      id: int.tryParse(id),
      title: title,
      category: 'bread', // 기본 카테고리 설정
      ingredients: ingredients
          .map((ing) => Ingredient(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: ing.name,
                amount: ing.amount,
                unit: ing.unit,
                properties: ing.properties,
              ))
          .toList(),
      instructions: [], // 기본 빈 리스트
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // 레거시 호환성을 위한 fromRecipe 팩토리 메소드
  factory UnifiedRecipe.fromRecipe(Recipe recipe) {
    return UnifiedRecipe(
      id: recipe.id?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: recipe.title,
      ingredients: recipe.ingredients
          .map((ing) => UnifiedIngredient(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: ing.name,
                amount: ing.amount,
                unit: ing.unit,
                properties: ing.properties ?? {},
              ))
          .toList(),
      processes: [], // 기본 빈 리스트
      equipment: EquipmentConfig.empty(),
      metadata: RecipeMetadata.empty(),
      createdAt: recipe.createdAt ?? DateTime.now(),
      updatedAt: recipe.updatedAt ?? DateTime.now(),
    );
  }

  factory UnifiedRecipe.fromJson(Map<String, dynamic> json) {
    print(
        '🔍 [UnifiedRecipe.fromJson] 시작 - ID: ${json['id']}, Title: ${json['title']}');

    // ingredients 필드 안전하게 파싱
    List<UnifiedIngredient> ingredients = [];
    try {
      final ingredientsData = json['ingredients'];
      print(
          '📦 [UnifiedRecipe.fromJson] ingredientsData 타입: ${ingredientsData?.runtimeType}, 값: ${ingredientsData}');

      if (ingredientsData is List) {
        print(
            '🔍 [UnifiedRecipe.fromJson] ingredientsData 길이: ${ingredientsData.length}');

        ingredients = ingredientsData
            .map((ing) {
              try {
                print('🔄 [UnifiedRecipe.fromJson] 재료 데이터 처리: $ing');
                if (ing is Map<String, dynamic>) {
                  final ingredient = UnifiedIngredient.fromJson(ing);
                  print(
                      '✅ [UnifiedRecipe.fromJson] 재료 변환 성공: ${ingredient.name}');
                  return ingredient;
                } else {
                  print(
                      '⚠️ [UnifiedRecipe.fromJson] 재료 데이터가 Map이 아님: $ing (타입: ${ing.runtimeType})');
                  return null;
                }
              } catch (e) {
                print('❌ [UnifiedRecipe.fromJson] 재료 파싱 실패: $e, 데이터: $ing');
                return null;
              }
            })
            .where((ing) => ing != null)
            .cast<UnifiedIngredient>()
            .toList();

        print(
            '✅ [UnifiedRecipe.fromJson] ingredients 파싱 성공: ${ingredients.length}개');
        ingredients.forEach(
            (ing) => print('   - ${ing.name}: ${ing.amount}${ing.unit}'));
      } else {
        print(
            '⚠️ [UnifiedRecipe.fromJson] ingredients가 List 타입이 아님: ${ingredientsData?.runtimeType}');
        if (ingredientsData != null) {
          print('   값: $ingredientsData');
        }
      }
    } catch (e) {
      print('❌ [UnifiedRecipe.fromJson] ingredients 파싱 중 치명적 오류: $e');
      print('   스택 트레이스: ${StackTrace.current}');
    }

    // processes 필드 안전하게 파싱
    List<UnifiedProcess> processes = [];
    try {
      final processesData = json['processes'];
      if (processesData is List) {
        processes = processesData
            .map((proc) {
              try {
                if (proc is Map<String, dynamic>) {
                  return UnifiedProcess.fromJson(proc);
                } else {
                  print('⚠️ [UnifiedRecipe.fromJson] 프로세스 데이터가 Map이 아님: $proc');
                  return null;
                }
              } catch (e) {
                print('❌ [UnifiedRecipe.fromJson] 프로세스 파싱 실패: $e');
                return null;
              }
            })
            .where((proc) => proc != null)
            .cast<UnifiedProcess>()
            .toList();

        print(
            '✅ [UnifiedRecipe.fromJson] processes 파싱 성공: ${processes.length}개');
      }
    } catch (e) {
      print('❌ [UnifiedRecipe.fromJson] processes 파싱 중 오류: $e');
    }

    // equipment와 metadata는 안전하게 파싱
    final equipment = json['equipment'] != null
        ? EquipmentConfig.fromJson(json['equipment'])
        : EquipmentConfig.empty();

    final metadata = json['metadata'] != null
        ? RecipeMetadata.fromJson(json['metadata'])
        : RecipeMetadata.empty();

    final result = UnifiedRecipe(
      id: json['id'] as String? ?? 'unknown',
      title: json['title'] as String? ?? '제목 없음',
      ingredients: ingredients,
      processes: processes,
      equipment: equipment,
      metadata: metadata,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );

    print(
        '🎯 [UnifiedRecipe.fromJson] 완료 - 재료: ${result.ingredients.length}개, 프로세스: ${result.processes.length}개');
    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'ingredients': ingredients.map((ing) => ing.toJson()).toList(),
      'processes': processes.map((proc) => proc.toJson()).toList(),
      'equipment': equipment.toJson(),
      'metadata': metadata.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'UnifiedRecipe: $title\n'
        'Ingredients: ${ingredients.length}\n'
        'Processes: ${processes.length}';
  }
}

/// 분석 결과 타입 (개선된 버전 - 데이터 구조 표준화)
class AnalysisResult {
  final String moduleId;
  final Map<String, dynamic> data;
  final List<String>? temperatureWarnings; // 온도 경고를 별도 필드로 분리
  final DateTime timestamp;
  final double confidence;
  final bool _isSuccessful;
  final String? _errorMessage;

  const AnalysisResult({
    required this.moduleId,
    required this.data,
    this.temperatureWarnings, // 선택적 파라미터로 추가
    required this.timestamp,
    required this.confidence,
    bool isSuccessful = true,
    String? errorMessage,
  })  : _isSuccessful = isSuccessful,
        _errorMessage = errorMessage;

  // 성공 상태의 AnalysisResult 생성
  factory AnalysisResult.success({
    required String moduleId,
    required Map<String, dynamic> data,
    required double confidence,
    DateTime? timestamp,
  }) {
    return AnalysisResult(
      moduleId: moduleId,
      data: data,
      timestamp: timestamp ?? DateTime.now(),
      confidence: confidence,
      isSuccessful: true,
    );
  }

  // 오류 상태의 AnalysisResult 생성
  factory AnalysisResult.error({
    required String moduleId,
    required String errorMessage,
    required DateTime timestamp,
  }) {
    return AnalysisResult(
      moduleId: moduleId,
      data: {},
      timestamp: timestamp,
      confidence: 0.0,
      isSuccessful: false,
      errorMessage: errorMessage,
    );
  }

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      moduleId: json['moduleId'] as String,
      data: Map<String, dynamic>.from(json['data']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      confidence: (json['confidence'] as num).toDouble(),
      isSuccessful: json['isSuccessful'] as bool? ?? true,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moduleId': moduleId,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'confidence': confidence,
      'isSuccessful': _isSuccessful,
      'errorMessage': _errorMessage,
    };
  }

  // 게터 메소드들
  bool get isSuccessful => _isSuccessful;
  String? get errorMessage => _errorMessage;

  // 헬퍼 메소드들
  bool get isError => !_isSuccessful;
  bool get hasError => _errorMessage != null && _errorMessage!.isNotEmpty;
}

// 환경 타입들은 environment_types.dart에서 import됨

/// 이벤트 관련 타입들
abstract class EventData {
  final DateTime timestamp;

  EventData({DateTime? timestamp}) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap();
}

enum SousChefEvent {
  moduleSwitched,
  analysisCompleted,
  analysisStarted,
  errorOccurred,
}

/// 모듈 능력 정의
class ModuleCapabilities {
  final bool supportsRealTimeAnalysis;
  final bool supportsRecipeModification;
  final List<String> supportedProcessTypes;
  final List<String> supportedIngredientTypes;
  final bool supportsEnvironmentAnalysis;
  final bool supportsAdvancedMetrics;

  const ModuleCapabilities({
    this.supportsRealTimeAnalysis = false,
    this.supportsRecipeModification = false,
    this.supportedProcessTypes = const [],
    this.supportedIngredientTypes = const [],
    this.supportsEnvironmentAnalysis = false,
    this.supportsAdvancedMetrics = false,
  });

  factory ModuleCapabilities.basic() {
    return const ModuleCapabilities(
      supportsRealTimeAnalysis: false,
      supportsRecipeModification: false,
      supportedProcessTypes: [],
      supportedIngredientTypes: [],
      supportsEnvironmentAnalysis: false,
      supportsAdvancedMetrics: false,
    );
  }

  factory ModuleCapabilities.advanced() {
    return const ModuleCapabilities(
      supportsRealTimeAnalysis: true,
      supportsRecipeModification: true,
      supportedProcessTypes: ['mixing', 'fermentation', 'baking'],
      supportedIngredientTypes: [
        'flour',
        'yeast',
        'water',
        'salt',
        'fat',
        'sugar'
      ],
      supportsEnvironmentAnalysis: true,
      supportsAdvancedMetrics: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supportsRealTimeAnalysis': supportsRealTimeAnalysis,
      'supportsRecipeModification': supportsRecipeModification,
      'supportedProcessTypes': supportedProcessTypes,
      'supportedIngredientTypes': supportedIngredientTypes,
      'supportsEnvironmentAnalysis': supportsEnvironmentAnalysis,
      'supportsAdvancedMetrics': supportsAdvancedMetrics,
    };
  }

  @override
  String toString() {
    return 'ModuleCapabilities('
        'realTime: $supportsRealTimeAnalysis, '
        'modification: $supportsRecipeModification, '
        'processes: ${supportedProcessTypes.length}, '
        'ingredients: ${supportedIngredientTypes.length})';
  }
}

// 중요: UnifiedRecipe와 AnalysisResult는 프로젝트 전반에 걸쳐 필수적으로 사용되므로 유지
// 다른 중복 클래스들은 bread_types.dart에서 제공하는 것으로 사용
