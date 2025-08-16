import 'dart:convert';
import 'ingredient.dart';

class Recipe {
  final int? id;
  final String title;
  final String category;
  final String description;
  final int prepTime;
  final int cookTime;
  final int servings;
  final List<String> instructions;
  final List<Ingredient> ingredients;
  final String? imagePath;
  final int baseServings;
  final bool isBaking;
  final double? targetSplitAmount;
  final int? targetSplitCount;
  final double? calculatedRemainingWeight;
  final double? totalIngredientWeight;
  final int? parentId;
  final List<Map<String, dynamic>>? fermentationSteps;
  final List<Map<String, dynamic>>? ovenSteps;

  Recipe({
    this.id,
    required this.title,
    required this.category,
    this.description = '',
    this.prepTime = 0,
    this.cookTime = 0,
    this.servings = 1,
    required this.instructions,
    required this.ingredients,
    this.imagePath,
    this.baseServings = 1,
    this.isBaking = false,
    this.targetSplitAmount,
    this.targetSplitCount,
    this.calculatedRemainingWeight,
    this.totalIngredientWeight,
    this.parentId,
    this.fermentationSteps,
    this.ovenSteps,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      // 'description': description, // 데이터베이스 스키마에 없는 컬럼 제거
      // 'prepTime': prepTime, // 데이터베이스 스키마에 없는 컬럼 제거
      // 'cookTime': cookTime, // 데이터베이스 스키마에 없는 컬럼 제거
      // 'servings': servings, // 데이터베이스 스키마에 없는 컬럼 제거
      'ingredients': jsonEncode(ingredients.map((e) => e.toJson()).toList()),
      'instructions': jsonEncode(instructions),
      'imagePath': imagePath,
      'baseServings': baseServings,
      'isBaking': isBaking ? 1 : 0, // bool을 int로 변환
      'targetSplitAmount': targetSplitAmount,
      'targetSplitCount': targetSplitCount,
      'calculatedRemainingWeight': calculatedRemainingWeight,
      'totalIngredientWeight': totalIngredientWeight,
      'parentId': parentId,
      'fermentationSteps': fermentationSteps != null ? jsonEncode(fermentationSteps) : null,
      'ovenSteps': ovenSteps != null ? jsonEncode(ovenSteps) : null,
    };
  }

  static List<Ingredient> _parseIngredients(dynamic ingredientsData) {
    if (ingredientsData == null) return [];
    
    if (ingredientsData is String) {
      try {
        final List<dynamic> parsed = jsonDecode(ingredientsData);
        return parsed.map((e) => Ingredient.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        // JSON 파싱 실패 시 빈 리스트 반환
        return [];
      }
    } else if (ingredientsData is List) {
      return ingredientsData.map((e) {
        if (e is Map<String, dynamic>) {
          return Ingredient.fromJson(e);
        } else if (e is String) {
          return Ingredient.fromJson(jsonDecode(e) as Map<String, dynamic>);
        } else {
          // 알 수 없는 형식의 재료 데이터
          return Ingredient(name: 'Unknown', amount: 0, unit: 'g');
        }
      }).toList();
    } else {
      // 알 수 없는 재료 데이터 타입
      return [];
    }
  }

  static List<String> _parseInstructions(dynamic instructionsData) {
    if (instructionsData == null) return [];
    
    if (instructionsData is String) {
      try {
        final List<dynamic> parsed = jsonDecode(instructionsData);
        
        // 새로운 형태의 데이터 처리: [{"text":"내용","imagePath":null}]
        if (parsed.isNotEmpty && parsed.first is Map<String, dynamic>) {
          return parsed.map((item) {
            if (item is Map<String, dynamic> && item.containsKey('text')) {
              return item['text']?.toString() ?? '';
            }
            return item.toString();
          }).where((text) => text.isNotEmpty).toList();
        }
        
        // 기존 형태의 데이터 처리: ["문자열1", "문자열2"]
        return List<String>.from(parsed);
      } catch (e) {
        // JSON 파싱 실패 시 단일 문자열로 처리
        return [instructionsData];
      }
    } else if (instructionsData is List) {
      // List 형태인 경우도 새로운 형태 확인
      if (instructionsData.isNotEmpty && instructionsData.first is Map<String, dynamic>) {
        return instructionsData.map((item) {
          if (item is Map<String, dynamic> && item.containsKey('text')) {
            return item['text']?.toString() ?? '';
          }
          return item.toString();
        }).where((text) => text.isNotEmpty).toList();
      }
      
      return List<String>.from(instructionsData);
    } else {
      // 알 수 없는 지시사항 데이터 타입
      return [];
    }
  }

  static List<Map<String, dynamic>>? _parseSteps(dynamic stepsData) {
    if (stepsData == null) return null;
    
    if (stepsData is String) {
      try {
        final List<dynamic> parsed = jsonDecode(stepsData);
        return parsed.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (e) {
        // 단계 데이터 파싱 실패
        return null;
      }
    } else if (stepsData is List) {
      return stepsData.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } else {
      // 알 수 없는 단계 데이터 타입
      return null;
    }
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    try {
      return Recipe(
        id: json['id'],
        title: json['title'] ?? '',
        category: json['category'] ?? '',
        description: json['description'] ?? '',
        prepTime: json['prepTime'] ?? 0,
        cookTime: json['cookTime'] ?? 0,
        servings: json['servings'] ?? 1,
        ingredients: _parseIngredients(json['ingredients']),
        instructions: _parseInstructions(json['instructions']),
        imagePath: json['imagePath'],
        baseServings: json['baseServings'] ?? 1,
        isBaking:
            json['isBaking'] is bool ? json['isBaking'] : json['isBaking'] == 1,
        targetSplitAmount: json['targetSplitAmount'],
        targetSplitCount: json['targetSplitCount'],
        calculatedRemainingWeight: json['calculatedRemainingWeight'],
        totalIngredientWeight: json['totalIngredientWeight'],
        parentId: json['parentId'],
        fermentationSteps: _parseSteps(json['fermentationSteps']),
        ovenSteps: _parseSteps(json['ovenSteps']),
      );
    } catch (e) {
      throw FormatException('Invalid recipe data: $e');
    }
  }
}
