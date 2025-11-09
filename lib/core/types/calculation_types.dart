// 계산 타입들 import
import 'package:flutter/foundation.dart';
import '../types/environment_types.dart';
import '../../features/chef/screen/widgets/fermentation_analysis_types.dart'
    as art;

/// 발효 상태 관리
class FermentationState {
  final double yeastActivity; // 이스트 활성도 (0.0-1.0)
  final double fermentationProgress; // 발효 진행율 (0.0-1.0)
  final double acidity; // 산도 (pH 단위)
  final double volumeIncrease; // 부피 증가율 (%)
  final String fermentationMethod; // 발효 방법
  final int currentStep; // 현재 발효 단계
  final double temperature; // 발효 온도
  final double humidity; // 발효 습도
  final double cumulativeCO2; // 누적 CO₂ 생산량 (다음 단계 초기값으로 사용)

  const FermentationState({
    required this.yeastActivity,
    required this.fermentationProgress,
    required this.acidity,
    required this.volumeIncrease,
    required this.fermentationMethod,
    required this.currentStep,
    required this.temperature,
    required this.humidity,
    required this.cumulativeCO2,
  });

  Map<String, dynamic> toJson() {
    return {
      'yeastActivity': yeastActivity,
      'fermentationProgress': fermentationProgress,
      'acidity': acidity,
      'volumeIncrease': volumeIncrease,
      'fermentationMethod': fermentationMethod,
      'currentStep': currentStep,
      'temperature': temperature,
      'humidity': humidity,
    };
  }

  /// 초기 상태 생성자 (빅데이터 준수: 재료 기반 동적 초기화)
  /// 실제 계산에 필요한 동적 초기화 값들을 환경과 믹싱 상태, 레시피 데이터 기반으로 설정
  factory FermentationState.initial({
    required BakingState mixingState,
    required UserEnvironment environment,
    Map<String, dynamic>? recipeData, // 빅데이터 준수: 레시피 데이터 옵셔널 (하위 호환성)
    List<Map<String, dynamic>>? ingredients, // 재료량 기반 산도 계산을 위한 재료 정보
    String? recipeTitle, // 레시피 제목 전달
  }) {
    // 🎯 빅데이터 준수: 실제 데이터 기반 동적 초기화
    final initialYeastActivity = mixingState.glutenFormation; // 믹싱 글루텐 형성도 기반

    // 빅데이터 준수 우선: 레시피 데이터가 있으면 재료 기반 산도 계산 (온도 독립성)
    final initialAcidity = recipeData != null
        ? _calculateInitialAcidity(environment.temperature ?? 25.0,
            recipeData) // 빅데이터 준수: 재료 기반 산도 계산 우선
        : (environment.temperature != null
            ? _calculateInitialAcidity(environment.temperature!, null)
            : 5.0); // 기존 하위 호환성 유지

    final initialTemperature = environment.temperature ?? 25.0; // 실제 환경 우선
    final initialHumidity =
        environment.humidity?.toDouble() ?? 70.0; // 실제 환경 우선

    return FermentationState(
      yeastActivity: initialYeastActivity,
      fermentationProgress: 0.0, // 진행율은 항상 0으로 시작
      acidity: initialAcidity,
      volumeIncrease: 0.0, // 부피 증가율은 항상 0으로 시작
      fermentationMethod: 'roomTemperature',
      currentStep: 0, // 단계는 항상 0으로 시작
      temperature: initialTemperature,
      humidity: initialHumidity,
      cumulativeCO2: 0.0, // 초기 누적 CO₂는 0
    );
  }

