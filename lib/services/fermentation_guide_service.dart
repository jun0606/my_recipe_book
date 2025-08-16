/// 통합 발효 가이드 서비스
/// 
/// 모든 발효 관련 로직을 통합하여 관리하는 중앙화된 서비스입니다.
/// 강타입 모델을 사용하여 타입 안전성을 보장하고,
/// 다양한 발효 방식에 대한 일관된 인터페이스를 제공합니다.

import 'dart:math';
import '../models/fermentation_guide_models.dart';
import '../models/sous_chef_models.dart';

/// 발효 가이드 서비스의 추상 인터페이스
abstract class IFermentationGuideService {
  /// 발효 방식에 따른 가이드 생성
  Future<FermentationGuide> generateGuide({
    required String fermentationType,
    required Map<String, dynamic> recipeData,
    required Map<String, dynamic> environmentalData,
    Map<String, dynamic>? customOptions,
  });

  /// 실시간 환경 분석
  Future<EnvironmentalAnalysis> analyzeEnvironment({
    required double temperature,
    required double humidity,
    required String fermentationType,
  });

  /// 레시피 분석
  Future<RecipeAnalysis> analyzeRecipe({
    required Map<String, dynamic> recipeData,
    required String fermentationType,
  });

  /// 발효 추천사항 생성
  Future<List<FermentationRecommendation>> generateRecommendations({
    required FermentationGuide guide,
    required EnvironmentalAnalysis environmentalAnalysis,
    required RecipeAnalysis recipeAnalysis,
  });
}

/// 통합 발효 가이드 서비스 구현
class FermentationGuideService implements IFermentationGuideService {
  // 싱글톤 패턴 제거하고 일반 클래스로 변경
  FermentationGuideService();

