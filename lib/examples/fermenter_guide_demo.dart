/// 발효기 설정 가이드 관리자 사용 예시
/// 실제 사용 시나리오를 통한 데모

import '../services/fermenter_guide_manager.dart';
import '../models/fermentation_scenario_v2.dart';
import '../models/environmental_conditions.dart';

class FermenterGuideDemo {
  /// 데모 1: 기본 빵 레시피의 발효기 설정
  static void demoBasicBreadFermentation() {
    print('=== 데모 1: 기본 빵 레시피 발효기 설정 ===\n');

    // 레시피 분석 결과
    final recipe = RecipeAnalysis(
      recipeId: 'basic-bread',
      ingredients: {
        'flour': 500.0,
        'water': 350.0,
        'yeast': 7.0,
        'sugar': 25.0,
        'salt': 8.0,
      },
      flourPercentage: 100.0,
      sugarPercentage: 5.0,
      yeastPercentage: 1.4,
      hydrationLevel: 70.0,
      bakingType: BakingType.bread,
      estimatedComplexity: 4.0,
      characteristics: ['중수분', '저당분'],
    );

    // 1차 발효 단계
    final primaryStage = FermentationStageV2(
      name: '1차 발효',
      type: FermentationStageType.primary,
      duration: Duration(minutes: 90),
      temperature: 28.0,
      humidity: 75.0,
      instructions: [],
      automationTargets: [],
      conditions: [],
    );

    // 최적 설정 계산
    final settings = FermenterGuideManager.calculateOptimalSettings(
      primaryStage,
      recipe,
    );

    print('📊 계산된 최적 설정:');
    print('   온도: ${settings.temperature}°C');
    print('   습도: ${settings.humidity}%');
    print('   시간: ${settings.duration.inMinutes}분');
    print('   단계: ${settings.stageName}');
    print('');

    // 스마트 발효기 설정 지침
    print('🤖 스마트 발효기 설정 지침:');
    final smartInstructions = FermenterGuideManager.generateSettingInstructions(
      settings,
      FermenterType.smart,
    );

    for (final instruction in smartInstructions) {
      print('   ${instruction.title}:');
      print('   ${instruction.description}');
      for (int i = 0; i < instruction.steps.length; i++) {
        print('   ${i + 1}. ${instruction.steps[i]}');
      }
      if (instruction.tips.isNotEmpty) {
        print('   💡 팁: ${instruction.tips.join(', ')}');
      }
      print('');
    }

    // 설정 검증
    final validation = FermenterGuideManager.validateSettings(
      settings,
      FermenterType.smart,
    );

    print('✅ 설정 검증 결과:');
    print('   유효성: ${validation['isValid'] ? '통과' : '실패'}');
    print('   점수: ${validation['score']}/100');
    if (validation['warnings'].isNotEmpty) {
      print('   ⚠️ 주의사항: ${validation['warnings'].join(', ')}');
    }
    print('\n' + '=' * 50 + '\n');
  }

  /// 데모 2: 고당분 페이스트리의 환경 조정
  static void demoHighSugarPastryWithEnvironment() {
    print('=== 데모 2: 고당분 페이스트리 + 환경 조정 ===\n');

    // 고당분 페이스트리 레시피
    final recipe = RecipeAnalysis(
      recipeId: 'sweet-pastry',
      ingredients: {
        'flour': 300.0,
        'butter': 150.0,
        'sugar': 80.0,
        'eggs': 50.0,
        'yeast': 6.0,
      },
      flourPercentage: 100.0,
      sugarPercentage: 26.7, // 고당분
      yeastPercentage: 2.0,
      hydrationLevel: 45.0, // 저수분
      bakingType: BakingType.pastry,
      estimatedComplexity: 7.0,
      characteristics: ['고당분', '저수분', '버터리치'],
    );

    // 최종 발효 단계
    final finalStage = FermentationStageV2(
      name: '최종 발효',
      type: FermentationStageType.final,
      duration: Duration(minutes: 45),
      temperature: 30.0,
      humidity: 80.0,
      instructions: [],
      automationTargets: [],
      conditions: [],
    );

    // 기본 설정 계산
    final baseSettings = FermenterGuideManager.calculateOptimalSettings(
      finalStage,
      recipe,
    );

    print('📊 기본 계산 설정:');
    print('   온도: ${baseSettings.temperature}°C');
    print('   습도: ${baseSettings.humidity}%');
    print('   조정 사유: 고당분(-2°C), 저수분(-5% 습도)');
    print('');

    // 여름철 더운 환경
    final summerEnvironment = EnvironmentalConditions(
      roomTemperature: 32.0,
      humidity: 80.0,
      season: Season.summer,
      altitude: 0,
    );

    // 환경 조정된 설정
    final adjustedSettings = FermenterGuideManager.adjustForEnvironment(
      baseSettings,
      summerEnvironment,
    );

    print('🌡️ 환경 조정 후 설정:');
    print('   온도: ${adjustedSettings.temperature}°C (${adjustedSettings.temperature - baseSettings.temperature > 0 ? '+' : ''}${(adjustedSettings.temperature - baseSettings.temperature).toStringAsFixed(1)}°C)');
    print('   습도: ${adjustedSettings.humidity}% (${adjustedSettings.humidity - baseSettings.humidity > 0 ? '+' : ''}${(adjustedSettings.humidity - baseSettings.humidity).toStringAsFixed(1)}%)');
    print('   조정 사유: 여름철 고온 환경');
    print('');

    // 설정 비교
    final comparison = FermenterGuideManager.compareSettings(
      baseSettings,
      adjustedSettings,
      '기본 설정',
      '환경 조정 설정',
    );

    print('⚖️ 설정 비교:');
    print('   기본 설정 점수: ${comparison['scores']['기본 설정']}/100');
    print('   조정 설정 점수: ${comparison['scores']['환경 조정 설정']}/100');
    print('   권장사항: ${comparison['recommendation']}');
    print('\n' + '=' * 50 + '\n');
  }

