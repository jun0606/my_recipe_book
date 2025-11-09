// 환경 컨트롤러
// 환경 데이터 처리 및 관리를 위한 비즈니스 로직

import '../../../../core/types/environment_types.dart';
import '../../../../services/environment_defaults_calculator.dart';

class EnvironmentController {
  /// 환경 데이터 검증
  static bool validateEnvironmentData(Map<String, dynamic> data) {
    final temperature = data['temperature'];
    final humidity = data['humidity'];
    final altitude = data['altitude'];

    return temperature is num &&
        temperature >= -50 &&
        temperature <= 100 &&
        humidity is num &&
        humidity >= 0 &&
        humidity <= 100 &&
        altitude is num &&
        altitude >= -500 &&
        altitude <= 10000;
  }

  /// Map 데이터를 UserEnvironment로 변환
  static UserEnvironment mapToUserEnvironment(Map<String, dynamic> data) {
    return UserEnvironment(
      temperature: (data['temperature'] as num?)?.toDouble() ?? 25.0,
      humidity: (data['humidity'] as num?)?.toDouble() ?? 60.0,
      pressure: (data['pressure'] as num?)?.toDouble() ?? 1013.25,
      altitude: (data['altitude'] as num?)?.toDouble() ?? 0.0,
      season: _parseSeason(data['season']?.toString()),
      ovenType: _parseOvenType(data['ovenType']?.toString()),
      fermentationMethod:
          _parseFermentationMethod(data['fermentationMethod']?.toString()),
      mixerType: _parseMixerType(data['mixerType']?.toString()),
      lastUpdated: DateTime.now(),
    );
  }

  /// UserEnvironment를 Map으로 변환
  static Map<String, dynamic> userEnvironmentToMap(UserEnvironment env) {
    return {
      'temperature': env.temperature,
      'humidity': env.humidity,
      'pressure': env.pressure,
      'altitude': env.altitude,
      'season': env.season.name,
      'ovenType': env.ovenType.name,
      'fermentationMethod': env.fermentationMethod.name,
      'mixerType': env.mixerType.name,
      'lastUpdated': env.lastUpdated.toIso8601String(),
    };
  }

  /// 환경 조건 분석 및 추천
  static Map<String, dynamic> analyzeEnvironmentalConditions(
      UserEnvironment env) {
    final recommendations = <String>[];
    final scores = <String, double>{};

    // 온도 분석
    if (env.temperature < 20) {
      recommendations.add('온도가 낮아 발효 시간이 길어질 수 있습니다. 따뜻한 곳으로 이동하세요.');
      scores['temperature'] = 0.6;
    } else if (env.temperature > 28) {
      recommendations.add('온도가 높아 과발효 위험이 있습니다. 서늘한 곳으로 이동하세요.');
      scores['temperature'] = 0.7;
    } else {
      scores['temperature'] = 1.0;
    }

    // 습도 분석
    if (env.humidity < 50) {
      recommendations.add('습도가 낮아 빵이 건조해질 수 있습니다. 물을 가까이 두세요.');
      scores['humidity'] = 0.6;
    } else if (env.humidity > 80) {
      recommendations.add('습도가 높아 빵이 무거워질 수 있습니다. 통풍이 잘 되는 곳을 확인하세요.');
      scores['humidity'] = 0.7;
    } else {
      scores['humidity'] = 1.0;
    }

    // 고도 분석
    if (env.altitude > 1000) {
      recommendations.add('고도가 높아 물이 빨리 증발할 수 있습니다. 수분량을 늘려보세요.');
      scores['altitude'] = 0.8;
    } else {
      scores['altitude'] = 1.0;
    }

    // 계절별 분석
    switch (env.season) {
      case Season.winter:
        recommendations.add('겨울에는 발효 시간을 20-30% 늘리는 것이 좋습니다.');
        break;
      case Season.summer:
        recommendations.add('여름에는 발효 시간을 10-20% 줄이는 것이 좋습니다.');
        break;
      default:
        break;
    }

    // 종합 점수 계산
    final overallScore = _calculateOverallScore(scores);

    return {
      'recommendations': recommendations,
      'scores': scores,
      'overallScore': overallScore,
      'isOptimal': overallScore >= 0.8,
    };
  }

  /// 환경 조건 기반 최적화 제안
  static Map<String, dynamic> suggestOptimizations(UserEnvironment env) {
    final optimizations = <String, Map<String, dynamic>>{};

    // 온도 최적화
    if (env.temperature < 22) {
      optimizations['temperature'] = {
        'action': '온도 높이기',
        'suggestion': '발효 온도를 2-3°C 높이거나 따뜻한 곳으로 이동',
        'impact': '발효 시간 20-30% 단축',
      };
    } else if (env.temperature > 26) {
      optimizations['temperature'] = {
        'action': '온도 낮추기',
        'suggestion': '발효 온도를 2-3°C 낮추거나 서늘한 곳으로 이동',
        'impact': '과발효 방지 및 품질 향상',
      };
    }

    // 습도 최적화
    if (env.humidity < 60) {
      optimizations['humidity'] = {
        'action': '습도 높이기',
        'suggestion': '물 용기를 가까이 두거나 습도 조절기 사용',
        'impact': '빵의 수분 유지 및 부드러움 향상',
      };
    } else if (env.humidity > 75) {
      optimizations['humidity'] = {
        'action': '습도 낮추기',
        'suggestion': '통풍이 잘 되는 곳으로 이동하거나 팬 사용',
        'impact': '빵의 바삭함 향상 및 무게 조절',
      };
    }

    // 오븐 타입 최적화
    switch (env.ovenType) {
      case OvenType.convection:
        optimizations['oven'] = {
          'action': '대류 오븐 최적화',
          'suggestion': '대류 팬을 활용하여 균일한 굽기',
          'impact': '전체적인 품질 향상',
        };
        break;
      case OvenType.home:
        optimizations['oven'] = {
          'action': '가정용 오븐 최적화',
          'suggestion': '오븐 온도를 10-15°C 높여서 보정',
          'impact': '더 좋은 굽기 결과',
        };
        break;
      default:
        break;
    }

    // 믹서 타입 최적화
    if (env.mixerType == MixerType.home) {
      optimizations['mixer'] = {
        'action': '가정용 믹서 최적화',
        'suggestion': '저속부터 시작하여 점진적으로 속도 높이기',
        'impact': '글루텐 형성 최적화',
      };
    }

    return {
      'optimizations': optimizations,
      'priorityOrder': _calculateOptimizationPriority(optimizations),
    };
  }

