import 'package:my_recipe_book/models/advanced_sous_chef_models.dart';
import 'package:my_recipe_book/models/baking_modules.dart';
import 'package:my_recipe_book/models/process_guide.dart';
import 'package:my_recipe_book/models/recipe_analysis_result.dart';
import 'package:my_recipe_book/services/baking_science_formula_engine.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:async';

// ========== 실시간 알람 시스템 ==========

/// 알람 시스템 인터페이스
abstract class AlertSystem {
  Future<void> initialize();
  Future<void> sendAlert(Alert alert);
  Future<void> scheduleAlert(Alert alert, Duration delay);
  Future<void> cancelAlert(String alertId);
  Future<void> cancelAllAlerts();
  Stream<Alert> get alertStream;
}

/// 로컬 알람 시스템 구현
class LocalAlertSystem implements AlertSystem {
  // 알람 상태 관리
  final Map<String, Alert> _activeAlerts = {};
  final Map<String, DateTime> _scheduledAlerts = {};

  // 알람 설정
  bool _isInitialized = false;
  AlertPreferences _preferences = const AlertPreferences();

  // 알람 스트림 컨트롤러
  final StreamController<Alert> _alertController =
      StreamController<Alert>.broadcast();

  @override
  Stream<Alert> get alertStream => _alertController.stream;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _isInitialized = true;
      print('LocalAlertSystem: 초기화 완료');
    } catch (e) {
      print('LocalAlertSystem 초기화 실패: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendAlert(Alert alert) async {
    if (!_isInitialized) {
      throw StateError('AlertSystem이 초기화되지 않았습니다. 먼저 initialize()를 호출하세요.');
    }

    try {
      _activeAlerts[alert.id] = alert;
      _alertController.add(alert);
      print('알람 전송 완료: ${alert.message}');
    } catch (e) {
      print('알람 전송 실패: $e');
      rethrow;
    }
  }

  @override
  Future<void> scheduleAlert(Alert alert, Duration delay) async {
    if (!_isInitialized) {
      throw StateError('AlertSystem이 초기화되지 않았습니다.');
    }

    final scheduledTime = DateTime.now().add(delay);
    _scheduledAlerts[alert.id] = scheduledTime;

    Timer(delay, () async {
      if (_scheduledAlerts.containsKey(alert.id)) {
        await sendAlert(alert);
        _scheduledAlerts.remove(alert.id);
      }
    });

    print('알람 스케줄링 완료: ${alert.message} (${delay.inMinutes}분 후)');
  }

  @override
  Future<void> cancelAlert(String alertId) async {
    _activeAlerts.remove(alertId);
    _scheduledAlerts.remove(alertId);
    print('알람 취소: $alertId');
  }

  @override
  Future<void> cancelAllAlerts() async {
    _activeAlerts.clear();
    _scheduledAlerts.clear();
    print('모든 알람 취소');
  }

  /// 사용자 알람 설정 업데이트
  void updatePreferences(AlertPreferences preferences) {
    _preferences = preferences;
    print('알람 설정 업데이트: $preferences');
  }

  /// 알람 설정 조회
  AlertPreferences getPreferences() => _preferences;

  /// 특정 타입의 알람 활성화 상태 확인
  bool isAlertTypeEnabled(AlertType type) {
    switch (type) {
      case AlertType.fermentationTimeDeviation:
        return _preferences.enableFermentationAlerts;
      case AlertType.bakingTemperatureDeviation:
        return _preferences.enableBakingAlerts;
      case AlertType.environmentVariableDeviation:
        return _preferences.enableEnvironmentAlerts;
      case AlertType.processCompletion:
        return _preferences.enableCompletionAlerts;
    }
  }

  /// 발효 시간 이탈 알람 생성
  Alert createFermentationTimeAlert({
    required String recipeId,
    required double expectedTime,
    required double actualTime,
    required double deviationPercentage,
  }) {
    final isOverdue = actualTime > expectedTime;
    final severity = deviationPercentage > 20
        ? AlertSeverity.high
        : deviationPercentage > 10
            ? AlertSeverity.medium
            : AlertSeverity.low;

    return Alert(
      id: 'fermentation_${recipeId}_${DateTime.now().millisecondsSinceEpoch}',
      type: AlertType.fermentationTimeDeviation,
      title: '발효 시간 알림',
      message: isOverdue
          ? '발효 시간이 예정보다 ${deviationPercentage.toStringAsFixed(1)}% 지연되고 있습니다.'
          : '발효가 예정보다 ${deviationPercentage.toStringAsFixed(1)}% 빠르게 진행되고 있습니다.',
      action: isOverdue ? '온도를 높이거나 스타터 양을 늘려보세요.' : '온도를 낮추거나 스타터 양을 줄여보세요.',
      timestamp: DateTime.now(),
      severity: severity,
    );
  }

  /// 굽기 온도 이탈 알람 생성
  Alert createBakingTemperatureAlert({
    required String recipeId,
    required double targetTemperature,
    required double currentTemperature,
    required double deviationPercentage,
  }) {
    final severity = deviationPercentage > 10
        ? AlertSeverity.critical
        : deviationPercentage > 5
            ? AlertSeverity.high
            : AlertSeverity.medium;

    return Alert(
      id: 'baking_${recipeId}_${DateTime.now().millisecondsSinceEpoch}',
      type: AlertType.bakingTemperatureDeviation,
      title: '굽기 온도 알림',
      message:
          '굽기 온도가 목표치에서 ${deviationPercentage.toStringAsFixed(1)}% 벗어났습니다.',
      action: currentTemperature < targetTemperature
          ? '온도를 높이거나 예열 시간을 늘려보세요.'
          : '온도를 낮추거나 오븐 위치를 조정해보세요.',
      timestamp: DateTime.now(),
      severity: severity,
    );
  }

  /// 환경 변수 이탈 알람 생성
  Alert createEnvironmentAlert({
    required String variable,
    required double targetValue,
    required double currentValue,
    required double deviationPercentage,
  }) {
    final variableName = _getVariableDisplayName(variable);
    final severity = deviationPercentage > 15
        ? AlertSeverity.high
        : deviationPercentage > 10
            ? AlertSeverity.medium
            : AlertSeverity.low;

    return Alert(
      id: 'environment_${variable}_${DateTime.now().millisecondsSinceEpoch}',
      type: AlertType.environmentVariableDeviation,
      title: '환경 조건 알림',
      message:
          '$variableName이 목표치에서 ${deviationPercentage.toStringAsFixed(1)}% 벗어났습니다.',
      action: _getEnvironmentActionAdvice(variable, currentValue, targetValue),
      timestamp: DateTime.now(),
      severity: severity,
    );
  }

  /// 공정 완료 알람 생성
  Alert createCompletionAlert({
    required String recipeId,
    required String processType,
    required Duration actualDuration,
    required Duration expectedDuration,
  }) {
    final isEarly = actualDuration < expectedDuration;
    final deviation = isEarly
        ? (expectedDuration - actualDuration).inMinutes
        : (actualDuration - expectedDuration).inMinutes;

    return Alert(
      id: 'completion_${recipeId}_${DateTime.now().millisecondsSinceEpoch}',
      type: AlertType.processCompletion,
      title: '공정 완료 알림',
      message: '$processType 공정이 완료되었습니다.',
      action: '다음 공정으로 진행하거나 품질을 확인하세요.',
      timestamp: DateTime.now(),
      severity: AlertSeverity.low,
    );
  }

  // ========== 헬퍼 메서드들 ==========

  String _getVariableDisplayName(String variable) {
    switch (variable) {
      case 'temperature':
        return '온도';
      case 'humidity':
        return '습도';
      case 'pressure':
        return '기압';
      default:
        return variable;
    }
  }

  String _getEnvironmentActionAdvice(
      String variable, double current, double target) {
    switch (variable) {
      case 'temperature':
        return current < target
            ? '작업실 온도를 높이거나 온풍기를 사용해보세요.'
            : '작업실 온도를 낮추거나 선풍기를 사용해보세요.';
      case 'humidity':
        return current < target
            ? '가습기를 사용하거나 물그릇을 놓아두세요.'
            : '제습기를 사용하거나 환기를 시키세요.';
      default:
        return '환경 조건을 조정해보세요.';
    }
  }

  /// 활성 알람 목록 조회
  List<Alert> getActiveAlerts() => _activeAlerts.values.toList();

  /// 스케줄된 알람 목록 조회
  Map<String, DateTime> getScheduledAlerts() => Map.from(_scheduledAlerts);

  /// 알람 시스템 상태 조회
  Map<String, dynamic> getSystemStatus() {
    return {
      'isInitialized': _isInitialized,
      'activeAlertsCount': _activeAlerts.length,
      'scheduledAlertsCount': _scheduledAlerts.length,
      'preferences': _preferences.toJson(),
    };
  }
}

