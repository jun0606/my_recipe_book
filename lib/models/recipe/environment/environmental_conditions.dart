import 'dart:math' as math;
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'season.dart';
import 'oven_characteristics.dart';
import 'oven_type.dart';

part 'environmental_conditions.g.dart';

/// 환경 조건 정보
@HiveType(typeId: 6)
@JsonSerializable()
class EnvironmentalConditions {
  @HiveField(0)
  final double temperature; // 섭씨
  @HiveField(1)
  final double humidity; // 퍼센트
  @HiveField(2)
  final double pressure; // hPa
  @HiveField(3)
  final Season season;
  @HiveField(4)
  final OvenCharacteristics oven;
  @HiveField(5)
  final double? altitude; // 미터

  const EnvironmentalConditions({
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.season,
    required this.oven,
    this.altitude,
  });

  factory EnvironmentalConditions.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentalConditionsFromJson(json);

  Map<String, dynamic> toJson() => _$EnvironmentalConditionsToJson(this);

  EnvironmentalConditions copyWith({
    double? temperature,
    double? humidity,
    double? pressure,
    Season? season,
    OvenCharacteristics? oven,
    double? altitude,
  }) {
    return EnvironmentalConditions(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      pressure: pressure ?? this.pressure,
      season: season ?? this.season,
      oven: oven ?? this.oven,
      altitude: altitude ?? this.altitude,
    );
  }

  /// 온도 보정 계수: 1 + ((실제 온도 - 25) / 10)
  double get temperatureCorrection {
    return 1 + ((temperature - 25) / 10);
  }

  /// 습도 보정 계수: 1 + ((실제 습도% - 65) × 0.005)
  double get humidityCorrection {
    return 1 + ((humidity - 65) * 0.005);
  }

  /// 고도 보정 계수: 1 + ((현재 고도(m) / 1000) × 0.02)
  double get altitudeCorrection {
    if (altitude == null) return 1.0;
    return 1 + ((altitude! / 1000) * 0.02);
  }

  /// 발효 속도 온도 보정: 2^((실제 온도 - 25) / 10)
  double get fermentationSpeedCorrection {
    return math.pow(2, (temperature - 25) / 10).toDouble();
  }

  /// 🔥 더운 환경 반죽온도 조절 조언
  List<String> get heatManagementRecommendations {
    final recommendations = <String>[];

    if (temperature > 30) {
      // 매우 더운 환경 (30°C 이상)
      recommendations.addAll([
        '🚨 매우 더운 환경 감지: 반죽온도가 급격히 상승할 수 있습니다',
        '재료 온도 조절:',
        '  • 냉장 재료 사용 (냉장 우유, 냉동 버터)',
        '  • 얼음물로 반죽하거나 아이스 큐브 2-3개 추가',
        '  • 밀가루를 냉장고에서 30분 이상 차갑게 보관',
        '믹싱 최적화:',
        '  • 저속 믹싱으로 시작 (1단계)',
        '  • 1-2분 믹싱 후 2-3분 휴식 (과열 방지)',
        '  • 총 믹싱 시간 20-30% 단축',
        '환경 제어:',
        '  • 선풍기나 에어컨으로 작업 공간 22-24°C 유지',
        '  • 차가운 대리석판이나 스테인리스 작업대 사용',
        '  • 반죽을 냉장고에서 15-20분 휴지',
        '⚠️ 레시피 조정 주의사항:',
        '  • 이스트/소금 양 조정은 발효에 큰 영향 → 전문가 상담 권장',
        '  • 정확한 계산 불가로 인한 리스크: 발효 실패 가능성',
        '  • 초보자는 재료 온도와 믹싱 방법 조절만 권장'
      ]);
    } else if (temperature > 25) {
      // 다소 더운 환경 (25-30°C)
      recommendations.addAll([
        '⚠️ 다소 더운 환경 감지: 반죽온도 상승 주의',
        '재료 온도 조절:',
        '  • 차가운 물 사용 (실온보다 3-5°C 낮은 물)',
        '  • 버터를 냉장 상태로 사용',
        '  • 밀가루 실온 보관 (냉장고에서 꺼내기)',
        '믹싱 최적화:',
        '  • 중속에서 저속으로 변경',
        '  • 믹싱 시간 10-15% 단축',
        '환경 제어:',
        '  • 통풍이 좋은 장소에서 작업',
        '  • 반죽을 서늘한 곳에서 10분 휴지',
        '⚠️ 레시피 조정 주의사항:',
        '  • 정확한 계산이 어려우므로 변경 자제',
        '  • 발효 시간 모니터링 강화 권장'
      ]);
    }

    return recommendations;
  }

