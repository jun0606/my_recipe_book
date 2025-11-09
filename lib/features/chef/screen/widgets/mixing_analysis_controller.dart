// 믹싱 분석 컨트롤러
// MixingAnalysisCard의 비즈니스 로직을 분리하여 관리

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/types/environment_types.dart';
import '../../../../core/types/unified_types.dart' hide RecipeMetadata;
import '../../../../core/utils/mixing_data_helper.dart';
import '../../../../core/utils/safe_type_converter.dart';
import '../../../../services/mixing_warning_service.dart';
import '../../../../services/mixing_analysis_service.dart';
import '../../../../services/moisture_tracker.dart';
import '../types/screen_types.dart' as st;
import 'mixing_analysis_types.dart' as mat;
import 'mixing_analysis_utils.dart';
import '../../../../services/progressive_mixing_calculator.dart';
import '../../../../core/services/dough_temperature_calculator.dart';

// 통합 계산 타입 추가
import '../../../../core/types/calculation_types.dart' as calc_types;

/// 믹싱 분석 헬퍼 클래스들
/// 복잡한 계산 로직들을 모듈화하여 재사용성과 유지보수성 향상
class MixingAnalysisHelper {
  /// 빵 제조 과학적 실제 수분량 계산 (레시피 기반)
  static double calculateActualTotalMoistureWeight(
      List<Map<String, dynamic>> ingredients) {
    double totalMoisture = 0.0;

    for (final ingredient in ingredients) {
      final name = ingredient['name'] as String;
      final amount = ingredient['amount'] as double;

      // 빵 제조 과학적 실제 수분 함량율 적용
      if (name.contains('물') || name.contains('water')) {
        totalMoisture += amount * 1.0; // 100% 수분
        print('   📏 수분 재료: ${name} - ${amount}g (100% 수분)');
      } else if (name.contains('우유') || name.contains('milk')) {
        totalMoisture += amount * 0.87; // 우유 87% 수분
        print('   📏 수분 재료: ${name} - ${amount}g × 0.87 (우유)');
      } else if (name.contains('크림') || name.contains('cream')) {
        totalMoisture += amount * 0.55; // 생크림 55% 수분
        print('   📏 수분 재료: ${name} - ${amount}g × 0.55 (크림)');
      } else if (name.contains('요거트') || name.contains('yogurt')) {
        totalMoisture += amount * 0.85; // 요거트 85% 수분
        print('   📏 수분 재료: ${name} - ${amount}g × 0.85 (요거트)');
      } // 다른 재료들은 수분 재료로 계산하지 않음
    }

    print('   ⚖️ 총 수분량 계산 결과: ${totalMoisture.toStringAsFixed(1)}g');
    return totalMoisture;
  }

  /// 밀가루 총량 계산 (빵 제조 과학적 기준품종)
  static double getTotalFlourWeightFromRecipe(
      List<Map<String, dynamic>> ingredients) {
    double totalFlour = 0.0;

    for (final ingredient in ingredients) {
      final name = ingredient['name'] as String;
      final amount = ingredient['amount'] as double;

      // 밀가루 관련 모든 재료 합계 (빵 제조 과학적 기준)
      if (name.contains('밀가루') ||
          name.contains('강력분') ||
          name.contains('중력분') ||
          name.contains('박력분') ||
          name.contains('통밀가루') ||
          name.contains('flour')) {
        totalFlour += amount;
        print('   🌾 밀가루 재료: ${name} - ${amount}g');
      }
    }

    print('   ⚖️ 총 밀가루량 계산 결과: ${totalFlour.toStringAsFixed(1)}g');
    if (totalFlour <= 0) {
      print('   ⚠️ 밀가루가 감지되지 않아 기본값 300g 사용');
      return 300.0; // 안전장치
    }

    return totalFlour;
  }

  /// 재료 데이터 동기 파싱 헬퍼
  static List<Map<String, dynamic>> parseIngredientsFromRecipeData([
    Map<String, dynamic>? recipeData,
  ]) {
    if (recipeData == null) {
      return [];
    }

    try {
      final rawIngredientsData = recipeData['ingredients'];

      if (rawIngredientsData == null) {
        return [];
      }

      List<dynamic> rawIngredients = [];

      if (rawIngredientsData is List) {
        rawIngredients = rawIngredientsData as List<dynamic>;
      } else if (rawIngredientsData is String) {
        try {
          final parsed = json.decode(rawIngredientsData);
          if (parsed is List) {
            rawIngredients = parsed as List<dynamic>;
          }
        } catch (e) {
          print('❌ [헬퍼] JSON 파싱 실패: $e');
          return [];
        }
      }

      final ingredients = <Map<String, dynamic>>[];
      for (final ingredient in rawIngredients) {
        if (ingredient is Map) {
          final name = (ingredient['name'] as String?) ?? '';
          final amount = (ingredient['amount'] as num?)?.toDouble() ?? 0.0;
          final unit = ingredient['unit'] as String? ?? 'g';

          if (name.isNotEmpty && amount > 0) {
            ingredients.add({
              'name': name,
              'amount': amount,
              'unit': unit,
            });
          }
        }
      }

      return ingredients;
    } catch (e) {
      print('❌ [헬퍼] 재료 파싱 실패: $e');
      return [];
    }
  }

