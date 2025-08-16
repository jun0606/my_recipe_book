/// 텍스트 기반 목표 파싱 엔진
/// 자연어 입력을 RecipeTarget으로 변환합니다.

import '../models/recipe_target.dart';

class TextBasedTargetParser {
  /// 텍스트를 분석하여 RecipeTarget 생성
  static RecipeTarget parseTextToTarget(String inputText) {
    try {
      final normalizedText = _normalizeText(inputText);
      
      // 기본 목표 생성
      RecipeTarget target = RecipeTarget.basicBread();
      
      // 베이킹 타입 감지
      final bakingType = _detectBakingType(normalizedText);
      target = target.copyWith(targetBakingType: bakingType);
      
      // 특성별 분석
      final textureAnalysis = _analyzeTextureKeywords(normalizedText);
      final flavorAnalysis = _analyzeFlavorKeywords(normalizedText);
      final appearanceAnalysis = _analyzeAppearanceKeywords(normalizedText);
      
      // 목표 업데이트
      target = target.copyWith(
        moistureTarget: textureAnalysis['moisture'] ?? target.moistureTarget,
        chewinessTarget: textureAnalysis['chewiness'] ?? target.chewinessTarget,
        softnessTarget: textureAnalysis['softness'] ?? target.softnessTarget,
        crispinessTarget: textureAnalysis['crispiness'] ?? target.crispinessTarget,
        sweetnessTarget: flavorAnalysis['sweetness'] ?? target.sweetnessTarget,
        richnessTarget: flavorAnalysis['richness'] ?? target.richnessTarget,
        saltinessTarget: flavorAnalysis['saltiness'] ?? target.saltinessTarget,
        crustColorTarget: appearanceAnalysis['crustColor'] ?? target.crustColorTarget,
        heightTarget: appearanceAnalysis['height'] ?? target.heightTarget,
        porosityTarget: appearanceAnalysis['porosity'] ?? target.porosityTarget,
      );
      
      return target;
    } catch (e) {
      print('텍스트 파싱 중 오류: $e');
      return RecipeTarget.basicBread();
    }
  }

