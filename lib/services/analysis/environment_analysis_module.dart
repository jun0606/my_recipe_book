import 'package:my_recipe_book/interfaces/analysis_module.dart';
import 'package:my_recipe_book/models/analysis_request.dart';
import 'package:my_recipe_book/models/environmental_conditions.dart';
import 'package:my_recipe_book/models/fermentation_scenario_v2.dart';
import 'dart:math' as math;

/// 환경 분석 모듈
/// 
/// 온도, 습도, 고도 등 환경 조건이 베이킹에 미치는 영향을 분석합니다.
class EnvironmentAnalysisModule extends BaseAnalysisModule {
  static const String moduleName = 'environment_analysis';
  static const String moduleVersion = '1.0.0';
  
  EnvironmentAnalysisModule() : super(
    name: moduleName,
    version: moduleVersion,
    description: '환경 조건 영향 분석 모듈',
    priority: 3, // 레시피, 재료 분석 후 실행
    dependencies: ['recipe_analysis'], // 레시피 분석 결과 참조
    category: AnalysisModuleCategory.environment,
    initialConfiguration: {
      'enable_temperature_analysis': true,
      'enable_humidity_analysis': true,
      'enable_altitude_analysis': true,
      'enable_seasonal_analysis': true,
      'enable_oven_analysis': true,
      'correction_factors': {
        'temperature_sensitivity': 0.8,
        'humidity_sensitivity': 0.6,
        'altitude_sensitivity': 0.4,
      },
      'standard_conditions': {
        'temperature': 20.0,
        'humidity': 60.0,
        'altitude': 0.0,
        'air_pressure': 1013.25,
      },
    },
  );

  @override
  Future<void> onInitialize() async {
    // 환경 데이터 기준값 로드, 지역별 환경 데이터 초기화 등
  }

  @override
  Future<void> onDispose() async {
    // 리소스 정리
  }

  @override
  bool canHandle(AnalysisRequest request) {
    return true; // 모든 요청에 대해 환경 분석 가능
  }

  @override
  Future<Map<String, dynamic>> analyze(AnalysisRequest request) async {
    final environment = request.environment;
    final recipe = request.recipe;
    final options = request.options;
    
    final results = <String, dynamic>{};
    
    try {
      // 1. 기본 환경 정보 분석
      results['basic_info'] = _analyzeBasicEnvironment(environment);
      
      // 2. 온도 영향 분석
      if (getConfiguration<bool>('enable_temperature_analysis', true)) {
        results['temperature_analysis'] = _analyzeTemperature(environment, recipe);
      }
      
      // 3. 습도 영향 분석
      if (getConfiguration<bool>('enable_humidity_analysis', true)) {
        results['humidity_analysis'] = _analyzeHumidity(environment, recipe);
      }
      
      // 4. 고도 영향 분석
      if (getConfiguration<bool>('enable_altitude_analysis', true)) {
        results['altitude_analysis'] = _analyzeAltitude(environment, recipe);
      }
      
      // 5. 계절적 요인 분석
      if (getConfiguration<bool>('enable_seasonal_analysis', true)) {
        results['seasonal_analysis'] = _analyzeSeasonal(environment, recipe);
      }
      
      // 6. 오븐 특성 분석
      if (getConfiguration<bool>('enable_oven_analysis', true)) {
        results['oven_analysis'] = _analyzeOven(environment, recipe);
      }
      
      // 7. 통합 환경 보정 계수 계산
      results['correction_factors'] = _calculateCorrectionFactors(environment, recipe);
      
      // 8. 환경 최적화 제안
      results['optimization_suggestions'] = _generateOptimizationSuggestions(environment, results);
      
      // 9. 전체 점수 계산
      results['overall_score'] = _calculateOverallScore(results);
      
      // 10. 추천 사항 생성
      if (options.generateRecommendations) {
        results['recommendations'] = _generateRecommendations(environment, results);
      }
      
    } catch (e) {
      throw AnalysisProcessingException(
        '환경 분석 중 오류가 발생했습니다: $e',
        moduleName: name,
        cause: e is Exception ? e : Exception(e.toString()),
      );
    }
    
    return results;
  }  
/// 기본 환경 정보 분석
  Map<String, dynamic> _analyzeBasicEnvironment(EnvironmentalConditions environment) {
    final standardConditions = getConfiguration<Map<String, dynamic>>('standard_conditions', {
      'temperature': 20.0,
      'humidity': 60.0,
      'altitude': 0.0,
      'air_pressure': 1013.25,
    });
    
    return {
      'current_conditions': {
        'temperature': environment.temperature,
        'humidity': environment.humidity,
        'altitude': environment.altitude,
        'air_pressure': environment.airPressure,
        'season': environment.season.name,
        'location': environment.location,
        'oven_type': environment.ovenType,
      },
      'standard_conditions': standardConditions,
      'deviations': {
        'temperature_deviation': environment.temperature - (standardConditions['temperature'] as double),
        'humidity_deviation': environment.humidity - (standardConditions['humidity'] as double),
        'altitude_deviation': environment.altitude - (standardConditions['altitude'] as double),
        'pressure_deviation': environment.airPressure - (standardConditions['air_pressure'] as double),
      },
      'environment_category': _categorizeEnvironment(environment),
      'comfort_index': _calculateComfortIndex(environment),
    };
  }

  /// 환경 카테고리 분류
  String _categorizeEnvironment(EnvironmentalConditions environment) {
    final temp = environment.temperature;
    final humidity = environment.humidity;
    
    if (temp >= 25 && humidity >= 70) return '고온다습';
    if (temp >= 25 && humidity <= 40) return '고온건조';
    if (temp <= 15 && humidity >= 70) return '저온다습';
    if (temp <= 15 && humidity <= 40) return '저온건조';
    if (temp >= 20 && temp <= 25 && humidity >= 50 && humidity <= 70) return '최적';
    
    return '보통';
  }