// ========== 빵 모듈: 핵심 기능 ==========

/// 빵 모듈: 도법 판정 시스템
String determineBreadMethod(
    List<String> keywords, List<Ingredient> ingredients) {
  // 키워드 기반 도법 판정
  final keywordMethods = <String, String>{
    'sourdough': '사워도우',
    'sauerteig': '사워도우',
    'wild yeast': '사워도우',
    'starter': '사워도우',
    'poolish': '풀리시',
    'biga': '비가',
    'preferment': '프리퍼먼트',
    'straight': '스트레이트',
    'direct': '스트레이트',
    'no knead': '노 피드',
    'ciabatta': '치아바타',
    'focaccia': '포카치아',
    'bagel': '베이글',
  };

  for (final keyword in keywords) {
    final method = keywordMethods[keyword.toLowerCase()];
    if (method != null) {
      return method;
    }
  }

  // 재료 기반 도법 판정
  final hasSourdoughStarter = ingredients.any((ing) =>
      ing.name.toLowerCase().contains('starter') ||
      ing.name.toLowerCase().contains('sourdough') ||
      ing.name.toLowerCase().contains('사워도우'));

  if (hasSourdoughStarter) {
    return '사워도우';
  }

  final hasPoolish = ingredients.any((ing) =>
      ing.name.toLowerCase().contains('poolish') ||
      ing.name.toLowerCase().contains('풀리시'));

  if (hasPoolish) {
    return '풀리시';
  }

  // 기본값: 스트레이트 도법
  return '스트레이트';
}

