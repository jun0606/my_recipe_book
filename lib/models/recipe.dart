import 'dart:convert';
import 'ingredient.dart';

class Recipe {
  final int? id;
  final String title;
  final String category;
  final List<Ingredient> ingredients;
  final List<Map<String, dynamic>> instructions;
  final String? imagePath;
  final int baseServings;
  final bool isBaking;
  final double? targetSplitAmount;
  final int? targetSplitCount;
  final double? calculatedRemainingWeight;
  final double? totalIngredientWeight;
  final int? parentId;
  final List<Map<String, dynamic>>? mixingSteps;
  final List<Map<String, dynamic>>? fermentationSteps;
  final List<Map<String, dynamic>>? ovenSteps;

  // Additional fields for sous chef mode compatibility
  final int? cookingTime;
  final int? servingSize;
  final String? difficulty;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? userId;
  final bool? isPublic;
  final List<String>? tags;
  final double? rating;
  final int? reviewCount;

  // Sous Chef 모드 호환성을 위한 getter들
  String get name => title;

  List<Map<String, dynamic>> get processes => instructions.map((instruction) {
        return {
          'id': instruction['id'] ?? '',
          'name': instruction['description'] ?? '',
          'type': _inferProcessType(instruction),
          'duration': instruction['duration'] ?? 0,
          'parameters': instruction,
          'order': instructions.indexOf(instruction),
        };
      }).toList();

  // 재료 카테고리 getter
  List<Map<String, dynamic>> get ingredientCategories {
    return ingredients.map((ingredient) {
      return {
        'id': ingredient.id,
        'name': ingredient.name,
        'amount': ingredient.amount,
        'unit': ingredient.unit,
        'category': ingredient.category ?? 'other',
        'notes': ingredient.notes,
      };
    }).toList();
  }

