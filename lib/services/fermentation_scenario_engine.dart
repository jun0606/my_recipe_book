import 'package:my_recipe_book/models/fermentation_scenario_v2.dart';
import 'package:my_recipe_book/models/sous_chef_models.dart'; // For BakingType, etc.
import 'package:my_recipe_book/models/advanced_sous_chef_models.dart'
    as advanced_models;
import 'package:my_recipe_book/models/environmental_conditions.dart'
    as env_conditions;

class EnvironmentalChange {
  final advanced_models.EnvironmentalConditions newConditions;

  EnvironmentalChange({required this.newConditions});
}

/// AI 시나리오 엔진 (FermentationScenarioEngine)
/// 모든 입력 조건을 분석하여 완벽한 발효 시나리오를 생성하고 관리합니다.
class FermentationScenarioEngine {
  /// 로깅을 위한 분석 세션 ID
  String? _currentAnalysisSessionId;

  /// 로깅 헬퍼
  void _log(String message, {String? level = 'INFO', dynamic data}) {
    final timestamp = DateTime.now().toIso8601String();
    final sessionId = _currentAnalysisSessionId ?? 'unknown';
    final logMessage =
        '[$timestamp] [FermentationScenarioEngine] [$sessionId] [$level] $message';

    if (data != null) {
      print('$logMessage | Data: $data');
    } else {
      print(logMessage);
    }
  }

  /// 분석 세션 시작 로깅
  void _startAnalysisSession() {
    _currentAnalysisSessionId =
        'fermentation_session_${DateTime.now().millisecondsSinceEpoch}';
    _log('=== 발효 시나리오 분석 세션 시작 ===', level: 'START');
  }

  /// 분석 세션 종료 로깅
  void _endAnalysisSession({String? result = 'unknown', dynamic error}) {
    if (error != null) {
      _log('=== 발효 시나리오 분석 세션 실패 ===', level: 'ERROR', data: error);
    } else {
      _log('=== 발효 시나리오 분석 세션 완료 ===',
          level: 'SUCCESS', data: {'result': result});
    }
    _currentAnalysisSessionId = null;
  }

  /// 메인 시나리오 생성 메서드
  /// 레시피, 환경, 장비 정보를 종합 분석하여 최적의 발효 시나리오를 생성합니다.
  Future<FermentationScenarioV2> generateScenario({
    required FermentationMode mode, // 실온 vs 발효기
    required FermentationMethodV2 method, // 일반/저온/냉동
    required RecipeAnalysis recipe, // 레시피 분석 결과
    required advanced_models.EnvironmentalConditions env, // 현재 환경
    required EquipmentProfile equipment, // 사용 장비
  }) async {
    _startAnalysisSession();

    try {
      _log('시나리오 생성 시작', data: {
        'mode': mode.name,
        'method': method.name,
        'env_temperature': env.temperature,
        'equipment_info': equipment.toString(),
      });

      // 기본 발효 시간 계산
      Duration totalDuration = _calculateBaseFermentationTime(
        recipe: recipe,
        env: env,
        mode: mode,
        method: method,
      );

      _log('기본 발효 시간 계산 완료', data: {
        'total_duration_hours': totalDuration.inHours,
        'total_duration_minutes': totalDuration.inMinutes,
        'mode': mode.name,
        'method': method.name,
      });

      List<FermentationStageV2> stages = [];

      // 단계별 시간 분배 계산
      Duration primaryFermentationDuration =
          Duration(milliseconds: (totalDuration.inMilliseconds * 0.6).round());
      Duration proofingDuration =
          Duration(milliseconds: (totalDuration.inMilliseconds * 0.2).round());
      Duration finalFermentationDuration =
          Duration(milliseconds: (totalDuration.inMilliseconds * 0.2).round());

      _log('단계별 시간 분배', data: {
        'primary_duration': primaryFermentationDuration.inMinutes,
        'proofing_duration': proofingDuration.inMinutes,
        'final_duration': finalFermentationDuration.inMinutes,
      });

      // 1차 발효 단계 생성
      _log('1차 발효 단계 생성 시작');
      stages.add(FermentationStageV2(
        name: '1차 발효 단계',
        type: FermentationStageType.primary,
        duration: primaryFermentationDuration,
        temperature: TemperatureRange(min: 20, max: 25, optimal: 22.5),
        humidity: HumidityRange(min: 70, max: 80, optimal: 75),
        instructions: [
          UserInstruction(
            action: '반죽 상태 확인',
            description: '반죽이 2배로 부풀었는지 확인하세요.',
            timing: Duration.zero,
            priority: InstructionPriority.important,
            visualAids: [],
            equipmentTarget: null,
          )
        ],
        automations: [],
        alerts: AlertSettings(
          enabled: true,
          beforeCompletion: const Duration(minutes: 5),
          notificationTypes: const ['push', 'sound'],
          message: '1차 발효 단계가 완료되었습니다.',
        ),
        description: '이것은 1차 발효 단계에 대한 설명입니다.',
        metadata: const {},
      ));
      _log('1차 발효 단계 생성 완료');

      // 휴지 단계 생성
      _log('휴지 단계 생성 시작');
      stages.add(FermentationStageV2(
        name: '휴지 단계',
        type: FermentationStageType.proofing,
        duration: proofingDuration,
        temperature: TemperatureRange(min: 20, max: 25, optimal: 22.5),
        humidity: HumidityRange(min: 70, max: 80, optimal: 75),
        instructions: [
          UserInstruction(
            action: '반죽 분할 및 성형',
            description: '반죽을 분할하고 원하는 모양으로 성형하세요.',
            timing: Duration.zero,
            priority: InstructionPriority.important,
            visualAids: [],
            equipmentTarget: null,
          )
        ],
        automations: [],
        alerts: AlertSettings(
          enabled: true,
          beforeCompletion: const Duration(minutes: 5),
          notificationTypes: const ['push', 'sound'],
          message: '휴지 단계가 완료되었습니다.',
        ),
        description: '이것은 휴지 단계에 대한 설명입니다.',
        metadata: const {},
      ));
      _log('휴지 단계 생성 완료');

      // 최종 발효 단계 생성
      _log('최종 발효 단계 생성 시작');
      stages.add(FermentationStageV2(
        name: '최종 발효 단계',
        type: FermentationStageType.finalStage,
        duration: finalFermentationDuration,
        temperature: TemperatureRange(min: 20, max: 25, optimal: 22.5),
        humidity: HumidityRange(min: 70, max: 80, optimal: 75),
        instructions: [
          UserInstruction(
            action: '오븐 예열 및 반죽 확인',
            description: '오븐을 예열하고 반죽이 충분히 부풀었는지 확인하세요.',
            timing: Duration.zero,
            priority: InstructionPriority.important,
            visualAids: [],
            equipmentTarget: null,
          )
        ],
        automations: [],
        alerts: AlertSettings(
          enabled: true,
          beforeCompletion: const Duration(minutes: 5),
          notificationTypes: const ['push', 'sound'],
          message: '최종 발효 단계가 완료되었습니다.',
        ),
        description: '이것은 최종 발효 단계에 대한 설명입니다.',
        metadata: const {},
      ));
      _log('최종 발효 단계 생성 완료');

      final scenario = FermentationScenarioV2(
        id: 'generated_scenario_${DateTime.now().millisecondsSinceEpoch}',
        name: 'AI 생성 발효 시나리오',
        description: 'AI 시나리오 엔진에 의해 생성된 시나리오입니다.',
        mode: mode,
        method: method,
        stages: stages,
        recipeAnalysis: recipe,
        environmentalConditions: env,
        equipment: equipment,
        createdAt: DateTime.now(),
        totalDuration: totalDuration,
      );

      _log('시나리오 생성 완료', data: {
        'scenario_id': scenario.id,
        'total_stages': stages.length,
        'total_duration_hours': totalDuration.inHours,
        'mode': mode.name,
        'method': method.name,
      });

      _endAnalysisSession(result: 'scenario_generated_successfully');
      return scenario;
    } catch (e) {
      _log('시나리오 생성 실패', level: 'ERROR', data: {
        'error': e.toString(),
        'mode': mode.name,
        'method': method.name,
      });
      _endAnalysisSession(error: {
        'error_message': e.toString(),
        'phase': 'scenario_generation',
        'mode': mode.name,
        'method': method.name,
      });
      rethrow;
    }
  }

