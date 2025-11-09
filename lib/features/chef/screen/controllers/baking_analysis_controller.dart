import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/types/environment_types.dart';
import '../../../../core/types/calculation_types.dart';
import '../../../../services/centralized_parsing_service.dart';
import '../../../../services/baking_calculator.dart' as baking_service;

/// 베이킹 단계별 분석 타입 (컨트롤러용 UI 타입)
class BakingStepAnalysis {
  final int stepNumber;
  final double ovenTemperature;
  final double bakingProgress;
  final double maillardReaction;
  final double crumbBakingProgress;
  final double internalTemperature;
  final double moistureLoss;
  final Duration time;

  // 누적 값 필드 추가
  final double cumulativeBakingProgress;
  final double cumulativeMaillardReaction;
  final double cumulativeCrumbBakingProgress;
  final double cumulativeInternalTemperature;

  const BakingStepAnalysis({
    required this.stepNumber,
    required this.ovenTemperature,
    required this.bakingProgress,
    required this.maillardReaction,
    required this.crumbBakingProgress,
    required this.internalTemperature,
    required this.moistureLoss,
    required this.time,
    required this.cumulativeBakingProgress,
    required this.cumulativeMaillardReaction,
    required this.cumulativeCrumbBakingProgress,
    required this.cumulativeInternalTemperature,
  });
}

/// 베이킹 분석 컨트롤러 - FermentationAnalysisController 패턴 적용
class BakingAnalysisController extends ChangeNotifier {
  // 상태 변수들
  Map<String, dynamic>? _mixingResult;
  FermentationState? _fermentationState;
  Map<String, dynamic>? _recipeData;
  UserEnvironment? _environment;

  // 계산 결과들
  baking_service.BakingProcessResult? _analysisResult;
  List<BakingStepAnalysis> _stepAnalyses = [];

  bool _isAnalyzing = false;
  DateTime? _lastAnalysisStartTime;
  static const _analysisTimeout = Duration(minutes: 5);
  String? _error;

  // 생성자
  BakingAnalysisController();

  // 게터들
  Map<String, dynamic>? get mixingResult => _mixingResult;
  Map<String, dynamic>? get recipeData => _recipeData;
  UserEnvironment? get environment => _environment;

  baking_service.BakingProcessResult? get analysisResult => _analysisResult;
  List<BakingStepAnalysis> get stepAnalyses => _stepAnalyses;
  bool get hasStepAnalysis => _stepAnalyses.isNotEmpty;

  bool get isAnalyzing => _isAnalyzing;
  String? get error => _error;
  bool get isComplete => _analysisResult != null;

  /// 믹싱 및 발효 결과 준비 상태 확인
  bool get hasMixingResult => _mixingResult != null;
  bool get hasFermentationState => _fermentationState != null;

  /// BakingState 타입 믹싱 결과를 getter로 제공 - 빅데이터 준수 완전 적용
  BakingState get mixingState {
    debugPrint('🔥 [BakingAnalysisController] mixingState getter 호출 (빅데이터 준수)');

    if (_mixingResult == null) {
      throw Exception('베이킹 계산에 믹싱 결과 데이터가 필요합니다 - 빅데이터 준수 위반');
    }

    final result = _mixingResult!;
    debugPrint('🔥 [BakingAnalysisController] 믹싱 데이터 추출 시작:');

    // 🧪 [빅데이터 준수] 실제 데이터만 사용, 기본값 완전 제거

    // 생지 온도 - 사용자 실제 데이터만 사용 (빅데이터 준수)
    final temperature = _extractNumericValue(result, 'finalTemperature');
    debugPrint('   - 생지 온도: ${temperature}°C (사용자 실제 데이터 사용)');

    // 글루텐 형성도 - 사용자 실제 데이터만 사용
    final glutenFormation =
        _extractNumericValue(result, 'finalGlutenFormation');
    debugPrint(
        '   - 글루텐 형성도: ${glutenFormation.toStringAsFixed(3)} (사용자 실제 데이터 사용)');

    // 점성도 - 사용자 실제 데이터만 사용
    final viscosity = _extractNumericValue(result, 'finalViscosity');
    debugPrint('   - 점성도: ${viscosity.toStringAsFixed(2)} (사용자 실제 데이터 사용)');

    // 수분 흡수율 - 사용자 실제 데이터만 사용
    final moistureAbsorption =
        _extractNumericValue(result, 'finalMoistureAbsorption');
    debugPrint(
        '   - 수분 흡수율: ${moistureAbsorption.toStringAsFixed(1)}% (사용자 실제 데이터 사용)');

    // 개발 단계 - 문자열 검증
    final developmentStage = result['developmentStage'] as String?;
    if (developmentStage == null || developmentStage.isEmpty) {
      throw Exception('베이킹 계산에 믹싱 결과의 개발 단계 데이터가 필요합니다 - 빅데이터 준수 위반');
    }
    debugPrint('   - 개발 단계: $developmentStage (사용자 실제 데이터 사용)');

    // 현재 단계 - 숫자 검증
    final currentStepValue = result['currentStep'];
    if (currentStepValue == null || currentStepValue is! num) {
      throw Exception('베이킹 계산에 믹싱 결과의 현재 단계 데이터가 필요합니다 - 빅데이터 준수 위반');
    }
    final currentStep = (currentStepValue as num).toInt();
    debugPrint('   - 현재 단계: $currentStep (사용자 실제 데이터 사용)');

    final mixingStateResult = BakingState(
      temperature: temperature,
      glutenFormation: glutenFormation,
      viscosity: viscosity,
      moistureAbsorption: moistureAbsorption,
      developmentStage: developmentStage,
      currentStep: currentStep,
    );

    debugPrint('✅ [BakingAnalysisController] 빅데이터 준수 BakingState 생성 완료');
    debugPrint('   - 모든 값이 사용자 실제 데이터 기반으로 설정됨');
    return mixingStateResult;
  }

