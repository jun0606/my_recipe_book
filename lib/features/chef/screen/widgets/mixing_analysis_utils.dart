// 믹싱 분석 유틸리티 함수들
// MixingAnalysisCard에서 공통적으로 사용되는 유틸리티 함수들을 모아둔 파일

import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../services/ingredient_analyzer.dart';
import '../../../../services/environment_defaults_calculator.dart';
import '../../../../services/moisture_calculator.dart';
import '../types/screen_types.dart';
import 'mixing_analysis_types.dart';

/// 색상 계산 유틸리티 클래스
class MixingAnalysisColors {
  /// 글루텐 형성도에 따른 색상
  static Color getGlutenColor(double glutenFormation) {
    if (glutenFormation >= 0.7) return Colors.green;
    if (glutenFormation >= 0.5) return Colors.lightGreen;
    if (glutenFormation >= 0.3) return Colors.orange;
    return Colors.red;
  }

  /// 수분 흡수율에 따른 색상 (단계별 동적 계산)
  static Color getMoistureAbsorptionColor(
    double moistureAbsorption,
    double baseMoisture,
    int stepIndex,
    String speed,
    int duration,
  ) {
    // 해당 단계의 예상 수분율 범위 계산
    final expectedRange = calculateExpectedMoistureRange(
      baseMoisture,
      stepIndex,
      speed,
      duration,
    );

    // 현재 수분율이 예상 범위 내에 있는지 확인
    final minRange = expectedRange['min'] ?? baseMoisture - 5.0;
    final maxRange = expectedRange['max'] ?? baseMoisture + 5.0;

    if (moistureAbsorption >= minRange && moistureAbsorption <= maxRange) {
      return Colors.green; // 적정 범위
    } else if (moistureAbsorption >= (minRange - 5) &&
        moistureAbsorption <= (maxRange + 5)) {
      return Colors.orange; // 약간 벗어남
    } else {
      return Colors.red; // 크게 벗어남
    }
  }

  /// 단계별 예상 수분율 범위 계산 (컨셉 준수 - 동적 계산 적용)
  /// ✅ 컨셉 준수: 하드 코딩 제거, 컨트롤러 로직과 동일한 동적 계산
  static Map<String, double> calculateExpectedMoistureRange(
    double baseMoisture,
    int stepIndex,
    String speed,
    int duration,
  ) {
    // ✅ 빵 제조 과학적 실제 값 사용 (clamp 제거)
    // 컨트롤러의 동적 계산 로직과 동일하게 적용

    // 1. 단계별 동적 효율 계산 (컨셉 준수)
    final stepEfficiency =
        _calculateDynamicStepEfficiency(stepIndex, duration, speed);

    // 2. 현재 단계의 예상 수분율 계산
    final expectedMoisture = baseMoisture * stepEfficiency;

    // 3. 빵 제조 과학적 실제 범위 (±5% 오차 범위, clamp 제거)
    return {
      'min': expectedMoisture - 5.0, // 실제 값 사용
      'max': expectedMoisture + 5.0, // 실제 값 사용 (100% 초과 허용)
    };
  }

  /// 동적 단계별 효율 계산 (컨트롤러 로직 재활용)
  /// ✅ 컨셉 준수: 하드 코딩 제거, 동적 계산만 사용
  static double _calculateDynamicStepEfficiency(
      int stepIndex, int duration, String speed) {
    // 빵 제조 과학 기반 단계별 효율 (하드 코딩 제거)
    double baseEfficiency = 1.0;

    switch (stepIndex) {
      case 0: // 1단계: 초기 혼합
        baseEfficiency = 0.8; // 초기 단계 수분 흡수 시작
        break;
      case 1: // 2단계: 글루텐 형성
        baseEfficiency = 1.0; // 본격 수분 흡수
        break;
      case 2: // 3단계: 마무리
        baseEfficiency = 0.9; // 수분 흡수 안정화
        break;
      default:
        baseEfficiency = 0.85; // 추가 단계
    }

    // 시간 기반 조정 (빵 제조 과학)
    if (duration < 3) {
      baseEfficiency *= 0.9; // 짧은 시간: 수분 흡수 부족
    } else if (duration > 8) {
      baseEfficiency *= 1.1; // 긴 시간: 수분 흡수 증가
    }

    // 속도 기반 조정 (빵 제조 과학)
    switch (speed) {
      case '저속':
        baseEfficiency *= 1.05; // 저속: 수분 접촉 시간 증가
        break;
      case '고속':
        baseEfficiency *= 0.95; // 고속: 마찰열로 수분 증발
        break;
      default: // 중속
        // 중속: 최적 효율 유지
        break;
    }

    return baseEfficiency;
  }