  /// 환경 쾌적도 지수 계산
  double _calculateComfortIndex(EnvironmentalConditions environment) {
    double score = 100.0;
    
    // 온도 쾌적도 (20-25°C가 최적)
    final tempDiff = (environment.temperature - 22.5).abs();
    score -= tempDiff * 2;
    
    // 습도 쾌적도 (50-70%가 최적)
    final humidityDiff = (environment.humidity - 60.0).abs();
    if (humidityDiff > 10) {
      score -= (humidityDiff - 10) * 1.5;
    }
    
    // 고도 영향 (해수면 기준)
    if (environment.altitude > 1000) {
      score -= (environment.altitude / 1000) * 5;
    }
    
    return score.clamp(0.0, 100.0);
  }

  /// 온도 영향 분석
  Map<String, dynamic> _analyzeTemperature(EnvironmentalConditions environment, recipe) {
    final temperature = environment.temperature;
    final standardTemp = 20.0;
    final tempDifference = temperature - standardTemp;
    
    // 발효 속도 보정 계수: 2^((실제 온도 - 25) / 10)
    final fermentationSpeedFactor = _calculateFermentationSpeedFactor(temperature);
    
    // 반죽 온도 영향
    final doughTempImpact = _analyzeDoughTemperatureImpact(temperature);
    
    // 굽기 온도 조정
    final bakingAdjustment = _calculateBakingTemperatureAdjustment(temperature);
    
    return {
      'current_temperature': temperature,
      'temperature_difference': tempDifference,
      'temperature_category': _categorizeTemperature(temperature),
      'fermentation_speed_factor': fermentationSpeedFactor,
      'fermentation_time_adjustment': _calculateFermentationTimeAdjustment(fermentationSpeedFactor),
      'dough_temperature_impact': doughTempImpact,
      'baking_adjustment': bakingAdjustment,
      'temperature_risks': _identifyTemperatureRisks(temperature),
      'temperature_benefits': _identifyTemperatureBenefits(temperature),
    };
  }

  /// 온도 카테고리 분류
  String _categorizeTemperature(double temperature) {
    if (temperature < 10) return '매우 추움';
    if (temperature < 15) return '추움';
    if (temperature < 20) return '서늘함';
    if (temperature <= 25) return '적정';
    if (temperature <= 30) return '따뜻함';
    if (temperature <= 35) return '더움';
    return '매우 더움';
  }

  /// 발효 속도 계수 계산
  double _calculateFermentationSpeedFactor(double temperature) {
    // 기준 온도 25°C에서 발효 속도 1.0
    // 온도가 10°C 증가할 때마다 속도 2배
    return math.pow(2, (temperature - 25) / 10).toDouble();
  }

  /// 발효 시간 조정 계산
  Map<String, dynamic> _calculateFermentationTimeAdjustment(double speedFactor) {
    final adjustmentPercentage = ((1 / speedFactor) - 1) * 100;
    
    return {
      'speed_factor': speedFactor,
      'time_adjustment_percentage': adjustmentPercentage,
      'adjustment_description': _getFermentationAdjustmentDescription(speedFactor),
    };
  }

  /// 발효 조정 설명
  String _getFermentationAdjustmentDescription(double speedFactor) {
    if (speedFactor > 1.5) return '발효가 빨라집니다. 시간을 단축하세요.';
    if (speedFactor > 1.2) return '발효가 약간 빨라집니다.';
    if (speedFactor < 0.7) return '발효가 느려집니다. 시간을 연장하세요.';
    if (speedFactor < 0.9) return '발효가 약간 느려집니다.';
    return '발효 속도가 적정합니다.';
  }

  /// 반죽 온도 영향 분석
  Map<String, dynamic> _analyzeDoughTemperatureImpact(double temperature) {
    return {
      'mixing_impact': _getMixingImpact(temperature),
      'gluten_development': _getGlutenDevelopmentImpact(temperature),
      'yeast_activity': _getYeastActivityImpact(temperature),
      'butter_handling': _getButterHandlingImpact(temperature),
    };
  }

  /// 반죽 영향 분석
  String _getMixingImpact(double temperature) {
    if (temperature > 25) return '반죽이 끈적해질 수 있음';
    if (temperature < 15) return '반죽이 딱딱해질 수 있음';
    return '반죽 상태 양호';
  }

  /// 글루텐 형성 영향
  String _getGlutenDevelopmentImpact(double temperature) {
    if (temperature > 30) return '글루텐 형성이 빨라지지만 과도할 수 있음';
    if (temperature < 10) return '글루텐 형성이 느려짐';
    return '글루텐 형성 적정';
  }

  /// 이스트 활성도 영향
  String _getYeastActivityImpact(double temperature) {
    if (temperature > 35) return '이스트가 과활성화될 수 있음';
    if (temperature < 5) return '이스트 활성도 매우 낮음';
    return '이스트 활성도 적정';
  }

  /// 버터 다루기 영향
  String _getButterHandlingImpact(double temperature) {
    if (temperature > 25) return '버터가 너무 부드러워짐';
    if (temperature < 15) return '버터가 너무 딱딱함';
    return '버터 상태 적정';
  }