/// 빵 모듈: 발효 시간 예측
double predictFermentationTime({
  required Recipe recipe,
  required EnvironmentalConditions environment,
  required String breadMethod,
  required List<IngredientMetadata> ingredientMeta,
}) {
  // 기본 발효 시간 (분)
  double baseTime = 120.0;

  // 도법별 보정
  final methodMultipliers = {
    '스트레이트': 1.0,
    '사워도우': 1.4,
    '풀리시': 1.2,
    '비가': 1.3,
    '프리퍼먼트': 1.1,
    '노 피드': 0.9,
  };

  baseTime *= methodMultipliers[breadMethod] ?? 1.0;

  // 미생물 활성 계수
  double microbialActivity = 1.0;
  final yeastIngredient = ingredientMeta.firstWhere(
    (meta) =>
        meta.name.toLowerCase().contains('yeast') ||
        meta.name.toLowerCase().contains('이스트'),
    orElse: () => IngredientMetadata(
      name: 'yeast',
      properties: {},
      effectiveValue: 0,
      function: 'fermentation',
      qualityCorrectionFactor: 1.0,
    ),
  );

  if (yeastIngredient.effectiveValue > 0) {
    microbialActivity = yeastIngredient.effectiveValue / 100.0;
  }

  // 환경 기후 계수
  final climateCoefficient = environment.fermentationSpeedCorrection;

  // 최종 계산
  final predictedTime = baseTime * microbialActivity * climateCoefficient;

  return predictedTime.clamp(30.0, 480.0); // 30분 ~ 8시간 범위
}

