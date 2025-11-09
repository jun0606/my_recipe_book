/// 재료 분석 및 감지 유틸리티
/// Sous Chef 모드에서 레시피의 재료를 분석하고 분류하는 기능을 제공합니다.

import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../core/constants/bread_constants.dart';

class IngredientAnalyzer {
  /// 밀가루 종류별 특성 데이터베이스
  /// ✅ 빵 제조 과학적 실제 값으로 수정 (초기 글루텐 형성도 기준)
  static const Map<String, Map<String, dynamic>> _flourCharacteristics = {
    'bread_flour': {
      'proteinContent': 0.125, // 12.5%
      'moistureContent': 0.135, // 13.5%
      'glutenFormation': 0.12, // 12% (실제 글루텐 함량 기반 초기 형성도)
      'hydrationCapacity': 0.75, // 75%
      'density': 0.65, // g/ml
      'keywords': ['강력분', 'bread flour', 'high-gluten flour'],
    },
    'all_purpose_flour': {
      'proteinContent': 0.105, // 10.5%
      'moistureContent': 0.125, // 12.5%
      'glutenFormation': 0.10, // 10% (실제 글루텐 함량 기반 초기 형성도)
      'hydrationCapacity': 0.65, // 65%
      'density': 0.60, // g/ml
      'keywords': ['중력분', 'all-purpose flour', 'all purpose'],
    },
    'cake_flour': {
      'proteinContent': 0.08, // 8%
      'moistureContent': 0.115, // 11.5%
      'glutenFormation': 0.08, // 8% (실제 글루텐 함량 기반 초기 형성도)
      'hydrationCapacity': 0.55, // 55%
      'density': 0.55, // g/ml
      'keywords': ['박력분', 'cake flour', 'soft flour'],
    },
    'whole_wheat_flour': {
      'proteinContent': 0.13, // 13%
      'moistureContent': 0.140, // 14.0%
      'glutenFormation': 0.6, // 60%
      'hydrationCapacity': 0.70, // 70%
      'density': 0.68, // g/ml
      'keywords': ['통밀가루', 'whole wheat flour', 'whole wheat'],
    },
    'rye_flour': {
      'proteinContent': 0.09, // 9%
      'moistureContent': 0.145, // 14.5%
      'glutenFormation': 0.3, // 30%
      'hydrationCapacity': 0.80, // 80%
      'density': 0.70, // g/ml
      'keywords': ['호밀가루', 'rye flour'],
    },
    'general_flour': {
      'proteinContent': 0.11, // 11%
      'moistureContent': 0.125, // 12.5%
      'glutenFormation': 0.6, // 60%
      'hydrationCapacity': 0.65, // 65%
      'density': 0.60, // g/ml
      'keywords': ['밀가루', 'flour', '생종', '탕종'],
    },
  };

  /// 밀가루 종류 감지 및 특성 반환
  static Map<String, dynamic> detectFlourType(String name) {
    final normalizedName = _normalizeIngredientName(name);

    for (final entry in _flourCharacteristics.entries) {
      final flourType = entry.key;
      final characteristics = entry.value;
      final keywords = characteristics['keywords'] as List<String>;

      if (keywords.any((keyword) => normalizedName.contains(keyword))) {
        return {
          'type': flourType,
          'characteristics': characteristics,
          'detectedKeyword': keywords.firstWhere(
            (keyword) => normalizedName.contains(keyword),
            orElse: () => '',
          ),
        };
      }
    }

    // 기본 밀가루 타입 반환
    return {
      'type': 'general_flour',
      'characteristics': _flourCharacteristics['general_flour']!,
      'detectedKeyword': '밀가루',
    };
  }

  /// 밀가루 종류별 특성을 고려한 수분 함량 계산
  static double getFlourMoistureContent(String name) {
    final flourInfo = detectFlourType(name);
    final characteristics =
        flourInfo['characteristics'] as Map<String, dynamic>;
    final moistureContent = characteristics['moistureContent'] as double;

    print('🔍 [밀가루 수분 함량] 밀가루 종류 감지: ${flourInfo['type']}');
    print('   - 감지된 키워드: ${flourInfo['detectedKeyword']}');
    print('   - 수분 함량: ${(moistureContent * 100).toStringAsFixed(1)}%');

    return moistureContent;
  }

  /// 밀가루 종류별 특성을 고려한 단백질 함량 계산
  static double getFlourProteinContent(String name) {
    final flourInfo = detectFlourType(name);
    final characteristics =
        flourInfo['characteristics'] as Map<String, dynamic>;
    final proteinContent = characteristics['proteinContent'] as double;

    print('🔍 [밀가루 단백질 함량] 밀가루 종류 감지: ${flourInfo['type']}');
    print('   - 감지된 키워드: ${flourInfo['detectedKeyword']}');
    print('   - 단백질 함량: ${(proteinContent * 100).toStringAsFixed(1)}%');

    return proteinContent;
  }

  /// 밀가루 종류별 특성을 고려한 글루텐 형성도 계산
  static double getFlourGlutenFormation(String name) {
    final flourInfo = detectFlourType(name);
    final characteristics =
        flourInfo['characteristics'] as Map<String, dynamic>;
    final glutenFormation = characteristics['glutenFormation'] as double;

    print('🔍 [밀가루 글루텐 형성도] 밀가루 종류 감지: ${flourInfo['type']}');
    print('   - 감지된 키워드: ${flourInfo['detectedKeyword']}');
    print('   - 글루텐 형성도: ${(glutenFormation * 100).toStringAsFixed(1)}%');

    return glutenFormation;
  }

  /// 밀가루 종류별 특성을 고려한 수분 흡수율 계산
  static double getFlourHydrationCapacity(String name) {
    final flourInfo = detectFlourType(name);
    final characteristics =
        flourInfo['characteristics'] as Map<String, dynamic>;
    final hydrationCapacity = characteristics['hydrationCapacity'] as double;

    print('🔍 [밀가루 수분 흡수율] 밀가루 종류 감지: ${flourInfo['type']}');
    print('   - 감지된 키워드: ${flourInfo['detectedKeyword']}');
    print('   - 수분 흡수율: ${(hydrationCapacity * 100).toStringAsFixed(1)}%');

    return hydrationCapacity;
  }

  /// 밀가루 종류별 밀도 반환
  static double getFlourDensity(String name) {
    final flourInfo = detectFlourType(name);
    final characteristics =
        flourInfo['characteristics'] as Map<String, dynamic>;
    final density = characteristics['density'] as double;

    print('🔍 [밀가루 밀도 계산] 밀가루 종류 감지: ${flourInfo['type']}');
    print('   - 감지된 키워드: ${flourInfo['detectedKeyword']}');
    print('   - 밀도: ${density.toStringAsFixed(3)} g/ml');

    return density;
  }

  /// 레시피 제목을 기반으로 빵 타입 추정
  static String estimateBreadTypeFromTitle(String title) {
    final lowerTitle = title.toLowerCase();

    // 한국어 빵 타입
    if (lowerTitle.contains('식빵') || lowerTitle.contains('토스트')) return 'bread';
    if (lowerTitle.contains('바게트') || lowerTitle.contains('프랑스빵'))
      return 'baguette';
    if (lowerTitle.contains('크루아상') || lowerTitle.contains('크로와상'))
      return 'croissant';
    if (lowerTitle.contains('브리오슈') || lowerTitle.contains('브리오쉬'))
      return 'brioche';
    if (lowerTitle.contains('사워도우') || lowerTitle.contains('천연발효'))
      return 'sourdough';
    if (lowerTitle.contains('피자') || lowerTitle.contains('도우')) return 'pizza';
    if (lowerTitle.contains('쿠키') || lowerTitle.contains('비스킷'))
      return 'cookie';
    if (lowerTitle.contains('케이크') || lowerTitle.contains('스펀지')) return 'cake';
    if (lowerTitle.contains('머핀') || lowerTitle.contains('컵케이크'))
      return 'muffin';
    if (lowerTitle.contains('스콘')) return 'scone';
    if (lowerTitle.contains('도넛') || lowerTitle.contains('도우넛')) return 'donut';
    if (lowerTitle.contains('베이글')) return 'bagel';
    if (lowerTitle.contains('프레첼')) return 'pretzel';
    if (lowerTitle.contains('치아바타')) return 'ciabatta';
    if (lowerTitle.contains('포카치아')) return 'focaccia';
    if (lowerTitle.contains('난') || lowerTitle.contains('인도빵')) return 'naan';

    // 영어 빵 타입
    if (lowerTitle.contains('bread') || lowerTitle.contains('loaf'))
      return 'bread';
    if (lowerTitle.contains('baguette') || lowerTitle.contains('french bread'))
      return 'baguette';
    if (lowerTitle.contains('croissant')) return 'croissant';
    if (lowerTitle.contains('brioche')) return 'brioche';
    if (lowerTitle.contains('sourdough')) return 'sourdough';
    if (lowerTitle.contains('pizza')) return 'pizza';
    if (lowerTitle.contains('cookie') || lowerTitle.contains('biscuit'))
      return 'cookie';
    if (lowerTitle.contains('cake')) return 'cake';
    if (lowerTitle.contains('muffin') || lowerTitle.contains('cupcake'))
      return 'muffin';
    if (lowerTitle.contains('scone')) return 'scone';
    if (lowerTitle.contains('donut') || lowerTitle.contains('doughnut'))
      return 'donut';
    if (lowerTitle.contains('bagel')) return 'bagel';
    if (lowerTitle.contains('pretzel')) return 'pretzel';
    if (lowerTitle.contains('ciabatta')) return 'ciabatta';
    if (lowerTitle.contains('focaccia')) return 'focaccia';
    if (lowerTitle.contains('naan')) return 'naan';

    return 'general';
  }

  /// 제목 기반 재료 추정 (인식률 향상을 위해)
  static Map<String, List<String>> getExpectedIngredientsFromTitle(
      String title) {
    final breadType = estimateBreadTypeFromTitle(title);

    switch (breadType) {
      case 'bread':
        return {
          'flour': ['강력분', '밀가루', 'bread flour', 'flour'],
          'liquid': ['물', '우유', 'water', 'milk'],
          'yeast': ['이스트', '드라이이스트', 'yeast', 'dry yeast'],
          'salt': ['소금', 'salt'],
          'sugar': ['설탕', 'sugar'],
        };
      case 'baguette':
        return {
          'flour': ['강력분', '밀가루', 'bread flour', 'flour'],
          'liquid': ['물', 'water'],
          'yeast': ['이스트', '드라이이스트', 'yeast', 'dry yeast'],
          'salt': ['소금', 'salt'],
        };
      case 'croissant':
        return {
          'flour': ['강력분', '밀가루', 'bread flour', 'flour'],
          'liquid': ['우유', '물', 'milk', 'water'],
          'yeast': ['이스트', '드라이이스트', 'yeast', 'dry yeast'],
          'fat': ['버터', 'butter'],
          'salt': ['소금', 'salt'],
          'sugar': ['설탕', 'sugar'],
        };
      case 'pizza':
        return {
          'flour': ['강력분', '밀가루', 'bread flour', 'flour'],
          'liquid': ['물', 'water'],
          'yeast': ['이스트', '드라이이스트', 'yeast', 'dry yeast'],
          'salt': ['소금', 'salt'],
          'fat': ['올리브오일', 'olive oil', '기름', 'oil'],
        };
      case 'cookie':
        return {
          'flour': ['박력분', '밀가루', 'cake flour', 'flour'],
          'fat': ['버터', '마가린', 'butter', 'margarine'],
          'sugar': ['설탕', '흑설탕', 'sugar', 'brown sugar'],
          'eggs': ['계란', '달걀', 'egg', 'eggs'],
        };
      case 'cake':
        return {
          'flour': ['박력분', '밀가루', 'cake flour', 'flour'],
          'sugar': ['설탕', 'sugar'],
          'eggs': ['계란', '달걀', 'egg', 'eggs'],
          'fat': ['버터', '기름', 'butter', 'oil'],
          'liquid': ['우유', '물', 'milk', 'water'],
          'leavening': ['베이킹파우더', 'baking powder'],
        };
      default:
        return {
          'flour': ['밀가루', 'flour'],
          'liquid': ['물', '우유', 'water', 'milk'],
        };
    }
  }

