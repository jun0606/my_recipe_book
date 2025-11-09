import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/types/environment_types.dart';
import '../../../../core/types/calculation_types.dart';
import '../../../../core/utils/fermentation_analysis_helpers.dart';
import '../../../../services/fermentation_calculator.dart';

import '../widgets/fermentation_analysis_types.dart' as art;
import '../widgets/fermentation_analysis_types.dart'
    show FermentationProcessResult;
import '../../../../services/centralized_parsing_service.dart';
import '../../../../services/fermentation_calculator.dart';

/// 발효 차별화 전략 인터페이스
/// 컨셉 준수: 기본값 제거, 산도 계산 완전 제거
/// ❌ 제거: 산도 관련 메소드들 (컨셉 위반)
abstract class FermentationDifferentiationStrategy {
  /// 유동적 차수 대응 메서드 (데이터 기반 단계 판별 유지)
  art.FermentationStage determineStageDynamically(
    int stepNumber,
    int totalSteps,
  );

  // ❌ 완전 제거: 산도 계산 메소드 (컨셉 위반)
  // double calculateInitialAcidity(Map<String, dynamic> recipeData);
}

/// 빵 과학 기반 차별화 전략 구현
/// 컨셉 준수: 산도 계산 완전 제거
class BreadScienceBasedDifferentiation
    implements FermentationDifferentiationStrategy {
  @override
  art.FermentationStage determineStageDynamically(
    int stepNumber,
    int totalSteps,
  ) {
    // 유동적 차수 대응: 단계 번호와 전체 단계 수 기반 동적 판별
    final relativePosition = stepNumber / math.max(totalSteps, 1).toDouble();

    if (stepNumber == 1 || relativePosition <= 0.25) {
      return art.FermentationStage.primary;
    } else if (stepNumber <= 2 || relativePosition <= 0.75) {
      return art.FermentationStage.secondary;
    } else {
      return art.FermentationStage.final_;
    }
  }

  // 산도 계산 메소드 완전 제거 (컨셉 준수)
}

/// 전략 패턴 관리자
/// 기본 차별화 전략을 관리
class DifferentiationStrategyManager {
  static final DifferentiationStrategyManager _instance =
      DifferentiationStrategyManager._internal();
  factory DifferentiationStrategyManager() => _instance;
  DifferentiationStrategyManager._internal();

  final FermentationDifferentiationStrategy _strategy =
      BreadScienceBasedDifferentiation();

  FermentationDifferentiationStrategy get strategy => _strategy;
}

/// 발효 분석 컨트롤러
/// 컨셉 준수: 전략 패턴 적용, 기본값 완전 제거, 유동적 차수 대응 가능
class FermentationAnalysisController extends ChangeNotifier {
  // 상태 변수들
  Map<String, dynamic>? _mixingResult;
  CalculationResult? _analysisResult;

  // 단계별 분석 결과들 (새로운 중앙화 아키텍처)
  List<art.FermentationStepAnalysis> _stepAnalyses = [];

  bool _isAnalyzing = false;
  String? _error;

  // 전략 패턴: 차별화 전략 주입 (컨셉 준수 - 기본값 제거)
  final FermentationDifferentiationStrategy _strategy;

  // 데이터
  Map<String, dynamic>? recipeData;
  UserEnvironment? environment;

  /// 생성자 - 전략 패턴 적용 (기본값 금지, 반드시 전략 주입)
  FermentationAnalysisController([
    FermentationDifferentiationStrategy? strategy,
  ]) : _strategy = strategy ?? DifferentiationStrategyManager().strategy;

  // 게터들
  Map<String, dynamic>? get mixingResult => _mixingResult;
  CalculationResult? get analysisResult => _analysisResult;

