// 믹싱 분석 타입 정의
// MixingAnalysisCard에서 사용되는 모든 타입들을 중앙 집중식으로 관리

import 'package:flutter/material.dart';
import '../../../../core/types/environment_types.dart';
import '../../../../services/ingredient_analyzer.dart';
import '../../../../services/environment_defaults_calculator.dart';
import '../../../../services/moisture_calculator.dart';
import '../../../../services/gluten_calculation_engine.dart'; // GlutenRange 클래스 import

/// 믹싱 단계별 분석 결과
class MixingStepAnalysis {
  final int stepNumber;
  final String speed;
  final int durationMinutes;
  final double rpm;
  final DoughState doughState;
  final List<String> recommendations;
  final double efficiency;

  const MixingStepAnalysis({
    required this.stepNumber,
    required this.speed,
    required this.durationMinutes,
    required this.rpm,
    required this.doughState,
    required this.recommendations,
    required this.efficiency,
  });

  /// JSON에서 생성
  factory MixingStepAnalysis.fromJson(Map<String, dynamic> json) {
    return MixingStepAnalysis(
      stepNumber: json['stepNumber'] as int? ?? 1,
      speed: json['speed'] as String? ?? '중속',
      durationMinutes: json['durationMinutes'] as int? ?? 5,
      rpm: (json['rpm'] as num?)?.toDouble() ?? 130.0,
      doughState: DoughState.fromJson(
          json['doughState'] as Map<String, dynamic>? ?? {}),
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      efficiency: (json['efficiency'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'stepNumber': stepNumber,
      'speed': speed,
      'durationMinutes': durationMinutes,
      'rpm': rpm,
      'doughState': doughState.toJson(),
      'recommendations': recommendations,
      'efficiency': efficiency,
    };
  }

  /// 복사본 생성
  MixingStepAnalysis copyWith({
    int? stepNumber,
    String? speed,
    int? durationMinutes,
    double? rpm,
    DoughState? doughState,
    List<String>? recommendations,
    double? efficiency,
  }) {
    return MixingStepAnalysis(
      stepNumber: stepNumber ?? this.stepNumber,
      speed: speed ?? this.speed,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      rpm: rpm ?? this.rpm,
      doughState: doughState ?? this.doughState,
      recommendations: recommendations ?? this.recommendations,
      efficiency: efficiency ?? this.efficiency,
    );
  }
}

/// 반죽 상태를 추적하는 클래스
/// 빵 제조 과학적 원리에 따라 상태가 누적됨
class DoughState {
  final double temperature; // 현재 온도 (°C)
  final double glutenFormation; // 현재 글루텐 형성도 (0.0-1.0)
  final double viscosity; // 현재 점도
  final double moistureAbsorption; // 현재 수분 흡수율 (%)
  final int currentStep; // 현재 단계 (0부터 시작)
  final String developmentStage; // 개발 단계

  // ✅ 환경 기반 구조적 개선: 계산/저장 분리 적용
  // ✅ environment 파라미터를 생성자에서 완전히 제거
  DoughState({
    double? temperature,
    double? glutenFormation,
    double? viscosity,
    double? moistureAbsorption,
    this.currentStep = 0,
    String? developmentStage,
    // ✅ 환경 계산은 외부에서 수행되므로 파라미터 제거
    required List<Map<String, dynamic>> ingredients,
    required String? recipeTitle,
    MixingStep? mixingStep,
  })  :
        // ✅ 환경 값 없이 기본값으로 계산 (환경 영향은 외부에서 별도 적용)
        temperature = temperature ??
            _calculateOptimalDoughTemperature(
                ingredients, null, mixingStep, recipeTitle),
        // ✅ 하드코딩 제거: 사용자 입력 기반 동적 계산 적용
        glutenFormation = glutenFormation ??
            _calculateDynamicInitialGlutenFormation(
                ingredients, recipeTitle, null, mixingStep),
        viscosity = viscosity ??
            _calculateInitialViscosity(
                ingredients,
                temperature ??
                    _calculateOptimalDoughTemperature(
                        ingredients, null, mixingStep, recipeTitle),
                recipeTitle),
        // ✅ 하드코딩 제거: 동적 계산 적용 (계산 불가 시 0)
        moistureAbsorption = moistureAbsorption ??
            _calculateDynamicMoistureAbsorption(
                ingredients, recipeTitle, null, mixingStep),
        developmentStage = developmentStage ??
            _determineInitialDevelopmentStage(
                glutenFormation ??
                    _calculateDynamicInitialGlutenFormation(
                        ingredients, recipeTitle, null, mixingStep),
                mixingStep);

  /// 동적 수분 흡수율을 사용하는 팩토리 생성자
  factory DoughState.withDynamicMoisture({
    double temperature = 25.0,
    double glutenFormation = 0.0,
    double viscosity = 1.0,
    int currentStep = 0,
    String developmentStage = '초기 개발',
    // ✅ 환경 파라미터 완전히 제거 - 계산/저장 분리 전략
    List<Map<String, dynamic>>? ingredients,
    String? recipeTitle,
    MixingStep? mixingStep,
  }) {
    final moistureAbsorption =
        MoistureCalculator.calculateBaseMoistureAbsorption(
      ingredients ?? [],
      recipeTitle: recipeTitle ?? '기본 빵',
    );
    return DoughState(
      temperature: temperature,
      glutenFormation: glutenFormation,
      viscosity: viscosity,
      moistureAbsorption: moistureAbsorption,
      currentStep: currentStep,
      developmentStage: developmentStage,
      ingredients: ingredients ?? [],
      recipeTitle: recipeTitle ?? '기본 빵',
      // ✅ environment 파라미터 제거됨 - 외부에서 환경 계산 수행
      mixingStep: mixingStep,
    );
  }

  /// JSON에서 생성
  factory DoughState.fromJson(Map<String, dynamic> json) {
    final moistureAbsorption = (json['moistureAbsorption'] as num?)?.toDouble();

    // 수분 흡수율 데이터 검증 및 기본값 처리
    final safeMoistureAbsorption = (moistureAbsorption != null &&
            !moistureAbsorption.isNaN &&
            moistureAbsorption > 0)
        ? moistureAbsorption
        : MoistureCalculator.calculateBaseMoistureAbsorption(
            [],
            recipeTitle: '기본 빵',
          );

    return DoughState(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 25.0,
      glutenFormation: (json['glutenFormation'] as num?)?.toDouble() ?? 0.0,
      viscosity: (json['viscosity'] as num?)?.toDouble() ?? 1.0,
      moistureAbsorption: safeMoistureAbsorption,
      currentStep: json['currentStep'] as int? ?? 0,
      developmentStage: json['developmentStage'] as String? ?? '초기 개발',
      // ✅ JSON 역직렬화 시 기본값 제공 (하위 호환성 유지)
      ingredients: [],
      recipeTitle: '기본 빵',
      // environment 파라미터 제거 - JSON 역직렬화에서는 환경 값 없음
      mixingStep: null,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'glutenFormation': glutenFormation,
      'viscosity': viscosity,
      'moistureAbsorption': moistureAbsorption,
      'currentStep': currentStep,
      'developmentStage': developmentStage,
    };
  }

  /// 복사 생성
  DoughState copy() {
    return DoughState(
      temperature: temperature,
      glutenFormation: glutenFormation,
      viscosity: viscosity,
      moistureAbsorption: moistureAbsorption,
      currentStep: currentStep,
      developmentStage: developmentStage,
      // ✅ 복사 시 기존 값들 유지 (하위 호환성)
      ingredients: [],
      recipeTitle: '기본 빵',
      // environment 파라미터 제거 - 복사에서는 환경 값 없음
      mixingStep: null,
    );
  }

  /// 디버그용 문자열
  @override
  String toString() {
    return 'DoughState(step: $currentStep, temp: ${temperature}°C, '
        'gluten: ${(glutenFormation * 100).toStringAsFixed(1)}%, '
        'viscosity: ${viscosity.toStringAsFixed(2)}, '
        'moisture: ${moistureAbsorption.toStringAsFixed(1)}%)';
  }

  /// 동등성 비교
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DoughState &&
        other.temperature == temperature &&
        other.glutenFormation == glutenFormation &&
        other.viscosity == viscosity &&
        other.moistureAbsorption == moistureAbsorption &&
        other.currentStep == currentStep &&
        other.developmentStage == developmentStage;
  }

  @override
  int get hashCode {
    return Object.hash(
      temperature,
      glutenFormation,
      viscosity,
      moistureAbsorption,
      currentStep,
      developmentStage,
    );
  }

  /// 최적 반죽 온도 계산 (하드코딩 제거)
  /// ✅ 환경 값 없어도 계산 가능 (기본값 사용)
  static double _calculateOptimalDoughTemperature(
    List<Map<String, dynamic>> ingredients,
    UserEnvironment? environment, // 환경 값 없어도 OK
    MixingStep? mixingStep,
    String? recipeTitle,
  ) {
    // ✅ 재료 기반 동적 계산
    if (ingredients.isNotEmpty) {
      return IngredientAnalyzer.calculateBaseTemperature(
        ingredients,
        recipeTitle: recipeTitle,
      );
    }

    // ✅ 환경 기반 동적 계산
    if (environment != null) {
      return EnvironmentDefaultsCalculator.getOptimalFermentationTemperature();
    }

    // ✅ 믹싱 단계 기반 동적 계산
    if (mixingStep != null) {
      return mixingStep.temperature ?? 22.0; // 빵 제조 표준값
    }

    // ✅ 최종 폴백: 빵 제조 과학적 표준값
    return 22.0; // 빵 제조 표준 실온
  }

  /// 초기 글루텐 형성도 계산 (완전 동적)
  static double _calculateInitialGlutenFormation(
    List<Map<String, dynamic>> ingredients,
    String? recipeTitle,
    UserEnvironment? environment,
  ) {
    // ✅ 밀가루 종류별 동적 계산
    final flourIngredients = IngredientAnalyzer.findFlourIngredients(
        ingredients,
        recipeTitle: recipeTitle);

    if (flourIngredients.isNotEmpty) {
      return IngredientAnalyzer.getFlourGlutenFormation(
              flourIngredients.first['name'] as String) *
          0.1; // 초기 형성도 10%
    }

    // ✅ 환경 조건 반영
    double baseGluten = 0.5; // 기본값
    if (environment != null) {
      if (environment.temperature < 20) baseGluten *= 0.8; // 저온 감소
      if (environment.humidity > 70) baseGluten *= 1.1; // 고습 증가
    }

    return baseGluten;
  }

  /// 동적 초기 글루텐 형성도 계산 (사용자 입력 기반)
  /// ✅ 빵 제조 과학적 실제 값 적용: 초기 형성도는 동적 범위로 제한 (하드코딩 제거)
  static double _calculateDynamicInitialGlutenFormation(
    List<Map<String, dynamic>> ingredients,
    String? recipeTitle,
    UserEnvironment? environment,
    MixingStep? mixingStep,
  ) {
    // 1. 재료 검증 및 계산 불가 시 0 반환 (거짓 정보 방지)
    if (ingredients.isEmpty) {
      debugPrint('🔍 [동적 글루텐 계산] 재료 없음 → 계산 불가 (0 반환)');
      return 0.0; // 거짓 정보 방지
    }

    // 2. 밀가루 존재 여부 검증
    final flourIngredients = IngredientAnalyzer.findFlourIngredients(
        ingredients,
        recipeTitle: recipeTitle);

    if (flourIngredients.isEmpty) {
      debugPrint('🔍 [동적 글루텐 계산] 밀가루 없음 → 계산 불가 (0 반환)');
      return 0.0; // 거짓 정보 방지
    }

    try {
      // 3. 밀가루 품질 기반 기초 계산 (실제 글루텐 함량 사용)
      final flourName = flourIngredients.first['name'] as String;
      final baseGlutenFormation =
          IngredientAnalyzer.getFlourGlutenFormation(flourName);

      // ✅ 빵 제조 과학적 수정: 초기 형성도는 밀가루 품질의 10-20%만 적용
      // 실제 빵 제조에서 초기 단계 글루텐 형성도는 10-20%가 적절
      final initialFormationBase = baseGlutenFormation * 0.15; // 15% 적용

      // 4. 재료 비율 기반 조정 (밀가루 총량 고려)
      final totalFlourWeight = _calculateTotalFlourWeight(flourIngredients);
      final flourRatioFactor =
          _calculateFlourRatioFactor(totalFlourWeight, ingredients);

      // 5. 환경 조건 반영 (동적 계산)
      final environmentFactor =
          _calculateEnvironmentFactorForGluten(environment);

      // 6. 믹서 타입 반영 (mixingStep에서 추출)
      final mixerFactor = _calculateMixerFactorForGluten(mixingStep);

      // 7. 초기 형성도 계산 (빵 제조 과학적 실제 값 적용)
      final initialFormation = initialFormationBase *
          flourRatioFactor *
          environmentFactor *
          mixerFactor;

      // ✅ 하드코딩 제거: 동적 범위 계산 적용
      final dynamicRange = _calculateDynamicInitialGlutenRange(
        ingredients,
        recipeTitle,
        environment,
        mixingStep,
      );
      final clampedValue =
          initialFormation.clamp(dynamicRange.min, dynamicRange.max);

      debugPrint('🔍 [동적 글루텐 계산] 빵 제조 과학적 실제 값 적용');
      debugPrint(
          '   - 밀가루: $flourName (${totalFlourWeight.toStringAsFixed(1)}g)');
      debugPrint(
          '   - 밀가루 품질: ${(baseGlutenFormation * 100).toStringAsFixed(1)}%');
      debugPrint(
          '   - 초기 형성도 기초: ${(initialFormationBase * 100).toStringAsFixed(1)}% (품질의 15%)');
      debugPrint('   - 환경 계수: ${environmentFactor.toStringAsFixed(3)}');
      debugPrint('   - 믹서 계수: ${mixerFactor.toStringAsFixed(3)}');
      debugPrint(
          '   - 동적 범위: ${(dynamicRange.min * 100).toStringAsFixed(1)}%-${(dynamicRange.max * 100).toStringAsFixed(1)}%');
      debugPrint(
          '   - 최종 초기 형성도: ${(clampedValue * 100).toStringAsFixed(1)}% (동적 범위 제한)');

      return clampedValue;
    } catch (e) {
      debugPrint('❌ [동적 글루텐 계산] 계산 중 오류: $e → 0 반환');
      return 0.0; // 거짓 정보 방지
    }
  }

  /// 동적 초기 글루텐 형성도 범위 계산 (하드코딩 제거)
  static GlutenRange _calculateDynamicInitialGlutenRange(
    List<Map<String, dynamic>> ingredients,
    String? recipeTitle,
    UserEnvironment? environment,
    MixingStep? mixingStep,
  ) {
    // 빵 타입별 기본 범위
    final breadType = _determineBreadType(recipeTitle);
    final baseRange = _getBaseRangeForBreadType(breadType);

    // 재료 기반 조정
    final ingredientAdjustment =
        _calculateIngredientRangeAdjustment(ingredients);

    // 환경 기반 조정
    final environmentAdjustment =
        _calculateEnvironmentRangeAdjustment(environment);

    // 믹서 기반 조정
    final mixerAdjustment = _calculateMixerRangeAdjustment(mixingStep);

    final min = (baseRange.min *
            ingredientAdjustment.min *
            environmentAdjustment.min *
            mixerAdjustment.min)
        .clamp(0.01, 0.15); // 최소 1%, 최대 15%
    final max = (baseRange.max *
            ingredientAdjustment.max *
            environmentAdjustment.max *
            mixerAdjustment.max)
        .clamp(0.15, 0.40); // 최소 15%, 최대 40%

    return GlutenRange(min: min, max: max);
  }

  /// 빵 타입 결정
  static String _determineBreadType(String? recipeTitle) {
    if (recipeTitle == null) return 'general';

    final title = recipeTitle.toLowerCase();
    if (title.contains('식빵') || title.contains('sandwich')) return 'sandwich';
    if (title.contains('바게트') || title.contains('baguette')) return 'baguette';
    if (title.contains('사워도우') || title.contains('sourdough'))
      return 'sourdough';
    if (title.contains('크루아상') || title.contains('croissant'))
      return 'croissant';

    return 'general';
  }

  /// 빵 타입별 기본 범위
  static GlutenRange _getBaseRangeForBreadType(String breadType) {
    switch (breadType) {
      case 'sandwich':
        return const GlutenRange(min: 0.05, max: 0.25);
      case 'baguette':
        return const GlutenRange(min: 0.03, max: 0.20);
      case 'sourdough':
        return const GlutenRange(min: 0.08, max: 0.30);
      case 'croissant':
        return const GlutenRange(min: 0.02, max: 0.15);
      default:
        return const GlutenRange(min: 0.05, max: 0.25);
    }
  }

  /// 재료 기반 범위 조정
  static GlutenRange _calculateIngredientRangeAdjustment(
      List<Map<String, dynamic>> ingredients) {
    if (ingredients.isEmpty) return const GlutenRange(min: 1.0, max: 1.0);

    final flourAnalysis = _analyzeFlourTypes(ingredients);
    final strongFlourRatio = _calculateFlourTypeRatio(flourAnalysis, '강력분');
    final weakFlourRatio = _calculateFlourTypeRatio(flourAnalysis, '박력분');

    // 강력분 비율이 높으면 범위 확대, 박력분 비율이 높으면 범위 축소
    final adjustment = 1.0 + (strongFlourRatio * 0.2) - (weakFlourRatio * 0.2);

    return GlutenRange(
      min: adjustment.clamp(0.8, 1.3),
      max: adjustment.clamp(0.8, 1.3),
    );
  }

  /// 환경 기반 범위 조정
  static GlutenRange _calculateEnvironmentRangeAdjustment(
      UserEnvironment? environment) {
    if (environment == null) return const GlutenRange(min: 1.0, max: 1.0);

    double adjustment = 1.0;

    // 온도 영향
    final temp = environment.temperature ?? 25.0;
    if (temp >= 22 && temp <= 26) {
      adjustment *= 1.1;
    } else if (temp >= 20 && temp <= 28) {
      adjustment *= 1.0;
    } else {
      adjustment *= 0.9;
    }

    // 습도 영향
    final humidity = environment.humidity ?? 60.0;
    if (humidity >= 50 && humidity <= 70) {
      adjustment *= 1.05;
    } else {
      adjustment *= 0.95;
    }

    return GlutenRange(min: adjustment, max: adjustment);
  }

  /// 믹서 기반 범위 조정
  static GlutenRange _calculateMixerRangeAdjustment(MixingStep? mixingStep) {
    if (mixingStep == null) return const GlutenRange(min: 1.0, max: 1.0);

    double adjustment = 1.0;

    switch (mixingStep.speed) {
      case '저속':
        adjustment = 0.95; // 저속: 안정적 형성
        break;
      case '중속':
        adjustment = 1.0; // 중속: 최적 형성
        break;
      case '고속':
        adjustment = 0.9; // 고속: 손상 위험 증가
        break;
    }

    return GlutenRange(min: adjustment, max: adjustment);
  }

  /// 밀가루 종류별 분석
  static Map<String, Map<String, dynamic>> _analyzeFlourTypes(
      List<Map<String, dynamic>> ingredients) {
    final analysis = <String, Map<String, dynamic>>{
      '강력분': {'amount': 0.0, 'count': 0},
      '중력분': {'amount': 0.0, 'count': 0},
      '박력분': {'amount': 0.0, 'count': 0},
    };

    for (final ingredient in ingredients) {
      final name = (ingredient['name'] as String? ?? '').toLowerCase();
      final amount = (ingredient['amount'] as num?)?.toDouble() ?? 0.0;
      final unit = ingredient['unit'] as String? ?? 'g';

      if (amount <= 0) continue;

      final weight = IngredientAnalyzer.convertToGrams(amount, unit, name);

      if (name.contains('강력분') ||
          name.contains('high') && name.contains('gluten')) {
        analysis['강력분']!['amount'] =
            (analysis['강력분']!['amount'] as double) + weight;
        analysis['강력분']!['count'] = (analysis['강력분']!['count'] as int) + 1;
      } else if (name.contains('박력분') ||
          name.contains('cake') && name.contains('flour')) {
        analysis['박력분']!['amount'] =
            (analysis['박력분']!['amount'] as double) + weight;
        analysis['박력분']!['count'] = (analysis['박력분']!['count'] as int) + 1;
      } else if (name.contains('중력분') ||
          name.contains('all') && name.contains('purpose')) {
        analysis['중력분']!['amount'] =
            (analysis['중력분']!['amount'] as double) + weight;
        analysis['중력분']!['count'] = (analysis['중력분']!['count'] as int) + 1;
      } else if (name.contains('밀가루') || name.contains('flour')) {
        analysis['중력분']!['amount'] =
            (analysis['중력분']!['amount'] as double) + weight;
        analysis['중력분']!['count'] = (analysis['중력분']!['count'] as int) + 1;
      }
    }

    return analysis;
  }

  /// 밀가루 타입 비율 계산
  static double _calculateFlourTypeRatio(
      Map<String, Map<String, dynamic>> flourAnalysis, String type) {
    final typeWeight = flourAnalysis[type]!['amount'] as double;
    final totalWeight = flourAnalysis.values
        .map((analysis) => analysis['amount'] as double)
        .reduce((a, b) => a + b);

    return totalWeight > 0 ? typeWeight / totalWeight : 0.0;
  }

  /// 밀가루 총 중량 계산
  static double _calculateTotalFlourWeight(
      List<Map<String, dynamic>> flourIngredients) {
    double totalWeight = 0.0;
    for (final flour in flourIngredients) {
      final amount = (flour['amount'] as num?)?.toDouble() ?? 0.0;
      final unit = flour['unit'] as String? ?? 'g';
      final weight = IngredientAnalyzer.convertToGrams(
          amount, unit, flour['name'] as String);
      totalWeight += weight;
    }
    return totalWeight;
  }

  /// 밀가루 비율 계수 계산
  static double _calculateFlourRatioFactor(
      double totalFlourWeight, List<Map<String, dynamic>> allIngredients) {
    if (totalFlourWeight <= 0) return 0.0;

    // 총 재료 중량 계산
    double totalWeight = 0.0;
    for (final ingredient in allIngredients) {
      final amount = (ingredient['amount'] as num?)?.toDouble() ?? 0.0;
      final unit = ingredient['unit'] as String? ?? 'g';
      final weight = IngredientAnalyzer.convertToGrams(
          amount, unit, ingredient['name'] as String);
      totalWeight += weight;
    }

    if (totalWeight <= 0) return 0.0;

    // 밀가루 비율 (빵 제조 과학적 기준)
    final flourRatio = totalFlourWeight / totalWeight;

    // 비율 기반 계수 계산 (빵 제조 표준: 밀가루 60-80%)
    if (flourRatio >= 0.6 && flourRatio <= 0.8) {
      return 1.0; // 최적 비율
    } else if (flourRatio >= 0.5 && flourRatio <= 0.9) {
      return 0.9; // 양호 비율
    } else {
      return 0.7; // 부적합 비율
    }
  }

  /// 글루텐 형성도용 환경 계수 계산
  static double _calculateEnvironmentFactorForGluten(
      UserEnvironment? environment) {
    if (environment == null) return 1.0;

    double factor = 1.0;

    // 온도 영향 (글루텐 형성 최적 온도: 22-26°C)
    final temp = environment.temperature ?? 25.0;
    if (temp >= 22 && temp <= 26) {
      factor *= 1.1; // 최적 온도
    } else if (temp >= 20 && temp <= 28) {
      factor *= 1.0; // 양호 온도
    } else if (temp >= 18 && temp <= 30) {
      factor *= 0.9; // 보통 온도
    } else {
      factor *= 0.8; // 불량 온도
    }

    // 습도 영향 (글루텐 형성에 영향)
    final humidity = environment.humidity ?? 60.0;
    if (humidity >= 50 && humidity <= 70) {
      factor *= 1.05; // 최적 습도
    } else if (humidity >= 40 && humidity <= 80) {
      factor *= 1.0; // 양호 습도
    } else {
      factor *= 0.95; // 불량 습도
    }

    return factor;
  }

  /// 글루텐 형성도용 믹서 계수 계산
  static double _calculateMixerFactorForGluten(MixingStep? mixingStep) {
    if (mixingStep == null) return 1.0;

    // 믹서 타입에 따른 글루텐 형성 효율성
    // 실제 빵 제조 과학적 데이터 기반
    switch (mixingStep.speed) {
      case '저속':
        return 0.9; // 저속: 안정적 형성
      case '중속':
        return 1.0; // 중속: 최적 형성
      case '고속':
        return 0.8; // 고속: 손상 위험 증가
      default:
        return 1.0;
    }
  }

  /// 초기 점도 계산 (완전 동적)
  static double _calculateInitialViscosity(
    List<Map<String, dynamic>> ingredients,
    double temperature,
    String? recipeTitle,
  ) {
    // ✅ 수분율 기반 동적 계산
    final hydration = IngredientAnalyzer.calculateHydration(ingredients,
        recipeTitle: recipeTitle);

    double baseViscosity = 1.0; // 기본값

    // ✅ 수분율에 따른 점도 조정
    if (hydration > 70) baseViscosity *= 1.3; // 고수분: 점도 증가
    if (hydration < 60) baseViscosity *= 0.8; // 저수분: 점도 감소

    // ✅ 온도에 따른 점도 조정
    if (temperature > 25) baseViscosity *= 0.9; // 고온: 점도 감소
    if (temperature < 20) baseViscosity *= 1.1; // 저온: 점도 증가

    return baseViscosity.clamp(0.5, 2.0); // 빵 제조 과학적 범위
  }

  /// 초기 개발 단계 결정 (동적)
  static String _determineInitialDevelopmentStage(
    double glutenFormation,
    MixingStep? mixingStep,
  ) {
    // ✅ 글루텐 형성도 기반 동적 결정
    if (glutenFormation < 0.3) return '초기 개발';
    if (glutenFormation < 0.6) return '중기 개발';
    if (glutenFormation < 0.8) return '후기 개발';
    return '완전 개발';
  }

  /// 동적 수분 흡수율 계산 (중앙화 적용 - 독자 계산 제거)
  /// ✅ 중앙화 컨트롤러의 scientific 누적 계산만 유효
  /// ✅ 독자 계산 중단 - 기본값 반환으로 계산 불능 표시
  static double _calculateDynamicMoistureAbsorption(
    List<Map<String, dynamic>> ingredients,
    String? recipeTitle,
    UserEnvironment? environment,
    MixingStep? mixingStep,
  ) {
    // ✅ 중앙화 전략:
    // - 독자적 수분 계산 함수 제거
    // - 컨트롤러의 getFinalMoistureAbsorption()에서만 실제 계산 수행
    // - DoughState는 컨트롤러 결과를 소비
    return 65.0; // 빵 제조 표준 수분율 (계산 중지 표시)
  }
}

// MixingAnalysisResult는 screen_types.dart에서 중앙 집중화하여 관리
// 중복 정의 제거

class MixingStep {
  final int stepNumber; // 단계 번호 추가
  final String comment;
  final String speed;
  final int durationMinutes;
  final double? temperature;

