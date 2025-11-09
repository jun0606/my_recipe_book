/// 언어 자동 감지 서비스
class LanguageDetector {
  static final LanguageDetector _instance = LanguageDetector._internal();
  factory LanguageDetector() => _instance;
  LanguageDetector._internal();

  /// 텍스트에서 언어 자동 감지
  String detectLanguage(String text) {
    if (text.trim().isEmpty) return 'en'; // 기본값

    // 한국어 감지 (한글)
    if (RegExp(r'[가-힣]').hasMatch(text)) {
      return 'ko';
    }

    // 일본어 감지 (히라가나, 카타나, 한자)
    if (RegExp(r'[\u3040-\u309f\u30a0-\u30ff\u4e00-\u9faf]').hasMatch(text)) {
      return 'ja';
    }

    // 영어 감지 (알파벳)
    if (RegExp(r'[a-zA-Z]').hasMatch(text)) {
      return 'en';
    }

    return 'en'; // 기본값
  }

  /// 혼합 언어 여부 확인
  bool isMixedLanguage(String text) {
    final Set<String> languages = {};

    if (RegExp(r'[가-힣]').hasMatch(text)) languages.add('ko');
    if (RegExp(r'[\u3040-\u309f\u30a0-\u30ff\u4e00-\u9faf]').hasMatch(text))
      languages.add('ja');
    if (RegExp(r'[a-zA-Z]').hasMatch(text)) languages.add('en');

    return languages.length > 1;
  }

  /// 언어별 신뢰도 점수 계산
  Map<String, double> calculateLanguageConfidence(String text) {
    final Map<String, int> scores = {'ko': 0, 'en': 0, 'ja': 0};

    // 한국어 점수 계산
    final koreanChars = RegExp(r'[가-힣]').allMatches(text).length;
    scores['ko'] = koreanChars * 2;

    // 일본어 점수 계산
    final japaneseChars = RegExp(r'[\u3040-\u309f\u30a0-\u30ff\u4e00-\u9faf]')
        .allMatches(text)
        .length;
    scores['ja'] = japaneseChars * 2;

    // 영어 점수 계산
    final englishChars = RegExp(r'[a-zA-Z]').allMatches(text).length;
    scores['en'] = englishChars;

    // 총 점수로 정규화
    final total = scores.values.reduce((a, b) => a + b);
    if (total == 0) return {'ko': 0.0, 'en': 1.0, 'ja': 0.0};

    return {
      'ko': scores['ko']! / total,
      'en': scores['en']! / total,
      'ja': scores['ja']! / total,
    };
  }

  /// 언어 코드 변환 (전체 이름 ↔ 코드)
  String getLanguageName(String code) {
    const names = {
      'ko': '한국어',
      'en': 'English',
      'ja': '日本語',
    };
    return names[code] ?? 'Unknown';
  }

  String getLanguageCode(String name) {
    const codes = {
      '한국어': 'ko',
      'English': 'en',
      '日本語': 'ja',
    };
    return codes[name] ?? 'en';
  }
}
