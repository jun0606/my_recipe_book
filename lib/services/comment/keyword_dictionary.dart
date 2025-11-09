/// 다국어 키워드 사전
class KeywordDictionary {
  static final KeywordDictionary _instance = KeywordDictionary._internal();
  factory KeywordDictionary() => _instance;
  KeywordDictionary._internal();

  /// 다국어 키워드 사전
  static const Map<String, Map<String, List<String>>> _multilingualKeywords = {
    'ko': {
      'refrigeration': [
        '냉장',
        '냉장고',
        '저온',
        '차가운',
        '콜드',
        '시원한',
        '아이스박스',
        '냉장실',
        '냉장 보관',
        '차갑게',
        '식혀서',
        '시원하게',
        '저온에서',
        '냉장 숙성',
        '냉장 발효',
        '차가운 곳',
        '저온 보관'
      ],
      'freezing': [
        '냉동',
        '냉동고',
        '얼리다',
        '얼린',
        '얼려서',
        '프리즈',
        '동결',
        '얼음',
        '아이스',
        '빙하',
        '얼려',
        '얼리는',
        '냉동실',
        '냉동 보관',
        '얼려서 보관',
        '냉동 상태',
        '얼음 정',
        '동결 보관',
        '급속 냉동'
      ],
      'temperature': [
        '온도',
        '도',
        '°C',
        '℃',
        '섭씨',
        '온도에서',
        '도에서',
        '온도로',
        '기온',
        '수온',
        '실온',
        '고온',
        '저온',
        '상온'
      ],
      'fermentation': [
        '발효',
        '숙성',
        '익히다',
        '부풀다',
        '효모',
        '이스트',
        '반죽',
        '빵',
        '반죽이',
        '반죽을',
        '반죽의',
        '반죽에서',
        '반죽으로'
      ],
      'storage': [
        '보관',
        '저장',
        '두다',
        '놓다',
        '담아두다',
        '넣어두다',
        '보존',
        '저장하다',
        '보관하다',
        '보관하는',
        '보관용'
      ],
    },
    'en': {
      'refrigeration': [
        'refrigerat',
        'refrigerator',
        'cold',
        'cool',
        'chill',
        'chilled',
        'icebox',
        'fridge',
        'cool down',
        'keep cold',
        'cold storage',
        'cold fermentation',
        'cold retard',
        'cold proof',
        'cold proofing',
        'cold rise',
        'cold bulk',
        'retard fermentation'
      ],
      'freezing': [
        'freez',
        'frozen',
        'freeze',
        'deep freeze',
        'ice',
        'frozen solid',
        'blast freeze',
        'quick freeze',
        'flash freeze',
        'ice up',
        'frozen storage',
        'freeze storage',
        'deep frozen',
        'hard freeze',
        'freeze down',
        'cold freeze',
        'super freeze'
      ],
      'temperature': [
        'temperature',
        'temp',
        '°C',
        '°F',
        'celsius',
        'fahrenheit',
        'degrees',
        'heat',
        'warm',
        'hot',
        'cool',
        'cold',
        'ambient',
        'room temperature',
        'oven temperature'
      ],
      'fermentation': [
        'ferment',
        'fermentation',
        'proof',
        'proofing',
        'rise',
        'rising',
        'bulk ferment',
        'bulk fermentation',
        'final proof',
        'retard',
        'cold retard',
        'dough',
        'bread',
        'yeast'
      ],
      'storage': [
        'store',
        'storage',
        'keep',
        'hold',
        'preserve',
        'save',
        'put away',
        'set aside',
        'stash',
        'stock',
        'deposit'
      ],
    },
    'ja': {
      'refrigeration': [
        '冷蔵',
        '冷やし',
        '冷たい',
        '冷やす',
        '冷蔵庫',
        '冷蔵室',
        'アイスボックス',
        'キル',
        'チル',
        '冷蔵保存',
        '冷蔵発酵',
        '冷蔵熟成',
        '冷やして',
        '冷たく',
        '冷やす',
        '冷やせ',
        '冷蔵で'
      ],
      'freezing': [
        '冷凍',
        '凍る',
        '凍った',
        '凍らす',
        '冷凍庫',
        '冷凍室',
        'アイス',
        '氷',
        'フリーズ',
        '急速冷凍',
        '瞬間冷凍',
        '冷凍保存',
        '冷凍状態',
        '氷結',
        '氷る',
        '凍結',
        '冷凍する',
        '冷凍した'
      ],
      'temperature': [
        '温度',
        '度',
        '°C',
        '℃',
        '摂氏',
        '華氏',
        '室温',
        '高温',
        '低温',
        '温度で',
        '度で',
        '温度を',
        '温度の',
        '気温',
        '水温'
      ],
      'fermentation': [
        '発酵',
        '熟成',
        'イースト',
        'パン生地',
        '生地',
        'パンを',
        '生地を',
        '生地の',
        '発酵する',
        '発酵させる',
        '膨らむ',
        '膨らませる'
      ],
      'storage': [
        '保存',
        '貯蔵',
        '置く',
        '入れておく',
        '保管',
        '貯蔵する',
        '保存する',
        '保つ',
        '保存状態',
        '保管状態'
      ],
    },
  };

