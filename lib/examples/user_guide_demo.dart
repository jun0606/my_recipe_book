/// 통합 사용자 가이드 시스템 데모
/// 실제 사용 시나리오를 통한 종합적인 데모

import '../services/user_guide_system.dart';
import '../services/fermentation_notification_service.dart';
import '../models/fermentation_scenario_v2.dart';

class UserGuideDemo {
  /// 데모 1: 완전한 발효기 설정 가이드 워크플로우
  static Future<void> demoCompleteSetupWorkflow() async {
    print('=== 데모 1: 완전한 발효기 설정 가이드 워크플로우 ===\n');

    // 시스템 초기화
    final guideSystem = UserGuideSystem();
    await guideSystem.initialize();

    // 레시피 정보
    final recipe = RecipeAnalysis(
      recipeId: 'artisan-sourdough',
      ingredients: {
        'flour': 500.0,
        'water': 375.0,
        'starter': 100.0,
        'salt': 10.0,
      },
      flourPercentage: 100.0,
      sugarPercentage: 2.0,
      yeastPercentage: 0.8, // 저이스트 (사워도우)
      hydrationLevel: 75.0, // 고수분
      bakingType: BakingType.bread,
      estimatedComplexity: 8.0,
      characteristics: ['사워도우', '고수분', '장시간발효'],
    );

    // 발효 단계들
    final stages = [
      FermentationStageV2(
        name: '오토리제',
        type: FermentationStageType.rest,
        duration: Duration(minutes: 30),
        temperature: 22.0,
        humidity: 70.0,
        instructions: [],
        automationTargets: [],
        conditions: [],
      ),
      FermentationStageV2(
        name: '벌크 발효',
        type: FermentationStageType.primary,
        duration: Duration(hours: 4),
        temperature: 26.0,
        humidity: 75.0,
        instructions: [],
        automationTargets: [],
        conditions: [],
      ),
      FermentationStageV2(
        name: '냉장 발효',
        type: FermentationStageType.storage,
        duration: Duration(hours: 12),
        temperature: 4.0,
        humidity: 85.0,
        instructions: [],
        automationTargets: [],
        conditions: [],
      ),
      FermentationStageV2(
        name: '최종 발효',
        type: FermentationStageType.final,
        duration: Duration(hours: 3),
        temperature: 24.0,
        humidity: 80.0,
        instructions: [],
        automationTargets: [],
        conditions: [],
      ),
    ];

    // 발효기 설정 가이드 생성
    print('🔧 발효기 설정 가이드 생성 중...');
    final setupGuide = await guideSystem.createFermenterSetupGuide(
      fermenterType: FermenterType.smart,
      recipe: recipe,
      stages: stages,
    );

    print('✅ 설정 가이드 생성 완료:');
    print('   제목: ${setupGuide.title}');
    print('   단계 수: ${setupGuide.steps.length}');
    print('   예상 시간: ${_formatDuration(setupGuide.estimatedRemainingTime)}');
    print('');

    // 발효 진행 가이드 생성
    print('📈 발효 진행 가이드 생성 중...');
    final progressGuide = await guideSystem.createFermentationProgressGuide(
      stages: stages,
      recipe: recipe,
    );

    print('✅ 진행 가이드 생성 완료:');
    print('   제목: ${progressGuide.title}');
    print('   단계 수: ${progressGuide.steps.length}');
    print('   총 발효 시간: ${_formatDuration(Duration(
      minutes: stages.fold(0, (sum, stage) => sum + stage.duration.inMinutes),
    ))}');
    print('');

    // 가이드 시뮬레이션 실행
    print('🎮 가이드 진행 시뮬레이션:');
    await _simulateGuideProgress(guideSystem, setupGuide);
    
    print('\n' + '=' * 60 + '\n');
  }

  /// 데모 2: 문제 해결 및 유지 관리 가이드
  static Future<void> demoTroubleshootingAndMaintenance() async {
    print('=== 데모 2: 문제 해결 및 유지 관리 가이드 ===\n');

    final guideSystem = UserGuideSystem();
    await guideSystem.initialize();

    // 문제 해결 가이드들 생성
    final problems = [
      '온도가 설정값보다 높음',
      '습도가 너무 낮음',
      '발효가 너무 빠름',
    ];

    print('🔧 문제 해결 가이드 생성:');
    for (final problem in problems) {
      final troubleGuide = await guideSystem.createTroubleshootingGuide(
        problem: problem,
        fermenterType: FermenterType.smart,
      );

      print('   • $problem: ${troubleGuide.steps.length}개 해결 방법');
    }
    print('');

    // 유지 관리 가이드 생성
    print('🧹 유지 관리 가이드 생성:');
    final maintenanceGuide = await guideSystem.createMaintenanceGuide(
      fermenterType: FermenterType.smart,
    );

    print('   • ${maintenanceGuide.title}');
    print('   • ${maintenanceGuide.steps.length}개 관리 항목');
    print('   • 예상 시간: ${_formatDuration(maintenanceGuide.estimatedRemainingTime)}');
    print('');

    // 유지 관리 가이드 단계별 시뮬레이션
    print('🎯 유지 관리 가이드 실행:');
    for (int i = 0; i < maintenanceGuide.steps.length && i < 3; i++) {
      final step = maintenanceGuide.steps[i];
      print('   ${i + 1}. ${step.title}');
      print('      ${step.description}');
      
      // 단계 완료 시뮬레이션
      await guideSystem.completeStep(maintenanceGuide.id, step.id);
      final updatedGuide = guideSystem.getGuide(maintenanceGuide.id)!;
      print('      ✅ 완료 (진행률: ${(updatedGuide.progress * 100).toInt()}%)');
      print('');
    }

    print('\n' + '=' * 60 + '\n');
  }

  /// 데모 3: 알림 시스템 통합 테스트
  static Future<void> demoNotificationIntegration() async {
    print('=== 데모 3: 알림 시스템 통합 테스트 ===\n');

    final guideSystem = UserGuideSystem();
    final notificationService = FermentationNotificationService();
    
    await guideSystem.initialize();
    await notificationService.initialize();

    print('🔔 알림 시스템 설정 확인:');
    print('   소리 알림: ${notificationService.soundEnabled ? '활성화' : '비활성화'}');
    print('   진동 알림: ${notificationService.vibrationEnabled ? '활성화' : '비활성화'}');
    print('   푸시 알림: ${notificationService.notificationEnabled ? '활성화' : '비활성화'}');
    print('   스마트 알림: ${guideSystem.smartNotificationsEnabled ? '활성화' : '비활성화'}');
    print('');

    // 다양한 알림 테스트
    print('📱 알림 테스트 시작:');
    
    print('   1. 단계 시작 알림...');
    await notificationService.notifyStageStart(
      stageName: '테스트 발효',
      duration: Duration(minutes: 90),
    );
    await Future.delayed(Duration(seconds: 1));

    print('   2. 체크포인트 알림...');
    await notificationService.notifyCheckpoint(
      message: '발효 상태를 확인해주세요',
    );
    await Future.delayed(Duration(seconds: 1));

    print('   3. 단계 완료 알림...');
    await notificationService.notifyStageComplete(
      stageName: '테스트 발효',
      nextStageName: '다음 테스트 단계',
    );
    await Future.delayed(Duration(seconds: 1));

    print('   4. 경고 알림...');
    await notificationService.notifyWarning(
      message: '온도가 설정값을 초과했습니다',
    );
    await Future.delayed(Duration(seconds: 1));

    print('   5. 발효 완료 축하 알림...');
    await notificationService.notifyFermentationComplete();
    await Future.delayed(Duration(seconds: 1));

    print('✅ 모든 알림 테스트 완료');
    print('');

    print('\n' + '=' * 60 + '\n');
  }

  /// 데모 4: 고급 기능 및 설정 관리
  static Future<void> demoAdvancedFeatures() async {
    print('=== 데모 4: 고급 기능 및 설정 관리 ===\n');

    final guideSystem = UserGuideSystem();
    await guideSystem.initialize();

    // 초기 설정 확인
    print('⚙️ 초기 설정 상태:');
    print('   자동 진행: ${guideSystem.autoProgressEnabled}');
    print('   스마트 알림: ${guideSystem.smartNotificationsEnabled}');
    print('   상황별 팁: ${guideSystem.contextualTipsEnabled}');
    print('   음성 가이드: ${guideSystem.voiceGuidanceEnabled}');
    print('');

    // 설정 변경 테스트
    print('🔧 설정 변경 테스트:');
    await guideSystem.setAutoProgressEnabled(false);
    await guideSystem.setVoiceGuidanceEnabled(true);
    
    print('   자동 진행 비활성화: ${!guideSystem.autoProgressEnabled ? '성공' : '실패'}');
    print('   음성 가이드 활성화: ${guideSystem.voiceGuidanceEnabled ? '성공' : '실패'}');
    print('');

    // 가이드 생성 및 관리
    print('📚 가이드 관리 테스트:');
    final guide1 = await guideSystem.createMaintenanceGuide(
      fermenterType: FermenterType.smart,
    );
    final guide2 = await guideSystem.createMaintenanceGuide(
      fermenterType: FermenterType.manual,
    );

    print('   활성 가이드 수: ${guideSystem.activeGuides.length}');
    print('   가이드 1: ${guide1.title} (${guide1.steps.length}단계)');
    print('   가이드 2: ${guide2.title} (${guide2.steps.length}단계)');
    print('');

    // 가이드 완료 및 히스토리 관리
    print('📋 가이드 완료 및 히스토리:');
    await guideSystem.completeGuide(guide1.id);
    
    print('   활성 가이드 수: ${guideSystem.activeGuides.length}');
    print('   히스토리 가이드 수: ${guideSystem.guideHistory.length}');
    print('   완료된 가이드: ${guideSystem.guideHistory.last.title}');
    print('');

    // 가이드 삭제
    print('🗑️ 가이드 삭제 테스트:');
    await guideSystem.removeGuide(guide2.id);
    
    print('   활성 가이드 수: ${guideSystem.activeGuides.length}');
    print('   삭제 완료: ${guideSystem.getGuide(guide2.id) == null ? '성공' : '실패'}');
    print('');

    print('\n' + '=' * 60 + '\n');
  }

  /// 데모 5: 실제 사용 시나리오 종합 테스트
  static Future<void> demoRealWorldScenario() async {
    print('=== 데모 5: 실제 사용 시나리오 종합 테스트 ===\n');

    final guideSystem = UserGuideSystem();
    final notificationService = FermentationNotificationService();
    
    await guideSystem.initialize();
    await notificationService.initialize();

    print('🏠 시나리오: 집에서 첫 번째 사워도우 빵 만들기');
    print('');

    // 1단계: 레시피 준비
    print('1️⃣ 레시피 분석 및 준비:');
    final recipe = RecipeAnalysis(
      recipeId: 'first-sourdough',
      ingredients: {
        'bread_flour': 400.0,
        'whole_wheat_flour': 100.0,
        'water': 375.0,
        'sourdough_starter': 100.0,
        'salt': 10.0,
      },
      flourPercentage: 100.0,
      sugarPercentage: 1.5,
      yeastPercentage: 0.6,
      hydrationLevel: 75.0,
      bakingType: BakingType.bread,
      estimatedComplexity: 9.0,
      characteristics: ['사워도우', '고수분', '초보자용'],
    );

    print('   레시피: ${recipe.recipeId}');
    print('   복잡도: ${recipe.estimatedComplexity}/10');
    print('   수분함량: ${recipe.hydrationLevel}%');
    print('');

    // 2단계: 발효 계획 수립
    print('2️⃣ 발효 계획 수립:');
    final stages = [
      FermentationStageV2(
        name: '오토리제 (밀가루 수화)',
        type: FermentationStageType.rest,
        duration: Duration(minutes: 30),
        temperature: 22.0,
        humidity: 70.0,
        instructions: [],
        automationTargets: [],
        conditions: [],
      ),
      FermentationStageV2(
        name: '벌크 발효 (1차)',
        type: FermentationStageType.primary,
        duration: Duration(hours: 5),
        temperature: 24.0, // 저이스트로 인한 조정
        humidity: 78.0, // 고수분으로 인한 조정
        instructions: [],
        automationTargets: [],
        conditions: [],
      ),
      FermentationStageV2(
        name: '냉장 숙성',
        type: FermentationStageType.storage,
        duration: Duration(hours: 18),
        temperature: 4.0,
        humidity: 85.0,
        instructions: [],
        automationTargets: [],
        conditions: [],
      ),
      FermentationStageV2(
        name: '최종 발효',
        type: FermentationStageType.final,
        duration: Duration(hours: 4),
        temperature: 22.0,
        humidity: 80.0,
        instructions: [],
        automationTargets: [],
        conditions: [],
      ),
    ];

    final totalTime = stages.fold(
      Duration.zero,
      (sum, stage) => sum + stage.duration,
    );
    print('   총 발효 시간: ${_formatDuration(totalTime)}');
    print('   발효 단계: ${stages.length}개');
    print('');

    // 3단계: 가이드 생성
    print('3️⃣ 맞춤형 가이드 생성:');
    final setupGuide = await guideSystem.createFermenterSetupGuide(
      fermenterType: FermenterType.smart,
      recipe: recipe,
      stages: stages,
    );

    final progressGuide = await guideSystem.createFermentationProgressGuide(
      stages: stages,
      recipe: recipe,
    );

    print('   설정 가이드: ${setupGuide.steps.length}단계');
    print('   진행 가이드: ${progressGuide.steps.length}단계');
    print('   총 가이드 수: ${guideSystem.activeGuides.length}개');
    print('');

    // 4단계: 가이드 실행 시뮬레이션
    print('4️⃣ 가이드 실행 시뮬레이션:');
    
    // 설정 가이드 일부 실행
    print('   📋 발효기 설정 중...');
    for (int i = 0; i < 2 && i < setupGuide.steps.length; i++) {
      final step = setupGuide.steps[i];
      print('      ${i + 1}. ${step.title}');
      await guideSystem.completeStep(setupGuide.id, step.id);
      
      // 알림 시뮬레이션
      await notificationService.notifyCheckpoint(
        message: '${step.title} 완료',
      );
    }

    // 진행 가이드 일부 실행
    print('   🫧 발효 진행 중...');
    for (int i = 0; i < 3 && i < progressGuide.steps.length; i++) {
      final step = progressGuide.steps[i];
      print('      ${i + 1}. ${step.title}');
      await guideSystem.completeStep(progressGuide.id, step.id);
      
      // 단계별 알림
      if (step.title.contains('시작')) {
        await notificationService.notifyStageStart(
          stageName: step.title.replaceAll(' 시작', ''),
          duration: Duration(hours: 2),
        );
      } else if (step.title.contains('완료')) {
        await notificationService.notifyStageComplete(
          stageName: step.title.replaceAll(' 완료', ''),
        );
      }
    }
    print('');

    // 5단계: 결과 요약
    print('5️⃣ 진행 상황 요약:');
    final updatedSetupGuide = guideSystem.getGuide(setupGuide.id)!;
    final updatedProgressGuide = guideSystem.getGuide(progressGuide.id)!;

    print('   설정 가이드 진행률: ${(updatedSetupGuide.progress * 100).toInt()}%');
    print('   발효 가이드 진행률: ${(updatedProgressGuide.progress * 100).toInt()}%');
    print('   완료된 총 단계: ${updatedSetupGuide.completedStepsCount + updatedProgressGuide.completedStepsCount}개');
    print('   예상 남은 시간: ${_formatDuration(
      updatedSetupGuide.estimatedRemainingTime + updatedProgressGuide.estimatedRemainingTime
    )}');
    print('');

    print('🎉 실제 사용 시나리오 테스트 완료!');
    print('   사용자는 이제 체계적인 가이드를 통해');
    print('   완벽한 사워도우 빵을 만들 수 있습니다.');
    
    print('\n' + '=' * 60 + '\n');
  }

  /// 가이드 진행 시뮬레이션
  static Future<void> _simulateGuideProgress(
    UserGuideSystem guideSystem,
    UserGuide guide,
  ) async {
    for (int i = 0; i < guide.steps.length && i < 3; i++) {
      final step = guide.steps[i];
      print('   ${i + 1}. ${step.title}');
      print('      우선순위: ${_getPriorityText(step.priority)}');
      print('      예상 시간: ${step.estimatedTime != null ? _formatDuration(step.estimatedTime!) : '미정'}');
      
      if (step.instructions.isNotEmpty) {
        print('      주요 지침: ${step.instructions.first}');
      }
      
      // 단계 완료 시뮬레이션
      await guideSystem.completeStep(guide.id, step.id);
      final updatedGuide = guideSystem.getGuide(guide.id)!;
      print('      ✅ 완료 (전체 진행률: ${(updatedGuide.progress * 100).toInt()}%)');
      print('');
    }

    if (guide.steps.length > 3) {
      print('   ... 총 ${guide.steps.length}개 단계 중 3개 시뮬레이션 완료');
    }
  }

  /// 모든 데모 실행
  static Future<void> runAllDemos() async {
    print('🚀 통합 사용자 가이드 시스템 데모 시작\n');
    print('=' * 60);
    print('');
    
    await demoCompleteSetupWorkflow();
    await demoTroubleshootingAndMaintenance();
    await demoNotificationIntegration();
    await demoAdvancedFeatures();
    await demoRealWorldScenario();
    
    print('✅ 모든 데모 완료!');
    print('');
    print('🎯 통합 사용자 가이드 시스템의 주요 특징:');
    print('   • 발효기 설정부터 문제 해결까지 완전 자동화');
    print('   • 레시피 특성 기반 맞춤형 가이드 생성');
    print('   • 단계별 진행 관리 및 자동 알림');
    print('   • 스마트 알림과 진동/소리 통합');
    print('   • 가이드 히스토리 및 설정 관리');
    print('   • 실시간 진행률 추적 및 예상 시간 계산');
    print('');
    print('🏆 이제 사용자는 복잡한 발효 과정을 걱정 없이');
    print('   체계적이고 안전하게 진행할 수 있습니다!');
  }

  // Helper methods
  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}시간 ${minutes}분';
    } else {
      return '${minutes}분';
    }
  }

  static String _getPriorityText(GuidePriority priority) {
    switch (priority) {
      case GuidePriority.critical:
        return '필수';
      case GuidePriority.important:
        return '중요';
      case GuidePriority.helpful:
        return '도움';
      case GuidePriority.optional:
        return '선택';
    }
  }
}

/// 데모 실행 함수
void main() async {
  await UserGuideDemo.runAllDemos();
}