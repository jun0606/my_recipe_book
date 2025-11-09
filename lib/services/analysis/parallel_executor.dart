import 'package:my_recipe_book/interfaces/analysis_module.dart';
import 'package:my_recipe_book/models/analysis_request.dart';
import 'package:my_recipe_book/models/analysis_status.dart';
import 'package:my_recipe_book/models/analysis_result.dart';
import 'package:my_recipe_book/services/analysis/module_registry.dart'; // ModuleRegistry 의존성 추가

/// 병렬 실행기
///
/// 분석 모듈들을 병렬로 실행하여 전체 분석 시간을 단축합니다.
class ParallelExecutor {
  final ModuleRegistry _moduleRegistry; // ModuleRegistry 의존성 추가

  ParallelExecutor(this._moduleRegistry); // 생성자 수정

  /// 모듈들을 병렬로 실행하고 결과를 통합합니다.
  ///
  /// 의존성 그래프를 기반으로 병렬 실행 가능한 모듈 그룹을 식별하고,
  /// 그룹 내에서는 병렬로, 그룹 간에는 순차적으로 실행합니다.
  Future<Map<String, dynamic>> executeModules(
    List<AnalysisModule> modules,
    AnalysisRequest request,
  ) async {
    final results = <String, dynamic>{};

    // ModuleRegistry를 통해 의존성 해결된 실행 순서 가져오기
    final executionOrder = _moduleRegistry.resolveExecutionOrder(modules);

    // 의존성 그래프에 따라 병렬 실행 가능한 그룹 식별
    final executionGroups = _groupModulesIntoParallelizableGroups(executionOrder);

    // 2. 그룹별 순차 실행, 그룹 내 병렬 실행
    for (final group in executionGroups) {
      final futures = group.map((module) async {
        // TODO: Task 6.2 리소스 풀 관리 - CPU 바운드 작업의 경우 Isolate 활용 고려
        // 현재는 Future.wait를 통해 비동기 I/O 바운드 작업에 효율적이지만,
        // 복잡한 계산이 필요한 CPU 바운드 모듈의 경우 메인 스레드를 블로킹할 수 있음.
        // Isolate 풀을 구현하여 모듈 분석을 별도의 Isolate에서 실행하는 방안을 검토해야 함.
        // Isolate 간 데이터 통신 비용(직렬화/역직렬화)도 고려 필요.
        if (module.canHandle(request)) {
          try {
            final moduleResult = await module.analyze(request);
            return {module.name: moduleResult};
          } on AnalysisProcessingException catch (e) {
            print('경고: 모듈 ${module.name} 처리 중 경고: ${e.message}');
            return {module.name: {'error': e.message, 'status': AnalysisStatus.partial_failure.toString()}};
          } catch (e) {
            print('오류: 모듈 ${module.name} 실행 중 예상치 못한 오류: $e');
            return {module.name: {'error': e.toString(), 'status': AnalysisStatus.failed.toString()}};
          }
        }
        return null;
      }).toList();

      final List<Map<String, dynamic>?> groupResults = await Future.wait(futures);

      for (final moduleResult in groupResults) {
        if (moduleResult != null) {
          results.addAll(moduleResult);
        }
      }
    }

    return results;
  }

  /// 의존성 해결된 모듈 목록을 병렬 실행 가능한 그룹으로 나눕니다.
  ///
  /// ModuleRegistry에서 위상 정렬된 결과를 받아,
  /// 의존성이 없는 모듈들을 같은 그룹으로 묶어 병렬 실행을 최적화합니다.
  List<List<AnalysisModule>> _groupModulesIntoParallelizableGroups(List<AnalysisModule> executionOrder) {
    final List<List<AnalysisModule>> parallelizableGroups = [];
    final Set<String> completedModules = {}; // 이미 실행된 모듈 추적

    // 실행 순서에 따라 그룹을 생성
    for (final module in executionOrder) {
      bool addedToExistingGroup = false;
      for (final group in parallelizableGroups) {
        // 현재 모듈이 이 그룹의 어떤 모듈에도 의존하지 않고,
        // 이 그룹의 어떤 모듈도 현재 모듈에 의존하지 않는다면 같은 그룹에 추가 가능
        // (간단화된 로직: 실제로는 더 복잡한 의존성 검사 필요)
        if (group.every((m) => !module.dependencies.contains(m.name) && !m.dependencies.contains(module.name))) {
          group.add(module);
          addedToExistingGroup = true;
          break;
        }
      }
      if (!addedToExistingGroup) {
        parallelizableGroups.add([module]); // 새 그룹 생성
      }
    }

    // TODO: 병목 지점 식별 로직은 이 그룹화 과정에서 추가될 수 있음.
    // 예를 들어, 단일 모듈로만 구성된 그룹이 많거나, 특정 모듈이 많은 다른 모듈의 의존성이라면 병목 가능성.

    return parallelizableGroups;
  }
}