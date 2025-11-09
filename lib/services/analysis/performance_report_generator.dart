import 'package:my_recipe_book/services/analysis/analysis_metrics.dart';

/// 성능 리포트 생성기
///
/// AnalysisMetrics에서 수집된 데이터를 기반으로 성능 리포트를 생성합니다.
class PerformanceReportGenerator {
  /// 현재 수집된 메트릭을 기반으로 성능 리포트를 생성합니다.
  String generateReport() {
    final metrics = AnalysisMetrics.getAllMetrics();

    final StringBuffer report = StringBuffer();
    report.writeln('--- 분석 파이프라인 성능 리포트 ---');
    report.writeln('생성 시간: ${DateTime.now()}');
    report.writeln('');

    report.writeln('1. 요청 통계');
    report.writeln('   총 분석 요청 수: ${metrics['request_counter']}');
    report.writeln('');

    report.writeln('2. 처리 시간');
    report.writeln('   평균 처리 시간: ${metrics['average_processing_duration_ms'].toStringAsFixed(2)} ms');
    report.writeln('   최대 처리 시간: ${metrics['max_processing_duration_ms']} ms');
    report.writeln('');

    report.writeln('3. 캐시 통계');
    report.writeln('   캐시 히트율: ${(metrics['cache_hit_rate'] * 100).toStringAsFixed(2)}%');
    report.writeln('');

    report.writeln('4. 모듈별 실행 시간');
    final moduleTimes = metrics['average_module_execution_times_ms'] as Map<String, double>;
    if (moduleTimes.isEmpty) {
      report.writeln('   모듈 실행 시간 데이터 없음');
    } else {
      moduleTimes.forEach((moduleName, avgTime) {
        report.writeln('   - $moduleName: ${avgTime.toStringAsFixed(2)} ms');
      });
      // 성능 트렌드 분석 (간단한 요약)
      final sortedModules = moduleTimes.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      if (sortedModules.isNotEmpty) {
        report.writeln('   가장 오래 걸리는 모듈: ${sortedModules.first.key} (${sortedModules.first.value.toStringAsFixed(2)} ms)');
      }
    }
    report.writeln('');

    report.writeln('5. 오류 통계');
    report.writeln('   총 오류 발생 수: ${metrics['error_counter']}');
    report.writeln('');

    report.writeln('--- 리포트 종료 ---');

    return report.toString();
  }
}