  /// 데모 3: 오버나이트 발효 보관 가이드
  static void demoOvernightStorageGuide() {
    print('=== 데모 3: 오버나이트 발효 보관 가이드 ===\n');

    // 오버나이트 브레드 레시피
    final recipe = RecipeAnalysis(
      recipeId: 'overnight-bread',
      ingredients: {
        'flour': 400.0,
        'water': 280.0,
        'yeast': 2.0, // 저이스트
        'salt': 8.0,
      },
      flourPercentage: 100.0,
      sugarPercentage: 0.0,
      yeastPercentage: 0.5, // 저이스트
      hydrationLevel: 70.0,
      bakingType: BakingType.bread,
      estimatedComplexity: 6.0,
      characteristics: ['저이스트', '장시간발효'],
    );

    // 냉장 보관 설정
    final refrigeratorStorage = FermenterGuideManager.calculateSafeStorageSettings(
      StorageType.refrigerator,
      Duration(hours: 12),
      recipe,
    );

    print('🧊 냉장 보관 가이드:');
    print('   온도: ${refrigeratorStorage.temperature}°C');
    print('   습도: ${refrigeratorStorage.humidity}%');
    print('   최대 보관: ${refrigeratorStorage.maxDuration.inDays}일');
    print('');
    print('   📋 보관 지침:');
    for (int i = 0; i < refrigeratorStorage.instructions.length; i++) {
      print('   ${i + 1}. ${refrigeratorStorage.instructions[i]}');
    }
    print('');
    print('   💡 안전 팁:');
    for (final tip in refrigeratorStorage.safetyTips) {
      print('   • $tip');
    }
    print('');

    // 냉동 보관 설정
    final freezerStorage = FermenterGuideManager.calculateSafeStorageSettings(
      StorageType.freezer,
      Duration(days: 3),
      recipe,
    );

    print('❄️ 냉동 보관 가이드:');
    print('   온도: ${freezerStorage.temperature}°C');
    print('   습도: ${freezerStorage.humidity}%');
    print('   최대 보관: ${freezerStorage.maxDuration.inDays}일');
    print('');
    print('   📋 보관 지침:');
    for (int i = 0; i < freezerStorage.instructions.length; i++) {
      print('   ${i + 1}. ${freezerStorage.instructions[i]}');
    }
    print('');
    print('   💡 안전 팁:');
    for (final tip in freezerStorage.safetyTips) {
      print('   • $tip');
    }
    print('\n' + '=' * 50 + '\n');
  }

  /// 데모 4: 문제 해결 및 유지 관리
  static void demoTroubleshootingAndMaintenance() {
    print('=== 데모 4: 문제 해결 및 유지 관리 ===\n');

    // 문제 해결 가이드
    final troubleshooting = FermenterGuideManager.getTroubleshootingGuide();

    print('🔧 발효기 문제 해결 가이드:');
    troubleshooting.forEach((problem, solutions) {
      print('   ❗ $problem:');
      for (int i = 0; i < solutions.length; i++) {
        print('   ${i + 1}. ${solutions[i]}');
      }
      print('');
    });

    // 유지 관리 팁
    final maintenanceTips = FermenterGuideManager.getMaintenanceTips();

    print('🧹 발효기 유지 관리 팁:');
    for (int i = 0; i < maintenanceTips.length; i++) {
      print('   ${i + 1}. ${maintenanceTips[i]}');
    }
    print('\n' + '=' * 50 + '\n');
  }