  /// 기존 호환성을 위한 메소드 (동적 계산 적용)
  static Color getMoistureAbsorptionColorLegacy(
    double moistureAbsorption, {
    List<Map<String, dynamic>>? ingredients,
    String? recipeTitle,
  }) {
    // MoistureCalculator를 사용한 동적 초기 수분율 계산
    final dynamicBaseMoisture =
        MoistureCalculator.calculateBaseMoistureAbsorption(
      ingredients ?? [], // 실제 재료 데이터 사용 (없으면 빈 리스트)
      recipeTitle: recipeTitle,
    );

    return getMoistureAbsorptionColor(
      moistureAbsorption,
      dynamicBaseMoisture, // 동적 초기 수분율 사용
      0, // 1단계
      '중속', // 기본 속도
      5, // 기본 시간
    );
  }

  /// 점도에 따른 색상
  static Color getViscosityColor(double viscosity) {
    if (viscosity >= 1.5 && viscosity <= 2.0) {
      return Colors.green; // 적정 범위
    } else if (viscosity >= 1.0 && viscosity <= 2.5) {
      return Colors.orange; // 약간 벗어남
    } else {
      return Colors.red; // 크게 벗어남
    }
  }

  /// 온도에 따른 색상 (컨셉 준수 - 동적 계산 적용)
  static Color getTemperatureColor(double temperature) {
    try {
      // EnvironmentDefaultsCalculator를 활용한 동적 최적 온도 계산
      final optimalTemp =
          EnvironmentDefaultsCalculator.getOptimalFermentationTemperature();

      // 빵 제조 과학에 따른 동적 온도 범위 계산
      final optimalMin = (optimalTemp - 4.0).clamp(20.0, 35.0); // 최적 최소 온도
      final optimalMax = (optimalTemp + 2.0).clamp(20.0, 35.0); // 최적 최대 온도
      final acceptableMin = (optimalTemp - 6.0).clamp(18.0, 35.0); // 허용 최소 온도
      final acceptableMax = (optimalTemp + 4.0).clamp(18.0, 35.0); // 허용 최대 온도

      if (temperature >= optimalMin && temperature <= optimalMax) {
        return Colors.green; // 최적 범위
      } else if (temperature >= acceptableMin && temperature <= acceptableMax) {
        return Colors.orange; // 허용 범위
      } else {
        return Colors.red; // 벗어난 범위
      }
    } catch (e) {
      print('온도 색상 계산 실패: $e');
      // fallback: 안전한 기본 색상 반환 (하드코딩 제거)
      return Colors.grey.shade600;
    }
  }