  /// 텍스트 정규화
  static String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s가-힣]'), ' ') // 특수문자 제거
        .replaceAll(RegExp(r'\s+'), ' ') // 연속 공백 제거
        .trim();
  }

  /// 베이킹 타입 감지
  static String _detectBakingType(String text) {
    final bakingTypeKeywords = {
      // 식빵류
      '식빵': '식빵',
      '빵': '식빵',
      '브레드': '식빵',
      'bread': '식빵',
      '토스트': '식빵',
      
      // 케이크류
      '케이크': '케이크',
      'cake': '케이크',
      '스펀지': '스펀지케이크',
      '시폰': '시폰케이크',
      
      // 쿠키류
      '쿠키': '쿠키',
      'cookie': '쿠키',
      '비스킷': '비스킷',
      
      // 브리오슈/단빵류
      '브리오슈': '브리오슈',
      'brioche': '브리오슈',
      '단빵': '단빵',
      '버터빵': '브리오슈',
      
      // 하드브레드류
      '바게트': '바게트',
      'baguette': '바게트',
      '치아바타': '치아바타',
      'ciabatta': '치아바타',
      '사워도우': '사워도우',
      'sourdough': '사워도우',
      
      // 페이스트리류
      '크루아상': '크루아상',
      'croissant': '크루아상',
      '데니쉬': '데니쉬',
      'danish': '데니쉬',
    };

    for (final entry in bakingTypeKeywords.entries) {
      if (text.contains(entry.key)) {
        return entry.value;
      }
    }

    return '식빵'; // 기본값
  }

  /// 식감 키워드 분석
  static Map<String, double> _analyzeTextureKeywords(String text) {
    var analysis = <String, double>{};
    
    // 촉촉함 키워드
    final moistureKeywords = {
      '촉촉한': 0.8,
      '촉촉하고': 0.8,
      '촉촉': 0.8,
      '부드럽고촉촉한': 0.9,
      '매우촉촉한': 1.0,
      '아주촉촉한': 1.0,
      '조금촉촉한': 0.6,
      '약간촉촉한': 0.6,
      'moist': 0.8,
      'very moist': 1.0,
    };

    // 쫄깃함 키워드
    final chewinessKeywords = {
      '쫄깃한': 0.8,
      '쫄깃하고': 0.8,
      '쫄깃': 0.8,
      '탄력있는': 0.7,
      '탄력': 0.7,
      '매우쫄깃한': 1.0,
      '아주쫄깃한': 1.0,
      '조금쫄깃한': 0.6,
      'chewy': 0.8,
      'elastic': 0.7,
    };

    // 부드러움 키워드
    final softnessKeywords = {
      '부드러운': 0.8,
      '부드럽고': 0.8,
      '부드러움': 0.8,
      '폭신한': 0.9,
      '폭신폭신한': 0.9,
      '매우부드러운': 1.0,
      '아주부드러운': 1.0,
      '조금부드러운': 0.6,
      'soft': 0.8,
      'fluffy': 0.9,
      'tender': 0.8,
    };

    // 바삭함 키워드
    final crispinessKeywords = {
      '바삭한': 0.8,
      '바삭하고': 0.8,
      '바삭': 0.8,
      '크리스피': 0.8,
      '바삭바삭한': 0.9,
      '매우바삭한': 1.0,
      '아주바삭한': 1.0,
      '조금바삭한': 0.6,
      'crispy': 0.8,
      'crunchy': 0.8,
      'crisp': 0.8,
    };

    // 키워드 매칭 및 점수 계산
    analysis['moisture'] = _findBestMatch(text, moistureKeywords) ?? 0.0;
    analysis['chewiness'] = _findBestMatch(text, chewinessKeywords) ?? 0.0;
    analysis['softness'] = _findBestMatch(text, softnessKeywords) ?? 0.0;
    analysis['crispiness'] = _findBestMatch(text, crispinessKeywords) ?? 0.0;

    // 부정 표현 처리
    analysis = _handleNegativeExpressions(text, analysis);

    return analysis;
  }

  /// 풍미 키워드 분석
  static Map<String, double> _analyzeFlavorKeywords(String text) {
    final analysis = <String, double>{};
    
    // 단맛 키워드
    final sweetnessKeywords = {
      '달콤한': 0.8,
      '달콤하고': 0.8,
      '달콤': 0.8,
      '단맛': 0.7,
      '달달한': 0.8,
      '매우달콤한': 1.0,
      '아주달콤한': 1.0,
      '조금달콤한': 0.6,
      '약간달콤한': 0.6,
      'sweet': 0.8,
      'very sweet': 1.0,
    };

    // 고소함 키워드
    final richnessKeywords = {
      '고소한': 0.8,
      '고소하고': 0.8,
      '고소': 0.8,
      '풍부한': 0.8,
      '진한': 0.8,
      '버터향': 0.9,
      '매우고소한': 1.0,
      '아주고소한': 1.0,
      '조금고소한': 0.6,
      'rich': 0.8,
      'buttery': 0.9,
      'nutty': 0.7,
    };

    // 짠맛 키워드
    final saltinessKeywords = {
      '짭짤한': 0.8,
      '짭짤하고': 0.8,
      '짭짤': 0.8,
      '짠맛': 0.7,
      '소금맛': 0.7,
      '매우짭짤한': 1.0,
      '아주짭짤한': 1.0,
      '조금짭짤한': 0.6,
      'salty': 0.8,
      'savory': 0.7,
    };

    // 키워드 매칭
    analysis['sweetness'] = _findBestMatch(text, sweetnessKeywords) ?? 0.0;
    analysis['richness'] = _findBestMatch(text, richnessKeywords) ?? 0.0;
    analysis['saltiness'] = _findBestMatch(text, saltinessKeywords) ?? 0.0;

    return analysis;
  }

  /// 외관 키워드 분석
  static Map<String, dynamic> _analyzeAppearanceKeywords(String text) {
    final analysis = <String, dynamic>{};
    
    // 크러스트 색상 키워드
    final crustColorKeywords = {
      '연한': CrustColorTarget.lightBrown,
      '연한색': CrustColorTarget.lightBrown,
      '연한갈색': CrustColorTarget.lightBrown,
      '황금색': CrustColorTarget.golden,
      '황금': CrustColorTarget.golden,
      '골든': CrustColorTarget.golden,
      '진한': CrustColorTarget.darkBrown,
      '진한갈색': CrustColorTarget.darkBrown,
      '진한색': CrustColorTarget.darkBrown,
      '어두운': CrustColorTarget.darkBrown,
      '매우진한': CrustColorTarget.veryDark,
      'light': CrustColorTarget.lightBrown,
      'golden': CrustColorTarget.golden,
      'dark': CrustColorTarget.darkBrown,
    };

    // 높이 키워드
    final heightKeywords = {
      '높은': 0.9,
      '높이': 0.9,
      '부풀어오른': 0.9,
      '부푼': 0.9,
      '매우높은': 1.0,
      '아주높은': 1.0,
      '조금높은': 0.7,
      '낮은': 0.3,
      '납작한': 0.2,
      'tall': 0.9,
      'high': 0.9,
      'risen': 0.9,
      'flat': 0.2,
    };

    // 기공 키워드
    final porosityKeywords = {
      '구멍많은': 0.9,
      '기공많은': 0.9,
      '스펀지같은': 0.9,
      '촘촘한': 0.3,
      '조밀한': 0.3,
      '매우구멍많은': 1.0,
      '아주구멍많은': 1.0,
      'airy': 0.9,
      'holey': 0.9,
      'dense': 0.3,
      'tight': 0.3,
    };

    // 키워드 매칭
    for (final entry in crustColorKeywords.entries) {
      if (text.contains(entry.key)) {
        analysis['crustColor'] = entry.value;
        break;
      }
    }

    analysis['height'] = _findBestMatch(text, heightKeywords);
    analysis['porosity'] = _findBestMatch(text, porosityKeywords);

    return analysis;
  }

  /// 최적 매칭 찾기
  static double? _findBestMatch(String text, Map<String, double> keywords) {
    double? bestScore;
    String? bestMatch;

    for (final entry in keywords.entries) {
      if (text.contains(entry.key)) {
        if (bestMatch == null || entry.key.length > bestMatch.length) {
          bestMatch = entry.key;
          bestScore = entry.value;
        }
      }
    }

    return bestScore;
  }

  /// 부정 표현 처리
  static Map<String, double> _handleNegativeExpressions(
    String text, 
    Map<String, double> analysis
  ) {
    final negativePatterns = [
      '않은', '안', '없는', '못한', '지않은', 'not', 'non', 'un'
    ];

    final result = Map<String, double>.from(analysis);

    for (final pattern in negativePatterns) {
      if (text.contains(pattern)) {
        // 부정 표현 근처의 특성을 찾아서 반대로 설정
        if (text.contains('$pattern 촉촉') || text.contains('촉촉$pattern')) {
          result['moisture'] = 0.3;
        }
        if (text.contains('$pattern 쫄깃') || text.contains('쫄깃$pattern')) {
          result['chewiness'] = 0.3;
        }
        if (text.contains('$pattern 부드러') || text.contains('부드러$pattern')) {
          result['softness'] = 0.3;
        }
        if (text.contains('$pattern 바삭') || text.contains('바삭$pattern')) {
          result['crispiness'] = 0.3;
        }
        if (text.contains('$pattern 달콤') || text.contains('달콤$pattern')) {
          result['sweetness'] = 0.3;
        }
      }
    }

    return result;
  }

  /// 텍스트에서 추천 프리셋 찾기
  static RecipeTarget? findRecommendedPreset(String inputText) {
    final normalizedText = _normalizeText(inputText);
    
    // 프리셋 키워드 매칭
    final presetKeywords = {
      '기본': RecipeTarget.basicBread(),
      '일반': RecipeTarget.basicBread(),
      '표준': RecipeTarget.basicBread(),
      '촉촉': RecipeTarget.moistBread(),
      '쫄깃': RecipeTarget.chewyBread(),
      '바삭': RecipeTarget.crispyBread(),
      '단빵': RecipeTarget.sweetBread(),
      '브리오슈': RecipeTarget.sweetBread(),
      '달콤': RecipeTarget.sweetBread(),
    };

    for (final entry in presetKeywords.entries) {
      if (normalizedText.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  /// 텍스트 분석 결과 요약
  static Map<String, dynamic> analyzeTextSummary(String inputText) {
    final target = parseTextToTarget(inputText);
    final recommendedPreset = findRecommendedPreset(inputText);
    
    return {
      'parsedTarget': target,
      'recommendedPreset': recommendedPreset,
      'detectedBakingType': _detectBakingType(_normalizeText(inputText)),
      'confidence': _calculateParsingConfidence(inputText),
      'suggestions': _generateSuggestions(inputText),
    };
  }

  /// 파싱 신뢰도 계산
  static double _calculateParsingConfidence(String inputText) {
    final normalizedText = _normalizeText(inputText);
    int matchedKeywords = 0;
    int totalKeywords = 0;

    // 주요 키워드 카테고리별 매칭 확인
    final keywordCategories = [
      ['촉촉', '쫄깃', '부드러', '바삭'], // 식감
      ['달콤', '고소', '짭짤'], // 풍미
      ['식빵', '케이크', '쿠키', '브리오슈'], // 타입
    ];

    for (final category in keywordCategories) {
      totalKeywords += category.length;
      for (final keyword in category) {
        if (normalizedText.contains(keyword)) {
          matchedKeywords++;
        }
      }
    }

    return totalKeywords > 0 ? matchedKeywords / totalKeywords : 0.0;
  }

  /// 제안 생성
  static List<String> _generateSuggestions(String inputText) {
    final suggestions = <String>[];
    final normalizedText = _normalizeText(inputText);

    if (normalizedText.length < 5) {
      suggestions.add('더 구체적인 설명을 입력해보세요. 예: "촉촉하고 부드러운 식빵"');
    }

    if (!normalizedText.contains(RegExp(r'촉촉|쫄깃|부드러|바삭'))) {
      suggestions.add('원하는 식감을 추가해보세요. 예: 촉촉한, 쫄깃한, 부드러운, 바삭한');
    }

    if (!normalizedText.contains(RegExp(r'식빵|케이크|쿠키|빵'))) {
      suggestions.add('베이킹 타입을 명시해보세요. 예: 식빵, 케이크, 쿠키');
    }

    if (suggestions.isEmpty) {
      suggestions.add('훌륭한 설명입니다! 레시피를 생성해보세요.');
    }

    return suggestions;
  }
}