import 'package:flutter/material.dart';
import '../../base_module.dart';
import '../../../../../core/types/unified_types.dart';
import '../../../../../core/types/environment_types.dart';

/// 빵 모듈 구현
class BreadModule extends SousChefModule {
  const BreadModule()
      : super(
          id: 'bread',
          displayName: '빵 모듈',
          description: '빵 베이킹 전문 모듈',
          version: '2.0.0',
          icon: Icons.bakery_dining,
          themeColor: Colors.amber,
        );

  @override
  Future<AnalysisResult> analyze(UnifiedRecipe recipe) async {
    // 빵 레시피 분석 로직
    final analysisData = {
      'ingredients': recipe.ingredients.length,
      'processes': recipe.processes.length,
      'hasFlour': recipe.ingredients.any((ing) =>
          ing.name.toLowerCase().contains('밀가루') ||
          ing.name.toLowerCase().contains('flour')),
      'hasYeast': recipe.ingredients.any((ing) =>
          ing.name.toLowerCase().contains('이스트') ||
          ing.name.toLowerCase().contains('yeast')),
      'hasWater': recipe.ingredients.any((ing) =>
          ing.name.toLowerCase().contains('물') ||
          ing.name.toLowerCase().contains('water')),
      'totalWeight':
          recipe.ingredients.fold<double>(0.0, (sum, ing) => sum + ing.amount),
      'analysis': {
        'recommendations': [
          '반죽 시간을 10분 정도로 유지하세요',
          '발효 온도는 25-28°C가 적당합니다',
          '오븐 예열을 충분히 하세요',
        ],
        'warnings': [],
        'tips': [
          '반죽 시 밀가루의 60% 정도의 물을 먼저 넣어주세요',
          '발효 중에 온도와 습도를 일정하게 유지하세요',
        ],
      },
    };

    return AnalysisResult.success(
      moduleId: id,
      data: analysisData,
      timestamp: DateTime.now(),
      confidence: 0.85,
    );
  }

  @override
  Future<AnalysisResult> analyzeWithEnvironment(
    UnifiedRecipe recipe,
    UserEnvironment environment,
  ) async {
    final baseAnalysis = await analyze(recipe);

    // 환경 정보를 고려한 추가 분석
    final environmentalFactors = {
      'temperature_impact':
          _calculateTemperatureImpact(environment.temperature),
      'humidity_impact': _calculateHumidityImpact(environment.humidity),
      'altitude_impact': _calculateAltitudeImpact(environment.altitude),
      'season_impact': _calculateSeasonImpact(environment.season),
    };

    final enhancedData = {
      ...baseAnalysis.data,
      'environmental_factors': environmentalFactors,
      'adjusted_recommendations':
          _getEnvironmentAdjustedRecommendations(environmentalFactors),
    };

    return AnalysisResult.success(
      moduleId: id,
      data: enhancedData,
      timestamp: DateTime.now(),
      confidence: 0.90,
    );
  }

  @override
  List<Widget> buildAnalysisUI(AnalysisResult result) {
    print('🔍 [BreadModule] buildAnalysisUI 시작');
    print('🔍 [BreadModule] result 타입: ${result.runtimeType}');
    print('🔍 [BreadModule] result.data 타입: ${result.data.runtimeType}');

    if (result.data is Map<String, dynamic>) {
      final data = result.data as Map<String, dynamic>;
      print('🔍 [BreadModule] result.data 키들: ${data.keys.toList()}');

      // 각 데이터 항목 로깅
      print('🔍 [BreadModule] ingredients: ${data['ingredients']}');
      print('🔍 [BreadModule] processes: ${data['processes']}');
      print('🔍 [BreadModule] totalWeight: ${data['totalWeight']}');
      print('🔍 [BreadModule] hasFlour: ${data['hasFlour']}');
      print('🔍 [BreadModule] hasYeast: ${data['hasYeast']}');
      print('🔍 [BreadModule] hasWater: ${data['hasWater']}');
    }

    return [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '빵 분석 결과',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text('재료 수: ${result.data['ingredients']}'),
              Text('프로세스 수: ${result.data['processes']}'),
              Text('총 무게: ${result.data['totalWeight'].toStringAsFixed(1)}g'),
              const SizedBox(height: 16),
              Text(
                '밀가루: ${result.data['hasFlour'] ? '포함' : '미포함'}',
                style: TextStyle(
                  color: result.data['hasFlour'] ? Colors.green : Colors.red,
                ),
              ),
              Text(
                '이스트: ${result.data['hasYeast'] ? '포함' : '미포함'}',
                style: TextStyle(
                  color: result.data['hasYeast'] ? Colors.green : Colors.red,
                ),
              ),
              Text(
                '물: ${result.data['hasWater'] ? '포함' : '미포함'}',
                style: TextStyle(
                  color: result.data['hasWater'] ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  @override
  List<Widget> buildAdviceUI(AnalysisResult result) {
    final recommendations =
        result.data['analysis']['recommendations'] as List<dynamic>;

    return recommendations.map<Widget>((rec) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.lightbulb, color: Colors.amber),
          title: Text(rec as String),
        ),
      );
    }).toList();
  }

