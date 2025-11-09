// 🎯 수쉐프 v2.0 빵 모듈 - 데이터 조율자
// MixingAnalysisCard, FermentationAnalysisCard의 데이터 관리 담당
// UI 컴포넌트 빌드는 컨셉에 따라 Screen/Widget 레이어에서 담당

import 'package:flutter/material.dart';
import '../base_module.dart';
import '../../../../core/types/unified_types.dart'
    show UnifiedRecipe, AnalysisResult, ModuleCapabilities;
import '../../../../core/types/environment_types.dart';
import '../../../../core/types/calculation_types.dart';
import '../../../../services/environment_defaults_calculator.dart';
import 'types/workflow_types.dart' hide AnalysisSettings;

/// 빵 모듈 - SousChefModule 추상 클래스 상속 및 컨셉 준수 구현
/// ✅ 컨셉 준수: 데이터 관리 + UI 표시 메타데이터 제공
/// ❌ 제거: 직접 UI 빌드, 하드코딩 기본값, 위젯 임포트
class BreadModule extends SousChefModule {
  static const String _moduleId = 'bread';
  static const String _displayName = '빵 분석';
  static const IconData _icon = Icons.bakery_dining;
  static const Color _themeColor = Colors.brown;
  static const String _description = '빵 만들기 전문 분석 모듈';

  bool _isInitialized = false;

  // 수쉐프 모드 화면에서 전달받은 데이터들
  UserEnvironment? _environment;
  Map<String, dynamic>? _recipeData;
  dynamic _analysisSettings;

  // 분석 단계별 결과 저장 (빵 모듈이 UI 조율자 역할)
  Map<String, dynamic>? _mixingResult;
  Map<String, dynamic>? _fermentationState;
  Map<String, dynamic>? _bakingResult;

  // 분석 완료 상태 추적 (무한 루프 방지)
  bool _isMixingAnalysisCompleted = false;
  bool _fermentationCompleted = false;

  BreadModule()
      : super(
          id: _moduleId,
          displayName: _displayName,
          description: _description,
          version: '2.0.0',
          icon: _icon,
          themeColor: _themeColor,
        );

  @override
  bool get isReady => _isInitialized;

  @override
  Map<String, dynamic> get moduleInfo => {
        'id': id,
        'displayName': displayName,
        'description': description,
        'version': version,
        'icon': icon.codePoint,
        'themeColor': themeColor.toARGB32(),
        'supportedRecipeTypes': supportedRecipeTypes,
        'capabilities': capabilities.toJson(),
      };

  @override
  ModuleCapabilities get capabilities => const ModuleCapabilities(
        supportsRealTimeAnalysis: true,
        supportsRecipeModification: true,
        supportedProcessTypes: ['mixing', 'kneading', 'fermentation', 'baking'],
        supportedIngredientTypes: ['flour', 'yeast', 'water', 'salt'],
      );

  @override
  List<String> get supportedRecipeTypes => ['bread', 'dough', 'fermentation'];

  @override
  bool canHandleRecipe(dynamic recipe) {
    // 빵 관련 재료나 프로세스가 있는지 확인
    final hasBreadIngredients = recipe.ingredients.any((ing) =>
        ing.properties['type'] == 'flour' || ing.properties['type'] == 'yeast');

    final hasBreadProcesses = recipe.processes
        .any((proc) => capabilities.supportedProcessTypes.contains(proc.type));

    return hasBreadIngredients || hasBreadProcesses;
  }

  @override
  Future<AnalysisResult> analyze(UnifiedRecipe recipe) async {
    // 빵 모듈은 분석 로직을 가지지 않음 - UI 표시 조율만 담당
    // 실제 분석은 각 카드 컴포넌트(MixingAnalysisCard, FermentationAnalysisCard, OvenAnalysisCard)에서 수행
    return AnalysisResult.success(
      moduleId: id,
      data: {
        'module': 'bread',
        'recipeTitle': recipe.title,
        'timestamp': DateTime.now().toIso8601String(),
        'note': '분석은 각 카드 컴포넌트에서 수행됩니다',
      },
      timestamp: DateTime.now(),
      confidence: 1.0,
    );
  }

  @override
  Future<AnalysisResult> analyzeWithEnvironment(
      UnifiedRecipe recipe, dynamic environment) async {
    // 환경 정보가 있는 경우 환경 고려 분석 수행
    return await analyze(recipe);
  }

  /// ✅ 컨셉 준수: UI 컴포넌트 빌드 완전 제거
  /// 모듈은 데이터 메타데이터만 제공, UI 빌드는 Screen/Widget 레이어 책임
  @override
  List<Widget> buildAnalysisUI(dynamic result) {
    // ✅ 컨셉 준수: 모듈은 UI 빌드하지 않음
    // UI 레이어에서 getAnalysisMetadata()를 사용해 컴포넌트 빌드
    debugPrint('🎯 BreadModule: 컨셉 준수 - UI 빌드 로직 제거됨');
    return const []; // 빈 리스트 반환
  }

