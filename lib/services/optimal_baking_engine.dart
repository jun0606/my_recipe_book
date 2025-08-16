/// 최적 굽기 조건 계산 엔진
/// 종합 제빵 과학 통합 계산식을 기반으로 반죽 상태에 따른 최적 굽기 조건 계산

import 'dart:math' as math;
import '../services/dough_state_analyzer.dart';

class OptimalBakingEngine {
  /// 최적 굽기 조건 계산
  static OptimalBakingResult calculateOptimalBaking({
    required DoughStateAnalysisResult doughState,
    required List<Map<String, dynamic>> ingredients,
    required String ovenType,
    required String breadType,
    String? recipeTitle,
    double environmentTemperature = 25.0,
    double environmentHumidity = 65.0,
  }) {
    try {
      // 1. 오븐 특성 계수 계산
      final ovenCharacteristics = _calculateOvenCharacteristics(ovenType);
      
      // 2. 빵 종류별 기본 굽기 조건
      final baseBakingConditions = _getBaseBakingConditions(breadType);
      
      // 3. 반죽 상태 기반 조정
      final doughAdjustments = _calculateDoughStateAdjustments(doughState);
      
      // 4. 단계별 온도 프로파일 계산
      final temperatureProfile = _calculateTemperatureProfile(
        baseBakingConditions,
        doughAdjustments,
        ovenCharacteristics,
        doughState,
      );
      
      // 5. 총 굽기 시간 계산
      final totalBakingTime = _calculateTotalBakingTime(
        baseBakingConditions,
        doughAdjustments,
        ovenCharacteristics,
        doughState,
      );
      
      // 6. 스팀 설정 계산
      final steamSettings = _calculateSteamSettings(
        breadType,
        doughState,
        ovenCharacteristics,
        environmentHumidity,
      );
      
      // 7. 굽기 성공 예측 지수
      final successPrediction = _calculateSuccessPrediction(
        doughState,
        temperatureProfile,
        totalBakingTime,
        ovenCharacteristics,
      );
      
      return OptimalBakingResult(
        temperatureProfile: temperatureProfile,
        totalBakingTime: totalBakingTime,
        steamSettings: steamSettings,
        successPrediction: successPrediction,
        ovenType: ovenType,
        breadType: breadType,
        doughStateScore: doughState.overallDoughState,
        calculationTimestamp: DateTime.now(),
      );
    } catch (e) {
      print('최적 굽기 조건 계산 오류: $e');
      return OptimalBakingResult.empty();
    }
  }
  
  /// 오븐 특성 계수 계산
  static Map<String, double> _calculateOvenCharacteristics(String ovenType) {
    switch (ovenType.toLowerCase()) {
      case 'home_convection':
      case '가정용컨벡션':
        return {
          'efficiency': 0.8,
          'heatRecovery': 0.7,
          'uniformity': 0.8,
          'steamCapability': 0.3,
          'temperatureStability': 0.7,
        };
      case 'professional_convection':
      case '전문가용컨벡션':
        return {
          'efficiency': 1.0,
          'heatRecovery': 0.9,
          'uniformity': 0.95,
          'steamCapability': 0.7,
          'temperatureStability': 0.9,
        };
      case 'deck_oven':
      case '덱오븐':
        return {
          'efficiency': 1.2,
          'heatRecovery': 1.0,
          'uniformity': 1.0,
          'steamCapability': 0.9,
          'temperatureStability': 1.0,
        };
      default:
        return {
          'efficiency': 1.0,
          'heatRecovery': 0.8,
          'uniformity': 0.8,
          'steamCapability': 0.5,
          'temperatureStability': 0.8,
        };
    }
  }
  
  /// 빵 종류별 기본 굽기 조건 (현실적인 값으로 수정)
  static Map<String, dynamic> _getBaseBakingConditions(String breadType) {
    switch (breadType.toLowerCase()) {
      case 'bread':
      case 'loaf':
      case '식빵':
        return {
          'baseTemperature': 180.0,
          'baseTime': 25.0, // 35분 → 25분으로 단축
          'steamTime': 3.0, // 5분 → 3분으로 단축
          'steamAmount': 30.0, // 50% → 30%로 감소
        };
      case 'baguette':
      case '바게트':
        return {
          'baseTemperature': 200.0, // 220°C → 200°C로 낮춤
          'baseTime': 20.0, // 25분 → 20분으로 단축
          'steamTime': 10.0, // 15분 → 10분으로 단축
          'steamAmount': 60.0, // 80% → 60%로 감소
        };
      default:
        return {
          'baseTemperature': 180.0,
          'baseTime': 25.0, // 30분 → 25분으로 단축
          'steamTime': 3.0, // 5분 → 3분으로 단축
          'steamAmount': 30.0, // 50% → 30%로 감소
        };
    }
  }
  