  /// 굽기 온도 조정 계산
  Map<String, dynamic> _calculateBakingTemperatureAdjustment(double ambientTemp) {
    // 주변 온도가 높으면 오븐 온도를 약간 낮춤
    double adjustment = 0.0;
    
    if (ambientTemp > 30) {
      adjustment = -10.0; // 10도 낮춤
    } else if (ambientTemp > 25) {
      adjustment = -5.0; // 5도 낮춤
    } else if (ambientTemp < 10) {
      adjustment = 5.0; // 5도 높임
    }
    
    return {
      'temperature_adjustment': adjustment,
      'adjustment_reason': _getBakingAdjustmentReason(adjustment),
      'preheating_time_adjustment': _getPreheatingTimeAdjustment(ambientTemp),
    };
  }

  /// 굽기 조정 이유
  String _getBakingAdjustmentReason(double adjustment) {
    if (adjustment > 0) return '낮은 주변 온도로 인한 열손실 보상';
    if (adjustment < 0) return '높은 주변 온도로 인한 과열 방지';
    return '조정 불필요';
  }

  /// 예열 시간 조정
  Map<String, dynamic> _getPreheatingTimeAdjustment(double ambientTemp) {
    double adjustment = 0.0;
    
    if (ambientTemp < 10) {
      adjustment = 5.0; // 5분 추가
    } else if (ambientTemp > 30) {
      adjustment = -2.0; // 2분 단축
    }
    
    return {
      'time_adjustment_minutes': adjustment,
      'reason': adjustment > 0 ? '낮은 온도로 인한 예열 시간 연장' : 
                adjustment < 0 ? '높은 온도로 인한 예열 시간 단축' : '조정 불필요',
    };
  }

  /// 온도 위험 요소 식별
  List<String> _identifyTemperatureRisks(double temperature) {
    final risks = <String>[];
    
    if (temperature > 35) {
      risks.addAll([
        '이스트 과활성화로 인한 과발효',
        '반죽 끈적임으로 인한 작업 어려움',
        '버터 과도한 연화',
      ]);
    }
    
    if (temperature < 10) {
      risks.addAll([
        '발효 시간 대폭 연장',
        '이스트 활성도 저하',
        '반죽 경직',
      ]);
    }
    
    if (temperature > 30) {
      risks.add('초콜릿 등 온도에 민감한 재료 변질');
    }
    
    return risks;
  }

  /// 온도 이점 식별
  List<String> _identifyTemperatureBenefits(double temperature) {
    final benefits = <String>[];
    
    if (temperature >= 20 && temperature <= 25) {
      benefits.addAll([
        '최적의 발효 환경',
        '안정적인 반죽 상태',
        '예측 가능한 결과',
      ]);
    }
    
    if (temperature > 25 && temperature <= 30) {
      benefits.addAll([
        '빠른 발효로 시간 단축',
        '부드러운 반죽 작업',
      ]);
    }
    
    return benefits;
  }  ///
 습도 영향 분석
  Map<String, dynamic> _analyzeHumidity(EnvironmentalConditions environment, recipe) {
    final humidity = environment.humidity;
    final standardHumidity = 60.0;
    final humidityDifference = humidity - standardHumidity;
    
    // 습도 보정 계수: 1 + ((실제 습도% - 65%) × 0.005)
    final humidityFactor = 1 + ((humidity - 65.0) * 0.005);
    
    return {
      'current_humidity': humidity,
      'humidity_difference': humidityDifference,
      'humidity_category': _categorizeHumidity(humidity),
      'humidity_correction_factor': humidityFactor,
      'dough_hydration_impact': _analyzeDoughHydrationImpact(humidity),
      'baking_impact': _analyzeBakingHumidityImpact(humidity),
      'storage_impact': _analyzeStorageHumidityImpact(humidity),
      'humidity_risks': _identifyHumidityRisks(humidity),
      'humidity_benefits': _identifyHumidityBenefits(humidity),
    };
  }

  /// 습도 카테고리 분류
  String _categorizeHumidity(double humidity) {
    if (humidity < 30) return '매우 건조';
    if (humidity < 40) return '건조';
    if (humidity < 50) return '약간 건조';
    if (humidity <= 70) return '적정';
    if (humidity <= 80) return '습함';
    return '매우 습함';
  }

  /// 반죽 수분 영향 분석
  Map<String, dynamic> _analyzeDoughHydrationImpact(double humidity) {
    return {
      'flour_moisture_absorption': _getFlourMoistureImpact(humidity),
      'dough_surface_condition': _getDoughSurfaceCondition(humidity),
      'hydration_adjustment': _getHydrationAdjustment(humidity),
    };
  }

  /// 밀가루 수분 흡수 영향
  String _getFlourMoistureImpact(double humidity) {
    if (humidity > 70) return '밀가루가 공기 중 수분을 흡수하여 더 촉촉해짐';
    if (humidity < 40) return '밀가루가 건조해져 수분 흡수력 증가';
    return '밀가루 수분 상태 적정';
  }

  /// 반죽 표면 상태
  String _getDoughSurfaceCondition(double humidity) {
    if (humidity > 75) return '반죽 표면이 끈적해질 수 있음';
    if (humidity < 35) return '반죽 표면이 빨리 마를 수 있음';
    return '반죽 표면 상태 양호';
  }

  /// 수분 조정 제안
  Map<String, dynamic> _getHydrationAdjustment(double humidity) {
    double adjustment = 0.0;
    String reason = '';
    
    if (humidity > 75) {
      adjustment = -2.0; // 수분 2% 감소
      reason = '높은 습도로 인한 수분 조정';
    } else if (humidity < 35) {
      adjustment = 2.0; // 수분 2% 증가
      reason = '낮은 습도로 인한 수분 보충';
    }
    
    return {
      'hydration_adjustment_percentage': adjustment,
      'adjustment_reason': reason,
      'is_adjustment_needed': adjustment != 0.0,
    };
  }