  /// ✅ 컨셉 준수: 조언 UI도 Screen/Widget 레이어에서 처리
  @override
  List<Widget> buildAdviceUI(dynamic result) {
    debugPrint('🎯 BreadModule: 컨셉 준수 - 조언 UI도 Screen 레벨에서 처리');
    return const [];
  }

  /// ✅ 컨셉 준수: 개선 UI도 Screen/Widget 레이어에서 처리
  @override
  List<Widget> buildImprovementUI(dynamic result) {
    debugPrint('🎯 BreadModule: 컨셉 준수 - 개선 UI도 Screen 레벨에서 처리');
    return const [];
  }

  /// 🎯 컨셉 준수: 데이터 메타데이터 제공 메소드 (UI 레이어에서 활용)
  List<Map<String, dynamic>> getAnalysisMetadata() {
    return [
      {
        'type': 'mixing',
        'status': _isMixingAnalysisCompleted ? 'completed' : 'analyzing',
        'hasData': _mixingResult != null,
        'data': _mixingResult,
        'error': null,
      },
      {
        'type': 'fermentation',
        'status': _mixingResult != null ? 'ready' : 'waiting',
        'hasData': _mixingResult != null,
        'data': _mixingResult, // 발효는 믹싱 결과 기반
        'error': null,
      },
      {
        'type': 'baking',
        'status': _isMixingAnalysisCompleted && _fermentationCompleted
            ? 'ready'
            : 'waiting',
        'hasData': _bakingResult != null,
        'data': _bakingResult,
        'error': null,
      },
    ];
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isInitialized = true;
    debugPrint('✅ BreadModule initialized - 컨셉 준수 모드');
  }

  @override
  void dispose() {
    _isInitialized = false;
    debugPrint('✅ BreadModule disposed');
    super.dispose();
  }

  /// 수쉐프 모드 화면에서 데이터 설정
  void setSousChefData({
    UserEnvironment? environment,
    Map<String, dynamic>? recipeData,
    dynamic analysisSettings,
  }) {
    _environment = environment;
    _recipeData = recipeData;
    _analysisSettings = analysisSettings;

    debugPrint(
        '📥 BreadModule data updated: env=${environment != null}, recipe=${recipeData != null}');
  }

  /// 믹싱 결과 설정 (컨트롤러 콜백에서 호출)
  void setMixingResult(Map<String, dynamic> result) {
    _mixingResult = result;
    _isMixingAnalysisCompleted = true;
    debugPrint('✅ BreadModule: 믹싱 결과 설정됨');
  }

  /// 발효 결과 설정
  void setFermentationResult(Map<String, dynamic> result) {
    _fermentationState = result;
    _fermentationCompleted = true;
    debugPrint('🍞 BreadModule: 발효 결과 설정됨');
  }

  /// 베이킹 결과 설정
  void setBakingResult(Map<String, dynamic> result) {
    _bakingResult = result;
    debugPrint('🔥 BreadModule: 베이킹 결과 설정됨');
  }

  /// 현재 분석 상태 조회
  Map<String, dynamic> getAnalysisStatus() {
    return {
      'isInitialized': _isInitialized,
      'mixingCompleted': _isMixingAnalysisCompleted,
      'hasMixingResult': _mixingResult != null,
      'fermentationReady': _isMixingAnalysisCompleted && _mixingResult != null,
    };
  }

  /// 분석 데이터 초기화
  void resetAnalysis() {
    _mixingResult = null;
    _isMixingAnalysisCompleted = false;
    debugPrint('🔄 BreadModule: 분석 데이터 초기화됨');
  }

  /// 🚨 아키텍처 위반: 컨트롤러 상태 조회 메소드 (임시 추가 - 컨셉 위배)
  /// 컨셉에 따르면 Module은 UI 상태를 직접 관리하지 않아야 함
  /// 하지만 Screen 레벨에서 호환성을 위해 임시 제공
  bool get isControllerReady => _isMixingAnalysisCompleted;

  /// 🚨 아키텍처 위반: 리스너 추가 메소드 (임시 추가 - 컨셉 위배)
  /// 컨셉에 따르면 Module은 UI 이벤트 리스너를 직접 관리하지 않아야 함
  /// 이벤트 기반 통신(Event Bus)을 사용해야 함
  void addListener(Function() listener) {
    // 실제로는 EventBus를 통해 통신해야 하지만,
    // 기존 Screen 코드 호환성을 위해 임시 구현
    debugPrint('⚠️ BreadModule: addListener 호출됨 - 컨셉 위배 감지');
  }

  /// 🎯 컨셉 준수: 믹싱 결과 제공 메소드
  /// 발효 카드에서 믹싱 결과 기반으로 분석을 수행하기 위해 필요
  Map<String, dynamic> getMixingResult() {
    return _mixingResult ?? {};
  }

  /// 🎯 컨셉 준수: 믹싱 결과 getter (호환성용)
  Map<String, dynamic> get mixingResult => getMixingResult();

  /// 발효 결과 제공 메소드
  Map<String, dynamic> getFermentationState() {
    return _fermentationState ?? {};
  }

  /// 베이킹 결과 제공 메소드
  Map<String, dynamic> getBakingResult() {
    return _bakingResult ?? {};
  }
}