  /// 🔥 더운 환경용 안전한 조언만 분리
  List<String> get safeHeatManagementTips {
    final safeTips = <String>[];

    if (temperature > 30) {
      safeTips.addAll([
        '냉장 재료 사용 (냉장 우유, 냉동 버터)',
        '얼음물로 반죽하거나 아이스 큐브 2-3개 추가',
        '저속 믹싱으로 시작 (1단계)',
        '1-2분 믹싱 후 2-3분 휴식 (과열 방지)',
        '선풍기나 에어컨으로 작업 공간 냉각',
        '차가운 대리석판이나 스테인리스 작업대 사용',
        '반죽을 냉장고에서 15-20분 휴지'
      ]);
    } else if (temperature > 25) {
      safeTips.addAll([
        '차가운 물 사용 (실온보다 3-5°C 낮은 물)',
        '버터를 냉장 상태로 사용',
        '중속에서 저속으로 변경',
        '통풍이 좋은 장소에서 작업',
        '반죽을 서늘한 곳에서 10분 휴지'
      ]);
    }

    return safeTips;
  }

  /// ❄️ 추운 환경 반죽온도 조절 조언
  List<String> get coldManagementRecommendations {
    final recommendations = <String>[];

    if (temperature < 15) {
      // 매우 추운 환경 (15°C 미만)
      recommendations.addAll([
        '❄️ 매우 추운 환경 감지: 반죽온도가 낮아 발효가 느려질 수 있습니다',
        '재료 온도 조절:',
        '  • 따뜻한 물 사용 (35-40°C)',
        '  • 버터와 계란 실온에 1-2시간 보관',
        '  • 밀가루를 실온에 2-3시간 두기',
        '  • 이스트는 따뜻한 물에 미리 활성화',
        '믹싱 최적화:',
        '  • 고속 믹싱으로 시작 (글루텐 형성 촉진)',
        '  • 믹싱 시간 20-30% 연장',
        '  • 2-3분 믹싱 후 1분 휴식 (과열 방지)',
        '환경 제어:',
        '  • 난방이 되는 따뜻한 장소에서 작업',
        '  • 반죽을 보온 장소(오븐 옆)에 20-30분 휴지',
        '  • 믹싱 볼에 따뜻한 물 담가서 예열',
        '발효 관리:',
        '  • 발효 시간을 50-100% 연장',
        '  • 발효 온도를 26-28°C로 유지',
        '  • 습도 80% 이상 유지 (건조 방지)',
        '⚠️ 레시피 조정 주의사항:',
        '  • 이스트 양 10-20% 증가 가능성 (발효 촉진)',
        '  • 정확한 계산 불가로 인한 리스크: 과발효 가능성',
        '  • 초보자는 환경 제어와 믹싱 방법 조절만 권장'
      ]);
    } else if (temperature < 20) {
      // 다소 추운 환경 (15-20°C)
      recommendations.addAll([
        '❄️ 다소 추운 환경 감지: 발효 시간이 길어질 수 있습니다',
        '재료 온도 조절:',
        '  • 미지근한 물 사용 (25-30°C)',
        '  • 버터 실온에 30분-1시간 보관',
        '  • 밀가루 실온에 1-2시간 두기',
        '믹싱 최적화:',
        '  • 중속 믹싱으로 시작',
        '  • 믹싱 시간 10-15% 연장',
        '환경 제어:',
        '  • 난방이 되는 장소에서 작업',
        '  • 반죽을 따뜻한 곳에서 10-15분 휴지',
        '발효 관리:',
        '  • 발효 시간을 20-30% 연장',
        '  • 발효 중간에 1-2회 접기',
        '⚠️ 레시피 조정 주의사항:',
        '  • 이스트 양 소폭 증가 가능성 (정확도 낮음)',
        '  • 발효 모니터링 강화 권장'
      ]);
    }

    return recommendations;
  }

  /// ❄️ 추운 환경용 안전한 조언만 분리
  List<String> get safeColdManagementTips {
    final safeTips = <String>[];

    if (temperature < 15) {
      safeTips.addAll([
        '따뜻한 물 사용 (35-40°C)',
        '버터와 계란 실온에 1-2시간 보관',
        '밀가루를 실온에 2-3시간 두기',
        '이스트는 따뜻한 물에 미리 활성화',
        '고속 믹싱으로 시작 (글루텐 형성 촉진)',
        '믹싱 시간 20-30% 연장',
        '2-3분 믹싱 후 1분 휴식 (과열 방지)',
        '난방이 되는 따뜻한 장소에서 작업',
        '반죽을 보온 장소(오븐 옆)에 20-30분 휴지',
        '믹싱 볼에 따뜻한 물 담가서 예열',
        '발효 시간을 50-100% 연장',
        '발효 온도를 26-28°C로 유지',
        '습도 80% 이상 유지 (건조 방지)'
      ]);
    } else if (temperature < 20) {
      safeTips.addAll([
        '미지근한 물 사용 (25-30°C)',
        '버터 실온에 30분-1시간 보관',
        '밀가루 실온에 1-2시간 두기',
        '중속 믹싱으로 시작',
        '믹싱 시간 10-15% 연장',
        '난방이 되는 장소에서 작업',
        '반죽을 따뜻한 곳에서 10-15분 휴지',
        '발효 시간을 20-30% 연장',
        '발효 중간에 1-2회 접기'
      ]);
    }

    return safeTips;
  }
}
