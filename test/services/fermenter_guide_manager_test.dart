import 'package:flutter_test/flutter_test.dart';
import '../../lib/services/fermenter_guide_manager.dart';
import '../../lib/models/fermentation_scenario_v2.dart';
import '../../lib/models/environmental_conditions.dart';

void main() {
  group('FermenterGuideManager Tests', () {
    late RecipeAnalysis testRecipe;
    late FermentationStageV2 testStage;

    setUp(() {
      testRecipe = RecipeAnalysis(
        recipeId: 'test-recipe',
        recipeName: 'Test Recipe',
        flourAmount: 100.0,
        yeastAmount: 1.5,
        sugarAmount: 10.0,
        liquidAmount: 70.0,
        fatAmount: 0.0,
        yeastType: YeastType.dry,
        breadType: BreadType.white,
        analysisTimestamp: DateTime.now(),
      );

      // EnhancedRecipe에서 BreadType으로 변환 예시
      final testEnhancedRecipe = EnhancedRecipe(
        id: 1,
        title: 'Test Recipe',
        category: 'bread',
        bakingCategory: BakingCategory.bread,
        ingredients: [],
        instructions: [],
      );

      final convertedBreadType =
          testEnhancedRecipe.bakingCategory.toBreadType();
      expect(convertedBreadType, equals(BreadType.white));

      testStage = FermentationStageV2(
        name: '1차 발효',
        type: FermentationStageType.primary,
        duration: Duration(minutes: 90),
        temperature: TemperatureRange(min: 25.0, max: 30.0, optimal: 28.0),
        humidity: HumidityRange(min: 70.0, max: 80.0, optimal: 75.0),
        instructions: [],
        automations: [],
        alerts: AlertSettings(message: '발효 시작'),
        description: '1차 발효 단계',
      );
    });

    test('calculateOptimalSettings - 기본 설정 계산', () {
      final settings = FermenterGuideManager.calculateOptimalSettings(
        testStage,
        testRecipe,
      );

      expect(settings.temperature, equals(28.0)); // 기본 온도
      expect(settings.humidity, equals(75.0)); // 기본 습도
      expect(settings.duration, equals(Duration(minutes: 90)));
      expect(settings.stageName, equals('1차 발효'));
      expect(settings.stageType, equals(FermentationStageType.primary));
    });

    test('calculateOptimalSettings - 고당분 레시피 조정', () {
      final highSugarRecipe = RecipeAnalysis(
        recipeId: 'high-sugar-recipe',
        ingredients: {
          'flour': 100.0,
          'water': 70.0,
          'yeast': 1.5,
          'sugar': 20.0
        },
        flourPercentage: 100.0,
        sugarPercentage: 20.0, // 고당분
        yeastPercentage: 1.5,
        hydrationLevel: 70.0,
        bakingType: BakingType.bread,
        estimatedComplexity: 6.0,
      );

      final settings = FermenterGuideManager.calculateOptimalSettings(
        testStage,
        highSugarRecipe,
      );

      expect(settings.temperature, equals(26.0)); // 28 - 2 = 26°C
      expect(settings.metadata['tempAdjustment'], equals(-2.0));
    });

    test('calculateOptimalSettings - 고이스트 레시피 조정', () {
      final highYeastRecipe = RecipeAnalysis(
        recipeId: 'high-yeast-recipe',
        ingredients: {
          'flour': 100.0,
          'water': 70.0,
          'yeast': 2.5,
          'sugar': 10.0
        },
        flourPercentage: 100.0,
        sugarPercentage: 10.0,
        yeastPercentage: 2.5, // 고이스트
        hydrationLevel: 70.0,
        bakingType: BakingType.bread,
        estimatedComplexity: 5.0,
      );

      final settings = FermenterGuideManager.calculateOptimalSettings(
        testStage,
        highYeastRecipe,
      );

      expect(settings.temperature, equals(27.0)); // 28 - 1 = 27°C
      expect(settings.metadata['tempAdjustment'], equals(-1.0));
    });

    test('calculateOptimalSettings - 고수분 레시피 조정', () {
      final highHydrationRecipe = RecipeAnalysis(
        recipeId: 'high-hydration-recipe',
        ingredients: {
          'flour': 100.0,
          'water': 80.0,
          'yeast': 1.5,
          'sugar': 10.0
        },
        flourPercentage: 100.0,
        sugarPercentage: 10.0,
        yeastPercentage: 1.5,
        hydrationLevel: 80.0, // 고수분
        bakingType: BakingType.bread,
        estimatedComplexity: 6.0,
      );

      final settings = FermenterGuideManager.calculateOptimalSettings(
        testStage,
        highHydrationRecipe,
      );

      expect(settings.humidity, equals(80.0)); // 75 + 5 = 80%
      expect(settings.metadata['humidityAdjustment'], equals(5.0));
    });

    test('generateSettingInstructions - 스마트 발효기', () {
      final settings = FermenterGuideManager.calculateOptimalSettings(
        testStage,
        testRecipe,
      );

      final instructions = FermenterGuideManager.generateSettingInstructions(
        settings,
        FermenterType.smart,
      );

      expect(instructions.length, equals(4)); // 온도, 습도, 타이머, 반죽배치

      final tempInstruction =
          instructions.firstWhere((i) => i.title == '온도 설정');
      expect(tempInstruction.steps.first, contains('디지털 패널'));
      expect(tempInstruction.priority, equals(InstructionPriority.critical));
    });

    test('generateSettingInstructions - 수동 발효기', () {
      final settings = FermenterGuideManager.calculateOptimalSettings(
        testStage,
        testRecipe,
      );

      final instructions = FermenterGuideManager.generateSettingInstructions(
        settings,
        FermenterType.manual,
      );

      expect(instructions.length, equals(4));

      final tempInstruction =
          instructions.firstWhere((i) => i.title == '온도 설정');
      expect(tempInstruction.steps.first, contains('전원을 켜세요'));
      expect(tempInstruction.steps[1], contains('다이얼'));
    });

    test('calculateSafeStorageSettings - 냉장 보관', () {
      final storageSettings =
          FermenterGuideManager.calculateSafeStorageSettings(
        StorageType.refrigerator,
        Duration(hours: 12),
        testRecipe,
      );

      expect(storageSettings.type, equals(StorageType.refrigerator));
      expect(storageSettings.temperature, equals(4.0));
      expect(storageSettings.humidity, equals(85.0));
      expect(storageSettings.maxDuration, equals(Duration(days: 3)));
      expect(storageSettings.instructions.length, greaterThan(0));
    });

    test('calculateSafeStorageSettings - 냉동 보관', () {
      final storageSettings =
          FermenterGuideManager.calculateSafeStorageSettings(
        StorageType.freezer,
        Duration(days: 1),
        testRecipe,
      );

      expect(storageSettings.type, equals(StorageType.freezer));
      expect(storageSettings.temperature, equals(-18.0));
      expect(storageSettings.humidity, equals(5.0));
      expect(storageSettings.maxDuration, equals(Duration(days: 7)));
    });

    test('calculateSafeStorageSettings - 실온 보관', () {
      final storageSettings =
          FermenterGuideManager.calculateSafeStorageSettings(
        StorageType.roomTemp,
        Duration(hours: 4),
        testRecipe,
      );

      expect(storageSettings.type, equals(StorageType.roomTemp));
      expect(storageSettings.temperature, equals(25.0));
      expect(storageSettings.humidity, equals(65.0));
      expect(storageSettings.maxDuration.inHours, greaterThanOrEqualTo(2));
      expect(storageSettings.maxDuration.inHours, lessThanOrEqualTo(8));
    });

    test('validateSettings - 정상 설정', () {
      final settings = FermenterSettings(
        temperature: 28.0,
        humidity: 75.0,
        duration: Duration(minutes: 90),
        stageName: '1차 발효',
        stageType: FermentationStageType.primary,
      );

      final validation = FermenterGuideManager.validateSettings(
        settings,
        FermenterType.smart,
      );

      expect(validation['isValid'], isTrue);
      expect(validation['issues'], isEmpty);
      expect(validation['score'], greaterThan(80));
    });

    test('validateSettings - 온도 너무 높음', () {
      final settings = FermenterSettings(
        temperature: 40.0, // 너무 높음
        humidity: 75.0,
        duration: Duration(minutes: 90),
        stageName: '1차 발효',
        stageType: FermentationStageType.primary,
      );

      final validation = FermenterGuideManager.validateSettings(
        settings,
        FermenterType.smart,
      );

      expect(validation['isValid'], isFalse);
      expect(validation['issues'], isNotEmpty);
      expect(validation['issues'].first, contains('온도가 너무 높습니다'));
    });

    test('validateSettings - 습도 너무 낮음', () {
      final settings = FermenterSettings(
        temperature: 28.0,
        humidity: 50.0, // 너무 낮음
        duration: Duration(minutes: 90),
        stageName: '1차 발효',
        stageType: FermentationStageType.primary,
      );

      final validation = FermenterGuideManager.validateSettings(
        settings,
        FermenterType.smart,
      );

      expect(validation['warnings'], isNotEmpty);
      expect(validation['warnings'].first, contains('습도가 낮습니다'));
    });

    test('adjustForEnvironment - 더운 환경', () {
      final baseSettings = FermenterSettings(
        temperature: 28.0,
        humidity: 75.0,
        duration: Duration(minutes: 90),
        stageName: '1차 발효',
        stageType: FermentationStageType.primary,
      );

      final hotEnvironment = EnvironmentalConditions(
        roomTemperature: 30.0, // 더운 환경
        humidity: 60.0,
        season: Season.summer,
        altitude: 0,
      );

      final adjustedSettings = FermenterGuideManager.adjustForEnvironment(
        baseSettings,
        hotEnvironment,
      );

      expect(adjustedSettings.temperature, lessThan(baseSettings.temperature));
      expect(adjustedSettings.metadata['environmentalAdjustment'], isNotNull);
    });

    test('compareSettings - 설정 비교', () {
      final settings1 = FermenterSettings(
        temperature: 26.0,
        humidity: 70.0,
        duration: Duration(minutes: 75),
        stageName: '1차 발효',
        stageType: FermentationStageType.primary,
      );

      final settings2 = FermenterSettings(
        temperature: 28.0,
        humidity: 75.0,
        duration: Duration(minutes: 90),
        stageName: '1차 발효',
        stageType: FermentationStageType.primary,
      );

      final comparison = FermenterGuideManager.compareSettings(
        settings1,
        settings2,
        '설정 A',
        '설정 B',
      );

      expect(comparison['comparison'], isNotNull);
      expect(comparison['scores'], isNotNull);
      expect(comparison['recommendation'], isNotNull);
      expect(
          comparison['comparison']['temperature']['difference'], equals('2.0'));
    });

    test('getTroubleshootingGuide - 문제 해결 가이드', () {
      final guide = FermenterGuideManager.getTroubleshootingGuide();

      expect(guide.keys, contains('온도가 설정값보다 높음'));
      expect(guide.keys, contains('온도가 설정값보다 낮음'));
      expect(guide.keys, contains('습도가 너무 높음'));
      expect(guide.keys, contains('습도가 너무 낮음'));
      expect(guide.keys, contains('발효가 너무 빠름'));
      expect(guide.keys, contains('발효가 너무 느림'));

      expect(guide['온도가 설정값보다 높음'], isNotEmpty);
    });

    test('getMaintenanceTips - 유지 관리 팁', () {
      final tips = FermenterGuideManager.getMaintenanceTips();

      expect(tips, isNotEmpty);
      expect(tips.length, greaterThanOrEqualTo(5));
      expect(tips.first, contains('청소'));
    });

    test('generateCustomGuide - 맞춤 가이드 생성', () {
      final stages = [testStage];

      final customGuide = FermenterGuideManager.generateCustomGuide(
        FermenterType.smart,
        testRecipe,
        stages,
      );

      expect(customGuide['fermenterType'], equals('smart'));
      expect(customGuide['isSmartFermenter'], isTrue);
      expect(customGuide['recipeInfo'], isNotNull);
      expect(customGuide['stageSettings'], isNotEmpty);
      expect(customGuide['generalTips'], isNotEmpty);
      expect(customGuide['troubleshooting'], isNotNull);
      expect(customGuide['maintenance'], isNotEmpty);
      expect(customGuide['safetyGuidelines'], isNotEmpty);

      final stageSettings = customGuide['stageSettings'] as List;
      expect(stageSettings.length, equals(1));
      expect(stageSettings.first['stageName'], equals('1차 발효'));
    });
  });
}
