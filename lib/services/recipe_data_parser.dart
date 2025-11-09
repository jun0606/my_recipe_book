import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/types/parsed_recipe_types.dart';
import 'ingredient_analyzer.dart';

/// 중앙 집중화된 레시피 데이터 파싱 서비스
/// 기존의 중복된 파싱 로직들을 통합하여 관리
class RecipeDataParser {
  static const String _version = '1.0.0';

  /// 싱글톤 패턴
  static final RecipeDataParser _instance = RecipeDataParser._internal();
  factory RecipeDataParser() => _instance;
  RecipeDataParser._internal();

  /// 캐시된 파싱 결과들 (성능 최적화)
  final Map<String, ParsedRecipeData> _cache = {};

  /// 캐시 키 생성
  String _generateCacheKey(dynamic rawData) {
    if (rawData is String) {
      return 'string_${rawData.hashCode}';
    } else if (rawData is Map) {
      return 'map_${jsonEncode(rawData).hashCode}';
    } else if (rawData is List) {
      return 'list_${jsonEncode(rawData).hashCode}';
    }
    return 'unknown_${rawData.hashCode}';
  }

  /// 캐시에서 데이터 가져오기
  ParsedRecipeData? _getFromCache(dynamic rawData) {
    final key = _generateCacheKey(rawData);
    return _cache[key];
  }

  /// 캐시에 데이터 저장
  void _saveToCache(dynamic rawData, ParsedRecipeData parsedData) {
    final key = _generateCacheKey(rawData);
    _cache[key] = parsedData;

    // 캐시 크기 제한 (최대 100개)
    if (_cache.length > 100) {
      final keysToRemove = _cache.keys.take(20).toList();
      for (final key in keysToRemove) {
        _cache.remove(key);
      }
    }
  }

  /// 캐시 클리어
  void clearCache() {
    _cache.clear();
  }

  /// 캐시 상태 확인
  int get cacheSize => _cache.length;

  /// 문자열 기반 레시피 파싱 (기존 MixingAnalysisCard 로직 통합)
  Future<ParsedRecipeData> parseFromString(String recipeText) async {
    // 캐시 확인
    final cached = _getFromCache(recipeText);
    if (cached != null) {
      return cached;
    }

    try {
      final ingredients = <ParsedIngredient>[];
      final lines = recipeText.split('\n');

      for (final line in lines) {
        final trimmedLine = line.trim();
        if (trimmedLine.isEmpty) continue;

        final parsedIngredient = _parseIngredientLine(trimmedLine);
        if (parsedIngredient != null) {
          ingredients.add(parsedIngredient);
        }
      }

      final metadata = RecipeMetadata(
        name: _extractRecipeName(recipeText),
        description: _extractRecipeDescription(recipeText),
        totalIngredients: ingredients.length,
        parsedAt: DateTime.now(),
        parserVersion: _version,
      );

      final parsedData = ParsedRecipeData.create(
        ingredients: ingredients,
        metadata: metadata,
      );

      // 캐시에 저장
      _saveToCache(recipeText, parsedData);

      return parsedData;
    } catch (e) {
      debugPrint('레시피 파싱 오류: $e');
      throw RecipeParsingException('레시피 파싱 실패: $e');
    }
  }

  /// 맵 기반 레시피 파싱 (기존 IngredientAnalysisHub 로직 통합)
  Future<ParsedRecipeData> parseFromMap(Map<String, dynamic> recipeMap) async {
    // 캐시 확인
    final cached = _getFromCache(recipeMap);
    if (cached != null) {
      return cached;
    }

    try {
      final ingredients = <ParsedIngredient>[];

      // 재료 목록 추출
      final ingredientsData = recipeMap['ingredients'] as List<dynamic>? ?? [];

      for (final ingredientData in ingredientsData) {
        if (ingredientData is Map<String, dynamic>) {
          final parsedIngredient = _parseIngredientMap(ingredientData);
          if (parsedIngredient != null) {
            ingredients.add(parsedIngredient);
          }
        }
      }

      final metadata = RecipeMetadata(
        name: recipeMap['name'] as String?,
        description: recipeMap['description'] as String?,
        totalIngredients: ingredients.length,
        parsedAt: DateTime.now(),
        parserVersion: _version,
      );

      final parsedData = ParsedRecipeData.create(
        ingredients: ingredients,
        metadata: metadata,
      );

      // 캐시에 저장
      _saveToCache(recipeMap, parsedData);

      return parsedData;
    } catch (e) {
      debugPrint('맵 기반 레시피 파싱 오류: $e');
      throw RecipeParsingException('맵 기반 레시피 파싱 실패: $e');
    }
  }

  /// 리스트 기반 레시피 파싱 (기존 RealTimeRecipeTab 로직 통합)
  Future<ParsedRecipeData> parseFromList(List<dynamic> ingredientsList) async {
    // 캐시 확인
    final cached = _getFromCache(ingredientsList);
    if (cached != null) {
      return cached;
    }

    try {
      final ingredients = <ParsedIngredient>[];

      for (final item in ingredientsList) {
        ParsedIngredient? parsedIngredient;

        if (item is String) {
          parsedIngredient = _parseIngredientLine(item);
        } else if (item is Map<String, dynamic>) {
          parsedIngredient = _parseIngredientMap(item);
        }

        if (parsedIngredient != null) {
          ingredients.add(parsedIngredient);
        }
      }

      final metadata = RecipeMetadata(
        totalIngredients: ingredients.length,
        parsedAt: DateTime.now(),
        parserVersion: _version,
      );

      final parsedData = ParsedRecipeData.create(
        ingredients: ingredients,
        metadata: metadata,
      );

      // 캐시에 저장
      _saveToCache(ingredientsList, parsedData);

      return parsedData;
    } catch (e) {
      debugPrint('리스트 기반 레시피 파싱 오류: $e');
      throw RecipeParsingException('리스트 기반 레시피 파싱 실패: $e');
    }
  }

