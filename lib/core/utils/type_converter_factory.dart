// lib/core/utils/type_converter_factory.dart
// 통합 타입 변환 시스템 - 팩토리 패턴 적용

import 'dart:convert';
import '../../models/recipe.dart';
import '../../models/ingredient.dart';
// import '../../../features/chef/module/bread/types/unified_types.dart'; // 빅데이터 제거로 인한 주석 처리
import 'safe_type_converter.dart';
import '../../services/environment_defaults_calculator.dart';

/// 타입 변환기 팩토리 - 일관된 변환 인터페이스 제공
class TypeConverterFactory {
  /// Recipe 변환기
  static final RecipeConverter _recipeConverter = RecipeConverter._();

  /// Ingredient 변환기
  static final IngredientConverter _ingredientConverter =
      IngredientConverter._();

  /// UnifiedRecipe 변환기 (빅데이터 제거로 임시 주석 처리)
  // static final UnifiedRecipeConverter _unifiedRecipeConverter =
  //     UnifiedRecipeConverter._();

  /// Recipe 관련 변환
  static RecipeConverter get recipe => _recipeConverter;

  /// Ingredient 관련 변환
  static IngredientConverter get ingredient => _ingredientConverter;

  /// UnifiedRecipe 관련 변환 (빅데이터 제거로 임시 주석 처리)
  // static UnifiedRecipeConverter get unifiedRecipe => _unifiedRecipeConverter;
}

/// Recipe 타입 변환기
class RecipeConverter {
  RecipeConverter._();

  /// Map에서 Recipe로 안전하게 변환
  Recipe fromJson(Map<String, dynamic> json) {
    try {
      // 필수 필드 검증 및 안전한 변환
      final title =
          SafeTypeConverter.safeToStringRequired(json['title'], 'title');
      final category =
          SafeTypeConverter.safeToStringRequired(json['category'], 'category');

      // Instructions 파싱 (안전하게)
      final instructionsData = json['instructions'];
      List<Map<String, dynamic>> parsedInstructions = [];

      if (instructionsData is String) {
        try {
          final decoded = jsonDecode(instructionsData);
          parsedInstructions =
              SafeTypeConverter.safeToList<Map<String, dynamic>>(
            decoded,
            defaultValue: [],
          );
        } catch (e) {
          parsedInstructions = [];
        }
      } else if (instructionsData is List) {
        parsedInstructions = SafeTypeConverter.safeToList<Map<String, dynamic>>(
          instructionsData,
          defaultValue: [],
        );
      }

      // Ingredients 파싱 (안전하게)
      final ingredientsData = json['ingredients'];
      List<Ingredient> parsedIngredients = [];

      List<dynamic> rawIngredients = [];
      if (ingredientsData is String) {
        try {
          final decoded = jsonDecode(ingredientsData);
          rawIngredients =
              SafeTypeConverter.safeToList<dynamic>(decoded, defaultValue: []);
        } catch (e) {
          rawIngredients = [];
        }
      } else if (ingredientsData is List) {
        rawIngredients = SafeTypeConverter.safeToList<dynamic>(ingredientsData,
            defaultValue: []);
      }

      for (var item in rawIngredients) {
        try {
          if (item is Map<String, dynamic>) {
            parsedIngredients
                .add(TypeConverterFactory.ingredient.fromJson(item));
          }
        } catch (e) {
          // 개별 재료 파싱 실패는 무시하고 계속 진행
          continue;
        }
      }

      // 선택적 필드들 안전하게 파싱
      final mixingSteps = _parseJsonList(json['mixingSteps']);
      final fermentationSteps = _parseJsonList(json['fermentationSteps']);
      final ovenSteps = _parseJsonList(json['ovenSteps']);

      // Tags 파싱
      final tagsData = json['tags'];
      List<String>? parsedTags;
      if (tagsData is String) {
        try {
          final decoded = jsonDecode(tagsData);
          parsedTags = SafeTypeConverter.safeToList<String>(decoded);
        } catch (e) {
          parsedTags = null;
        }
      } else if (tagsData is List) {
        parsedTags = SafeTypeConverter.safeToList<String>(tagsData);
      }

      return Recipe(
        id: SafeTypeConverter.safeToInt(json['id']),
        title: title,
        category: category,
        ingredients: parsedIngredients,
        instructions: parsedInstructions,
        imagePath: SafeTypeConverter.safeToString(json['imagePath']),
        baseServings: SafeTypeConverter.safeToInt(json['baseServings']) ?? 1,
        isBaking: SafeTypeConverter.safeToBool(json['isBaking']),
        targetSplitAmount:
            SafeTypeConverter.safeToDouble(json['targetSplitAmount']),
        targetSplitCount: SafeTypeConverter.safeToInt(json['targetSplitCount']),
        calculatedRemainingWeight:
            SafeTypeConverter.safeToDouble(json['calculatedRemainingWeight']),
        totalIngredientWeight:
            SafeTypeConverter.safeToDouble(json['totalIngredientWeight']),
        parentId: SafeTypeConverter.safeToInt(json['parentId']),
        mixingSteps: mixingSteps,
        fermentationSteps: fermentationSteps,
        ovenSteps: ovenSteps,
        cookingTime: SafeTypeConverter.safeToInt(json['cookingTime']),
        servingSize: SafeTypeConverter.safeToInt(json['servingSize']),
        difficulty: SafeTypeConverter.safeToString(json['difficulty']),
        imageUrl: SafeTypeConverter.safeToString(json['imageUrl']),
        createdAt: SafeTypeConverter.safeToDateTime(json['createdAt']),
        updatedAt: SafeTypeConverter.safeToDateTime(json['updatedAt']),
        userId: SafeTypeConverter.safeToString(json['userId']),
        isPublic: json['isPublic'] != null
            ? SafeTypeConverter.safeToBool(json['isPublic'])
            : null,
        tags: parsedTags,
        rating: SafeTypeConverter.safeToDouble(json['rating']),
        reviewCount: SafeTypeConverter.safeToInt(json['reviewCount']),
      );
    } catch (e) {
      throw ValidationException('Recipe deserialization failed: $e');
    }
  }