  /// 레시피에서 밀가루 재료들을 찾아 반환 (제목 기반 개선)
  static List<Map<String, dynamic>> findFlourIngredients(
    List<Map<String, dynamic>> ingredients, {
    String? recipeTitle,
  }) {
    final foundIngredients = ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final isFlourDetected = isFlour(name);

      // ✅ [밀가루 감지 심층 로깅] - 모든 재료마다 검증 과정을 기록
      if (!isFlourDetected) {
        debugPrint('🔍 [findFlourIngredients 검증] "$name" → 밀가루 아님');
        debugPrint('   - 정규화된 이름: "${_normalizeIngredientName(name)}"');
        debugPrint('   - isFlour() 결과: false');
      } else {
        debugPrint('✅ [findFlourIngredients 성공] "$name" → 밀가루 감지됨');
      }

      return isFlourDetected;
    }).toList();

    debugPrint(
        '📊 [findFlourIngredients 최종] 검색된 밀가루 개수: ${foundIngredients.length}');

    // 제목 기반 추가 검색
    if (foundIngredients.isEmpty && recipeTitle != null) {
      final expectedIngredients = getExpectedIngredientsFromTitle(recipeTitle);
      final flourKeywords = expectedIngredients['flour'] ?? [];

      debugPrint('🔄 [제목 기반 검색] 밀가루 발견 실패 → 제목 기반 보조 검색 시작');
      debugPrint('🎯 [예상 키워드] $flourKeywords');

      for (final ingredient in ingredients) {
        final name = (ingredient['name'] as String? ?? '').toLowerCase();
        final matchedKeyword = flourKeywords.firstWhere(
          (keyword) => name.contains(keyword.toLowerCase()),
          orElse: () => '',
        );

        if (matchedKeyword.isNotEmpty) {
          debugPrint('🎯 [제목 기반 발견] "$name" → "$matchedKeyword" 키워드로 추가');
          foundIngredients.add(ingredient);
        }
      }

      debugPrint('📊 [제목 기반 최종] 추가 발견 개수: ${foundIngredients.length}');
    }

    return foundIngredients;
  }

  /// 레시피에서 액체 재료들을 찾아 반환 (제목 기반 개선)
  static List<Map<String, dynamic>> findLiquidIngredients(
    List<Map<String, dynamic>> ingredients, {
    String? recipeTitle,
  }) {
    print('🔍 [수분 재료 감지] 총 ${ingredients.length}개 재료 분석 시작');

    final foundIngredients = ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final isLiquid = _isLiquid(name);
      if (isLiquid) {
        print('✅ [수분 재료 감지] 액체 재료 발견: "$name"');
      }
      return isLiquid;
    }).toList();

    print('🔍 [수분 재료 감지] 기본 감지 결과: ${foundIngredients.length}개 액체 재료');

    // 제목 기반 추가 검색
    if (foundIngredients.isEmpty && recipeTitle != null) {
      print('🔍 [수분 재료 감지] 제목 기반 추가 검색 시작: "$recipeTitle"');
      final expectedIngredients = getExpectedIngredientsFromTitle(recipeTitle);
      final liquidKeywords = expectedIngredients['liquid'] ?? [];
      print('🔍 [수분 재료 감지] 예상 액체 키워드: $liquidKeywords');

      for (final ingredient in ingredients) {
        final name = (ingredient['name'] as String? ?? '').toLowerCase();
        final matchedKeyword = liquidKeywords.firstWhere(
          (keyword) => name.contains(keyword.toLowerCase()),
          orElse: () => '',
        );

        if (matchedKeyword.isNotEmpty) {
          print(
              '✅ [수분 재료 감지] 제목 기반 액체 재료 발견: "$name" (키워드: "$matchedKeyword")');
          foundIngredients.add(ingredient);
        }
      }
    }

    print('🔍 [수분 재료 감지] 최종 결과: ${foundIngredients.length}개 액체 재료');
    if (foundIngredients.isEmpty) {
      print('⚠️ [수분 재료 감지] 액체 재료가 하나도 감지되지 않음!');
      print('⚠️ [수분 재료 감지] 재료 목록:');
      for (final ingredient in ingredients) {
        final name = ingredient['name'] as String? ?? '';
        final amount = ingredient['amount'] as double? ?? 0.0;
        final unit = ingredient['unit'] as String? ?? '';
        print('   - $name: ${amount.toStringAsFixed(1)}$unit');
      }
    }

    return foundIngredients;
  }

  /// 수분 재료 존재 여부 검증 (NaN 방지용)
  static bool hasMoistureIngredients(
    List<Map<String, dynamic>> ingredients, {
    String? recipeTitle,
  }) {
    final liquidIngredients =
        findLiquidIngredients(ingredients, recipeTitle: recipeTitle);
    return liquidIngredients.isNotEmpty;
  }

  /// 레시피에서 이스트 재료들을 찾아 반환 (제목 기반 개선)
  static List<Map<String, dynamic>> findYeastIngredients(
    List<Map<String, dynamic>> ingredients, {
    String? recipeTitle,
  }) {
    print('🧪 [이스트 탐지 시작] 총 ${ingredients.length}개 재료 중 발효 관련 재료 탐색');
    print('📋 [이스트 탐지] 레시피 제목: "${recipeTitle ?? '제목 없음'}"');

    // 각 재료별 탐색 로그
    for (final ingredient in ingredients) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final amount = ingredient['amount'] as double? ?? 0.0;
      print('🔍 [이스트 탐색] "$name" (${amount}g) → 감지 시작...');
    }

    final foundIngredients = ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final isDetected = _isYeast(name);
      if (isDetected) {
        print('✅ [이스트 발견] "$name" → 발효 재료로 판별됨');
      }
      return isDetected;
    }).toList();

    print('📊 [기본 탐지 완료] ${foundIngredients.length}개 이스트 재료 감지됨');
    for (final yeast in foundIngredients) {
      print('   • "${yeast['name']}" (${yeast['amount'] as double? ?? 0.0}g)');
    }

    // 제목 기반 추가 검색
    if (foundIngredients.isEmpty && recipeTitle != null) {
      print('🔄 [추가 탐색] 기본 탐지에 실패하여 제목 기반 추가 검색 진행');
      final expectedIngredients = getExpectedIngredientsFromTitle(recipeTitle);
      final yeastKeywords = expectedIngredients['yeast'] ?? [];
      print('🎯 [제목 기반 키워드] ${yeastKeywords.length}개 키워드 검색: $yeastKeywords');

      for (final ingredient in ingredients) {
        final name = (ingredient['name'] as String? ?? '').toLowerCase();
        final matchedKeyword = yeastKeywords.firstWhere(
          (keyword) => name.contains(keyword.toLowerCase()),
          orElse: () => '',
        );

        if (matchedKeyword.isNotEmpty) {
          print('🎯 [제목 기반 감지] "$name" → "$matchedKeyword" 키워드로 추가');
          foundIngredients.add(ingredient);
        }
      }

      if (foundIngredients.length > foundIngredients.length) {
        print(
            '✅ [추가 탐지 성공] ${foundIngredients.length - foundIngredients.length}개 추가 발효 재료 감지');
      } else {
        print('❌ [추가 탐지 실패] 제목 기반 탐색에서도 발효 재료를 찾지 못함');
      }
    }

    final finalCount = foundIngredients.length;
    print('🎯 [이스트 탐지 완료] 최종 결과: $finalCount개 발효 관련 재료 감지');
    if (finalCount == 0) {
      print('⚠️ [주의] 발효 관련 재료가 하나도 감지되지 않았음');
      print('   💡 팽창율 계산은 0%로 진행될 예정입니다');
    }

    return foundIngredients;
  }

  /// 레시피에서 자연 발효종 재료들을 찾아 반환 (제목 기반 개선)
  static List<Map<String, dynamic>> findNaturalStarterIngredients(
    List<Map<String, dynamic>> ingredients, {
    String? recipeTitle,
  }) {
    print('🌱 [자연 발효종 탐지 시작] 총 ${ingredients.length}개 재료 중 자연 발효종 탐색');
    print('📋 [자연 발효종 탐지] 레시피 제목: "${recipeTitle ?? '제목 없음'}"');

    // 각 재료별 탐색 로그
    for (final ingredient in ingredients) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final amount = ingredient['amount'] as double? ?? 0.0;
      print('🔍 [자연 발효종 탐색] "$name" (${amount}g) → 감지 시작...');
    }

    final foundIngredients = ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final isDetected = _isNaturalStarter(name);
      if (isDetected) {
        print('✅ [자연 발효종 발견] "$name" → 자연 발효종으로 판별됨');
      }
      return isDetected;
    }).toList();

    print('📊 [기본 탐지 완료] ${foundIngredients.length}개 자연 발효종 재료 감지됨');
    for (final starter in foundIngredients) {
      print(
          '   • "${starter['name']}" (${starter['amount'] as double? ?? 0.0}g)');
    }

    // 제목 기반 추가 검색 (사워도우, 자연 발효 관련 레시피)
    if (foundIngredients.isEmpty && recipeTitle != null) {
      final lowerTitle = recipeTitle.toLowerCase();
      if (lowerTitle.contains('사워도우') ||
          lowerTitle.contains('자연발효') ||
          lowerTitle.contains('르뱅') ||
          lowerTitle.contains('sourdough') ||
          lowerTitle.contains('natural')) {
        print('🔄 [추가 탐색] 자연 발효 관련 레시피로 판단하여 추가 검색 진행');

        // 밀가루와 물의 조합을 자연 발효종으로 간주
        final flourIngredients = findFlourIngredients(ingredients);
        final liquidIngredients = findLiquidIngredients(ingredients);

        if (flourIngredients.isNotEmpty && liquidIngredients.isNotEmpty) {
          // 밀가루와 물의 비율이 1:1 근처라면 자연 발효종으로 추정
          final totalFlour = flourIngredients.fold<double>(0.0, (sum, flour) {
            final amount = flour['amount'] as double? ?? 0.0;
            final unit = flour['unit'] as String? ?? 'g';
            return sum +
                convertToGrams(amount, unit, flour['name'] as String? ?? '');
          });

          final totalLiquid =
              liquidIngredients.fold<double>(0.0, (sum, liquid) {
            final amount = liquid['amount'] as double? ?? 0.0;
            final unit = liquid['unit'] as String? ?? 'g';
            return sum +
                convertToGrams(amount, unit, liquid['name'] as String? ?? '');
          });

          if (totalFlour > 0 && totalLiquid > 0) {
            final ratio = totalLiquid / totalFlour;
            if (ratio >= 0.8 && ratio <= 1.5) {
              // 1:1 비율 근처
              print(
                  '🎯 [제목 기반 자연 발효종 감지] 밀가루:물 비율 ${ratio.toStringAsFixed(2)}로 자연 발효종 추정');
              // 가상의 자연 발효종 재료 생성
              foundIngredients.add({
                'name': '자연 발효종 (추정)',
                'amount': totalFlour + totalLiquid,
                'unit': 'g',
              });
            }
          }
        }
      }
    }

    final finalCount = foundIngredients.length;
    print('🎯 [자연 발효종 탐지 완료] 최종 결과: $finalCount개 자연 발효종 재료 감지');
    if (finalCount == 0) {
      print('⚠️ [주의] 자연 발효종 재료가 감지되지 않았음');
      print('   💡 상업용 이스트 기반 계산으로 진행됩니다');
    }

    return foundIngredients;
  }

  /// 레시피에서 소금 재료들을 찾아 반환 (제목 기반 개선)
  static List<Map<String, dynamic>> findSaltIngredients(
    List<Map<String, dynamic>> ingredients, {
    String? recipeTitle,
  }) {
    final foundIngredients = ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      return _isSalt(name);
    }).toList();

    // 제목 기반 추가 검색
    if (foundIngredients.isEmpty && recipeTitle != null) {
      final expectedIngredients = getExpectedIngredientsFromTitle(recipeTitle);
      final saltKeywords = expectedIngredients['salt'] ?? [];

      for (final ingredient in ingredients) {
        final name = (ingredient['name'] as String? ?? '').toLowerCase();
        if (saltKeywords
            .any((keyword) => name.contains(keyword.toLowerCase()))) {
          foundIngredients.add(ingredient);
        }
      }
    }

    return foundIngredients;
  }

  /// 수분율(Hydration) 계산 (제목 기반 개선)
  /// 공식: (액체 재료 총량 / 밀가루 총량) × 100
  static double calculateHydration(
    List<Map<String, dynamic>> ingredients, {
    String? recipeTitle,
  }) {
    final flourIngredients =
        findFlourIngredients(ingredients, recipeTitle: recipeTitle);
    final liquidIngredients =
        findLiquidIngredients(ingredients, recipeTitle: recipeTitle);

    if (flourIngredients.isEmpty) return 0.0;

    // 밀가루 총량 계산
    double totalFlour = 0.0;
    for (final flour in flourIngredients) {
      final amount = flour['amount'] as double? ?? 0.0;
      final unit = flour['unit'] as String? ?? 'g';
      totalFlour +=
          convertToGrams(amount, unit, flour['name'] as String? ?? '');
    }

    // 액체 총량 계산
    double totalLiquid = 0.0;
    for (final liquid in liquidIngredients) {
      final amount = liquid['amount'] as double? ?? 0.0;
      final unit = liquid['unit'] as String? ?? 'g';
      totalLiquid +=
          convertToGrams(amount, unit, liquid['name'] as String? ?? '');
    }

    if (totalFlour == 0) return 0.0;
    return (totalLiquid / totalFlour) * 100;
  }

  /// 개선된 수분율 계산 (재료별 수분 함량 기반)
  /// 실제 빵 제조 방식: (총 수분량 / 고체 재료량) × 100
  /// ✅ 컨셉 준수: 데이터 기반 계산만 수행, 기본값 없음
  static double calculateRealisticHydration(
    List<Map<String, dynamic>> ingredients, {
    String? recipeTitle,
  }) {
    try {
      // 1. 재료 데이터 검증 (강화된 검증)
      if (ingredients.isEmpty) {
        print('⚠️ 수분 계산: 재료 데이터가 비어있음 - 계산 불가 (0% 반환)');
        return 0.0; // 계산 불가 시 0% 반환 (허위 값 방지)
      }

      // 2. 유효한 재료 필터링 (NaN 방지)
      final validIngredients = _filterValidIngredients(ingredients);
      if (validIngredients.isEmpty) {
        print('⚠️ 수분 계산: 유효한 재료가 없음 - 안전한 기본값 반환');
        return _getSafeDefaultHydration(); // 안전한 기본값 반환
      }

      // 3. 재료를 수분 함량에 따라 분류
      final classifiedIngredients =
          classifyIngredientsByMoistureContent(validIngredients);

      // 4. 고체 재료 총량 계산 (밀가루 포함)
      final solidWeight = _calculateSolidIngredientsWeight(
          classifiedIngredients['solid'] ?? []);

      // 5. 액체 재료 총량 계산 (100% 수분)
      final liquidWeight = _calculateLiquidIngredientsWeight(
          classifiedIngredients['liquid'] ?? []);

      // 6. 수분이 많은 재료의 수분량 계산
      final moistIngredientsMoisture = _calculateMoistIngredientsMoisture(
          classifiedIngredients['moist'] ?? []);

      // 7. 데이터 유효성 검증
      if (solidWeight <= 0) {
        print('⚠️ 수분 계산: 고체 재료가 없거나 무게가 0임');
        return 0.0; // 계산 불가 시 0 반환 (NaN 방지)
      }

      if (liquidWeight <= 0 && moistIngredientsMoisture <= 0) {
        print('⚠️ 수분 계산: 수분을 포함한 재료가 없음');
        return 0.0; // 계산 불가 시 0 반환 (NaN 방지)
      }

      // 8. 총 수분량 계산
      final totalMoisture = liquidWeight + moistIngredientsMoisture;

      // 9. 수분 흡수율 계산 (실제 빵 제조 공식)
      final hydration = (totalMoisture / solidWeight) * 100;

      // 10. 계산 결과 검증 및 물리적 한계 적용
      if (hydration.isNaN || hydration.isInfinite) {
        print('⚠️ 수분 계산: 계산 결과가 유효하지 않음');
        return 0.0; // 계산 불가 시 0 반환 (NaN 방지)
      }

      // ✅ 물리적 한계 적용: 수분 흡수율은 100%를 초과할 수 없음
      final clampedHydration = hydration.clamp(0.0, 100.0);

      // 11. 밀가루 종류별 특성 기반 보정 (새로운 기능)
      final flourBasedAdjustment = calculateFlourBasedHydration(
        validIngredients,
        recipeTitle: recipeTitle,
      );

      // 밀가루 특성 기반 조정 적용 (선택적)
      final flourAdjustedHydration = flourBasedAdjustment > 0
          ? clampedHydration *
              (1 + (flourBasedAdjustment - clampedHydration) * 0.1)
          : clampedHydration;

      // 12. 빵 타입별 조정 (선택적, 실제 데이터 기반)
      final breadType = estimateBreadTypeFromTitle(recipeTitle ?? '');
      final adjustedHydration =
          _adjustHydrationByBreadType(flourAdjustedHydration, breadType);

      // ✅ 물리적 한계 재적용: 최종 결과도 100% 제한
      final finalHydration = adjustedHydration.clamp(0.0, 100.0);

      print('✅ 수분 계산 완료: ${finalHydration.toStringAsFixed(1)}% (물리적 한계 적용)');
      print('   - 기본 수분: ${(hydration).toStringAsFixed(1)}%');
      print('   - 물리적 제한: ${(clampedHydration).toStringAsFixed(1)}%');
      print('   - 밀가루 조정: ${(flourBasedAdjustment).toStringAsFixed(1)}%');
      // 불필요한 빵 타입 조정 값 출력 제거 (사용자 요청)
      print('   - 최종 결과: ${finalHydration.toStringAsFixed(1)}%');

      return finalHydration;
    } catch (e) {
      print('❌ 현실적 수분 계산 중 오류: $e');
      return 0.0; // 오류 시 0 반환 (NaN 방지)
    }
  }

  /// 이스트 비율 계산 (밀가루 대비 %) (제목 기반 개선)
  static double calculateYeastPercentage(
    List<Map<String, dynamic>> ingredients, {
    String? recipeTitle,
  }) {
    final flourIngredients =
        findFlourIngredients(ingredients, recipeTitle: recipeTitle);
    final yeastIngredients =
        findYeastIngredients(ingredients, recipeTitle: recipeTitle);

    if (flourIngredients.isEmpty || yeastIngredients.isEmpty) return 0.0;

    // 밀가루 총량
    double totalFlour = 0.0;
    for (final flour in flourIngredients) {
      final amount = flour['amount'] as double? ?? 0.0;
      final unit = flour['unit'] as String? ?? 'g';
      totalFlour +=
          convertToGrams(amount, unit, flour['name'] as String? ?? '');
    }

    // 이스트 총량
    double totalYeast = 0.0;
    for (final yeast in yeastIngredients) {
      final amount = yeast['amount'] as double? ?? 0.0;
      final unit = yeast['unit'] as String? ?? 'g';
      totalYeast +=
          convertToGrams(amount, unit, yeast['name'] as String? ?? '');
    }

    if (totalFlour == 0) return 0.0;
    return (totalYeast / totalFlour) * 100;
  }

  /// 소금 비율 계산 (밀가루 대비 %) (제목 기반 개선)
  static double calculateSaltPercentage(
    List<Map<String, dynamic>> ingredients, {
    String? recipeTitle,
  }) {
    final flourIngredients =
        findFlourIngredients(ingredients, recipeTitle: recipeTitle);
    final saltIngredients =
        findSaltIngredients(ingredients, recipeTitle: recipeTitle);

    if (flourIngredients.isEmpty || saltIngredients.isEmpty) return 0.0;

    // 밀가루 총량
    double totalFlour = 0.0;
    for (final flour in flourIngredients) {
      final amount = flour['amount'] as double? ?? 0.0;
      final unit = flour['unit'] as String? ?? 'g';
      totalFlour +=
          convertToGrams(amount, unit, flour['name'] as String? ?? '');
    }

    // 소금 총량
    double totalSalt = 0.0;
    for (final salt in saltIngredients) {
      final amount = salt['amount'] as double? ?? 0.0;
      final unit = salt['unit'] as String? ?? 'g';
      totalSalt += convertToGrams(amount, unit, salt['name'] as String? ?? '');
    }

    if (totalFlour == 0) return 0.0;
    return (totalSalt / totalFlour) * 100;
  }

  /// 이스트 품질 평가 (빵 제조 과학적 계산)
  /// 다양한 이스트 타입에 따라 품질 계수 반환
  static double estimateYeastQuality(List<Map<String, dynamic>> ingredients) {
    print('🧪 [이스트 품질 분석] 함수 시작 - 재료 분석 시작: ${ingredients.length}개 재료');
    print('🧪 [이스트 품질 분석] 입력 재료 목록 확인:');
    for (int i = 0; i < ingredients.length && i < 10; i++) {
      // 최대 10개만 출력
      final ing = ingredients[i];
      final name = ing['name'] as String?;
      final amount = ing['amount'];
      print('   - 재료 ${i + 1}: "$name" (양: $amount)');
    }

    final yeastIngredients = findYeastIngredients(ingredients);
    print(
        '🧪 [이스트 품질 분석] findYeastIngredients 결과: ${yeastIngredients.length}개 발견');
    if (yeastIngredients.isNotEmpty) {
      print(
          '🧪 [이스트 품질 분석] 발견된 이스트 재료: ${yeastIngredients.map((y) => y['name'] as String? ?? '이름없음').join(', ')}');
    } else {
      print('🧪 [이스트 품질 분석] 이스트 재료 발견 실패 - 품질 0.0 반환');
      // 더 자세한 디버깅 정보 추가
      print('🧪 [이스트 품질 분석] 각 재료별 이스트 판별 결과:');
      for (int i = 0; i < ingredients.length && i < 10; i++) {
        final ing = ingredients[i];
        final name = ing['name'] as String?;
        final amount = ing['amount'];
        final isYeast = name != null ? _isYeast(name) : false;
        print('   - 재료 ${i + 1}: "$name" (이스트=${isYeast}, 양=${amount})');
      }
      return 0.0;
    }

    if (yeastIngredients.isEmpty) {
      return 0.0; // 이스트 없음
    }

    // 각 이스트 재료의 품질 계수 계산
    double totalQualityScore = 0.0;
    double totalWeight = 0.0;

    for (final yeast in yeastIngredients) {
      final name = (yeast['name'] as String?)?.toLowerCase() ?? '';
      final amount = yeast['amount'] as double? ?? 0.0;
      final unit = yeast['unit'] as String? ?? 'g';

      final weight = convertToGrams(amount, unit, name);

      // 이스트 타입별 품질 계수
      double qualityFactor = 0.3; // 기본값

      if (name.contains('생종') || name.contains('starter')) {
        qualityFactor = 1.0; // 생종: 최고 품질 (자가 증식 이스트)
      } else if (name.contains('신선한') || name.contains('fresh yeast')) {
        qualityFactor = 0.9; // 신선한 생 이스트
      } else if (name.contains('인스턴트') || name.contains('instant')) {
        qualityFactor = 0.8; // 인스턴트 이스트
      } else if (name.contains('드라이') || name.contains('dry')) {
        qualityFactor = 0.7; // 드라이 이스트 (재수화 필요)
      } else if (name.contains('액티브 드라이') || name.contains('active dry')) {
        qualityFactor = 0.8; // 액티브 드라이 이스트
      } else if (name.contains('사워도우') || name.contains('sourdough')) {
        qualityFactor = 0.95; // 사워도우 스타터
      } else if (name.contains('풀드') || name.contains('pooled')) {
        qualityFactor = 0.6; // 풀드 이스트 (오래됨)
      }

      totalQualityScore += qualityFactor * weight;
      totalWeight += weight;
    }

    // 가중 평균 품질 계산
    return totalWeight > 0
        ? (totalQualityScore / totalWeight).clamp(0.0, 1.0)
        : 0.3;
  }

  /// 베이커스 퍼센트 계산 (제목 기반 개선)
  /// 밀가루를 100%로 기준으로 다른 재료들의 비율 계산
  static Map<String, double> calculateBakersPercentage(
    List<Map<String, dynamic>> ingredients, {
    String? recipeTitle,
  }) {
    final flourIngredients =
        findFlourIngredients(ingredients, recipeTitle: recipeTitle);
    if (flourIngredients.isEmpty) return {};

    // 밀가루 총량 계산
    double totalFlour = 0.0;
    for (final flour in flourIngredients) {
      final amount = flour['amount'] as double? ?? 0.0;
      final unit = flour['unit'] as String? ?? 'g';
      totalFlour +=
          convertToGrams(amount, unit, flour['name'] as String? ?? '');
    }

    if (totalFlour == 0) return {};

    // 각 재료별 베이커스 퍼센트 계산
    final bakersPercentage = <String, double>{};

    for (final ingredient in ingredients) {
      final name = ingredient['name'] as String? ?? '';
      final amount = ingredient['amount'] as double? ?? 0.0;
      final unit = ingredient['unit'] as String? ?? 'g';

      final gramsAmount = convertToGrams(amount, unit, name);
      final percentage = (gramsAmount / totalFlour) * 100;

      bakersPercentage[name] = percentage;
    }

    return bakersPercentage;
  }

  /// 반죽 최대양 계산 (수정된 정확한 계산식)
  /// 오븐 용량과 빵 종류에 따른 최적 반죽량 계산
  static Map<String, dynamic> calculateMaximumDoughAmount(
    List<Map<String, dynamic>> ingredients, {
    double ovenCapacityLiters = 30.0, // 기본 오븐 용량 (리터)
    String breadType = 'general', // 빵 종류
    String? recipeTitle,
  }) {
    try {
      final flourIngredients =
          findFlourIngredients(ingredients, recipeTitle: recipeTitle);
      if (flourIngredients.isEmpty) {
        return {
          'maxFlourAmount': 0.0,
          'maxDoughWeight': 0.0,
          'scalingFactor': 0.0,
          'recommendation': '밀가루 재료를 찾을 수 없습니다.',
        };
      }

      // 현재 밀가루 총량
      double currentFlourAmount = 0.0;
      for (final flour in flourIngredients) {
        final amount = flour['amount'] as double? ?? 0.0;
        final unit = flour['unit'] as String? ?? 'g';
        currentFlourAmount +=
            convertToGrams(amount, unit, flour['name'] as String? ?? '');
      }

      // 현재 총 반죽 무게 계산
      double currentTotalWeight = 0.0;
      for (final ingredient in ingredients) {
        final amount = ingredient['amount'] as double? ?? 0.0;
        final unit = ingredient['unit'] as String? ?? 'g';
        final name = ingredient['name'] as String? ?? '';
        currentTotalWeight += convertToGrams(amount, unit, name);
      }

      // 빵 종류별 오븐 점유율 (실제 베이킹 경험 기반)
      final ovenOccupancyRatio = _getBreadTypeOccupancyRatio(breadType);

      // 오븐 용량 기반 최대 반죽 무게 계산 (더 현실적인 공식)
      // 30L 오븐 기준: 식빵 1개(약 800g 반죽), 바게트 2개(약 600g 반죽)
      final baseCapacityGrams = ovenCapacityLiters * 25; // 1L당 약 25g 반죽 기준
      final maxDoughWeight = baseCapacityGrams * ovenOccupancyRatio;

      // 현재 반죽 대비 최대 밀가루량 역산
      final flourRatio = currentFlourAmount / currentTotalWeight;
      final maxFlourAmount = maxDoughWeight * flourRatio;

      // 현재 레시피 대비 스케일링 팩터
      final scalingFactor =
          currentTotalWeight > 0 ? maxDoughWeight / currentTotalWeight : 0.0;

      // 권장사항 생성 (더 현실적인 기준)
      String recommendation;
      if (scalingFactor > 3.0) {
        recommendation =
            '현재 레시피를 3배까지 확대 가능합니다 (${maxDoughWeight.toStringAsFixed(0)}g 반죽).';
      } else if (scalingFactor > 1.5) {
        recommendation =
            '현재 레시피를 ${scalingFactor.toStringAsFixed(1)}배 확대 가능합니다 (${maxDoughWeight.toStringAsFixed(0)}g 반죽).';
      } else if (scalingFactor >= 0.9) {
        recommendation =
            '현재 레시피가 오븐 용량에 적합합니다 (${currentTotalWeight.toStringAsFixed(0)}g 반죽).';
      } else {
        final reductionFactor = 1 / scalingFactor;
        recommendation =
            '현재 레시피가 오븐 용량을 초과합니다. ${reductionFactor.toStringAsFixed(1)}배 축소 권장 (${maxDoughWeight.toStringAsFixed(0)}g로).';
      }

      return {
        'maxFlourAmount': maxFlourAmount,
        'maxDoughWeight': maxDoughWeight,
        'scalingFactor': scalingFactor,
        'currentFlourAmount': currentFlourAmount,
        'currentTotalWeight': currentTotalWeight,
        'ovenCapacity': ovenCapacityLiters,
        'breadType': breadType,
        'recommendation': recommendation,
      };
    } catch (e) {
      return {
        'maxFlourAmount': 0.0,
        'maxDoughWeight': 0.0,
        'scalingFactor': 0.0,
        'recommendation': '계산 중 오류가 발생했습니다: $e',
      };
    }
  }

  /// 빵 종류별 오븐 점유율 반환 (실제 베이킹 경험 기반)
  static double _getBreadTypeOccupancyRatio(String breadType) {
    switch (breadType.toLowerCase()) {
      case 'bread':
      case 'loaf':
      case '식빵':
        return 1.0; // 기준 (30L 오븐에 식빵 1개)
      case 'baguette':
      case '바게트':
        return 0.8; // 바게트는 길지만 얇아서 조금 더 들어감
      case 'pizza':
      case '피자':
        return 1.5; // 피자는 얇게 펼쳐서 더 많이 들어감
      case 'croissant':
      case '크루아상':
        return 0.6; // 크루아상은 개별 단위가 작음
      case 'brioche':
      case '브리오슈':
        return 0.9; // 브리오슈는 밀도가 높음
      case 'sourdough':
      case '사워도우':
        return 1.1; // 사워도우는 부피가 큼
      case 'cookie':
      case '쿠키':
        return 2.0; // 쿠키는 평평해서 많이 들어감
      case 'cake':
      case '케이크':
        return 0.7; // 케이크는 높이가 있어서 적게 들어감
      case 'muffin':
      case '머핀':
        return 1.2; // 머핀은 개별 단위로 여러 개
      case 'bagel':
      case '베이글':
        return 1.3; // 베이글은 도넛 모양으로 공간 활용 좋음
      case 'scone':
      case '스콘':
        return 1.4; // 스콘은 작은 단위
      default:
        return 1.0; // 일반적인 빵류 기본값
    }
  }

  /// 재료 타입 분석
  static Map<String, List<Map<String, dynamic>>> analyzeIngredientTypes(
      List<Map<String, dynamic>> ingredients) {
    return {
      'flour': findFlourIngredients(ingredients),
      'liquid': findLiquidIngredients(ingredients),
      'yeast': findYeastIngredients(ingredients),
      'salt': findSaltIngredients(ingredients),
      'sugar': _findSugarIngredients(ingredients),
      'fat': _findFatIngredients(ingredients),
      'eggs': _findEggIngredients(ingredients),
      'leavening': _findLeaveningIngredients(ingredients),
      'other': _findOtherIngredients(ingredients),
    };
  }

  // === 재료 감지 로직 ===

  /// 밀가루 재료 판별 - BreadConstants 중앙 키워드 활용
  /// ✅ 빅데이터/빵타입별 금지, 범위제한 금지, 기본값 사용 금지 정책 준수
  static bool isFlour(String name) {
    // ✅ BreadConstants 중앙 키워드 연동 (로깅 최소화로 정책 준수)
    bool result = BreadConstants.hasFlour(name);

    if (!result) {
      debugPrint('❌ [밀가루 감지 실패] "$name" → BreadConstants 키워드 매칭 실패');
      debugPrint(
          '   - 중앙 키워드: ${BreadConstants.flourKeywords.take(10).join(", ")}...');
    }

    return result; // 매칭 안되면 false (기본값/보정 금지 - 문제 드러냄)
  }

  /// 재료 이름 정규화 (특수문자 제거, 공백 정리)
  static String _normalizeIngredientName(String name) {
    return name
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^\w\s가-힣]'), '') // 특수문자 제거 (한글과 영문, 숫자, 공백만 유지)
        .replaceAll(RegExp(r'\s+'), ' ') // 다중 공백을 단일 공백으로
        .trim();
  }

  /// 액체 재료 판별 - 과학적 수분 함량 기반 개선
  static bool _isLiquid(String name) {
    final lowerName = name.toLowerCase();

    // 1. 명확한 액체 재료 (100% 수분)
    final pureLiquidKeywords = [
      '물',
      'water',
      '얼음',
      'ice',
      '증류수',
      'distilled water',
      '정제수',
      'purified water',
    ];

    // 2. 고수분 함량 액체 재료 (80-95% 수분)
    final highMoistureLiquidKeywords = [
      '우유',
      'milk',
      '생크림',
      'heavy cream',
      '휘핑크림',
      'whipped cream',
      '버터밀크',
      'buttermilk',
      '요구르트',
      'yogurt',
      '두유',
      'soy milk',
      '코코넛밀크',
      'coconut milk',
      '아몬드밀크',
      'almond milk',
      '오트밀크',
      'oat milk',
      '라이스밀크',
      'rice milk',
      '사워크림',
      'sour cream',
      '크림치즈',
      'cream cheese',
      '연유',
      'condensed milk',
      '탈지유',
      'skim milk',
      '전지유',
      'whole milk',
      '저지방우유',
      'low-fat milk',
    ];

    // 3. 중수분 함량 액체 재료 (50-80% 수분)
    final mediumMoistureLiquidKeywords = [
      '주스',
      'juice',
      '레몬주스',
      'lemon juice',
      '오렌지주스',
      'orange juice',
      '사과주스',
      'apple juice',
      '포도주스',
      'grape juice',
      '식초',
      'vinegar',
      '와인',
      'wine',
      '맥주',
      'beer',
      '육수',
      'broth',
      '스톡',
      'stock',
      '국물',
      'soup stock',
    ];

    // 4. 저수분 함량 액체 재료 (20-50% 수분) - 기름류
    final lowMoistureLiquidKeywords = [
      '기름',
      'oil',
      '올리브오일',
      'olive oil',
      '식용유',
      'vegetable oil',
      '코코넛오일',
      'coconut oil',
      '아보카도오일',
      'avocado oil',
      '참기름',
      'sesame oil',
      '들기름',
      'perilla oil',
      '포도씨오일',
      'grapeseed oil',
      '해바라기유',
      'sunflower oil',
      '카놀라유',
      'canola oil',
      '버터',
      'butter',
      '마가린',
      'margarine',
    ];

    // 5. 고점성 액체 재료 (꿀, 시럽 등)
    final viscousLiquidKeywords = [
      '꿀',
      'honey',
      '시럽',
      'syrup',
      '메이플시럽',
      'maple syrup',
      '물엿',
      'corn syrup',
      '아가베시럽',
      'agave syrup',
      '현미시럽',
      'brown rice syrup',
      '쌀시럽',
      'rice syrup',
      '당밀',
      'molasses',
      '황금시럽',
      'golden syrup',
    ];

    // 6. 기타 액체 형태
    final otherLiquidKeywords = [
      '액체',
      'liquid',
      '추출물',
      'extract',
      '바닐라추출물',
      'vanilla extract',
      '레몬추출물',
      'lemon extract',
      '알코올',
      'alcohol',
      '럼',
      'rum',
      '브랜디',
      'brandy',
      '와인',
      'wine',
      '맥주',
      'beer',
    ];

    // 모든 카테고리에서 검색
    final allLiquidKeywords = [
      ...pureLiquidKeywords,
      ...highMoistureLiquidKeywords,
      ...mediumMoistureLiquidKeywords,
      ...lowMoistureLiquidKeywords,
      ...viscousLiquidKeywords,
      ...otherLiquidKeywords,
    ];

    // 정확한 매칭을 위해 단어 경계 고려
    return allLiquidKeywords.any((keyword) {
      final keywordLower = keyword.toLowerCase();
      return lowerName.contains(keywordLower) ||
          lowerName == keywordLower ||
          lowerName.startsWith(keywordLower + ' ') ||
          lowerName.endsWith(' ' + keywordLower) ||
          lowerName.contains(' ' + keywordLower + ' ');
    });
  }

  /// 이스트 재료 판별 - 상업용 이스트만 감지 (자연 발효종 제외)
  static bool _isYeast(String name) {
    final lowerName = name.toLowerCase();
    final yeastKeywords = [
      // 한국어 - 상업용 이스트만
      '이스트', '드라이이스트', '인스턴트이스트', '액티브드라이이스트',
      '생이스트', '천연효모',
      // 한국어 - 확장 (상업용 이스트 강화)
      '효모', '빵효모', '제빵효모', '압축효모', '냉동효모',
      // 영어 - 상업용 이스트
      'yeast', 'dry yeast', 'instant yeast', 'active dry yeast',
      'fresh yeast', 'baker\'s yeast',
      // 영어 - 상업용 이스트 확장
      'compressed yeast', 'cake yeast', 'bread yeast',
      'bread machine yeast', 'nutritional yeast', 'commercial yeast',
      'rapid-rise yeast', 'pizza yeast',
    ];

    final isYeast = yeastKeywords.any((keyword) => lowerName.contains(keyword));
    print('🔍 [상업용 이스트 감지] 입력: "$name" (소문자: "$lowerName") → 결과: $isYeast');

    if (isYeast) {
      final matchedKeyword =
          yeastKeywords.firstWhere((keyword) => lowerName.contains(keyword));
      print('✅ [상업용 이스트 감지] 매칭 키워드: "$matchedKeyword"');
    }

    return isYeast;
  }

  /// 자연 발효종 재료 판별 - 생종, 르방 등 자연 발효 방법
  /// 개선: 더 유연한 매칭과 특수문자 처리
  static bool _isNaturalStarter(String name) {
    final lowerName = name.toLowerCase();

    // 특수문자 제거 및 공백 정리 (더 유연한 매칭을 위해)
    final normalizedName = lowerName
        .replaceAll(RegExp(r'[^\w\s가-힣]'), ' ') // 특수문자를 공백으로 변환
        .replaceAll(RegExp(r'\s+'), ' ') // 다중 공백을 단일 공백으로
        .trim();

    final naturalStarterKeywords = [
      // 한국어 - 자연 발효종 (더 포괄적인 키워드 추가)
      '생종', '탕종', '르방', '레뱅', '커머센트', '커머센트',
      '사워도우스타터', '천연발효종', '자연종', '산종',
      '발효종', '스타터', '자연효모', '발효싸리터',
      '무산소주종', '밀가루물종', '사워도우', '자연발효',
      '종균', '종', 'starter', 'culture',
      // 영어 - 자연 발효종
      'sourdough starter', 'levain', 'mother', 'starter culture',
      'fermentation starter', 'natural starter', 'wild yeast',
      'sourdough', 'natural yeast', 'ferment',
    ];

    // 원본 이름과 정규화된 이름 모두에서 검색
    final isNaturalStarter = naturalStarterKeywords.any((keyword) =>
        lowerName.contains(keyword) || normalizedName.contains(keyword));

    print('🔍 [자연 발효종 감지] 입력: "$name"');
    print('   - 소문자: "$lowerName"');
    print('   - 정규화: "$normalizedName"');
    print('   - 결과: $isNaturalStarter');

    if (isNaturalStarter) {
      final matchedKeyword = naturalStarterKeywords.firstWhere(
          (keyword) =>
              lowerName.contains(keyword) || normalizedName.contains(keyword),
          orElse: () => '알 수 없음');
      print('✅ [자연 발효종 감지] 매칭 키워드: "$matchedKeyword"');
    } else {
      print('❌ [자연 발효종 감지] 매칭되는 키워드 없음');
    }

    return isNaturalStarter;
  }

  /// 소금 재료 판별
  static bool _isSalt(String name) {
    final lowerName = name.toLowerCase();
    final saltKeywords = [
      // 한국어
      '소금', '천일염', '바다소금', '암염', '정제염',
      // 영어
      'salt', 'sea salt', 'kosher salt', 'table salt',
      'rock salt', 'himalayan salt'
    ];

    return saltKeywords.any((keyword) => lowerName.contains(keyword));
  }

  /// 설탕 재료 찾기
  static List<Map<String, dynamic>> _findSugarIngredients(
      List<Map<String, dynamic>> ingredients) {
    return ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final sugarKeywords = [
        '설탕',
        '백설탕',
        '흑설탕',
        '황설탕',
        '코코넛설탕',
        'sugar',
        'white sugar',
        'brown sugar',
        'coconut sugar',
        'cane sugar',
        'raw sugar',
        'turbinado'
      ];
      return sugarKeywords.any((keyword) => name.contains(keyword));
    }).toList();
  }

  /// 지방 재료 찾기
  static List<Map<String, dynamic>> _findFatIngredients(
      List<Map<String, dynamic>> ingredients) {
    return ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final fatKeywords = [
        '버터',
        '마가린',
        '쇼트닝',
        '라드',
        '코코넛오일',
        'butter',
        'margarine',
        'shortening',
        'lard',
        'coconut oil'
      ];
      return fatKeywords.any((keyword) => name.contains(keyword));
    }).toList();
  }

  /// 계란 재료 찾기
  static List<Map<String, dynamic>> _findEggIngredients(
      List<Map<String, dynamic>> ingredients) {
    return ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final eggKeywords = [
        '계란',
        '달걀',
        '계란흰자',
        '계란노른자',
        'egg',
        'eggs',
        'egg white',
        'egg yolk',
        'whole egg'
      ];
      return eggKeywords.any((keyword) => name.contains(keyword));
    }).toList();
  }

  /// 팽창제 재료 찾기
  static List<Map<String, dynamic>> _findLeaveningIngredients(
      List<Map<String, dynamic>> ingredients) {
    return ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final leaveningKeywords = [
        '베이킹파우더',
        '베이킹소다',
        '중조',
        '타르타르크림',
        'baking powder',
        'baking soda',
        'cream of tartar',
        'sodium bicarbonate'
      ];
      return leaveningKeywords.any((keyword) => name.contains(keyword));
    }).toList();
  }

  /// 기타 재료 찾기
  static List<Map<String, dynamic>> _findOtherIngredients(
      List<Map<String, dynamic>> ingredients) {
    return ingredients.where((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      return !isFlour(name) &&
          !_isLiquid(name) &&
          !_isYeast(name) &&
          !_isSalt(name);
    }).toList();
  }

  /// 단위를 그램으로 변환
  static double convertToGrams(
      double amount, String unit, String ingredientName) {
    final lowerUnit = unit.toLowerCase();

    // 이미 그램인 경우
    if (lowerUnit == 'g' || lowerUnit == 'gram' || lowerUnit == 'grams') {
      return amount;
    }

    // 킬로그램
    if (lowerUnit == 'kg' ||
        lowerUnit == 'kilogram' ||
        lowerUnit == 'kilograms') {
      return amount * 1000;
    }

    // 부피 단위는 재료별 밀도를 고려하여 변환
    final density = _getIngredientDensity(ingredientName);

    switch (lowerUnit) {
      case 'ml':
      case 'milliliter':
        return amount * density;
      case 'l':
      case 'liter':
        return amount * 1000 * density;
      case 'cup':
        return amount * 240 * density; // 1컵 = 240ml
      case 'tbsp':
      case 'tablespoon':
        return amount * 15 * density; // 1큰술 = 15ml
      case 'tsp':
      case 'teaspoon':
        return amount * 5 * density; // 1작은술 = 5ml
      default:
        return amount; // 알 수 없는 단위는 그대로 반환
    }
  }

  /// 재료별 밀도 반환 (g/ml) - 밀가루 종류별 특성 데이터베이스 활용 개선
  static double _getIngredientDensity(String ingredientName) {
    final lowerName = ingredientName.toLowerCase();

    // 밀가루류 - 밀가루 종류별 특성 데이터베이스 활용
    if (isFlour(lowerName)) {
      // 밀가루 종류 감지 및 밀도 활용
      final flourInfo = detectFlourType(ingredientName);
      final characteristics =
          flourInfo['characteristics'] as Map<String, dynamic>;
      final density = characteristics['density'] as double;

      print('🔍 [밀가루 밀도 계산] 밀가루 종류 감지: ${flourInfo['type']}');
      print('   - 감지된 키워드: ${flourInfo['detectedKeyword']}');
      print('   - 밀도: ${density.toStringAsFixed(3)} g/ml');

      return density;
    }

    // 액체류 (정밀한 밀도 적용)
    if (lowerName.contains('물') || lowerName.contains('water')) return 1.00;
    if (lowerName.contains('우유') || lowerName.contains('milk')) return 1.03;
    if (lowerName.contains('생크림') || lowerName.contains('heavy cream'))
      return 1.01;
    if (lowerName.contains('버터밀크') || lowerName.contains('buttermilk'))
      return 1.03;
    if (lowerName.contains('요구르트') || lowerName.contains('yogurt')) return 1.05;
    if (lowerName.contains('식용유') || lowerName.contains('vegetable oil'))
      return 0.92;
    if (lowerName.contains('올리브오일') || lowerName.contains('olive oil'))
      return 0.91;
    if (lowerName.contains('코코넛오일') || lowerName.contains('coconut oil'))
      return 0.92;
    if (lowerName.contains('기름') || lowerName.contains('oil')) return 0.92;
    if (lowerName.contains('꿀') || lowerName.contains('honey')) return 1.42;
    if (lowerName.contains('메이플시럽') || lowerName.contains('maple syrup'))
      return 1.32;
    if (lowerName.contains('물엿') || lowerName.contains('corn syrup'))
      return 1.38;
    if (lowerName.contains('시럽') || lowerName.contains('syrup')) return 1.30;

    // 고체류 (정밀한 밀도 적용)
    if (lowerName.contains('백설탕') || lowerName.contains('white sugar'))
      return 0.85;
    if (lowerName.contains('흑설탕') || lowerName.contains('brown sugar'))
      return 0.90;
    if (lowerName.contains('설탕') || lowerName.contains('sugar')) return 0.85;
    if (lowerName.contains('소금') || lowerName.contains('salt')) return 1.20;
    if (lowerName.contains('버터') || lowerName.contains('butter')) return 0.91;
    if (lowerName.contains('마가린') || lowerName.contains('margarine'))
      return 0.90;

    // 이스트류
    if (lowerName.contains('드라이이스트') || lowerName.contains('dry yeast'))
      return 0.45;
    if (lowerName.contains('인스턴트이스트') || lowerName.contains('instant yeast'))
      return 0.45;
    if (lowerName.contains('생이스트') || lowerName.contains('fresh yeast'))
      return 1.05;
    if (lowerName.contains('이스트') || lowerName.contains('yeast')) return 0.45;

    // 계란류
    if (lowerName.contains('계란') ||
        lowerName.contains('달걀') ||
        lowerName.contains('egg')) return 1.03;

    // 기본값 (물의 밀도)
    return 1.00;
  }

  // === 개선된 수분 계산을 위한 헬퍼 메소드들 ===

  /// 재료를 수분 함량에 따라 분류
  static Map<String, List<Map<String, dynamic>>>
      classifyIngredientsByMoistureContent(
          List<Map<String, dynamic>> ingredients) {
    final classified = <String, List<Map<String, dynamic>>>{
      'solid': [], // 고체 재료 (밀가루, 소금, 설탕, 이스트 등)
      'liquid': [], // 액체 재료 (물, 우유, 기름 등)
      'moist': [], // 수분이 많은 재료 (계란, 크림, 요구르트 등)
    };

    for (final ingredient in ingredients) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();

      if (isSolidIngredient(name)) {
        classified['solid']!.add(ingredient);
      } else if (isPureLiquidIngredient(name)) {
        classified['liquid']!.add(ingredient);
      } else if (isMoistIngredient(name)) {
        classified['moist']!.add(ingredient);
      } else {
        // 분류되지 않은 재료는 고체로 취급
        classified['solid']!.add(ingredient);
      }
    }

    return classified;
  }

  /// 고체 재료 총량 계산
  static double _calculateSolidIngredientsWeight(
      List<Map<String, dynamic>> solidIngredients) {
    double totalWeight = 0.0;

    for (final ingredient in solidIngredients) {
      final amount = ingredient['amount'] as double? ?? 0.0;
      final unit = ingredient['unit'] as String? ?? 'g';
      final name = ingredient['name'] as String? ?? '';

      totalWeight += convertToGrams(amount, unit, name);
    }

    return totalWeight;
  }

  /// 액체 재료 총량 계산 (100% 수분)
  static double _calculateLiquidIngredientsWeight(
      List<Map<String, dynamic>> liquidIngredients) {
    double totalWeight = 0.0;

    for (final ingredient in liquidIngredients) {
      final amount = ingredient['amount'] as double? ?? 0.0;
      final unit = ingredient['unit'] as String? ?? 'g';
      final name = ingredient['name'] as String? ?? '';

      totalWeight += convertToGrams(amount, unit, name);
    }

    return totalWeight;
  }

  /// 수분이 많은 재료의 수분량 계산
  static double _calculateMoistIngredientsMoisture(
      List<Map<String, dynamic>> moistIngredients) {
    double totalMoisture = 0.0;

    for (final ingredient in moistIngredients) {
      final amount = ingredient['amount'] as double? ?? 0.0;
      final unit = ingredient['unit'] as String? ?? 'g';
      final name = ingredient['name'] as String? ?? '';

      final weight = convertToGrams(amount, unit, name);
      final moistureContent = getMoistureContent(name);

      totalMoisture += weight * moistureContent;
    }

    return totalMoisture;
  }

  /// 빵 타입별 수분 흡수율 조정 (밀가루 종류별 특성 고려)
  static double _adjustHydrationByBreadType(
      double hydration, String breadType) {
    // 빵 타입별 기본 조정 계수
    double adjustmentFactor = 1.0;

    switch (breadType.toLowerCase()) {
      case 'baguette':
      case '바게트':
        adjustmentFactor = 0.75; // 바게트는 낮은 수분
        break;
      case 'ciabatta':
      case '치아바타':
        adjustmentFactor = 0.85; // 치아바타는 중간 수분
        break;
      case 'sourdough':
      case '사워도우':
        adjustmentFactor = 0.90; // 사워도우는 높은 수분
        break;
      case 'pizza':
      case '피자':
        adjustmentFactor = 0.70; // 피자는 낮은 수분
        break;
      case 'croissant':
      case '크루아상':
        adjustmentFactor = 0.65; // 크루아상은 매우 낮은 수분
        break;
      case 'brioche':
      case '브리오슈':
        adjustmentFactor = 0.80; // 브리오슈는 중간 수분
        break;
      default:
        adjustmentFactor = 1.0; // 기본 빵 타입은 조정 없음
    }

    final adjustedHydration = hydration * adjustmentFactor;

    print('🔍 [빵 타입별 수분 조정] 빵 타입: $breadType');
    print('   - 조정 계수: ${adjustmentFactor.toStringAsFixed(2)}');
    print('   - 원래 수분: ${(hydration * 100).toStringAsFixed(1)}%');
    print('   - 조정 후 수분: ${(adjustedHydration * 100).toStringAsFixed(1)}%');

    return adjustedHydration;
  }

  /// 밀가루 종류별 수분 흡수율 계산 (밀가루 특성 기반)
  static double calculateFlourBasedHydration(
    List<Map<String, dynamic>> ingredients, {
    String? recipeTitle,
  }) {
    try {
      final flourIngredients =
          findFlourIngredients(ingredients, recipeTitle: recipeTitle);
      final liquidIngredients =
          findLiquidIngredients(ingredients, recipeTitle: recipeTitle);

      if (flourIngredients.isEmpty) return 0.0;

      // 밀가루 종류별 수분 흡수율 계산
      double totalFlourHydrationCapacity = 0.0;
      double totalFlourWeight = 0.0;

      for (final flour in flourIngredients) {
        final name = flour['name'] as String? ?? '';
        final amount = flour['amount'] as double? ?? 0.0;
        final unit = flour['unit'] as String? ?? 'g';

        // 밀가루 종류별 수분 흡수율 가져오기
        final hydrationCapacity = getFlourHydrationCapacity(name);
        final weight = convertToGrams(amount, unit, name);

        totalFlourHydrationCapacity += hydrationCapacity * weight;
        totalFlourWeight += weight;

        print('🔍 [밀가루 수분 흡수율] 밀가루: $name');
        print('   - 수분 흡수율: ${(hydrationCapacity * 100).toStringAsFixed(1)}%');
        print('   - 무게: ${weight.toStringAsFixed(1)}g');
      }

      // 평균 밀가루 수분 흡수율 계산
      final avgFlourHydrationCapacity = totalFlourWeight > 0
          ? totalFlourHydrationCapacity / totalFlourWeight
          : 0.65; // 기본값

      // 액체 총량 계산
      double totalLiquidWeight = 0.0;
      for (final liquid in liquidIngredients) {
        final amount = liquid['amount'] as double? ?? 0.0;
        final unit = liquid['unit'] as String? ?? 'g';
        final name = liquid['name'] as String? ?? '';

        totalLiquidWeight += convertToGrams(amount, unit, name);
      }

      // 밀가루 종류별 수분 흡수율 기반 계산
      if (totalFlourWeight > 0) {
        final hydration = (totalLiquidWeight / totalFlourWeight) * 100;

        // 밀가루 특성에 따른 조정
        final adjustedHydration = hydration / avgFlourHydrationCapacity;

        print('🔍 [밀가루 기반 수분 계산]');
        print(
            '   - 평균 밀가루 수분 흡수율: ${(avgFlourHydrationCapacity * 100).toStringAsFixed(1)}%');
        print('   - 원래 수분: ${(hydration).toStringAsFixed(1)}%');
        print('   - 조정 후 수분: ${(adjustedHydration).toStringAsFixed(1)}%');

        return adjustedHydration;
      }

      return 0.0;
    } catch (e) {
      print('❌ 밀가루 기반 수분 계산 오류: $e');
      return 0.0;
    }
  }

  /// 고체 재료 판별
  static bool isSolidIngredient(String name) {
    final lowerName = name.toLowerCase();

    // 밀가루류
    if (isFlour(lowerName)) return true;

    // 소금류
    if (_isSalt(lowerName)) return true;

    // 설탕류
    if (lowerName.contains('설탕') || lowerName.contains('sugar')) return true;

    // 이스트류
    if (_isYeast(lowerName)) return true;

    // 기타 고체 재료
    final solidKeywords = [
      '베이킹파우더',
      'baking powder',
      '베이킹소다',
      'baking soda',
      '코코아',
      'cocoa',
      '초콜릿',
      'chocolate',
      '견과류',
      'nuts',
      '씨앗',
      'seeds',
      '과일',
      'fruit',
      '채소',
      'vegetable',
      '향료',
      'spice',
      '허브',
      'herb'
    ];

    return solidKeywords.any((keyword) => lowerName.contains(keyword));
  }

  /// 순수 액체 재료 판별
  static bool isPureLiquidIngredient(String name) {
    final lowerName = name.toLowerCase();

    // 물
    if (lowerName.contains('물') || lowerName.contains('water')) return true;

    // 기름류 (액체지만 수분 없음)
    if (lowerName.contains('기름') ||
        lowerName.contains('오일') ||
        lowerName.contains('oil')) return true;

    // 시럽류
    if (lowerName.contains('시럽') || lowerName.contains('syrup')) return true;

    // 꿀
    if (lowerName.contains('꿀') || lowerName.contains('honey')) return true;

    return false;
  }

  /// 수분이 많은 재료 판별
  static bool isMoistIngredient(String name) {
    final lowerName = name.toLowerCase();

    // 우유류
    if (lowerName.contains('우유') || lowerName.contains('milk')) return true;

    // 크림류
    if (lowerName.contains('크림') || lowerName.contains('cream')) return true;

    // 요구르트
    if (lowerName.contains('요구르트') || lowerName.contains('yogurt')) return true;

    // 계란
    if (lowerName.contains('계란') ||
        lowerName.contains('달걀') ||
        lowerName.contains('egg')) return true;

    // 치즈
    if (lowerName.contains('치즈') || lowerName.contains('cheese')) return true;

    return false;
  }

  /// 재료별 수분 함량 반환 (빵 제조 과학적 데이터 기반)
  static double getMoistureContent(String name) {
    final lowerName = name.toLowerCase();

    // 밀가루류 - 밀가루 종류별 특성 데이터베이스 활용
    if (isFlour(lowerName)) {
      // 밀가루 종류 감지 및 특성 활용
      final flourInfo = detectFlourType(name);
      final characteristics =
          flourInfo['characteristics'] as Map<String, dynamic>;
      final moistureContent = characteristics['moistureContent'] as double;

      print('🔍 [수분 함량 계산] 밀가루 종류 감지: ${flourInfo['type']}');
      print('   - 감지된 키워드: ${flourInfo['detectedKeyword']}');
      print('   - 수분 함량: ${(moistureContent * 100).toStringAsFixed(1)}%');

      return moistureContent;
    }

    // 우유류 (87-90% 수분)
    if (lowerName.contains('우유') || lowerName.contains('milk')) {
      if (lowerName.contains('전지유') || lowerName.contains('whole milk'))
        return 0.87;
      if (lowerName.contains('저지방') || lowerName.contains('low-fat'))
        return 0.90;
      if (lowerName.contains('탈지') || lowerName.contains('skim')) return 0.91;
      return 0.87; // 기본 우유
    }

    // 크림류 (70-85% 수분)
    if (lowerName.contains('크림') || lowerName.contains('cream')) {
      if (lowerName.contains('생크림') || lowerName.contains('heavy cream'))
        return 0.70;
      if (lowerName.contains('휘핑') || lowerName.contains('whipping'))
        return 0.75;
      return 0.80; // 일반 크림
    }

    // 요구르트 (85-88% 수분)
    if (lowerName.contains('요구르트') || lowerName.contains('yogurt')) return 0.85;

    // 계란 (74% 수분)
    if (lowerName.contains('계란') ||
        lowerName.contains('달걀') ||
        lowerName.contains('egg')) return 0.74;

    // 치즈 (30-50% 수분, 빵에 사용되는 정도)
    if (lowerName.contains('치즈') || lowerName.contains('cheese')) return 0.40;

    // 기본값 (수분이 많은 재료로 분류되었지만 구체적인 값이 없는 경우)
    return 0.0; // 수분 없음 (정확한 계산)
  }

  /// 기본 수분 흡수율 계산 (재료가 없을 때 사용)
  static double _calculateDefaultHydration() {
    // 실제 데이터 기반 계산 원칙 준수
    // 수분 재료가 감지되지 않으면 0 반환 (수분 없음)
    return 0.0; // 수분 없음 (올바른 계산 결과)
  }

  /// 동적 온도 범위 계산 (컨셉 준수 - 하드코딩 제거)
  /// 재료 열용량, 환경 조건 기반 과학적 범위 계산
  static Map<String, double> calculateDynamicTemperatureRange(
    List<Map<String, dynamic>> ingredients, {
    String? recipeTitle,
    double environmentTemp = 20.0,
  }) {
    try {
      // 1. 재료 열용량 기반 기본 범위 (빵 제조 과학적 계산)
      final heatCapacities = _calculateIngredientHeatCapacities(ingredients);
      double baseMin = 5.0; // 빵 제조 최소 (과학적)
      double baseMax = 50.0; // 빵 제조 최대 (과학적)

      // 2. 환경 온도 반영 (빵 제조 과학적 계산)
      final tempAdjustment = (environmentTemp - 20.0) * 0.8;
      baseMin += tempAdjustment;
      baseMax += tempAdjustment;

      // 3. 재료 특성 반영 (빵 제조 과학적 계산)
      if (hasColdIngredients(ingredients)) {
        baseMin -= 3.0; // 냉장 재료 고려
      }

      // 4. 빵 제조 과학적 안전 마진 (±2°C)
      return {
        'min': baseMin - 2.0,
        'max': baseMax + 2.0,
      };
    } catch (e) {
      print('❌ 동적 온도 범위 계산 오류: $e');
      // 오류 시 기본 범위 반환 (컨셉 준수)
      return {'min': 10.0, 'max': 35.0};
    }
  }

  /// 냉장 재료 존재 여부 확인
  static bool hasColdIngredients(List<Map<String, dynamic>> ingredients) {
    return ingredients.any((ingredient) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      return name.contains('버터') ||
          name.contains('butter') ||
          name.contains('크림') ||
          name.contains('cream') ||
          name.contains('우유') ||
          name.contains('milk') ||
          name.contains('치즈') ||
          name.contains('cheese');
    });
  }

  /// 재료별 열용량 계산 (빵 제조 과학적 계산)
  static Map<String, double> _calculateIngredientHeatCapacities(
      List<Map<String, dynamic>> ingredients) {
    double flourHeatCapacity = 0.0;
    double waterHeatCapacity = 0.0;
    double otherHeatCapacity = 0.0;

    for (final ingredient in ingredients) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final amount = ingredient['amount'] as double? ?? 0.0;
      final unit = ingredient['unit'] as String? ?? 'g';

      // 그램으로 변환
      final weightInGrams = convertToGrams(amount, unit, name);

      if (weightInGrams <= 0) continue;

      // 빵 제조 과학적 열용량 계수 (cal/g°C)
      if (_isFlourIngredient(name)) {
        // 밀가루 열용량: 0.4 cal/g°C (빵 제조 표준 값)
        flourHeatCapacity += weightInGrams * 0.4;
      } else if (_isWaterIngredient(name)) {
        // 물 열용량: 1.0 cal/g°C (물리화학적 상수)
        waterHeatCapacity += weightInGrams * 1.0;
      } else {
        // 기타 재료 열용량: 0.8 cal/g°C (평균 값)
        otherHeatCapacity += weightInGrams * 0.8;
      }
    }

    return {
      'flour': flourHeatCapacity,
      'water': waterHeatCapacity,
      'other': otherHeatCapacity,
    };
  }

  /// 밀가루 재료 판별
  static bool _isFlourIngredient(String name) {
    return name.contains('밀가루') ||
        name.contains('flour') ||
        name.contains('밀가') ||
        name.contains('곡물가루');
  }

  /// 물 재료 판별
  static bool _isWaterIngredient(String name) {
    return name.contains('물') ||
        name.contains('water') ||
        name.contains('우유') ||
        name.contains('milk') ||
        name.contains('크림') ||
        name.contains('cream');
  }

  /// 기본 온도 계산 (컨셉 준수 - 동적 범위 적용)
  /// 재료 기반으로 최적의 반죽 온도를 계산 (하드코딩 범위 제거)
  static double calculateBaseTemperature(
    List<Map<String, dynamic>> ingredients, {
    String? recipeTitle,
    double environmentTemp = 20.0,
  }) {
    try {
      // 빵 타입별 기본 온도 설정 (경고용으로만 사용)
      final breadType = estimateBreadTypeFromTitle(recipeTitle ?? '');
      double baseTemperature = 22.0; // 기본 실온

      switch (breadType.toLowerCase()) {
        case 'bread':
        case '식빵':
          baseTemperature = 24.0; // 식빵은 약간 따뜻한 온도
          break;
        case 'baguette':
        case '바게트':
          baseTemperature = 22.0; // 바게트는 실온
          break;
        case 'croissant':
        case '크루아상':
          baseTemperature = 20.0; // 크루아상은 서늘한 온도
          break;
        case 'brioche':
        case '브리오슈':
          baseTemperature = 25.0; // 브리오슈는 따뜻한 온도
          break;
        case 'sourdough':
        case '사워도우':
          baseTemperature = 23.0; // 사워도우는 중간 온도
          break;
        case 'pizza':
        case '피자':
          baseTemperature = 20.0; // 피자는 서늘한 온도
          break;
        default:
          baseTemperature = 22.0; // 일반 빵은 실온
      }

      // 재료별 온도 조정
      if (ingredients.isNotEmpty) {
        // 냉장 재료가 있는 경우 온도 조정
        if (hasColdIngredients(ingredients)) {
          baseTemperature += 2.0; // 냉장 재료 보정
        }

        // 고온 재료가 있는 경우 온도 조정
        final hasHotIngredients = ingredients.any((ingredient) {
          final name = (ingredient['name'] as String? ?? '').toLowerCase();
          return name.contains('뜨거운') ||
              name.contains('hot') ||
              name.contains('끓는') ||
              name.contains('boiling');
        });

        if (hasHotIngredients) {
          baseTemperature -= 3.0; // 고온 재료 보정
        }
      }

      // ✅ 컨셉 준수: 동적 범위 적용 (하드코딩 제거)
      // 빵 타입별 범위는 경고용으로만 사용, 계산 clamp는 동적 범위 기반
      final dynamicRange = calculateDynamicTemperatureRange(
        ingredients,
        recipeTitle: recipeTitle,
        environmentTemp: environmentTemp,
      );

      // 동적 범위 내에서만 제한 (극단적 값도 허용하되 합리적 범위 유지)
      final clampedTemp =
          baseTemperature.clamp(dynamicRange['min']!, dynamicRange['max']!);

      print(
          '✅ [기본 온도 계산] 동적 범위 적용: ${dynamicRange['min']}°C ~ ${dynamicRange['max']}°C');
      print('   - 계산된 온도: ${baseTemperature.toStringAsFixed(1)}°C');
      print('   - 최종 온도: ${clampedTemp.toStringAsFixed(1)}°C');

      return clampedTemp;
    } catch (e) {
      print('❌ 기본 온도 계산 오류: $e');
      // 오류 시에도 동적 범위 적용
      final fallbackRange = calculateDynamicTemperatureRange(
        ingredients,
        recipeTitle: recipeTitle,
        environmentTemp: environmentTemp,
      );
      return 22.0.clamp(fallbackRange['min']!, fallbackRange['max']!);
    }
  }

  /// 고체 재료 총 무게 계산
  static double calculateSolidIngredientsWeight(
    List<Map<String, dynamic>> ingredients, {
    String? recipeTitle,
  }) {
    final solidIngredients = ingredients
        .where((ingredient) =>
            isSolidIngredient(ingredient['name'] as String? ?? ''))
        .toList();

    double totalWeight = 0.0;
    for (final ingredient in solidIngredients) {
      final amount = ingredient['amount'] as double? ?? 0.0;
      final unit = ingredient['unit'] as String? ?? 'g';
      final name = ingredient['name'] as String? ?? '';

      totalWeight += convertToGrams(amount, unit, name);
    }

    print('🔍 [고체 재료 무게] 총 고체 무게: ${totalWeight.toStringAsFixed(1)}g');
    return totalWeight;
  }

  /// 수분 재료 총 무게 계산
  static double calculateLiquidIngredientsWeight(
    List<Map<String, dynamic>> ingredients, {
    String? recipeTitle,
  }) {
    final liquidIngredients =
        findLiquidIngredients(ingredients, recipeTitle: recipeTitle);

    double totalWeight = 0.0;
    for (final ingredient in liquidIngredients) {
      final amount = ingredient['amount'] as double? ?? 0.0;
      final unit = ingredient['unit'] as String? ?? 'g';
      final name = ingredient['name'] as String? ?? '';

      // 액체 재료는 100% 수분이므로 총량 그대로
      totalWeight += convertToGrams(amount, unit, name);
    }

    print('🔍 [수분 재료 무게] 총 수분 무게: ${totalWeight.toStringAsFixed(1)}g');
    return totalWeight;
  }

  /// 총 반죽 무게 계산 (고체 + 수분)
  static double calculateTotalDoughWeight(
    List<Map<String, dynamic>> ingredients, {
    String? recipeTitle,
  }) {
    final solidWeight =
        calculateSolidIngredientsWeight(ingredients, recipeTitle: recipeTitle);
    final liquidWeight =
        calculateLiquidIngredientsWeight(ingredients, recipeTitle: recipeTitle);

    final totalWeight = solidWeight + liquidWeight;
    print(
        '🔍 [총 반죽 무게] 고체: ${solidWeight.toStringAsFixed(1)}g, 수분: ${liquidWeight.toStringAsFixed(1)}g, 총계: ${totalWeight.toStringAsFixed(1)}g');

    return totalWeight;
  }

  /// 반죽 형성 가능성 분석 (빵 제조 과학적 계산)
  /// 재료 기반으로 반죽이 고체재료들이 수분을 흡수해서 반죽을 만들 수 있는지 분석
  static Map<String, dynamic> analyzeDoughFormationCapability(
    List<Map<String, dynamic>> ingredients, {
    String? recipeTitle,
  }) {
    final analysis = <String, dynamic>{
      'isFormable': false,
      'confidence': 0.0,
      'issues': <String>[],
      'recommendations': <String>[],
      'formationFactors': <String, dynamic>{},
    };

    try {
      // 1. 필수 재료 검증
      final hasFlour =
          findFlourIngredients(ingredients, recipeTitle: recipeTitle)
              .isNotEmpty;
      final hasLiquid =
          findLiquidIngredients(ingredients, recipeTitle: recipeTitle)
              .isNotEmpty;

      if (!hasFlour) {
        analysis['issues'].add('밀가루가 없어 반죽 형성이 불가능합니다');
        analysis['recommendations'].add('빵 제조를 위해 밀가루를 추가하세요');
        return analysis;
      }

      if (!hasLiquid) {
        analysis['issues'].add('액체 재료가 없어 반죽 형성이 불가능합니다');
        analysis['recommendations'].add('빵 제조를 위해 물이나 우유 등의 액체를 추가하세요');
        return analysis;
      }

      // 2. 수분 흡수율 계산 및 검증
      final hydration =
          calculateRealisticHydration(ingredients, recipeTitle: recipeTitle);
      if (hydration.isNaN || hydration.isInfinite) {
        analysis['issues'].add('수분 흡수율 계산에 실패했습니다');
        return analysis;
      }

      // 3. 반죽 형성 가능성 평가 (빵 제조 과학적 기준)
      final formationAnalysis = _evaluateDoughFormationFactors(
        ingredients,
        hydration,
        recipeTitle,
      );

      analysis['formationFactors'] = formationAnalysis['factors'];
      analysis['issues'].addAll(formationAnalysis['issues']);
      analysis['recommendations'].addAll(formationAnalysis['recommendations']);

      // 4. 종합 평가
      final overallScore = _calculateDoughFormationScore(
        formationAnalysis['factors'] as Map<String, dynamic>,
        hydration,
      );

      analysis['isFormable'] = overallScore >= 0.6; // 60% 이상이면 형성 가능
      analysis['confidence'] = overallScore;

      // 5. 형성 가능성 등급화
      analysis['formationGrade'] = _getFormationGrade(overallScore);

      print(
          '✅ 반죽 형성 분석 완료: ${analysis['formationGrade']} (점수: ${(overallScore * 100).toStringAsFixed(1)}%)');

      return analysis;
    } catch (e) {
      print('❌ 반죽 형성 분석 중 오류: $e');
      analysis['issues'].add('반죽 형성 분석 중 오류가 발생했습니다: $e');
      return analysis;
    }
  }

  /// 반죽 형성 요인 평가 (빵 제조 과학적 계산)
  static Map<String, dynamic> _evaluateDoughFormationFactors(
    List<Map<String, dynamic>> ingredients,
    double hydration,
    String? recipeTitle,
  ) {
    final factors = <String, dynamic>{};
    final issues = <String>[];
    final recommendations = <String>[];

    // 1. 수분 흡수율 요인 (가장 중요)
    factors['hydrationFactor'] = _evaluateHydrationFactor(hydration);
    if (hydration < 0.5) {
      issues.add(
          '수분 흡수율이 너무 낮아 반죽 형성이 어려움 (${(hydration * 100).toStringAsFixed(1)}%)');
      recommendations.add('수분을 더 추가하여 60-75% 범위로 조정하세요');
    } else if (hydration > 1.0) {
      issues.add(
          '수분 흡수율이 100%를 초과하여 과학적으로 불가능 (${(hydration * 100).toStringAsFixed(1)}%)');
      recommendations.add('빵 제조 과학적으로 수분 흡수율은 100%를 초과할 수 없습니다');
    }

    // 2. 밀가루 품질 요인
    final flourFactor = _evaluateFlourQualityFactor(ingredients);
    factors['flourFactor'] = flourFactor;
    if (flourFactor < 0.6) {
      issues.add('밀가루 품질이 반죽 형성에 적합하지 않음');
      recommendations.add('빵 제조용 강력분 사용을 고려하세요');
    }

    // 3. 글루텐 형성 잠재력 요인
    final glutenFactor = _evaluateGlutenFormationFactor(ingredients, hydration);
    factors['glutenFactor'] = glutenFactor;
    if (glutenFactor < 0.5) {
      issues.add('글루텐 형성 잠재력이 부족함');
      recommendations.add('단백질 함량이 높은 밀가루 사용을 고려하세요');
    }

    // 4. 재료 균형 요인
    final balanceFactor = _evaluateIngredientBalanceFactor(ingredients);
    factors['balanceFactor'] = balanceFactor;
    if (balanceFactor < 0.6) {
      issues.add('재료 비율이 균형을 이루지 못함');
      recommendations.add('밀가루, 물, 소금, 이스트의 비율을 적정하게 조정하세요');
    }

    // 5. 빵 타입 적합성 요인
    final breadTypeFactor =
        _evaluateBreadTypeSuitability(recipeTitle, hydration);
    factors['breadTypeFactor'] = breadTypeFactor;
    if (breadTypeFactor < 0.7) {
      issues.add('현재 빵 타입에 적합하지 않은 수분량');
      recommendations.add('빵 타입에 맞는 수분량으로 조정하세요');
    }

    return {
      'factors': factors,
      'issues': issues,
      'recommendations': recommendations,
    };
  }

  /// 수분 흡수율 요인 평가
  static double _evaluateHydrationFactor(double hydration) {
    if (hydration >= 0.6 && hydration <= 0.75) return 1.0; // 최적 범위
    if (hydration >= 0.5 && hydration <= 0.8) return 0.8; // 수용 가능 범위
    if (hydration >= 0.4 && hydration <= 0.9) return 0.6; // 한계 범위
    return 0.3; // 부적합 범위
  }

  /// 밀가루 품질 요인 평가 (밀가루 종류별 특성 활용)
  static double _evaluateFlourQualityFactor(
      List<Map<String, dynamic>> ingredients) {
    final flourIngredients = findFlourIngredients(ingredients);

    if (flourIngredients.isEmpty) return 0.0;

    double totalScore = 0.0;
    double totalWeight = 0.0;

    for (final flour in flourIngredients) {
      final name = flour['name'] as String? ?? '';
      final amount = flour['amount'] as double? ?? 0.0;
      final unit = flour['unit'] as String? ?? 'g';

      // 밀가루 종류별 특성 데이터베이스 활용
      final flourInfo = detectFlourType(name);
      final characteristics =
          flourInfo['characteristics'] as Map<String, dynamic>;
      final glutenFormation = characteristics['glutenFormation'] as double;
      final weight = convertToGrams(amount, unit, name);

      // 글루텐 형성도를 기반으로 품질 점수 계산
      final score = glutenFormation; // 0.0 ~ 1.0 범위

      totalScore += score * weight;
      totalWeight += weight;

      print('🔍 [밀가루 품질 평가] 밀가루: $name');
      print('   - 글루텐 형성도: ${(glutenFormation * 100).toStringAsFixed(1)}%');
      print('   - 품질 점수: ${(score * 100).toStringAsFixed(1)}%');
      print('   - 무게: ${weight.toStringAsFixed(1)}g');
    }

    // 가중 평균 계산
    final avgScore = totalWeight > 0 ? totalScore / totalWeight : 0.0;

    print('🔍 [밀가루 품질 최종] 평균 품질 점수: ${(avgScore * 100).toStringAsFixed(1)}%');

    return avgScore;
  }

  /// 글루텐 형성 잠재력 요인 평가 (밀가루 종류별 특성 활용)
  static double _evaluateGlutenFormationFactor(
    List<Map<String, dynamic>> ingredients,
    double hydration,
  ) {
    // 밀가루 종류별 특성 데이터베이스 활용
    final flourIngredients = findFlourIngredients(ingredients);
    double totalGlutenFormation = 0.0;
    double totalWeight = 0.0;

    if (flourIngredients.isNotEmpty) {
      for (final flour in flourIngredients) {
        final name = flour['name'] as String? ?? '';
        final amount = flour['amount'] as double? ?? 0.0;
        final unit = flour['unit'] as String? ?? 'g';

        // 밀가루 종류별 글루텐 형성도 가져오기
        final glutenFormation = getFlourGlutenFormation(name);
        final weight = convertToGrams(amount, unit, name);

        totalGlutenFormation += glutenFormation * weight;
        totalWeight += weight;

        print('🔍 [글루텐 형성도 계산] 밀가루: $name');
        print('   - 글루텐 형성도: ${(glutenFormation * 100).toStringAsFixed(1)}%');
        print('   - 무게: ${weight.toStringAsFixed(1)}g');
      }
    }

    // 평균 글루텐 형성도 계산
    final avgGlutenFormation =
        totalWeight > 0 ? totalGlutenFormation / totalWeight : 0.6;

    // 수분량에 따른 글루텐 형성 효율 보정
    double hydrationEfficiency = 1.0;
    if (hydration > 0.75) {
      hydrationEfficiency = 0.8; // 고수분은 글루텐 형성이 어려움
    } else if (hydration < 0.6) {
      hydrationEfficiency = 0.7; // 저수분은 글루텐 형성이 불충분
    }

    final finalScore = avgGlutenFormation * hydrationEfficiency;

    print(
        '🔍 [글루텐 형성도 최종] 평균: ${(avgGlutenFormation * 100).toStringAsFixed(1)}%, 효율: ${hydrationEfficiency.toStringAsFixed(2)}, 최종: ${(finalScore * 100).toStringAsFixed(1)}%');

    return finalScore;
  }

  /// 재료 균형 요인 평가
  static double _evaluateIngredientBalanceFactor(
      List<Map<String, dynamic>> ingredients) {
    final flourIngredients = findFlourIngredients(ingredients);
    final liquidIngredients = findLiquidIngredients(ingredients);
    final yeastIngredients = findYeastIngredients(ingredients);
    final saltIngredients = findSaltIngredients(ingredients);

    double balanceScore = 0.0;
    int factorCount = 0;

    // 밀가루 존재성
    if (flourIngredients.isNotEmpty) {
      balanceScore += 1.0;
      factorCount++;
    }

    // 액체 존재성
    if (liquidIngredients.isNotEmpty) {
      balanceScore += 1.0;
      factorCount++;
    }

    // 이스트 존재성 (선택적)
    if (yeastIngredients.isNotEmpty) {
      balanceScore += 0.8;
      factorCount++;
    }

    // 소금 존재성 (선택적)
    if (saltIngredients.isNotEmpty) {
      balanceScore += 0.6;
      factorCount++;
    }

    return factorCount > 0 ? balanceScore / factorCount : 0.0;
  }

  /// 빵 타입 적합성 요인 평가
  static double _evaluateBreadTypeSuitability(
      String? recipeTitle, double hydration) {
    if (recipeTitle == null) return 0.8; // 기본값

    final breadType = estimateBreadTypeFromTitle(recipeTitle);
    double suitability = 0.8; // 기본 적합성

    // 빵 타입별 최적 수분 범위
    switch (breadType) {
      case 'baguette':
        suitability = (hydration >= 0.65 && hydration <= 0.75) ? 1.0 : 0.6;
        break;
      case 'ciabatta':
        suitability = (hydration >= 0.7 && hydration <= 0.85) ? 1.0 : 0.7;
        break;
      case 'sourdough':
        suitability = (hydration >= 0.65 && hydration <= 0.8) ? 1.0 : 0.7;
        break;
      case 'bread':
        suitability = (hydration >= 0.6 && hydration <= 0.75) ? 1.0 : 0.8;
        break;
      case 'croissant':
        suitability = (hydration >= 0.55 && hydration <= 0.65) ? 1.0 : 0.6;
        break;
      default:
        suitability = (hydration >= 0.6 && hydration <= 0.75) ? 1.0 : 0.7;
    }

    return suitability;
  }

  /// 반죽 형성 점수 계산
  static double _calculateDoughFormationScore(
    Map<String, dynamic> factors,
    double hydration,
  ) {
    // 각 요인의 가중치
    final weights = {
      'hydrationFactor': 0.4, // 수분 흡수율 (가장 중요)
      'flourFactor': 0.25, // 밀가루 품질
      'glutenFactor': 0.2, // 글루텐 형성 잠재력
      'balanceFactor': 0.1, // 재료 균형
      'breadTypeFactor': 0.05, // 빵 타입 적합성
    };

    double totalScore = 0.0;
    double totalWeight = 0.0;

    for (final entry in weights.entries) {
      final factorName = entry.key;
      final weight = entry.value;
      final factorValue = factors[factorName] as double? ?? 0.0;

      totalScore += factorValue * weight;
      totalWeight += weight;
    }

    return totalWeight > 0 ? totalScore / totalWeight : 0.0;
  }

  /// 형성 가능성 등급화
  static String _getFormationGrade(double score) {
    if (score >= 0.9) return '탁월';
    if (score >= 0.8) return '우수';
    if (score >= 0.7) return '양호';
    if (score >= 0.6) return '가능';
    if (score >= 0.4) return '한계';
    return '불가능';
  }

  /// 안전한 기본 수분 흡수율 반환 (NaN 방지)
  static double _getSafeDefaultHydration() {
    print('🛡️ [안전한 기본 수분] 빵 제조 표준 수분 흡수율: 65.0%');
    return 65.0; // 빵 제조 표준 수분 흡수율
  }

  /// 유효한 재료 필터링 (NaN 방지)
  static List<Map<String, dynamic>> _filterValidIngredients(
      List<Map<String, dynamic>> ingredients) {
    return ingredients.where((ingredient) {
      try {
        final name = ingredient['name'] as String? ?? '';
        final amount = ingredient['amount'] as num?;
        final unit = ingredient['unit'] as String? ?? 'g';

        // 기본 검증
        if (name.isEmpty) return false;
        if (amount == null || amount <= 0) return false;
        if (unit.isEmpty) return false;

        // 수치 검증
        if (amount.isNaN || amount.isInfinite) return false;

        // 단위 변환 검증
        final weight = convertToGrams(amount.toDouble(), unit, name);
        if (weight.isNaN || weight.isInfinite || weight <= 0) return false;

        return true;
      } catch (e) {
        print('⚠️ [재료 필터링] 유효하지 않은 재료 발견: $e');
        return false;
      }
    }).toList();
  }
}