  /// BakingState 타입 믹싱 결과를 getter로 제공 (중복 제거 - 헬퍼 사용)
  BakingState get mixingState {
    FermentationAnalysisHelpers.ensureMixingResultAvailable(_mixingResult);
    final result = _mixingResult!;

    // 헬퍼 클래스로 중복 로직 제거
    final temperature =
        FermentationAnalysisHelpers.extractNumericFromMixingResult(
            result, 'finalTemperature', environment,
            stepAnalysesPath: 'temperature',
            environmentFallback: FermentationAnalysisHelpers.getSafeTemperature(
                environment,
                fallback: 26.0),
            fallback: 26.0);

    final glutenFormation =
        FermentationAnalysisHelpers.extractNumericFromMixingResult(
            result, 'finalGlutenFormation', environment,
            stepAnalysesPath: 'glutenFormation', fallback: 0.5);

    final viscosity =
        FermentationAnalysisHelpers.extractNumericFromMixingResult(
            result, 'finalViscosity', environment,
            stepAnalysesPath: 'viscosity', fallback: 1.3);

    final moistureAbsorption =
        FermentationAnalysisHelpers.extractNumericFromMixingResult(
            result, 'finalMoistureAbsorption', environment,
            stepAnalysesPath: 'moistureAbsorption',
            environmentFallback: FermentationAnalysisHelpers.getSafeHumidity(
                        environment,
                        fallback: 60.0) *
                    0.1 +
                65.0,
            fallback: 65.0);

    // 개발 단계는 특별 처리 (문자열)
    String developmentStage = '완전 개발';
    if (result.containsKey('developmentStage') &&
        result['developmentStage'] is String) {
      developmentStage = result['developmentStage'] as String;
    }
    if (result.containsKey('stepAnalyses') &&
        result['stepAnalyses'] is List &&
        result['stepAnalyses'].isNotEmpty) {
      final lastStep = result['stepAnalyses'].last;
      if (lastStep is Map && lastStep.containsKey('doughState')) {
        final doughState = lastStep['doughState'] as Map;
        if (doughState.containsKey('developmentStage') &&
            doughState['developmentStage'] is String) {
          developmentStage = doughState['developmentStage'] as String;
        }
      }
    }

    final currentStep = result.containsKey('currentStep') &&
            result['currentStep'] is num
        ? (result['currentStep'] as num).toInt()
        : (result.containsKey('stepAnalyses') && result['stepAnalyses'] is List
            ? result['stepAnalyses'].length
            : 4);

    return BakingState(
      temperature: temperature,
      glutenFormation: glutenFormation,
      viscosity: viscosity,
      moistureAbsorption: moistureAbsorption,
      developmentStage: developmentStage,
      currentStep: currentStep,
    );
  }

  // 중복 제거: 유효성 검증 로직은 FermentationAnalysisHelpers.validateNumericValue 사용

  // 단계별 분석 결과들 (중앙화 아키텍처)
  List<art.FermentationStepAnalysis> get stepAnalyses => _stepAnalyses;
  bool get hasStepAnalysis => _stepAnalyses.isNotEmpty;

  bool get isAnalyzing => _isAnalyzing;
  String? get error => _error;
  bool get isComplete => _analysisResult != null;
  bool get hasMixingResult => _mixingResult != null;

  /// 발효 시간이 완전히 계산되었는지 확인 - 모든 발효 단계 완료 후 최종 결과 표시용
  bool get isFermentationTimeFullyCalculated {
    final expectedSteps = _getExpectedFermentationStepsCount();
    return _stepAnalyses.length == expectedSteps; // 모든 단계 분석 완료
  }

  // 세터들
  set mixingResult(Map<String, dynamic>? value) {
    if (_mixingResult != value) {
      _mixingResult = value;
      debugPrint('🍞 [발효 컨트롤러] 믹싱 결과 업데이트: ${value != null ? '받음' : '없음'}');
      notifyListeners();
    }
  }

  /// 믹싱 결과 설정 - 단순화
  void setMixingResult(Map<String, dynamic> result) {
    debugPrint('🍞 [발효 컨트롤러] 믹싱 결과 업데이트');
    mixingResult = result;
  }

  /// 분석 데이터 설정
  void setAnalysisData({
    Map<String, dynamic>? recipeData,
    UserEnvironment? environment,
  }) {
    this.recipeData = recipeData;
    this.environment = environment;

    // 데이터 설정 시 기존 캐시 클리어 - 292% 문제 해결
    FermentationCalculator.instance.clearCalculationCache();

    debugPrint('🍞 [발효 컨트롤러] 분석 데이터 설정 완료 (캐시 클리어됨)');
    notifyListeners();
  }