  /// 초기 산도 계산 (빅데이터 준수: 재료 기반 동적 계산)
  static double _calculateInitialAcidity(
      double temperature, Map<String, dynamic>? recipeData) {
    // 빅데이터 준수: 레시피 데이터가 없으면 기존 하드코딩 값 사용
    if (recipeData == null) {
      debugPrint('🧪 [초기 산도 계산] 레시피 데이터 없음 - 기존 하드코딩 값 사용');
      return 5.0 + (temperature - 25.0) * 0.02; // 기존 로직 유지
    }

    // 🎯 빅데이터 준수: 재료 기반 초기 산도 계산
    // 밀가루 종류 감지하여 기본 산도 설정
    final baseFlourPh = _detectFlourTypeAcidity(recipeData);
    debugPrint('🧪 [초기 산도 계산] 밀가루 기준 산도: ${baseFlourPh}pH');

    // 산성 재료 영향 계산
    final acidIngredientsEffect = _calculateAcidIngredientsEffect(recipeData);
    debugPrint(
        '🧪 [초기 산도 계산] 산성 재료 영향: ${acidIngredientsEffect.toStringAsFixed(3)}pH');

    // 빵 타입별 패턴 적용
    final breadTypePattern = _getBreadTypeAcidityPattern(recipeData);
    debugPrint(
        '🧪 [초기 산도 계산] 빵 타입 패턴: ${breadTypePattern.toStringAsFixed(3)}pH');

    // 온도 보정 (빵 과학적 영향)
    final temperatureAdjustment =
        (temperature - 25.0) * 0.02; // 1°C당 +0.02 pH 증가
    debugPrint(
        '🧪 [초기 산도 계산] 온도 보정: ${temperatureAdjustment.toStringAsFixed(3)}pH (${temperature}°C)');

    // 최종 계산 (빅데이터 준수: 계산 결과 그대로 사용)
    final finalAcidity = baseFlourPh +
        acidIngredientsEffect +
        breadTypePattern +
        temperatureAdjustment;
    debugPrint(
        '🧪 [초기 산도 계산] 최종 산도: ${finalAcidity.toStringAsFixed(2)}pH (빅데이터 준수 적용)');

    return finalAcidity;
  }

  /// 밀가루 종류 감지하여 기본 산도 설정 (빅데이터 준수)
  static double _detectFlourTypeAcidity(Map<String, dynamic> recipeData) {
    final ingredients = recipeData['ingredients'];
    if (ingredients is! List) return 5.8; // 기본값: 산업 표준 밀가루 산도

    // 밀가루 재료 감지
    for (final ingredient in ingredients) {
      final name = (ingredient['name'] as String?)?.toLowerCase() ?? '';

      // 빵 과학적 밀가루 산도 기준
      if (name.contains('통밀') || name.contains('whole wheat')) {
        return 5.2; // 통밀가루: 더 산성
      }
      if (name.contains('호밀') || name.contains('rye')) {
        return 4.8; // 호밀가루: 매우 산성
      }
      if (name.contains('호밀빵') || name.contains('sourdough rye')) {
        return 4.5; // 호밀빵: 강산성
      }
      if (name.contains('백밀') ||
          name.contains('white flour') ||
          name.contains('밀가루')) {
        return 5.8; // 백밀가루: 산업 표준
      }
    }

    return 5.8; // 미감지 시 산업 표준 값
  }

  /// 산성 재료 영향 계산 (빅데이터 준수)
  static double _calculateAcidIngredientsEffect(
      Map<String, dynamic> recipeData) {
    final ingredients = recipeData['ingredients'];
    if (ingredients is! List) return 0.0;

    double totalAcidityEffect = 0.0;

    // 빵 과학적 산성 계수 (ml 또는 g 기준)
    final acidityCoefficients = {
      '식초': -0.012, // ml당 pH 영향
      'vinegar': -0.012,
      '레몬': -0.052, // ml당 pH 영향
      'lemon': -0.052,
      '요구르트': -0.008, // g당 pH 영향
      'yogurt': -0.008,
      '사워크림': -0.009, // g당 pH 영향
      'sour cream': -0.009,
      '숙성종': -0.015, // g당 pH 영향
      'sourdough': -0.015,
      'starter': -0.015,
    };

    for (final ingredient in ingredients) {
      final name = (ingredient['name'] as String?)?.toLowerCase() ?? '';
      final amount = (ingredient['amount'] as num?)?.toDouble() ?? 0.0;

      final coefficient = acidityCoefficients.entries
          .firstWhere(
            (entry) => name.contains(entry.key),
            orElse: () => MapEntry('', 0.0),
          )
          .value;

      if (coefficient != 0.0) {
        final effect = amount * coefficient;
        totalAcidityEffect += effect;
        debugPrint(
            '     - $name: ${amount} × ${coefficient} = ${effect.toStringAsFixed(3)}');
      }
    }

    return totalAcidityEffect;
  }