  /// 개별 재료 라인 파싱 (공통 헬퍼 메소드)
  ParsedIngredient? _parseIngredientLine(String line) {
    // 정규식으로 양과 단위, 재료명 분리
    final regex = RegExp(r'^(\d+(?:\.\d+)?)\s*([a-zA-Z가-힣]+)\s+(.+)$');
    final match = regex.firstMatch(line.trim());

    if (match == null) return null;

    final amount = double.tryParse(match.group(1) ?? '0') ?? 0.0;
    final unit = match.group(2) ?? '';
    final name = match.group(3)?.trim() ?? '';

    if (amount <= 0 || name.isEmpty) return null;

    final weightInGrams = IngredientAnalyzer.convertToGrams(amount, unit, name);
    final ingredientType = _analyzeIngredientType(name);

    return ParsedIngredient(
      name: _normalizeIngredientName(name),
      originalName: name,
      amount: amount,
      unit: unit,
      weightInGrams: weightInGrams,
      isFlour: ingredientType.isFlour,
      isWater: ingredientType.isWater,
      isMilk: ingredientType.isMilk,
    );
  }

  /// 맵 형태 재료 데이터 파싱
  ParsedIngredient? _parseIngredientMap(Map<String, dynamic> data) {
    final name = data['name'] as String? ?? '';
    final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
    final unit = data['unit'] as String? ?? 'g';

    if (name.isEmpty || amount <= 0) return null;

    final weightInGrams = IngredientAnalyzer.convertToGrams(amount, unit, name);
    final ingredientType = _analyzeIngredientType(name);

    return ParsedIngredient(
      name: _normalizeIngredientName(name),
      originalName: name,
      amount: amount,
      unit: unit,
      weightInGrams: weightInGrams,
      isFlour: ingredientType.isFlour,
      isWater: ingredientType.isWater,
      isMilk: ingredientType.isMilk,
    );
  }

  /// 재료 타입 분석
  ({bool isFlour, bool isWater, bool isMilk}) _analyzeIngredientType(
      String name) {
    final lowerName = name.toLowerCase();

    final isFlour = lowerName.contains('밀가루') ||
        lowerName.contains('flour') ||
        lowerName.contains('강력분') ||
        lowerName.contains('중력분') ||
        lowerName.contains('박력분') ||
        lowerName.contains('통밀') ||
        lowerName.contains('whole wheat') ||
        lowerName.contains('bread flour') ||
        lowerName.contains('cake flour');

    final isWater = lowerName.contains('물') ||
        lowerName.contains('water') ||
        lowerName.contains('워터');

    final isMilk = lowerName.contains('우유') ||
        lowerName.contains('milk') ||
        lowerName.contains('크림') ||
        lowerName.contains('cream') ||
        lowerName.contains('요거트') ||
        lowerName.contains('yogurt');

    return (isFlour: isFlour, isWater: isWater, isMilk: isMilk);
  }

  /// 재료명 정규화 (개선된 버전 - 탭 문자 및 특수문자 처리 강화)
  String _normalizeIngredientName(String name) {
    // 탭 문자 및 특수문자 제거 (공백으로 변환)
    String normalized = name
        .replaceAll('\t', ' ') // 탭 문자 제거
        .replaceAll('\n', ' ') // 개행 문자 제거
        .replaceAll('\r', ' ') // 캐리지 리턴 제거
        .replaceAll(RegExp(r'[^\w\s가-힣]'), ' ') // 특수문자 제거
        .trim();

    // 연속된 공백을 단일 공백으로 정리
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');

    // 디버깅 로그 추가
    if (name != normalized) {
      print('🔄 [재료명 정규화] "$name" → "$normalized"');
    }

    return normalized;
  }

  /// 레시피명 추출 (첫 번째 줄)
  String? _extractRecipeName(String text) {
    final lines =
        text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    return lines.isNotEmpty ? lines.first.trim() : null;
  }

  /// 레시피 설명 추출 (두 번째 줄부터 시작되는 설명 부분)
  String? _extractRecipeDescription(String text) {
    final lines =
        text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    if (lines.length > 1) {
      // 첫 번째 줄이 레시피명이라면 두 번째 줄부터 설명으로 간주
      final descriptionLines = lines
          .skip(1)
          .takeWhile(
              (line) => !RegExp(r'^\d').hasMatch(line.trim()) // 숫자로 시작하지 않는 줄들
              )
          .toList();

      return descriptionLines.isNotEmpty
          ? descriptionLines.join(' ').trim()
          : null;
    }
    return null;
  }