  /// 데모 5: 완전한 맞춤 가이드 생성
  static void demoCompleteCustomGuide() {
    print('=== 데모 5: 완전한 맞춤 가이드 생성 ===\n');

    // 복합 레시피 (브리오슈)
    final recipe = RecipeAnalysis(
      recipeId: 'brioche',
      ingredients: {
        'flour': 500.0,
        'butter': 250.0,
        'eggs': 200.0,
        'sugar': 50.0,
        'yeast': 10.0,
        'milk': 100.0,
      },
      flourPercentage: 100.0,
      sugarPercentage: 10.0,
      yeastPercentage: 2.0,
      hydrationLevel: 60.0,
      bakingType: BakingType.enriched,
      estimatedComplexity: 8.0,
      characteristics: ['고지방', '중당분', '고이스트'],
    );

    // 다단계 발효 과정
    final stages = [
      FermentationStageV2(
        name: '1차 발효',
        type: FermentationStageType.primary,
        duration: Duration(hours: 2),
        temperature: 26.0,
        humidity: 75.0,
        instructions: [],
        automationTargets: [],
        conditions: [],
      ),
      FermentationStageV2(
        name: '냉장 휴지',
        type: FermentationStageType.rest,
        duration: Duration(hours: 8),
        temperature: 4.0,
        humidity: 85.0,
        instructions: [],
        automationTargets: [],
        conditions: [],
      ),
      FermentationStageV2(
        name: '최종 발효',
        type: FermentationStageType.final,
        duration: Duration(minutes: 90),
        temperature: 28.0,
        humidity: 80.0,
        instructions: [],
        automationTargets: [],
        conditions: [],
      ),
    ];

    // 완전한 맞춤 가이드 생성
    final customGuide = FermenterGuideManager.generateCustomGuide(
      FermenterType.smart,
      recipe,
      stages,
    );

    print('📖 브리오슈 완전 맞춤 가이드:');
    print('   발효기 타입: ${customGuide['fermenterType']}');
    print('   스마트 발효기: ${customGuide['isSmartFermenter']}');
    print('');

    print('   📊 레시피 정보:');
    final recipeInfo = customGuide['recipeInfo'] as Map<String, dynamic>;
    print('   • 설탕 함량: ${recipeInfo['sugarPercentage']}%');
    print('   • 이스트 함량: ${recipeInfo['yeastPercentage']}%');
    print('   • 수분 함량: ${recipeInfo['hydrationLevel']}%');
    print('   • 복잡도: ${recipeInfo['complexity']}/10');
    print('');

    print('   🔄 단계별 설정:');
    final stageSettings = customGuide['stageSettings'] as List;
    for (int i = 0; i < stageSettings.length; i++) {
      final stage = stageSettings[i];
      final settings = stage['settings'] as Map<String, dynamic>;
      print('   ${i + 1}. ${stage['stageName']}:');
      print('      온도: ${settings['temperature']}°C');
      print('      습도: ${settings['humidity']}%');
      print('      시간: ${settings['duration']}분');
      
      final instructions = stage['instructions'] as List;
      if (instructions.isNotEmpty) {
        print('      주요 지침: ${instructions.first['description']}');
      }
      print('');
    }

    print('   💡 일반 팁:');
    final generalTips = customGuide['generalTips'] as List<String>;
    for (final tip in generalTips.take(3)) {
      print('   • $tip');
    }
    print('   ... 총 ${generalTips.length}개 팁');
    print('');

    print('   🛡️ 안전 수칙:');
    final safetyGuidelines = customGuide['safetyGuidelines'] as List<String>;
    for (final guideline in safetyGuidelines.take(3)) {
      print('   • $guideline');
    }
    print('   ... 총 ${safetyGuidelines.length}개 수칙');
    print('\n' + '=' * 50 + '\n');
  }

  /// 모든 데모 실행
  static void runAllDemos() {
    print('🚀 발효기 설정 가이드 관리자 데모 시작\n');
    
    demoBasicBreadFermentation();
    demoHighSugarPastryWithEnvironment();
    demoOvernightStorageGuide();
    demoTroubleshootingAndMaintenance();
    demoCompleteCustomGuide();
    
    print('✅ 모든 데모 완료!');
    print('발효기 설정 가이드 관리자가 성공적으로 구현되었습니다.');
  }
}

/// 데모 실행 함수
void main() {
  FermenterGuideDemo.runAllDemos();
}