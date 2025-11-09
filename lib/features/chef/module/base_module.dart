// lib/modules/base_module.dart
// 모듈 시스템의 기초 클래스들

import 'dart:async';
import '../../../core/types/unified_types.dart';
import '../../../core/types/environment_types.dart';
import '../ui/dynamic_analysis_tab.dart';
import 'package:flutter/material.dart';

/// Sous Chef 모듈 추상 클래스
/// 모든 베이킹 모듈의 기본 인터페이스
abstract class SousChefModule {
  final String id;
  final String displayName;
  final String description;
  final String version;
  final IconData icon;
  final Color themeColor;

  const SousChefModule({
    required this.id,
    required this.displayName,
    required this.description,
    required this.version,
    required this.icon,
    required this.themeColor,
  });

  /// 레시피 분석
  Future<AnalysisResult> analyze(UnifiedRecipe recipe);

  /// 환경 정보를 고려한 분석
  Future<AnalysisResult> analyzeWithEnvironment(
    UnifiedRecipe recipe,
    UserEnvironment environment,
  ) async {
    // 기본 구현은 일반 분석 사용
    return analyze(recipe);
  }

  /// 분석 UI 컴포넌트들 생성
  List<Widget> buildAnalysisUI(AnalysisResult result);

  /// 조언 UI 컴포넌트들 생성
  List<Widget> buildAdviceUI(AnalysisResult result);

  /// 개선 UI 컴포넌트들 생성
  List<Widget> buildImprovementUI(AnalysisResult result);

  /// 모듈 초기화
  Future<void> initialize() async {
    // 기본 구현은 아무것도 하지 않음
  }

  /// 모듈 정리
  void dispose() {
    // 기본 구현은 아무것도 하지 않음
  }

  /// 모듈 활성화 시 호출
  void onModuleActivated() {
    // 기본 구현은 아무것도 하지 않음
  }

  /// 모듈 비활성화 시 호출
  void onModuleDeactivated() {
    // 기본 구현은 아무것도 하지 않음
  }

  /// 레시피를 처리할 수 있는지 확인
  bool canHandleRecipe(UnifiedRecipe recipe) {
    // 기본적으로 모든 레시피를 처리할 수 있다고 가정
    return true;
  }

  /// 레시피 업데이트 시 호출
  void onRecipeUpdated(UnifiedRecipe recipe) {
    // 기본 구현은 아무것도 하지 않음
  }

  /// 모듈 상태 확인
  bool get isReady => true;

  /// 지원하는 레시피 타입들
  List<String> get supportedRecipeTypes => ['bread', 'dough'];

  /// 모듈 기능 정보
  ModuleCapabilities get capabilities => const ModuleCapabilities(
        supportsRealTimeAnalysis: false,
        supportsRecipeModification: false,
        supportedProcessTypes: [],
        supportedIngredientTypes: [],
      );

  /// 모듈 정보
  Map<String, dynamic> get moduleInfo => {
        'id': id,
        'displayName': displayName,
        'description': description,
        'version': version,
        'icon': icon.codePoint,
        'themeColor': themeColor.value,
        'supportedRecipeTypes': supportedRecipeTypes,
        'capabilities': capabilities.toJson(),
      };

  @override
  String toString() => '$displayName v$version';
}

/// 모듈 관리자
class ModuleManager {
  static final ModuleManager _instance = ModuleManager._internal();
  static ModuleManager get instance => _instance;

  final Map<String, SousChefModule> _modules = {};
  final Map<String, bool> _moduleStates = {};
  final StreamController<String> _moduleEventController =
      StreamController<String>.broadcast();

  ModuleManager._internal();

  /// 모듈 관리자 초기화
  static Future<void> initialize() async {
    // 모듈들은 외부에서 등록됨
    debugPrint('ModuleManager base initialization completed');
  }

  /// 모듈 등록
  void _registerModule(String moduleId, SousChefModule module) {
    _modules[moduleId] = module;
    _moduleStates[moduleId] = true;
  }

  /// 모듈 검색
  static SousChefModule? getModule(String moduleId) {
    return instance._modules[moduleId];
  }

  /// 모든 모듈 목록
  static List<SousChefModule> getAllModules() {
    return instance._modules.values.toList();
  }

  /// 활성 모듈 목록
  static List<SousChefModule> getActiveModules() {
    return instance._modules.entries
        .where((entry) => instance._moduleStates[entry.key] ?? false)
        .map((entry) => entry.value)
        .toList();
  }

  /// 모듈 활성화/비활성화
  static Future<void> setModuleState(String moduleId, bool isActive) async {
    if (instance._modules.containsKey(moduleId)) {
      instance._moduleStates[moduleId] = isActive;

      if (isActive) {
        await instance._modules[moduleId]!.initialize();
      } else {
        instance._modules[moduleId]!.dispose();
      }
    }
  }

  /// 모듈 전환
  static Future<void> switchToModule(String moduleId) async {
    if (instance._modules.containsKey(moduleId)) {
      // 모든 모듈 비활성화
      for (final entry in instance._moduleStates.entries) {
        if (entry.value) {
          await setModuleState(entry.key, false);
        }
      }

      // 지정된 모듈 활성화
      await setModuleState(moduleId, true);

      // 이벤트 발행
      instance._moduleEventController.add(moduleId);
    }
  }

  /// 레시피 업데이트 통보
  static Future<void> notifyRecipeUpdate(UnifiedRecipe recipe) async {
    // 모든 활성 모듈에 레시피 업데이트 통보
    for (final module in getActiveModules()) {
      // 모듈별로 레시피 업데이트 처리
      await module.initialize();
    }
  }

  /// 디버그 정보
  static Map<String, dynamic> getDebugInfo() {
    return {
      'totalModules': instance._modules.length,
      'activeModules': getActiveModules().length,
      'moduleStates': instance._moduleStates,
      'modules': instance._modules.keys.toList(),
    };
  }

  /// 정리
  void dispose() {
    _moduleEventController.close();
  }
}