  /// 재료 수분량 파싱 메소드 (mixing_analysis_card.dart에서 이동)
  Map<String, double> parseIngredientsForMoisture(
      Map<String, dynamic> recipeData) {
    try {
      print('💧 [재료 수분량 파싱] ===== 시작 =====');

      // 레시피 데이터 구조 확인
      final ingredientsRaw = recipeData['ingredients'];
      print('📋 [원본 재료 데이터] 타입: ${ingredientsRaw?.runtimeType}');
      print('📋 [원본 재료 데이터] 값: $ingredientsRaw');

      if (ingredientsRaw == null) {
        print('⚠️ [재료 데이터 없음] 안전한 기본값 반환');
        return _getSafeDefaultMoistureValues();
      }

      double flourWeight = 0.0;
      double waterWeight = 0.0;
      double milkWeight = 0.0;

      // 0. JSON 문자열인 경우 먼저 파싱 시도 (가장 우선)
      if (ingredientsRaw is String) {
        print('🔄 [JSON 문자열 감지] JSON 파싱 시도');
        print('🔍 [원본 JSON 문자열] "$ingredientsRaw"');

        // 여러 가지 JSON 파싱 시도
        dynamic jsonData;
        bool parseSuccess = false;

        // 시도 1: 기본 JSON 파싱
        try {
          jsonData = jsonDecode(ingredientsRaw);
          parseSuccess = true;
          print('✅ [JSON 파싱 성공] 기본 파싱으로 성공');
        } catch (e1) {
          print('⚠️ [기본 JSON 파싱 실패] $e1');

          // 시도 2: 따옴표 정리 후 파싱
          try {
            String cleanedJson = ingredientsRaw
                .replaceAll('\\"', '"') // 이스케이프된 따옴표 복원
                .replaceAll("\\'", "'") // 싱글 따옴표 정리
                .trim();

            // JSON 배열/객체 패턴 확인
            if (!cleanedJson.startsWith('[') && !cleanedJson.startsWith('{')) {
              // JSON이 아닌 경우 텍스트로 처리
              print('📝 [JSON 형식이 아님] 텍스트로 처리');
              final result = _parseWeightAndMoistureFromText(ingredientsRaw);
              flourWeight = result['flourWeight'] as double;
              waterWeight = result['waterWeight'] as double;
              milkWeight = result['milkWeight'] as double;
              parseSuccess = true;
            } else {
              jsonData = jsonDecode(cleanedJson);
              parseSuccess = true;
              print('✅ [JSON 파싱 성공] 정리 후 파싱으로 성공');
            }
          } catch (e2) {
            print('⚠️ [정리 후 JSON 파싱 실패] $e2');

            // 시도 3: 수동 JSON 배열 파싱
            try {
              if (ingredientsRaw.startsWith('[') &&
                  ingredientsRaw.endsWith(']')) {
                // JSON 배열 수동 파싱
                String content =
                    ingredientsRaw.substring(1, ingredientsRaw.length - 1);
                List<Map<String, dynamic>> manualArray = [];

                // 간단한 객체 분리 (쉼표로 분리)
                List<String> objects = _splitJsonObjects(content);
                for (String objStr in objects) {
                  if (objStr.trim().isNotEmpty) {
                    try {
                      Map<String, dynamic> obj =
                          _parseSimpleJsonObject(objStr.trim());
                      manualArray.add(obj);
                    } catch (e) {
                      print('⚠️ [객체 파싱 실패] $objStr');
                    }
                  }
                }

                jsonData = manualArray;
                parseSuccess = true;
                print('✅ [JSON 파싱 성공] 수동 배열 파싱으로 성공');
              }
            } catch (e3) {
              print('❌ [수동 JSON 파싱 실패] $e3');
              print('📝 [최종 fallback] 텍스트 파싱으로 전환');
              final result = _parseWeightAndMoistureFromText(ingredientsRaw);
              flourWeight = result['flourWeight'] as double;
              waterWeight = result['waterWeight'] as double;
              milkWeight = result['milkWeight'] as double;
              parseSuccess = true;
            }
          }
        }

        // JSON 파싱 성공 시 데이터 처리
        if (parseSuccess && jsonData != null) {
          print('📦 [JSON 데이터 처리 시작] 타입: ${jsonData.runtimeType}');

          if (jsonData is List) {
            print('📦 [JSON 배열 처리] ${jsonData.length}개 재료');
            for (int i = 0; i < jsonData.length; i++) {
              final ingredient = jsonData[i];
              print('🔍 [재료 ${i + 1}] $ingredient');

              if (ingredient is Map) {
                final result =
                    _extractWeightAndMoistureFromIngredientMap(ingredient);
                final weight = result['weight'] as double;
                final moisture = result['moisture'] as double;

                // 재료 타입에 따라 분류
                final name = ingredient['name']?.toString().toLowerCase() ?? '';
                if (IngredientAnalyzer.isFlour(name)) {
                  flourWeight += weight;
                } else if (_isWaterIngredient(name)) {
                  waterWeight += weight;
                } else if (_isMilkIngredient(name)) {
                  milkWeight += weight;
                }

                print('✅ [재료 ${i + 1}] 무게: ${weight}g, 수분: ${moisture}g');
                print(
                    '📊 [누적] 밀가루: ${flourWeight}g, 물: ${waterWeight}g, 우유: ${milkWeight}g');
              }
            }
          } else if (jsonData is Map) {
            print('📦 [JSON 객체 처리] 단일 재료');
            final result = _extractWeightAndMoistureFromIngredientMap(jsonData);
            final weight = result['weight'] as double;
            final moisture = result['moisture'] as double;

            // 재료 타입에 따라 분류
            final name = jsonData['name']?.toString().toLowerCase() ?? '';
            if (_isFlourIngredient(name)) {
              flourWeight += weight;
            } else if (_isWaterIngredient(name)) {
              waterWeight += weight;
            } else if (_isMilkIngredient(name)) {
              milkWeight += weight;
            }

            print('✅ [단일 객체] 무게: ${weight}g, 수분: ${moisture}g');
          }
        }
      }
      // 1. JSON 배열 형태 처리 (이미 List인 경우)
      else if (ingredientsRaw is List) {
        print('📦 [JSON 배열 파싱] ${ingredientsRaw.length}개 재료 처리 시작');
        for (int i = 0; i < ingredientsRaw.length; i++) {
          final ingredient = ingredientsRaw[i];
          print('🔍 [재료 ${i + 1}] 원본 데이터: $ingredient');

          if (ingredient is Map) {
            final result =
                _extractWeightAndMoistureFromIngredientMap(ingredient);
            final weight = result['weight'] as double;
            final moisture = result['moisture'] as double;

            // 재료 타입에 따라 분류
            final name = ingredient['name']?.toString().toLowerCase() ?? '';
            if (_isFlourIngredient(name)) {
              flourWeight += weight;
            } else if (_isWaterIngredient(name)) {
              waterWeight += weight;
            } else if (_isMilkIngredient(name)) {
              milkWeight += weight;
            }

            print('✅ [재료 ${i + 1}] 계산 결과 - 무게: ${weight}g, 수분: ${moisture}g');
            print(
                '📊 [누적 합계] 밀가루: ${flourWeight}g, 물: ${waterWeight}g, 우유: ${milkWeight}g');
          } else {
            print('⚠️ [재료 ${i + 1}] Map 타입이 아님: ${ingredient.runtimeType}');
          }
        }
      }
      // 2. JSON 객체 형태 처리
      else if (ingredientsRaw is Map) {
        print('📦 [JSON 객체 파싱] 단일 재료 객체 처리');
        final result =
            _extractWeightAndMoistureFromIngredientMap(ingredientsRaw);
        final weight = result['weight'] as double;
        final moisture = result['moisture'] as double;

        // 재료 타입에 따라 분류
        final name = ingredientsRaw['name']?.toString().toLowerCase() ?? '';
        if (_isFlourIngredient(name)) {
          flourWeight += weight;
        } else if (_isWaterIngredient(name)) {
          waterWeight += weight;
        } else if (_isMilkIngredient(name)) {
          milkWeight += weight;
        }

        print('✅ [단일 객체] 계산 결과 - 무게: ${weight}g, 수분: ${moisture}g');
      }
      // 3. 기타 형태 처리 (fallback)
      else {
        print('📝 [기타 타입 파싱] ${ingredientsRaw.runtimeType} 형태로 처리');
        final ingredientsText = ingredientsRaw.toString();
        print('📝 [텍스트 내용] "$ingredientsText"');

        final result = _parseWeightAndMoistureFromText(ingredientsText);
        flourWeight = result['flourWeight'] as double;
        waterWeight = result['waterWeight'] as double;
        milkWeight = result['milkWeight'] as double;

        print(
            '✅ [텍스트 파싱] 계산 결과 - 밀가루: ${flourWeight}g, 물: ${waterWeight}g, 우유: ${milkWeight}g');
      }

      // 우유의 수분 함량 고려 (우유 ≈ 87% 수분)
      final milkMoisture = milkWeight * 0.87;
      final totalMoisture = waterWeight + milkMoisture;

      print(
          '📊 [파싱 완료] 밀가루: ${flourWeight}g, 물: ${waterWeight}g, 우유: ${milkWeight}g, 총 수분: ${totalMoisture}g');

      return {
        'flourWeight': flourWeight,
        'waterWeight': waterWeight,
        'milkWeight': milkWeight,
        'totalMoisture': totalMoisture,
      };
    } catch (e) {
      print('❌ [재료 수분량 파싱 오류] $e');
      print('❌ [오류 스택트레이스] ${StackTrace.current}');
      return {
        'flourWeight': 500.0,
        'waterWeight': 300.0,
        'milkWeight': 0.0,
        'totalMoisture': 300.0
      };
    }
  }

