// 밀가루 감지 로직 개선 테스트
import 'lib/services/centralized_parsing_service.dart';

void main() {
  print('=== 밀가루 감지 로직 개선 테스트 ===');

  // 다양한 밀가루 이름으로 테스트
  final testCases = [
    '밀가루',
    '강력분',
    '중력분',
    '박력분',
    '통밀가루',
    '호밀가루',
    '곡물가루',
    'flour',
    'bread flour',
    'whole wheat flour',
    'cake flour',
    'high protein flour',
    '곡물 가루',
    '빵가루',
  ];

  print('\n📋 테스트할 재료들:');
  for (final testCase in testCases) {
    print('  - "$testCase"');
  }

  // 각 재료로 테스트 데이터 생성
  for (final flourName in testCases) {
    print('\n🧪 === "$flourName" 테스트 ===');

    final mockRecipeData = {
      'ingredients': [
        {
          'name': flourName,
          'amount': 500.0,
          'unit': 'g',
        },
        {
          'name': '물',
          'amount': 300.0,
          'unit': 'g',
        }
      ]
    };

    try {
      final result = CentralizedParsingService()
          .parseIngredientsForMoisture(mockRecipeData);

      print('✅ 파싱 성공!');
      print('   밀가루 무게: ${result['flourWeight']}g');
      print('   물 무게: ${result['waterWeight']}g');
      print('   총 수분: ${result['totalMoisture']}g');

      if (result['flourWeight'] == 0.0) {
        print('❌ 밀가루 감지 실패!');
      } else {
        print('✅ 밀가루 감지 성공!');
      }
    } catch (e) {
      print('❌ 파싱 실패: $e');
    }
  }

  print('\n=== 밀가루 감지 개선 테스트 완료 ===');
}