  /// 반죽 상태 기반 조정 계수 계산
  static Map<String, double> _calculateDoughStateAdjustments(DoughStateAnalysisResult doughState) {
    final glutenAdjustment = doughState.glutenStrengthIndex > 10.0 ? 1.1 : 
                           doughState.glutenStrengthIndex > 6.0 ? 1.0 : 0.9;
    
    final fermentationAdjustment = doughState.fermentationProgress > 0.8 ? 0.9 : 
                                 doughState.fermentationProgress > 0.5 ? 1.0 : 1.1;
    
    return {
      'temperatureAdjustment': glutenAdjustment * fermentationAdjustment,
      'timeAdjustment': fermentationAdjustment,
    };
  }
  
  /// 단계별 온도 프로파일 계산 (현실적인 로직으로 수정)
  static Map<String, dynamic> _calculateTemperatureProfile(
    Map<String, dynamic> baseConditions,
    Map<String, double> adjustments,
    Map<String, double> ovenCharacteristics,
    DoughStateAnalysisResult doughState,
  ) {
    final baseTemp = baseConditions['baseTemperature'] as double;
    final tempAdjustment = adjustments['temperatureAdjustment']!;
    final ovenEfficiency = ovenCharacteristics['efficiency']!;
    
    // 오븐 효율이 높을수록 온도를 약간 낮춰도 됨 (나누기가 아닌 곱하기 보정)
    final efficiencyFactor = ovenEfficiency > 1.0 ? 0.95 : 1.0; // 고효율 오븐은 5% 낮춤
    
    // 현실적인 온도 프로파일: 초기 높음 → 중간 → 마지막 약간 낮춤
    final phase1Temp = (baseTemp + 10) * tempAdjustment * efficiencyFactor; // +20°C → +10°C로 수정
    final phase2Temp = baseTemp * tempAdjustment * efficiencyFactor;
    final phase3Temp = (baseTemp - 5) * tempAdjustment * efficiencyFactor; // -10°C → -5°C로 수정
    
    return {
      'phase1': {
        'temperature': phase1Temp.round().clamp(160, 220), // 온도 범위 제한
        'duration': 5,
        'description': '오븐 스프링 유도',
      },
      'phase2': {
        'temperature': phase2Temp.round().clamp(160, 200), // 온도 범위 제한
        'duration': 15,
        'description': '내부 익힘',
      },
      'phase3': {
        'temperature': phase3Temp.round().clamp(150, 190), // 온도 범위 제한
        'duration': 5, // 10분 → 5분으로 단축
        'description': '크러스트 완성',
      },
    };
  }
  
  /// 총 굽기 시간 계산 (현실적인 로직으로 수정)
  static int _calculateTotalBakingTime(
    Map<String, dynamic> baseConditions,
    Map<String, double> adjustments,
    Map<String, double> ovenCharacteristics,
    DoughStateAnalysisResult doughState,
  ) {
    final baseTime = baseConditions['baseTime'] as double;
    final timeAdjustment = adjustments['timeAdjustment']!;
    final ovenEfficiency = ovenCharacteristics['efficiency']!;
    
    // 오븐 효율이 높을수록 시간 단축 (나누기가 아닌 곱하기 보정)
    final efficiencyFactor = ovenEfficiency > 1.0 ? 0.9 : 1.0; // 고효율 오븐은 10% 단축
    
    final adjustedTime = baseTime * timeAdjustment * efficiencyFactor;
    return adjustedTime.round().clamp(15, 45); // 15-45분 범위로 제한
  }
  
  /// 스팀 설정 계산 (현실적인 로직으로 수정)
  static Map<String, dynamic> _calculateSteamSettings(
    String breadType,
    DoughStateAnalysisResult doughState,
    Map<String, double> ovenCharacteristics,
    double environmentHumidity,
  ) {
    final steamCapability = ovenCharacteristics['steamCapability']!;
    
    // 가정용 오븐은 스팀 기능이 제한적
    if (steamCapability < 0.5) {
      return {
        'duration': 0,
        'amount': 0,
        'method': '물그릇 사용 권장',
      };
    }
    
    // 빵 종류별 기본 스팀 설정 (현실적인 값)
    double baseSteamTime = 3.0; // 5분 → 3분으로 단축
    double baseSteamAmount = 20.0; // 50% → 20%로 감소
    
    if (breadType.toLowerCase().contains('baguette') || 
        breadType.toLowerCase().contains('바게트')) {
      baseSteamTime = 8.0; // 15분 → 8분으로 단축
      baseSteamAmount = 40.0; // 80% → 40%로 감소
    }
    
    // 환경 습도가 높으면 스팀 감소
    final humidityFactor = environmentHumidity > 70 ? 0.7 : 1.0;
    
    final finalSteamTime = (baseSteamTime * steamCapability * humidityFactor).round();
    final finalSteamAmount = (baseSteamAmount * steamCapability * humidityFactor).round();
    
    return {
      'duration': finalSteamTime.clamp(0, 10), // 최대 10분
      'amount': finalSteamAmount.clamp(0, 50), // 최대 50%
      'method': finalSteamTime > 0 ? '초기 스팀 분사' : '스팀 없음',
    };
  }
  
