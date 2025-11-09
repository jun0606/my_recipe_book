// 순수 Dart로 밀가루 키워드 테스트
void main() {
  print('=== 밀가루 키워드 매칭 테스트 ===');

  // CentralizedParsingService의 밀가루 키워드 리스트 복사
  final flourKeywords = [
    // 기본 한글 키워드
    '밀가루',
    '강력분',
    '중력분',
    '박력분',
    '통밀가루',
    '호밀가루',
    '곡물가루',
    '곡물분',
    '밀분',
    '빵가루',
    '빵분',

    // 영어 키워드
    'flour',
    'wheat flour',
    'bread flour',
    'all-purpose flour',
    'cake flour',
    'whole wheat flour',
    'rye flour',
    'spelt flour',
    'einkorn flour',
    'emmer flour',
    'farro flour',
    'kamut flour',
    'triticale flour',
    'durum flour',
    'semolina flour',
    'corn flour',
    'rice flour',
    'oat flour',
    'barley flour',
    'sorghum flour',
    'millet flour',
    'quinoa flour',
    'amaranth flour',
    'buckwheat flour',
    'chickpea flour',
    'lentil flour',

    // 한글 변형 표현들
    '밀 가루',
    '강력 분',
    '중력 분',
    '박력 분',
    '통밀 가루',
    '호밀 가루',
    '곡물 가루',
    '곡물 분',
    '밀 분',
    '빵 가루',
    '빵 분',

    // 전문 베이킹 용어
    'high gluten flour', // 고글루텐 밀가루
    'high protein flour', // 고단백 밀가루
    'low protein flour', // 저단백 밀가루
    'organic flour', // 유기농 밀가루
    'stone ground flour', // 석유방 방식 밀가루
    'whole grain flour', // 통곡물 밀가루
  ];

  // 테스트할 재료명들
  final testIngredients = [
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
    '밀 가루',
    '빵가루',

    // 실패해야 하는 테스트 케이스
    '몰가루', // 오타
    '밀가루2', // 숫자 포함
    '물가루', // 다른 의미
    'flourish', // 영어철자 비슷
    '밀가루(고급)', // 괄호 포함
  ];

  print('\n📋 총 키워드 수: ${flourKeywords.length}');
  print('📋 테스트할 재료 수: ${testIngredients.length}');

  print('\n🧪 === 매칭 테스트 ===');
  int successCount = 0;

  for (final ingredient in testIngredients) {
    print('\n🔍 재료: "$ingredient"');

    final matchingKeywords =
        flourKeywords.where((keyword) => ingredient.contains(keyword)).toList();

    if (matchingKeywords.isNotEmpty) {
      print('✅ 매칭 성공! 키워드: ${matchingKeywords.join(', ')}');
      successCount++;
    } else {
      print('❌ 매칭 실패');
    }

    // 이 재료명을 포함하는 키워드들을 찾기
    final containingKeywords =
        flourKeywords.where((keyword) => keyword.contains(ingredient)).toList();

    if (containingKeywords.isNotEmpty) {
      print('📝 관련 키워드: ${containingKeywords.join(', ')}');
    }
  }

  print('\n📊 === 테스트 결과 ===');
  print('총 테스트: ${testIngredients.length}');
  print('매칭 성공: $successCount');
  print('매칭 실패: ${testIngredients.length - successCount}');
  print(
      '성공률: ${(successCount / testIngredients.length * 100).toStringAsFixed(1)}%');

  print('\n✅ 밀가루 키워드 확장 작업 완료!');
}
