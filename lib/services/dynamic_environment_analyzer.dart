// lib/services/dynamic_environment_analyzer.dart
// 동적 환경 분석 시스템 - 환경 변화를 예측하고 분석하는 시스템

import 'dart:async';
import 'dart:math';
import '../core/types/mixing_aliases.dart';
import '../core/utils/mixing_data_integration_system.dart';

/// 동적 환경 분석 시스템
/// 환경 변화를 실시간으로 분석하고 미래 상태를 예측합니다.
class DynamicEnvironmentAnalyzer {
  final StreamController<EnvironmentAnalysisEvent> _analysisController =
      StreamController<EnvironmentAnalysisEvent>.broadcast();

  Timer? _analysisTimer;
  final List<EnvironmentDataPoint> _historicalData = [];
  final Map<String, EnvironmentTrend> _activeTrends = {};

  // 예측 모델 파라미터
  static const int _maxHistoryPoints = 100;
  static const Duration _analysisInterval = Duration(minutes: 5);
  static const int _predictionHorizon = 30; // 30분 예측

  /// 분석 이벤트 스트림
  Stream<EnvironmentAnalysisEvent> get analysisEvents =>
      _analysisController.stream;

  /// 분석 시스템 시작
  void startAnalysis() {
    _analysisTimer?.cancel();
    _analysisTimer = Timer.periodic(_analysisInterval, _onAnalysisTick);

    _analysisController.add(EnvironmentAnalysisEvent(
      type: EnvironmentAnalysisEventType.analysisStarted,
      message: '동적 환경 분석 시스템 시작됨',
      timestamp: DateTime.now(),
    ));
  }

  /// 분석 시스템 중지
  void stopAnalysis() {
    _analysisTimer?.cancel();
    _analysisTimer = null;

    _analysisController.add(EnvironmentAnalysisEvent(
      type: EnvironmentAnalysisEventType.analysisStopped,
      message: '동적 환경 분석 시스템 중지됨',
      timestamp: DateTime.now(),
    ));
  }