  /// 빵 타입별 산도 패턴 적용 (빅데이터 준수)
  static double _getBreadTypeAcidityPattern(Map<String, dynamic> recipeData) {
    final title = (recipeData['title'] as String?)?.toLowerCase() ?? '';
    final description =
        (recipeData['instructions'] as String?)?.toLowerCase() ?? '';

    // 빵 타입별 산업 경험치 기반 산도 패턴
    if (title.contains('산종') ||
        title.contains('sourdough') ||
        title.contains('sour') ||
        description.contains('산균')) {
      return -0.8; // 산종빵: 기존에 어느 정도 산성화됨
    } else if (title.contains('유산균') ||
        title.contains('lactobacillus') ||
        title.contains('프로바이오틱') ||
        description.contains('유산균')) {
      return -0.5; // 유산균빵: 어느 정도 산성
    } else if (title.contains('식빵') ||
        title.contains('white') ||
        title.contains('식빵') ||
        description.contains('white bread')) {
      return 0.2; // 일반 식빵: 약간 알칼리성
    }

    // 기본 빵에서는 밀가루 자연 산도로 유지
    return 0.0;
  }
}

/// 발효 단계 데이터
class FermentationStep {
  final int stepNumber; // 차수
  final int durationMinutes; // 시간 (분단위)
  final double targetHumidity; // 목표 습도 (%)
  final double targetTemperature; // 목표 온도 (°C)
  final String description; // 단계 설명

  const FermentationStep({
    required this.stepNumber,
    required this.durationMinutes,
    required this.targetHumidity,
    required this.targetTemperature,
    this.description = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'stepNumber': stepNumber,
      'durationMinutes': durationMinutes,
      'targetHumidity': targetHumidity,
      'targetTemperature': targetTemperature,
      'description': description,
    };
  }
}

/// 발효 단계별 결과
class FermentationStepResult {
  final FermentationState state;
  final Map<String, dynamic> metadata;
  final bool success;
  final DateTime calculatedAt;

  // 단계별 CO2 생성량 추가 (중앙화 용)
  final double co2Generation;

  const FermentationStepResult({
    required this.state,
    required this.metadata,
    required this.success,
    required this.calculatedAt,
    this.co2Generation = 0.0,
  });
}

/// 발효 방법 열거형
enum FermentationMethodType {
  roomTemperature, // 실온 발효
  proofer, // 발효기 사용
}

/// 발효 계산 입력 확장
class FermentationCalculationInput {
  final BakingState mixingState; // 믹싱 최종 상태 입력
  final List<FermentationStep> fermentationSteps; // 발효 단계들 (타입 충돌 해결)
  final FermentationMethodType fermentationMethod; // 발효 방법
  final UserEnvironment environment; // 환경 정보
  final List<Map<String, dynamic>> ingredients; // 재료 목록 추가 - 오직 사용자가 입력한 재료만 사용
  final Map<String, dynamic>? recipeData; // 빅데이터 준수: 레시피 데이터 옵셔널 (하위 호환성)

  const FermentationCalculationInput({
    required this.mixingState,
    required this.fermentationSteps,
    required this.fermentationMethod,
    required this.environment,
    required this.ingredients, // 필수 파라미터로 추가
    this.recipeData, // 빅데이터 준수: 옵셔널로 변경 (하위 호환성)
  });

  /// 편의를 위한 getter
  FermentationMethodType get method => fermentationMethod;
}

