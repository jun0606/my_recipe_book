import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/unified_ingredient.dart';
import '../../../features/chef/module/bread/types/unified_types.dart'
    hide UnifiedIngredient;
import 'ingredient_parser.dart';

/// 다국어 지원을 위한 고급 재료 파싱 서비스
class MultilingualIngredientParser {
  static final MultilingualIngredientParser _instance =
      MultilingualIngredientParser._internal();
  factory MultilingualIngredientParser() => _instance;
  MultilingualIngredientParser._internal();

  // 다국어 재료 데이터베이스
  Map<String, MultilingualIngredientType> _multilingualDatabase = {};
  Map<String, UnitConversion> _unitConversions = {};

  // 언어 설정
  String _primaryLanguage = 'ko'; // 기본 언어: 한국어
  List<String> _supportedLanguages = ['ko', 'en', 'ja'];

  bool _isInitialized = false;

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 다국어 데이터베이스 로드
      await _loadMultilingualDatabase();
      // 단위 변환 데이터 로드
      await _loadUnitConversions();

      _isInitialized = true;
    } catch (e) {
      print('MultilingualIngredientParser initialization failed: $e');
      // 기본 데이터로 초기화
      _initializeDefaultMultilingualData();
    }
  }

  /// 다국어 데이터베이스 로드
  Future<void> _loadMultilingualDatabase() async {
    try {
      final jsonString = await rootBundle
          .loadString('assets/data/multilingual_ingredients.json');
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      _multilingualDatabase = {};
      data.forEach((key, value) {
        _multilingualDatabase[key] =
            MultilingualIngredientType.fromJson(value as Map<String, dynamic>);
      });
    } catch (e) {
      print('Failed to load multilingual database: $e');
      _initializeDefaultMultilingualData();
    }
  }

  /// 기본 다국어 데이터 초기화
  void _initializeDefaultMultilingualData() {
    _multilingualDatabase = {
      // 밀가루 계열
      'flour': MultilingualIngredientType(
        baseName: 'flour',
        category: IngredientCategory.grain,
        density: 0.55,
        translations: {
          'ko': ['밀가루', '밀가루', '중력분', '박력분', '강력분', '통밀가루', '아몬드가루', '코코아가루'],
          'en': [
            'flour',
            'wheat flour',
            'all-purpose flour',
            'cake flour',
            'bread flour',
            'whole wheat flour',
            'almond flour',
            'cocoa powder'
          ],
          'ja': ['小麦粉', '薄力粉', '強力粉', '全粒粉', 'アーモンド粉', 'ココアパウダー'],
        },
        properties: {'gluten': 'high', 'usage': 'baking'},
      ),

      // 효모 계열
      'yeast': MultilingualIngredientType(
        baseName: 'yeast',
        category: IngredientCategory.leavening,
        density: 0.3,
        translations: {
          'ko': ['이스트', '인스턴트 드라이 이스트', '생이스트', '건조효모', '압축효모'],
          'en': [
            'yeast',
            'instant yeast',
            'dry yeast',
            'fresh yeast',
            'active dry yeast',
            'compressed yeast'
          ],
          'ja': ['イースト', 'インスタントドライイースト', '生イースト', '乾燥酵母', '圧縮酵母'],
        },
        properties: {'type': 'yeast', 'strength': 'high'},
      ),

      // 설탕 계열
      'sugar': MultilingualIngredientType(
        baseName: 'sugar',
        category: IngredientCategory.sweetener,
        density: 0.85,
        translations: {
          'ko': ['설탕', '흰설탕', '백설탕', '흑설탕', '갈색설탕', '분말설탕', '바닐라설탕'],
          'en': [
            'sugar',
            'white sugar',
            'brown sugar',
            'powdered sugar',
            'granulated sugar',
            'vanilla sugar'
          ],
          'ja': ['砂糖', '白砂糖', '黒糖', '粉糖', 'グラニュー糖', 'バニラシュガー'],
        },
        properties: {'type': 'refined', 'crystallization': 'fast'},
      ),

      // 버터 계열
      'butter': MultilingualIngredientType(
        baseName: 'butter',
        category: IngredientCategory.fat,
        density: 0.95,
        translations: {
          'ko': ['버터', '무염버터', '유화버터', '마가린', '식물성기름', '올리브오일'],
          'en': [
            'butter',
            'unsalted butter',
            'salted butter',
            'margarine',
            'vegetable oil',
            'olive oil'
          ],
          'ja': ['バター', '無塩バター', '有塩バター', 'マーガリン', '植物油', 'オリーブオイル'],
        },
        properties: {'type': 'dairy', 'smoke_point': 'medium'},
      ),

      // 물 계열
      'water': MultilingualIngredientType(
        baseName: 'water',
        category: IngredientCategory.liquid,
        density: 1.0,
        translations: {
          'ko': ['물', '정수물', '뜨거운물', '차가운물', '미지근한물'],
          'en': [
            'water',
            'filtered water',
            'hot water',
            'cold water',
            'warm water'
          ],
          'ja': ['水', '浄水', '熱水', '冷水', 'ぬるま湯'],
        },
        properties: {'type': 'water', 'ph': 'neutral'},
      ),

      // 계란 계열
      'egg': MultilingualIngredientType(
        baseName: 'egg',
        category: IngredientCategory.protein,
        density: 1.0,
        translations: {
          'ko': ['계란', '달걀', '란', '계란노른자', '계란흰자', '전란'],
          'en': ['egg', 'eggs', 'egg yolk', 'egg white', 'whole egg'],
          'ja': ['卵', '鶏卵', '卵黄', '卵白', '全卵'],
        },
        properties: {'type': 'egg', 'size': 'large'},
      ),

      // 소금 계열
      'salt': MultilingualIngredientType(
        baseName: 'salt',
        category: IngredientCategory.other,
        density: 2.17,
        translations: {
          'ko': ['소금', '바다소금', '암염', '히말라야핑크소금', '셀러리스소금'],
          'en': [
            'salt',
            'sea salt',
            'rock salt',
            'himalayan pink salt',
            'celery salt'
          ],
          'ja': ['塩', '海塩', '岩塩', 'ヒマラヤ岩塩', 'セロリソルト'],
        },
        properties: {'type': 'salt', 'iodine': 'yes'},
      ),

      // 우유 계열
      'milk': MultilingualIngredientType(
        baseName: 'milk',
        category: IngredientCategory.liquid,
        density: 1.03,
        translations: {
          'ko': ['우유', '전지분유', '저지방우유', '무지방우유', '아몬드유', '두유'],
          'en': [
            'milk',
            'whole milk',
            'low-fat milk',
            'skim milk',
            'almond milk',
            'soy milk'
          ],
          'ja': ['牛乳', '全乳', '低脂肪乳', '無脂肪乳', 'アーモンドミルク', '豆乳'],
        },
        properties: {'type': 'dairy', 'fat_content': 'medium'},
      ),
    };
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

      // 개수 단위 (다국어 지원)
      '개': UnitConversion(factor: 1.0, toBase: 1.0, fromBase: 1.0),
      'piece': UnitConversion(factor: 1.0, toBase: 1.0, fromBase: 1.0),
      '個': UnitConversion(factor: 1.0, toBase: 1.0, fromBase: 1.0), // 일본어
      'slice': UnitConversion(factor: 1.0, toBase: 1.0, fromBase: 1.0),
    };
  }

  /// 다국어 재료 파싱
  Future<MultilingualParseResult> parseMultilingualIngredient(String text,
      {String? languageHint}) async {
    if (!_isInitialized) {
      await initialize();
    }

    // 언어 감지
    final detectedLanguage = languageHint ?? _detectLanguage(text);

    // 재료명과 수량/단위 추출
    final extracted = _extractIngredientInfo(text, detectedLanguage);
    if (extracted == null) {
      return MultilingualParseResult.failure(
        originalText: text,
        error: 'Unable to parse ingredient information',
      );
    }

    // 다국어 매칭
    final ingredientType = _findBestMatch(extracted.name, detectedLanguage);

    // 단위 변환
    final baseAmount =
        _convertToBaseUnit(extracted.amount, extracted.unit, ingredientType);

    final unifiedIngredient = UnifiedIngredient(
      name: ingredientType.getNameInLanguage(detectedLanguage),
      amount: baseAmount,
      unit: 'g',
      properties: {
        ...ingredientType.properties,
        'type': ingredientType.category.toString(),
        'originalName': extracted.name,
        'originalAmount': extracted.amount,
        'originalUnit': extracted.unit,
        'detectedLanguage': detectedLanguage,
        'baseName': ingredientType.baseName,
        'confidence': _calculateConfidence(
            extracted.name, ingredientType, detectedLanguage),
      },
    );

    return MultilingualParseResult.success(
      ingredient: unifiedIngredient,
      originalText: text,
      detectedLanguage: detectedLanguage,
      confidence: _calculateConfidence(
          extracted.name, ingredientType, detectedLanguage),
    );
  }

  /// 언어 감지
  String _detectLanguage(String text) {
    // 한글 감지
    if (RegExp(r'[가-힣]').hasMatch(text)) return 'ko';

    // 일본어 감지 (히라가나, 카타카나)
    if (RegExp(r'[\u3040-\u309f\u30a0-\u30ff]').hasMatch(text)) return 'ja';

    // 기본적으로 영어로 처리
    return 'en';
  }

  /// 재료 정보 추출
  ExtractedIngredientInfo? _extractIngredientInfo(
      String text, String language) {
    // 언어별 정규표현식 패턴
    final patterns = {
      'ko': {
        'number': RegExp(r'(\d+(?:\.\d+)?)'),
        'unit': RegExp(r'(\d+(?:\.\d+)?)\s*([^\d\s가-힣]+)'),
      },
      'en': {
        'number': RegExp(r'(\d+(?:\.\d+)?)'),
        'unit': RegExp(r'(\d+(?:\.\d+)?)\s*([a-zA-Z]+)'),
      },
      'ja': {
        'number': RegExp(r'(\d+(?:\.\d+)?)'),
        'unit':
            RegExp(r'(\d+(?:\.\d+)?)\s*([^\d\s\u3040-\u309f\u30a0-\u30ff]+)'),
      },
    };

    final pattern = patterns[language] ?? patterns['en']!;
    final numberMatch = pattern['number']!.firstMatch(text);
    final unitMatch = pattern['unit']!.firstMatch(text);

    double amount = 1.0;
    String unit = language == 'ko' ? '개' : 'piece';

    if (unitMatch != null) {
      amount = double.tryParse(unitMatch.group(1)!) ?? 1.0;
      unit = unitMatch.group(2)!.trim();
    } else if (numberMatch != null) {
      amount = double.tryParse(numberMatch.group(1)!) ?? 1.0;
    }

    // 재료명 추출
    var ingredientName = text;

    if (unitMatch != null) {
      final fullMatch = unitMatch.group(0)!;
      ingredientName = text.replaceAll(fullMatch, '').trim();
    } else if (numberMatch != null) {
      final number = numberMatch.group(0)!;
      ingredientName = text.replaceAll(number, '').trim();
    }

    // 언어별 특수문자 처리
    final cleanPatterns = {
      'ko': RegExp(r'[^\w\s가-힣]'),
      'en': RegExp(r'[^\w\s]'),
      'ja': RegExp(r'[^\w\s\u3040-\u309f\u30a0-\u30ff]'),
    };

    ingredientName =
        ingredientName.replaceAll(cleanPatterns[language]!, '').trim();

    if (ingredientName.isEmpty) return null;

    return ExtractedIngredientInfo(
      name: ingredientName,
      amount: amount,
      unit: unit,
    );
  }

  /// 최적 매칭 찾기
  MultilingualIngredientType _findBestMatch(String name, String language) {
    // 정확한 매칭 우선
    for (final type in _multilingualDatabase.values) {
      if (type.translations[language]?.contains(name) == true) {
        return type;
      }
    }

    // 부분 매칭
    for (final type in _multilingualDatabase.values) {
      final translations = type.translations[language] ?? [];
      for (final translation in translations) {
        if (name.contains(translation) || translation.contains(name)) {
          return type;
        }
      }
    }

    // 다른 언어에서 매칭 시도
    for (final type in _multilingualDatabase.values) {
      for (final langTranslations in type.translations.values) {
        for (final translation in langTranslations) {
          if (name.contains(translation) || translation.contains(name)) {
            return type;
          }
        }
      }
    }

    // 매칭 실패 시 기본 타입 반환
    return MultilingualIngredientType(
      baseName: name,
      category: IngredientCategory.other,
      density: 1.0,
      translations: {
        language: [name]
      },
      properties: {},
    );
  }

  /// 단위 변환
  double _convertToBaseUnit(
      double amount, String unit, MultilingualIngredientType type) {
    final normalizedUnit = unit.toLowerCase().trim();

    if (_unitConversions.containsKey(normalizedUnit)) {
      final conversion = _unitConversions[normalizedUnit]!;
      return amount * conversion.toBase;
    }

    // 부피 단위인 경우 밀도 고려
    if (_isVolumeUnit(normalizedUnit)) {
      final density = type.density;
      final baseVolume =
          amount * (_unitConversions[normalizedUnit]?.toBase ?? 1.0);
      return baseVolume * density;
    }

    return amount;
  }

  /// 부피 단위 확인
  bool _isVolumeUnit(String unit) {
    const volumeUnits = ['ml', 'l', 'cup', 'tbsp', 'tsp', 'fl oz', 'cc', 'dl'];
    return volumeUnits.contains(unit.toLowerCase());
  }

  /// 신뢰도 계산
  double _calculateConfidence(
      String name, MultilingualIngredientType type, String language) {
    // 정확한 매칭
    if (type.translations[language]?.contains(name) == true) {
      return 1.0;
    }

    // 부분 매칭
    final translations = type.translations[language] ?? [];
    for (final translation in translations) {
      if (name.contains(translation) || translation.contains(name)) {
        return 0.8;
      }
    }

    // 다른 언어 매칭
    for (final langTranslations in type.translations.values) {
      for (final translation in langTranslations) {
        if (name.contains(translation) || translation.contains(name)) {
          return 0.6;
        }
      }
    }

    // 추론 기반
    return 0.3;
  }

  /// 복수 재료 텍스트 파싱 (다국어 지원)
  Future<List<MultilingualParseResult>> parseMultipleMultilingualIngredients(
      List<String> ingredientTexts,
      {String? languageHint}) async {
    final results = <MultilingualParseResult>[];

    for (final text in ingredientTexts) {
      try {
        final result =
            await parseMultilingualIngredient(text, languageHint: languageHint);
        results.add(result);
      } catch (e) {
        results.add(MultilingualParseResult.failure(
          originalText: text,
          error: e.toString(),
        ));
      }
    }

    return results;
  }

  /// 언어 설정
  void setPrimaryLanguage(String language) {
    if (_supportedLanguages.contains(language)) {
      _primaryLanguage = language;
    }
  }

  /// 지원 언어 목록
  List<String> get supportedLanguages => List.unmodifiable(_supportedLanguages);
}