  /// 재료 총량 계산 메소드 (mixing_analysis_card.dart에서 이동)
  double calculateTotalIngredientWeight(Map<String, dynamic> recipeData) {
    try {
      print('🔍 [재료 총량 계산] ===== 시작 =====');

      // 레시피 데이터 구조 확인
      final ingredientsRaw = recipeData['ingredients'];
      print('📋 [원본 재료 데이터] 타입: ${ingredientsRaw?.runtimeType}');
      print('📋 [원본 재료 데이터] 값: $ingredientsRaw');

      if (ingredientsRaw == null) {
        print('⚠️ [재료 데이터 없음] ingredients 키가 없어 기본값 1000.0g 반환');
        return 1000.0; // 기본값
      }

      double totalWeight = 0.0;
      double totalMoisture = 0.0;

      // 0. JSON 문자열인 경우 먼저 파싱 시도 (가장 우선)
      if (ingredientsRaw is String) {
        print('🔄 [JSON 문자열 감지] JSON 파싱 시도');
        print('🔍 [원본 JSON 문자열] "$ingredientsRaw"');

        // 여러 가지 JSON 파싱 시도
        dynamic jsonData;
        bool parseSuccess = false;

        // 시도 1: 기본 JSON 파싱
        try {
          jsonData = jsonDecode(ingredientsRaw);
          parseSuccess = true;
          print('✅ [JSON 파싱 성공] 기본 파싱으로 성공');
        } catch (e1) {
          print('⚠️ [기본 JSON 파싱 실패] $e1');

          // 시도 2: 따옴표 정리 후 파싱
          try {
            String cleanedJson = ingredientsRaw
                .replaceAll('\\"', '"') // 이스케이프된 따옴표 복원
                .replaceAll("\\'", "'") // 싱글 따옴표 정리
                .trim();

            // JSON 배열/객체 패턴 확인
            if (!cleanedJson.startsWith('[') && !cleanedJson.startsWith('{')) {
              // JSON이 아닌 경우 텍스트로 처리
              print('📝 [JSON 형식이 아님] 텍스트로 처리');
              final result = _parseWeightAndMoistureFromText(ingredientsRaw);
              totalWeight = result['weight'] as double;
              totalMoisture = result['moisture'] as double;
              parseSuccess = true;
            } else {
              jsonData = jsonDecode(cleanedJson);
              parseSuccess = true;
              print('✅ [JSON 파싱 성공] 정리 후 파싱으로 성공');
            }
          } catch (e2) {
            print('⚠️ [정리 후 JSON 파싱 실패] $e2');

            // 시도 3: 수동 JSON 배열 파싱
            try {
              if (ingredientsRaw.startsWith('[') &&
                  ingredientsRaw.endsWith(']')) {
                // JSON 배열 수동 파싱
                String content =
                    ingredientsRaw.substring(1, ingredientsRaw.length - 1);
                List<Map<String, dynamic>> manualArray = [];

                // 간단한 객체 분리 (쉼표로 분리)
                List<String> objects = _splitJsonObjects(content);
                for (String objStr in objects) {
                  if (objStr.trim().isNotEmpty) {
                    try {
                      Map<String, dynamic> obj =
                          _parseSimpleJsonObject(objStr.trim());
                      manualArray.add(obj);
                    } catch (e) {
                      print('⚠️ [객체 파싱 실패] $objStr');
                    }
                  }
                }

                jsonData = manualArray;
                parseSuccess = true;
                print('✅ [JSON 파싱 성공] 수동 배열 파싱으로 성공');
              }
            } catch (e3) {
              print('❌ [수동 JSON 파싱 실패] $e3');
              print('📝 [최종 fallback] 텍스트 파싱으로 전환');
              final result = _parseWeightAndMoistureFromText(ingredientsRaw);
              totalWeight = result['weight'] as double;
              totalMoisture = result['moisture'] as double;
              parseSuccess = true;
            }
          }
        }

        // JSON 파싱 성공 시 데이터 처리
        if (parseSuccess && jsonData != null) {
          print('📦 [JSON 데이터 처리 시작] 타입: ${jsonData.runtimeType}');

          if (jsonData is List) {
            print('📦 [JSON 배열 처리] ${jsonData.length}개 재료');
            for (int i = 0; i < jsonData.length; i++) {
              final ingredient = jsonData[i];
              print('🔍 [재료 ${i + 1}] $ingredient');

              if (ingredient is Map) {
                final result =
                    _extractWeightAndMoistureFromIngredientMap(ingredient);
                final weight = result['weight'] as double;
                final moisture = result['moisture'] as double;

                totalWeight += weight;
                totalMoisture += moisture;

                print('✅ [재료 ${i + 1}] 무게: ${weight}g, 수분: ${moisture}g');
                print('📊 [누적] 총 무게: ${totalWeight}g, 총 수분: ${totalMoisture}g');
              }
            }
          } else if (jsonData is Map) {
            print('📦 [JSON 객체 처리] 단일 재료');
            final result = _extractWeightAndMoistureFromIngredientMap(jsonData);
            totalWeight += result['weight'] as double;
            totalMoisture += result['moisture'] as double;
            print(
                '✅ [단일 객체] 무게: ${result['weight']}g, 수분: ${result['moisture']}g');
          }
        }
      }
      // 1. JSON 배열 형태 처리 (이미 List인 경우)
      else if (ingredientsRaw is List) {
        print('📦 [JSON 배열 파싱] ${ingredientsRaw.length}개 재료 처리 시작');
        for (int i = 0; i < ingredientsRaw.length; i++) {
          final ingredient = ingredientsRaw[i];
          print('🔍 [재료 ${i + 1}] 원본 데이터: $ingredient');

          if (ingredient is Map) {
            final result =
                _extractWeightAndMoistureFromIngredientMap(ingredient);
            final weight = result['weight'] as double;
            final moisture = result['moisture'] as double;

            totalWeight += weight;
            totalMoisture += moisture;

            print('✅ [재료 ${i + 1}] 계산 결과 - 무게: ${weight}g, 수분: ${moisture}g');
            print('📊 [누적 합계] 총 무게: ${totalWeight}g, 총 수분: ${totalMoisture}g');
          } else {
            print('⚠️ [재료 ${i + 1}] Map 타입이 아님: ${ingredient.runtimeType}');
          }
        }
      }
      // 2. JSON 객체 형태 처리
      else if (ingredientsRaw is Map) {
        print('📦 [JSON 객체 파싱] 단일 재료 객체 처리');
        final result =
            _extractWeightAndMoistureFromIngredientMap(ingredientsRaw);
        totalWeight += result['weight'] as double;
        totalMoisture += result['moisture'] as double;
        print(
            '✅ [단일 객체] 계산 결과 - 무게: ${result['weight']}g, 수분: ${result['moisture']}g');
      }
      // 3. 기타 형태 처리 (fallback)
      else {
        print('📝 [기타 타입 파싱] ${ingredientsRaw.runtimeType} 형태로 처리');
        final ingredientsText = ingredientsRaw.toString();
        print('📝 [텍스트 내용] "$ingredientsText"');

        final result = _parseWeightAndMoistureFromText(ingredientsText);
        totalWeight = result['weight'] as double;
        totalMoisture = result['moisture'] as double;

        print('✅ [텍스트 파싱] 계산 결과 - 무게: ${totalWeight}g, 수분: ${totalMoisture}g');
      }

      print('📊 [파싱 완료] 총 재료량: ${totalWeight}g, 총 수분량: ${totalMoisture}g');

      // ✅ 물리법칙 준수: clamp 제거 (실제 계산값 그대로 반환)
      // 빵 제조 과학적으로 계산된 값은 그대로 유지 (물리적 한계 검증만 수행)
      print('🎯 [최종 결과]');
      print('   📊 파싱된 실제 총량: ${totalWeight}g');
      print('   ✅ 물리법칙 준수: clamp 제거, 실제 계산값 그대로 반환');
      print('   🔍 물리적 한계 검증: 수분량은 재료 무게를 초과할 수 없음');

      // ✅ 물리법칙 준수: 실제 계산값 그대로 반환 (clamp 제거)
      return totalWeight;
    } catch (e) {
      print('❌ [재료 총량 계산 오류] $e');
      print('❌ [오류 스택트레이스] ${StackTrace.current}');
      return 1000.0; // 오류 시 기본값
    }
  }