  /// 빅데이터 준수 헬퍼 메소드 - 실제 데이터만 추출, 기본값 금지
  double _extractNumericValue(Map<String, dynamic> result, String key) {
    final value = result[key];
    if (value == null) {
      throw Exception('베이킹 계산에 믹싱 결과의 $key 데이터가 필요합니다 - 빅데이터 준수 위반 (null 값)');
    }

    if (value is! num) {
      throw Exception(
          '베이킹 계산에 믹싱 결과의 $key 데이터 타입이 올바르지 않습니다 - 빅데이터 준수 위반 (숫자가 아님)');
    }

    final doubleValue = value.toDouble();
    if (doubleValue <= 0) {
      throw Exception(
          '베이킹 계산에 믹싱 결과의 $key 데이터가 유효하지 않습니다 - 빅데이터 준수 위반 (0 이하 값)');
    }

    return doubleValue;
  }

  // 세터들
  void setMixingResult(Map<String, dynamic> result) {
    debugPrint('🔥 [BakingAnalysisController.setMixingResult] 시작');
    debugPrint('   - 입력 데이터 타입: ${result.runtimeType}');
    debugPrint('   - 입력 데이터 키들: ${result.keys.toList()}');

    // 🧪 [기본값 적용 해결] cumulativeStates의 마지막 상태를 추출하여 누락된 키들 추가
    if (result.containsKey('cumulativeStates')) {
      final cumulativeStates = result['cumulativeStates'] as List?;
      if (cumulativeStates != null && cumulativeStates.isNotEmpty) {
        final lastState = cumulativeStates.last as Map<String, dynamic>;
        debugPrint('🔗 [BakingAnalysisController] cumulativeStates 마지막 상태 추출:');
        debugPrint('   - cumulativeStates 타입: ${cumulativeStates.runtimeType}');
        debugPrint('   - cumulativeStates 길이: ${cumulativeStates.length}');
        debugPrint('   - 마지막 상태 키들: ${lastState.keys.toList()}');
        debugPrint('   - 최종 viscosity: ${lastState['viscosity']}');
        debugPrint(
            '   - 최종 moistureAbsorption: ${lastState['moistureAbsorption']}');
        debugPrint(
            '   - 최종 developmentStage: ${lastState['developmentStage']}');
        debugPrint('   - 최종 currentStep: ${lastState['currentStep']}');

        // 누락된 키들을 result에 추가 (기존 데이터는 보존)
        result = Map<String, dynamic>.from(result);
        result['finalViscosity'] = lastState['viscosity'];
        result['finalMoistureAbsorption'] = lastState['moistureAbsorption'];

        // developmentStage와 currentStep도 마지막 상태로부터 갱신
        if (lastState.containsKey('developmentStage')) {
          result['developmentStage'] = lastState['developmentStage'];
        }
        if (lastState.containsKey('currentStep')) {
          result['currentStep'] = lastState['currentStep'];
        }

        debugPrint('✅ [BakingAnalysisController] 누락 키 추가 완료:');
        debugPrint(
            '   - finalViscosity: ${result['finalViscosity']} (${result['finalViscosity'].runtimeType})');
        debugPrint(
            '   - finalMoistureAbsorption: ${result['finalMoistureAbsorption']} (${result['finalMoistureAbsorption'].runtimeType})');
        debugPrint('   - developmentStage: ${result['developmentStage']}');
        debugPrint('   - currentStep: ${result['currentStep']}');
      } else {
        debugPrint(
            '⚠️ [BakingAnalysisController] cumulativeStates가 비어있거나 null임');
      }
    } else {
      debugPrint('⚠️ [BakingAnalysisController] cumulativeStates 키가 존재하지 않음');
    }

    _mixingResult = result;

    debugPrint('🔥 [베이킹 컨트롤러] 믹싱 결과 설정됨');
    debugPrint('   - 설정된 _mixingResult 존재: ${_mixingResult != null}');
    debugPrint('   - notifyListeners 호출 예정');

    notifyListeners();

    debugPrint('⏰ [BakingAnalysisController.setMixingResult] 완료');
  }