/// 다국어 재료 타입
class MultilingualIngredientType {
  final String baseName;
  final IngredientCategory category;
  final double density;
  final Map<String, List<String>> translations; // 언어별 번역 목록
  final Map<String, dynamic> properties;

  const MultilingualIngredientType({
    required this.baseName,
    required this.category,
    required this.density,
    required this.translations,
    required this.properties,
  });

  factory MultilingualIngredientType.fromJson(Map<String, dynamic> json) {
    return MultilingualIngredientType(
      baseName: json['baseName'] ?? '',
      category: IngredientCategory.values.firstWhere(
        (cat) => cat.toString().split('.').last == json['category'],
        orElse: () => IngredientCategory.other,
      ),
      density: json['density'] ?? 1.0,
      translations: Map<String, List<String>>.from(json['translations'] ?? {}),
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseName': baseName,
      'category': category.toString().split('.').last,
      'density': density,
      'translations': translations,
      'properties': properties,
    };
  }

  /// 특정 언어로 된 이름 반환
  String getNameInLanguage(String language) {
    final names = translations[language];
    if (names != null && names.isNotEmpty) {
      return names.first;
    }

    // 기본 언어로 폴백
    final fallbackNames = translations['en'];
    if (fallbackNames != null && fallbackNames.isNotEmpty) {
      return fallbackNames.first;
    }

    return baseName;
  }