  /// 굽기 성공 예측 지수 계산
  static double _calculateSuccessPrediction(
    DoughStateAnalysisResult doughState,
    Map<String, dynamic> temperatureProfile,
    int totalBakingTime,
    Map<String, double> ovenCharacteristics,
  ) {
    final doughScore = [
      doughState.glutenStrengthIndex / 15.0,
      doughState.fermentationProgress,
      doughState.gasRetentionIndex,
      doughState.elasticityIndex,
    ].reduce((a, b) => a + b) / 4;
    
    final ovenScore = [
      ovenCharacteristics['efficiency']!,
      ovenCharacteristics['uniformity']!,
      ovenCharacteristics['temperatureStability']!,
    ].reduce((a, b) => a + b) / 3;
    
    final conditionScore = totalBakingTime > 10 && totalBakingTime < 90 ? 1.0 : 0.8;
    
    final overallScore = (doughScore * 0.4) + (ovenScore * 0.3) + (conditionScore * 0.3);
    return overallScore.clamp(0.0, 1.0);
  }
}

/// 최적 굽기 결과 클래스
class OptimalBakingResult {
  final Map<String, dynamic> temperatureProfile;
  final int totalBakingTime;
  final Map<String, dynamic> steamSettings;
  final double successPrediction;
  final String ovenType;
  final String breadType;
  final String doughStateScore;
  final DateTime calculationTimestamp;

  OptimalBakingResult({
    required this.temperatureProfile,
    required this.totalBakingTime,
    required this.steamSettings,
    required this.successPrediction,
    required this.ovenType,
    required this.breadType,
    required this.doughStateScore,
    required this.calculationTimestamp,
  });

  /// 빈 결과 생성 (오류 시 사용)
  factory OptimalBakingResult.empty() {
    return OptimalBakingResult(
      temperatureProfile: {},
      totalBakingTime: 30,
      steamSettings: {},
      successPrediction: 0.0,
      ovenType: "알 수 없음",
      breadType: "알 수 없음",
      doughStateScore: "분석 불가",
      calculationTimestamp: DateTime.now(),
    );
  }

  /// 성공 예측 텍스트
  String get successPredictionText {
    if (successPrediction >= 0.9) return "매우 높음 (${(successPrediction * 100).toStringAsFixed(0)}%)";
    if (successPrediction >= 0.7) return "높음 (${(successPrediction * 100).toStringAsFixed(0)}%)";
    if (successPrediction >= 0.5) return "보통 (${(successPrediction * 100).toStringAsFixed(0)}%)";
    if (successPrediction >= 0.3) return "낮음 (${(successPrediction * 100).toStringAsFixed(0)}%)";
    return "매우 낮음 (${(successPrediction * 100).toStringAsFixed(0)}%)";
  }

  /// 온도 프로파일 요약 텍스트
  String get temperatureProfileSummary {
    if (temperatureProfile.isEmpty) return "계산 불가";
    
    final phase1 = temperatureProfile['phase1'] as Map<String, dynamic>? ?? {};
    final phase2 = temperatureProfile['phase2'] as Map<String, dynamic>? ?? {};
    final phase3 = temperatureProfile['phase3'] as Map<String, dynamic>? ?? {};
    
    return "${phase1['temperature'] ?? 0}°C → ${phase2['temperature'] ?? 0}°C → ${phase3['temperature'] ?? 0}°C";
  }

  /// 스팀 설정 요약 텍스트
  String get steamSettingsSummary {
    if (steamSettings.isEmpty) return "스팀 없음";
    
    final duration = steamSettings['duration'] as int? ?? 0;
    final amount = steamSettings['amount'] as int? ?? 0;
    
    if (duration == 0) return "스팀 없음";
    return "${duration}분간 ${amount}% 스팀";
  }
}