  /// 환경 조건 예측
  static UserEnvironment predictFutureEnvironment(
    UserEnvironment current,
    Duration timeAhead,
  ) {
    // 현재는 간단한 예측 로직 (실제로는 더 복잡한 알고리즘 사용)
    final hoursAhead = timeAhead.inHours;

    // 계절 변화 예측
    Season predictedSeason = current.season;
    if (hoursAhead > 24 * 30) {
      // 30일 이상
      // 계절 변화 로직 (단순화)
      final currentMonth = DateTime.now().month;
      final futureMonth =
          (currentMonth + (hoursAhead / (24 * 30)).round()) % 12;
      predictedSeason =
          Season.fromDate(DateTime(DateTime.now().year, futureMonth));
    }

    return UserEnvironment(
      temperature: current.temperature,
      humidity: current.humidity,
      pressure: current.pressure,
      altitude: current.altitude,
      season: predictedSeason,
      ovenType: current.ovenType,
      fermentationMethod: current.fermentationMethod,
      mixerType: current.mixerType,
      lastUpdated: DateTime.now(),
    );
  }

  /// 환경 데이터 저장
  static Future<bool> saveEnvironmentData(UserEnvironment env) async {
    try {
      // 실제로는 SharedPreferences나 데이터베이스에 저장
      final data = userEnvironmentToMap(env);
      print('환경 데이터 저장: $data');
      return true;
    } catch (e) {
      print('환경 데이터 저장 실패: $e');
      return false;
    }
  }

  /// 환경 데이터 로드
  static Future<UserEnvironment?> loadEnvironmentData() async {
    try {
      // 실제로는 SharedPreferences나 데이터베이스에서 로드
      // 임시로 기본 환경 반환
      return UserEnvironment.defaultEnvironment();
    } catch (e) {
      print('환경 데이터 로드 실패: $e');
      return null;
    }
  }

  // 헬퍼 메서드들
  static Season _parseSeason(String? value) {
    if (value == null) return Season.spring;

    switch (value.toLowerCase()) {
      case 'spring':
        return Season.spring;
      case 'summer':
        return Season.summer;
      case 'autumn':
        return Season.autumn;
      case 'winter':
        return Season.winter;
      default:
        return Season.spring;
    }
  }

  static OvenType _parseOvenType(String? value) {
    if (value == null) return OvenType.convection;

    switch (value.toLowerCase()) {
      case 'convection':
        return OvenType.convection;
      case 'radiation':
        return OvenType.radiation;
      case 'stone':
        return OvenType.stone;
      case 'home':
        return OvenType.home;
      case 'professional':
        return OvenType.professional;
      default:
        return OvenType.convection;
    }
  }

  static FermentationMethod _parseFermentationMethod(String? value) {
    if (value == null) return FermentationMethod.roomTemperature;

    switch (value.toLowerCase()) {
      case 'roomtemperature':
        return FermentationMethod.roomTemperature;
      case 'overnight': // 제거된 값은 roomTemperature로 매핑
        return FermentationMethod.roomTemperature;
      case 'fermenter':
        return FermentationMethod.fermenter;
      case 'natural': // 제거된 값은 roomTemperature로 매핑
        return FermentationMethod.roomTemperature;
      default:
        return FermentationMethod.roomTemperature;
    }
  }

  static MixerType _parseMixerType(String? value) {
    if (value == null) return MixerType.home;

    switch (value.toLowerCase()) {
      case 'home':
        return MixerType.home;
      case 'commercial':
        return MixerType.commercial;
      case 'professional':
        return MixerType.professional;
      default:
        return MixerType.home;
    }
  }

  static double _calculateOverallScore(Map<String, double> scores) {
    if (scores.isEmpty) return 0.0;

    final totalScore = scores.values.reduce((a, b) => a + b);
    return totalScore / scores.length;
  }

  static List<String> _calculateOptimizationPriority(
      Map<String, Map<String, dynamic>> optimizations) {
    // 우선순위 계산 로직 (간소화)
    final priorities = <String>[];

    if (optimizations.containsKey('temperature')) {
      priorities.add('temperature');
    }
    if (optimizations.containsKey('humidity')) {
      priorities.add('humidity');
    }
    if (optimizations.containsKey('oven')) {
      priorities.add('oven');
    }
    if (optimizations.containsKey('mixer')) {
      priorities.add('mixer');
    }

    return priorities;
  }
}
