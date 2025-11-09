import 'package:my_recipe_book/interfaces/analysis_module.dart';
import 'package:my_recipe_book/services/analysis/recipe_analysis_module.dart';
import 'package:my_recipe_book/services/analysis/ingredient_analysis_module.dart';
import 'package:my_recipe_book/services/analysis/environment_analysis_module.dart';
import 'package:my_recipe_book/services/analysis/nutritional_analysis_module.dart';

/// 모듈 레지스트리
///
/// 분석 모듈들을 등록하고 관리하며, 의존성을 해결하여 실행 순서를 결정합니다。
/// 이는 플러그인 아키텍처의 핵심 컴포넌트 역할을 합니다。
class ModuleRegistry {
  final Map<String, AnalysisModule> _modules = {};

  // 생성자를 수정하여 외부에서 모듈 목록을 받아 등록하도록 변경
  ModuleRegistry({List<AnalysisModule>? initialModules}) {
    if (initialModules != null) {
      for (final module in initialModules) {
        registerModule(module);
      }
    } else {
      // 기본 제공 모듈 등록 (initialModules가 제공되지 않을 경우)
      registerModule(RecipeAnalysisModule());
      registerModule(IngredientAnalysisModule());
      registerModule(EnvironmentAnalysisModule());
      registerModule(NutritionalAnalysisModule());
      // TODO: 다른 기본 모듈들도 여기에 등록
    }
  }

  /// 모듈을 레지스트리에 등록합니다.
  ///
  /// 이 메서드를 통해 새로운 분석 모듈(플러그인)을 시스템에 추가할 수 있습니다。
  /// 모듈은 AnalysisModule 인터페이스를 구현해야 합니다。
  void registerModule(AnalysisModule module) {
    if (_modules.containsKey(module.name)) {
      throw ArgumentError('모듈 ${module.name}은(는) 이미 등록되어 있습니다.');
    }
    _modules[module.name] = module;
    // 모듈 초기화 (생명주기 관리)
    module.onInitialize();
  }

  /// 이름으로 모듈을 가져옵니다。
  AnalysisModule? getModule(String name) {
    return _modules[name];
  }

  /// 등록된 모든 모듈을 가져옵니다。
  List<AnalysisModule> getAllModules() {
    return _modules.values.toList();
  }

  /// 활성화할 모듈 목록을 필터링하여 반환합니다。
  List<AnalysisModule> getEnabledModules(List<String> enabledModuleNames) {
    if (enabledModuleNames.isEmpty) {
      return getAllModules(); // 모든 모듈 활성화
    }
    return enabledModuleNames
        .map((name) => _modules[name])
        .whereType<AnalysisModule>()
        .toList();
  }

  /// 모듈들의 의존성을 해결하고 실행 순서를 결정합니다.
  /// (위상 정렬 알고리즘 사용)
  List<AnalysisModule> resolveExecutionOrder(List<AnalysisModule> modules) {
    final List<AnalysisModule> sortedModules = [];
    final Map<AnalysisModule, int> inDegree = {};
    final Map<AnalysisModule, List<AnalysisModule>> adj = {};

    // 그래프 초기화
    for (final module in modules) {
      inDegree[module] = 0;
      adj[module] = [];
    }

    // 의존성 그래프 구축
    for (final module in modules) {
      for (final depName in module.dependencies) {
        final dependency = _modules[depName];
        if (dependency != null && modules.contains(dependency)) {
          adj[dependency]!.add(module);
          inDegree[module] = (inDegree[module] ?? 0) + 1;
        } else if (dependency == null) {
          // 등록되지 않은 의존성 처리 (경고 또는 오류)
          print('경고: 모듈 ${module.name}의 의존성 ${depName}이(가) 등록되지 않았습니다.');
        }
      }
    }

    // 진입 차수가 0인 노드들을 큐에 추가
    final List<AnalysisModule> queue = [];
    for (final module in modules) {
      if (inDegree[module] == 0) {
        queue.add(module);
      }
    }

    // 위상 정렬 실행
    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      sortedModules.add(current);

      for (final neighbor in adj[current]!) {
        inDegree[neighbor] = (inDegree[neighbor] ?? 0) - 1;
        if (inDegree[neighbor] == 0) {
          queue.add(neighbor);
        }
      }
    }

    // 순환 의존성 검사
    if (sortedModules.length != modules.length) {
      throw StateError('순환 의존성이 감지되었거나 일부 모듈이 누락되었습니다.');
    }

    // 우선순위가 높은 모듈을 먼저 실행하도록 정렬 (동일 의존성 레벨 내에서)
    sortedModules.sort((a, b) => a.priority.compareTo(b.priority));

    return sortedModules;
  }

  /// 레지스트리에 등록된 모든 모듈을 정리합니다。
  void disposeAllModules() {
    for (final module in _modules.values) {
      module.onDispose();
    }
    _modules.clear();
  }
}