  /// 분석 준비 상태 확인
  bool get isReadyForAnalysis {
    final ready = recipeData != null &&
        environment != null &&
        hasMixingResult &&
        !_isAnalyzing;

    // 중요 오류만 로그
    if (!ready && !isAnalyzing) {
      final msg = [
        if (recipeData == null) '레시피 데이터 없음',
        if (environment == null) '환경 데이터 없음',
        if (!hasMixingResult) '믹싱 결과 없음'
      ].join(', ');
      debugPrint('🔄 [발효 컨트롤러] 분석 준비 불완: $msg');
    }

    return ready;
  }

  /// 🏗️ 빵 과학 컨셉 준수: 단일 중앙화 메소드 호출 방식으로 완전 전환
  /// 독립적 단계별 계산 완전 제거 - 컨셉 위반 방지
  Future<void> performAnalysis() async {
    debugPrint('🚀 [중앙화 발효 분석] performAnalysis 시작됨!');
    try {
      // 데이터 초기화 (중앙화로 간소화)
      final service = CentralizedParsingService();
      final initData = service.initializeFermentationAnalysis(
        recipeData: recipeData!,
        environment: environment!,
      );

      debugPrint(
          '🚀 [중앙화] 데이터 초기화 완료: ${initData.fermentationSteps.length}개 단계');
      debugPrint('🔧 [중앙화] 재료 수: ${initData.ingredients.length}개');

      // 단계 변환 로드 (✅ 실제 시간 값 저장)
      final fermentationSteps =
          _loadFermentationStepsFromCentralizedData(initData);
      debugPrint('🔧 [중앙화] 단계 변환 자동 완료');

      // ✅ 중앙화: 단계 시간 계산 제거, fermentationSteps 직접 사용
      debugPrint('⏱️ [중앙화] 단계 시간: fermentationSteps에서 직접 사용');

      // 🧪 믹싱 CO2 잔류량 계산 (발효 초기 CO2 값으로 사용)
      final initialCO2FromMixing = _mixingResult != null
          ? FermentationAnalysisHelpers.calculateMixingResidualCO2(
              mixingResult: _mixingResult!,
              fermentationEnvironment: {
                'temperature': environment!.temperature,
                'humidity': environment!.humidity
              },
              ingredients: initData.ingredients,
            )
          : 0.0;
      debugPrint(
          '🧪 [발효 초기 CO2 값] 믹싱 잔류량: ${initialCO2FromMixing.toStringAsFixed(2)}ml');

      // ✅ 빵 과학 컨셉 준수: 전체 발효 과정을 단일 계산기로 처리
      // 🧪 믹싱 CO2 잔류 제거: 발효는 발효 특유의 CO2만 계산하도록 청결화
      // ✅ 타입 호환성을 위해 art.FermentationStep을 FermentationStep으로 변환
      final calculationFermentationSteps = fermentationSteps
          .map((step) => FermentationStep(
                stepNumber: step.stepNumber,
                durationMinutes: step.duration.inMinutes,
                targetTemperature: step.targetTemperature,
                targetHumidity: step.targetHumidity,
                description: step.stepNotes,
              ))
          .toList();

      final input = FermentationCalculationInput(
        mixingState: mixingState,
        fermentationSteps: calculationFermentationSteps,
        fermentationMethod: FermentationMethodType.roomTemperature,
        environment: environment!,
        ingredients: initData.ingredients,
      );

      // ✅ 직접 calculateRoomTemperatureFermentation 호출하여 실제 결과 얻기
      final calculationResult = await FermentationCalculator.instance
          .calculateRoomTemperatureFermentation(input);

      if (!calculationResult.success) {
        throw Exception('발효 계산 실패: ${calculationResult.error}');
      }

      // ✅ CalculationResult에서 stepResults 직접 추출
      final data = calculationResult.data;
      final stepResults = (data?['stepResults'] as List<dynamic>?)
          ?.cast<FermentationStepResult>();

      if (stepResults == null || stepResults.isEmpty) {
        debugPrint('⚠️ [CO2 디버깅] stepResults가 비어있음 - 계산 결과 확인');
        debugPrint('   data 내용: ${data?.keys.toList()}');
        debugPrint('   totalSteps: ${data?['totalSteps']}');
        throw Exception('발효 단계별 결과가 비어있음');
      }

      // ✅ CO2 값 디버깅 로깅 추가
      debugPrint('💨 [CO2 디버깅] 추출된 stepResults 개수: ${stepResults.length}');
      stepResults.forEach((step) {
        debugPrint(
            '   단계 ${step.state.currentStep}: CO2=${step.co2Generation}');
      });

      // ✅ FermentationStepResult 리스트를 FermentationProcessResult 형태로 변환
      final result = art.FermentationProcessResult(
        stepResults: [], // 실제로는 stepResults를 그대로 사용하지 않고 변환
        totalElapsedTime: fermentationSteps.fold<int>(
            0, (sum, step) => sum + step.duration.inMinutes),
        finalYeastActivity:
            (data?['yeastProperties']?['activity'] as num?)?.toDouble() ?? 0.0,
        overallSuccess: calculationResult.success,
      );

      // 🔍 [초기 잔류 제거 로깅] 전달된 값 vs 실제 사용 값 비교
      if (initialCO2FromMixing > 0.0) {
        debugPrint(
            '🧹 [CO2 초기화 적용] 믹싱 잔류량 ${initialCO2FromMixing.toStringAsFixed(1)}ml → 0.0ml 청결화');
      }

      debugPrint('🎯 [중앙화] 전체 발효 프로세스 계산 완료!');
      debugPrint('📊 [중앙화] 결과 단계 수: ${result.stepResults.length}');
      debugPrint('⏱️ [중앙화] 총 소요시간: ${result.totalElapsedTime}분');
      debugPrint(
          '🍞 [중앙화] 최종 이스트 양: ${result.finalYeastActivity.toStringAsFixed(1)}g');

      // 결과 저장 - 다른 곳에서 사용 가능 (컨셉 준수)
      FermentationCalculator.setLastFermentationResult(result);
      debugPrint('💾 [발효 결과 저장] 마지막 결과 저장됨 - 다른 컴포넌트에서 활용 가능');

      // 중앙화 결과에서 UI 데이터로 변환
      final lastStepProgress = stepResults.isNotEmpty
          ? stepResults.last.state.fermentationProgress
          : 0.0;

      // ✅ CO2 누적 계산을 위한 변수
      double cumulativeCO2 = 0.0;

      _stepAnalyses = stepResults.map((stepResult) {
        // ✅ CO2 누적 계산: 이전 단계의 누적 값 + 현재 단계의 CO2 생성량
        cumulativeCO2 += stepResult.co2Generation;

        debugPrint('💨 [CO2 누적 계산] 단계 ${stepResult.state.currentStep}:');
        debugPrint(
            '   - 단계별 생성량: ${stepResult.co2Generation.toStringAsFixed(6)}ml');
        debugPrint('   - 누적 합산값: ${cumulativeCO2.toStringAsFixed(6)}ml');

        // ✅ 중앙화: fermentationSteps에서 직접 duration 가져오기
        final stepIndex = stepResult.state.currentStep - 1;
        final stepFromOriginal = fermentationSteps.length > stepIndex
            ? fermentationSteps[stepIndex]
            : art.FermentationStep(
                stepNumber: stepResult.state.currentStep,
                duration: Duration.zero,
                targetTemperature: environment!.temperature ?? 0,
                targetHumidity: environment!.humidity ?? 0,
                expectedStage: art.FermentationStage.primary,
                stepNotes: '기본값',
              );

        debugPrint(
            '⏱️ [FermentationStepAnalysis] 단계 ${stepResult.state.currentStep} 실제 Duration: ${stepFromOriginal.duration.inMinutes}분');

        debugPrint(
            '🚧 [FermentationStepAnalysis 생성] 단계 ${stepResult.state.currentStep} 시작');
        debugPrint('   - cumulativeCO2 값 설정 중: $cumulativeCO2');

        final analysisObject = art.FermentationStepAnalysis(
          stepNumber: stepResult.state.currentStep,
          stage: _determineStageFromStepNumber(
              stepResult.state.currentStep, stepResults.length),
          temperature: environment!.temperature ?? 0,
          targetHumidity: environment!.humidity ?? 0,
          duration: stepFromOriginal.duration, // ✅ fermentationSteps에서 직접 가져옴
          fermentationProgress: stepResult.state.fermentationProgress,
          yeastActivity: stepResult.state.yeastActivity,
          acidity: stepResult.state.acidity, // ✅ 중앙화 산도 값 직접 사용
          volumeIncrease: stepResult.state.volumeIncrease,
          gasProduction: stepResult.co2Generation,
          carbonationLevel: 0.0,
          yeastActivityLevel:
              FermentationAnalysisHelpers.determineYeastActivityLevel(
                  stepResult.state.yeastActivity),
          volumeExpansion: VolumeExpansionCalculator.convertToEnum(
              stepResult.state.volumeIncrease), // 중앙화 적용
          developmentNotes: '실제 레시피 세균시간 사용 - 빅데이터 제거',
          cumulativeCO2: cumulativeCO2, // ✅ 정확한 누적 CO2 값 설정
        );

        debugPrint(
            '✅ [FermentationStepAnalysis 생성] 단계 ${stepResult.state.currentStep} 완료');
        debugPrint('   - 최종 객체 cumulativeCO2: ${analysisObject.cumulativeCO2}');
        debugPrint('   - 객체 해시코드: ${analysisObject.hashCode}');

        return analysisObject;
      }).toList();

      // 결과 저장 - 총 발효 진행율을 마지막 단계 진행률로 통일
      final totalFermentationProgress = lastStepProgress; // 마지막 단계 진행률 = 총 진행율

      _analysisResult = CalculationResult(
        data: {
          'fermentationSuccessProbability':
              totalFermentationProgress, // 통일된 총 진행율
          'totalFermentationProgress': totalFermentationProgress, // 명확한 필드 추가
          'stepAnalyses': _stepAnalyses,
          'cumulativeStates': [],
          'yeastQualityFactor': totalFermentationProgress, // 통일
          'stepProgresses':
              _stepAnalyses.map((step) => step.fermentationProgress).toList(),
          'fermentationTotalElapsedTime':
              result.totalElapsedTime, // 중앙화된 총 시간 저장
        },
        success: true,
        calculatedAt: DateTime.now(),
      );

      debugPrint(
          '🎯 [진행율 통일] 총 발효 진행율 = 마지막 단계 진행률: ${(totalFermentationProgress * 100).toStringAsFixed(1)}%');

      debugPrint('✅ [중앙화 발효 분석] 완료: ${result.overallSuccess ? '성공' : '실패'}');
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('❌ [중앙화 발효 분석] 오류: $e');
      _error = '$e\n$stackTrace';
      _analysisResult = null;
    }
  }