  /// 분석 틱 - 정기적인 환경 분석 수행
  void _onAnalysisTick(Timer timer) async {
    try {
      final currentEnv = await _collectCurrentEnvironment();

      // 히스토리 데이터에 추가
      _addDataPoint(currentEnv);

      // 트렌드 분석
      await _analyzeTrends();

      // 예측 수행
      final predictions = await _generatePredictions();

      // 이상 감지
      final anomalies = _detectAnomalies();

      // 이벤트 발행
      _analysisController.add(EnvironmentAnalysisEvent(
        type: EnvironmentAnalysisEventType.predictionUpdated,
        message: '환경 예측 업데이트됨',
        data: {
          'current': currentEnv,
          'predictions': predictions,
          'trends': _activeTrends,
          'anomalies': anomalies,
        },
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _analysisController.add(EnvironmentAnalysisEvent(
        type: EnvironmentAnalysisEventType.error,
        message: '환경 분석 오류: $e',
        data: {'error': e.toString()},
        timestamp: DateTime.now(),
      ));
    }
  }

  /// 현재 환경 데이터 수집
  Future<Map<String, dynamic>> _collectCurrentEnvironment() async {
    // 실제 구현에서는 다양한 센서와 API 사용
    // 시뮬레이션 데이터 생성
    final now = DateTime.now();
    final baseTemp = 20.0 + 5 * sin(now.hour * pi / 12); // 일일 온도 주기
    final baseHumidity = 60.0 + 10 * sin(now.hour * pi / 6); // 습도 변동

    return {
      'temperature': baseTemp + (Random().nextDouble() - 0.5) * 2,
      'humidity': baseHumidity + (Random().nextDouble() - 0.5) * 4,
      'pressure': 1013.25 + (Random().nextDouble() - 0.5) * 10,
      'altitude': 100.0,
      'timestamp': now,
    };
  }

  /// 데이터 포인트 추가
  void _addDataPoint(Map<String, dynamic> environment) {
    final dataPoint = EnvironmentDataPoint(
      temperature: environment['temperature'] as double,
      humidity: environment['humidity'] as double,
      pressure: environment['pressure'] as double,
      altitude: environment['altitude'] as double,
      timestamp: environment['timestamp'] as DateTime,
    );

    _historicalData.add(dataPoint);

    // 최대 히스토리 크기 유지
    if (_historicalData.length > _maxHistoryPoints) {
      _historicalData.removeAt(0);
    }
  }

  /// 트렌드 분석
  Future<void> _analyzeTrends() async {
    if (_historicalData.length < 10) return; // 최소 데이터 요구

    // 각 환경 변수별 트렌드 분석
    await _analyzeTemperatureTrend();
    await _analyzeHumidityTrend();
    await _analyzePressureTrend();
  }

  /// 온도 트렌드 분석
  Future<void> _analyzeTemperatureTrend() async {
    final recent = _historicalData.sublist(max(0, _historicalData.length - 20));

    if (recent.length < 5) return;

    // 선형 회귀를 통한 트렌드 계산
    final trend = _calculateLinearTrend(
        recent.map((p) => p.temperature).toList(),
        recent
            .map((p) => p.timestamp.millisecondsSinceEpoch.toDouble())
            .toList());

    // 트렌드 방향 및 강도 평가
    final direction = trend.slope > 0.1
        ? TrendDirection.increasing
        : trend.slope < -0.1
            ? TrendDirection.decreasing
            : TrendDirection.stable;

    final strength = trend.r2.abs();

    _activeTrends['temperature'] = EnvironmentTrend(
      variable: 'temperature',
      direction: direction,
      strength: strength,
      slope: trend.slope,
      confidence: trend.r2,
      timeHorizon: Duration(minutes: 30),
    );

    // 급격한 변화 감지
    if (strength > 0.7) {
      _analysisController.add(EnvironmentAnalysisEvent(
        type: EnvironmentAnalysisEventType.trendDetected,
        message: '급격한 온도 변화 감지: ${direction.name}',
        data: {
          'variable': 'temperature',
          'trend': _activeTrends['temperature'],
          'slope': trend.slope,
        },
        timestamp: DateTime.now(),
      ));
    }
  }

  /// 습도 트렌드 분석
  Future<void> _analyzeHumidityTrend() async {
    final recent = _historicalData.sublist(max(0, _historicalData.length - 20));

    if (recent.length < 5) return;

    final trend = _calculateLinearTrend(
        recent.map((p) => p.humidity).toList(),
        recent
            .map((p) => p.timestamp.millisecondsSinceEpoch.toDouble())
            .toList());

    final direction = trend.slope > 0.2
        ? TrendDirection.increasing
        : trend.slope < -0.2
            ? TrendDirection.decreasing
            : TrendDirection.stable;

    final strength = trend.r2.abs();

    _activeTrends['humidity'] = EnvironmentTrend(
      variable: 'humidity',
      direction: direction,
      strength: strength,
      slope: trend.slope,
      confidence: trend.r2,
      timeHorizon: Duration(minutes: 30),
    );
  }

  /// 기압 트렌드 분석
  Future<void> _analyzePressureTrend() async {
    final recent = _historicalData.sublist(max(0, _historicalData.length - 20));

    if (recent.length < 5) return;

    final trend = _calculateLinearTrend(
        recent.map((p) => p.pressure).toList(),
        recent
            .map((p) => p.timestamp.millisecondsSinceEpoch.toDouble())
            .toList());

    final direction = trend.slope > 0.5
        ? TrendDirection.increasing
        : trend.slope < -0.5
            ? TrendDirection.decreasing
            : TrendDirection.stable;

    final strength = trend.r2.abs();

    _activeTrends['pressure'] = EnvironmentTrend(
      variable: 'pressure',
      direction: direction,
      strength: strength,
      slope: trend.slope,
      confidence: trend.r2,
      timeHorizon: Duration(minutes: 60),
    );
  }

  /// 선형 트렌드 계산
  TrendResult _calculateLinearTrend(List<double> values, List<double> times) {
    final n = values.length;
    if (n < 2) return TrendResult(slope: 0.0, r2: 0.0);

    // 선형 회귀 계산
    final sumX = times.reduce((a, b) => a + b);
    final sumY = values.reduce((a, b) => a + b);
    final sumXY =
        List.generate(n, (i) => times[i] * values[i]).reduce((a, b) => a + b);
    final sumXX = times.map((x) => x * x).reduce((a, b) => a + b);
    final sumYY = values.map((y) => y * y).reduce((a, b) => a + b);

    final slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;

    // R² 계산
    final ssRes = values
        .map((y) => pow(y - (slope * times[values.indexOf(y)] + intercept), 2))
        .reduce((a, b) => a + b);
    final ssTot =
        values.map((y) => pow(y - sumY / n, 2)).reduce((a, b) => a + b);
    final r2 = 1 - (ssRes / ssTot);

    return TrendResult(slope: slope, r2: r2);
  }

  /// 예측 생성
  Future<Map<String, List<PredictionPoint>>> _generatePredictions() async {
    final predictions = <String, List<PredictionPoint>>{};

    // 각 변수별 예측
    for (final variable in ['temperature', 'humidity', 'pressure']) {
      final trend = _activeTrends[variable];
      if (trend != null) {
        predictions[variable] = _generateVariablePredictions(variable, trend);
      }
    }

    return predictions;
  }

  /// 개별 변수 예측 생성
  List<PredictionPoint> _generateVariablePredictions(
      String variable, EnvironmentTrend trend) {
    final predictions = <PredictionPoint>[];
    final baseTime = DateTime.now();

    // 예측 지평선 동안의 예측 생성
    for (int i = 5; i <= _predictionHorizon; i += 5) {
      final futureTime = baseTime.add(Duration(minutes: i));

      // 트렌드 기반 예측 값 계산
      final currentValue = _getCurrentValue(variable);
      final predictedValue =
          currentValue + (trend.slope * i * 60 * 1000); // 밀리초 변환

      // 예측 신뢰도 계산 (시간이 지날수록 감소)
      final confidence = trend.confidence * exp(-i / 30.0); // 30분에 걸쳐 감소

      predictions.add(PredictionPoint(
        timestamp: futureTime,
        value: predictedValue,
        confidence: confidence.clamp(0.0, 1.0),
        variable: variable,
      ));
    }

    return predictions;
  }

  /// 현재 값 조회
  double _getCurrentValue(String variable) {
    if (_historicalData.isEmpty) return 20.0; // 기본값

    final latest = _historicalData.last;
    switch (variable) {
      case 'temperature':
        return latest.temperature;
      case 'humidity':
        return latest.humidity;
      case 'pressure':
        return latest.pressure;
      default:
        return 20.0;
    }
  }

  /// 이상 감지
  List<EnvironmentAnomaly> _detectAnomalies() {
    final anomalies = <EnvironmentAnomaly>[];

    if (_historicalData.length < 10) return anomalies;

    // 최근 10개 데이터로 이동 평균 및 표준편차 계산
    final recent = _historicalData.sublist(max(0, _historicalData.length - 10));

    for (final variable in ['temperature', 'humidity', 'pressure']) {
      final values =
          recent.map((p) => _getDataPointValue(p, variable)).toList();
      final mean = values.reduce((a, b) => a + b) / values.length;
      final variance =
          values.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) /
              values.length;
      final stdDev = sqrt(variance);

      final current = _getCurrentValue(variable);
      final zScore = (current - mean) / (stdDev + 0.001); // 0으로 나누기 방지

      // Z-score가 2.5 이상이면 이상으로 간주
      if (zScore.abs() > 2.5) {
        anomalies.add(EnvironmentAnomaly(
          variable: variable,
          currentValue: current,
          expectedValue: mean,
          deviation: zScore,
          severity: zScore.abs() > 3.0
              ? AnomalySeverity.high
              : AnomalySeverity.medium,
          timestamp: DateTime.now(),
        ));
      }
    }

    return anomalies;
  }

  /// 데이터 포인트에서 변수 값 추출
  double _getDataPointValue(EnvironmentDataPoint point, String variable) {
    switch (variable) {
      case 'temperature':
        return point.temperature;
      case 'humidity':
        return point.humidity;
      case 'pressure':
        return point.pressure;
      default:
        return 0.0;
    }
  }

  /// 믹싱 영향 분석
  Future<MixingImpactAnalysis> analyzeMixingImpact(
    MixingProfileData profile,
    Map<String, List<PredictionPoint>> predictions,
  ) async {
    var impactLevel = ImpactLevel.none;
    final concerns = <String>[];
    final recommendations = <String>[];

    // 온도 예측 분석
    final tempPredictions = predictions['temperature'] ?? [];
    if (tempPredictions.isAny((p) => p.confidence > 0.7)) {
      final futureTemp =
          tempPredictions.firstWhere((p) => p.confidence > 0.7).value;

      if (futureTemp < 18) {
        impactLevel = ImpactLevel.medium;
        concerns.add('예상 온도 저하로 믹싱 시간 증가 필요');
        recommendations.add('저온 모드로 전환 고려');
      } else if (futureTemp > 28) {
        impactLevel = ImpactLevel.medium;
        concerns.add('예상 온도 상승으로 믹싱 시간 단축 가능');
        recommendations.add('고온 최적화 모드 고려');
      }
    }

    // 습도 예측 분석
    final humidityPredictions = predictions['humidity'] ?? [];
    if (humidityPredictions.isAny((p) => p.confidence > 0.7)) {
      final futureHumidity =
          humidityPredictions.firstWhere((p) => p.confidence > 0.7).value;

      if (futureHumidity < 50) {
        impactLevel = maxImpact(impactLevel, ImpactLevel.medium);
        concerns.add('예상 습도 저하로 건조한 환경');
        recommendations.add('습도 보정 고려');
      } else if (futureHumidity > 70) {
        impactLevel = maxImpact(impactLevel, ImpactLevel.low);
        concerns.add('예상 습도 상승으로 습한 환경');
        recommendations.add('습한 환경 최적화');
      }
    }

    return MixingImpactAnalysis(
      impactLevel: impactLevel,
      concerns: concerns,
      recommendations: recommendations,
      predictedChanges: _extractPredictedChanges(predictions),
      timestamp: DateTime.now(),
    );
  }

  /// 예측 변화 추출
  Map<String, double> _extractPredictedChanges(
      Map<String, List<PredictionPoint>> predictions) {
    final changes = <String, double>{};

    for (final entry in predictions.entries) {
      final variable = entry.key;
      final points = entry.value;

      if (points.isNotEmpty) {
        final first = points.first;
        final last = points.last;
        final change = last.value - first.value;
        changes[variable] = change;
      }
    }

    return changes;
  }

  /// 현재 분석 상태 조회
  Map<String, dynamic> getCurrentAnalysisState() {
    return {
      'isAnalyzing': _analysisTimer?.isActive ?? false,
      'historicalDataPoints': _historicalData.length,
      'activeTrends': _activeTrends.length,
      'lastAnalysis':
          _historicalData.isNotEmpty ? _historicalData.last.timestamp : null,
    };
  }

  /// 리소스 정리
  void dispose() {
    stopAnalysis();
    _analysisController.close();
  }
}

/// 환경 분석 이벤트 타입
enum EnvironmentAnalysisEventType {
  analysisStarted,
  analysisStopped,
  trendDetected,
  predictionUpdated,
  anomalyDetected,
  error,
}

/// 환경 분석 이벤트
class EnvironmentAnalysisEvent {
  final EnvironmentAnalysisEventType type;
  final String message;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  const EnvironmentAnalysisEvent({
    required this.type,
    required this.message,
    this.data,
    required this.timestamp,
  });

