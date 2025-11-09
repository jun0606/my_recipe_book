import 'package:flutter_test/flutter_test.dart';
import 'package:my_recipe_book/services/comment/multilingual_comment_analyzer.dart';
import 'package:my_recipe_book/services/comment/language_detector.dart';
import 'package:my_recipe_book/services/comment/keyword_dictionary.dart';

void main() {
  group('Multilingual Comment Analyzer Tests', () {
    late MultilingualCommentAnalyzer analyzer;

    setUp(() {
      analyzer = MultilingualCommentAnalyzer();
    });

    group('Language Detection Tests', () {
      test('Korean language detection', () async {
        final result = await analyzer.analyzeComment('냉장 발효 후 냉동 보관하세요');

        expect(result.detectedLanguage, 'ko');
        expect(result.languageConfidence['ko'], greaterThan(0.5));
      });

      test('English language detection', () async {
        final result = await analyzer.analyzeComment(
            'Refrigerate for cold fermentation, then freeze for storage');

        expect(result.detectedLanguage, 'en');
        expect(result.languageConfidence['en'], greaterThan(0.5));
      });

      test('Japanese language detection', () async {
        final result = await analyzer.analyzeComment('冷蔵発酵してから冷凍保存してください');

        expect(result.detectedLanguage, 'ja');
        expect(result.languageConfidence['ja'], greaterThan(0.5));
      });
    });

    group('Keyword Analysis Tests', () {
      test('Korean refrigeration keywords', () async {
        final result = await analyzer.analyzeComment('냉장고에서 4시간 발효하세요');

        expect(result.keywordMatches['refrigeration'], true);
        expect(result.topCategory, 'refrigeration');
        expect(result.extractedData['temperature'], 4.0);
      });

      test('Korean freezing keywords', () async {
        final result = await analyzer.analyzeComment('냉동고에 얼려서 보관하세요');

        expect(result.keywordMatches['freezing'], true);
        expect(result.extractedData['storage'], 'freezer');
      });

      test('English refrigeration keywords', () async {
        final result =
            await analyzer.analyzeComment('Keep in refrigerator for 12 hours');

        expect(result.keywordMatches['refrigeration'], true);
        expect(result.extractedData['time'], 12.0);
        expect(result.extractedData['timeUnit'], 'hours');
      });

      test('English freezing keywords', () async {
        final result =
            await analyzer.analyzeComment('Freeze at -18°C for up to 7 days');

        expect(result.keywordMatches['freezing'], true);
        expect(result.extractedData['temperature'], -18.0);
      });

      test('Japanese refrigeration keywords', () async {
        final result = await analyzer.analyzeComment('冷蔵庫で5時間冷やしてください');

        expect(result.keywordMatches['refrigeration'], true);
        expect(result.extractedData['time'], 5.0);
        expect(result.extractedData['timeUnit'], 'hours');
      });

      test('Japanese freezing keywords', () async {
        final result = await analyzer.analyzeComment('冷凍保存で1週間まで可能です');

        expect(result.keywordMatches['freezing'], true);
        expect(result.extractedData['time'], 1.0);
        expect(result.extractedData['timeUnit'], 'weeks');
      });
    });

    group('Temperature Extraction Tests', () {
      test('Korean temperature extraction', () async {
        final result = await analyzer.analyzeComment('4°C에서 발효하세요');

        expect(result.extractedData['temperature'], 4.0);
        expect(result.extractedData['temperatureUnit'], 'C');
      });

      test('Korean sub-zero temperature', () async {
        final result = await analyzer.analyzeComment('영하 18도에서 냉동하세요');

        expect(result.extractedData['temperature'], -18.0);
        expect(result.extractedData['temperatureUnit'], 'C');
      });

      test('English temperature extraction', () async {
        final result = await analyzer.analyzeComment('Store at 39°F');

        expect(result.extractedData['temperature'], 39.0);
        expect(result.extractedData['temperatureUnit'], 'F');
      });

      test('Japanese temperature extraction', () async {
        final result = await analyzer.analyzeComment('5℃で冷蔵してください');

        expect(result.extractedData['temperature'], 5.0);
        expect(result.extractedData['temperatureUnit'], 'C');
      });
    });

    group('Time Extraction Tests', () {
      test('Korean time extraction', () async {
        final result = await analyzer.analyzeComment('12시간 동안 발효하세요');

        expect(result.extractedData['time'], 12.0);
        expect(result.extractedData['timeUnit'], 'hours');
      });

      test('English time extraction', () async {
        final result = await analyzer.analyzeComment('Ferment for 2.5 hours');

        expect(result.extractedData['time'], 2.5);
        expect(result.extractedData['timeUnit'], 'hours');
      });

      test('Japanese time extraction', () async {
        final result = await analyzer.analyzeComment('30分間休ませてください');

        expect(result.extractedData['time'], 30.0);
        expect(result.extractedData['timeUnit'], 'minutes');
      });
    });

    group('Method Inference Tests', () {
      test('Korean cold retardation method', () async {
        final result = await analyzer.analyzeComment('냉장 발효를 진행하세요');

        expect(result.extractedData['method'], 'cold_retardation');
      });

      test('English freezer overnight method', () async {
        final result =
            await analyzer.analyzeComment('Use freezer for overnight storage');

        expect(result.extractedData['method'], 'freezer_overnight');
      });

      test('Japanese room temperature method', () async {
        final result = await analyzer.analyzeComment('室温で発酵させてください');

        expect(result.extractedData['method'], 'room_temperature');
      });
    });

    group('Confidence Calculation Tests', () {
      test('High confidence for clear instructions', () async {
        final result = await analyzer.analyzeComment('냉장고에서 4°C로 12시간 발효하세요');

        expect(result.confidence, greaterThan(0.8));
      });

      test('Medium confidence for partial information', () async {
        final result = await analyzer.analyzeComment('냉장 보관하세요');

        expect(result.confidence, greaterThan(0.5));
        expect(result.confidence, lessThan(0.8));
      });

      test('Low confidence for unclear instructions', () async {
        final result = await analyzer.analyzeComment('식혀서 보관');

        expect(result.confidence, lessThan(0.5));
      });
    });

    group('Recommendation Generation Tests', () {
      test('Korean recommendations for refrigeration', () async {
        final result = await analyzer.analyzeComment('냉장 발효하세요');

        expect(result.recommendations.length, greaterThan(0));
        expect(result.recommendations.first, contains('냉장 발효'));
        expect(result.recommendations.first, contains('4°C'));
      });

      test('English recommendations for freezing', () async {
        final result = await analyzer.analyzeComment('Freeze for storage');

        expect(result.recommendations.length, greaterThan(0));
        expect(result.recommendations.first, contains('freezer'));
        expect(result.recommendations.first, contains('-18°C'));
      });

      test('Japanese recommendations for low confidence', () async {
        final result = await analyzer.analyzeComment('保存');

        expect(result.recommendations.length, greaterThan(0));
        expect(result.recommendations.first, contains('信頼性'));
      });
    });

    group('Multiple Comments Analysis Tests', () {
      test('Analyze multiple comments in batch', () async {
        final comments = [
          '냉장 발효 후 냉동 보관하세요',
          'Refrigerate for 12 hours',
          '冷蔵庫で保存してください'
        ];

        final results = await analyzer.analyzeMultipleComments(comments);

        expect(results.length, 3);
        expect(results[0].detectedLanguage, 'ko');
        expect(results[1].detectedLanguage, 'en');
        expect(results[2].detectedLanguage, 'ja');
      });
    });

    group('Statistics Generation Tests', () {
      test('Generate comprehensive statistics', () async {
        final results = await analyzer.analyzeMultipleComments(
            ['냉장 발효하세요', 'Freeze storage', '冷蔵保存', 'Keep in fridge']);

        final stats = analyzer.generateStatistics(results);

        expect(stats['totalComments'], 4);
        expect(stats['languageDistribution'], isNotEmpty);
        expect(stats['categoryDistribution'], isNotEmpty);
        expect(stats['confidenceDistribution'], isNotEmpty);
        expect(stats['averageConfidence'], isNotNull);
      });
    });

    group('Edge Cases Tests', () {
      test('Empty comment handling', () async {
        final result = await analyzer.analyzeComment('');

        expect(result.detectedLanguage, 'en');
        expect(result.confidence, 0.0);
      });

      test('Mixed language handling', () async {
        final result = await analyzer.analyzeComment('냉장 refrigerator 冷蔵');

        expect(result.detectedLanguage, isNotNull);
        expect(result.confidence, greaterThan(0.0));
      });

      test('Forced language override', () async {
        final result = await analyzer.analyzeComment('Store in fridge',
            forcedLanguage: 'ko');

        expect(result.detectedLanguage, 'ko'); // 강제 설정된 언어
      });

      test('Special characters and numbers', () async {
        final result = await analyzer.analyzeComment('4°C에서 12시간 냉장!');

        expect(result.extractedData['temperature'], 4.0);
        expect(result.extractedData['time'], 12.0);
        expect(result.keywordMatches['refrigeration'], true);
      });
    });

    group('Integration Tests', () {
      test('Complete workflow: Korean to English to Japanese', () async {
        // Korean
        final koResult = await analyzer.analyzeComment('냉장고에서 4시간 발효하세요');
        expect(koResult.detectedLanguage, 'ko');
        expect(koResult.keywordMatches['refrigeration'], true);

        // English
        final enResult =
            await analyzer.analyzeComment('Refrigerate for 4 hours');
        expect(enResult.detectedLanguage, 'en');
        expect(enResult.keywordMatches['refrigeration'], true);

        // Japanese
        final jaResult = await analyzer.analyzeComment('冷蔵庫で4時間発酵してください');
        expect(jaResult.detectedLanguage, 'ja');
        expect(jaResult.keywordMatches['refrigeration'], true);

        // All should extract similar temperature and time
        expect(koResult.extractedData['time'], 4.0);
        expect(enResult.extractedData['time'], 4.0);
        expect(jaResult.extractedData['time'], 4.0);
      });

      test('Cross-language consistency', () async {
        final testCases = [
          ('냉장 발효', 'ko', 'cold_retardation'),
          ('cold fermentation', 'en', 'cold_retardation'),
          ('冷蔵発酵', 'ja', 'cold_retardation'),
        ];

        for (final testCase in testCases) {
          final result = await analyzer.analyzeComment(testCase.$1,
              forcedLanguage: testCase.$2);
          expect(result.extractedData['method'], testCase.$3,
              reason: '${testCase.$1} should extract ${testCase.$3}');
        }
      });
    });
  });

  group('Language Detector Tests', () {
    late LanguageDetector detector;

    setUp(() {
      detector = LanguageDetector();
    });

    test('Korean character detection', () {
      expect(detector.detectLanguage('냉장고'), 'ko');
      expect(detector.detectLanguage('한국어 텍스트'), 'ko');
    });

    test('English character detection', () {
      expect(detector.detectLanguage('refrigerator'), 'en');
      expect(detector.detectLanguage('English text'), 'en');
    });

    test('Japanese character detection', () {
      expect(detector.detectLanguage('冷蔵庫'), 'ja');
      expect(detector.detectLanguage('日本語テキスト'), 'ja');
    });

    test('Mixed language detection', () {
      final mixed = detector.isMixedLanguage('냉장 refrigerator 冷蔵');
      expect(mixed, true);
    });

    test('Language confidence calculation', () {
      final confidence = detector.calculateLanguageConfidence('냉장고에서 4시간');
      expect(confidence['ko'], greaterThan(0.5));
      expect(confidence['en'], lessThan(0.3));
      expect(confidence['ja'], lessThan(0.3));
    });
  });

  group('Keyword Dictionary Tests', () {
    late KeywordDictionary dictionary;

    setUp(() {
      dictionary = KeywordDictionary();
    });

    test('Supported languages', () {
      expect(dictionary.supportedLanguages, contains('ko'));
      expect(dictionary.supportedLanguages, contains('en'));
      expect(dictionary.supportedLanguages, contains('ja'));
    });

    test('Categories availability', () {
      expect(dictionary.categories, isNotEmpty);
      expect(dictionary.categories, contains('refrigeration'));
      expect(dictionary.categories, contains('freezing'));
      expect(dictionary.categories, contains('temperature'));
    });

    test('Korean keyword matching', () {
      expect(dictionary.containsKeyword('ko', 'refrigeration', '냉장고'), true);
      expect(dictionary.containsKeyword('ko', 'freezing', '냉동'), true);
      expect(dictionary.containsKeyword('ko', 'temperature', '온도'), true);
    });

    test('English keyword matching', () {
      expect(dictionary.containsKeyword('en', 'refrigeration', 'refrigerator'),
          true);
      expect(dictionary.containsKeyword('en', 'freezing', 'freezer'), true);
      expect(dictionary.containsKeyword('en', 'temperature', 'celsius'), true);
    });

    test('Japanese keyword matching', () {
      expect(dictionary.containsKeyword('ja', 'refrigeration', '冷蔵庫'), true);
      expect(dictionary.containsKeyword('ja', 'freezing', '冷凍'), true);
      expect(dictionary.containsKeyword('ja', 'temperature', '温度'), true);
    });

    test('Keyword scoring', () {
      final scores = dictionary.calculateKeywordScores('ko', '냉장고에서 4시간 냉동');
      expect(scores['refrigeration'], greaterThan(0));
      expect(scores['freezing'], greaterThan(0));
    });

    test('Top category detection', () {
      final topCategory = dictionary.findTopCategory('ko', '냉장고에 넣어서 보관하세요');
      expect(topCategory, 'refrigeration');
    });

    test('Statistics generation', () {
      final stats = dictionary.getStatistics();
      expect(stats['ko'], isNotNull);
      expect(stats['en'], isNotNull);
      expect(stats['ja'], isNotNull);
      expect(stats['ko']!['refrigeration'], greaterThan(0));
    });
  });
}