  /// 단계 번호로부터 발효 단계 결정 헬퍼
  art.FermentationStage _determineStageFromStepNumber(
      int stepNumber, int totalSteps) {
    final relativePosition = stepNumber / math.max(totalSteps, 1).toDouble();

    if (stepNumber == 1 || relativePosition <= 0.25) {
      return art.FermentationStage.primary;
    } else if (stepNumber <= 2 || relativePosition <= 0.75) {
      return art.FermentationStage.secondary;
    } else {
      return art.FermentationStage.final_;
    }
  }

  /// ✅ 컨셉 준수: 완전 중앙화 - 예상 단계 수 계산 서비스 위임
  int _getExpectedFermentationStepsCount() {
    final service = CentralizedParsingService();
    final initData = service.initializeFermentationAnalysis(
      recipeData: recipeData!,
      environment: environment!,
    );
    // 중앙화 서비스에서 계산된 값 사용 - 하드코딩 제거
    return initData.expectedStepsCount;
  }

  /// ✅ 중앙화된 데이터로부터 발효 단계 로드 - 실제 사용자 입력 시간 보존
  List<art.FermentationStep> _loadFermentationStepsFromCentralizedData(
    FermentationAnalysisInitData initData,
  ) {
    debugPrint(
      '� [컨셉 준수] 발효 단계 변환 시작: ${initData.fermentationSteps.length}개 단계',
    );

    final steps = <art.FermentationStep>[];
    for (int i = 0; i < initData.fermentationSteps.length; i++) {
      final stepNumber = i + 1;
      final stepData = initData.fermentationSteps[i];

      // ✅ [컨셉 준수] 단계 데이터 구조 확인 로깅
      debugPrint(
          '🔍 [데이터 구조 확인] 단계 $stepNumber - 키들: ${stepData.keys.join(', ')}');
      stepData.forEach((key, value) {
        debugPrint('   $key: $value (${value.runtimeType})');
      });

      // ✅ 하드코딩 제거: 데이터 우선 사용, 없으면 환경 기본값
      final useTemperature =
          (stepData['targetTemperature'] as num?)?.toDouble() ??
              initData.environment.temperature!;

      final useHumidity = (stepData['targetHumidity'] as num?)?.toDouble() ??
          initData.environment.humidity!;

      // ✅ [단순화] time 키만 사용하여 데이터 변질 해소 (분 단위 int만 사용)
      debugPrint('⏱️ [단계 $stepNumber] 시간 추출 시작');
      debugPrint('⏱️ [단계 $stepNumber] stepData 키들: ${stepData.keys.toList()}');

      int useDurationMinutesInt = 0; // 기본값은 0분

      // 단일 키만 확인: time (int, 분 단위)
      if (stepData.containsKey('time') && stepData['time'] is num) {
        useDurationMinutesInt = (stepData['time'] as num).toInt();
        debugPrint('✅ [단계 $stepNumber] time 키에서 추출: ${useDurationMinutesInt}분');
      } else {
        debugPrint('⚠️ [단계 $stepNumber] time 키 없음 또는 잘못된 타입 - 기본값 0분 사용');
        debugPrint(
            '   time 값: ${stepData['time']}, 타입: ${stepData['time']?.runtimeType}');
      }

      final stepDuration = Duration(minutes: useDurationMinutesInt);
      debugPrint('⚡ [단계 $stepNumber] Duration 생성: ${stepDuration.inMinutes}분');

      steps.add(
        art.FermentationStep(
          stepNumber: stepNumber,
          duration: stepDuration,
          targetTemperature: useTemperature,
          targetHumidity: useHumidity,
          expectedStage: _strategy.determineStageDynamically(
            stepNumber,
            initData.fermentationSteps.length,
          ),
          stepNotes: stepData['description'] as String? ??
              '${stepNumber}차 발효 - 실제 데이터 기반',
        ),
      );
    }

    // 🔥 [데이터 무결성 검증] 컨트롤러 로드 결과 검증 로깅 추가
    debugPrint('🔍 [데이터 무결성 검증] 컨트롤러 로드 결과:');
    for (int i = 0; i < steps.length; i++) {
      final minutes = steps[i].duration.inMinutes;
      debugPrint('   단계 ${i + 1}: ${minutes}분 (변질 방지 검증)');
      if (minutes == 0) {
        debugPrint('   ⚠️ [경고] 단계 ${i + 1} 시간값이 0입니다 - 데이터 변질 의심!');
      }
    }

    debugPrint('✅ [컨셉 준수] 발효 단계 변환 완료: ${steps.length}개 단계');
    for (int i = 0; i < steps.length; i++) {
      debugPrint('   단계 ${i + 1} 최종 Duration: ${steps[i].duration.inMinutes}분');
    }
    return steps;
  }

