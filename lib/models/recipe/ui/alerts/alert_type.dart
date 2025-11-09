import 'package:json_annotation/json_annotation.dart';

/// 알람 타입
enum AlertType {
  @JsonValue('fermentation_time_deviation')
  fermentationTimeDeviation,
  @JsonValue('baking_temperature_deviation')
  bakingTemperatureDeviation,
  @JsonValue('environment_variable_deviation')
  environmentVariableDeviation,
  @JsonValue('process_completion')
  processCompletion,
}

extension AlertTypeExtension on AlertType {
  String get displayName {
    switch (this) {
      case AlertType.fermentationTimeDeviation:
        return '발효 시간 이탈';
      case AlertType.bakingTemperatureDeviation:
        return '굽기 온도 이탈';
      case AlertType.environmentVariableDeviation:
        return '환경 변수 이탈';
      case AlertType.processCompletion:
        return '공정 완료';
    }
  }

  String get description {
    switch (this) {
      case AlertType.fermentationTimeDeviation:
        return '발효 과정에서 예상 시간과의 차이가 발생한 경우';
      case AlertType.bakingTemperatureDeviation:
        return '굽기 과정에서 온도가 예상 범위를 벗어난 경우';
      case AlertType.environmentVariableDeviation:
        return '온도, 습도 등의 환경 조건이 권장 범위를 벗어난 경우';
      case AlertType.processCompletion:
        return '빵 만들기 공정이 완료되었음을 알리는 경우';
    }
  }

  /// 알람의 우선순위 레벨 (높을수록 중요)
  int get priorityLevel {
    switch (this) {
      case AlertType.fermentationTimeDeviation:
        return 3; // 발효 실패는 심각한 문제
      case AlertType.bakingTemperatureDeviation:
        return 4; // 굽기 실패는 가장 심각
      case AlertType.environmentVariableDeviation:
        return 2; // 환경 문제는 중간 중요도
      case AlertType.processCompletion:
        return 1; // 완료 알림은 낮은 우선순위
    }
  }

  /// 알람 아이콘 추천
  String get recommendedIcon {
    switch (this) {
      case AlertType.fermentationTimeDeviation:
        return '⏰';
      case AlertType.bakingTemperatureDeviation:
        return '🌡️';
      case AlertType.environmentVariableDeviation:
        return '🌤️';
      case AlertType.processCompletion:
        return '✅';
    }
  }
}