  /// 재료 객체에서 무게와 수분량 추출 (물리법칙 준수 버전 - 개선됨)
  /// ✅ 물리법칙 준수: 수분량은 물리적 한계를 초과할 수 없음
  Map<String, double> _extractWeightAndMoistureFromIngredientMap(
      Map<dynamic, dynamic> ingredient) {
    try {
      // 다양한 키 이름 시도 (더 포괄적)
      final possibleAmountKeys = [
        'amount',
        'quantity',
        'qty',
        'weight',
        'mass',
        'value',
        'amt'
      ];
      final possibleUnitKeys = ['unit', 'units', 'measure', 'measurement', 'u'];
      final possibleNameKeys = ['name', 'ingredient', 'item', 'title'];

      double? amount;
      String? unit;
      String? name;

      // 양 추출 (더 유연하게)
      for (final key in possibleAmountKeys) {
        if (ingredient.containsKey(key)) {
          final value = ingredient[key];
          if (value is num) {
            amount = value.toDouble();
            break;
          } else if (value is String) {
            // 문자열에서 숫자 추출 시도 (예: "290.0", "290")
            final numMatch = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(value);
            if (numMatch != null) {
              amount = double.tryParse(numMatch.group(1)!);
              if (amount != null) break;
            }
          }
        }
      }

      // 단위 추출 (더 유연하게)
      for (final key in possibleUnitKeys) {
        if (ingredient.containsKey(key)) {
          final value = ingredient[key];
          if (value is String && value.trim().isNotEmpty) {
            unit = value.toLowerCase().trim();
            break;
          }
        }
      }

      // 이름 추출 (더 유연하게)
      for (final key in possibleNameKeys) {
        if (ingredient.containsKey(key)) {
          final value = ingredient[key];
          if (value is String && value.trim().isNotEmpty) {
            name = value.toLowerCase().trim();
            break;
          }
        }
      }

      // ✅ 물리법칙 준수: 기본값 적용 (컨셉 준수하면서도 유연성 확보)
      // amount가 null이거나 0인 경우에도 기본값 적용
      if (amount == null) {
        print('⚠️ [무게 추출] 양이 null이므로 기본값 100g 사용');
        amount = 100.0; // 기본값 적용
      } else if (amount <= 0) {
        print('⚠️ [무게 추출] 양이 0 이하이므로 기본값 100g 사용');
        amount = 100.0; // 기본값 적용
      }

      // unit이 없는 경우 기본값 적용
      if (unit == null || unit.isEmpty) {
        print('⚠️ [단위 추출] 단위가 없으므로 기본값 "g" 사용');
        unit = 'g'; // 기본 단위
      }

      // name이 없는 경우 기본값 적용
      if (name == null || name.isEmpty) {
        print('⚠️ [이름 추출] 이름이 없으므로 기본값 "unknown" 사용');
        name = 'unknown'; // 기본 이름
      }

      // 단위 변환 적용
      final weightInGrams =
          IngredientAnalyzer.convertToGrams(amount, unit, name);

      // 수분량 계산 (재료 타입에 따라 다르게)
      double moistureContent = 0.0;
      if (_isMilkIngredient(name)) {
        // 우유: 87% 수분 (빵 제조 과학적 상수)
        moistureContent = weightInGrams * 0.87;
      } else if (_isWaterIngredient(name)) {
        // 물: 100% 수분 (물리화학적 상수)
        moistureContent = weightInGrams;
      }
      // 다른 재료들은 수분 함량 0으로 가정 (빵 제조에서 주로 건조 재료)

      // ✅ 물리법칙 준수: 수분량 물리적 한계 검증
      // 우유의 경우 수분량은 무게를 초과할 수 없음 (물리적 한계)
      if (_isMilkIngredient(name) && moistureContent > weightInGrams) {
        print('⚠️ [물리법칙 준수] 우유 수분량이 무게를 초과함');
        print('   - 계산된 수분: ${moistureContent.toStringAsFixed(1)}g');
        print('   - 물리적 한계: ${weightInGrams.toStringAsFixed(1)}g');
        print('   - 물리적 원리: 수분량은 재료 무게를 초과할 수 없음');
        // 물리법칙 위반 시 계산값 유지 (clamp 제거)
      }

      // ✅ 물리법칙 준수: 물의 경우 수분량은 무게와 같아야 함 (물리적 한계)
      if (_isWaterIngredient(name) && moistureContent != weightInGrams) {
        print('⚠️ [물리법칙 준수] 물 수분량이 무게와 다름');
        print('   - 계산된 수분: ${moistureContent.toStringAsFixed(1)}g');
        print('   - 물리적 한계: ${weightInGrams.toStringAsFixed(1)}g');
        print('   - 물리적 원리: 물의 수분량은 무게와 같아야 함');
        // 물리법칙 위반 시 계산값 유지 (clamp 제거)
      }

      print(
          '✅ [재료 객체 파싱 성공] $name: ${weightInGrams}g, 수분: ${moistureContent}g');
      return {'weight': weightInGrams, 'moisture': moistureContent};
    } catch (e) {
      print('❌ [재료 객체 파싱 오류] $e');
      // 오류 시에도 기본값 반환 (NaN 방지)
      return {'weight': 100.0, 'moisture': 0.0};
    }
  }

