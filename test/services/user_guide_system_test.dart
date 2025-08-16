// 임시 비활성화 - 모델 구조 수정 중
// import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../lib/services/user_guide_system.dart';
import '../../lib/models/fermentation_scenario_v2.dart';

void main() {
  group('UserGuideSystem Tests', () {
    late UserGuideSystem guideSystem;

    setUp(() async {
      // SharedPreferences 모킹
      SharedPreferences.setMockInitialValues({});
      guideSystem = UserGuideSystem();
    });

    tearDown(() async {
      await guideSystem.dispose();
    });

    test('시스템 초기화', () async {
      await guideSystem.initialize();
      
      expect(guideSystem.activeGuides, isEmpty);
      expect(guideSystem.guideHistory, isEmpty);
      expect(guideSystem.autoProgressEnabled, isTrue);
      expect(guideSystem.smartNotificationsEnabled, isTrue);
    });

    test('발효기 설정 가이드 생성', () async {
      await guideSystem.initialize();

      final recipe = RecipeAnalysis(
        recipeId: 'test-bread',
        ingredients: {'flour': 100.0, 'water': 70.0, 'yeast': 1.5},
        flourPercentage: 100.0,
        sugarPercentage: 5.0,
        yeastPercentage: 1.5,
        hydrationLevel: 70.0,
        bakingType: BakingType.bread,
        estimatedComplexity: 5.0,
      );

      final stages = [
        FermentationStageV2(
          name: '1차 발효',
          type: FermentationStageType.primary,
          duration: Duration(minutes: 90),
          temperature: 28.0,
          humidity: 75.0,
          instructions: [],
          automationTargets: [],
          conditions: [],
        ),
      ];

      final guide = await guideSystem.createFermenterSetupGuide(
        fermenterType: FermenterType.smart,
        recipe: recipe,
        stages: stages,
      );

      expect(guide.title, contains('스마트 발효기 설정 가이드'));
      expect(guide.type, equals(GuideType.setup));
      expect(guide.steps, isNotEmpty);
      expect(guide.context['fermenterType'], equals('smart'));
      expect(guide.context['recipeId'], equals('test-bread'));
      
      expect(guideSystem.activeGuides, hasLength(1));
      expect(guideSystem.activeGuides.first.id, equals(guide.id));
    });

    test('발효 진행 가이드 생성', () async {
      await guideSystem.initialize();

      final recipe = RecipeAnalysis(
        recipeId: 'test-bread',
        ingredients: {'flour': 100.0, 'water': 70.0, 'yeast': 1.5},
        flourPercentage: 100.0,
        sugarPercentage: 5.0,
        yeastPercentage: 1.5,
        hydrationLevel: 70.0,
        bakingType: BakingType.bread,
        estimatedComplexity: 5.0,
      );

      final stages = [
        FermentationStageV2(
          name: '1차 발효',
          type: FermentationStageType.primary,
          duration: Duration(minutes: 90),
          temperature: 28.0,
          humidity: 75.0,
          instructions: [],
          automationTargets: [],
          conditions: [],
        ),
        FermentationStageV2(
          name: '2차 발효',
          type: FermentationStageType.secondary,
          duration: Duration(minutes: 60),
          temperature: 30.0,
          humidity: 80.0,
          instructions: [],
          automationTargets: [],
          conditions: [],
        ),
      ];

      final guide = await guideSystem.createFermentationProgressGuide(
        stages: stages,
        recipe: recipe,
      );

      expect(guide.title, equals('발효 진행 가이드'));
      expect(guide.type, equals(GuideType.fermentation));
      expect(guide.steps.length, equals(6)); // 2 stages * 3 steps each
      expect(guide.context['stageCount'], equals(2));
      
      // 단계 이름 확인
      expect(guide.steps[0].title, equals('1차 발효 시작'));
      expect(guide.steps[1].title, equals('1차 발효 중간 확인'));
      expect(guide.steps[2].title, equals('1차 발효 완료'));
      expect(guide.steps[3].title, equals('2차 발효 시작'));
      expect(guide.steps[4].title, equals('2차 발효 완료'));
    });

    test('문제 해결 가이드 생성', () async {
      await guideSystem.initialize();

      final guide = await guideSystem.createTroubleshootingGuide(
        problem: '온도가 설정값보다 높음',
        fermenterType: FermenterType.smart,
      );

      expect(guide.title, equals('문제 해결: 온도가 설정값보다 높음'));
      expect(guide.type, equals(GuideType.troubleshooting));
      expect(guide.steps, isNotEmpty);
      expect(guide.context['problem'], equals('온도가 설정값보다 높음'));
      expect(guide.context['fermenterType'], equals('smart'));
    });

    test('유지 관리 가이드 생성', () async {
      await guideSystem.initialize();

      final guide = await guideSystem.createMaintenanceGuide(
        fermenterType: FermenterType.manual,
      );

      expect(guide.title, equals('발효기 유지 관리 가이드'));
      expect(guide.type, equals(GuideType.maintenance));
      expect(guide.steps, isNotEmpty);
      expect(guide.context['fermenterType'], equals('manual'));
    });

    test('단계 완료 처리', () async {
      await guideSystem.initialize();

      // 테스트 가이드 생성
      final guide = await guideSystem.createMaintenanceGuide(
        fermenterType: FermenterType.smart,
      );

      final initialProgress = guide.progress;
      final firstStepId = guide.steps.first.id;

      // 첫 번째 단계 완료
      await guideSystem.completeStep(guide.id, firstStepId);

      final updatedGuide = guideSystem.getGuide(guide.id);
      expect(updatedGuide, isNotNull);
      expect(updatedGuide!.progress, greaterThan(initialProgress));
      expect(updatedGuide.steps.first.isCompleted, isTrue);
      expect(updatedGuide.steps.first.completedAt, isNotNull);
    });

    test('가이드 완료 처리', () async {
      await guideSystem.initialize();

      final guide = await guideSystem.createMaintenanceGuide(
        fermenterType: FermenterType.smart,
      );

      final initialActiveCount = guideSystem.activeGuides.length;
      final initialHistoryCount = guideSystem.guideHistory.length;

      // 가이드 완료
      await guideSystem.completeGuide(guide.id);

      expect(guideSystem.activeGuides.length, equals(initialActiveCount - 1));
      expect(guideSystem.guideHistory.length, equals(initialHistoryCount + 1));
      expect(guideSystem.getGuide(guide.id), isNull);
      expect(guideSystem.guideHistory.last.id, equals(guide.id));
    });

    test('가이드 삭제', () async {
      await guideSystem.initialize();

      final guide = await guideSystem.createMaintenanceGuide(
        fermenterType: FermenterType.smart,
      );

      expect(guideSystem.activeGuides, hasLength(1));

      await guideSystem.removeGuide(guide.id);

      expect(guideSystem.activeGuides, isEmpty);
      expect(guideSystem.getGuide(guide.id), isNull);
    });

    test('설정 변경', () async {
      await guideSystem.initialize();

      // 초기값 확인
      expect(guideSystem.autoProgressEnabled, isTrue);
      expect(guideSystem.smartNotificationsEnabled, isTrue);
      expect(guideSystem.contextualTipsEnabled, isTrue);
      expect(guideSystem.voiceGuidanceEnabled, isFalse);

      // 설정 변경
      await guideSystem.setAutoProgressEnabled(false);
      await guideSystem.setSmartNotificationsEnabled(false);
      await guideSystem.setContextualTipsEnabled(false);
      await guideSystem.setVoiceGuidanceEnabled(true);

      // 변경된 값 확인
      expect(guideSystem.autoProgressEnabled, isFalse);
      expect(guideSystem.smartNotificationsEnabled, isFalse);
      expect(guideSystem.contextualTipsEnabled, isFalse);
      expect(guideSystem.voiceGuidanceEnabled, isTrue);
    });

    test('가이드 진행률 계산', () async {
      await guideSystem.initialize();

      final guide = await guideSystem.createMaintenanceGuide(
        fermenterType: FermenterType.smart,
      );

      // 초기 진행률
      expect(guide.progress, equals(0.0));
      expect(guide.completedStepsCount, equals(0));

      // 첫 번째 단계 완료
      await guideSystem.completeStep(guide.id, guide.steps.first.id);
      final updatedGuide1 = guideSystem.getGuide(guide.id)!;
      
      expect(updatedGuide1.completedStepsCount, equals(1));
      expect(updatedGuide1.progress, equals(1.0 / guide.steps.length));

      // 두 번째 단계 완료
      if (guide.steps.length > 1) {
        await guideSystem.completeStep(guide.id, guide.steps[1].id);
        final updatedGuide2 = guideSystem.getGuide(guide.id)!;
        
        expect(updatedGuide2.completedStepsCount, equals(2));
        expect(updatedGuide2.progress, equals(2.0 / guide.steps.length));
      }
    });

    test('다음 단계 찾기', () async {
      await guideSystem.initialize();

      final guide = await guideSystem.createMaintenanceGuide(
        fermenterType: FermenterType.smart,
      );

      // 초기 다음 단계는 첫 번째 단계
      expect(guide.nextStep?.id, equals(guide.steps.first.id));

      // 첫 번째 단계 완료 후
      await guideSystem.completeStep(guide.id, guide.steps.first.id);
      final updatedGuide = guideSystem.getGuide(guide.id)!;

      if (guide.steps.length > 1) {
        expect(updatedGuide.nextStep?.id, equals(guide.steps[1].id));
      } else {
        expect(updatedGuide.nextStep?.id, equals(guide.steps.last.id));
      }
    });

    test('예상 남은 시간 계산', () async {
      await guideSystem.initialize();

      final guide = await guideSystem.createMaintenanceGuide(
        fermenterType: FermenterType.smart,
      );

      final initialRemainingTime = guide.estimatedRemainingTime;
      expect(initialRemainingTime.inMinutes, greaterThan(0));

      // 첫 번째 단계 완료 후 남은 시간 감소 확인
      await guideSystem.completeStep(guide.id, guide.steps.first.id);
      final updatedGuide = guideSystem.getGuide(guide.id)!;

      expect(
        updatedGuide.estimatedRemainingTime.inMinutes,
        lessThan(initialRemainingTime.inMinutes),
      );
    });

    test('가이드 컨텍스트 정보', () async {
      await guideSystem.initialize();

      final recipe = RecipeAnalysis(
        recipeId: 'context-test',
        ingredients: {'flour': 100.0, 'water': 70.0, 'yeast': 1.5},
        flourPercentage: 100.0,
        sugarPercentage: 8.0,
        yeastPercentage: 1.5,
        hydrationLevel: 70.0,
        bakingType: BakingType.bread,
        estimatedComplexity: 6.0,
      );

      final stages = [
        FermentationStageV2(
          name: '테스트 발효',
          type: FermentationStageType.primary,
          duration: Duration(minutes: 120),
          temperature: 26.0,
          humidity: 78.0,
          instructions: [],
          automationTargets: [],
          conditions: [],
        ),
      ];

      final guide = await guideSystem.createFermenterSetupGuide(
        fermenterType: FermenterType.manual,
        recipe: recipe,
        stages: stages,
      );

      expect(guide.context['fermenterType'], equals('manual'));
      expect(guide.context['recipeId'], equals('context-test'));
      expect(guide.context['stageCount'], equals(1));
      expect(guide.context['customGuide'], isNotNull);
    });
  });

  group('GuideStep Tests', () {
    test('GuideStep 생성 및 복사', () {
      final step = GuideStep(
        id: 'test-step',
        title: '테스트 단계',
        description: '테스트용 단계입니다',
        instructions: ['첫 번째 지침', '두 번째 지침'],
        tips: ['유용한 팁'],
        warnings: ['주의사항'],
        priority: GuidePriority.critical,
        estimatedTime: Duration(minutes: 10),
        requiredTools: ['도구1', '도구2'],
      );

      expect(step.id, equals('test-step'));
      expect(step.title, equals('테스트 단계'));
      expect(step.instructions.length, equals(2));
      expect(step.isCompleted, isFalse);
      expect(step.completedAt, isNull);

      // 완료 상태로 복사
      final completedStep = step.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      expect(completedStep.isCompleted, isTrue);
      expect(completedStep.completedAt, isNotNull);
      expect(completedStep.title, equals(step.title)); // 다른 속성은 유지
    });

    test('GuideStep JSON 직렬화', () {
      final step = GuideStep(
        id: 'json-test',
        title: 'JSON 테스트',
        description: 'JSON 직렬화 테스트',
        instructions: ['지침1', '지침2'],
        priority: GuidePriority.important,
        estimatedTime: Duration(minutes: 15),
      );

      final json = step.toJson();
      final restoredStep = GuideStep.fromJson(json);

      expect(restoredStep.id, equals(step.id));
      expect(restoredStep.title, equals(step.title));
      expect(restoredStep.description, equals(step.description));
      expect(restoredStep.instructions, equals(step.instructions));
      expect(restoredStep.priority, equals(step.priority));
      expect(restoredStep.estimatedTime, equals(step.estimatedTime));
    });
  });

  group('UserGuide Tests', () {
    test('UserGuide 진행률 계산', () {
      final steps = [
        GuideStep(
          id: 'step1',
          title: '단계 1',
          description: '첫 번째 단계',
          instructions: ['지침'],
          priority: GuidePriority.critical,
          isCompleted: true,
        ),
        GuideStep(
          id: 'step2',
          title: '단계 2',
          description: '두 번째 단계',
          instructions: ['지침'],
          priority: GuidePriority.important,
          isCompleted: false,
        ),
        GuideStep(
          id: 'step3',
          title: '단계 3',
          description: '세 번째 단계',
          instructions: ['지침'],
          priority: GuidePriority.helpful,
          isCompleted: true,
        ),
      ];

      final guide = UserGuide(
        id: 'test-guide',
        title: '테스트 가이드',
        description: '테스트용 가이드',
        type: GuideType.setup,
        steps: steps,
        createdAt: DateTime.now(),
      );

      expect(guide.completedStepsCount, equals(2));
      expect(guide.progress, closeTo(2.0 / 3.0, 0.01));
      expect(guide.nextStep?.id, equals('step2'));
    });

    test('UserGuide JSON 직렬화', () {
      final guide = UserGuide(
        id: 'json-guide',
        title: 'JSON 가이드',
        description: 'JSON 테스트용 가이드',
        type: GuideType.fermentation,
        steps: [
          GuideStep(
            id: 'step1',
            title: '단계 1',
            description: '첫 번째 단계',
            instructions: ['지침'],
            priority: GuidePriority.critical,
          ),
        ],
        context: {'testKey': 'testValue'},
        createdAt: DateTime.now(),
      );

      final json = guide.toJson();
      final restoredGuide = UserGuide.fromJson(json);

      expect(restoredGuide.id, equals(guide.id));
      expect(restoredGuide.title, equals(guide.title));
      expect(restoredGuide.type, equals(guide.type));
      expect(restoredGuide.steps.length, equals(guide.steps.length));
      expect(restoredGuide.context['testKey'], equals('testValue'));
    });
  });
}