  void setFermentationState(FermentationState state) {
    _fermentationState = state;
    debugPrint('🔥 [베이킹 컨트롤러] 발효 상태 설정됨');
    notifyListeners();
  }

  void setAnalysisData({
    required Map<String, dynamic> recipeData,
    required UserEnvironment environment,
  }) {
    _recipeData = recipeData;
    _environment = environment;
    debugPrint('🔥 [베이킹 컨트롤러] 분석 데이터 설정 완료');
    notifyListeners();
  }

  /// 분석 준비 상태 확인
  bool get isReadyForAnalysis {
    final ready = _recipeData != null &&
        _environment != null &&
        hasMixingResult &&
        hasFermentationState &&
        !_isAnalyzing;

    if (!ready) {
      debugPrint('🔥 [베이킹 컨트롤러] 분석 준비 불충분');
    }

    return ready;
  }

  /// 베이킹 분석 수행 메소드 - 빵 과학 컨셉 준수
  /// 동시 호출 방지 및 실패 재시도 메커니즘 추가
  Future<void> performBakingAnalysis() async {
    debugPrint('🔥 [베이킹 분석 시작] ===== BEGIN =====');
    debugPrint('   - 시간: ${DateTime.now()}');
    debugPrint('   - 컨트롤러 인스턴스: ${hashCode}');

    // ✅ 컨트롤러 상태 상세 로깅 추가 (값 전달 추적)
    debugPrint('📋 [컨트롤러 상태 검사]');
    debugPrint(
        '   - _recipeData: ${_recipeData == null ? 'null' : '존재 (${_recipeData!.keys.length}개 키)'}');
    debugPrint('   - _environment: ${_environment == null ? 'null' : '존재'}');
    debugPrint(
        '   - _mixingResult: ${_mixingResult == null ? 'null' : '존재 (${_mixingResult!.keys.length}개 키)'}');
    debugPrint(
        '   - _fermentationState: ${_fermentationState == null ? 'null' : '존재'}');
    debugPrint('   - _isAnalyzing: $_isAnalyzing');
    debugPrint('   - _error: ${_error ?? 'null'}');
    debugPrint(
        '   - _lastAnalysisStartTime: ${_lastAnalysisStartTime ?? 'null'}');

    // 🔥 발효 상태 체크 추가 - ferm모entu이-ArationState가 null이면 대기
    if (_fermentationState == null) {
      debugPrint('🔥 [베이킹 분석] 발효 상태가 아직 준비되지 않아 대기함');
      debugPrint('   - _fermentationState: null');
      debugPrint('   - 발효 분석이 아직 완료되지 않은 것으로 보임');
      _error = '발효 상태가 준비되지 않아 베이킹 분석을 진행할 수 없습니다. 발효 분석을 먼저 완료해주세요.';
      notifyListeners();
      return;
    }

    // ✅ 더 강력한 중복 실행 방지 메커니즘
    final now = DateTime.now();

    // 1. 기본 동시 호출 보호
    if (_isAnalyzing) {
      debugPrint('⚠️ [베이킹 분석] 이미 실행 중이므로 무시 - 호출 시점 추적');
      debugPrint('   - 현재 상태: _isAnalyzing=true');
      return;
    }

    // 2. 최근 분석 완료 시간 검사 추가 (5분 내 재실행 방지)
    if (_lastAnalysisStartTime != null &&
        now.difference(_lastAnalysisStartTime!) < _analysisTimeout) {
      debugPrint('⚠️ [베이킹 분석] 최근 분석 5분 내 재시도 방지');
      debugPrint('   - 마지막 분석 시간: $_lastAnalysisStartTime');
      debugPrint(
          '   - 경과 시간: ${now.difference(_lastAnalysisStartTime!).inMinutes}분');
      debugPrint('   - 타임아웃 시간: ${_analysisTimeout.inMinutes}분');
      return;
    }

    // 분석 시작 시간 기록
    _lastAnalysisStartTime = now;

    debugPrint('🔥 [베이킹 분석 전 준비]');
    debugPrint('   - 레시피 데이터 존재: ${_recipeData != null}');
    debugPrint('   - 환경 데이터 존재: ${_environment != null}');
    debugPrint('   - 믹싱 결과 존재: ${_mixingResult != null}');
    debugPrint('   - 발효 상태 존재: ${_fermentationState != null}');
    debugPrint('   - 분석 준비 상태: $isReadyForAnalysis');
    debugPrint('   - 현재 _error 상태: $_error');

    // 재시도 횟수 제한 (실패 시 최대 3회 재시도)
    const int maxRetries = 3;
    int retryCount = 0;

    while (retryCount <= maxRetries) {
      try {
        debugPrint(
            '🔥 [베이킹 분석 시도 시작] ${retryCount + 1}/${maxRetries + 1} - ${DateTime.now()}');
        _isAnalyzing = true;
        _error = null;
        debugPrint('📢 [notifyListeners 호출] 시점 추적 - 분석 시작 전');
        debugPrint('   - 호출 위치: ${StackTrace.current}');
        notifyListeners();

        debugPrint('🔥 [베이킹 분석] 시도 ${retryCount + 1}/${maxRetries + 1}');

        // 중앙화 서비스를 통한 오븐 단계 데이터 추출
        final service = CentralizedParsingService();
        final initData = service.initializeBakingAnalysis(
          recipeData: _recipeData!,
          environment: _environment!,
        );

        debugPrint(
            '🔥 [베이킹 분석] 오븐 단계 데이터 추출 완료: ${initData.ovenSteps.length}단계');

        // ✅ 해결: 처리된 ingredients를 사용하는 recipeData 생성
        final processedRecipeData = Map<String, dynamic>.from(_recipeData!)
          ..['ingredients'] = initData.ingredients; // 변환된 List ingredients 사용

        debugPrint('🔥 [데이터 전처리] recipeData ingredients 타입 변환 완료');
        debugPrint(
            '   - 처리 전 ingredients 타입: ${_recipeData!['ingredients'].runtimeType}');
        debugPrint(
            '   - 처리 후 ingredients 타입: ${initData.ingredients.runtimeType}');

        // BakingCalculator로 중앙화 계산 수행
        final bakingResult = await baking_service.BakingCalculator.instance
            .calculateCentralizedBaking(
          recipeData: processedRecipeData, // ✅ 변환된 ingredients가 포함된 recipeData
          mixingState: mixingState,
          fermentationState: _fermentationState!,
          ovenSteps: initData.ovenSteps,
        );

        debugPrint(
            '🔥 [베이킹 분석] 계산 완료: ${bakingResult.overallBakingSuccess ? '성공' : '실패'}');

        // 🔧 [사용자 요청] 베이킹 성공률 낮음 경고 메시지 제거
        // 메트릭 값으로만 표시하고 오류로 처리하지 않음
        // if (!bakingResult.overallBakingSuccess) {
        //   final lastStepProgress = bakingResult.stepResults.isNotEmpty
        //       ? bakingResult.stepResults.last.bakingProgress
        //       : 0.0;
        //   _error = '베이킹 성공률이 ${lastStepProgress.toStringAsFixed(1)}%로 낮습니다. '
        //       '환경 조건이나 레시피를 조정해보세요.';
        //   debugPrint('⚠️ [베이킹 분석] 실패 피드백 설정: $_error');
        // }

        // 결과 저장
        baking_service.BakingCalculator.setLastBakingResult(bakingResult);
        debugPrint('🔥 [베이킹 분석] 결과 저장 완료');
        debugPrint(
            '   - stepResults.length: ${bakingResult.stepResults.length}');

        // UI 데이터로 변환
        debugPrint('🔥 [베이킹 분석] UI 데이터 변환 시작');
        _stepAnalyses = bakingResult.stepResults.map((stepResult) {
          debugPrint('🔥 [베이킹 분석] stepResult ${stepResult.stepNumber} 변환:');
          debugPrint(
              '   - bakingProgress: ${stepResult.bakingProgress.toStringAsFixed(1)}');
          debugPrint(
              '   - maillardReaction: ${stepResult.maillardReaction.toStringAsFixed(1)}');
          debugPrint(
              '   - crumbBakingProgress: ${stepResult.crumbBakingProgress.toStringAsFixed(1)}');
          debugPrint(
              '   - crustColorValue: ${stepResult.crustColorValue.toStringAsFixed(1)}');

          // 오븐 단계 정보 찾기
          final stepIndex = stepResult.stepNumber - 1;
          final ovenStep = initData.ovenSteps.length > stepIndex
              ? initData.ovenSteps[stepIndex]
              : {'time': 30, 'targetTemperature': 180.0};

          final analysis = BakingStepAnalysis(
            stepNumber: stepResult.stepNumber,
            ovenTemperature:
                (ovenStep['targetTemperature'] as num?)?.toDouble() ??
                    180.0, // 실제 오븐 온도
            bakingProgress: stepResult.bakingProgress,
            maillardReaction: stepResult.maillardReaction,
            crumbBakingProgress: stepResult.crumbBakingProgress,
            internalTemperature: stepResult.internalTemperature,
            moistureLoss: stepResult.moistureLoss,
            time: Duration(minutes: (ovenStep['time'] as num?)?.toInt() ?? 30),
            cumulativeBakingProgress: stepResult.cumulativeBakingProgress,
            cumulativeMaillardReaction: stepResult.cumulativeMaillardReaction,
            cumulativeCrumbBakingProgress:
                stepResult.cumulativeCrumbBakingProgress,
            cumulativeInternalTemperature:
                stepResult.cumulativeInternalTemperature,
          );
          debugPrint(
              '   - BakingStepAnalysis 생성 완료: stepNumber=${analysis.stepNumber}');
          return analysis;
        }).toList();

        // 최종 결과 저장
        _analysisResult = bakingResult;
        debugPrint('🔥 [베이킹 분석] UI 데이터 변환 완료');
        debugPrint('   - _stepAnalyses.length: ${_stepAnalyses.length}');

        debugPrint('🔥 [베이킹 분석] 완료: ${_stepAnalyses.length}단계 분석됨');
        debugPrint('   - notifyListeners 호출 전 _error 상태: $_error');
        debugPrint(
            '📢 [notifyListeners 호출] 분석 완료 후 - 호출 위치: ${StackTrace.current}');
        _isAnalyzing = false;
        debugPrint('   - notifyListeners 호출 완료');
        notifyListeners();
        debugPrint(
            '   - notifyListeners 호출 후 컨트롤러 상태: isAnalyzing=${_isAnalyzing}, error=${_error}');
        return; // 성공 시 종료
      } catch (e, stackTrace) {
        retryCount++;
        debugPrint('🔥 [베이킹 분석] 오류 발생 (${retryCount}/${maxRetries + 1}): $e');

        if (retryCount <= maxRetries) {
          // 재시도 전 잠시 대기
          await Future.delayed(const Duration(milliseconds: 500));
          debugPrint('🔄 [베이킹 분석] 재시도 준비 중...');
          continue;
        } else {
          // 최대 재시도 횟수 초과
          debugPrint('❌ [베이킹 분석] 최대 재시도 횟수 초과, 분석 실패');
          _error = '분석 실패 (재시도 후에도 해결되지 않음): $e';
          _isAnalyzing = false;
          notifyListeners();

          // 실패 시에도 최근 분석 시간 기록 (반복 호출 방지)
          _lastAnalysisStartTime = now;
          return;
        }
      }
    }
  }