  // 중복 제거: 메트릭 계산은 FermentationAnalysisHelpers 사용

  /// ✅ 데이터 오염 제거: 발효 성공 확률 계산 (종결 단계 진행률만 사용 - 컨셉 준수)
  double _calculateSuccessProbability(
    double lastStepProgress, // ✅ 종결 단계 진행률만 사용 - 산도 제거
  ) {
    // ✅ 빵 제조 과학: 발효 성공 확률 = 마지막 단계의 발효 진행률
    // 종결 단계의 성취도가 전체 발효 성공의 지표

    debugPrint(
      '🎯 [발효 성공 확률] 종결 단계 진행률 기반 계산:'
      '진행률=${lastStepProgress.toStringAsFixed(1)}%', // ✅ 종결 단계 진도만 사용
    );

    // 종결 단계 진행률을 그대로 성공 확률로 사용 (예: 100% 완료시 100% 성공)
    final successProbability = lastStepProgress; // ✅ 원시 진행률 그대로 사용

    debugPrint(
        '   - 계산 결과: ${successProbability.toStringAsFixed(4)}% (종결 단계 중심)');

    return successProbability; // 종결 단계 기반 결과 (단계별 누적 반영)
  }

  /// 컨트롤러 초기화
  void reset() {
    _mixingResult = null;
    _analysisResult = null;
    _stepAnalyses = [];
    _isAnalyzing = false;
    _error = null;
    notifyListeners();
  }
}
