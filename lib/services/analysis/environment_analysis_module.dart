import 'package:my_recipe_book/interfaces/analysis_module.dart';
import 'package:my_recipe_book/models/analysis_request.dart';
import 'package:my_recipe_book/models/environmental_conditions.dart'; // EnvironmentalConditions 모델이 필요할 수 있음

/// 환경 분석 모듈
///
/// 온도, 습도, 고도 등 환경 조건이 베이킹에 미치는 영향을 분석합니다.
class EnvironmentAnalysisModule extends BaseAnalysisModule {
  static const String moduleName = 'environment_analysis';
  static const String moduleVersion = '1.0.0';

  EnvironmentAnalysisModule()
      : super(
          name: moduleName,
          version: moduleVersion,
          description: '환경 조건이 베이킹에 미치는 영향 분석 모듈',
          priority: 3, // IngredientAnalysisModule 다음 우선순위
          dependencies: [], // 초기 의존성 없음
          category: AnalysisModuleCategory.environment,
          initialConfiguration: {
            'enable_temperature_humidity_correction': true,
            'enable_altitude_analysis': true,
            'enable_seasonal_factor_analysis': true,
          },
        );

  @override
  Future<void> onInitialize() async {
    // 환경 분석에 필요한 리소스 초기화
  }

  @override
  Future<void> onDispose() async {
    // 리소스 정리
  }

  @override
  bool canHandle(AnalysisRequest request) {
    // 환경 조건이 제공된 경우에만 처리 가능
    return request.environment != null;
  }

  @override
  Future<Map<String, dynamic>> analyze(AnalysisRequest request) async {
    final environment = request.environment;
    final options = request.options;

    final results = <String, dynamic>{};

    try {
      // 1. 온도/습도 보정 분석
      if ((getConfiguration<bool>('enable_temperature_humidity_correction', true) ?? false)) {
        results['temperature_humidity_correction'] = _analyzeTemperatureHumidity(environment);
      }

      // 2. 고도 영향 분석
      if ((getConfiguration<bool>('enable_altitude_analysis', true) ?? false)) {
        results['altitude_analysis'] = _analyzeAltitude(environment);
      }

      // 3. 계절적 요인 분석
      if ((getConfiguration<bool>('enable_seasonal_factor_analysis', true) ?? false)) {
        results['seasonal_factor_analysis'] = _analyzeSeasonalFactors(environment);
      }

      // TODO: 장비 특성 반영 (추후 확장)

    } catch (e) {
      throw AnalysisProcessingException(
        '환경 분석 중 오류가 발생했습니다: $e',
        moduleName: name,
        cause: e is Exception ? e : Exception(e.toString()),
      );
    }

    return results;
  }

  /// 온도/습도 보정 분석
  Map<String, dynamic> _analyzeTemperatureHumidity(EnvironmentalConditions environment) {
    final temperature = environment.temperature;
    final humidity = environment.humidity;

    String correctionNeeded = '없음';
    if (temperature < 20 || temperature > 28) { // 예시: 적정 온도 20-28도
      correctionNeeded = '온도 조절 필요';
    }
    if (humidity < 40 || humidity > 60) { // 예시: 적정 습도 40-60%
      correctionNeeded = '습도 조절 필요';
    }

    return {
      'current_temperature': temperature,
      'current_humidity': humidity,
      'correction_needed': correctionNeeded,
      'recommendations': _generateTemperatureHumidityRecommendations(temperature, humidity),
    };
  }

  List<String> _generateTemperatureHumidityRecommendations(double temperature, double humidity) {
    final recommendations = <String>[];
    if (temperature < 20) recommendations.add('실내 온도를 20-28도 사이로 유지하세요.');
    if (temperature > 28) recommendations.add('실내 온도를 낮춰주세요.');
    if (humidity < 40) recommendations.add('실내 습도를 40-60%로 유지하기 위해 가습기를 사용하세요.');
    if (humidity > 60) recommendations.add('실내 습도를 낮춰주세요.');
    return recommendations;
  }

  /// 고도 영향 분석
  Map<String, dynamic> _analyzeAltitude(EnvironmentalConditions environment) {
    final altitude = environment.altitude;

    String impact = '없음';
    List<String> recommendations = [];

    if (altitude > 1000) { // 예시: 1000m 이상 고도
      impact = '고도 영향 있음';
      recommendations.add('고도에 따라 레시피의 액체량과 베이킹 시간을 조절해야 합니다.');
      recommendations.add('베이킹 파우더나 소다의 양을 줄이는 것을 고려하세요.');
    }

    return {
      'current_altitude': altitude,
      'impact': impact,
      'recommendations': recommendations,
    };
  }

  /// 계절적 요인 분석
  Map<String, dynamic> _analyzeSeasonalFactors(EnvironmentalConditions environment) {
    final currentMonth = DateTime.now().month; // 현재 월을 기준으로 계절 판단
    String season = '알 수 없음';
    List<String> recommendations = [];

    if (currentMonth >= 3 && currentMonth <= 5) {
      season = '봄';
      recommendations.add('봄철에는 온도가 불안정할 수 있으니 발효 과정에 주의하세요.');
    } else if (currentMonth >= 6 && currentMonth <= 8) {
      season = '여름';
      recommendations.add('여름철에는 높은 온도와 습도로 인해 반죽이 과발효될 수 있으니 냉장 발효를 고려하세요.');
    }
    else if (currentMonth >= 9 && currentMonth <= 11) {
      season = '가을';
      recommendations.add('가을철에는 건조할 수 있으니 반죽이 마르지 않도록 주의하세요.');
    }
    else if (currentMonth == 12 || (currentMonth >= 1 && currentMonth <= 2)) {
      season = '겨울';
      recommendations.add('겨울철에는 낮은 온도로 인해 발효 시간이 길어질 수 있으니 따뜻한 곳에서 발효하세요.');
    }

    return {
      'current_season': season,
      'recommendations': recommendations,
    };
  }

  @override
  int estimateProcessingTime(AnalysisRequest request) {
    return 200; // 0.2초 (환경 분석은 비교적 빠름)
  }

  @override
  int estimateMemoryUsage(AnalysisRequest request) {
    return 2 * 1024 * 1024; // 2MB (환경 데이터는 작음)
  }

  @override
  List<String> getSupportedFeatures() {
    return [
      'temperature_humidity_correction',
      'altitude_analysis',
      'seasonal_factor_analysis',
    ];
  }

  @override
  List<String> getRequiredPermissions() {
    return []; // 특별한 권한 불필요
  }

  @override
  Map<String, dynamic> getConfigurationSchema() {
    return {
      'enable_temperature_humidity_correction': {
        'type': 'boolean',
        'default': true,
        'description': '온도/습도 보정 분석 활성화',
      },
      'enable_altitude_analysis': {
        'type': 'boolean',
        'default': true,
        'description': '고도 영향 분석 활성화',
      },
      'enable_seasonal_factor_analysis': {
        'type': 'boolean',
        'default': true,
        'description': '계절적 요인 분석 활성화',
      },
    };
  }
}