  /// 굽기 습도 영향 분석
  Map<String, dynamic> _analyzeBakingHumidityImpact(double humidity) {
    return {
      'crust_formation': _getCrustFormationImpact(humidity),
      'browning_rate': _getBrowningRateImpact(humidity),
      'steam_effect': _getSteamEffectImpact(humidity),
      'baking_time_adjustment': _getBakingTimeAdjustment(humidity),
    };
  }

  /// 크러스트 형성 영향
  String _getCrustFormationImpact(double humidity) {
    if (humidity > 70) return '크러스트 형성이 느려질 수 있음';
    if (humidity < 40) return '크러스트가 빨리 형성되어 딱딱해질 수 있음';
    return '크러스트 형성 적정';
  }

  /// 갈변 속도 영향
  String _getBrowningRateImpact(double humidity) {
    if (humidity > 75) return '갈변 속도가 느려짐';
    if (humidity < 35) return '갈변 속도가 빨라짐';
    return '갈변 속도 적정';
  }

  /// 스팀 효과 영향
  String _getSteamEffectImpact(double humidity) {
    if (humidity > 70) return '자연 스팀 효과로 부드러운 크러스트';
    if (humidity < 40) return '추가 스팀이 필요할 수 있음';
    return '스팀 효과 적정';
  }

  /// 굽기 시간 조정
  Map<String, dynamic> _getBakingTimeAdjustment(double humidity) {
    double adjustment = 0.0;
    
    if (humidity > 75) {
      adjustment = 5.0; // 5% 시간 연장
    } else if (humidity < 35) {
      adjustment = -3.0; // 3% 시간 단축
    }
    
    return {
      'time_adjustment_percentage': adjustment,
      'adjustment_reason': adjustment > 0 ? '높은 습도로 인한 시간 연장' :
                          adjustment < 0 ? '낮은 습도로 인한 시간 단축' : '조정 불필요',
    };
  }

  /// 보관 습도 영향 분석
  Map<String, dynamic> _analyzeStorageHumidityImpact(double humidity) {
    return {
      'ingredient_storage': _getIngredientStorageImpact(humidity),
      'finished_product_storage': _getFinishedProductStorageImpact(humidity),
      'mold_risk': _getMoldRiskAssessment(humidity),
    };
  }

  /// 재료 보관 영향
  String _getIngredientStorageImpact(double humidity) {
    if (humidity > 70) return '밀가루, 설탕 등이 습기를 흡수하여 굳을 수 있음';
    if (humidity < 40) return '재료가 건조해져 품질 저하 가능';
    return '재료 보관 환경 적정';
  }

  /// 완제품 보관 영향
  String _getFinishedProductStorageImpact(double humidity) {
    if (humidity > 75) return '완제품이 눅눅해질 수 있음';
    if (humidity < 35) return '완제품이 빨리 마를 수 있음';
    return '완제품 보관 환경 적정';
  }

  /// 곰팡이 위험도 평가
  Map<String, dynamic> _getMoldRiskAssessment(double humidity) {
    String riskLevel = 'low';
    String description = '곰팡이 위험도 낮음';
    
    if (humidity > 80) {
      riskLevel = 'high';
      description = '곰팡이 발생 위험 높음 - 환기 필요';
    } else if (humidity > 70) {
      riskLevel = 'medium';
      description = '곰팡이 발생 가능성 있음 - 주의 필요';
    }
    
    return {
      'risk_level': riskLevel,
      'description': description,
      'prevention_tips': _getMoldPreventionTips(humidity),
    };
  }

  /// 곰팡이 예방 팁
  List<String> _getMoldPreventionTips(double humidity) {
    final tips = <String>[];
    
    if (humidity > 70) {
      tips.addAll([
        '환기를 자주 시키세요',
        '제습기 사용을 고려하세요',
        '재료를 밀폐 용기에 보관하세요',
        '완제품을 빨리 소비하세요',
      ]);
    }
    
    return tips;
  }

  /// 습도 위험 요소 식별
  List<String> _identifyHumidityRisks(double humidity) {
    final risks = <String>[];
    
    if (humidity > 80) {
      risks.addAll([
        '곰팡이 발생 위험',
        '재료 습기 흡수로 인한 변질',
        '완제품 품질 저하',
      ]);
    }
    
    if (humidity < 30) {
      risks.addAll([
        '반죽 표면 빠른 건조',
        '크러스트 과도한 경화',
        '완제품 빠른 노화',
      ]);
    }
    
    return risks;
  }

  /// 습도 이점 식별
  List<String> _identifyHumidityBenefits(double humidity) {
    final benefits = <String>[];
    
    if (humidity >= 50 && humidity <= 70) {
      benefits.addAll([
        '최적의 반죽 상태 유지',
        '안정적인 발효 환경',
        '적절한 크러스트 형성',
      ]);
    }
    
    if (humidity >= 60 && humidity <= 75) {
      benefits.add('자연 스팀 효과로 부드러운 식감');
    }
    
    return benefits;
  }  /
// 고도 영향 분석
  Map<String, dynamic> _analyzeAltitude(EnvironmentalConditions environment, recipe) {
    final altitude = environment.altitude;
    final airPressure = environment.airPressure;
    
    // 고도 보정 계수: 1 + ((현재 고도(m) / 1000) × 0.02)
    final altitudeFactor = 1 + ((altitude / 1000) * 0.02);
    
    return {
      'current_altitude': altitude,
      'air_pressure': airPressure,
      'altitude_category': _categorizeAltitude(altitude),
      'altitude_correction_factor': altitudeFactor,
      'boiling_point_adjustment': _calculateBoilingPointAdjustment(altitude),
      'leavening_impact': _analyzeLeavenImpact(altitude),
      'liquid_evaporation': _analyzeEvaporationImpact(altitude),
      'baking_adjustments': _calculateAltitudeBakingAdjustments(altitude),
    };
  }

