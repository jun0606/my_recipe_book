// lib/services/bread_rpm_calculator.dart
// RPM 관련 계산 기능 모듈

/// RPM 기반 계산 결과를 담는 클래스
class RPMCalculationResult {
  final double rpm;
  final double efficiency;
  final double heatFactor;
  final int optimalTime;
  final String speed;
  final String mixerType;

  const RPMCalculationResult({
    required this.rpm,
    required this.efficiency,
    required this.heatFactor,
    required this.optimalTime,
    required this.speed,
    required this.mixerType,
  });

  Map<String, dynamic> toMap() {
    return {
      'rpm': rpm,
      'efficiency': efficiency,
      'heatFactor': heatFactor,
      'optimalTime': optimalTime,
      'speed': speed,
      'mixerType': mixerType,
    };
  }
}

/// RPM 기반 발열 계산 결과 클래스
class HeatGenerationResult {
  final double baseHeat;
  final double adjustedHeat;
  final double temperatureChange;
  final double efficiency;
  final String mixerType;

  const HeatGenerationResult({
    required this.baseHeat,
    required this.adjustedHeat,
    required this.temperatureChange,
    required this.efficiency,
    required this.mixerType,
  });

  Map<String, dynamic> toMap() {
    return {
      'baseHeat': baseHeat,
      'adjustedHeat': adjustedHeat,
      'temperatureChange': temperatureChange,
      'efficiency': efficiency,
      'mixerType': mixerType,
    };
  }
}

/// RPM 기반 시간 계산 결과 클래스
class TimeCalculationResult {
  final int baseTime;
  final int adjustedTime;
  final double timeMultiplier;
  final double rpmEfficiency;
  final String speed;
  final String mixerType;

  const TimeCalculationResult({
    required this.baseTime,
    required this.adjustedTime,
    required this.timeMultiplier,
    required this.rpmEfficiency,
    required this.speed,
    required this.mixerType,
  });

  Map<String, dynamic> toMap() {
    return {
      'baseTime': baseTime,
      'adjustedTime': adjustedTime,
      'timeMultiplier': timeMultiplier,
      'rpmEfficiency': rpmEfficiency,
      'speed': speed,
      'mixerType': mixerType,
    };
  }
}

/// 빵 믹서 RPM 계산기 클래스
class BreadRPMCalculator {
  /// 믹서 RPM 프로파일 (빵 굽기 최적 RPM 기반)
  static const Map<String, Map<String, Map<String, double>>> mixerRPMProfiles =
      {
    '가정용': {
      '저속': {
        'rpm': 70.0, // 초기 반죽 최적 RPM
        'efficiency': 0.85, // 효율성 계수
        'heatFactor': 0.8, // 발열 계수
        'optimalTime': 5, // 최적 시간(분)
      },
      '중속': {
        'rpm': 130.0, // 본 반죽 최적 RPM
        'efficiency': 1.0, // 기준 효율성
        'heatFactor': 1.0, // 기준 발열
        'optimalTime': 10, // 최적 시간(분)
      },
      '고속': {
        'rpm': 200.0, // 마무리 최적 RPM
        'efficiency': 0.9, // 효율성 약간 감소
        'heatFactor': 1.2, // 발열 증가
        'optimalTime': 3, // 최적 시간(분)
      },
    },
    '상업용': {
      '저속': {
        'rpm': 90.0,
        'efficiency': 0.9,
        'heatFactor': 0.85,
        'optimalTime': 5
      },
      '중속': {
        'rpm': 170.0,
        'efficiency': 1.0,
        'heatFactor': 1.0,
        'optimalTime': 10
      },
      '고속': {
        'rpm': 250.0,
        'efficiency': 0.95,
        'heatFactor': 1.1,
        'optimalTime': 3
      },
    },
    '전문가용': {
      '저속': {
        'rpm': 110.0,
        'efficiency': 1.0,
        'heatFactor': 0.9,
        'optimalTime': 5
      },
      '중속': {
        'rpm': 210.0,
        'efficiency': 1.0,
        'heatFactor': 1.0,
        'optimalTime': 10
      },
      '고속': {
        'rpm': 310.0,
        'efficiency': 1.0,
        'heatFactor': 1.0,
        'optimalTime': 3
      },
    },
  };

  /// 믹서 타입으로 RPM 프로파일 조회
  static Map<String, Map<String, double>> _getMixerRPMProfile(
      String? mixerType) {
    final normalizedType = _normalizeMixerType(mixerType);
    return mixerRPMProfiles[normalizedType] ?? mixerRPMProfiles['가정용']!;
  }