  /// 모든 언어의 이름 목록 반환
  List<String> getAllNames() {
    final allNames = <String>[];
    for (final names in translations.values) {
      allNames.addAll(names);
    }
    return allNames;
  }
}

/// 추출된 재료 정보
class ExtractedIngredientInfo {
  final String name;
  final double amount;
  final String unit;

  const ExtractedIngredientInfo({
    required this.name,
    required this.amount,
    required this.unit,
  });
}

/// 다국어 파싱 결과
class MultilingualParseResult {
  final UnifiedIngredient? ingredient;
  final String originalText;
  final String? detectedLanguage;
  final double confidence;
  final bool success;
  final String? error;

  const MultilingualParseResult._({
    this.ingredient,
    required this.originalText,
    this.detectedLanguage,
    this.confidence = 0.0,
    required this.success,
    this.error,
  });

  factory MultilingualParseResult.success({
    required UnifiedIngredient ingredient,
    required String originalText,
    required String detectedLanguage,
    required double confidence,
  }) {
    return MultilingualParseResult._(
      ingredient: ingredient,
      originalText: originalText,
      detectedLanguage: detectedLanguage,
      confidence: confidence,
      success: true,
    );
  }

  factory MultilingualParseResult.failure({
    required String originalText,
    required String error,
  }) {
    return MultilingualParseResult._(
      originalText: originalText,
      success: false,
      error: error,
    );
  }
}
