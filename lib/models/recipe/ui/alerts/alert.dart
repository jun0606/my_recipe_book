import 'dart:convert';
import 'alert_severity.dart';
import 'alert_type.dart';

/// 알람 정보
class Alert {
  final String id;
  final String title;
  final String message;
  final AlertType type;
  final String action;
  final DateTime timestamp;
  final AlertSeverity severity;

  const Alert({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.action,
    required this.timestamp,
    required this.severity,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: AlertType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AlertType.processCompletion,
      ),
      action: json['action'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      severity: AlertSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => AlertSeverity.medium,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'action': action,
      'timestamp': timestamp.toIso8601String(),
      'severity': severity.name,
    };
  }

  Alert copyWith({
    String? id,
    String? title,
    String? message,
    AlertType? type,
    String? action,
    DateTime? timestamp,
    AlertSeverity? severity,
  }) {
    return Alert(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      action: action ?? this.action,
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
    );
  }

  /// 알람이 만료되었는지 확인
  bool get isExpired {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return difference.inHours > 24; // 24시간 후 만료
  }

  /// 긴급 알람인지 확인
  bool get isUrgent => severity == AlertSeverity.critical;

  /// 알람 우선순위 점수 계산
  int get priorityScore {
    int score = 0;

    // 심각도에 따른 점수
    switch (severity) {
      case AlertSeverity.low:
        score += 10;
        break;
      case AlertSeverity.medium:
        score += 20;
        break;
      case AlertSeverity.high:
        score += 30;
        break;
      case AlertSeverity.critical:
        score += 50;
        break;
    }

    // 타입에 따른 점수
    switch (type) {
      case AlertType.fermentationTimeDeviation:
        score += 15;
        break;
      case AlertType.bakingTemperatureDeviation:
        score += 20;
        break;
      case AlertType.environmentVariableDeviation:
        score += 10;
        break;
      case AlertType.processCompletion:
        score += 5;
        break;
    }

    // 시간에 따른 점수 (최근 알람일수록 높음)
    final hoursSince = DateTime.now().difference(timestamp).inHours;
    if (hoursSince < 1) {
      score += 10;
    } else if (hoursSince < 6) {
      score += 5;
    }

    return score;
  }

  @override
  String toString() {
    return 'Alert(id: $id, title: $title, type: ${type.displayName}, '
        'severity: ${severity.displayName}, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Alert && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 알람 생성기
class AlertFactory {
  /// 발효 시간 이탈 알람 생성
  static Alert createFermentationTimeDeviationAlert({
    required String recipeId,
    required Duration expectedTime,
    required Duration actualTime,
    required double deviationPercent,
  }) {
    final message = '발효 시간이 ${deviationPercent.toStringAsFixed(1)}% '
        '이탈되었습니다. (예상: ${expectedTime.inMinutes}분, 실제: ${actualTime.inMinutes}분)';

    return Alert(
      id: 'fermentation_${recipeId}_${DateTime.now().millisecondsSinceEpoch}',
      title: '발효 시간 이탈',
      message: message,
      type: AlertType.fermentationTimeDeviation,
      action: '발효 시간을 모니터링하세요',
      timestamp: DateTime.now(),
      severity: deviationPercent > 50
          ? AlertSeverity.critical
          : deviationPercent > 25
              ? AlertSeverity.high
              : AlertSeverity.medium,
    );
  }

  /// 굽기 온도 이탈 알람 생성
  static Alert createBakingTemperatureDeviationAlert({
    required String recipeId,
    required double expectedTemp,
    required double actualTemp,
    required double deviationPercent,
  }) {
    final message = '굽기 온도가 ${deviationPercent.toStringAsFixed(1)}°C '
        '이탈되었습니다. (예상: ${expectedTemp.toStringAsFixed(1)}°C, 실제: ${actualTemp.toStringAsFixed(1)}°C)';

    return Alert(
      id: 'baking_${recipeId}_${DateTime.now().millisecondsSinceEpoch}',
      title: '굽기 온도 이탈',
      message: message,
      type: AlertType.bakingTemperatureDeviation,
      action: '오븐 온도를 조정하세요',
      timestamp: DateTime.now(),
      severity: deviationPercent > 20
          ? AlertSeverity.critical
          : deviationPercent > 10
              ? AlertSeverity.high
              : AlertSeverity.medium,
    );
  }

  /// 공정 완료 알람 생성
  static Alert createProcessCompletionAlert({
    required String recipeId,
    required String processName,
    required bool isSuccessful,
  }) {
    final message = isSuccessful
        ? '$processName 공정이 성공적으로 완료되었습니다.'
        : '$processName 공정이 완료되었으나 문제가 발견되었습니다.';

    return Alert(
      id: 'completion_${recipeId}_${DateTime.now().millisecondsSinceEpoch}',
      title: '공정 완료',
      message: message,
      type: AlertType.processCompletion,
      action: isSuccessful ? '다음 단계로 진행하세요' : '문제를 확인하세요',
      timestamp: DateTime.now(),
      severity: isSuccessful ? AlertSeverity.low : AlertSeverity.medium,
    );
  }

  /// 환경 변수 이탈 알람 생성
  static Alert createEnvironmentDeviationAlert({
    required String recipeId,
    required String variableName,
    required double expectedValue,
    required double actualValue,
    required String unit,
  }) {
    final deviation =
        ((actualValue - expectedValue) / expectedValue * 100).abs();
    final message = '$variableName이 ${deviation.toStringAsFixed(1)}% '
        '이탈되었습니다. (예상: ${expectedValue.toStringAsFixed(1)}$unit, '
        '실제: ${actualValue.toStringAsFixed(1)}$unit)';

    return Alert(
      id: 'environment_${recipeId}_${DateTime.now().millisecondsSinceEpoch}',
      title: '환경 변수 이탈',
      message: message,
      type: AlertType.environmentVariableDeviation,
      action: '환경 조건을 조정하세요',
      timestamp: DateTime.now(),
      severity: deviation > 30
          ? AlertSeverity.critical
          : deviation > 15
              ? AlertSeverity.high
              : AlertSeverity.medium,
    );
  }
}

/// 알람 관리자
class AlertManager {
  final List<Alert> _alerts = [];

  /// 알람 추가
  void addAlert(Alert alert) {
    _alerts.add(alert);
    _sortAlerts();
  }

  /// 알람 제거
  void removeAlert(String alertId) {
    _alerts.removeWhere((alert) => alert.id == alertId);
  }

  /// 만료된 알람 정리
  void cleanExpiredAlerts() {
    _alerts.removeWhere((alert) => alert.isExpired);
  }

  /// 특정 타입의 알람 조회
  List<Alert> getAlertsByType(AlertType type) {
    return _alerts.where((alert) => alert.type == type).toList();
  }

  /// 특정 심각도의 알람 조회
  List<Alert> getAlertsBySeverity(AlertSeverity severity) {
    return _alerts.where((alert) => alert.severity == severity).toList();
  }

  /// 긴급 알람 조회
  List<Alert> getUrgentAlerts() {
    return _alerts.where((alert) => alert.isUrgent).toList();
  }

  /// 최근 알람 조회 (시간순 정렬)
  List<Alert> getRecentAlerts({int limit = 10}) {
    return _alerts.take(limit).toList();
  }

  /// 모든 알람 조회
  List<Alert> getAllAlerts() => List.unmodifiable(_alerts);

  /// 알람 개수
  int get alertCount => _alerts.length;

  /// 우선순위별 알람 정렬
  void _sortAlerts() {
    _alerts.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));
  }
}