  /// 고도 카테고리 분류
  String _categorizeAltitude(double altitude) {
    if (altitude < 300) return '해수면';
    if (altitude < 1000) return '저고도';
    if (altitude < 2000) return '중고도';
    if (altitude < 3000) return '고고도';
    return '매우 높은 고도';
  }

  /// 끓는점 조정 계산
  Map<String, dynamic> _calculateBoilingPointAdjustment(double altitude) {
    // 고도 300m마다 끓는점 1°C 감소
    final boilingPointReduction = altitude / 300;
    final adjustedBoilingPoint = 100.0 - boilingPointReduction;
    
    return {
      'sea_level_boiling_point': 100.0,
      'adjusted_boiling_point': adjustedBoilingPoint,
      'reduction': boilingPointReduction,
      'impact': boilingPointReduction > 2 ? 'significant' : 'minimal',
    };
  }

  /// 팽창제 영향 분석
  Map<String, dynamic> _analyzeLeavenImpact(double altitude) {
    final impact = <String, dynamic>{};
    
    if (altitude > 1000) {
      impact['yeast_activity'] = '이스트 활성도 증가 - 발효 시간 단축 필요';
      impact['chemical_leavening'] = '베이킹파우더 효과 증가 - 양 감소 필요';
      impact['gas_expansion'] = '기체 팽창 증가 - 과팽창 위험';
      
      // 조정 제안
      impact['adjustments'] = {
        'yeast_reduction': '이스트 양 10-25% 감소',
        'baking_powder_reduction': '베이킹파우더 양 15-25% 감소',
        'liquid_increase': '액체 양 2-4큰술 증가',
        'sugar_reduction': '설탕 양 0-2큰술 감소',
        'flour_increase': '밀가루 양 1-2큰술 증가',
      };
    } else {
      impact['impact_level'] = 'minimal';
      impact['adjustments'] = '조정 불필요';
    }
    
    return impact;
  }

  /// 액체 증발 영향 분석
  Map<String, dynamic> _analyzeEvaporationImpact(double altitude) {
    final evaporationRate = altitude > 1000 ? 'increased' : 'normal';
    
    return {
      'evaporation_rate': evaporationRate,
      'liquid_loss': altitude > 1000 ? '액체 증발 속도 증가' : '정상적인 증발',
      'adjustment_needed': altitude > 1000,
      'liquid_compensation': altitude > 1000 ? '액체 양 2-4큰술 추가' : '조정 불필요',
    };
  }

  /// 고도별 굽기 조정
  Map<String, dynamic> _calculateAltitudeBakingAdjustments(double altitude) {
    if (altitude < 1000) {
      return {'adjustment_needed': false, 'message': '조정 불필요'};
    }
    
    // 고도 1000m 이상에서의 조정
    final adjustments = <String, dynamic>{};
    
    // 온도 조정 (15-25°F 증가)
    adjustments['temperature_increase'] = '온도 8-14°C 증가';
    
    // 시간 조정 (5-8분 단축)
    adjustments['time_reduction'] = '굽기 시간 5-8분 단축';
    
    // 재료 조정
    adjustments['ingredient_adjustments'] = {
      'liquid': '액체 2-4큰술 증가',
      'sugar': '설탕 0-2큰술 감소',
      'flour': '밀가루 1-2큰술 증가',
      'leavening': '팽창제 15-25% 감소',
    };
    
    return {
      'adjustment_needed': true,
      'altitude_level': altitude > 2000 ? 'high' : 'medium',
      'adjustments': adjustments,
      'explanation': '낮은 기압으로 인한 빠른 팽창과 수분 증발 보상',
    };
  }

  /// 계절적 요인 분석
  Map<String, dynamic> _analyzeSeasonal(EnvironmentalConditions environment, recipe) {
    final season = environment.season;
    
    return {
      'current_season': season.name,
      'seasonal_characteristics': _getSeasonalCharacteristics(season),
      'seasonal_adjustments': _getSeasonalAdjustments(season, environment),
      'ingredient_availability': _analyzeSeasonalIngredients(season),
      'storage_considerations': _getSeasonalStorageConsiderations(season),
    };
  }

  /// 계절별 특성
  Map<String, dynamic> _getSeasonalCharacteristics(Season season) {
    switch (season) {
      case Season.spring:
        return {
          'temperature_range': '15-25°C',
          'humidity_range': '50-70%',
          'characteristics': ['온화한 기후', '적당한 습도', '안정적인 환경'],
          'baking_advantages': ['예측 가능한 결과', '안정적인 발효'],
        };
      case Season.summer:
        return {
          'temperature_range': '25-35°C',
          'humidity_range': '60-80%',
          'characteristics': ['고온다습', '빠른 발효', '재료 변질 위험'],
          'baking_challenges': ['과발효', '반죽 끈적임', '크러스트 형성 지연'],
        };
      case Season.autumn:
        return {
          'temperature_range': '10-20°C',
          'humidity_range': '45-65%',
          'characteristics': ['서늘하고 건조', '안정적인 환경'],
          'baking_advantages': ['좋은 보관 환경', '안정적인 결과'],
        };
      case Season.winter:
        return {
          'temperature_range': '5-15°C',
          'humidity_range': '40-60%',
          'characteristics': ['저온건조', '느린 발효', '난방으로 인한 건조'],
          'baking_challenges': ['발효 시간 연장', '반죽 경직', '빠른 건조'],
        };
    }
  }