/// 빵 모듈: 글루텐 강도 지수 계산
double calculateGlutenStrengthIndex({
  required List<IngredientMetadata> ingredientMeta,
  required double hydrationPercentage,
  required double saltPercentage,
}) {
  // 유효 밀가루 단백질%
  final flourMeta = ingredientMeta.firstWhere(
    (meta) =>
        meta.name.toLowerCase().contains('flour') ||
        meta.name.toLowerCase().contains('밀가루'),
    orElse: () => IngredientMetadata(
      name: 'flour',
      properties: {'protein': 12.0},
      effectiveValue: 12.0,
      function: 'structure',
      qualityCorrectionFactor: 1.0,
    ),
  );

  final effectiveProtein = flourMeta.effectiveProteinPercentage;

  // 글루텐 강도 지수 계산 공식
  double glutenIndex = (effectiveProtein * 1.2) + (saltPercentage * 0.7);

  // 지방 함량 보정
  final fatIngredients = ingredientMeta.where(
    (meta) =>
        meta.name.toLowerCase().contains('butter') ||
        meta.name.toLowerCase().contains('oil') ||
        meta.name.toLowerCase().contains('fat') ||
        meta.name.toLowerCase().contains('버터') ||
        meta.name.toLowerCase().contains('기름'),
  );

  double totalFatPercentage = 0.0;
  for (final fat in fatIngredients) {
    totalFatPercentage += 5.0;
  }
  glutenIndex -= (totalFatPercentage * 0.5);

  return glutenIndex.clamp(0.0, 100.0);
}

// ========== 케이크 모듈: 핵심 기능 ==========

/// 케이크 모듈: 텍스처 분석 시스템
Map<String, dynamic> analyzeCakeTexture({
  required List<IngredientMetadata> ingredientMeta,
  required EnvironmentalConditions environment,
  required String cakeType,
  required double bakingTemperature,
  required int bakingTime,
}) {
  // 지방 함량 분석 (크림성, 무거움, 촉감에 영향)
  final fatIngredients = ingredientMeta.where(
    (meta) =>
        meta.name.toLowerCase().contains('butter') ||
        meta.name.toLowerCase().contains('oil') ||
        meta.name.toLowerCase().contains('shortening') ||
        meta.name.toLowerCase().contains('버터') ||
        meta.name.toLowerCase().contains('기름'),
  );

  double totalFatPercentage = 0.0;
  for (final fat in fatIngredients) {
    totalFatPercentage += 15.0;
  }

  // 텍스처 지수 계산
  final moistureRetention =
      totalFatPercentage * 0.4 + (environment.humidity * 0.2);
  final crumbTenderness =
      totalFatPercentage * 0.3 + (100 - totalFatPercentage * 2);
  final crustFirmness = (bakingTemperature - 150) * 0.5 + (bakingTime / 10);
  final overallTexture =
      (moistureRetention + crumbTenderness + (100 - crustFirmness)) / 3;

  // 케이크 타입별 보정
  double typeMultiplier = 1.0;
  switch (cakeType.toLowerCase()) {
    case 'sponge':
    case '스폰지':
      typeMultiplier = 1.2;
      break;
    case 'butter':
    case '버터':
      typeMultiplier = 0.9;
      break;
    case 'pound':
    case '파운드':
      typeMultiplier = 0.8;
      break;
  }

  final finalTextureScore = (overallTexture * typeMultiplier).clamp(0.0, 100.0);

  return {
    'moistureRetention': moistureRetention.clamp(0.0, 100.0),
    'crumbTenderness': crumbTenderness.clamp(0.0, 100.0),
    'crustFirmness': crustFirmness.clamp(0.0, 100.0),
    'overallTextureScore': finalTextureScore,
    'textureDescription': _getCakeTextureDescription(finalTextureScore),
    'recommendations':
        _getCakeTextureRecommendations(finalTextureScore, totalFatPercentage),
  };
}

/// 케이크 텍스처 관련 헬퍼 메서드들
String _getCakeTextureDescription(double score) {
  if (score >= 85) {
    return '완벽한 텍스처: 촉촉하고 부드러우며 균형 잡힌 케이크';
  } else if (score >= 75) {
    return '우수한 텍스처: 좋은 촉감과 풍미의 케이크';
  } else if (score >= 60) {
    return '양호한 텍스처: 기본적인 케이크 품질';
  } else if (score >= 45) {
    return '개선이 필요한 텍스처: 다소 건조하거나 무거움';
  } else {
    return '문제가 있는 텍스처: 대대적인 개선이 필요함';
  }
}