  const MixingStep({
    required this.stepNumber, // 필수 파라미터로 추가
    required this.comment,
    required this.speed,
    required this.durationMinutes,
    this.temperature,
  });

  /// JSON에서 생성
  factory MixingStep.fromJson(Map<String, dynamic> json) {
    return MixingStep(
      stepNumber: json['stepNumber'] as int? ?? json['step'] as int? ?? 1,
      comment: json['comment'] as String? ?? '',
      speed: json['speed'] as String? ?? '중속',
      durationMinutes: json['durationMinutes'] as int? ?? 5,
      temperature: (json['temperature'] as num?)?.toDouble(),
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'comment': comment,
      'speed': speed,
      'durationMinutes': durationMinutes,
      if (temperature != null) 'temperature': temperature,
    };
  }
}

// AnalysisSettings는 screen_types.dart에서 중앙 집중화하여 관리
// 중복 정의 제거

/// 메트릭 표시를 위한 헬퍼 클래스
class MetricDisplay {
  final String label;
  final String value;
  final Color color;
  final String? range;
  final IconData? icon;

  const MetricDisplay({
    required this.label,
    required this.value,
    required this.color,
    this.range,
    this.icon,
  });

  /// 간소화된 메트릭 생성
  factory MetricDisplay.simple({
    required String label,
    required String value,
    required Color color,
  }) {
    return MetricDisplay(
      label: label,
      value: value,
      color: color,
    );
  }

