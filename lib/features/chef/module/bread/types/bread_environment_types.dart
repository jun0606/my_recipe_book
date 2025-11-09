// lib/modules/bread/types/bread_environment_types.dart
// 빵 환경 타입 시스템

import 'dart:convert';
import '../../../../../core/types/unified_types.dart';

/// 계절
enum Season {
  spring,
  summer,
  autumn,
  winter,
}

/// 날씨 상태
enum WeatherCondition {
  clear,
  cloudy,
  rainy,
  snowy,
  windy,
  humid,
  dry,
}

/// 환경 영향 요인
class EnvironmentalFactor {
  final String name;
  final double impactLevel; // -1.0 ~ 1.0 (부정적 ~ 긍정적)
  final String description;
  final List<String> recommendations;

  const EnvironmentalFactor({
    required this.name,
    required this.impactLevel,
    required this.description,
    this.recommendations = const [],
  });

  factory EnvironmentalFactor.fromJson(Map<String, dynamic> json) {
    return EnvironmentalFactor(
      name: json['name'] as String,
      impactLevel: (json['impactLevel'] as num).toDouble(),
      description: json['description'] as String,
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'impactLevel': impactLevel,
      'description': description,
      'recommendations': recommendations,
    };
  }

  bool get isPositive => impactLevel > 0;
  bool get isNegative => impactLevel < 0;
  bool get isNeutral => impactLevel == 0;
}

/// 계절별 조정
class SeasonalAdjustment {
  final Season season;
  final Map<String, double> temperatureAdjustments;
  final Map<String, double> timeAdjustments;
  final Map<String, double> hydrationAdjustments;
  final List<String> recommendations;
  final Map<String, dynamic> customAdjustments;

  const SeasonalAdjustment({
    required this.season,
    required this.temperatureAdjustments,
    required this.timeAdjustments,
    required this.hydrationAdjustments,
    this.recommendations = const [],
    this.customAdjustments = const {},
  });