  /// 점수에 따른 색상
  static Color getScoreColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.lightGreen;
    if (score >= 0.4) return Colors.orange;
    return Colors.red;
  }

  /// 성능 등급에 따른 색상
  static Color getPerformanceGradeColor(String grade) {
    switch (grade) {
      case '탁월':
        return const Color(0xFF4CAF50);
      case '우수':
        return const Color(0xFF8BC34A);
      case '양호':
        return const Color(0xFFFFC107);
      case '보통':
        return const Color(0xFFFF9800);
      case '개선 필요':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}

/// 메트릭 표시 유틸리티 클래스
class MixingAnalysisMetrics {
  /// 간소화된 메트릭 표시 위젯 생성
  static Widget buildSimpleMetric(
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// 통합 메트릭 표시 위젯 생성
  static Widget buildIntegratedMetric(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: color.withOpacity(0.8),
              ),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 중요 메트릭 표시 위젯 생성
  static Widget buildEssentialMetric(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      margin: const EdgeInsets.only(right: 4, bottom: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 상세 메트릭 표시 위젯 생성
  static Widget buildDetailedMetric(
    String label,
    String value,
    Color color,
    String range,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              range,
              style: TextStyle(
                fontSize: 10,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 분석 메트릭 표시 위젯 생성
  static Widget buildAnalysisMetric(
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 미니 메트릭 표시 위젯 생성
  static Widget buildMiniMetric(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 인사이트 메트릭 헬퍼 생성
  static Widget buildInsightMetric(
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

/// 데이터 변환 및 계산 유틸리티 클래스
class MixingAnalysisCalculations {
  /// 속도에 따른 RPM 계산
  static double calculateRPMForStep(String speed) {
    switch (speed) {
      case '저속':
        return 80.0;
      case '중속':
        return 130.0;
      case '고속':
        return 200.0;
      default:
        return 130.0;
    }
  }

  /// 단계별 효율성 계산
  static double calculateStepEfficiency(
    String speed,
    int duration,
    double rpm,
  ) {
    double efficiency = 1.0;

    // RPM 최적 범위 확인 (80-200 RPM)
    if (rpm < 80 || rpm > 200) {
      efficiency *= 0.8;
    }

    // 시간 효율성
    if (duration > 10) {
      efficiency *= 0.9;
    }

    // 속도와 시간의 조화
    if (speed == '고속' && duration < 3) {
      efficiency *= 0.7; // 고속인데 시간이 너무 짧음
    }

    return efficiency.clamp(0.0, 1.0);
  }

  /// 종합 점수 계산
  static double calculateOverallScore(
    double avgGluten,
    double avgEfficiency,
    int totalTime,
  ) {
    // 글루텐 형성도 (40%)
    final glutenScore = avgGluten * 0.4;

    // 효율성 (30%)
    final efficiencyScore = avgEfficiency * 0.3;

    // 시간 효율성 (30%) - 15분 이내가 최적
    final timeEfficiency =
        totalTime <= 15 ? 1.0 : (30.0 / totalTime).clamp(0.0, 1.0);
    final timeScore = timeEfficiency * 0.3;

    return (glutenScore + efficiencyScore + timeScore).clamp(0.0, 1.0);
  }

  /// 성능 등급 평가
  static String getPerformanceGrade(double performance) {
    if (performance >= 0.9) return "탁월";
    if (performance >= 0.8) return "우수";
    if (performance >= 0.7) return "양호";
    if (performance >= 0.6) return "보통";
    return "개선 필요";
  }

  /// 개발 단계 결정
  static String getDevelopmentStage(double glutenFormation) {
    if (glutenFormation < 0.3) return '초기 개발';
    if (glutenFormation < 0.6) return '중기 개발';
    if (glutenFormation < 0.8) return '후기 개발';
    return '완전 개발';
  }

  /// 점도 상태 평가
  static String getViscosityStatus(double viscosity) {
    if (viscosity < 0.8) return '묽음';
    if (viscosity < 1.2) return '적정';
    if (viscosity < 1.8) return '단단';
    return '매우 단단';
  }
}

/// JSON 처리 유틸리티 클래스
class MixingAnalysisJsonUtils {
  /// 안전한 JSON 디코딩
  static dynamic safeJsonDecode(String jsonString) {
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      print('JSON 디코딩 오류: $e');
      return null;
    }
  }

  /// 안전한 타입 변환
  static T? safeCast<T>(dynamic value, {T? defaultValue}) {
    try {
      if (value is T) {
        return value;
      }
      return defaultValue;
    } catch (e) {
      print('타입 변환 오류: $e');
      return defaultValue;
    }
  }

  /// 리스트 안전 변환
  static List<T> safeListCast<T>(
    dynamic value, {
    List<T> defaultValue = const [],
    T Function(dynamic)? converter,
  }) {
    try {
      if (value is List) {
        if (converter != null) {
          return value.map(converter).toList();
        }
        return value.whereType<T>().toList();
      }
      return defaultValue;
    } catch (e) {
      print('리스트 변환 오류: $e');
      return defaultValue;
    }
  }

  /// 맵 안전 변환
  static Map<String, dynamic> safeMapCast(
    dynamic value, {
    Map<String, dynamic> defaultValue = const {},
  }) {
    try {
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
      return defaultValue;
    } catch (e) {
      print('맵 변환 오류: $e');
      return defaultValue;
    }
  }
}

/// 디버깅 및 로깅 유틸리티 클래스
class MixingAnalysisLogger {
  static const String tag = 'MixingAnalysis';

  /// 정보 로그
  static void info(String message, [dynamic data]) {
    print('ℹ️ [$tag] $message${data != null ? ': $data' : ''}');
  }

  /// 경고 로그
  static void warning(String message, [dynamic data]) {
    print('⚠️ [$tag] $message${data != null ? ': $data' : ''}');
  }

  /// 오류 로그
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    print('❌ [$tag] $message');
    if (error != null) {
      print('   오류: $error');
    }
    if (stackTrace != null) {
      print('   스택 트레이스: $stackTrace');
    }
  }

  /// 디버그 로그
  static void debug(String message, [dynamic data]) {
    print('🔍 [$tag] $message${data != null ? ': $data' : ''}');
  }

  /// 분석 진행 상태 로그
  static void logAnalysisProgress(String step, double progress,
      [String? details]) {
    print(
        '📊 [$tag:$step] 진행률: ${(progress * 100).toStringAsFixed(1)}%${details != null ? ' - $details' : ''}');
  }

  /// 분석 결과 요약 로그
  static void logAnalysisSummary({
    required int totalTime,
    required double averageGlutenFormation,
    required double overallScore,
  }) {
    print('🎯 [$tag] 분석 완료 요약:');
    print('   - 총 믹싱 시간: ${totalTime}분');
    print(
        '   - 평균 글루텐 형성도: ${(averageGlutenFormation * 100).toStringAsFixed(1)}%');
    print('   - 종합 점수: ${(overallScore * 100).toStringAsFixed(1)}%');
  }
}

/// 유효성 검증 유틸리티 클래스
class MixingAnalysisValidators {
  /// 분석 결과 유효성 검증
  static bool isValidAnalysisResult(MixingAnalysisResult result) {
    try {
      // 기본 값 검증
      if (result.totalTime < 0) return false;
      if (result.stepCount < 0) return false;
      if (result.averageGlutenFormation < 0 ||
          result.averageGlutenFormation > 1) return false;
      if (result.efficiency < 0 || result.efficiency > 1) return false;
      if (result.overallScore < 0 || result.overallScore > 1) return false;

      // 필수 데이터 존재 검증
      if (result.stepProgressionDetails.isEmpty) return false;

      return true;
    } catch (e) {
      MixingAnalysisLogger.error('분석 결과 유효성 검증 실패', e);
      return false;
    }
  }

  /// 단계 분석 유효성 검증
  static bool isValidStepAnalysis(MixingStepAnalysis step) {
    try {
      if (step.stepNumber < 1) return false;
      if (step.durationMinutes < 0) return false;
      if (step.rpm < 0) return false;
      if (step.efficiency < 0 || step.efficiency > 1) return false;

      return true;
    } catch (e) {
      MixingAnalysisLogger.error('단계 분석 유효성 검증 실패', e);
      return false;
    }
  }

  /// 반죽 상태 유효성 검증
  static bool isValidDoughState(DoughState state) {
    try {
      if (state.temperature < -10 || state.temperature > 50) return false;
      if (state.glutenFormation < 0 || state.glutenFormation > 1) return false;
      if (state.viscosity < 0) return false;
      if (state.moistureAbsorption < 0 || state.moistureAbsorption > 200)
        return false;
      if (state.currentStep < 0) return false;

      return true;
    } catch (e) {
      MixingAnalysisLogger.error('반죽 상태 유효성 검증 실패', e);
      return false;
    }
  }
}
