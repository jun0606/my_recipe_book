// 빵 믹싱 분석기
// 믹싱 단계별 분석을 수행하는 서비스 클래스

/// 빵 믹싱 분석 결과 클래스
class MixingAnalysisResult {
  final Map<String, dynamic> resultData;
  final double successProbability;
  final String riskLevel;
  final List<Map<String, dynamic>> issues;
  final List<Map<String, dynamic>> recommendations;

  const MixingAnalysisResult({
    required this.resultData,
    required this.successProbability,
    required this.riskLevel,
    required this.issues,
    required this.recommendations,
  });

  Map<String, dynamic> toMap() {
    return {
      'resultData': resultData,
      'successProbability': successProbability,
      'riskLevel': riskLevel,
      'issues': issues,
      'recommendations': recommendations,
    };
  }
}

/// 빵 믹싱 분석기 클래스
class BreadMixingAnalyzer {
  /// 기본 믹싱 단계 분석 (호환성 유지)
  static Map<String, dynamic> calculateMixingStageAnalysis(
    Map<String, dynamic> recipeData, [
    List<dynamic>? mixingData,
  ]) {
    // mixingData가 제공되지 않은 경우 기본 데이터 생성
    final defaultMixingData = mixingData ??
        [
          {'speed': '중속', 'time': 5, 'comment': '초기 반죽 단계'},
          {'speed': '중속', 'time': 8, 'comment': '본 반죽 단계'},
          {'speed': '저속', 'time': 3, 'comment': '마무리 단계'},
        ];

    return calculateMixingStageAnalysisWithRPM(recipeData, defaultMixingData);
  }

  /// RPM 기반 믹싱 단계 분석
  static Map<String, dynamic> calculateMixingStageAnalysisWithRPM(
    Map<String, dynamic> recipeData,
    List<dynamic> mixingData,
  ) {
    final analysis = <String, dynamic>{};

    // RPM 프로파일 계산
    final rpmProfile = _calculateRPMProfile(mixingData);
    analysis['rpmProfile'] = rpmProfile;

    // 차수별 분석
    final stageAnalysis = _analyzeStagesByRPM(mixingData);
    analysis['차수별 분석'] = stageAnalysis;

    // 성공 확률 계산
    final successProbability =
        _calculateMixingSuccessProbability(rpmProfile, stageAnalysis);
    analysis['successProbability'] = successProbability;

    // 위험도 평가
    final riskLevel = _evaluateMixingRiskLevel(successProbability);
    analysis['riskLevel'] = riskLevel;

    // 문제점 식별
    final issues = _identifyMixingIssues(mixingData, rpmProfile);
    analysis['issues'] = issues;

    return analysis;
  }

  /// RPM 프로파일 계산
  static Map<String, dynamic> _calculateRPMProfile(List<dynamic> mixingData) {
    final profile = <String, dynamic>{};

    for (int i = 0; i < mixingData.length; i++) {
      final step = mixingData[i] as Map<String, dynamic>;
      final speed = step['speed'] as String? ?? '중속';
      // 여러 가능한 키 시도
      final duration = step['durationMinutes'] as int? ??
          step['time'] as int? ??
          step['duration'] as int? ??
          5;

      // 속도에 따른 RPM 계산
      final rpm = _speedToRPM(speed);
      profile['단계 ${i + 1}'] = {
        '속도': speed,
        'RPM': rpm,
        '시간': duration,
        '예상_열_발생량': _calculateHeatGeneration(rpm, duration),
      };
    }

    return profile;
  }

  /// 차수별 RPM 기반 분석
  static List<Map<String, dynamic>> _analyzeStagesByRPM(
      List<dynamic> mixingData) {
    final stageResults = <Map<String, dynamic>>[];

    for (int i = 0; i < mixingData.length; i++) {
      final step = mixingData[i] as Map<String, dynamic>;
      final speed = step['speed'] as String? ?? '중속';
      // 여러 가능한 키 시도
      final duration = step['durationMinutes'] as int? ??
          step['time'] as int? ??
          step['duration'] as int? ??
          5;

      final rpm = _speedToRPM(speed);
      final analysis = <String, dynamic>{
        '단계': i + 1,
        '속도': speed,
        'RPM': rpm,
        '시간': duration,
        '효율성': _calculateMixingEfficiency(rpm, duration, i),
        '권장사항': _getStageRecommendation(i, speed, duration),
      };

      stageResults.add(analysis);
    }

    return stageResults;
  }