  /// 발효 방식별 기본 설정
  static const Map<String, Map<String, dynamic>> _fermentationDefaults = {
    'room_temperature': {
      'optimalTemperature': 25.0,
      'optimalHumidity': 65.0,
      'temperatureRange': [20.0, 30.0],
      'humidityRange': [60.0, 70.0],
      'estimatedDuration': Duration(hours: 8),
    },
    'cold': {
      'optimalTemperature': 4.0,
      'optimalHumidity': 80.0,
      'temperatureRange': [2.0, 8.0],
      'humidityRange': [75.0, 85.0],
      'estimatedDuration': Duration(hours: 24),
    },
    'warm': {
      'optimalTemperature': 35.0,
      'optimalHumidity': 70.0,
      'temperatureRange': [30.0, 40.0],
      'humidityRange': [65.0, 75.0],
      'estimatedDuration': Duration(hours: 4),
    },
  };
@override
  Future<FermentationGuide> generateGuide({
    required String fermentationType,
    required Map<String, dynamic> recipeData,
    required Map<String, dynamic> environmentalData,
    Map<String, dynamic>? customOptions,
  }) async {
    try {
      // 환경 및 레시피 분석
      final environmentalAnalysis = await analyzeEnvironment(
        temperature: environmentalData['temperature']?.toDouble() ?? 25.0,
        humidity: environmentalData['humidity']?.toDouble() ?? 65.0,
        fermentationType: fermentationType,
      );

      final recipeAnalysis = await analyzeRecipe(
        recipeData: recipeData,
        fermentationType: fermentationType,
      );

      // 기본 가이드 생성
      final guide = await _createBaseGuide(
        fermentationType: fermentationType,
        recipeData: recipeData,
        environmentalAnalysis: environmentalAnalysis,
        recipeAnalysis: recipeAnalysis,
        customOptions: customOptions,
      );

      // 추천사항 생성
      final recommendations = await generateRecommendations(
        guide: guide,
        environmentalAnalysis: environmentalAnalysis,
        recipeAnalysis: recipeAnalysis,
      );

      // 최종 가이드 완성
      return guide.copyWith(
        recommendations: recommendations,
        environmentalAnalysis: environmentalAnalysis,
        recipeAnalysis: recipeAnalysis,
        updatedAt: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw Exception('발효 가이드 생성 중 오류 발생: $e');
    }
  }

  @override
  Future<EnvironmentalAnalysis> analyzeEnvironment({
    required double temperature,
    required double humidity,
    required String fermentationType,
  }) async {
    final defaults = _fermentationDefaults[fermentationType] ?? _fermentationDefaults['room_temperature']!;
    
    final optimalTemp = defaults['optimalTemperature'] as double;
    final optimalHumidity = defaults['optimalHumidity'] as double;
    final tempRange = defaults['temperatureRange'] as List<double>;
    final humidityRange = defaults['humidityRange'] as List<double>;

    // 온도 상태 분석
    String temperatureStatus;
    if (temperature < tempRange[0]) {
      temperatureStatus = 'too_low';
    } else if (temperature > tempRange[1]) {
      temperatureStatus = 'too_high';
    } else {
      temperatureStatus = 'optimal';
    }

    // 습도 상태 분석
    String humidityStatus;
    if (humidity < humidityRange[0]) {
      humidityStatus = 'too_low';
    } else if (humidity > humidityRange[1]) {
      humidityStatus = 'too_high';
    } else {
      humidityStatus = 'optimal';
    }

    // 조정 팁 생성
    final adjustmentTips = <String>[];
    if (temperatureStatus == 'too_low') {
      adjustmentTips.add('온도가 낮습니다. 따뜻한 곳으로 이동하거나 발효기를 사용하세요.');
    } else if (temperatureStatus == 'too_high') {
      adjustmentTips.add('온도가 높습니다. 서늘한 곳으로 이동하거나 에어컨을 사용하세요.');
    }

    if (humidityStatus == 'too_low') {
      adjustmentTips.add('습도가 낮습니다. 젖은 수건을 근처에 두거나 가습기를 사용하세요.');
    } else if (humidityStatus == 'too_high') {
      adjustmentTips.add('습도가 높습니다. 제습기를 사용하거나 환기를 개선하세요.');
    }

    // 전체 평가
    String overallAssessment;
    if (temperatureStatus == 'optimal' && humidityStatus == 'optimal') {
      overallAssessment = '최적의 발효 환경입니다.';
    } else if (temperatureStatus != 'optimal' || humidityStatus != 'optimal') {
      overallAssessment = '환경 조정이 필요합니다.';
    } else {
      overallAssessment = '발효에 부적합한 환경입니다.';
    }

    return EnvironmentalAnalysis(
      currentTemperature: temperature,
      currentHumidity: humidity,
      optimalTemperature: optimalTemp,
      optimalHumidity: optimalHumidity,
      temperatureStatus: temperatureStatus,
      humidityStatus: humidityStatus,
      adjustmentTips: adjustmentTips,
      overallAssessment: overallAssessment,
    );
  }
@override
  Future<RecipeAnalysis> analyzeRecipe({
    required Map<String, dynamic> recipeData,
    required String fermentationType,
  }) async {
    // 레시피 데이터 추출
    final yeastAmount = _extractYeastAmount(recipeData);
    final sugarAmount = _extractSugarAmount(recipeData);
    final yeastType = _extractYeastType(recipeData);

    // 최적 비율 계산
    final totalFlour = _extractFlourAmount(recipeData);
    final optimalYeastRatio = _calculateOptimalYeastRatio(fermentationType, totalFlour);
    final optimalSugarRatio = _calculateOptimalSugarRatio(fermentationType, totalFlour);

    // 상태 분석
    final yeastStatus = _analyzeYeastStatus(yeastAmount, optimalYeastRatio);
    final sugarStatus = _analyzeSugarStatus(sugarAmount, optimalSugarRatio);

    // 최적화 팁 생성
    final optimizationTips = _generateOptimizationTips(
      yeastStatus: yeastStatus,
      sugarStatus: sugarStatus,
      yeastAmount: yeastAmount,
      sugarAmount: sugarAmount,
      optimalYeastRatio: optimalYeastRatio,
      optimalSugarRatio: optimalSugarRatio,
    );

    // 발효 시간 추정
    final estimatedTime = _estimateFermentationTime(
      fermentationType: fermentationType,
      yeastAmount: yeastAmount,
      sugarAmount: sugarAmount,
      temperature: 25.0, // 기본값, 실제로는 환경 데이터에서 가져와야 함
    );

    // 전체 평가
    final overallAssessment = _generateOverallAssessment(yeastStatus, sugarStatus);

    return RecipeAnalysis(
      yeastAmount: yeastAmount,
      sugarAmount: sugarAmount,
      yeastType: yeastType,
      yeastStatus: yeastStatus,
      sugarStatus: sugarStatus,
      optimizationTips: optimizationTips,
      estimatedFermentationTimeMinutes: estimatedTime.inMinutes,
      overallAssessment: overallAssessment,
    );
  }

  @override
  Future<List<FermentationRecommendation>> generateRecommendations({
    required FermentationGuide guide,
    required EnvironmentalAnalysis environmentalAnalysis,
    required RecipeAnalysis recipeAnalysis,
  }) async {
    final recommendations = <FermentationRecommendation>[];

    // 환경 기반 추천사항
    if (environmentalAnalysis.temperatureStatus != 'optimal') {
      recommendations.add(FermentationRecommendation(
        category: '환경 조정',
        title: '온도 최적화',
        description: '현재 온도가 최적 범위를 벗어났습니다.',
        actionItems: environmentalAnalysis.adjustmentTips,
        priority: 'high',
        reasoning: '온도는 발효 속도와 품질에 직접적인 영향을 미칩니다.',
      ));
    }

    // 레시피 기반 추천사항
    if (recipeAnalysis.yeastStatus != 'optimal') {
      recommendations.add(FermentationRecommendation(
        category: '레시피 조정',
        title: '이스트 양 조정',
        description: '이스트 양이 최적 비율과 다릅니다.',
        actionItems: recipeAnalysis.optimizationTips
            .where((tip) => tip.contains('이스트'))
            .toList(),
        priority: 'medium',
        reasoning: '적절한 이스트 양은 균일한 발효를 위해 중요합니다.',
      ));
    }

    // 시간 관리 추천사항
    recommendations.add(FermentationRecommendation(
      category: '시간 관리',
      title: '발효 시간 모니터링',
      description: '예상 발효 시간: ${_formatDuration(Duration(minutes: recipeAnalysis.estimatedFermentationTimeMinutes))}',
      actionItems: [
        '30분마다 발효 상태를 확인하세요',
        '과발효를 방지하기 위해 타이머를 설정하세요',
        '발효 완료 신호를 놓치지 마세요',
      ],
      priority: 'medium',
      reasoning: '적절한 발효 시간은 최종 제품의 품질을 결정합니다.',
    ));

    return recommendations;
  }

  /// 기본 가이드 생성
  Future<FermentationGuide> _createBaseGuide({
    required String fermentationType,
    required Map<String, dynamic> recipeData,
    required EnvironmentalAnalysis environmentalAnalysis,
    required RecipeAnalysis recipeAnalysis,
    Map<String, dynamic>? customOptions,
  }) async {
    final now = DateTime.now();
    final guideId = '${fermentationType}_${now.millisecondsSinceEpoch}';

    // 발효 방식별 기본 정보
    final typeInfo = _getFermentationTypeInfo(fermentationType);
    
    return FermentationGuide(
      id: guideId,
      name: typeInfo['name'] as String,
      type: fermentationType,
      description: typeInfo['description'] as String,
      methodExplanation: typeInfo['methodExplanation'] as String,
      customInstructions: _generateCustomInstructions(
        fermentationType,
        environmentalAnalysis,
        recipeAnalysis,
      ),
      steps: _generateFermentationSteps(fermentationType),
      tips: _generateFermentationTips(fermentationType),
      warnings: _generateFermentationWarnings(fermentationType),
      quickStartGuide: _generateQuickStartGuide(fermentationType),
      createdAt: now.toIso8601String(),
      metadata: {
        'version': '2.0',
        'generator': 'FermentationGuideService',
        'customOptions': customOptions ?? {},
      },
    );
  }

  /// 발효 방식별 기본 정보 반환
  Map<String, dynamic> _getFermentationTypeInfo(String type) {
    switch (type) {
      case 'room_temperature':
        return {
          'name': '실온 발효',
          'description': '실온에서 진행하는 자연스러운 발효 방식',
          'methodExplanation': '실온(20-30°C)에서 자연스럽게 발효시키는 방법입니다. '
              '온도와 습도를 적절히 유지하면서 6-12시간 정도 발효시킵니다.',
        };
      case 'cold':
        return {
          'name': '냉장 발효',
          'description': '냉장고에서 천천히 진행하는 저온 발효 방식',
          'methodExplanation': '냉장고(2-8°C)에서 천천히 발효시키는 방법입니다. '
              '12-48시간의 긴 시간이 걸리지만 깊은 맛과 향을 얻을 수 있습니다.',
        };
      case 'warm':
        return {
          'name': '온발효',
          'description': '따뜻한 환경에서 빠르게 진행하는 발효 방식',
          'methodExplanation': '발효기나 오븐의 발효 기능(30-40°C)을 사용하여 '
              '빠르게 발효시키는 방법입니다. 2-6시간 내에 완료됩니다.',
        };
      default:
        return {
          'name': '맞춤 발효',
          'description': '사용자 정의 발효 방식',
          'methodExplanation': '사용자가 설정한 조건에 따른 맞춤형 발효 방식입니다.',
        };
    }
  }

  /// 맞춤 지침 생성
  List<String> _generateCustomInstructions(
    String fermentationType,
    EnvironmentalAnalysis environmentalAnalysis,
    RecipeAnalysis recipeAnalysis,
  ) {
    final instructions = <String>[];

    // 환경 기반 지침
    if (environmentalAnalysis.temperatureStatus != 'optimal') {
      instructions.add('현재 온도(${environmentalAnalysis.currentTemperature.toStringAsFixed(1)}°C)가 '
          '최적 범위를 벗어났습니다. ${environmentalAnalysis.adjustmentTips.first}');
    }

    // 레시피 기반 지침
    if (recipeAnalysis.yeastStatus != 'optimal') {
      instructions.add('이스트 양이 ${recipeAnalysis.yeastStatus == 'insufficient' ? '부족' : '과다'}합니다. '
          '${recipeAnalysis.optimizationTips.first}');
    }

    // 발효 방식별 특별 지침
    switch (fermentationType) {
      case 'room_temperature':
        instructions.add('실온 발효는 계절과 실내 온도에 영향을 많이 받습니다. '
            '겨울철에는 따뜻한 곳에, 여름철에는 서늘한 곳에 두세요.');
        break;
      case 'cold':
        instructions.add('냉장 발효는 시간이 오래 걸리지만 맛이 깊어집니다. '
            '최소 12시간은 발효시켜야 효과를 볼 수 있습니다.');
        break;
      case 'warm':
        instructions.add('온발효는 빠르지만 과발효 위험이 높습니다. '
            '30분마다 상태를 확인하고 적절한 시점에 중단하세요.');
        break;
    }

    return instructions;
  }

  /// 발효 단계 생성
  List<FermentationStep> _generateFermentationSteps(String fermentationType) {
    switch (fermentationType) {
      case 'room_temperature':
        return [
          FermentationStep(
            title: '준비 단계',
            description: '발효 환경을 준비하고 반죽을 정리합니다.',
            durationMinutes: 15,
            checkpoints: ['반죽 표면이 매끄러운지 확인', '발효 용기가 깨끗한지 확인'],
            tips: ['반죽에 올리브오일을 살짝 발라주면 건조를 방지할 수 있습니다.'],
          ),
          FermentationStep(
            title: '1차 발효',
            description: '실온에서 반죽이 2배로 부풀 때까지 발효시킵니다.',
            durationMinutes: 120,
            temperature: 25.0,
            checkpoints: ['반죽 크기가 2배로 증가', '표면에 기포가 보임', '손가락 테스트 통과'],
            tips: ['젖은 수건으로 덮어 건조를 방지하세요.', '직사광선을 피하세요.'],
          ),
          FermentationStep(
            title: '가스 빼기',
            description: '발효된 반죽의 가스를 빼고 재정리합니다.',
            durationMinutes: 5,
            checkpoints: ['반죽에서 가스가 빠짐', '반죽이 다시 매끄러워짐'],
            tips: ['너무 강하게 치대지 마세요.'],
          ),
          FermentationStep(
            title: '2차 발효',
            description: '성형 후 최종 발효를 진행합니다.',
            durationMinutes: 45,
            temperature: 25.0,
            checkpoints: ['반죽이 1.5배로 증가', '탄력이 생김'],
            tips: ['오븐을 예열하는 시간을 고려하여 타이밍을 맞추세요.'],
          ),
        ];
      case 'cold':
        return [
          FermentationStep(
            title: '준비 단계',
            description: '냉장 발효를 위한 반죽을 준비합니다.',
            durationMinutes: 20,
            checkpoints: ['반죽이 잘 반죽됨', '밀폐 용기 준비'],
            tips: ['냉장고에서 팽창할 공간을 충분히 남겨두세요.'],
          ),
          FermentationStep(
            title: '냉장 발효',
            description: '냉장고에서 천천히 발효시킵니다.',
            durationMinutes: 1440,
            temperature: 4.0,
            checkpoints: ['12시간 후 크기 확인', '24시간 후 최종 확인'],
            tips: ['발효 중간에 한 번 가스를 빼주면 더 좋습니다.'],
          ),
          FermentationStep(
            title: '실온 복귀',
            description: '사용 전 실온에서 30분간 둡니다.',
            durationMinutes: 30,
            temperature: 25.0,
            checkpoints: ['반죽이 실온에 적응', '작업하기 좋은 상태'],
            tips: ['너무 오래 두면 과발효될 수 있습니다.'],
          ),
        ];
      case 'warm':
        return [
          FermentationStep(
            title: '발효기 준비',
            description: '발효기를 35°C로 설정하고 준비합니다.',
            durationMinutes: 10,
            temperature: 35.0,
            checkpoints: ['발효기 온도 확인', '습도 조절'],
            tips: ['물그릇을 함께 넣어 습도를 유지하세요.'],
          ),
          FermentationStep(
            title: '1차 발효',
            description: '발효기에서 빠르게 발효시킵니다.',
            durationMinutes: 60,
            temperature: 35.0,
            checkpoints: ['30분마다 크기 확인', '과발효 주의'],
            tips: ['온발효는 빠르므로 자주 확인하세요.'],
          ),
          FermentationStep(
            title: '2차 발효',
            description: '성형 후 최종 발효를 진행합니다.',
            durationMinutes: 30,
            temperature: 35.0,
            checkpoints: ['적절한 크기 증가', '탄력 확인'],
            tips: ['과발효되면 맛이 떨어질 수 있습니다.'],
          ),
        ];
      default:
        return [];
    }
  }

  /// 발효 팁 생성
  List<FermentationTip> _generateFermentationTips(String fermentationType) {
    final commonTips = [
      FermentationTip(
        category: '기본',
        title: '손가락 테스트',
        content: '반죽에 밀가루를 묻힌 손가락을 찔러보세요. 구멍이 천천히 메워지면 적절히 발효된 것입니다.',
        priority: 5,
      ),
      FermentationTip(
        category: '기본',
        title: '발효 용기 선택',
        content: '투명한 용기를 사용하면 발효 상태를 쉽게 관찰할 수 있습니다.',
        priority: 3,
      ),
      FermentationTip(
        category: '환경',
        title: '습도 유지',
        content: '젖은 수건이나 랩으로 덮어 반죽이 마르지 않도록 하세요.',
        priority: 4,
      ),
    ];

    final specificTips = <FermentationTip>[];
    
    switch (fermentationType) {
      case 'room_temperature':
        specificTips.addAll([
          FermentationTip(
            category: '실온발효',
            title: '계절별 조정',
            content: '여름에는 발효 시간을 줄이고, 겨울에는 늘려주세요.',
            priority: 4,
          ),
          FermentationTip(
            category: '실온발효',
            title: '위치 선택',
            content: '직사광선을 피하고 온도가 일정한 곳을 선택하세요.',
            priority: 3,
          ),
        ]);
        break;
      case 'cold':
        specificTips.addAll([
          FermentationTip(
            category: '냉장발효',
            title: '시간 여유',
            content: '냉장 발효는 최소 12시간, 최대 72시간까지 가능합니다.',
            priority: 4,
          ),
          FermentationTip(
            category: '냉장발효',
            title: '용기 크기',
            content: '반죽이 팽창할 공간을 충분히 남겨두세요.',
            priority: 3,
          ),
        ]);
        break;
      case 'warm':
        specificTips.addAll([
          FermentationTip(
            category: '온발효',
            title: '온도 주의',
            content: '40°C를 넘지 않도록 주의하세요. 이스트가 죽을 수 있습니다.',
            priority: 5,
          ),
          FermentationTip(
            category: '온발효',
            title: '자주 확인',
            content: '빠른 발효이므로 15-30분마다 상태를 확인하세요.',
            priority: 4,
          ),
        ]);
        break;
    }

    return [...commonTips, ...specificTips];
  }

  /// 발효 경고사항 생성
  List<FermentationWarning> _generateFermentationWarnings(String fermentationType) {
    final commonWarnings = [
      FermentationWarning(
        title: '과발효 주의',
        description: '발효가 너무 오래되면 반죽이 시어지고 구조가 약해집니다.',
        severity: 'high',
        preventionTips: [
          '정해진 시간을 지키세요',
          '발효 상태를 주기적으로 확인하세요',
          '손가락 테스트를 활용하세요',
        ],
      ),
      FermentationWarning(
        title: '건조 방지',
        description: '반죽 표면이 마르면 딱딱한 껍질이 생겨 발효를 방해합니다.',
        severity: 'medium',
        preventionTips: [
          '젖은 수건으로 덮으세요',
          '밀폐 용기를 사용하세요',
          '올리브오일을 살짝 발라주세요',
        ],
      ),
    ];

    final specificWarnings = <FermentationWarning>[];

    switch (fermentationType) {
      case 'room_temperature':
        specificWarnings.add(
          FermentationWarning(
            title: '온도 변화 주의',
            description: '실온 발효는 환경 온도 변화에 민감합니다.',
            severity: 'medium',
            preventionTips: [
              '온도가 일정한 곳에 두세요',
              '에어컨이나 히터 바람을 피하세요',
              '계절에 따라 시간을 조정하세요',
            ],
          ),
        );
        break;
      case 'cold':
        specificWarnings.add(
          FermentationWarning(
            title: '냉장고 냄새 주의',
            description: '냉장고의 다른 음식 냄새가 반죽에 배을 수 있습니다.',
            severity: 'low',
            preventionTips: [
              '밀폐 용기를 사용하세요',
              '냉장고를 깨끗하게 유지하세요',
              '강한 냄새 나는 음식과 분리하세요',
            ],
          ),
        );
        break;
      case 'warm':
        specificWarnings.add(
          FermentationWarning(
            title: '고온 주의',
            description: '온도가 너무 높으면 이스트가 죽어 발효가 중단됩니다.',
            severity: 'critical',
            preventionTips: [
              '40°C를 절대 넘지 마세요',
              '온도계로 정확히 측정하세요',
              '발효기 온도를 자주 확인하세요',
            ],
          ),
        );
        break;
    }

    return [...commonWarnings, ...specificWarnings];
  }

  /// 빠른 시작 가이드 생성
  QuickStartGuide _generateQuickStartGuide(String fermentationType) {
    switch (fermentationType) {
      case 'room_temperature':
        return QuickStartGuide(
          title: '실온 발효 빠른 시작',
          steps: [
            '반죽을 기름칠한 볼에 넣기',
            '젖은 수건으로 덮기',
            '실온(20-25°C)에서 2시간 대기',
            '손가락 테스트로 발효 확인',
            '가스 빼고 2차 발효 45분',
          ],
          estimatedTimeMinutes: 180,
          difficulty: 'beginner',
          requiredTools: ['큰 볼', '젖은 수건', '타이머'],
          keyTips: [
            '온도가 일정한 곳에 두세요',
            '직사광선을 피하세요',
            '과발효 주의하세요',
          ],
        );
      case 'cold':
        return QuickStartGuide(
          title: '냉장 발효 빠른 시작',
          steps: [
            '반죽을 밀폐 용기에 넣기',
            '냉장고(4°C)에 보관',
            '12-24시간 발효',
            '사용 30분 전 실온에 꺼내기',
            '발효 상태 확인 후 사용',
          ],
          estimatedTimeMinutes: 1440,
          difficulty: 'intermediate',
          requiredTools: ['밀폐 용기', '냉장고', '타이머'],
          keyTips: [
            '팽창 공간을 충분히 남기세요',
            '최대 72시간까지 보관 가능',
            '사용 전 실온 적응 필수',
          ],
        );
      case 'warm':
        return QuickStartGuide(
          title: '온발효 빠른 시작',
          steps: [
            '발효기를 35°C로 설정',
            '물그릇과 함께 반죽 넣기',
            '1시간 1차 발효',
            '가스 빼고 성형',
            '30분 2차 발효',
          ],
          estimatedTimeMinutes: 120,
          difficulty: 'intermediate',
          requiredTools: ['발효기', '온도계', '물그릇', '타이머'],
          keyTips: [
            '40°C를 넘지 마세요',
            '15-30분마다 확인하세요',
            '과발효 위험이 높습니다',
          ],
        );
      default:
        return QuickStartGuide(
          title: '맞춤 발효 가이드',
          steps: ['사용자 설정에 따라 진행'],
          estimatedTimeMinutes: 240,
          difficulty: 'advanced',
          requiredTools: [],
          keyTips: [],
        );
    }
  }

  /// 헬퍼 메서드들
  double _extractYeastAmount(Map<String, dynamic> recipeData) {
    // 다양한 키에서 이스트 양 추출 시도
    final possibleKeys = ['yeast', 'yeastAmount', 'dry_yeast', 'active_yeast'];
    for (final key in possibleKeys) {
      if (recipeData.containsKey(key)) {
        return (recipeData[key] as num?)?.toDouble() ?? 0.0;
      }
    }
    return 0.0;
  }

  double _extractSugarAmount(Map<String, dynamic> recipeData) {
    final possibleKeys = ['sugar', 'sugarAmount', 'sweetener'];
    for (final key in possibleKeys) {
      if (recipeData.containsKey(key)) {
        return (recipeData[key] as num?)?.toDouble() ?? 0.0;
      }
    }
    return 0.0;
  }

  String _extractYeastType(Map<String, dynamic> recipeData) {
    return recipeData['yeastType'] as String? ?? 'dry_yeast';
  }

  double _extractFlourAmount(Map<String, dynamic> recipeData) {
    final possibleKeys = ['flour', 'flourAmount', 'bread_flour', 'all_purpose_flour'];
    for (final key in possibleKeys) {
      if (recipeData.containsKey(key)) {
        return (recipeData[key] as num?)?.toDouble() ?? 500.0;
      }
    }
    return 500.0; // 기본값
  }

  double _calculateOptimalYeastRatio(String fermentationType, double flourAmount) {
    switch (fermentationType) {
      case 'room_temperature':
        return flourAmount * 0.01; // 1%
      case 'cold':
        return flourAmount * 0.005; // 0.5%
      case 'warm':
        return flourAmount * 0.015; // 1.5%
      default:
        return flourAmount * 0.01;
    }
  }

  double _calculateOptimalSugarRatio(String fermentationType, double flourAmount) {
    return flourAmount * 0.02; // 2% (일반적인 비율)
  }

  String _analyzeYeastStatus(double actual, double optimal) {
    final ratio = actual / optimal;
    if (ratio < 0.7) return 'insufficient';
    if (ratio > 1.3) return 'excessive';
    return 'optimal';
  }

  String _analyzeSugarStatus(double actual, double optimal) {
    final ratio = actual / optimal;
    if (ratio < 0.5) return 'insufficient';
    if (ratio > 2.0) return 'excessive';
    return 'optimal';
  }

  List<String> _generateOptimizationTips({
    required String yeastStatus,
    required String sugarStatus,
    required double yeastAmount,
    required double sugarAmount,
    required double optimalYeastRatio,
    required double optimalSugarRatio,
  }) {
    final tips = <String>[];

    if (yeastStatus == 'insufficient') {
      tips.add('이스트를 ${(optimalYeastRatio - yeastAmount).toStringAsFixed(1)}g 더 추가하세요.');
    } else if (yeastStatus == 'excessive') {
      tips.add('이스트가 ${(yeastAmount - optimalYeastRatio).toStringAsFixed(1)}g 과다합니다. 다음에는 줄여보세요.');
    }

    if (sugarStatus == 'insufficient') {
      tips.add('설탕을 ${(optimalSugarRatio - sugarAmount).toStringAsFixed(1)}g 더 추가하면 발효가 더 활발해집니다.');
    } else if (sugarStatus == 'excessive') {
      tips.add('설탕이 과다하면 발효가 너무 빨라질 수 있습니다.');
    }

    return tips;
  }

  Duration _estimateFermentationTime({
    required String fermentationType,
    required double yeastAmount,
    required double sugarAmount,
    required double temperature,
  }) {
    // 기본 시간
    Duration baseTime;
    switch (fermentationType) {
      case 'room_temperature':
        baseTime = Duration(hours: 8);
        break;
      case 'cold':
        baseTime = Duration(hours: 24);
        break;
      case 'warm':
        baseTime = Duration(hours: 4);
        break;
      default:
        baseTime = Duration(hours: 6);
    }

    // 이스트 양에 따른 조정 (더 많으면 빨라짐)
    double yeastFactor = 1.0;
    if (yeastAmount > 10) yeastFactor = 0.8;
    else if (yeastAmount < 5) yeastFactor = 1.2;

    // 온도에 따른 조정
    double tempFactor = 1.0;
    if (temperature > 30) tempFactor = 0.7;
    else if (temperature < 20) tempFactor = 1.3;

    final adjustedMinutes = (baseTime.inMinutes * yeastFactor * tempFactor).round();
    return Duration(minutes: adjustedMinutes);
  }

  String _generateOverallAssessment(String yeastStatus, String sugarStatus) {
    if (yeastStatus == 'optimal' && sugarStatus == 'optimal') {
      return '레시피가 잘 균형잡혀 있습니다. 좋은 발효 결과를 기대할 수 있습니다.';
    } else if (yeastStatus != 'optimal' || sugarStatus != 'optimal') {
      return '레시피 조정이 필요합니다. 위의 제안사항을 참고하세요.';
    } else {
      return '레시피에 문제가 있습니다. 전면적인 재검토가 필요합니다.';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}시간 ${duration.inMinutes % 60}분';
    } else {
      return '${duration.inMinutes}분';
    }
  }

  /// 레거시 호환성을 위한 메서드
  /// 기존 UI가 기대하는 Map 형태의 데이터를 반환
  Future<Map<String, dynamic>> getCustomGuideForLegacyUI({
    required String fermentationType,
    required Map<String, dynamic> recipeData,
    required Map<String, dynamic> environmentalData,
  }) async {
    final guide = await generateGuide(
      fermentationType: fermentationType,
      recipeData: recipeData,
      environmentalData: environmentalData,
    );
    
    return guide.toLegacyMap();
  }
}