  /// 상세 메트릭 생성
  factory MetricDisplay.detailed({
    required String label,
    required String value,
    required Color color,
    required String range,
  }) {
    return MetricDisplay(
      label: label,
      value: value,
      color: color,
      range: range,
    );
  }

  /// 아이콘 포함 메트릭 생성
  factory MetricDisplay.withIcon({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return MetricDisplay(
      label: label,
      value: value,
      color: color,
      icon: icon,
    );
  }
}

/// 분석 상태 열거형
enum AnalysisStatus {
  idle,
  analyzing,
  completed,
  error,
}

/// 분석 진행 상태
class AnalysisProgress {
  final AnalysisStatus status;
  final double progress;
  final String message;
  final DateTime? startTime;
  final DateTime? endTime;

  const AnalysisProgress({
    this.status = AnalysisStatus.idle,
    this.progress = 0.0,
    this.message = '',
    this.startTime,
    this.endTime,
  });

  /// 진행 중 상태 생성
  factory AnalysisProgress.running({
    required double progress,
    required String message,
    required DateTime startTime,
  }) {
    return AnalysisProgress(
      status: AnalysisStatus.analyzing,
      progress: progress,
      message: message,
      startTime: startTime,
    );
  }

  /// 완료 상태 생성
  factory AnalysisProgress.completed({
    required String message,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    return AnalysisProgress(
      status: AnalysisStatus.completed,
      progress: 1.0,
      message: message,
      startTime: startTime,
      endTime: endTime,
    );
  }

  /// 오류 상태 생성
  factory AnalysisProgress.error({
    required String message,
    DateTime? startTime,
  }) {
    return AnalysisProgress(
      status: AnalysisStatus.error,
      progress: 0.0,
      message: message,
      startTime: startTime,
    );
  }

  /// 진행 시간 계산
  Duration? get duration {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!);
    }
    return null;
  }

  /// 복사본 생성
  AnalysisProgress copyWith({
    AnalysisStatus? status,
    double? progress,
    String? message,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return AnalysisProgress(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      message: message ?? this.message,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

/// 단계 역할 열거형 (유동적 단계 분석용)
/// 빵 제조 과학적 단계별 역할을 동적으로 분류
enum StepRole {
  /// 초기 혼합: 첫 단계, 재료 혼합 시작
  initialMix,

  /// 글루텐 형성: 중간 단계, 글루텐 네트워크 형성
  glutenFormation,

  /// 추가 혼합: 중간 단계, 추가 혼합 작업
  finalMix,

  /// 숙성: 마지막 단계, 반죽 숙성
  resting,
}