  /// 언어별 키워드 가져오기
  Map<String, List<String>> getKeywords(String language) {
    return _multilingualKeywords[language] ?? _multilingualKeywords['en']!;
  }

  /// 특정 카테고리의 키워드 가져오기
  List<String> getKeywordsByCategory(String language, String category) {
    final languageKeywords = getKeywords(language);
    return languageKeywords[category] ?? [];
  }

  /// 키워드 존재 여부 확인
  bool containsKeyword(String language, String category, String text) {
    final keywords = getKeywordsByCategory(language, category);
    return keywords
        .any((keyword) => text.toLowerCase().contains(keyword.toLowerCase()));
  }

  /// 여러 카테고리에서 키워드 검색
  Map<String, bool> searchInAllCategories(String language, String text) {
    final result = <String, bool>{};
    final keywords = getKeywords(language);

    keywords.forEach((category, keywordList) {
      result[category] = keywordList
          .any((keyword) => text.toLowerCase().contains(keyword.toLowerCase()));
    });

    return result;
  }

  /// 키워드 매칭 점수 계산
  Map<String, int> calculateKeywordScores(String language, String text) {
    final result = <String, int>{};
    final keywords = getKeywords(language);

    keywords.forEach((category, keywordList) {
      int score = 0;
      for (final keyword in keywordList) {
        if (text.toLowerCase().contains(keyword.toLowerCase())) {
          score += keyword.length; // 키워드 길이에 비례한 점수
        }
      }
      result[category] = score;
    });

    return result;
  }

  /// 가장 높은 점수의 카테고리 찾기
  String findTopCategory(String language, String text) {
    final scores = calculateKeywordScores(language, text);
    var topCategory = 'unknown';
    var maxScore = 0;

    scores.forEach((category, score) {
      if (score > maxScore) {
        maxScore = score;
        topCategory = category;
      }
    });

    return topCategory;
  }

  /// 다국어 키워드 통합 검색
  Map<String, Map<String, dynamic>> searchAllLanguages(String text) {
    final result = <String, Map<String, dynamic>>{};

    _multilingualKeywords.forEach((language, keywords) {
      final searchResult = searchInAllCategories(language, text);
      final scores = calculateKeywordScores(language, text);

      result[language] = {
        'matches': searchResult,
        'scores': scores,
        'topCategory': findTopCategory(language, text),
        'totalScore': scores.values.reduce((a, b) => a + b),
      };
    });

    return result;
  }

  /// 언어별 가중치 계산 (언어 감지용)
  Map<String, double> calculateLanguageWeights(String text) {
    final result = <String, double>{};
    final allLanguagesResult = searchAllLanguages(text);

    allLanguagesResult.forEach((language, data) {
      final totalScore = data['totalScore'] as int;
      result[language] = totalScore.toDouble();
    });

    // 정규화
    final total = result.values.reduce((a, b) => a + b);
    if (total == 0) {
      return {'ko': 0.0, 'en': 1.0, 'ja': 0.0};
    }

    result.forEach((language, score) {
      result[language] = score / total;
    });

    return result;
  }

  /// 지원 언어 목록
  List<String> get supportedLanguages => _multilingualKeywords.keys.toList();

  /// 카테고리 목록
  List<String> get categories {
    if (_multilingualKeywords.isEmpty) return [];
    return _multilingualKeywords['en']!.keys.toList();
  }

  /// 특정 언어의 카테고리 수
  int getCategoryCount(String language) {
    return getKeywords(language).length;
  }

  /// 키워드 통계
  Map<String, Map<String, int>> getStatistics() {
    final stats = <String, Map<String, int>>{};

    _multilingualKeywords.forEach((language, keywords) {
      stats[language] = {};
      keywords.forEach((category, keywordList) {
        stats[language]![category] = keywordList.length;
      });
    });

    return stats;
  }
}