  @override
  String toString() => '[$timestamp] $type: $message';
}

/// 환경 데이터 포인트
class EnvironmentDataPoint {
  final double temperature;
  final double humidity;
  final double pressure;
  final double altitude;
  final DateTime timestamp;

  const EnvironmentDataPoint({
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.altitude,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'temperature': temperature,
        'humidity': humidity,
        'pressure': pressure,
        'altitude': altitude,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// 환경 트렌드
class EnvironmentTrend {
  final String variable;
  final TrendDirection direction;
  final double strength;
  final double slope;
  final double confidence;
  final Duration timeHorizon;

  const EnvironmentTrend({
    required this.variable,
    required this.direction,
    required this.strength,
    required this.slope,
    required this.confidence,
    required this.timeHorizon,
  });

  Map<String, dynamic> toJson() => {
        'variable': variable,
        'direction': direction.name,
        'strength': strength,
        'slope': slope,
        'confidence': confidence,
        'timeHorizonMinutes': timeHorizon.inMinutes,
      };
}

/// 트렌드 방향
enum TrendDirection {
  increasing,
  decreasing,
  stable,
}

/// 트렌드 계산 결과
class TrendResult {
  final double slope;
  final double r2;

  const TrendResult({
    required this.slope,
    required this.r2,
  });
}

/// 예측 포인트
class PredictionPoint {
  final DateTime timestamp;
  final double value;
  final double confidence;
  final String variable;

  const PredictionPoint({
    required this.timestamp,
    required this.value,
    required this.confidence,
    required this.variable,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'value': value,
        'confidence': confidence,
        'variable': variable,
      };
}

/// 환경 이상
class EnvironmentAnomaly {
  final String variable;
  final double currentValue;
  final double expectedValue;
  final double deviation;
  final AnomalySeverity severity;
  final DateTime timestamp;

  const EnvironmentAnomaly({
    required this.variable,
    required this.currentValue,
    required this.expectedValue,
    required this.deviation,
    required this.severity,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'variable': variable,
        'currentValue': currentValue,
        'expectedValue': expectedValue,
        'deviation': deviation,
        'severity': severity.name,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// 이상 심각도
enum AnomalySeverity {
  low,
  medium,
  high,
  critical,
}

/// 믹싱 영향 분석
class MixingImpactAnalysis {
  final ImpactLevel impactLevel;
  final List<String> concerns;
  final List<String> recommendations;
  final Map<String, double> predictedChanges;
  final DateTime timestamp;

  const MixingImpactAnalysis({
    required this.impactLevel,
    required this.concerns,
    required this.recommendations,
    required this.predictedChanges,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'impactLevel': impactLevel.name,
        'concerns': concerns,
        'recommendations': recommendations,
        'predictedChanges': predictedChanges,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// 영향 레벨
enum ImpactLevel {
  none,
  low,
  medium,
  high,
  critical,
}

/// 헬퍼 함수들
ImpactLevel maxImpact(ImpactLevel a, ImpactLevel b) {
  return ImpactLevel.values[max(a.index, b.index)];
}

extension ListExtension<T> on List<T> {
  bool isAny(bool Function(T) test) {
    return any(test);
  }
}