List<String> _getCakeTextureRecommendations(
    double score, double fatPercentage) {
  final recommendations = <String>[];

  if (score < 60) {
    if (fatPercentage < 20) {
      recommendations.add('지방 함량을 늘려 촉촉함을 개선하세요');
    }
  } else if (score > 85) {
    recommendations.add('현재 레시피가 매우 우수합니다');
    if (fatPercentage > 35) {
      recommendations.add('지방 함량이 높아 무겁게 느껴질 수 있습니다');
    }
  } else {
    recommendations.add('전반적으로 균형 잡힌 레시피입니다');
  }

  return recommendations;
}

// ========== 쿠키 모듈: 핵심 기능 ==========

/// 쿠키 모듈: 스프레드 예측 시스템
Map<String, dynamic> predictCookieSpread({
  required List<IngredientMetadata> ingredientMeta,
  required EnvironmentalConditions environment,
  required double bakingTemperature,
  required int bakingTime,
  required String cookieType,
}) {
  // 지방 함량 분석 (스프레드에 영향)
  final fatIngredients = ingredientMeta.where(
    (meta) =>
        meta.name.toLowerCase().contains('butter') ||
        meta.name.toLowerCase().contains('oil') ||
        meta.name.toLowerCase().contains('shortening') ||
        meta.name.toLowerCase().contains('버터') ||
        meta.name.toLowerCase().contains('기름'),
  );

  double totalFatPercentage = 0.0;
  for (final fat in fatIngredients) {
    totalFatPercentage += 20.0;
  }

  // 스프레드 지수 계산
  final fatSpreadFactor = totalFatPercentage * 0.4;
  final temperatureSpreadFactor = (bakingTemperature - 160) * 0.1;
  final timeSpreadFactor = (bakingTime - 12) * 0.05;
  final baseSpreadIndex =
      fatSpreadFactor + temperatureSpreadFactor + timeSpreadFactor;

  // 쿠키 타입별 보정
  double typeMultiplier = 1.0;
  switch (cookieType.toLowerCase()) {
    case 'chocolate chip':
    case '초코칩':
      typeMultiplier = 1.1;
      break;
    case 'sugar':
    case '설탕':
      typeMultiplier = 1.2;
      break;
    case 'shortbread':
    case '쇼트브레드':
      typeMultiplier = 0.8;
      break;
  }

  final finalSpreadIndex = (baseSpreadIndex * typeMultiplier).clamp(0.0, 100.0);

  return {
    'spreadIndex': finalSpreadIndex,
    'expectedDiameter': _calculateExpectedDiameter(finalSpreadIndex),
    'spreadPattern': _getSpreadPattern(finalSpreadIndex),
    'bakingRecommendations':
        _getCookieBakingRecommendations(finalSpreadIndex, totalFatPercentage),
  };
}

/// 쿠키 관련 헬퍼 메서드들
double _calculateExpectedDiameter(double spreadIndex) {
  if (spreadIndex < 30) return 6.0;
  if (spreadIndex < 50) return 8.0;
  if (spreadIndex < 70) return 10.0;
  if (spreadIndex < 90) return 12.0;
  return 15.0;
}

String _getSpreadPattern(double spreadIndex) {
  if (spreadIndex < 40) return '최소 스프레드: 둥글고 높은 형태';
  if (spreadIndex < 60) return '적당한 스프레드: 균형 잡힌 형태';
  if (spreadIndex < 80) return '넓은 스프레드: 바삭하고 얇은 형태';
  return '최대 스프레드: 매우 얇고 넓은 형태';
}

List<String> _getCookieBakingRecommendations(
    double spreadIndex, double fatPercentage) {
  final recommendations = <String>[];

  if (spreadIndex < 30) {
    if (fatPercentage < 15) {
      recommendations.add('지방 함량을 늘려 스프레드를 촉진하세요');
    }
  } else if (spreadIndex > 80) {
    recommendations.add('현재 스프레드가 너무 넓습니다');
    if (fatPercentage > 25) {
      recommendations.add('지방 함량을 줄여 형태 유지를 개선하세요');
    }
  } else {
    recommendations.add('스프레드 지수가 적절합니다');
  }

  return recommendations;
}