  @override
  List<Widget> buildImprovementUI(AnalysisResult result) {
    final tips = result.data['analysis']['tips'] as List<dynamic>;

    return tips.map<Widget>((tip) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.build, color: Colors.blue),
          title: Text(tip as String),
        ),
      );
    }).toList();
  }

  @override
  void onModuleActivated() {
    debugPrint('빵 모듈이 활성화되었습니다');
  }

  @override
  void onModuleDeactivated() {
    debugPrint('빵 모듈이 비활성화되었습니다');
  }

  @override
  bool canHandleRecipe(UnifiedRecipe recipe) {
    // 빵 관련 키워드가 있는지 확인
    final title = recipe.title.toLowerCase();
    final ingredients =
        recipe.ingredients.map((ing) => ing.name.toLowerCase()).join(' ');

    final breadKeywords = [
      '빵',
      'bread',
      'dough',
      '반죽',
      '밀가루',
      'flour',
      '이스트',
      'yeast'
    ];
    return breadKeywords.any(
        (keyword) => title.contains(keyword) || ingredients.contains(keyword));
  }

  @override
  void onRecipeUpdated(UnifiedRecipe recipe) {
    debugPrint('빵 모듈: 레시피가 업데이트되었습니다 - ${recipe.title}');
  }

  // 환경 영향 계산 헬퍼 메서드들
  double _calculateTemperatureImpact(double temperature) {
    // 최적 온도(25°C)로부터의 편차 계산
    const optimalTemp = 25.0;
    final deviation = (temperature - optimalTemp).abs();
    return deviation > 5 ? 0.7 : (deviation > 2 ? 0.9 : 1.0);
  }

  double _calculateHumidityImpact(double humidity) {
    // 최적 습도(75%)로부터의 편차 계산
    const optimalHumidity = 75.0;
    final deviation = (humidity - optimalHumidity).abs();
    return deviation > 20 ? 0.6 : (deviation > 10 ? 0.8 : 1.0);
  }

  double _calculateAltitudeImpact(double altitude) {
    // 고도가 높을수록 발효에 영향
    if (altitude > 1000) return 0.8;
    if (altitude > 500) return 0.9;
    return 1.0;
  }

  double _calculateSeasonImpact(Season season) {
    // 계절별 발효 영향
    switch (season) {
      case Season.spring:
      case Season.autumn:
        return 1.0;
      case Season.summer:
        return 0.9; // 더운 여름은 발효 속도가 빠름
      case Season.winter:
        return 0.8; // 추운 겨울은 발효 속도가 느림
    }
  }

  List<String> _getEnvironmentAdjustedRecommendations(
      Map<String, double> factors) {
    final recommendations = <String>[];

    if (factors['temperature_impact']! < 0.9) {
      recommendations.add('온도 조절을 고려하세요');
    }

    if (factors['humidity_impact']! < 0.9) {
      recommendations.add('습도 관리가 중요합니다');
    }

    if (factors['altitude_impact']! < 1.0) {
      recommendations.add('고지대에서는 발효 시간을 조정하세요');
    }

    return recommendations;
  }
}