  /// 믹서 타입 정규화
  static String _normalizeMixerType(String? mixerType) {
    if (mixerType == null) return '가정용';

    switch (mixerType.toLowerCase()) {
      case 'home':
      case '가정용':
      case 'domestic':
        return '가정용';
      case 'commercial':
      case '상업용':
      case 'business':
        return '상업용';
      case 'professional':
      case '전문가용':
      case 'expert':
        return '전문가용';
      default:
        return '가정용';
    }
  }

  /// 속도로 가장 가까운 RPM 값 찾기
  static Map<String, double> _findClosestRPMSettings(
      String speed, Map<String, Map<String, double>> rpmProfile) {
    // 입력 속도를 정규화
    final normalizedSpeed = _normalizeSpeed(speed);

    // 해당 속도의 RPM 설정이 있으면 반환
    if (rpmProfile.containsKey(normalizedSpeed)) {
      return rpmProfile[normalizedSpeed]!;
    }

    // 기본값으로 중속 설정 반환
    return rpmProfile['중속'] ??
        {
          'rpm': 130.0,
          'efficiency': 1.0,
          'heatFactor': 1.0,
          'optimalTime': 10.0
        };
  }

  /// 속도 값 정규화
  static String _normalizeSpeed(String speed) {
    final lowerSpeed = speed.toLowerCase();

    if (lowerSpeed.contains('저속') ||
        lowerSpeed.contains('low') ||
        lowerSpeed.contains('slow')) {
      return '저속';
    } else if (lowerSpeed.contains('중속') ||
        lowerSpeed.contains('medium') ||
        lowerSpeed.contains('mid')) {
      return '중속';
    } else if (lowerSpeed.contains('고속') ||
        lowerSpeed.contains('high') ||
        lowerSpeed.contains('fast')) {
      return '고속';
    }

    // 기본값으로 중속 반환
    return '중속';
  }

  /// RPM 값 유효성 검증
  static bool _validateRPM(double rpm) {
    // RPM 범위 검증 (빵 믹서의 실제 RPM 범위)
    if (rpm < 50 || rpm > 500) return false;

    // 합리적인 RPM 값들만 허용
    final validRPMs = [
      70.0,
      90.0,
      110.0,
      130.0,
      170.0,
      200.0,
      210.0,
      250.0,
      310.0
    ];
    return validRPMs.contains(rpm);
  }

  /// RPM 효율성 계산 (빵 굽기 과학 기반)
  static double _calculateRPMEfficiency(double rpm, String mixerType) {
    // 최적 RPM 범위: 100-200 RPM (빵 굽기 연구 기반)
    const optimalMinRPM = 100.0;
    const optimalMaxRPM = 200.0;

    double efficiency = 1.0;

    if (rpm >= optimalMinRPM && rpm <= optimalMaxRPM) {
      // 최적 범위 내: 최대 효율성
      efficiency = 1.0;
    } else if (rpm < optimalMinRPM) {
      // 저RPM 범위: 효율성 감소 (글루텐 형성 부족)
      final deviation = optimalMinRPM - rpm;
      efficiency = 1.0 - (deviation / optimalMinRPM) * 0.3; // 최대 30% 감소
    } else {
      // 고RPM 범위: 효율성 감소 (글루텐 파괴)
      final deviation = rpm - optimalMaxRPM;
      efficiency = 1.0 - (deviation / 100.0) * 0.2; // 100RPM마다 20% 감소
    }

    // 믹서 타입별 효율성 보정
    final mixerEfficiency = _getMixerEfficiency(mixerType);
    efficiency *= mixerEfficiency;

    return efficiency.clamp(0.5, 1.0); // 최소 50%에서 최대 100%
  }

  /// 믹서 타입별 기본 효율성
  static double _getMixerEfficiency(String mixerType) {
    switch (mixerType.toLowerCase()) {
      case 'professional':
      case '전문가용':
        return 1.0; // 전문가용: 기준 효율성
      case 'commercial':
      case '상업용':
        return 0.95; // 상업용: 약간 낮은 효율성
      case 'home':
      case '가정용':
      default:
        return 0.85; // 가정용: 효율성 낮음
    }
  }

  /// 믹서 타입별 발열 계수
  static double _getMixerHeatFactor(String mixerType) {
    switch (mixerType.toLowerCase()) {
      case 'professional':
      case '전문가용':
        return 1.0; // 전문가용: 기준 발열
      case 'commercial':
      case '상업용':
        return 1.1; // 상업용: 약간 높은 발열
      case 'home':
      case '가정용':
      default:
        return 1.2; // 가정용: 높은 발열 (효율성 낮음)
    }
  }

  /// RPM 프로파일 조회 함수 (UI에서 사용)
  static Map<String, Map<String, double>> getMixerRPMProfile(
      String? mixerType) {
    final normalizedType = _normalizeMixerType(mixerType);
    return mixerRPMProfiles[normalizedType] ?? mixerRPMProfiles['가정용']!;
  }