/// 빵 제조 공통 상태 타입
class BakingState {
  final double temperature; // 온도 (°C)
  final double glutenFormation; // 글루텐 형성도 (0.0-1.0)
  final double viscosity; // 점도
  final double moistureAbsorption; // 수분 흡수율 (%)
  final String developmentStage; // 개발 단계
  final int currentStep; // 현재 단계

  const BakingState({
    required this.temperature,
    required this.glutenFormation,
    required this.viscosity,
    required this.moistureAbsorption,
    required this.developmentStage,
    required this.currentStep,
  });

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'glutenFormation': glutenFormation,
      'viscosity': viscosity,
      'moistureAbsorption': moistureAbsorption,
      'developmentStage': developmentStage,
      'currentStep': currentStep,
    };
  }

  /// 불변 객체 업데이트를 위한 copyWith 메소드
  BakingState copyWith({
    double? temperature,
    double? glutenFormation,
    double? viscosity,
    double? moistureAbsorption,
    String? developmentStage,
    int? currentStep,
  }) {
    return BakingState(
      temperature: temperature ?? this.temperature,
      glutenFormation: glutenFormation ?? this.glutenFormation,
      viscosity: viscosity ?? this.viscosity,
      moistureAbsorption: moistureAbsorption ?? this.moistureAbsorption,
      developmentStage: developmentStage ?? this.developmentStage,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}

/// 빵 제조 계산 엔진 인터페이스 (중앙관리식 계산 패턴)
abstract class BakingCalculator {
  /// 표준화된 계산 인터페이스
  CalculationResult calculate(CalculationInput input);
}

/// 믹싱 단계 정보
class MixingStep {
  final int stepNumber; // 단계 번호
  final String speed; // 속도 (저속/중속/고속)
  final double durationMinutes; // 시간 (분)
  final double temperatureCelsius; // 목표 온도
  final bool isPreFerment; // 프리퍼먼테이션 여부

  const MixingStep({
    required this.stepNumber,
    required this.speed,
    required this.durationMinutes,
    required this.temperatureCelsius,
    this.isPreFerment = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'stepNumber': stepNumber,
      'speed': speed,
      'durationMinutes': durationMinutes,
      'temperatureCelsius': temperatureCelsius,
      'isPreFerment': isPreFerment,
    };
  }
}

/// 계산 입력 인터페이스
class CalculationInput {
  final BakingState currentState; // 현재 빵 제조 상태
  final MixingStep mixingStep; // 믹싱 단계 정보
  final UserEnvironment environment; // 환경 조건
  final List<Map<String, dynamic>> ingredients; // 재료 목록
  final String? recipeTitle; // 레시피 제목
  final int stepIndex; // 단계 인덱스

  const CalculationInput({
    required this.currentState,
    required this.mixingStep,
    required this.environment,
    required this.ingredients,
    this.recipeTitle,
    required this.stepIndex,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentState': currentState.toJson(),
      'mixingStep': mixingStep.toJson(),
      'environment': {
        'temperature': environment.temperature,
        'humidity': environment.humidity,
        'pressure': environment.pressure,
        'altitude': environment.altitude,
        'season': environment.season?.name,
        'ovenType': environment.ovenType?.name,
        'fermentationMethod': environment.fermentationMethod?.name,
        'mixerType': environment.mixerType?.name,
        'lastUpdated': environment.lastUpdated.toIso8601String(),
      },
      'ingredients': ingredients,
      'recipeTitle': recipeTitle,
      'stepIndex': stepIndex,
    };
  }
}

/// 계산 결과 타입
class CalculationResult {
  final Map<String, dynamic> data; // 계산 결과 데이터
  final bool success; // 성공 여부
  final String? error; // 오류 메시지
  final DateTime calculatedAt; // 계산 시간

  const CalculationResult({
    required this.data,
    required this.success,
    this.error,
    required this.calculatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'success': success,
      'error': error,
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }
}
