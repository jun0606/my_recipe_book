import 'package:json_annotation/json_annotation.dart';

/// 알람 심각도
enum AlertSeverity {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
}

extension AlertSeverityExtension on AlertSeverity {
  String get displayName {
    switch (this) {
      case AlertSeverity.low:
        return '낮음';
      case AlertSeverity.medium:
        return '보통';
      case AlertSeverity.high:
        return '높음';
      case AlertSeverity.critical:
        return '긴급';
    }
  }

  String get koreanName {
    switch (this) {
      case AlertSeverity.low:
        return '낮음';
      case AlertSeverity.medium:
        return '보통';
      case AlertSeverity.high:
        return '높음';
      case AlertSeverity.critical:
        return '긴급';
    }
  }

  /// 심각도 레벨 (숫자가 높을수록 심각)
  int get level {
    switch (this) {
      case AlertSeverity.low:
        return 1;
      case AlertSeverity.medium:
        return 2;
      case AlertSeverity.high:
        return 3;
      case AlertSeverity.critical:
        return 4;
    }
  }

  /// 색상 코드 (UI 표시용)
  String get colorCode {
    switch (this) {
      case AlertSeverity.low:
        return '#4CAF50'; // 녹색
      case AlertSeverity.medium:
        return '#FF9800'; // 주황색
      case AlertSeverity.high:
        return '#FF5722'; // 빨강-주황
      case AlertSeverity.critical:
        return '#F44336'; // 빨강
    }
  }

  /// 아이콘 추천
  String get recommendedIcon {
    switch (this) {
      case AlertSeverity.low:
        return 'ℹ️';
      case AlertSeverity.medium:
        return '⚠️';
      case AlertSeverity.high:
        return '🚨';
      case AlertSeverity.critical:
        return '🔴';
    }
  }

  /// 사용자 액션 필요성
  String get actionRequired {
    switch (this) {
      case AlertSeverity.low:
        return '모니터링 권장';
      case AlertSeverity.medium:
        return '주의 필요';
      case AlertSeverity.high:
        return '즉시 조치 필요';
      case AlertSeverity.critical:
        return '긴급 조치 필수';
    }
  }

  /// 알람 지속 시간 (분)
  int get recommendedDurationMinutes {
    switch (this) {
      case AlertSeverity.low:
        return 60; // 1시간
      case AlertSeverity.medium:
        return 30; // 30분
      case AlertSeverity.high:
        return 15; // 15분
      case AlertSeverity.critical:
        return 5; // 5분
    }
  }

  /// 소리 알림 필요 여부
  bool get shouldPlaySound {
    return this == AlertSeverity.high || this == AlertSeverity.critical;
  }

  /// 진동 알림 필요 여부
  bool get shouldVibrate {
    return this == AlertSeverity.critical;
  }

  /// 푸시 알림 필요 여부
  bool get shouldPushNotify {
    return level >= 2; // medium 이상
  }
}
