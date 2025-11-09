import 'package:flutter_test/flutter_test.dart';
import 'package:my_recipe_book/models/advanced_sous_chef_models.dart';

void main() {
  group('IngredientMetadata 테스트', () {
    test('기본 생성자가 정상 동작해야 함', () {
      const metadata = IngredientMetadata(
        name: '강력분',
        properties: {'protein': 12.5, 'moisture': 14.0},
        effectiveValue: 12.5,
        function: '구조 형성',
        qualityCorrectionFactor: 1.0,
      );

      expect(metadata.name, equals('강력분'));
      expect(metadata.properties['protein'], equals(12.5));
      expect(metadata.effectiveValue, equals(12.5));
      expect(metadata.function, equals('구조 형성'));
      expect(metadata.qualityCorrectionFactor, equals(1.0));
    });

    test('유효 밀가루 단백질% 계산이 정확해야 함', () {
      const metadata = IngredientMetadata(
        name: '강력분',
        properties: {
          'protein': 12.5,
          'activityIndex': 1.1,
        },
        effectiveValue: 12.5,
        function: '구조 형성',
        qualityCorrectionFactor: 1.2,
      );

      // 유효 단백질% = 12.5 × 1.1 = 13.75 (qualityCorrectionFactor는 별도 적용)
      expect(metadata.effectiveProteinPercentage, closeTo(13.75, 0.01));
    });

    test('유효 이스트 활성도% 계산이 정확해야 함', () {
      const metadata = IngredientMetadata(
        name: '인스턴트 이스트',
        properties: {
          'standardActivity': 0.5,
          'freshnessIndex': 1.0,
        },
        effectiveValue: 0.5,
        function: '발효',
        qualityCorrectionFactor: 1.2,
      );

      // 유효 활성도% = 0.5 × 1.0 = 0.5 (qualityCorrectionFactor는 별도 적용)
      expect(metadata.effectiveYeastActivity, closeTo(0.5, 0.01));
    });

    test('단백질 정보가 없으면 effectiveValue를 반환해야 함', () {
      const metadata = IngredientMetadata(
        name: '소금',
        properties: {'purity': 99.0},
        effectiveValue: 10.0,
        function: '풍미 향상',
        qualityCorrectionFactor: 1.0,
      );

      expect(
          metadata.effectiveProteinPercentage, equals(0.0)); // 단백질 정보가 없으면 0.0
    });

    test('copyWith 메서드가 정상 동작해야 함', () {
      const original = IngredientMetadata(
        name: '강력분',
        properties: {'protein': 12.5},
        effectiveValue: 12.5,
        function: '구조 형성',
        qualityCorrectionFactor: 1.0,
      );

      final copied = original.copyWith(
        name: '박력분',
        effectiveValue: 8.5,
      );

      expect(copied.name, equals('박력분'));
      expect(copied.effectiveValue, equals(8.5));
      expect(copied.function, equals('구조 형성')); // 변경되지 않음
      expect(copied.qualityCorrectionFactor, equals(1.0)); // 변경되지 않음
    });

    test('toString 메서드가 정상 동작해야 함', () {
      const metadata = IngredientMetadata(
        name: '강력분',
        properties: {'protein': 12.5},
        effectiveValue: 12.5,
        function: '구조 형성',
        qualityCorrectionFactor: 1.0,
      );

      final result = metadata.toString();
      expect(result, contains('강력분'));
      expect(result, contains('구조 형성'));
      expect(result, contains('12.5'));
    });

    test('동등성 비교가 정상 동작해야 함', () {
      const metadata1 = IngredientMetadata(
        name: '강력분',
        properties: {'protein': 12.5},
        effectiveValue: 12.5,
        function: '구조 형성',
        qualityCorrectionFactor: 1.0,
      );

      const metadata2 = IngredientMetadata(
        name: '강력분',
        properties: {'protein': 12.5},
        effectiveValue: 12.5,
        function: '구조 형성',
        qualityCorrectionFactor: 1.0,
      );

      const metadata3 = IngredientMetadata(
        name: '박력분',
        properties: {'protein': 8.5},
        effectiveValue: 8.5,
        function: '구조 형성',
        qualityCorrectionFactor: 1.0,
      );

      expect(metadata1, equals(metadata2));
      expect(metadata1, isNot(equals(metadata3)));
      expect(metadata1.hashCode, equals(metadata2.hashCode));
    });

    test('JSON 직렬화/역직렬화가 정상 동작해야 함', () {
      const original = IngredientMetadata(
        name: '강력분',
        properties: {'protein': 12.5, 'moisture': 14.0},
        effectiveValue: 12.5,
        function: '구조 형성',
        qualityCorrectionFactor: 1.0,
      );

      final json = original.toJson();
      final restored = IngredientMetadata.fromJson(json);

      expect(restored.name, equals(original.name));
      expect(restored.properties, equals(original.properties));
      expect(restored.effectiveValue, equals(original.effectiveValue));
      expect(restored.function, equals(original.function));
      expect(restored.qualityCorrectionFactor,
          equals(original.qualityCorrectionFactor));
    });
  });
}