  /// ✅ [Fix 무한 루프] 단일 notifyListeners() 호출로 Bulk 데이터 설정
  /// fermentationState가 null인 경우 기본값 생성 없이 단일 상태 변경 방지
  void bulkSetData({
    Map<String, dynamic>? recipeData,
    UserEnvironment? environment,
    Map<String, dynamic>? mixingResult,
    FermentationState? fermentationState,
  }) {
    // ✅ [중요] fermentationState가 null일 때는 기본값 생성하지 않음
    // BakingAnalysisCard가 fermentationState를 제공하기 전까지는 null 유지
    _recipeData = recipeData;
    _environment = environment;
    if (mixingResult != null) _mixingResult = mixingResult;
    // fermentationState는 명시적으로 null이 제공되지 않은 경우에만 설정
    if (fermentationState != null) {
      _fermentationState = fermentationState;
    }
    // 🍞 [중앙화] 단일 notifyListeners()만 호출 - 무한 루프 방지
    notifyListeners();
  }

  /// 컨트롤러 초기화
  void reset() {
    _mixingResult = null;
    _fermentationState = null;
    _lastAnalysisStartTime = null; // 분석 시간 초기화
    _analysisResult = null;
    _stepAnalyses = [];
    _isAnalyzing = false;
    _error = null;
    notifyListeners();
  }
}