  /// Recipe을 Map으로 변환
  Map<String, dynamic> toJson(Recipe recipe) {
    try {
      return {
        'id': recipe.id,
        'title': recipe.title,
        'category': recipe.category,
        'ingredients': jsonEncode(recipe.ingredients
            .map((i) => TypeConverterFactory.ingredient.toJson(i))
            .toList()),
        'instructions': jsonEncode(recipe.instructions),
        'imagePath': recipe.imagePath,
        'baseServings': recipe.baseServings,
        'isBaking': recipe.isBaking ? 1 : 0,
        'targetSplitAmount': recipe.targetSplitAmount,
        'targetSplitCount': recipe.targetSplitCount,
        'calculatedRemainingWeight': recipe.calculatedRemainingWeight,
        'totalIngredientWeight': recipe.totalIngredientWeight,
        'parentId': recipe.parentId,
        'mixingSteps':
            recipe.mixingSteps != null ? jsonEncode(recipe.mixingSteps) : null,
        'fermentationSteps': recipe.fermentationSteps != null
            ? jsonEncode(recipe.fermentationSteps)
            : null,
        'ovenSteps':
            recipe.ovenSteps != null ? jsonEncode(recipe.ovenSteps) : null,
        'cookingTime': recipe.cookingTime,
        'servingSize': recipe.servingSize,
        'difficulty': recipe.difficulty,
        'imageUrl': recipe.imageUrl,
        'createdAt': recipe.createdAt?.toIso8601String(),
        'updatedAt': recipe.updatedAt?.toIso8601String(),
        'userId': recipe.userId,
        'isPublic': recipe.isPublic != null ? (recipe.isPublic! ? 1 : 0) : null,
        'tags': recipe.tags != null ? jsonEncode(recipe.tags) : null,
        'rating': recipe.rating,
        'reviewCount': recipe.reviewCount,
      };
    } catch (e) {
      throw ValidationException('Recipe serialization failed: $e');
    }
  }

  /// JSON 리스트 파싱 헬퍼
  static List<Map<String, dynamic>>? _parseJsonList(dynamic data) {
    if (data == null) return null;

    try {
      if (data is String) {
        final decoded = jsonDecode(data);
        if (decoded is List) {
          return List<Map<String, dynamic>>.from(
              decoded.map((item) => Map<String, dynamic>.from(item as Map)));
        }
      } else if (data is List) {
        return List<Map<String, dynamic>>.from(
            data.map((item) => Map<String, dynamic>.from(item as Map)));
      }
    } catch (e) {
      // 파싱 실패 시 null 반환
    }

    return null;
  }
}

/// Ingredient 타입 변환기
class IngredientConverter {
  IngredientConverter._();

  /// Map에서 Ingredient로 안전하게 변환
  Ingredient fromJson(Map<String, dynamic> json) {
    try {
      final name = SafeTypeConverter.safeToStringRequired(
          json['name'], 'ingredient name');
      final unit = SafeTypeConverter.safeToString(json['unit']) ?? '';
      final amount = SafeTypeConverter.safeToDouble(json['amount']) ?? 0.0;
      final properties =
          SafeTypeConverter.safeToMap<String, dynamic>(json['properties']);

      return Ingredient(
        id: SafeTypeConverter.safeToString(json['id']) ?? '',
        name: name,
        amount: amount,
        unit: unit,
        properties: properties.isNotEmpty ? properties : null,
      );
    } catch (e) {
      throw ValidationException('Ingredient deserialization failed: $e');
    }
  }

  /// Ingredient을 Map으로 변환
  Map<String, dynamic> toJson(Ingredient ingredient) {
    return {
      'name': ingredient.name,
      'amount': ingredient.amount,
      'unit': ingredient.unit,
      'properties': ingredient.properties,
    };
  }
}