  /// 실시간 시나리오 재계산
  /// 환경 변화를 감지하고 시나리오를 실시간으로 조정합니다.
  Future<FermentationScenarioV2> adaptScenario(
    FermentationScenarioV2 current,
    EnvironmentalChange change,
  ) async {
    // TODO: 환경 변화 감지 및 현재 시나리오에 대한 영향 분석
    // TODO: 발효 상태 예측 및 시나리오 재계산 로직 구현
    // TODO: 대안 제시 및 사용자에게 알림

    // 임시 반환값 (실제 구현 필요)
    return current.copyWith(
      name: '${current.name} (조정됨)',
      // 기타 조정된 필드 업데이트
    );
  }
}

// Helper methods for recipe analysis factors
extension on FermentationScenarioEngine {
  double _calculateYeastFactor(RecipeAnalysis recipe) {
    // Placeholder logic: assume yeast type/amount affects factor
    // For example, more yeast or instant yeast could mean a lower factor (faster fermentation)
    // This needs actual recipe analysis details to be accurate.
    return 1.0;
  }

  double _calculateFlourFactor(RecipeAnalysis recipe) {
    // Placeholder logic: assume flour type affects factor
    // For example, strong flour might mean a higher factor (slower fermentation)
    // This needs actual recipe analysis details to be accurate.
    return 1.0;
  }

  double _calculateSugarFactor(RecipeAnalysis recipe) {
    // Placeholder logic: assume sugar content affects factor
    // For example, higher sugar content might mean a lower factor (faster fermentation)
    // This needs actual recipe analysis details to be accurate.
    return 1.0;
  }

  // Helper methods for environmental impact
  double _calculateTemperatureFactor(
      advanced_models.EnvironmentalConditions env) {
    // Placeholder logic: assume temperature affects factor
    // For example, higher temperature could mean a lower factor (faster fermentation)
    // This needs actual environmental conditions details to be accurate.
    return 1.0;
  }

  double _calculateHumidityFactor(advanced_models.EnvironmentalConditions env) {
    // Placeholder logic: assume humidity affects factor
    // Humidity has less direct impact on timing, but can affect dough surface.
    // For now, a neutral factor.
    return 1.0;
  }

  // Helper method to calculate base fermentation time
  Duration _calculateBaseFermentationTime({
    required RecipeAnalysis recipe,
    required advanced_models.EnvironmentalConditions env,
    required FermentationMode mode,
    required FermentationMethodV2 method,
  }) {
    // Placeholder: This is where the actual calculation will go.
    // For now, return a default duration.
    // This will eventually use the factors calculated above.
    if (mode == FermentationMode.roomTemperature) {
      if (method == FermentationMethodV2.normal) {
        return const Duration(hours: 4);
      } else if (method == FermentationMethodV2.coldRetardation) {
        return const Duration(hours: 12);
      } else if (method == FermentationMethodV2.freezerOvernight) {
        return const Duration(hours: 24);
      } else {
        return const Duration(hours: 8); // Default for other methods
      }
    } else {
      return const Duration(hours: 8); // Default for other modes
    }
  }
}