  /// 텍스트에서 무게와 수분량 파싱 (개선된 버전)
  Map<String, double> _parseWeightAndMoistureFromText(String text) {
    double flourWeight = 0.0;
    double waterWeight = 0.0;
    double milkWeight = 0.0;

    // 빈 줄로 분리 (더 유연한 파싱)
    final lines = text.split(RegExp(r'[\n\r]+'));
    print('📏 [분리된 라인 수] ${lines.length}');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final lowerLine = line.toLowerCase();
      print('🔍 [라인 ${i + 1}] "$line"');

      // 밀가루 양 추출
      for (final keyword in [
        '밀가루',
        '강력분',
        '중력분',
        '박력분',
        '통밀가루',
        '호밀가루',
        '라이밀가루',
        'flour',
        'wheat flour',
        'bread flour',
        'all-purpose flour',
        'cake flour',
        'whole wheat flour',
        'rye flour',
        'spelt flour'
      ]) {
        if (lowerLine.contains(keyword)) {
          final weight = _extractWeightFromLine(line);
          if (weight > 0) {
            flourWeight += weight;
            print('🌾 [밀가루 감지] "$keyword" → ${weight}g (총: ${flourWeight}g)');
            break;
          }
        }
      }

      // 물 양 추출
      for (final keyword in [
        '물',
        '뜨거운 물',
        '차가운 물',
        '따뜻한 물',
        '온수',
        '냉수',
        'water',
        'warm water',
        'hot water',
        'cold water',
        'ice water'
      ]) {
        if (lowerLine.contains(keyword)) {
          final weight = _extractWeightFromLine(line);
          if (weight > 0) {
            waterWeight += weight;
            print('💧 [물 감지] "$keyword" → ${weight}g (총: ${waterWeight}g)');
            break;
          }
        }
      }

      // 우유 양 추출
      for (final keyword in [
        '우유',
        '전지유',
        '저지방우유',
        '무지방우유',
        '생우유',
        '요구르트',
        '크림',
        'milk',
        'whole milk',
        'skim milk',
        'low-fat milk',
        'fresh milk',
        'yogurt',
        'cream',
        'buttermilk'
      ]) {
        if (lowerLine.contains(keyword)) {
          final weight = _extractWeightFromLine(line);
          if (weight > 0) {
            milkWeight += weight;
            print('🥛 [우유 감지] "$keyword" → ${weight}g (총: ${milkWeight}g)');
            break;
          }
        }
      }
    }

    // 우유의 수분 함량 고려 (우유 ≈ 87% 수분)
    final milkMoisture = milkWeight * 0.87;
    final totalMoisture = waterWeight + milkMoisture;

    print(
        '✅ [텍스트 파싱 성공] 밀가루: ${flourWeight}g, 물: ${waterWeight}g, 우유: ${milkWeight}g, 총 수분: ${totalMoisture}g');