  /// 계절별 조정 사항
  Map<String, dynamic> _getSeasonalAdjustments(Season season, EnvironmentalConditions environment) {
    switch (season) {
      case Season.summer:
        return {
          'fermentation': '발효 시간 20-30% 단축',
          'temperature': '반죽 온도 낮게 유지',
          'storage': '냉장 보관 권장',
          'timing': '아침 일찍 작업 권장',
        };
      case Season.winter:
        return {
          'fermentation': '발효 시간 30-50% 연장',
          'temperature': '따뜻한 곳에서 발효',
          'hydration': '수분 약간 증가',
          'preheating': '예열 시간 연장',
        };
      default:
        return {'adjustment': '특별한 조정 불필요'};
    }
  }

  /// 계절별 재료 가용성 분석
  Map<String, dynamic> _analyzeSeasonalIngredients(Season season) {
    final seasonalIngredients = <String, List<String>>{
      'spring': ['딸기', '아스파라거스', '완두콩', '새싹'],
      'summer': ['복숭아', '자두', '베리류', '토마토', '옥수수'],
      'autumn': ['사과', '배', '호박', '밤', '감'],
      'winter': ['귤', '유자', '배추', '무', '고구마'],
    };
    
    return {
      'seasonal_ingredients': seasonalIngredients[season.name] ?? [],
      'peak_quality': '제철 재료로 최고 품질',
      'cost_benefit': '제철 재료로 비용 절약',
      'flavor_enhancement': '자연스러운 맛의 조화',
    };
  }

  /// 계절별 보관 고려사항
  Map<String, dynamic> _getSeasonalStorageConsiderations(Season season) {
    switch (season) {
      case Season.summer:
        return {
          'temperature_control': '냉장 보관 필수',
          'humidity_control': '제습 필요',
          'shelf_life': '유통기한 단축',
          'precautions': ['직사광선 피하기', '서늘한 곳 보관', '빠른 소비'],
        };
      case Season.winter:
        return {
          'temperature_control': '실온 보관 가능',
          'humidity_control': '가습 고려',
          'shelf_life': '유통기한 연장',
          'precautions': ['건조 방지', '적절한 습도 유지'],
        };
      default:
        return {
          'storage': '일반적인 보관 방법 적용',
          'precautions': ['온도와 습도 모니터링'],
        };
    }
  }  /// 오븐 
특성 분석
  Map<String, dynamic> _analyzeOven(EnvironmentalConditions environment, recipe) {
    final ovenType = environment.ovenType;
    
    return {
      'oven_type': ovenType,
      'oven_characteristics': _getOvenCharacteristics(ovenType),
      'environment_interaction': _analyzeOvenEnvironmentInteraction(environment, ovenType),
      'adjustment_recommendations': _getOvenAdjustmentRecommendations(environment, ovenType),
    };
  }

  /// 오븐 특성 정보
  Map<String, dynamic> _getOvenCharacteristics(String ovenType) {
    switch (ovenType.toLowerCase()) {
      case 'convection':
        return {
          'heat_distribution': 'excellent',
          'temperature_accuracy': 'high',
          'moisture_retention': 'low',
          'baking_speed': 'fast',
          'energy_efficiency': 'high',
        };
      case 'conventional':
        return {
          'heat_distribution': 'moderate',
          'temperature_accuracy': 'moderate',
          'moisture_retention': 'moderate',
          'baking_speed': 'normal',
          'energy_efficiency': 'moderate',
        };
      case 'steam':
        return {
          'heat_distribution': 'excellent',
          'temperature_accuracy': 'high',
          'moisture_retention': 'high',
          'baking_speed': 'normal',
          'energy_efficiency': 'high',
        };
      default:
        return {
          'heat_distribution': 'unknown',
          'temperature_accuracy': 'unknown',
          'moisture_retention': 'unknown',
          'baking_speed': 'unknown',
          'energy_efficiency': 'unknown',
        };
    }
  }

  /// 오븐-환경 상호작용 분석
  Map<String, dynamic> _analyzeOvenEnvironmentInteraction(EnvironmentalConditions environment, String ovenType) {
    final temperature = environment.temperature;
    final humidity = environment.humidity;
    
    return {
      'preheating_efficiency': _calculatePreheatingEfficiency(temperature, ovenType),
      'heat_loss_factor': _calculateHeatLossFactor(temperature, ovenType),
      'moisture_management': _analyzeMoistureManagement(humidity, ovenType),
      'energy_consumption': _estimateEnergyConsumption(environment, ovenType),
    };
  }

  /// 예열 효율성 계산
  Map<String, dynamic> _calculatePreheatingEfficiency(double ambientTemp, String ovenType) {
    double baseEfficiency = ovenType.toLowerCase() == 'convection' ? 0.9 : 0.8;
    double tempFactor = 1.0 - ((ambientTemp - 20) * 0.01);
    double efficiency = (baseEfficiency * tempFactor).clamp(0.5, 1.0);
    
    return {
      'efficiency': efficiency,
      'preheating_time_multiplier': 1.0 / efficiency,
      'energy_impact': efficiency < 0.8 ? 'increased' : 'normal',
    };
  }

  /// 열손실 계수 계산
  double _calculateHeatLossFactor(double ambientTemp, String ovenType) {
    double baseLoss = ovenType.toLowerCase() == 'convection' ? 0.05 : 0.08;
    double tempDifference = (200 - ambientTemp) / 200; // 200°C 기준
    return baseLoss * tempDifference;
  }

