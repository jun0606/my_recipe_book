import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/unified_ingredient.dart';
import '../../../features/chef/module/bread/types/unified_types.dart'
    hide UnifiedIngredient;

/// 재료 카테고리 열거형
enum IngredientCategory {
  grain, // 곡물 및 밀가루
  leavening, // 발효제
  sweetener, // 감미료
  fat, // 유지방
  liquid, // 액체
  protein, // 단백질
  other, // 기타
}

/// 재료 타입 정보
class IngredientType {
  final IngredientCategory category;
  final double density; // g/ml
  final List<String> commonNames;
  final Map<String, dynamic> properties;

  const IngredientType({
    required this.category,
    required this.density,
    required this.commonNames,
    required this.properties,
  });

  factory IngredientType.fromJson(Map<String, dynamic> json) {
    return IngredientType(
      category: IngredientCategory.values.firstWhere(
        (cat) => cat.toString().split('.').last == json['category'],
        orElse: () => IngredientCategory.other,
      ),
      density: json['density'] ?? 1.0,
      commonNames: List<String>.from(json['commonNames'] ?? []),
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category.toString().split('.').last,
      'density': density,
      'commonNames': commonNames,
      'properties': properties,
    };
  }
}

/// 고급 재료 파싱 및 타입 추론 서비스
class IngredientParser {
  static final IngredientParser _instance = IngredientParser._internal();
  factory IngredientParser() => _instance;
  IngredientParser._internal();

  // 재료 타입 데이터베이스
  Map<String, IngredientType> _ingredientDatabase = {};
  Map<String, UnitConversion> _unitConversions = {};

  // 초기화 상태
  bool _isInitialized = false;

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 재료 데이터베이스 로드
      await _loadIngredientDatabase();
      // 단위 변환 데이터 로드
      await _loadUnitConversions();

