// 믹싱 경고 서비스
// 차수별 특성에 맞는 간단한 경고 메시지를 생성하는 서비스 클래스

import '../core/types/environment_types.dart';

/// 믹싱 경고 서비스 클래스
/// 각 단계별 특성에 맞는 간단한 경고 메시지를 생성하고 관리
class MixingWarningService {
  /// 기본 경고 메시지 생성
  static String generateComprehensiveWarning({
    required int stepIndex,
    required String speed,
    required int duration,
    required Map<String, dynamic> recipeData,
    required double hydrationPercentage,
    required UserEnvironment environment,
    required int totalSteps,
  }) {
    final warnings = <String>[];

    // 시간 경고
    if (duration > 10) {
      warnings.add('⏰ ${stepIndex + 1}단계: 믹싱 시간이 ${duration}분으로 길어요');
    }

    // 속도 경고
    if (speed == '고속' && stepIndex == totalSteps - 1) {
      warnings.add('⚠️ 마무리 단계에서 고속 믹싱을 사용 중입니다');
    }

    return warnings.join('\n');
  }

  /// 기본 위험 분석 수행 (빅데이터 분석 제거)
  /// 사용자 입력 데이터만으로 간단한 위험 평가
  static Map<String, dynamic> performBasicRiskAnalysis({
    required List<Map<String, dynamic>> mixingSteps,
    required Map<String, dynamic> recipeData,
    required UserEnvironment environment,
  }) {
    // 총 믹싱 시간 계산
    int totalTime = 0;
    for (final step in mixingSteps) {
      totalTime += (step['durationMinutes'] as int?) ?? 0;
    }

    return {
      'analysis': '기본 위험 분석 완료',
      'totalMixingTime': totalTime,
      'riskLevel': totalTime > 15 ? 'medium' : 'low',
      'recommendation': '믹싱 시간을 적정하게 유지하세요',
    };
  }

  /// 통합 피드백 생성 (기본 구현)
  static List<String> generateIntegratedFeedback(
    Map<String, dynamic> step,
    Map<String, dynamic> doughState,
    Map<String, dynamic>? previousStepAnalysis,
    Map<String, dynamic>? previousDoughState,
    int stepIndex,
  ) {
    return ['✅ 기본 피드백 제공'];
  }

  /// 반죽 온도 경고 생성 (기본 구현)
  static String generateDoughTemperatureWarning(
    int stepIndex,
    String speed,
    int duration,
    double currentDoughTemp,
    double roomTemp,
    double initialDoughTemp,
  ) {
    if (currentDoughTemp > 35) {
      return '🔥 반죽 온도가 너무 높습니다 (${currentDoughTemp.toStringAsFixed(1)}°C)';
    } else if (currentDoughTemp < 20) {
      return '🧊 반죽 온도가 너무 낮습니다 (${currentDoughTemp.toStringAsFixed(1)}°C)';
    }
    return '';
  }
}