  /// 수분 관리 분석
  Map<String, dynamic> _analyzeMoistureManagement(double humidity, String ovenType) {
    bool needsAdditionalSteam = false;
    String moistureLevel = 'normal';
    
    if (ovenType.toLowerCase() == 'steam') {
      moistureLevel = 'high';
    } else if (humidity < 40) {
      needsAdditionalSteam = true;
      moistureLevel = 'low';
    }
    
    return {
      'moisture_level': moistureLevel,
      'needs_additional_steam': needsAdditionalSteam,
      'steam_recommendation': needsAdditionalSteam ? '물그릇 추가 또는 스프레이 사용' : '추가 스팀 불필요',
    };
  }

  /// 에너지 소비 추정
  Map<String, dynamic> _estimateEnergyConsumption(EnvironmentalConditions environment, String ovenType) {
    double baseConsumption = ovenType.toLowerCase() == 'convection' ? 0.8 : 1.0;
    double tempFactor = 1.0 + ((20 - environment.temperature) * 0.02);
    double humidityFactor = 1.0 + ((environment.humidity - 60) * 0.001);
    
    double totalConsumption = baseConsumption * tempFactor * humidityFactor;
    
    return {
      'relative_consumption': totalConsumption,
      'efficiency_rating': totalConsumption < 0.9 ? 'excellent' : 
                          totalConsumption < 1.1 ? 'good' : 'poor',
      'cost_impact': totalConsumption > 1.2 ? 'high' : 'normal',
    };
  }

  /// 오븐 조정 권장사항
  List<String> _getOvenAdjustmentRecommendations(EnvironmentalConditions environment, String ovenType) {
    final recommendations = <String>[];
    
    if (environment.temperature < 15) {
      recommendations.add('예열 시간을 10-15% 연장하세요');
    }
    
    if (environment.humidity < 40 && ovenType.toLowerCase() != 'steam') {
      recommendations.add('베이킹 초기에 물그릇을 넣어 스팀을 생성하세요');
    }
    
    if (ovenType.toLowerCase() == 'convection') {
      recommendations.add('온도를 15-20°C 낮추고 시간을 단축하세요');
    }
    
    if (environment.altitude > 1000) {
      recommendations.add('고도로 인한 온도 상승과 시간 단축을 고려하세요');
    }
    
    return recommendations;
  }

  /// 통합 환경 보정 계수 계산
  Map<String, dynamic> _calculateCorrectionFactors(EnvironmentalConditions environment, recipe) {
    final tempFactor = _calculateFermentationSpeedFactor(environment.temperature);
    final humidityFactor = 1 + ((environment.humidity - 65.0) * 0.005);
    final altitudeFactor = 1 + ((environment.altitude / 1000) * 0.02);
    
    // 종합 보정 계수
    final overallFactor = (tempFactor + humidityFactor + altitudeFactor) / 3;
    
    return {
      'temperature_factor': tempFactor,
      'humidity_factor': humidityFactor,
      'altitude_factor': altitudeFactor,
      'overall_correction_factor': overallFactor,
      'fermentation_time_multiplier': 1.0 / tempFactor,
      'hydration_adjustment': (humidityFactor - 1) * 100, // 백분율
      'leavening_adjustment': altitudeFactor > 1.02 ? 'reduce' : 'normal',
    };
  }

  /// 환경 최적화 제안 생성
  Map<String, dynamic> _generateOptimizationSuggestions(EnvironmentalConditions environment, Map<String, dynamic> results) {
    final suggestions = <String, List<String>>{
      'immediate': [],
      'equipment': [],
      'process': [],
      'long_term': [],
    };
    
    // 온도 최적화
    final tempCategory = results['temperature_analysis']?['temperature_category'] as String? ?? '';
    if (tempCategory.contains('추움') || tempCategory.contains('더움')) {
      suggestions['immediate']!.add('작업 공간 온도를 20-25°C로 조절하세요');
    }
    
    // 습도 최적화
    final humidityCategory = results['humidity_analysis']?['humidity_category'] as String? ?? '';
    if (humidityCategory.contains('건조')) {
      suggestions['immediate']!.add('가습기 사용 또는 물그릇 배치로 습도를 높이세요');
    } else if (humidityCategory.contains('습함')) {
      suggestions['immediate']!.add('제습기 사용 또는 환기로 습도를 낮추세요');
    }
    
    // 고도 최적화
    if (environment.altitude > 1000) {
      suggestions['process']!.addAll([
        '팽창제 양을 15-25% 줄이세요',
        '액체를 2-4큰술 추가하세요',
        '굽기 온도를 8-14°C 높이세요',
      ]);
    }
    
    // 장비 제안
    suggestions['equipment']!.addAll([
      '온습도계로 환경을 모니터링하세요',
      '오븐 온도계로 정확한 온도를 확인하세요',
    ]);
    
    // 장기적 개선
    suggestions['long_term']!.addAll([
      '주방 환경 제어 시스템 설치 고려',
      '계절별 레시피 조정 가이드 작성',
    ]);
    
    return {
      'suggestions': suggestions,
      'priority_level': _calculateSuggestionPriority(results),
      'expected_improvement': _estimateImprovementPotential(results),
    };
  }

  /// 제안 우선순위 계산
  String _calculateSuggestionPriority(Map<String, dynamic> results) {
    final overallScore = results['overall_score'] as double? ?? 50.0;
    
    if (overallScore < 40) return 'high';
    if (overallScore < 60) return 'medium';
    return 'low';
  }