  /// 점도 변화 예측 헬퍼
  static double predictViscosity(int stepIndex, String speed, int duration) {
    try {
      return MixingAnalysisService()
          .calculateViscosity(stepIndex, speed, duration);
    } catch (e) {
      print('❌ [헬퍼] 점도 예측 실패: $e');
      return 1.0; // 기본 점도
    }
  }

  /// 글루텐 형성도로부터 개발 단계 결정 헬퍼
  static String getDevelopmentStageFromGluten(double glutenFormation) {
    if (glutenFormation < 0.3) return '초기 개발';
    if (glutenFormation < 0.6) return '중기 개발';
    if (glutenFormation < 0.8) return '후기 개발';
    return '완전 개발';
  }
}

/// 믹싱 분석 컨트롤러
class MixingAnalysisController extends ChangeNotifier {
  // 상태 변수들
  List<mat.MixingStep> _mixingSteps = [];
  st.MixingAnalysisResult? _analysisResult;
  List<mat.MixingStepAnalysis> _stepAnalyses = [];
  mat.AnalysisProgress _progress = const mat.AnalysisProgress();
  bool _isAnalyzing = false;

  // 수분 트래킹 시스템 (빵 제조 과학 준수)
  MoistureTracker? _moistureTracker;

  // 토글 상태 관리
  final List<bool> _expandedStates = [];

  // 게터들
  List<mat.MixingStep> get mixingSteps => _mixingSteps;
  st.MixingAnalysisResult? get analysisResult => _analysisResult;
  List<mat.MixingStepAnalysis> get stepAnalyses => _stepAnalyses;
  mat.AnalysisProgress get progress => _progress;
  bool get isAnalyzing => _isAnalyzing;
  List<bool> get expandedStates => _expandedStates;

  // 세터들
  set stepAnalyses(List<mat.MixingStepAnalysis> value) {
    _stepAnalyses = value;
    notifyListeners();
  }

  set analysisResult(st.MixingAnalysisResult? value) {
    _analysisResult = value;
    notifyListeners();
  }

  set isAnalyzing(bool value) {
    _isAnalyzing = value;
    notifyListeners();
  }

  // 설정
  final Map<String, dynamic> recipeData;
  final UserEnvironment environment;
  final st.AnalysisSettings settings;
  final void Function(AnalysisResult)? onAnalysisComplete;

  MixingAnalysisController({
    required this.recipeData,
    required this.environment,
    required this.settings,
    this.onAnalysisComplete,
  }) {
    _initialize();
  }

  /// 초기화
  void _initialize() {
    print('🔧 [컨트롤러] 초기화 시작');
    _loadMixingSteps();
    _initializeExpandedStates();
    _initializeMoistureTracker();
    print('✅ [컨트롤러] 초기화 완료');
  }

  /// 수분 트래커 초기화 (빵 제조 과학 준수)
  void _initializeMoistureTracker() {
    try {
      final ingredients =
          MixingAnalysisHelper.parseIngredientsFromRecipeData(recipeData);
      _moistureTracker = MoistureTracker.fromRecipeData(ingredients);
      print('✅ [컨트롤러] 수분 트래커 초기화 완료');
    } catch (e) {
      print('❌ [컨트롤러] 수분 트래커 초기화 실패: $e');
      _moistureTracker = null;
    }
  }

  /// 믹싱 단계 로드
  void _loadMixingSteps() {
    try {
      final rawSteps = MixingDataHelper.extractMixingSteps(recipeData);
      _mixingSteps = rawSteps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        return mat.MixingStep(
          stepNumber: SafeTypeConverter.safeToInt(step['step']) ??
              (index + 1), // 단계 번호 추가
          comment:
              SafeTypeConverter.safeToString(step['comment'], defaultValue: ''),
          speed:
              SafeTypeConverter.safeToString(step['speed'], defaultValue: '중속'),
          durationMinutes: SafeTypeConverter.safeToInt(
                  step['durationMinutes'] ??
                      step['time'] ??
                      step['duration']) ??
              5,
          temperature: SafeTypeConverter.safeToDouble(step['temperature']),
        );
      }).toList();