  factory SeasonalAdjustment.fromJson(Map<String, dynamic> json) {
    return SeasonalAdjustment(
      season: Season.values[json['season'] as int],
      temperatureAdjustments: Map<String, double>.from(
        (json['temperatureAdjustments'] as Map).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      timeAdjustments: Map<String, double>.from(
        (json['timeAdjustments'] as Map).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      hydrationAdjustments: Map<String, double>.from(
        (json['hydrationAdjustments'] as Map).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      customAdjustments:
          Map<String, dynamic>.from(json['customAdjustments'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'season': season.index,
      'temperatureAdjustments': temperatureAdjustments,
      'timeAdjustments': timeAdjustments,
      'hydrationAdjustments': hydrationAdjustments,
      'recommendations': recommendations,
      'customAdjustments': customAdjustments,
    };
  }

  double getTemperatureAdjustment(String process) {
    return temperatureAdjustments[process] ?? 0.0;
  }

  double getTimeAdjustment(String process) {
    return timeAdjustments[process] ?? 1.0; // 기본 1.0 = 변화 없음
  }

  double getHydrationAdjustment(String ingredient) {
    return hydrationAdjustments[ingredient] ?? 0.0;
  }
}

/// 고도 영향
class AltitudeImpact {
  final double altitude; // 미터
  final Map<String, double> pressureAdjustments;
  final Map<String, double> temperatureAdjustments;
  final Map<String, double> timeAdjustments;
  final List<String> recommendations;
  final Map<String, dynamic> customImpacts;

  const AltitudeImpact({
    required this.altitude,
    required this.pressureAdjustments,
    required this.temperatureAdjustments,
    required this.timeAdjustments,
    this.recommendations = const [],
    this.customImpacts = const {},
  });

  factory AltitudeImpact.fromJson(Map<String, dynamic> json) {
    return AltitudeImpact(
      altitude: (json['altitude'] as num).toDouble(),
      pressureAdjustments: Map<String, double>.from(
        (json['pressureAdjustments'] as Map).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      temperatureAdjustments: Map<String, double>.from(
        (json['temperatureAdjustments'] as Map).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      timeAdjustments: Map<String, double>.from(
        (json['timeAdjustments'] as Map).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      customImpacts: Map<String, dynamic>.from(json['customImpacts'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'altitude': altitude,
      'pressureAdjustments': pressureAdjustments,
      'temperatureAdjustments': temperatureAdjustments,
      'timeAdjustments': timeAdjustments,
      'recommendations': recommendations,
      'customImpacts': customImpacts,
    };
  }

  bool get isHighAltitude => altitude > 1000; // 1000m 이상 고지대
  bool get isVeryHighAltitude => altitude > 2000; // 2000m 이상 초고지대

  double getPressureAdjustment(String process) {
    return pressureAdjustments[process] ?? 0.0;
  }

  double getTemperatureAdjustment(String process) {
    return temperatureAdjustments[process] ?? 0.0;
  }

  double getTimeAdjustment(String process) {
    return timeAdjustments[process] ?? 1.0; // 기본 1.0 = 변화 없음
  }
}

/// 환경 프로필
class EnvironmentProfile {
  final String profileId;
  final String profileName;
  final Season season;
  final WeatherCondition weather;
  final double temperature;
  final double humidity;
  final double altitude;
  final Map<String, dynamic> additionalFactors;

  const EnvironmentProfile({
    required this.profileId,
    required this.profileName,
    required this.season,
    required this.weather,
    required this.temperature,
    required this.humidity,
    required this.altitude,
    this.additionalFactors = const {},
  });

  factory EnvironmentProfile.fromJson(Map<String, dynamic> json) {
    return EnvironmentProfile(
      profileId: json['profileId'] as String,
      profileName: json['profileName'] as String,
      season: Season.values[json['season'] as int],
      weather: WeatherCondition.values[json['weather'] as int],
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      altitude: (json['altitude'] as num).toDouble(),
      additionalFactors:
          Map<String, dynamic>.from(json['additionalFactors'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileId': profileId,
      'profileName': profileName,
      'season': season.index,
      'weather': weather.index,
      'temperature': temperature,
      'humidity': humidity,
      'altitude': altitude,
      'additionalFactors': additionalFactors,
    };
  }

  bool get isDry => humidity < 40;
  bool get isHumid => humidity > 70;
  bool get isHot => temperature > 25;
  bool get isCold => temperature < 10;

  String get climateDescription {
    if (isHot && isHumid) return 'Hot and Humid';
    if (isHot && isDry) return 'Hot and Dry';
    if (isCold && isHumid) return 'Cold and Humid';
    if (isCold && isDry) return 'Cold and Dry';
    return 'Moderate';
  }
}

/// 환경 영향 분석
class EnvironmentalImpactAnalysis {
  final EnvironmentProfile environment;
  final List<EnvironmentalFactor> factors;
  final SeasonalAdjustment seasonalAdjustment;
  final AltitudeImpact? altitudeImpact;
  final List<String> recommendations;
  final Map<String, dynamic> impactSummary;

  const EnvironmentalImpactAnalysis({
    required this.environment,
    required this.factors,
    required this.seasonalAdjustment,
    this.altitudeImpact,
    this.recommendations = const [],
    this.impactSummary = const {},
  });

  factory EnvironmentalImpactAnalysis.fromJson(Map<String, dynamic> json) {
    return EnvironmentalImpactAnalysis(
      environment: EnvironmentProfile.fromJson(json['environment']),
      factors: (json['factors'] as List)
          .map((item) => EnvironmentalFactor.fromJson(item))
          .toList(),
      seasonalAdjustment:
          SeasonalAdjustment.fromJson(json['seasonalAdjustment']),
      altitudeImpact: json['altitudeImpact'] != null
          ? AltitudeImpact.fromJson(json['altitudeImpact'])
          : null,
      recommendations: List<String>.from(json['recommendations'] ?? []),
      impactSummary: Map<String, dynamic>.from(json['impactSummary'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'environment': environment.toJson(),
      'factors': factors.map((factor) => factor.toJson()).toList(),
      'seasonalAdjustment': seasonalAdjustment.toJson(),
      'altitudeImpact': altitudeImpact?.toJson(),
      'recommendations': recommendations,
      'impactSummary': impactSummary,
    };
  }

  double get overallImpactScore {
    if (factors.isEmpty) return 0.0;
    final totalImpact =
        factors.map((f) => f.impactLevel).reduce((a, b) => a + b);
    return totalImpact / factors.length;
  }

  List<EnvironmentalFactor> get positiveFactors =>
      factors.where((factor) => factor.isPositive).toList();

  List<EnvironmentalFactor> get negativeFactors =>
      factors.where((factor) => factor.isNegative).toList();

  bool get hasSignificantImpact => overallImpactScore.abs() > 0.3;
}

/// 환경 모니터링 데이터
class EnvironmentalMonitoringData {
  final String sensorId;
  final DateTime timestamp;
  final double temperature;
  final double humidity;
  final double pressure;
  final double? altitude;
  final Map<String, dynamic> additionalMeasurements;

  const EnvironmentalMonitoringData({
    required this.sensorId,
    required this.timestamp,
    required this.temperature,
    required this.humidity,
    required this.pressure,
    this.altitude,
    this.additionalMeasurements = const {},
  });

  factory EnvironmentalMonitoringData.fromJson(Map<String, dynamic> json) {
    return EnvironmentalMonitoringData(
      sensorId: json['sensorId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      pressure: (json['pressure'] as num).toDouble(),
      altitude: json['altitude'] != null
          ? (json['altitude'] as num).toDouble()
          : null,
      additionalMeasurements:
          Map<String, dynamic>.from(json['additionalMeasurements'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sensorId': sensorId,
      'timestamp': timestamp.toIso8601String(),
      'temperature': temperature,
      'humidity': humidity,
      'pressure': pressure,
      'altitude': altitude,
      'additionalMeasurements': additionalMeasurements,
    };
  }

  bool get isValid =>
      temperature >= -50 &&
      temperature <= 100 && // 유효 온도 범위
      humidity >= 0 &&
      humidity <= 100 && // 유효 습도 범위
      pressure > 0; // 유효 기압 범위

  String get comfortLevel {
    if (temperature < 10 || temperature > 30) return 'Uncomfortable';
    if (humidity < 30 || humidity > 70) return 'Moderate';
    return 'Comfortable';
  }
}

/// 환경 변화 추적
class EnvironmentalChangeTracking {
  final String trackingId;
  final DateTime startTime;
  final DateTime endTime;
  final List<EnvironmentalMonitoringData> readings;
  final Map<String, double> trends;
  final List<String> significantChanges;
  final Map<String, dynamic> analysis;

  const EnvironmentalChangeTracking({
    required this.trackingId,
    required this.startTime,
    required this.endTime,
    required this.readings,
    required this.trends,
    this.significantChanges = const [],
    this.analysis = const {},
  });

  factory EnvironmentalChangeTracking.fromJson(Map<String, dynamic> json) {
    return EnvironmentalChangeTracking(
      trackingId: json['trackingId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      readings: (json['readings'] as List)
          .map((item) => EnvironmentalMonitoringData.fromJson(item))
          .toList(),
      trends: Map<String, double>.from(
        (json['trends'] as Map).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      significantChanges: List<String>.from(json['significantChanges'] ?? []),
      analysis: Map<String, dynamic>.from(json['analysis'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackingId': trackingId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'readings': readings.map((reading) => reading.toJson()).toList(),
      'trends': trends,
      'significantChanges': significantChanges,
      'analysis': analysis,
    };
  }

  Duration get duration {
    return endTime.difference(startTime);
  }

  int get readingCount {
    return readings.length;
  }

  bool get hasSignificantChanges {
    return significantChanges.isNotEmpty;
  }

  double? getTemperatureTrend() {
    return trends['temperature'];
  }

  double? getHumidityTrend() {
    return trends['humidity'];
  }

  double? getPressureTrend() {
    return trends['pressure'];
  }
}

/// 환경 적응 추천
class EnvironmentalAdaptationRecommendation {
  final String recommendationId;
  final EnvironmentalImpactAnalysis impactAnalysis;
  final List<String> adaptations;
  final Map<String, double> adjustmentFactors;
  final String rationale;
  final double confidence;

  const EnvironmentalAdaptationRecommendation({
    required this.recommendationId,
    required this.impactAnalysis,
    required this.adaptations,
    required this.adjustmentFactors,
    required this.rationale,
    required this.confidence,
  });

  factory EnvironmentalAdaptationRecommendation.fromJson(
      Map<String, dynamic> json) {
    return EnvironmentalAdaptationRecommendation(
      recommendationId: json['recommendationId'] as String,
      impactAnalysis:
          EnvironmentalImpactAnalysis.fromJson(json['impactAnalysis']),
      adaptations: List<String>.from(json['adaptations'] ?? []),
      adjustmentFactors: Map<String, double>.from(
        (json['adjustmentFactors'] as Map).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      rationale: json['rationale'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommendationId': recommendationId,
      'impactAnalysis': impactAnalysis.toJson(),
      'adaptations': adaptations,
      'adjustmentFactors': adjustmentFactors,
      'rationale': rationale,
      'confidence': confidence,
    };
  }

  bool get isHighConfidence => confidence >= 0.8;
  bool get hasAdaptations => adaptations.isNotEmpty;
}

/// 환경 품질 지표
class EnvironmentalQualityIndex {
  final double temperatureIndex; // 0-100
  final double humidityIndex; // 0-100
  final double airQualityIndex; // 0-100
  final double stabilityIndex; // 0-100
  final double overallIndex; // 0-100
  final String qualityLevel; // 'Excellent', 'Good', 'Fair', 'Poor'
  final List<String> concerns;

  const EnvironmentalQualityIndex({
    required this.temperatureIndex,
    required this.humidityIndex,
    required this.airQualityIndex,
    required this.stabilityIndex,
    required this.overallIndex,
    required this.qualityLevel,
    this.concerns = const [],
  });

  factory EnvironmentalQualityIndex.fromJson(Map<String, dynamic> json) {
    return EnvironmentalQualityIndex(
      temperatureIndex: (json['temperatureIndex'] as num).toDouble(),
      humidityIndex: (json['humidityIndex'] as num).toDouble(),
      airQualityIndex: (json['airQualityIndex'] as num).toDouble(),
      stabilityIndex: (json['stabilityIndex'] as num).toDouble(),
      overallIndex: (json['overallIndex'] as num).toDouble(),
      qualityLevel: json['qualityLevel'] as String,
      concerns: List<String>.from(json['concerns'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperatureIndex': temperatureIndex,
      'humidityIndex': humidityIndex,
      'airQualityIndex': airQualityIndex,
      'stabilityIndex': stabilityIndex,
      'overallIndex': overallIndex,
      'qualityLevel': qualityLevel,
      'concerns': concerns,
    };
  }

  bool get isExcellent => qualityLevel == 'Excellent';

  bool get isGood => qualityLevel == 'Good';

  bool get isPoor => qualityLevel == 'Poor';

  bool get hasConcerns => concerns.isNotEmpty;
}