  /// 개선 잠재력 추정
  Map<String, dynamic> _estimateImprovementPotential(Map<String, dynamic> results) {
    final currentScore = results['overall_score'] as double? ?? 50.0;
    final maxPossibleScore = 90.0; // 현실적인 최대 점수
    final improvementPotential = maxPossibleScore - currentScore;
    
    return {
      'current_score': currentScore,
      'max_possible_score': maxPossibleScore,
      'improvement_potential': improvementPotential,
      'improvement_percentage': (improvementPotential / maxPossibleScore) * 100,
    };
  }

  /// 전체 점수 계산
  double _calculateOverallScore(Map<String, dynamic> results) {
    double score = 50.0; // 기본 점수
    
    // 온도 점수 (30점 만점)
    final tempCategory = results['temperature_analysis']?['temperature_category'] as String? ?? '';
    if (tempCategory == '적정') {
      score += 30.0;
    } else if (tempCategory.contains('따뜻함') || tempCategory.contains('서늘함')) {
      score += 20.0;
    } else if (tempCategory.contains('추움') || tempCategory.contains('더움')) {
      score += 10.0;
    }
    
    // 습도 점수 (25점 만점)
    final humidityCategory = results['humidity_analysis']?['humidity_category'] as String? ?? '';
    if (humidityCategory == '적정') {
      score += 25.0;
    } else if (humidityCategory.contains('약간')) {
      score += 15.0;
    } else if (humidityCategory.contains('건조') || humidityCategory.contains('습함')) {
      score += 5.0;
    }
    
    // 고도 점수 (15점 만점)
    final altitudeCategory = results['altitude_analysis']?['altitude_category'] as String? ?? '';
    if (altitudeCategory == '해수면' || altitudeCategory == '저고도') {
      score += 15.0;
    } else if (altitudeCategory == '중고도') {
      score += 10.0;
    } else {
      score += 5.0;
    }
    
    // 계절 보너스 (10점 만점)
    final seasonalCharacteristics = results['seasonal_analysis']?['seasonal_characteristics'] as Map<String, dynamic>?;
    if (seasonalCharacteristics?['baking_advantages'] != null) {
      score += 10.0;
    } else if (seasonalCharacteristics?['baking_challenges'] == null) {
      score += 5.0;
    }
    
    return score.clamp(0.0, 100.0);
  }

  /// 추천 사항 생성
  List<Map<String, dynamic>> _generateRecommendations(EnvironmentalConditions environment, Map<String, dynamic> results) {
    final recommendations = <Map<String, dynamic>>[];
    
    final overallScore = results['overall_score'] as double? ?? 50.0;
    
    // 환경 개선 추천
    if (overallScore < 60) {
      recommendations.add({
        'type': 'environment_improvement',
        'priority': 'high',
        'title': '환경 조건 개선',
        'description': '현재 환경이 베이킹에 적합하지 않습니다. 온도와 습도 조절이 필요합니다.',
        'actions': _getEnvironmentImprovementActions(results),
      });
    }
    
    // 공정 조정 추천
    final correctionFactors = results['correction_factors'] as Map<String, dynamic>?;
    if (correctionFactors != null) {
      final fermentationMultiplier = correctionFactors['fermentation_time_multiplier'] as double? ?? 1.0;
      if ((fermentationMultiplier - 1.0).abs() > 0.2) {
        recommendations.add({
          'type': 'process_adjustment',
          'priority': 'medium',
          'title': '발효 시간 조정',
          'description': '환경 조건에 따른 발효 시간 조정이 필요합니다.',
          'adjustment_factor': fermentationMultiplier,
        });
      }
    }
    
    // 재료 조정 추천
    if (environment.altitude > 1000) {
      recommendations.add({
        'type': 'ingredient_adjustment',
        'priority': 'high',
        'title': '고도 보정',
        'description': '높은 고도로 인한 재료 비율 조정이 필요합니다.',
        'adjustments': results['altitude_analysis']?['baking_adjustments']?['adjustments'],
      });
    }
    
    return recommendations;
  }

  /// 환경 개선 액션 목록
  List<String> _getEnvironmentImprovementActions(Map<String, dynamic> results) {
    final actions = <String>[];
    
    final tempCategory = results['temperature_analysis']?['temperature_category'] as String? ?? '';
    if (tempCategory.contains('추움')) {
      actions.add('실내 온도를 높이거나 따뜻한 곳에서 작업하세요');
    } else if (tempCategory.contains('더움')) {
      actions.add('에어컨이나 선풍기로 작업 공간을 시원하게 하세요');
    }
    
    final humidityCategory = results['humidity_analysis']?['humidity_category'] as String? ?? '';
    if (humidityCategory.contains('건조')) {
      actions.add('가습기를 사용하거나 물그릇을 놓아 습도를 높이세요');
    } else if (humidityCategory.contains('습함')) {
      actions.add('제습기를 사용하거나 환기를 강화하세요');
    }
    
    return actions;
  }

  @override
  int estimateProcessingTime(AnalysisRequest request) {
    int baseTime = 800; // 0.8초
    
    // 분석 깊이에 따른 추가 시간
    baseTime += request.options.analysisDepth * 200;
    
    // 고도 분석 추가 시간
    if (request.environment.altitude > 1000) {
      baseTime += 300;
    }
    
    // 계절 분석 추가 시간
    baseTime += 200;
    
    return baseTime;
  }

  @override
  int estimateMemoryUsage(AnalysisRequest request) {
    int baseMemory = 8 * 1024 * 1024; // 8MB
    
    // 분석 옵션에 따른 메모리 사용량
    if (request.options.generateRecommendations) {
      baseMemory += 2 * 1024 * 1024; // 2MB 추가
    }
    
    // 상세 분석 시 추가 메모리
    baseMemory += request.options.analysisDepth * 1024 * 1024;
    
    return baseMemory;
  }
}