// /// UnifiedRecipe 타입 변환기 (빅데이터 제거로 임시 주석 처리)
// // class UnifiedRecipeConverter {
// //   UnifiedRecipeConverter._();
//
// //   /// Recipe에서 UnifiedRecipe로 변환
// //   Future<UnifiedRecipe> fromRecipe(Recipe recipe) async {
// //     try {
// //       // 필수 필드 검증
// //       if (recipe.title.isEmpty) {
// //         throw ValidationException('Recipe title cannot be empty');
// //       }
//
// //       // 재료 변환 (안전하게)
// //       final ingredients = <UnifiedIngredient>[];
// //       for (final ingredient in recipe.ingredients) {
// //         try {
// //           ingredients.add(UnifiedIngredient.from(ingredient));
// //         } catch (e) {
// //           // 개별 재료 변환 실패는 무시하고 계속 진행
// //           continue;
// //         }
// //       }
//
// //       // 프로세스 변환 (기본적으로 빈 리스트)
// //       final processes = <UnifiedProcess>[];
// //       // TODO: 추후 instructions에서 processes로 변환 로직 추가
//
// //       return UnifiedRecipe(
// //         id: recipe.id?.toString() ??
// //             'recipe_${DateTime.now().millisecondsSinceEpoch}',
// //         title: recipe.title,
// //         ingredients: ingredients,
// //         processes: processes,
// //         equipment: EquipmentConfig.empty(),
// //         metadata: RecipeMetadata.empty(),
// //       );
// //     } catch (e) {
// //       // 변환 실패 시 기본 UnifiedRecipe 반환
// //       return UnifiedRecipe(
// //         id: 'error_recipe_${DateTime.now().millisecondsSinceEpoch}',
// //         title: 'Error Recipe',
// //         ingredients: [],
// //         processes: [],
// //         equipment: EquipmentConfig.empty(),
// //         metadata: RecipeMetadata.empty(),
// //       );
// //     }
// //   }
//
// //   /// UnifiedRecipe에서 Recipe로 변환
// //   Recipe toRecipe(UnifiedRecipe unifiedRecipe) {
// //     // 프로세스를 분류하여 mixingSteps, fermentationSteps, ovenSteps 생성
// //     final mixingSteps = <Map<String, dynamic>>[];
// //     final fermentationSteps = <Map<String, dynamic>>[];
// //     final ovenSteps = <Map<String, dynamic>>[];
// //     final instructions = <Map<String, dynamic>>[];
//
// //     for (final process in unifiedRecipe.processes) {
// //       // 프로세스 타입에 따라 분류
// //       switch (process.type) {
// //         case 'mixing':
// //           mixingSteps.add({
// //             'name': process.name,
// //             'speed': process.parameters['speed'] ?? '중속',
// //             'time': process.parameters['time'] ??
// //                 process.parameters['duration'] ??
// //                 '5',
// //             'step': '${mixingSteps.length + 1}단계',
// //             'comment': process.parameters['comment'] ?? '',
// //           });
// //           break;
// //         case 'fermentation':
// //           fermentationSteps.add({
// //             'name': process.name,
// //             'temperature': process.parameters['temperature'] ??
// //                 EnvironmentDefaultsCalculator
// //                         .getOptimalFermentationTemperature()
// //                     .toString(),
// //             'humidity': process.parameters['humidity'] ?? '80',
// //             'time': process.parameters['time'] ??
// //                 process.parameters['duration'] ??
// //                 '60',
// //             'step': '${fermentationSteps.length + 1}단계',
// //             'comment': process.parameters['comment'] ?? '',
// //           });
// //           break;
// //         case 'baking':
// //           ovenSteps.add({
// //             'name': process.name,
// //             'temperature': process.parameters['temperature'] ?? '180',
// //             'time': process.parameters['time'] ??
// //                 process.parameters['duration'] ??
// //                 '30',
// //             'step': '${ovenSteps.length + 1}단계',
// //             'comment': process.parameters['comment'] ?? '',
// //           });
// //           break;
// //         default:
// //           // 기타 프로세스는 instructions로 추가
// //           instructions.add(process.toInstruction());
// //       }
// //     }
//
// //     return Recipe(
// //       id: int.tryParse(unifiedRecipe.id),
// //       title: unifiedRecipe.title,
// //       category: 'baking', // 기본 카테고리 설정
// //       ingredients:
// //           unifiedRecipe.ingredients.map((ing) => ing.toIngredient()).toList(),
// //       instructions: instructions,
// //       createdAt: unifiedRecipe.createdAt,
// //       updatedAt: unifiedRecipe.updatedAt,
// //       // 프로세스 정보를 추가
// //       mixingSteps: mixingSteps.isNotEmpty ? mixingSteps : null,
// //       fermentationSteps:
// //           fermentationSteps.isNotEmpty ? fermentationSteps : null,
// //       ovenSteps: ovenSteps.isNotEmpty ? ovenSteps : null,
// //     );
// //   }
// // }