  Recipe({
    this.id,
    required this.title,
    required this.category,
    required this.ingredients,
    required this.instructions,
    this.imagePath,
    this.baseServings = 1,
    this.isBaking = false,
    this.targetSplitAmount,
    this.targetSplitCount,
    this.calculatedRemainingWeight,
    this.totalIngredientWeight,
    this.parentId,
    this.mixingSteps,
    this.fermentationSteps,
    this.ovenSteps,
    this.cookingTime,
    this.servingSize,
    this.difficulty,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.isPublic,
    this.tags,
    this.rating,
    this.reviewCount,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    print(
        '🔍 [JSON_PARSER] Recipe.fromJson 시작 - ID: ${json['id']}, Title: ${json['title']}');

    final dynamic instructionsData = json['instructions'];
    List<Map<String, dynamic>> parsedInstructions;

    print(
        '📝 [JSON_PARSER] instructionsData 타입: ${instructionsData.runtimeType}, 값: $instructionsData');

    if (instructionsData is String) {
      print('🔄 [JSON_PARSER] instructionsData가 String 타입 - jsonDecode 실행');
      print('📄 [JSON_PARSER] 원본 JSON 문자열: "$instructionsData"');
      try {
        final decoded = jsonDecode(instructionsData);
        print(
            '🔍 [JSON_PARSER] jsonDecode 결과: $decoded (타입: ${decoded.runtimeType})');

        if (decoded is List) {
          parsedInstructions = List<Map<String, dynamic>>.from(decoded);
          print(
              '✅ [JSON_PARSER] String 타입 instructions 성공적으로 파싱됨: ${parsedInstructions.length}개 항목');
        } else {
          print(
              '❌ [JSON_PARSER] jsonDecode 결과가 List가 아님: ${decoded.runtimeType}');
          parsedInstructions = [];
        }
      } catch (e) {
        print('❌ [JSON_PARSER] String 타입 instructions 파싱 실패: $e');
        parsedInstructions = [];
      }
    } else if (instructionsData is List) {
      print('🔄 [JSON_PARSER] instructionsData가 List 타입 - 직접 변환');
      print('📄 [JSON_PARSER] 원본 List 내용: $instructionsData');
      parsedInstructions = List<Map<String, dynamic>>.from(instructionsData);
      print(
          '✅ [JSON_PARSER] List 타입 instructions 성공적으로 변환됨: ${parsedInstructions.length}개 항목');
    } else {
      print('⚠️ [JSON_PARSER] instructionsData가 예상치 못한 타입 - 빈 리스트로 초기화');
      print(
          '📄 [JSON_PARSER] 예상치 못한 타입: ${instructionsData.runtimeType}, 값: $instructionsData');
      parsedInstructions = [];
    }

    // 각 instruction 항목 상세 분석 및 내용 로깅
    print('📋 [JSON_PARSER] ===== INSTRUCTIONS 상세 분석 시작 =====');
    for (int i = 0; i < parsedInstructions.length; i++) {
      final instruction = parsedInstructions[i];
      print('📋 [JSON_PARSER] Instruction $i: $instruction');
      print(
          '   - description 타입: ${instruction['description']?.runtimeType}, 값: "${instruction['description']}"');
      print(
          '   - imagePath 타입: ${instruction['imagePath']?.runtimeType}, 값: ${instruction['imagePath']}');

      // instruction 내용이 Map인지 확인하고 모든 키-값 로깅
      if (instruction is Map<String, dynamic>) {
        print('   - 모든 키: ${instruction.keys.toList()}');
        instruction.forEach((key, value) {
          print('   - $key: $value (${value?.runtimeType})');
        });
      }
    }
    print('📋 [JSON_PARSER] ===== INSTRUCTIONS 상세 분석 완료 =====');

    final dynamic ingredientsData = json['ingredients'];
    List<Ingredient> parsedIngredients;

    print(
        '📝 [JSON_PARSER] ingredientsData 타입: ${ingredientsData.runtimeType}, 값: $ingredientsData');

    if (ingredientsData is String) {
      print('🔄 [JSON_PARSER] ingredientsData가 String 타입 - jsonDecode 실행');
      print('📄 [JSON_PARSER] 원본 JSON 문자열: "$ingredientsData"');
      try {
        final decoded = jsonDecode(ingredientsData);
        print(
            '🔍 [JSON_PARSER] jsonDecode 결과: $decoded (타입: ${decoded.runtimeType})');

        if (decoded is List) {
          parsedIngredients = decoded.map((i) {
            print('📦 [JSON_PARSER] Ingredient 변환 전: $i (${i.runtimeType})');
            final ingredient = Ingredient.fromJson(i as Map<String, dynamic>);
            print(
                '✅ [JSON_PARSER] Ingredient 변환 후: ${ingredient.name}, ${ingredient.amount}${ingredient.unit}');
            return ingredient;
          }).toList();
          print(
              '✅ [JSON_PARSER] String 타입 ingredients 성공적으로 파싱됨: ${parsedIngredients.length}개 항목');
        } else {
          print(
              '❌ [JSON_PARSER] jsonDecode 결과가 List가 아님: ${decoded.runtimeType}');
          parsedIngredients = [];
        }
      } catch (e) {
        print('❌ [JSON_PARSER] String 타입 ingredients 파싱 실패: $e');
        parsedIngredients = [];
      }
    } else if (ingredientsData is List) {
      print('🔄 [JSON_PARSER] ingredientsData가 List 타입 - 직접 변환');
      print('📄 [JSON_PARSER] 원본 List 내용: $ingredientsData');
      parsedIngredients = ingredientsData.map((i) {
        print('📦 [JSON_PARSER] Ingredient 변환 전: $i (${i.runtimeType})');
        final ingredient = Ingredient.fromJson(i as Map<String, dynamic>);
        print(
            '✅ [JSON_PARSER] Ingredient 변환 후: ${ingredient.name}, ${ingredient.amount}${ingredient.unit}');
        return ingredient;
      }).toList();
      print(
          '✅ [JSON_PARSER] List 타입 ingredients 성공적으로 변환됨: ${parsedIngredients.length}개 항목');
    } else {
      print('⚠️ [JSON_PARSER] ingredientsData가 예상치 못한 타입 - 빈 리스트로 초기화');
      print(
          '📄 [JSON_PARSER] 예상치 못한 타입: ${ingredientsData.runtimeType}, 값: $ingredientsData');
      parsedIngredients = [];
    }

    List<Map<String, dynamic>>? parsedMixingSteps;
    if (json['mixingSteps'] != null) {
      final dynamic mixingData = json['mixingSteps'];
      print(
          '📝 [JSON_PARSER] mixingStepsData 타입: ${mixingData.runtimeType}, 값: $mixingData');

      if (mixingData is String) {
        print('🔄 [JSON_PARSER] mixingStepsData가 String 타입 - jsonDecode 실행');
        print('📄 [JSON_PARSER] 원본 JSON 문자열: "$mixingData"');
        try {
          final decoded = jsonDecode(mixingData);
          print(
              '🔍 [JSON_PARSER] jsonDecode 결과: $decoded (타입: ${decoded.runtimeType})');

          if (decoded is List) {
            parsedMixingSteps = List<Map<String, dynamic>>.from(decoded);
            print(
                '✅ [JSON_PARSER] String 타입 mixingSteps 성공적으로 파싱됨: ${parsedMixingSteps!.length}개 항목');

            // 각 mixing step 상세 로깅
            for (int i = 0; i < parsedMixingSteps!.length; i++) {
              final step = parsedMixingSteps![i];
              print('🔄 [JSON_PARSER] MixingStep $i: $step');
              if (step is Map<String, dynamic>) {
                step.forEach((key, value) {
                  print('   - $key: $value (${value?.runtimeType})');
                });
              }
            }
          } else {
            print(
                '❌ [JSON_PARSER] jsonDecode 결과가 List가 아님: ${decoded.runtimeType}');
            parsedMixingSteps = null;
          }
        } catch (e) {
          print('❌ [JSON_PARSER] String 타입 mixingSteps 파싱 실패: $e');
          parsedMixingSteps = null;
        }
      } else if (mixingData is List) {
        print('🔄 [JSON_PARSER] mixingStepsData가 List 타입 - 직접 변환');
        print('📄 [JSON_PARSER] 원본 List 내용: $mixingData');
        parsedMixingSteps = List<Map<String, dynamic>>.from(mixingData);
        print(
            '✅ [JSON_PARSER] List 타입 mixingSteps 성공적으로 변환됨: ${parsedMixingSteps!.length}개 항목');

        // 각 mixing step 상세 로깅
        for (int i = 0; i < parsedMixingSteps!.length; i++) {
          final step = parsedMixingSteps![i];
          print('🔄 [JSON_PARSER] MixingStep $i: $step');
          if (step is Map<String, dynamic>) {
            step.forEach((key, value) {
              print('   - $key: $value (${value?.runtimeType})');
            });
          }
        }
      } else {
        print('⚠️ [JSON_PARSER] mixingStepsData가 예상치 못한 타입 - null로 설정');
        print(
            '📄 [JSON_PARSER] 예상치 못한 타입: ${mixingData.runtimeType}, 값: $mixingData');
        parsedMixingSteps = null;
      }
    } else {
      print('📝 [JSON_PARSER] mixingSteps 데이터가 null입니다');
      parsedMixingSteps = null;
    }

    List<Map<String, dynamic>>? parsedFermentationSteps;
    if (json['fermentationSteps'] != null) {
      final dynamic fermentationData = json['fermentationSteps'];
      print(
          '📝 [JSON_PARSER] fermentationStepsData 타입: ${fermentationData.runtimeType}, 값: $fermentationData');

      if (fermentationData is String) {
        print(
            '🔄 [JSON_PARSER] fermentationStepsData가 String 타입 - jsonDecode 실행');
        print('📄 [JSON_PARSER] 원본 JSON 문자열: "$fermentationData"');
        try {
          final decoded = jsonDecode(fermentationData);
          print(
              '🔍 [JSON_PARSER] jsonDecode 결과: $decoded (타입: ${decoded.runtimeType})');

          if (decoded is List) {
            parsedFermentationSteps = List<Map<String, dynamic>>.from(decoded);
            print(
                '✅ [JSON_PARSER] String 타입 fermentationSteps 성공적으로 파싱됨: ${parsedFermentationSteps!.length}개 항목');

            for (int i = 0; i < parsedFermentationSteps!.length; i++) {
              final step = parsedFermentationSteps![i];
              print('🌡️ [JSON_PARSER] FermentationStep $i: $step');
              if (step is Map<String, dynamic>) {
                step.forEach((key, value) {
                  print('   - $key: $value (${value?.runtimeType})');
                });
                // 시간 데이터 검증 및 변환
                if (step.containsKey('time')) {
                  final timeValue = step['time'];

                  // ✅ 기존: String 타입 처리
                  if (timeValue is String) {
                    final timeInt = int.tryParse(timeValue);
                    if (timeInt != null) {
                      step['time'] = timeInt;
                      print('   - [타입변환] time: "$timeValue" → $timeInt (int)');
                    } else {
                      step['time'] = 0;
                      print('   - [타입변환실패] time: "$timeValue" → 0 (기본값)');
                    }
                  }
                  // ✅ 새로 추가: num 타입도 처리 (int/double 모두)
                  else if (timeValue is num) {
                    step['time'] = timeValue.toInt();
                    print(
                        '   - [타입보존] time: $timeValue → ${step['time']} (${timeValue.runtimeType} 유지)');
                  }
                  // ✅ 새로 추가: 다른 타입들 처리
                  else {
                    step['time'] = 0;
                    print(
                        '   - [타입변환실패] time: $timeValue (${timeValue.runtimeType}) → 0 (기본값)');
                  }
                }
                // ✅ 새로 추가: durationHours 키도 처리 (시간 → 분 변환)
                else if (step.containsKey('durationHours') &&
                    step['durationHours'] is num) {
                  final durationHours = step['durationHours'] as num;
                  step['time'] = (durationHours * 60).toInt();
                  print(
                      '   - [시간변환] durationHours: ${durationHours}시간 → ${step['time']}분');
                }
              }
            }
          } else {
            print(
                '❌ [JSON_PARSER] jsonDecode 결과가 List가 아님: ${decoded.runtimeType}');
            parsedFermentationSteps = null;
          }
        } catch (e) {
          print('❌ [JSON_PARSER] String 타입 fermentationSteps 파싱 실패: $e');
          parsedFermentationSteps = null;
        }
      } else if (fermentationData is List) {
        print('🔄 [JSON_PARSER] fermentationStepsData가 List 타입 - 직접 변환');
        print('📄 [JSON_PARSER] 원본 List 내용: $fermentationData');
        parsedFermentationSteps =
            List<Map<String, dynamic>>.from(fermentationData);
        print(
            '✅ [JSON_PARSER] List 타입 fermentationSteps 성공적으로 변환됨: ${parsedFermentationSteps!.length}개 항목');

        for (int i = 0; i < parsedFermentationSteps!.length; i++) {
          final step = parsedFermentationSteps![i];
          print('🌡️ [JSON_PARSER] FermentationStep $i: $step');
          if (step is Map<String, dynamic>) {
            step.forEach((key, value) {
              print('   - $key: $value (${value?.runtimeType})');
            });
          }
        }
      } else {
        print('⚠️ [JSON_PARSER] fermentationStepsData가 예상치 못한 타입 - null로 설정');
        print(
            '📄 [JSON_PARSER] 예상치 못한 타입: ${fermentationData.runtimeType}, 값: $fermentationData');
        parsedFermentationSteps = null;
      }
    } else {
      print('📝 [JSON_PARSER] fermentationSteps 데이터가 null입니다');
      parsedFermentationSteps = null;
    }

    List<Map<String, dynamic>>? parsedOvenSteps;
    if (json['ovenSteps'] != null) {
      final dynamic ovenData = json['ovenSteps'];
      print(
          '📝 [JSON_PARSER] ovenStepsData 타입: ${ovenData.runtimeType}, 값: $ovenData');

      if (ovenData is String) {
        print('🔄 [JSON_PARSER] ovenStepsData가 String 타입 - jsonDecode 실행');
        print('📄 [JSON_PARSER] 원본 JSON 문자열: "$ovenData"');
        try {
          final decoded = jsonDecode(ovenData);
          print(
              '🔍 [JSON_PARSER] jsonDecode 결과: $decoded (타입: ${decoded.runtimeType})');

          if (decoded is List) {
            parsedOvenSteps = List<Map<String, dynamic>>.from(decoded);
            print(
                '✅ [JSON_PARSER] String 타입 ovenSteps 성공적으로 파싱됨: ${parsedOvenSteps!.length}개 항목');

            for (int i = 0; i < parsedOvenSteps!.length; i++) {
              final step = parsedOvenSteps![i];
              print('🔥 [JSON_PARSER] OvenStep $i: $step');
              if (step is Map<String, dynamic>) {
                step.forEach((key, value) {
                  print('   - $key: $value (${value?.runtimeType})');
                });
              }
            }
          } else {
            print(
                '❌ [JSON_PARSER] jsonDecode 결과가 List가 아님: ${decoded.runtimeType}');
            parsedOvenSteps = null;
          }
        } catch (e) {
          print('❌ [JSON_PARSER] String 타입 ovenSteps 파싱 실패: $e');
          parsedOvenSteps = null;
        }
      } else if (ovenData is List) {
        print('🔄 [JSON_PARSER] ovenStepsData가 List 타입 - 직접 변환');
        print('📄 [JSON_PARSER] 원본 List 내용: $ovenData');
        parsedOvenSteps = List<Map<String, dynamic>>.from(ovenData);
        print(
            '✅ [JSON_PARSER] List 타입 ovenSteps 성공적으로 변환됨: ${parsedOvenSteps!.length}개 항목');

        for (int i = 0; i < parsedOvenSteps!.length; i++) {
          final step = parsedOvenSteps![i];
          print('🔥 [JSON_PARSER] OvenStep $i: $step');
          if (step is Map<String, dynamic>) {
            step.forEach((key, value) {
              print('   - $key: $value (${value?.runtimeType})');
            });
          }
        }
      } else {
        print('⚠️ [JSON_PARSER] ovenStepsData가 예상치 못한 타입 - null로 설정');
        print(
            '📄 [JSON_PARSER] 예상치 못한 타입: ${ovenData.runtimeType}, 값: $ovenData');
        parsedOvenSteps = null;
      }
    } else {
      print('📝 [JSON_PARSER] ovenSteps 데이터가 null입니다');
      parsedOvenSteps = null;
    }

    List<String>? parsedTags;
    if (json['tags'] != null) {
      final dynamic tagsData = json['tags'];
      print(
          '📝 [JSON_PARSER] tagsData 타입: ${tagsData.runtimeType}, 값: $tagsData');

      if (tagsData is String) {
        print('🔄 [JSON_PARSER] tagsData가 String 타입 - jsonDecode 실행');
        print('📄 [JSON_PARSER] 원본 JSON 문자열: "$tagsData"');
        try {
          final decoded = jsonDecode(tagsData);
          print(
              '🔍 [JSON_PARSER] jsonDecode 결과: $decoded (타입: ${decoded.runtimeType})');

          if (decoded is List) {
            parsedTags = List<String>.from(decoded);
            print(
                '✅ [JSON_PARSER] String 타입 tags 성공적으로 파싱됨: ${parsedTags!.length}개 태그');
            print('🏷️ [JSON_PARSER] 태그 목록: $parsedTags');
          } else {
            print(
                '❌ [JSON_PARSER] jsonDecode 결과가 List가 아님: ${decoded.runtimeType}');
            parsedTags = null;
          }
        } catch (e) {
          print('❌ [JSON_PARSER] String 타입 tags 파싱 실패: $e');
          parsedTags = null;
        }
      } else if (tagsData is List) {
        print('🔄 [JSON_PARSER] tagsData가 List 타입 - 직접 변환');
        print('📄 [JSON_PARSER] 원본 List 내용: $tagsData');
        parsedTags = List<String>.from(tagsData);
        print(
            '✅ [JSON_PARSER] List 타입 tags 성공적으로 변환됨: ${parsedTags!.length}개 태그');
        print('🏷️ [JSON_PARSER] 태그 목록: $parsedTags');
      } else {
        print('⚠️ [JSON_PARSER] tagsData가 예상치 못한 타입 - null로 설정');
        print(
            '📄 [JSON_PARSER] 예상치 못한 타입: ${tagsData.runtimeType}, 값: $tagsData');
        parsedTags = null;
      }
    } else {
      print('📝 [JSON_PARSER] tags 데이터가 null입니다');
      parsedTags = null;
    }

    final recipe = Recipe(
      id: json['id'] as int?,
      title: json['title'] as String,
      category: json['category'] as String,
      ingredients: parsedIngredients,
      instructions: parsedInstructions,
      imagePath: json['imagePath'] as String?,
      baseServings: json['baseServings'] as int? ?? 1,
      isBaking: (json['isBaking'] as int? ?? 0) == 1,
      targetSplitAmount: json['targetSplitAmount'] as double?,
      targetSplitCount: json['targetSplitCount'] as int?,
      calculatedRemainingWeight: json['calculatedRemainingWeight'] as double?,
      totalIngredientWeight: json['totalIngredientWeight'] as double?,
      parentId: json['parentId'] as int?,
      mixingSteps: parsedMixingSteps,
      fermentationSteps: parsedFermentationSteps,
      ovenSteps: parsedOvenSteps,
      cookingTime: json['cookingTime'] as int?,
      servingSize: json['servingSize'] as int?,
      difficulty: json['difficulty'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      userId: json['userId'] as String?,
      isPublic:
          json['isPublic'] != null ? (json['isPublic'] as int) == 1 : null,
      tags: json['tags'] as List<String>?,
      rating: json['rating'] as double?,
      reviewCount: json['reviewCount'] as int?,
    );

    // 최종 Recipe 객체의 모든 필드 검증 및 로깅
    print('🎯 [JSON_PARSER] ===== 최종 Recipe 객체 검증 =====');
    print('📋 [JSON_PARSER] Recipe ID: ${recipe.id}');
    print('📋 [JSON_PARSER] Recipe Title: ${recipe.title}');
    print('📋 [JSON_PARSER] Recipe Category: ${recipe.category}');
    print('📋 [JSON_PARSER] Recipe Base Servings: ${recipe.baseServings}');
    print('📋 [JSON_PARSER] Recipe Is Baking: ${recipe.isBaking}');
    print('📋 [JSON_PARSER] Recipe Image Path: ${recipe.imagePath}');

    // Ingredients 상세 검증
    print('📦 [JSON_PARSER] Ingredients (${recipe.ingredients.length}개):');
    for (int i = 0; i < recipe.ingredients.length; i++) {
      final ingredient = recipe.ingredients[i];
      print(
          '   ${i + 1}. ${ingredient.name}: ${ingredient.amount}${ingredient.unit}');
    }

    // Instructions 상세 검증
    print('📝 [JSON_PARSER] Instructions (${recipe.instructions.length}개):');
    for (int i = 0; i < recipe.instructions.length; i++) {
      final instruction = recipe.instructions[i];
      print(
          '   ${i + 1}. description: ${instruction['description']} (${instruction['description']?.runtimeType})');
      print(
          '      imagePath: ${instruction['imagePath']} (${instruction['imagePath']?.runtimeType})');
    }

    // Mixing Steps 검증
    if (recipe.mixingSteps != null) {
      print('🔄 [JSON_PARSER] Mixing Steps (${recipe.mixingSteps!.length}개):');
      for (int i = 0; i < recipe.mixingSteps!.length; i++) {
        final step = recipe.mixingSteps![i];
        print('   ${i + 1}. ${step}');
      }
    } else {
      print('🔄 [JSON_PARSER] Mixing Steps: null');
    }

    // Fermentation Steps 검증
    if (recipe.fermentationSteps != null) {
      print(
          '🌡️ [JSON_PARSER] Fermentation Steps (${recipe.fermentationSteps!.length}개):');
      for (int i = 0; i < recipe.fermentationSteps!.length; i++) {
        final step = recipe.fermentationSteps![i];
        print('   ${i + 1}. ${step}');
      }
    } else {
      print('🌡️ [JSON_PARSER] Fermentation Steps: null');
    }

    // Oven Steps 검증
    if (recipe.ovenSteps != null) {
      print('🔥 [JSON_PARSER] Oven Steps (${recipe.ovenSteps!.length}개):');
      for (int i = 0; i < recipe.ovenSteps!.length; i++) {
        final step = recipe.ovenSteps![i];
        print('   ${i + 1}. ${step}');
      }
    } else {
      print('🔥 [JSON_PARSER] Oven Steps: null');
    }

    // Tags 검증
    if (recipe.tags != null) {
      print('🏷️ [JSON_PARSER] Tags (${recipe.tags!.length}개): ${recipe.tags}');
    } else {
      print('🏷️ [JSON_PARSER] Tags: null');
    }

    // 추가 필드 검증
    print('📊 [JSON_PARSER] 추가 정보:');
    print('   - Parent ID: ${recipe.parentId}');
    print('   - Target Split Amount: ${recipe.targetSplitAmount}');
    print('   - Target Split Count: ${recipe.targetSplitCount}');
    print(
        '   - Calculated Remaining Weight: ${recipe.calculatedRemainingWeight}');
    print('   - Total Ingredient Weight: ${recipe.totalIngredientWeight}');
    print('   - Cooking Time: ${recipe.cookingTime}');
    print('   - Serving Size: ${recipe.servingSize}');
    print('   - Difficulty: ${recipe.difficulty}');
    print('   - Image URL: ${recipe.imageUrl}');
    print('   - Created At: ${recipe.createdAt}');
    print('   - Updated At: ${recipe.updatedAt}');
    print('   - User ID: ${recipe.userId}');
    print('   - Is Public: ${recipe.isPublic}');
    print('   - Rating: ${recipe.rating}');
    print('   - Review Count: ${recipe.reviewCount}');

    print('✅ [JSON_PARSER] ===== Recipe.fromJson 파싱 완료 =====');

    return recipe;
  }

  // Recipe를 Map으로 변환하는 메서드 추가
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'instructions': instructions,
      'imagePath': imagePath,
      'baseServings': baseServings,
      'isBaking': isBaking ? 1 : 0,
      'targetSplitAmount': targetSplitAmount,
      'targetSplitCount': targetSplitCount,
      'calculatedRemainingWeight': calculatedRemainingWeight,
      'totalIngredientWeight': totalIngredientWeight,
      'parentId': parentId,
      'mixingSteps': mixingSteps,
      'fermentationSteps': fermentationSteps,
      'ovenSteps': ovenSteps,
      'cookingTime': cookingTime,
      'servingSize': servingSize,
      'difficulty': difficulty,
      'imageUrl': imageUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'userId': userId,
      'isPublic': isPublic,
      'tags': tags,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }

  // 프로세스 타입 추론 헬퍼 메서드
  static String _inferProcessType(Map<String, dynamic> instruction) {
    final description = instruction['description'] as String? ?? '';

    if (description.contains('반죽') ||
        description.contains('mix') ||
        description.contains('knead')) {
      return 'mixing';
    } else if (description.contains('발효') || description.contains('ferment')) {
      return 'fermentation';
    } else if (description.contains('굽') ||
        description.contains('bake') ||
        description.contains('oven')) {
      return 'baking';
    } else if (description.contains('성형') || description.contains('shape')) {
      return 'shaping';
    } else {
      return 'other';
    }
  }

  Map<String, dynamic> toJson() {
    print('🔄 [JSON_SERIALIZER] Recipe.toJson 시작 - ID: $id, Title: $title');

    // Instructions 변환 과정 로깅
    print('📝 [JSON_SERIALIZER] instructions 원본: $instructions');
    String instructionsJson;
    try {
      instructionsJson = jsonEncode(instructions);
      print(
          '✅ [JSON_SERIALIZER] instructions jsonEncode 성공: $instructionsJson');
    } catch (e) {
      print('❌ [JSON_SERIALIZER] instructions jsonEncode 실패: $e');
      instructionsJson = '[]';
    }

    // Ingredients 변환 과정 로깅
    String ingredientsJson;
    try {
      ingredientsJson = jsonEncode(ingredients.map((i) => i.toJson()).toList());
      print(
          '✅ [JSON_SERIALIZER] ingredients jsonEncode 성공: ${ingredientsJson.length}자');
    } catch (e) {
      print('❌ [JSON_SERIALIZER] ingredients jsonEncode 실패: $e');
      ingredientsJson = '[]';
    }

    // MixingSteps 변환 과정 로깅
    String? mixingStepsJson;
    if (mixingSteps != null) {
      try {
        mixingStepsJson = jsonEncode(mixingSteps);
        print(
            '✅ [JSON_SERIALIZER] mixingSteps jsonEncode 성공: ${mixingStepsJson.length}자');
      } catch (e) {
        print('❌ [JSON_SERIALIZER] mixingSteps jsonEncode 실패: $e');
        mixingStepsJson = null;
      }
    }

    // FermentationSteps 변환 과정 로깅
    String? fermentationStepsJson;
    if (fermentationSteps != null) {
      try {
        fermentationStepsJson = jsonEncode(fermentationSteps);

        // 🔄 [저장 로깅] fermentationSteps 저장 전 구조 로깅
        // assert를 사용하여 null-safety 보장 - 이 영역에서는 fermentationSteps가 null이 아님을 보장
        assert(fermentationSteps != null,
            'fermentationSteps는 toJson()에서 null일 수 없습니다');
        final steps = fermentationSteps!; // 여기서는 null 아님을 보장
        print('🔄 [저장 로깅] fermentationSteps 원본 데이터 구조 (${steps.length}개 단계):');

        if (steps.isNotEmpty) {
          for (int i = 0; i < steps.length; i++) {
            final step = steps[i];
            print(
                '   단계 $i: ${step.keys.join(', ')} | time=${step['time']}, durationHours=${step['durationHours']}, temperature=${step['temperature']}, targetTemperature=${step['targetTemperature']}, targetHumidity=${step['targetHumidity']}');
          }
          // JSON 직렬화 후 로깅 추가
          print(
              '✅ [JSON_SERIALIZER] fermentationSteps jsonEncode 직렬화 전 데이터 검증 완료');
        }

        print(
            '✅ [JSON_SERIALIZER] fermentationSteps jsonEncode 성공: ${fermentationStepsJson.length}자');
        print('✅ [저장 로깅] fermentationSteps 최종 JSON: $fermentationStepsJson');
      } catch (e) {
        print('❌ [JSON_SERIALIZER] fermentationSteps jsonEncode 실패: $e');
        fermentationStepsJson = null;
      }
    }

    // OvenSteps 변환 과정 로깅
    String? ovenStepsJson;
    if (ovenSteps != null) {
      try {
        ovenStepsJson = jsonEncode(ovenSteps);
        print(
            '✅ [JSON_SERIALIZER] ovenSteps jsonEncode 성공: ${ovenStepsJson.length}자');
      } catch (e) {
        print('❌ [JSON_SERIALIZER] ovenSteps jsonEncode 실패: $e');
        ovenStepsJson = null;
      }
    }

    // Tags 변환 과정 로깅
    String? tagsJson;
    if (tags != null) {
      try {
        tagsJson = jsonEncode(tags);
        print('✅ [JSON_SERIALIZER] tags jsonEncode 성공: $tagsJson');
      } catch (e) {
        print('❌ [JSON_SERIALIZER] tags jsonEncode 실패: $e');
        tagsJson = null;
      }
    }

    final result = {
      'id': id,
      'title': title,
      'category': category,
      'ingredients': ingredientsJson,
      'instructions': instructionsJson,
      'imagePath': imagePath,
      'baseServings': baseServings,
      'isBaking': isBaking ? 1 : 0,
      'targetSplitAmount': targetSplitAmount,
      'targetSplitCount': targetSplitCount,
      'calculatedRemainingWeight': calculatedRemainingWeight,
      'totalIngredientWeight': totalIngredientWeight,
      'parentId': parentId,
      'mixingSteps': mixingStepsJson,
      'fermentationSteps': fermentationStepsJson,
      'ovenSteps': ovenStepsJson,
      'cookingTime': cookingTime,
      'servingSize': servingSize,
      'difficulty': difficulty,
      'imageUrl': imageUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'userId': userId,
      'isPublic': isPublic,
      'tags': tagsJson,
      'rating': rating,
      'reviewCount': reviewCount,
    };

    print('🏁 [JSON_SERIALIZER] Recipe.toJson 완료 - 총 필드 수: ${result.length}');
    return result;
  }
}