  /// 속도를 RPM으로 변환
  static int _speedToRPM(String speed) {
    switch (speed) {
      case '저속':
        return 80;
      case '중속':
        return 130;
      case '고속':
        return 200;
      default:
        return 130;
    }
  }

  /// 열 발생량 계산
  static double _calculateHeatGeneration(int rpm, int duration) {
    // RPM과 시간에 따른 열 발생량 계산
    return (rpm * duration * 0.01).clamp(0.0, 10.0);
  }

  /// 믹싱 효율성 계산
  static double _calculateMixingEfficiency(
      int rpm, int duration, int stageIndex) {
    double efficiency = 1.0;

    // RPM 최적 범위 확인 (80-200 RPM)
    if (rpm < 80 || rpm > 200) {
      efficiency *= 0.8;
    }

    // 시간 효율성
    if (duration > 10) {
      efficiency *= 0.9;
    }

    // 단계별 최적 조건
    if (stageIndex == 0 && rpm > 150) {
      efficiency *= 0.9; // 1단계 고속 감점
    }

    return efficiency.clamp(0.0, 1.0);
  }

  /// 단계별 권장사항
  static String _getStageRecommendation(
      int stageIndex, String speed, int duration) {
    switch (stageIndex) {
      case 0: // 1단계
        if (speed == '고속') {
          return '1단계는 중속으로 시작하는 것이 좋습니다';
        }
        return '균일한 재료 혼합에 적합합니다';
      case 1: // 2단계
        if (duration < 5) {
          return '글루텐 형성을 위해 5분 이상 권장합니다';
        }
        return '글루텐 네트워크 형성에 최적입니다';
      case 2: // 3단계
        if (speed == '고속' && duration > 4) {
          return '마무리 단계 고속은 4분 이내로 유지하세요';
        }
        return '안정적인 마무리에 적합합니다';
      default:
        return '표준 믹싱 조건을 유지하세요';
    }
  }

  /// 믹싱 성공 확률 계산
  static double _calculateMixingSuccessProbability(
    Map<String, dynamic> rpmProfile,
    List<Map<String, dynamic>> stageAnalysis,
  ) {
    double totalScore = 0.0;
    int totalStages = stageAnalysis.length;

    for (final stage in stageAnalysis) {
      final efficiency = stage['효율성'] as double? ?? 0.0;
      totalScore += efficiency;
    }

    return totalScore / totalStages;
  }

  /// 믹싱 위험도 평가
  static String _evaluateMixingRiskLevel(double successProbability) {
    if (successProbability >= 0.9) return '매우 낮음 (A등급)';
    if (successProbability >= 0.8) return '낮음 (B등급)';
    if (successProbability >= 0.7) return '보통 (C등급)';
    if (successProbability >= 0.6) return '높음 (D등급)';
    return '매우 높음 (F등급)';
  }

  /// 믹싱 문제점 식별
  static List<Map<String, dynamic>> _identifyMixingIssues(
    List<dynamic> mixingData,
    Map<String, dynamic> rpmProfile,
  ) {
    final issues = <Map<String, dynamic>>[];

    for (int i = 0; i < mixingData.length; i++) {
      final step = mixingData[i] as Map<String, dynamic>;
      final speed = step['speed'] as String? ?? '중속';
      // 여러 가능한 키 시도
      final duration = step['durationMinutes'] as int? ??
          step['time'] as int? ??
          step['duration'] as int? ??
          5;

      // 1단계 고속 문제
      if (i == 0 && speed == '고속') {
        issues.add({
          'description': '1단계에서 고속 믹싱이 사용되었습니다',
          'severity': 'medium',
          'recommendation': '초기 재료 혼합에는 중속을 권장합니다',
          'expected_impact': '더 균일한 반죽 형성',
        });
      }

      // 긴 믹싱 시간 문제
      if (duration > 8) {
        issues.add({
          'description': '${i + 1}단계 믹싱 시간이 ${duration}분으로 깁니다',
          'severity': 'high',
          'recommendation': '글루텐 과도 발달을 방지하기 위해 시간을 단축하세요',
          'expected_impact': '반죽 질감 개선',
        });
      }

      // 마무리 단계 고속 문제
      if (i == mixingData.length - 1 && speed == '고속' && duration > 3) {
        issues.add({
          'description': '마무리 단계에서 고속 믹싱이 ${duration}분 사용되었습니다',
          'severity': 'high',
          'recommendation': '글루텐 구조 보호를 위해 저속으로 마무리하세요',
          'expected_impact': '반죽 구조 안정화',
        });
      }
    }

    return issues;
  }
}