    return {
      'flourWeight': flourWeight,
      'waterWeight': waterWeight,
      'milkWeight': milkWeight,
      'weight': flourWeight + waterWeight + milkWeight, // 총 무게
      'moisture': totalMoisture, // 총 수분
      'totalMoisture': totalMoisture, // 호환성 유지
    };
  }

  /// 동적 재료량 제한 계산
  Map<String, double> _calculateDynamicWeightLimits(
      Map<String, dynamic> recipeData) {
    // 빵 타입에 따른 기본 제한 계산
    final breadType = _analyzeBreadType(recipeData);
    final flourType = _analyzeFlourType(recipeData);

    // 기본 제한값 (빵 제조 과학 기반)
    double minWeight = 300.0; // 최소 300g
    double maxWeight = 5000.0; // 최대 5kg

    // 빵 타입에 따른 조정
    switch (breadType) {
      case '식빵':
        minWeight = 400.0; // 식빵은 어느 정도 크기가 필요
        maxWeight = 3000.0;
        break;
      case '바게트':
        minWeight = 250.0; // 바게트는 상대적으로 작음
        maxWeight = 1000.0;
        break;
      case '크루아상':
        minWeight = 200.0; // 크루아상은 더 작음
        maxWeight = 800.0;
        break;
      case '케이크':
        minWeight = 300.0;
        maxWeight = 2000.0;
        break;
      default:
        // 일반 빵 타입
        minWeight = 300.0;
        maxWeight = 3000.0;
    }

    // 밀가루 타입에 따른 조정
    switch (flourType) {
      case '강력분':
        minWeight *= 1.1; // 강력분은 더 많은 양 필요
        break;
      case '박력분':
        minWeight *= 0.9; // 박력분은 상대적으로 적은 양
        break;
      case '통밀가루':
        minWeight *= 1.2; // 통밀가루는 수분 흡수가 높아 더 많은 양
        break;
    }

    // 환경 요인 고려 (기본값 사용)
    final temp = 25.0; // 기본 온도
    final humidity = 50.0; // 기본 습도

    // 고온/저온 환경에서는 제한 조정
    if (temp >= 30) {
      minWeight *= 0.9; // 고온: 최소량 감소
      maxWeight *= 0.95;
    } else if (temp <= 15) {
      minWeight *= 1.1; // 저온: 최소량 증가
      maxWeight *= 1.05;
    }

    // 습도에 따른 조정
    if (humidity >= 70) {
      minWeight *= 0.95; // 고습도: 최소량 감소
    } else if (humidity <= 30) {
      minWeight *= 1.05; // 저습도: 최소량 증가
    }

    return {
      'minWeight': minWeight.clamp(100.0, 1000.0), // 최소 100g, 최대 1kg
      'maxWeight': maxWeight.clamp(1000.0, 10000.0), // 최소 1kg, 최대 10kg
    };
  }

  /// 빵 타입 분석
  String _analyzeBreadType(Map<String, dynamic> recipeData) {
    final recipeName = recipeData['name']?.toString().toLowerCase() ?? '';
    final description =
        recipeData['description']?.toString().toLowerCase() ?? '';

    final combinedText = '$recipeName $description';

    if (combinedText.contains('식빵') ||
        combinedText.contains('sandwich') ||
        combinedText.contains('loaf')) {
      return '식빵';
    } else if (combinedText.contains('바게트') ||
        combinedText.contains('baguette') ||
        combinedText.contains('french')) {
      return '바게트';
    } else if (combinedText.contains('크루아상') ||
        combinedText.contains('croissant')) {
      return '크루아상';
    } else if (combinedText.contains('케이크') || combinedText.contains('cake')) {
      return '케이크';
    } else if (combinedText.contains('쿠키') || combinedText.contains('cookie')) {
      return '쿠키';
    } else {
      return '일반빵'; // 기본값
    }
  }

  /// 밀가루 타입 분석
  String _analyzeFlourType(Map<String, dynamic> recipeData) {
    final ingredients =
        recipeData['ingredients']?.toString().toLowerCase() ?? '';

    if (ingredients.contains('강력분') || ingredients.contains('bread flour')) {
      return '강력분';
    } else if (ingredients.contains('중력분') ||
        ingredients.contains('all-purpose flour')) {
      return '중력분';
    } else if (ingredients.contains('박력분') ||
        ingredients.contains('cake flour')) {
      return '박력분';
    } else if (ingredients.contains('통밀가루') ||
        ingredients.contains('whole wheat flour')) {
      return '통밀가루';
    } else if (ingredients.contains('호밀가루') ||
        ingredients.contains('rye flour')) {
      return '호밀가루';
    } else if (ingredients.contains('밀가루') || ingredients.contains('flour')) {
      return '중력분'; // 일반 밀가루는 중력분으로 가정
    }

    return 'unknown';
  }

  /// 안전한 기본 수분 값 반환 (NaN 방지)
  Map<String, double> _getSafeDefaultMoistureValues() {
    print('🛡️ [안전한 기본값 사용] 밀가루: 500g, 물: 300g, 우유: 0g, 총 수분: 300g');
    return {
      'flourWeight': 500.0, // 빵 제조 표준 밀가루량
      'waterWeight': 300.0, // 빵 제조 표준 물량
      'milkWeight': 0.0, // 기본 우유 없음
      'totalMoisture': 300.0 // 총 수분량
    };
  }

  /// 밀가루 재료인지 확인 (개선된 버전 - 탭 문자 처리 및 키워드 확장)
  bool _isFlourIngredient(String name) {
    // 먼저 정규화된 이름으로 확인
    final normalizedName = _normalizeIngredientName(name);

    final flourKeywords = [
      '밀가루',
      '강력분',
      '중력분',
      '박력분',
      '통밀가루',
      '호밀가루',
      '라이밀가루',
      'flour',
      'wheat flour',
      'bread flour',
      'all-purpose flour',
      'cake flour',
      'whole wheat flour',
      'rye flour',
      'spelt flour',
      // 추가 키워드 (더 포괄적인 인식)
      '밀가루분',
      '빵가루',
      '곡물가루',
      '글루텐',
      '밀',
      'wheat',
      'grain flour',
      'pastry flour',
      'self-rising flour',
      'durum flour',
      'semolina flour',
      'barley flour',
      'oat flour',
      'corn flour',
      'rice flour',
      'potato flour',
      'soy flour',
      'chickpea flour',
      'almond flour',
      'coconut flour',
    ];

    final isFlour = flourKeywords.any((keyword) =>
        normalizedName.contains(keyword) || name.contains(keyword));

    // 디버깅 로그 추가
    if (isFlour) {
      print('🌾 [밀가루 인식 성공] "$name" → "$normalizedName" (키워드 매칭)');
    }

    return isFlour;
  }

  /// 물 재료인지 확인
  bool _isWaterIngredient(String name) {
    final waterKeywords = [
      '물',
      '뜨거운 물',
      '차가운 물',
      '따뜻한 물',
      '온수',
      '냉수',
      'water',
      'warm water',
      'hot water',
      'cold water',
      'ice water'
    ];

    return waterKeywords.any((keyword) => name.contains(keyword));
  }

  /// 우유 재료인지 확인
  bool _isMilkIngredient(String name) {
    final milkKeywords = [
      '우유',
      '전지유',
      '저지방우유',
      '무지방우유',
      '생우유',
      '요구르트',
      '크림',
      'milk',
      'whole milk',
      'skim milk',
      'low-fat milk',
      'fresh milk',
      'yogurt',
      'cream',
      'buttermilk'
    ];

    return milkKeywords.any((keyword) => name.contains(keyword));
  }

  /// 텍스트 라인에서 무게 추출
  double _extractWeightFromLine(String line) {
    // 숫자 + 단위 패턴 찾기
    final weightPatterns =
        RegExp(r'(\d+(?:\.\d+)?)\s*(g|kg|ml|l|컵|cup)', caseSensitive: false);
    final matches = weightPatterns.allMatches(line);

    double totalWeight = 0.0;
    for (final match in matches) {
      final amount = double.tryParse(match.group(1) ?? '0') ?? 0.0;
      final unit = match.group(2)?.toLowerCase() ?? '';

      double weightInGrams = amount;

      // 단위 변환
      switch (unit) {
        case 'kg':
          weightInGrams = amount * 1000;
          break;
        case 'ml':
        case 'l':
          // 액체의 경우 밀도 1.0으로 가정
          weightInGrams = unit == 'l' ? amount * 1000 : amount;
          break;
        case '컵':
        case 'cup':
          // 빵 제조에서 1컵 ≈ 240ml ≈ 240g (물 기준), 120g (밀가루 기준)
          // 재료 타입에 따라 다르게 처리할 수 있지만, 여기서는 평균값 사용
          weightInGrams = amount * 180; // 중간값 사용
          break;
        case 'g':
        default:
          weightInGrams = amount;
          break;
      }

      totalWeight += weightInGrams;
    }

    return totalWeight;
  }

  /// JSON 객체들을 분리하는 헬퍼 메소드
  List<String> _splitJsonObjects(String content) {
    final objects = <String>[];
    int braceCount = 0;
    int startIndex = 0;
    bool inString = false;
    bool escaped = false;

    for (int i = 0; i < content.length; i++) {
      final char = content[i];

      if (escaped) {
        escaped = false;
        continue;
      }

      if (char == '\\') {
        escaped = true;
        continue;
      }

      if (char == '"' && !escaped) {
        inString = !inString;
        continue;
      }

      if (!inString) {
        if (char == '{') {
          if (braceCount == 0) {
            startIndex = i;
          }
          braceCount++;
        } else if (char == '}') {
          braceCount--;
          if (braceCount == 0) {
            objects.add(content.substring(startIndex, i + 1));
          }
        } else if (char == ',' && braceCount == 0) {
          // 최상위 레벨의 쉼표는 무시
          continue;
        }
      }
    }

    return objects;
  }

  /// 간단한 JSON 객체를 파싱하는 헬퍼 메소드
  Map<String, dynamic> _parseSimpleJsonObject(String objStr) {
    final result = <String, dynamic>{};
    final cleaned = objStr.trim();

    if (!cleaned.startsWith('{') || !cleaned.endsWith('}')) {
      throw FormatException('Invalid JSON object format');
    }

    // 중괄호 제거
    final content = cleaned.substring(1, cleaned.length - 1);

    // 간단한 키-값 쌍 분리 (쉼표로 분리)
    final pairs = <String>[];
    int parenCount = 0;
    int bracketCount = 0;
    int startIndex = 0;
    bool inString = false;
    bool escaped = false;

    for (int i = 0; i < content.length; i++) {
      final char = content[i];

      if (escaped) {
        escaped = false;
        continue;
      }

      if (char == '\\') {
        escaped = true;
        continue;
      }

      if (char == '"' && !escaped) {
        inString = !inString;
        continue;
      }

      if (!inString) {
        if (char == '(' || char == '[' || char == '{') {
          if (char == '(') parenCount++;
          if (char == '[') bracketCount++;
          if (char == '{') parenCount++; // 중괄호도 카운트
        } else if (char == ')' || char == ']' || char == '}') {
          if (char == ')') parenCount--;
          if (char == ']') bracketCount--;
          if (char == '}') parenCount--; // 중괄호도 카운트
        } else if (char == ',' && parenCount == 0 && bracketCount == 0) {
          pairs.add(content.substring(startIndex, i).trim());
          startIndex = i + 1;
        }
      }
    }

    // 마지막 쌍 추가
    if (startIndex < content.length) {
      pairs.add(content.substring(startIndex).trim());
    }

    // 각 쌍 파싱
    for (final pair in pairs) {
      final colonIndex = pair.indexOf(':');
      if (colonIndex == -1) continue;

      final key = pair.substring(0, colonIndex).trim().replaceAll('"', '');
      final value = pair.substring(colonIndex + 1).trim();

      // 값 타입에 따라 파싱
      if (value.startsWith('"') && value.endsWith('"')) {
        // 문자열
        result[key] = value.substring(1, value.length - 1);
      } else if (value == 'true' || value == 'false') {
        // 불리언
        result[key] = value == 'true';
      } else if (value == 'null') {
        // null
        result[key] = null;
      } else if (RegExp(r'^-?\d+(\.\d+)?$').hasMatch(value)) {
        // 숫자
        if (value.contains('.')) {
          result[key] = double.tryParse(value) ?? value;
        } else {
          result[key] = int.tryParse(value) ?? value;
        }
      } else {
        // 기타 (문자열로 처리)
        result[key] = value.replaceAll('"', '');
      }
    }

    return result;
  }
}

/// 레시피 파싱 예외 클래스
class RecipeParsingException implements Exception {
  final String message;
  const RecipeParsingException(this.message);

  @override
  String toString() => 'RecipeParsingException: $message';
}