      _isInitialized = true;
    } catch (e) {
      print('IngredientParser initialization failed: $e');
      // 기본 데이터로 초기화
      _initializeDefaultData();
    }
  }

  /// 재료 데이터베이스 로드
  Future<void> _loadIngredientDatabase() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/ingredients.json');
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      _ingredientDatabase = {};
      data.forEach((key, value) {
        _ingredientDatabase[key] =
            IngredientType.fromJson(value as Map<String, dynamic>);
      });
    } catch (e) {
      print('Failed to load ingredient database: $e');
      _initializeDefaultData();
    }
  }

  /// 단위 변환 데이터 로드
  Future<void> _loadUnitConversions() async {
    _unitConversions = {
      // 무게 단위 변환 (기준: gram)
      'g': UnitConversion(factor: 1.0, toBase: 1.0, fromBase: 1.0),
      'kg': UnitConversion(factor: 1000.0, toBase: 1000.0, fromBase: 0.001),
      'oz': UnitConversion(factor: 28.35, toBase: 28.35, fromBase: 1 / 28.35),
      'lb':
          UnitConversion(factor: 453.59, toBase: 453.59, fromBase: 1 / 453.59),

      // 부피 단위 변환 (기준: ml)
      'ml': UnitConversion(factor: 1.0, toBase: 1.0, fromBase: 1.0),
      'l': UnitConversion(factor: 1000.0, toBase: 1000.0, fromBase: 0.001),
      'cup':
          UnitConversion(factor: 236.59, toBase: 236.59, fromBase: 1 / 236.59),
      'tbsp': UnitConversion(factor: 14.79, toBase: 14.79, fromBase: 1 / 14.79),
      'tsp': UnitConversion(factor: 4.93, toBase: 4.93, fromBase: 1 / 4.93),
      'fl oz':
          UnitConversion(factor: 29.57, toBase: 29.57, fromBase: 1 / 29.57),

      // 개수 단위
      '개': UnitConversion(factor: 1.0, toBase: 1.0, fromBase: 1.0),
      'piece': UnitConversion(factor: 1.0, toBase: 1.0, fromBase: 1.0),
      'slice': UnitConversion(factor: 1.0, toBase: 1.0, fromBase: 1.0),
    };
  }

  /// 기본 데이터 초기화
  void _initializeDefaultData() {
    _ingredientDatabase = {
      // 곡물 및 밀가루
      '밀가루': IngredientType(
        category: IngredientCategory.grain,
        density: 0.55, // g/ml
        commonNames: [
          '밀가루',
          'flour',
          'wheat flour',
          'cake flour',
          'bread flour'
        ],
        properties: {'gluten': 'high', 'usage': 'baking'},
      ),
      '강력분': IngredientType(
        category: IngredientCategory.grain,
        density: 0.55,
        commonNames: ['강력분', 'bread flour', 'high gluten flour'],
        properties: {'gluten': 'very_high', 'usage': 'bread'},
      ),
      '박력분': IngredientType(
        category: IngredientCategory.grain,
        density: 0.55,
        commonNames: ['박력분', 'cake flour', 'low gluten flour'],
        properties: {'gluten': 'low', 'usage': 'cake'},
      ),

      // 효모 및 발효제
      '인스턴트 드라이 이스트': IngredientType(
        category: IngredientCategory.leavening,
        density: 0.3,
        commonNames: ['인스턴트 드라이 이스트', 'instant yeast', 'dry yeast'],
        properties: {'type': 'yeast', 'strength': 'high'},
      ),
      '생이스트': IngredientType(
        category: IngredientCategory.leavening,
        density: 1.0,
        commonNames: ['생이스트', 'fresh yeast', 'cake yeast'],
        properties: {'type': 'yeast', 'strength': 'medium'},
      ),

      // 설탕
      '설탕': IngredientType(
        category: IngredientCategory.sweetener,
        density: 0.85,
        commonNames: ['설탕', 'sugar', 'white sugar', 'granulated sugar'],
        properties: {'type': 'refined', 'crystallization': 'fast'},
      ),
      '흑설탕': IngredientType(
        category: IngredientCategory.sweetener,
        density: 0.85,
        commonNames: ['흑설탕', 'brown sugar', 'dark brown sugar'],
        properties: {'type': 'brown', 'molasses': 'high'},
      ),

      // 유지방
      '버터': IngredientType(
        category: IngredientCategory.fat,
        density: 0.95,
        commonNames: ['버터', 'butter', 'unsalted butter', 'salted butter'],
        properties: {'type': 'dairy', 'smoke_point': 'medium'},
      ),
      '마가린': IngredientType(
        category: IngredientCategory.fat,
        density: 0.95,
        commonNames: ['마가린', 'margarine', 'vegetable oil spread'],
        properties: {'type': 'vegetable', 'smoke_point': 'medium'},
      ),

      // 액체
      '물': IngredientType(
        category: IngredientCategory.liquid,
        density: 1.0,
        commonNames: ['물', 'water', 'filtered water'],
        properties: {'type': 'water', 'ph': 'neutral'},
      ),
      '우유': IngredientType(
        category: IngredientCategory.liquid,
        density: 1.03,
        commonNames: ['우유', 'milk', 'whole milk', 'skim milk'],
        properties: {'type': 'dairy', 'fat_content': 'medium'},
      ),

      // 계란
      '계란': IngredientType(
        category: IngredientCategory.protein,
        density: 1.0,
        commonNames: ['계란', 'egg', 'whole egg', 'large egg'],
        properties: {'type': 'egg', 'size': 'large'},
      ),
    };
  }

  /// 재료 파싱 및 분석
  Future<UnifiedIngredient> parseIngredient(
      String name, double amount, String unit) async {
    if (!_isInitialized) {
      await initialize();
    }

    // 재료명 정규화
    final normalizedName = _normalizeIngredientName(name);

    // 재료 타입 추론
    final ingredientType = _inferIngredientType(normalizedName);

    // 단위 변환
    final baseAmount = await _convertToBaseUnit(amount, unit, ingredientType);

    return UnifiedIngredient(
      name: normalizedName,
      amount: baseAmount,
      unit: 'g', // 기본 단위로 통일
      properties: {
        ...ingredientType.properties,
        'type': ingredientType.category.toString(),
        'originalName': name,
        'originalAmount': amount,
        'originalUnit': unit,
        'confidence': _calculateConfidence(normalizedName, ingredientType),
      },
    );
  }

  /// 재료명 정규화
  String _normalizeIngredientName(String name) {
    // 특수문자 제거 및 정리
    var normalized = name.replaceAll(RegExp(r'[^\w\s가-힣]'), '').trim();

    // 빈 문자열인 경우 원본 반환
    if (normalized.isEmpty) {
      return name;
    }

    // 일반적인 단어 교정
    final corrections = {
      '밀가루': ['밀가루', '밀가루', '밀가루', 'flour'],
      '설탕': ['설탕', '흰설탕', '백설탕', 'sugar', 'white sugar'],
      '버터': ['버터', '무염버터', '유화버터', 'butter', 'unsalted butter'],
      '계란': ['계란', '달걀', '란', 'egg', 'eggs'],
      '물': ['물', '정수물', '물', 'water'],
      '우유': ['우유', '전지분유', '저지방우유', 'milk', 'whole milk'],
    };

    for (final entry in corrections.entries) {
      for (final variant in entry.value) {
        if (normalized.contains(variant)) {
          return entry.key;
        }
      }
    }

    return normalized;
  }

  /// 재료 타입 추론
  IngredientType _inferIngredientType(String normalizedName) {
    // 정확한 매칭 우선
    if (_ingredientDatabase.containsKey(normalizedName)) {
      return _ingredientDatabase[normalizedName]!;
    }

    // 부분 매칭
    for (final entry in _ingredientDatabase.entries) {
      final type = entry.value;
      for (final commonName in type.commonNames) {
        if (normalizedName.contains(commonName.toLowerCase())) {
          return type;
        }
      }
    }

    // 기본 타입 반환
    return IngredientType(
      category: IngredientCategory.other,
      density: 1.0,
      commonNames: [normalizedName],
      properties: {},
    );
  }

  /// 단위 변환
  Future<double> _convertToBaseUnit(
      double amount, String unit, IngredientType type) async {
    if (!_isInitialized) {
      await initialize();
    }

    final normalizedUnit = unit.toLowerCase().trim();

    // 한글 단위 매핑
    final koreanToEnglish = {
      '컵': 'cup',
      'ml': 'ml',
      'l': 'l',
      'g': 'g',
      'kg': 'kg',
      'oz': 'oz',
      'lb': 'lb',
      'tbsp': 'tbsp',
      'tsp': 'tsp',
      'fl oz': 'fl oz',
      '개': 'piece',
    };

    final mappedUnit = koreanToEnglish[normalizedUnit] ?? normalizedUnit;

    if (_unitConversions.containsKey(mappedUnit)) {
      final conversion = _unitConversions[mappedUnit]!;
      final baseAmount = amount * conversion.toBase;

      // 부피 단위인 경우 밀도 적용 (무게 변환)
      if (_isVolumeUnit(mappedUnit)) {
        return baseAmount * type.density;
      }

      return baseAmount;
    }

    // 알 수 없는 단위는 그대로 반환
    return amount;
  }

  /// 부피 단위인지 확인
  bool _isVolumeUnit(String unit) {
    const volumeUnits = ['ml', 'l', 'cup', 'tbsp', 'tsp', 'fl oz'];
    return volumeUnits.contains(unit);
  }

  /// 신뢰도 계산
  double _calculateConfidence(String normalizedName, IngredientType type) {
    // 정확한 매칭
    if (_ingredientDatabase.containsKey(normalizedName)) {
      return 1.0;
    }

    // 부분 매칭 (흰설탕 -> 설탕)
    for (final commonName in type.commonNames) {
      if (normalizedName.contains(commonName.toLowerCase()) ||
          commonName.toLowerCase().contains(normalizedName)) {
        return 0.8;
      }
    }

    // 기본 타입인 경우
    if (type.category == IngredientCategory.other) {
      return 0.3;
    }

    // 카테고리 기반 추론
    return 0.3;
  }

  /// 재료명에서 숫자 정보 추출 (예: "계란 2개" -> amount: 2, unit: "개")
  Future<IngredientParseResult> parseIngredientText(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    // 더 정확한 정규표현식
    final unitRegex = RegExp(r'(\d+(?:\.\d+)?)\s*([^\d\s]+(?:\s*[^\d\s]+)*)$');
    final numberRegex = RegExp(r'(\d+(?:\.\d+)?)');

    final unitMatch = unitRegex.firstMatch(text.trim());
    final numberMatch = numberRegex.firstMatch(text.trim());

    double amount = 1.0;
    String unit = 'g'; // 기본 단위 변경

    if (unitMatch != null) {
      amount = double.tryParse(unitMatch.group(1)!) ?? 1.0;
      unit = unitMatch.group(2)!.trim();
    } else if (numberMatch != null) {
      amount = double.tryParse(numberMatch.group(1)!) ?? 1.0;
      unit = 'g'; // 숫자만 있는 경우 기본 단위
    }

    // 재료명 추출 (숫자와 단위 부분 제거)
    var ingredientName = text.trim();

    if (unitMatch != null) {
      final fullMatch = unitMatch.group(0)!;
      ingredientName = text.replaceAll(fullMatch, '').trim();
    } else if (numberMatch != null && unitMatch == null) {
      final number = numberMatch.group(0)!;
      ingredientName = text.replaceAll(number, '').trim();
    }

    // 최종 정리
    ingredientName =
        ingredientName.replaceAll(RegExp(r'[^\w\s가-힣]'), '').trim();

    final unifiedIngredient =
        await parseIngredient(ingredientName, amount, unit);

    return IngredientParseResult(
      ingredient: unifiedIngredient,
      originalText: text,
      success: true,
    );
  }

  /// 복수 재료 텍스트 파싱
  Future<List<UnifiedIngredient>> parseMultipleIngredients(
      List<String> ingredientTexts) async {
    final results = <UnifiedIngredient>[];

    for (final text in ingredientTexts) {
      try {
        final result = await parseIngredientText(text);
        if (result.success && _isValidIngredient(result.ingredient)) {
          results.add(result.ingredient);
        }
      } catch (e) {
        print('Failed to parse ingredient: $text, error: $e');
        // 파싱 실패한 재료는 건너뜀
      }
    }

    return results;
  }

  /// 재료 유효성 검증
  bool _isValidIngredient(UnifiedIngredient ingredient) {
    // 최소한의 유효성 검사
    if (ingredient.name.length < 2) return false;
    if (ingredient.amount <= 0) return false;
    if (ingredient.properties?['confidence'] == 0.3) return false;

    // 의미 없는 이름 필터링
    const meaninglessNames = ['invalid', 'ingredient', 'test', ''];
    if (meaninglessNames.contains(ingredient.name.toLowerCase())) return false;

    return true;
  }
}

/// 단위 변환 정보
class UnitConversion {
  final double factor;
  final double toBase;
  final double fromBase;

  const UnitConversion({
    required this.factor,
    required this.toBase,
    required this.fromBase,
  });
}

/// 재료 파싱 결과
class IngredientParseResult {
  final UnifiedIngredient ingredient;
  final String originalText;
  final bool success;

  const IngredientParseResult({
    required this.ingredient,
    required this.originalText,
    required this.success,
  });
}