  /// RPM 계산 (메인 함수)
  static RPMCalculationResult calculateRPMSettings(
      String speed, String mixerType) {
    final rpmProfile = getMixerRPMProfile(mixerType);
    final rpmSettings = _findClosestRPMSettings(speed, rpmProfile);

    final rpm = rpmSettings['rpm'] ?? 130.0;
    final efficiency = rpmSettings['efficiency'] ?? 1.0;
    final heatFactor = rpmSettings['heatFactor'] ?? 1.0;
    final optimalTime = (rpmSettings['optimalTime'] ?? 10).toInt();

    return RPMCalculationResult(
      rpm: rpm,
      efficiency: efficiency,
      heatFactor: heatFactor,
      optimalTime: optimalTime,
      speed: speed,
      mixerType: mixerType,
    );
  }

  /// RPM 기반 발열 계산
  static HeatGenerationResult calculateHeatGeneration(double rpm, int time,
      String mixerType, double currentTemp, double targetTemp) {
    // 기본 발열 계산
    final baseHeat = _calculateBaseHeatGeneration(rpm, time);

    // 믹서 타입별 발열 보정
    final mixerHeatFactor = _getMixerHeatFactor(mixerType);
    final adjustedHeat = baseHeat * mixerHeatFactor;

    // RPM 효율성 보정
    final rpmEfficiency = _calculateRPMEfficiency(rpm, mixerType);
    final finalHeat = adjustedHeat * rpmEfficiency;

    // 온도 차이에 따른 보정 (현재 온도가 높을수록 발열 감소)
    final tempDiff = targetTemp - currentTemp;
    double temperatureEfficiency = 1.0;
    if (tempDiff > 5) {
      temperatureEfficiency = 1.1; // 목표 온도가 높음: 발열 증가
    } else if (tempDiff < -5) {
      temperatureEfficiency = 0.9; // 목표 온도가 낮음: 발열 감소
    }

    final finalAdjustedHeat = finalHeat * temperatureEfficiency;
    final temperatureChange = finalAdjustedHeat;

    return HeatGenerationResult(
      baseHeat: baseHeat,
      adjustedHeat: finalAdjustedHeat,
      temperatureChange: temperatureChange,
      efficiency: rpmEfficiency,
      mixerType: mixerType,
    );
  }

  /// 기본 발열 계산 (RPM 기반)
  static double _calculateBaseHeatGeneration(double rpm, int time) {
    // RPM에 따른 기본 발열: RPM이 높을수록 발열 증가
    // 130 RPM 기준으로 1°C/min 발열 가정
    const baseRPM = 130.0;
    const baseHeatPerMin = 1.0; // °C per minute at base RPM

    final rpmFactor = rpm / baseRPM;
    final heatPerMin = baseHeatPerMin * rpmFactor;

    return heatPerMin * time;
  }

  /// RPM 기반 시간 계산
  static TimeCalculationResult calculateTimeWithRPM(
      Map<String, dynamic> inputs, String speed, int baseTime, double rpm) {
    double timeMultiplier = 1.0;

    // 믹서 타입별 시간 보정 (기존 로직 유지)
    final mixerType = inputs['mixerType'] as String? ?? '가정용';
    switch (mixerType) {
      case 'professional':
        timeMultiplier *= 0.8;
        break;
      case 'spiral':
        timeMultiplier *= 0.9;
        break;
      case 'planetary':
        timeMultiplier *= 1.1;
        break;
      case 'hand':
        timeMultiplier *= 1.5;
        break;
    }

    // 속도별 시간 보정 (기존 로직 유지)
    switch (speed) {
      case '저속':
        timeMultiplier *= 1.2;
        break;
      case '고속':
        timeMultiplier *= 0.8;
        break;
    }

    // 온도별 시간 보정 (기존 로직 유지)
    final temperature = inputs['temperature'] as double? ?? 24.0;
    if (temperature < 20) {
      timeMultiplier *= 1.3;
    } else if (temperature > 28) {
      timeMultiplier *= 0.9;
    }

    // RPM 효율성 보정 (새로 추가)
    final rpmEfficiency = _calculateRPMEfficiency(rpm, mixerType);
    timeMultiplier *= (2.0 - rpmEfficiency); // 효율성이 높을수록 시간 단축

    final adjustedTime = (baseTime * timeMultiplier).round();

    return TimeCalculationResult(
      baseTime: baseTime,
      adjustedTime: adjustedTime,
      timeMultiplier: timeMultiplier,
      rpmEfficiency: rpmEfficiency,
      speed: speed,
      mixerType: mixerType,
    );
  }

  /// RPM 유효성 검증
  static bool validateRPM(double rpm) {
    return _validateRPM(rpm);
  }

  /// RPM 효율성 조회
  static double getRPMEfficiency(double rpm, String mixerType) {
    return _calculateRPMEfficiency(rpm, mixerType);
  }
}