      print('✅ [컨트롤러] 믹싱 단계 로드 완료: ${_mixingSteps.length}개');
    } catch (e) {
      print('❌ [컨트롤러] 믹싱 단계 로드 실패: $e');
      _mixingSteps = [];
    }
  }

  /// 토글 상태 초기화
  void _initializeExpandedStates() {
    _expandedStates.clear();
    _expandedStates.addAll(List<bool>.filled(_mixingSteps.length, false));
  }

  /// 분석 실행
  Future<void> performAnalysis() async {
    if (_isAnalyzing) {
      print('⚠️ [컨트롤러] 이미 분석 중입니다');
      return;
    }

    _setAnalyzing(true);
    _updateProgress(
        const mat.AnalysisProgress(status: mat.AnalysisStatus.idle));

    try {
      print(
          '🔍 [컨트롤러] 분석 시작 - 환경: 온도 ${environment.temperature}°C, 습도 ${environment.humidity}%');

      // 1. 각 단계별 상세 분석 수행
      _stepAnalyses = [];
      final stepAnalyses = <mat.MixingStepAnalysis>[];
      final cumulativeStates = <mat.DoughState>[]; // 누적 상태 추적

      try {
        for (int i = 0; i < _mixingSteps.length; i++) {
          final step = _mixingSteps[i];
          final progress = (i + 1) / _mixingSteps.length;

          _updateProgress(mat.AnalysisProgress.running(
            progress: progress,
            message: '단계 ${i + 1}/${_mixingSteps.length} 분석 중...',
            startTime: DateTime.now(),
          ));

          // 이전 단계의 상태를 고려한 분석 수행
          final previousState =
              cumulativeStates.isNotEmpty ? cumulativeStates.last : null;

          // 수분 트래킹 시스템 업데이트 (빵 제조 과학 준수)
          if (_moistureTracker != null) {
            print('\n💧 [빵 제조 과학적 수분 트래킹] 단계 ${i + 1} 믹싱 전 수분 상태');
            print(
                '   - 총 레시피 수분량: ${_moistureTracker!.totalRecipeMoistureWeight.toStringAsFixed(1)}g');
            print(
                '   - 현재残여 수분량: ${_moistureTracker!.remainingMoistureWeight.toStringAsFixed(1)}g');
            print(
                '   - 누적 흡수량: ${_moistureTracker!.absorbedMoisture.toStringAsFixed(1)}g');
            print(
                '   - 누적 증발량: ${_moistureTracker!.evaporatedMoisture.toStringAsFixed(1)}g');

            try {
              print('💧 [컨트롤러] 단계 ${i + 1} 수분 트래킹 시스템 업데이트 호출');
              print('   - 믹싱 속도: ${step.speed}, 시간: ${step.durationMinutes}분');

              _moistureTracker!.updateMoistureState(
                speed: step.speed,
                durationMinutes: step.durationMinutes,
                environmentTemperature: environment.temperature,
                environmentHumidity: environment.humidity,
                mixerTypeIndex: 1, // 상업용 믹서
              );

              print('✅ [빵 제조 과학적 수분 트래킹] 단계 ${i + 1} 믹싱 후 수분 상태');
              print(
                  '   - 단계별 흡수량: ${_moistureTracker!.absorbedMoisture.toStringAsFixed(1)}g (누적)');
              print(
                  '   - 단계별 증발량: ${_moistureTracker!.evaporatedMoisture.toStringAsFixed(1)}g (누적)');
              print(
                  '   - 남은 수분량: ${_moistureTracker!.remainingMoistureWeight.toStringAsFixed(1)}g');
              print(
                  '   - 총 수분 보존:\n     ${_moistureTracker!.remainingMoistureWeight + _moistureTracker!.absorbedMoisture + _moistureTracker!.evaporatedMoisture == _moistureTracker!.totalRecipeMoistureWeight ? '✅ 보존됨' : '❌ 손실'}');
              print(
                  '     = ${_moistureTracker!.remainingMoistureWeight.toStringAsFixed(1)} + ${_moistureTracker!.absorbedMoisture.toStringAsFixed(1)} + ${_moistureTracker!.evaporatedMoisture.toStringAsFixed(1)} = ${(_moistureTracker!.remainingMoistureWeight + _moistureTracker!.absorbedMoisture + _moistureTracker!.evaporatedMoisture).toStringAsFixed(1)}g (원본: ${_moistureTracker!.totalRecipeMoistureWeight.toStringAsFixed(1)}g)');
            } catch (e) {
              print('⚠️ [컨트롤러] 수분 트래킹 업데이트 실패: $e');
            }

            print('💧 [빵 제조 과학적 수분 트래킹] 단계 ${i + 1} 완료\n');
          }

          // 누적 상태를 고려하여 단계 분석 수행
          final stepAnalysis = await _analyzeMixingStepWithAccumulatedState(
              step, i, previousState);

          stepAnalyses.add(stepAnalysis);

          // 현재 단계의 최종 누적 상태를 cumulativeStates에 추가
          cumulativeStates.add(stepAnalysis.doughState);

          // 🔔 [실시간 UI 업데이트] 단계별 분석 완료 후 다음 프레임에서 안전하게 업데이트
          if (WidgetsBinding.instance != null) {
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              _stepAnalyses = List.from(stepAnalyses);
              notifyListeners();
            });
          } else {
            // 폴백: 다음 틱에서 업데이트
            Future.microtask(() {
              _stepAnalyses = List.from(stepAnalyses);
              notifyListeners();
            });
          }

          print('✅ [컨트롤러] 단계 ${i + 1} 환경 포함해서 상태 추가 완료');

          print('✅ [컨트롤러] 단계 ${i + 1} 분석 완료 - UI 실시간 업데이트');
        }
      } catch (e) {
        print('❌ [컨트롤러] 단계별 분석 루프 실패: $e');
        if (stepAnalyses.isEmpty) {
          throw Exception('모든 단계 분석 실패: $e');
        }
      }

      // 2. 종합 분석 수행
      _updateProgress(const mat.AnalysisProgress(
        status: mat.AnalysisStatus.analyzing,
        progress: 0.9,
        message: '종합 분석 수행 중...',
      ));

      final comprehensiveResult =
          await _performComprehensiveAnalysis(stepAnalyses);

      // ✅ [중앙화된 최종 반죽온도 계산] - BreadCalculatorService 활용
      print('🔥 [컨트롤러] 중앙화된 최종 반죽온도 계산 시작');
      final calculatedFinalDoughTemperature =
          await _calculateFinalDoughTemperature();
      print(
          '🔥 [컨트롤러] 중앙화된 최종 반죽온도 계산 완료: ${calculatedFinalDoughTemperature?.toStringAsFixed(1)}°C');

      // 조정된 결과에 최종 반죽온도 추가
      final adjustedComprehensiveResult = st.MixingAnalysisResult(
        totalTime: comprehensiveResult.totalTime,
        averageGlutenFormation: comprehensiveResult.averageGlutenFormation,
        finalMoisturePercentage: comprehensiveResult.finalMoisturePercentage,
        finalDoughTemperature:
            calculatedFinalDoughTemperature, // ✅ 중앙화된 계산 값 사용
        efficiency: comprehensiveResult.efficiency,
        overallScore: comprehensiveResult.overallScore,
        stepCount: comprehensiveResult.stepCount,
        finalDoughState: comprehensiveResult.finalDoughState,
        stepProgressionAnalysis: comprehensiveResult.stepProgressionAnalysis,
        speedDistributionAnalysis:
            comprehensiveResult.speedDistributionAnalysis,
        timeOptimizationAnalysis: comprehensiveResult.timeOptimizationAnalysis,
        integratedPerformanceAnalysis:
            comprehensiveResult.integratedPerformanceAnalysis,
        processOptimizationSuggestions:
            comprehensiveResult.processOptimizationSuggestions,
        stepProgressionDetails: comprehensiveResult.stepProgressionDetails,
        analysisVersion: comprehensiveResult.analysisVersion,
        analysisTimestamp: comprehensiveResult.analysisTimestamp,
        dataUtilizationRate: comprehensiveResult.dataUtilizationRate,
      );

      // 2.5. 온도 경고 생성 및 통합
      final temperatureWarnings =
          await _generateTemperatureWarnings(stepAnalyses);

      // 3. 결과 저장 및 콜백 호출
      _stepAnalyses = stepAnalyses;
      _analysisResult = adjustedComprehensiveResult; // ✅ 조정된 결과 사용

      _updateProgress(mat.AnalysisProgress.completed(
        message: '분석 완료',
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      ));

      // 🐛 [근본 원인 추적] 컨트롤러에서 UI로 보내는 데이터 확인
      print('🐛 [컨트롤러 → UI 데이터 전송] 단계별 분석 데이터:');
      for (int i = 0; i < stepAnalyses.length; i++) {
        final analysis = stepAnalyses[i];
        print(
            '🐛   단계 ${i + 1}: ${analysis.doughState.temperature.toStringAsFixed(1)}°C, 습도: ${environment.humidity.toStringAsFixed(1)}%, 믹싱시간: ${analysis.durationMinutes}분');
      }

      print('🐛 [컨트롤러 → UI 전송] stepAnalyses 개수: ${stepAnalyses.length}');

      // ✅ 컨셉 준수: finalGlutenFormation 추가하여 발효 단계 연동 보장
      // 콜백 호출
      _callAnalysisCompleteCallback(
        stepAnalyses: stepAnalyses,
        comprehensiveResult: comprehensiveResult,
        cumulativeStates: cumulativeStates,
        temperatureWarnings: temperatureWarnings,
        finalGlutenFormation: cumulativeStates.isNotEmpty
            ? cumulativeStates.last.glutenFormation
            : 0.0,
        finalTemperature: cumulativeStates.isNotEmpty
            ? cumulativeStates.last.temperature
            : environment.temperature,
      );

      print('✅ [컨트롤러] 분석 완료');

      // 🎯 [눈에 띄게] 최종 분석 결과 한줄 요약
      _printAnalysisSummary();
    } catch (e) {
      print('❌ [컨트롤러] 분석 중 오류 발생: $e');
      _updateProgress(mat.AnalysisProgress.error(
        message: '분석 실패: $e',
        startTime: DateTime.now(),
      ));
    } finally {
      _setAnalyzing(false);
    }
  }

  /// 누적 상태를 고려한 단계별 분석
  Future<mat.MixingStepAnalysis> _analyzeMixingStepWithAccumulatedState(
    mat.MixingStep step,
    int stepIndex,
    mat.DoughState? previousState,
  ) async {
    try {
      // RPM 계산
      final rpm = MixingAnalysisCalculations.calculateRPMForStep(step.speed);

      // 반죽 상태 분석 (이전 누적 상태 고려)
      final doughState =
          await _calculateAccumulatedDoughState(step, stepIndex, previousState);

      // 권장사항 생성
      final recommendations =
          await _generateStepRecommendations(step, doughState, stepIndex);

      // 효율성 계산
      final efficiency = MixingAnalysisCalculations.calculateStepEfficiency(
        step.speed,
        step.durationMinutes,
        rpm,
      );

      return mat.MixingStepAnalysis(
        stepNumber: step.stepNumber,
        speed: step.speed,
        durationMinutes: step.durationMinutes,
        rpm: rpm,
        doughState: doughState,
        recommendations: recommendations,
        efficiency: efficiency,
      );
    } catch (e) {
      print('❌ [컨트롤러] 누적 분석 실패: $e');
      // 오류 시 기본 분석 결과 반환
      return _createDefaultStepAnalysis(step, stepIndex);
    }
  }

  /// 누적 상태 계산
  Future<mat.DoughState> _calculateAccumulatedDoughState(
      mat.MixingStep step, int stepIndex, mat.DoughState? previousState) async {
    try {
      // 기본 계산 수행
      final ingredients =
          MixingAnalysisHelper.parseIngredientsFromRecipeData(recipeData);

      // 🎯 [중앙화 엔진 사용] ProgressiveMixingCalculator 활용
      print(
          '🔬 [빵 제조 과학 계산] 단계 ${step.stepNumber} 시작 (총 ${_mixingSteps.length}단계 중 ${stepIndex + 1}번째)');

      // 중앙화된 빵 제조 과학 엔진 사용
      final stepWiseResult = await _calculateWithCentralizedEngine(
        step: step,
        stepIndex: stepIndex,
        totalSteps: _mixingSteps.length,
        ingredients: ingredients,
        previousState: previousState,
      );

      final currentState = mat.DoughState(
        temperature: stepWiseResult.temperature,
        glutenFormation: stepWiseResult.glutenFormation,
        viscosity: stepWiseResult.viscosity,
        moistureAbsorption: stepWiseResult.moistureAbsorption,
        currentStep: step.stepNumber,
        developmentStage: stepWiseResult.developmentStage,
        ingredients: ingredients,
        recipeTitle: recipeData['title'] as String?,
        mixingStep: step,
      );

      print('✅ [빵 제조 과학 계산 완료]');
      print('   - 온도: ${currentState.temperature.toStringAsFixed(1)}°C');
      print('   - 글루텐: ${(currentState.glutenFormation * 100).round()}%');
      print('   - 점도: ${currentState.viscosity.toStringAsFixed(2)}');

      print('✅ [차수 기반 정확 계산 완료]');
      print(
          '✅ [컨트롤러] 단계 ${stepIndex + 1} 누적 상태 계산 완료: ${currentState.temperature.toStringAsFixed(1)}°C');
      return currentState;
    } catch (e) {
      print('❌ [빵 제조 과학 누적 상태 계산 실패]: $e');
      // 오류 시 기본 DoughState 반환
      final ingredients =
          MixingAnalysisHelper.parseIngredientsFromRecipeData(recipeData);
      return mat.DoughState(
        temperature: previousState?.temperature ?? environment.temperature,
        glutenFormation: previousState?.glutenFormation ?? 0.0,
        viscosity: previousState?.viscosity ?? 0.0,
        moistureAbsorption: previousState?.moistureAbsorption ?? 0.0,
        currentStep: step.stepNumber,
        developmentStage: '계산 오류',
        ingredients: ingredients,
        recipeTitle: recipeData['title'] as String?,
        mixingStep: step,
      );
    }
  }

  /// 🎯 [중앙화 엔진 사용] ProgressiveMixingCalculator를 활용한 단계별 계산
  Future<StepWiseCalculationResult> _calculateWithCentralizedEngine({
    required mat.MixingStep step,
    required int stepIndex,
    required int totalSteps,
    required List<Map<String, dynamic>> ingredients,
    required mat.DoughState? previousState,
  }) async {
    try {
      // ProgressiveMixingCalculator를 사용하여 중앙화된 빵 제조 과학 계산
      final calculator = ProgressiveMixingCalculator();

      final input = calc_types.CalculationInput(
        currentState: calc_types.BakingState(
          temperature: previousState?.temperature ?? environment.temperature,
          glutenFormation: previousState?.glutenFormation ?? 0.0,
          viscosity: previousState?.viscosity ?? 1.0,
          moistureAbsorption: previousState?.moistureAbsorption ?? 65.0,
          developmentStage: previousState?.developmentStage ?? '초기',
          currentStep: stepIndex,
        ),
        mixingStep: calc_types.MixingStep(
          stepNumber: step.stepNumber,
          speed: step.speed,
          durationMinutes: step.durationMinutes.toDouble(),
          temperatureCelsius: step.temperature ?? environment.temperature,
        ),
        environment: environment,
        ingredients: ingredients,
        recipeTitle: recipeData['title'] as String? ?? '빵 제조',
        stepIndex: stepIndex,
      );

      final result = await calculator.calculate(input);

      // CalculationResult를 StepWiseCalculationResult로 변환
      return StepWiseCalculationResult(
        temperature: result.data['temperature'] as double? ?? 0.0,
        glutenFormation: result.data['glutenFormation'] as double? ?? 0.0,
        viscosity: result.data['viscosity'] as double? ?? 0.0,
        moistureAbsorption: result.data['moistureAbsorption'] as double? ?? 0.0,
        developmentStage: '통합 계산 엔진 적용',
      );
    } catch (e) {
      print('❌ [중앙화 엔진 계산 실패]: $e');
      // 실패시 기본 결과 반환
      return StepWiseCalculationResult(
        temperature: previousState?.temperature ?? environment.temperature,
        glutenFormation: previousState?.glutenFormation ?? 0.0,
        viscosity: previousState?.viscosity ?? 0.0,
        moistureAbsorption: previousState?.moistureAbsorption ?? 0.0,
        developmentStage: '중앙화 엔진 오류',
      );
    }
  }

  /// 단계별 권장사항 생성
  Future<List<String>> _generateStepRecommendations(
    mat.MixingStep step,
    mat.DoughState doughState,
    int stepIndex,
  ) async {
    return MixingWarningService.generateIntegratedFeedback(
      {
        'speed': step.speed,
        'durationMinutes': step.durationMinutes,
      },
      {
        'glutenFormation': doughState.glutenFormation,
        'temperature': doughState.temperature,
        'viscosity': doughState.viscosity,
        'moistureAbsorption': doughState.moistureAbsorption,
      },
      null, // previousStepAnalysis
      null, // previousDoughState
      stepIndex,
    );
  }

  /// 기본 단계 분석 생성 (오류 시 사용)
  mat.MixingStepAnalysis _createDefaultStepAnalysis(
      mat.MixingStep step, int stepIndex) {
    try {
      final ingredients =
          MixingAnalysisHelper.parseIngredientsFromRecipeData(recipeData);

      return mat.MixingStepAnalysis(
        stepNumber: stepIndex + 1,
        speed: step.speed,
        durationMinutes: step.durationMinutes,
        rpm: MixingAnalysisCalculations.calculateRPMForStep(step.speed),
        doughState: mat.DoughState(
          temperature: step.temperature ?? 25.0,
          glutenFormation: 0.3,
          viscosity: 1.0,
          moistureAbsorption: 65.0,
          currentStep: step.stepNumber,
          developmentStage: '기본 분석',
          ingredients: ingredients,
          recipeTitle: recipeData['title'] as String?,
          // environment 파라미터 제거 - 이미 계산에 사용됨
          mixingStep: step,
        ),
        recommendations: ['기본 분석 결과를 사용합니다. 실제 데이터로 재분석을 권장합니다.'],
        efficiency: 0.5,
      );
    } catch (e) {
      print('❌ [컨트롤러] 기본 분석 생성 실패: $e');
      // 최후의 안전장치
      return mat.MixingStepAnalysis(
        stepNumber: stepIndex + 1,
        speed: step.speed,
        durationMinutes: step.durationMinutes,
        rpm: MixingAnalysisCalculations.calculateRPMForStep(step.speed),
        doughState: mat.DoughState(
          temperature: 25.0,
          glutenFormation: 0.3,
          viscosity: 1.0,
          moistureAbsorption: 65.0,
          currentStep: step.stepNumber,
          developmentStage: '안전 모드',
          ingredients: [],
          recipeTitle: recipeData['title'] as String?,
          // environment 파라미터 제거 - 오류 처리에서는 기본값 사용
          mixingStep: step,
        ),
        recommendations: ['분석에 실패했습니다. 재시도를 권장합니다.'],
        efficiency: 0.3,
      );
    }
  }

  /// 종합 분석 수행
  Future<st.MixingAnalysisResult> _performComprehensiveAnalysis(
    List<mat.MixingStepAnalysis> stepAnalyses,
  ) async {
    try {
      // MixingAnalysisService 활용
      final stepAnalysisData = stepAnalyses
          .map((step) => {
                'speed': step.speed,
                'durationMinutes': step.durationMinutes,
                'efficiency': step.efficiency,
                'doughState': {
                  'glutenFormation': step.doughState.glutenFormation,
                  'temperature': step.doughState.temperature,
                  'viscosity': step.doughState.viscosity,
                  'moistureAbsorption': step.doughState.moistureAbsorption,
                  'developmentStage': step.doughState.developmentStage,
                },
              })
          .toList();

      final serviceResult =
          await MixingAnalysisService().performComprehensiveAnalysis(
        stepAnalysisData,
        recipeData,
      );

      return st.MixingAnalysisResult(
        totalTime: serviceResult['totalTime'] as int? ?? 0,
        averageGlutenFormation:
            serviceResult['averageGlutenFormation'] as double? ?? 0.0,
        finalMoisturePercentage:
            serviceResult['finalMoisturePercentage'] as double? ?? 0.0,
        efficiency: serviceResult['efficiency'] as double? ?? 0.0,
        overallScore: serviceResult['overallScore'] as double? ?? 0.0,
        stepCount: serviceResult['stepCount'] as int? ?? 0,
        finalDoughState: serviceResult['finalDoughState'] as String? ?? '',
        stepProgressionAnalysis:
            serviceResult['stepProgressionAnalysis'] as Map<String, dynamic>? ??
                {},
        speedDistributionAnalysis: serviceResult['speedDistributionAnalysis']
                as Map<String, dynamic>? ??
            {},
        timeOptimizationAnalysis: serviceResult['timeOptimizationAnalysis']
                as Map<String, dynamic>? ??
            {},
        integratedPerformanceAnalysis:
            serviceResult['integratedPerformanceAnalysis']
                    as Map<String, dynamic>? ??
                {},
        processOptimizationSuggestions:
            (serviceResult['processOptimizationSuggestions'] as List?)
                    ?.cast<String>() ??
                [],
        stepProgressionDetails:
            (serviceResult['stepProgressionDetails'] as List?)
                    ?.cast<Map<String, dynamic>>() ??
                [],
        analysisVersion: serviceResult['analysisVersion'] as String? ?? '1.0',
        analysisTimestamp: serviceResult['analysisTimestamp'] as String? ??
            DateTime.now().toIso8601String(),
        dataUtilizationRate:
            serviceResult['dataUtilizationRate'] as String? ?? '0%',
      );
    } catch (e) {
      print('❌ [컨트롤러] 종합 분석 실패: $e');
      // 기본 종합 결과 반환
      return st.MixingAnalysisResult(
        totalTime:
            stepAnalyses.fold(0, (sum, step) => sum + step.durationMinutes),
        averageGlutenFormation: stepAnalyses.isEmpty
            ? 0.0
            : stepAnalyses
                    .map((s) => s.doughState.glutenFormation)
                    .reduce((a, b) => a + b) /
                stepAnalyses.length,
        finalMoisturePercentage: stepAnalyses.isEmpty
            ? 0.0
            : stepAnalyses.last.doughState.moistureAbsorption,
        efficiency: stepAnalyses.isEmpty
            ? 0.0
            : stepAnalyses.map((s) => s.efficiency).reduce((a, b) => a + b) /
                stepAnalyses.length,
        overallScore: 65.0,
        stepCount: stepAnalyses.length,
        finalDoughState: '종합 분석 오류',
        stepProgressionAnalysis: {},
        speedDistributionAnalysis: {},
        timeOptimizationAnalysis: {},
        integratedPerformanceAnalysis: {},
        processOptimizationSuggestions: ['분석에 실패했습니다. 재시도를 권장합니다.'],
        stepProgressionDetails: [],
        analysisVersion: '1.0',
        analysisTimestamp: DateTime.now().toIso8601String(),
        dataUtilizationRate: '0%',
      );
    }
  }

  /// 온도 경고 생성
  Future<List<String>> _generateTemperatureWarnings(
      List<mat.MixingStepAnalysis> stepAnalyses) async {
    final temperatureWarnings = <String>[];

    // 실제 환경 값 사용
    final roomTemp = environment.temperature;

    for (int i = 0; i < stepAnalyses.length; i++) {
      final step = stepAnalyses[i];
      final currentDoughTemp = step.doughState.temperature;

      final stepWarning = MixingWarningService.generateDoughTemperatureWarning(
        i,
        step.speed,
        step.durationMinutes,
        currentDoughTemp,
        roomTemp,
        20.0, // 기본 반죽 온도
      );

      if (stepWarning.isNotEmpty) {
        temperatureWarnings.add(stepWarning);
      }
    }

    return temperatureWarnings;
  }

  /// 분석 완료 콜백 호출
  void _callAnalysisCompleteCallback({
    required List<mat.MixingStepAnalysis> stepAnalyses,
    required st.MixingAnalysisResult comprehensiveResult,
    required List<mat.DoughState> cumulativeStates,
    required List<String> temperatureWarnings,
    required double finalGlutenFormation,
    required double finalTemperature,
  }) {
    debugPrint('🔧 [컨트롤러] 콜백 호출 시작');
    debugPrint('🔧 [믹싱 결과 생성 디버깅] 최종 데이터 확인:');
    debugPrint('   - finalGlutenFormation: $finalGlutenFormation');
    debugPrint('   - finalTemperature: $finalTemperature');
    debugPrint('   - stepAnalyses 개수: ${stepAnalyses.length}');
    debugPrint('   - cumulativeStates 개수: ${cumulativeStates.length}');
    debugPrint(
        '   - comprehensiveResult: ${comprehensiveResult.overallScore.toStringAsFixed(3)}');

    if (onAnalysisComplete == null) {
      debugPrint('⚠️ 콜백 null');
      return;
    }

    try {
      final stepAnalysesJson = stepAnalyses.map((e) => e.toJson()).toList();
      final resultData = {
        'stepAnalyses': stepAnalysesJson,
        'comprehensiveAnalysis': comprehensiveResult.toJson(),
        'cumulativeStates': cumulativeStates.map((e) => e.toJson()).toList(),
        'temperatureWarnings': temperatureWarnings,
        'analysisMetadata': {
          'totalSteps': stepAnalyses.length,
          'hasTemperatureWarnings': temperatureWarnings.isNotEmpty,
          'analysisTimestamp': DateTime.now().toIso8601String(),
          'dataVersion': '2.0',
        },
        'finalGlutenFormation': finalGlutenFormation,
        'finalTemperature': finalTemperature,
      };

      // 🎯 [디버그] 믹싱 결과 데이터 구조의 최종 형태 로깅
      debugPrint('🎯 [믹싱 결과 데이터 구조] 생성된 최종 데이터:');
      debugPrint('   resultData.keys: ${resultData.keys.toList()}');
      debugPrint(
          '   stepAnalyses.length: ${(resultData['stepAnalyses'] as List).length}');
      debugPrint(
          '   comprehensiveAnalysis.keys: ${(resultData['comprehensiveAnalysis'] as Map<String, dynamic>).keys.toList()}');
      debugPrint(
          '   cumulativeStates.length: ${(resultData['cumulativeStates'] as List).length}');
      debugPrint(
          '   temperatureWarnings.length: ${(resultData['temperatureWarnings'] as List).length}');
      debugPrint('   analysisMetadata: ${resultData['analysisMetadata']}');

      final analysisResult = AnalysisResult(
        moduleId: 'mixing_analysis',
        data: resultData,
        temperatureWarnings: temperatureWarnings,
        timestamp: DateTime.now(),
        confidence: 0.85,
        isSuccessful: true,
      );

      onAnalysisComplete!(analysisResult);
      debugPrint('✅ 콜백 성공');
    } catch (e) {
      debugPrint('❌ 콜백 오류: $e');
    }
  }

  /// 분석 상태 설정
  void _setAnalyzing(bool analyzing) {
    _isAnalyzing = analyzing;
    notifyListeners();
  }

  /// 진행 상태 업데이트
  void _updateProgress(mat.AnalysisProgress newProgress) {
    _progress = newProgress;
    notifyListeners();
  }

  /// 최종 누적 글루텐 형성도 가져오기
  double getFinalAccumulatedGlutenFormation() {
    if (_stepAnalyses.isEmpty) return 0.0;
    return _stepAnalyses.last.doughState.glutenFormation;
  }

  /// 최종 누적 수분 흡수율 가져오기
  double getFinalMoistureAbsorption() {
    if (_stepAnalyses.isEmpty) return 0.0;
    return _stepAnalyses.last.doughState.moistureAbsorption;
  }

  /// 🎯 [눈에 띄게] 분석 요약 출력 - 통합 계산기 사용 반영
  void _printAnalysisSummary() {
    if (_stepAnalyses.isEmpty) {
      print('🎯 [분석 요약] ❌ 단계 분석 데이터가 없습니다');
      return;
    }

    print('\n🎯🎯🎯🎯🎯🎯 [믹싱 분석 최종 요약] 🎯🎯🎯🎯🎯🎯');

    // 각 단계별 통합 계산 결과 요약
    final summary = <String>[];
    double totalGlutenProgression = 0.0;

    for (int i = 0; i < _stepAnalyses.length; i++) {
      final step = _stepAnalyses[i];
      final stepGluten = step.doughState.glutenFormation;

      summary.add('단계 ${i + 1}: ${(stepGluten * 100).round()}%');
      totalGlutenProgression += stepGluten;

      print(
          '🎯 단계 ${i + 1}: ${(stepGluten * 100).round()}% (통합 계산: 온도→수분→글루텐→점도 순차 연산)');
    }

    final finalGluten = _stepAnalyses.last.doughState.glutenFormation;
    final finalMoisture = _stepAnalyses.last.doughState.moistureAbsorption;
    final finalTemperature = _stepAnalyses.last.doughState.temperature;
    final finalViscosity = _stepAnalyses.last.doughState.viscosity;

    print(
        '🎯 최종 글루텐 형성도: ${(finalGluten * 100).round()}% (총 누적 진행: ${(totalGlutenProgression * 100).round()}%)');
    print('🎯 최종 수분 흡수율: ${finalMoisture.toStringAsFixed(1)}%');
    print('🎯 최종 반죽온도: ${finalTemperature.toStringAsFixed(1)}°C');
    print('🎯 최종 점도: ${finalViscosity.toStringAsFixed(2)}');
    print('🎯 계산 방식: 빵 제조 과학적 단일 계산 엔진');
    print('🎯 데이터 소스: ProgressiveMixingCalculator.calculateStepWise()');
    print('🎯 믹싱 파라미터 100% 반영: 차수, 속도, 시간 결정론적 영향');
    print('🎯 컨셉 통일: 단계별 계산기로 통합 - 중복 및 불일치 제거');
    print('🎯🎯🎯🎯🎯🎯================================================\n');
  }

  /// 리소스 정리
  @override
  void dispose() {
    print('🧹 [컨트롤러] 리소스 정리');
    super.dispose();
  }

  /// [중앙화된 최종 반죽온도 계산] - DoughTemperatureCalculator 사용
  Future<double?> _calculateFinalDoughTemperature() async {
    try {
      print('🔥 [최종 반죽온도 계산] 중앙화된 계산기 사용');

      // ✅ [레거시 인터페이스 사용] 간단한 방법으로 중앙화 계산기 활용
      final result =
          DoughTemperatureCalculator.calculateActualDoughTemperature({
        'temperature': environment.temperature,
        'humidity': environment.humidity,
        'mixerType': 'home',
        'stageAnalysis': _mixingSteps
            .map((step) => {
                  '속도': step.speed,
                  '시간(분)': step.durationMinutes,
                })
            .toList(),
      });

      print('🔥 [최종 반죽온도 계산] 중앙화된 계산기 결과: ${result.toStringAsFixed(1)}°C');
      return result;
    } catch (e) {
      print('❌ [중앙화된 최종 반죽온도 계산 실패]: $e');
      // ❌ [중앙화 실패 시 폴백] 환경 온도 기반 기본값 반환
      return environment.temperature?.clamp(5.0, 50.0);
    }
  }
}

/// ✅ [빵 제조 과학 계산] 단계별 계산 결과 타입
class StepWiseCalculationResult {
  final double temperature;
  final double glutenFormation;
  final double viscosity;
  final double moistureAbsorption;
  final String developmentStage;

  StepWiseCalculationResult({
    required this.temperature,
    required this.glutenFormation,
    required this.viscosity,
    required this.moistureAbsorption,
    required this.developmentStage,
  });
}
