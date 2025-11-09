import 'package:my_recipe_book/models/analysis_metadata.dart';
import 'package:my_recipe_book/models/analysis_status.dart';

class AnalysisResult {
  /// 분석 요청 ID
  final String requestId;

  /// 분석 결과 데이터 (모듈별 결과)
  final Map<String, dynamic> results;

  /// 추천 사항 목록
  final List<Recommendation> recommendations;

  /// 분석 메타데이터
  final AnalysisMetadata metadata;

  /// 전체 분석 점수 (0-100)
  final double overallScore;

  /// 분석 상태
  final AnalysisStatus status;

  /// 오류 메시지 (실패 시)
  final String? errorMessage;

  /// 경고 메시지 목록
  final List<String> warnings;

  /// 분석 완료 시간
  final DateTime completedAt;

  /// 캐시에서 가져온 결과인지 여부
  final bool fromCache;

  /// 실패한 모듈 목록
  final List<String> failedModules;

  /// 성공한 모듈 목록
  final List<String> successfulModules;

  const AnalysisResult({
    required this.requestId,
    required this.results,
    required this.recommendations,
    required this.metadata,
    required this.overallScore,
    required this.status,
    this.errorMessage,
    this.warnings = const [],
    required this.completedAt,
    this.fromCache = false,
    this.failedModules = const [],
    this.successfulModules = const [],
  });

  /// 성공적인 분석 결과 생성
  factory AnalysisResult.success({
    required String requestId,
    required Map<String, dynamic> results,
    required List<Recommendation> recommendations,
    required AnalysisMetadata metadata,
    required double overallScore,
    List<String> warnings = const [],
    bool fromCache = false,
    List<String> successfulModules = const [],
  }) {
    return AnalysisResult(
      requestId: requestId,
      results: results,
      recommendations: recommendations,
      metadata: metadata,
      overallScore: overallScore,
      status: AnalysisStatus.completed,
      warnings: warnings,
      completedAt: DateTime.now(),
      fromCache: fromCache,
      successfulModules: successfulModules,
    );
  }

  /// 실패한 분석 결과 생성
  factory AnalysisResult.failure({
    required String requestId,
    required String errorMessage,
    required AnalysisMetadata metadata,
    Map<String, dynamic> partialResults = const {},
    List<String> warnings = const [],
    List<String> failedModules = const [],
    List<String> successfulModules = const [],
  }) {
    return AnalysisResult(
      requestId: requestId,
      results: partialResults,
      recommendations: [],
      metadata: metadata,
      overallScore: 0.0,
      status: AnalysisStatus.failed,
      errorMessage: errorMessage,
      warnings: warnings,
      completedAt: DateTime.now(),
      failedModules: failedModules,
      successfulModules: successfulModules,
    );
  }

  /// 부분 성공 분석 결과 생성
  factory AnalysisResult.partialSuccess({
    required String requestId,
    required Map<String, dynamic> results,
    required List<Recommendation> recommendations,
    required AnalysisMetadata metadata,
    required double overallScore,
    required List<String> warnings,
    bool fromCache = false,
    List<String> failedModules = const [],
    List<String> successfulModules = const [],
  }) {
    return AnalysisResult(
      requestId: requestId,
      results: results,
      recommendations: recommendations,
      metadata: metadata,
      overallScore: overallScore,
      status: AnalysisStatus.partiallyCompleted,
      warnings: warnings,
      completedAt: DateTime.now(),
      fromCache: fromCache,
      failedModules: failedModules,
      successfulModules: successfulModules,
    );
  }

  /// 부분 실패 분석 결과 생성
  factory AnalysisResult.partialFailure({
    required String requestId,
    required String failedModule,
    required String error,
    Map<String, dynamic> partialResults = const {},
    List<Recommendation> recommendations = const [],
    AnalysisMetadata? metadata,
  }) {
    return AnalysisResult(
      requestId: requestId,
      results: partialResults,
      recommendations: recommendations,
      metadata: metadata ?? AnalysisMetadata.empty(requestId),
      overallScore: partialResults.isNotEmpty ? 50.0 : 0.0,
      status: AnalysisStatus.partiallyCompleted,
      errorMessage: 'Module $failedModule failed: $error',
      warnings: ['일부 분석 모듈에서 오류가 발생했습니다.'],
      completedAt: DateTime.now(),
      failedModules: [failedModule],
      successfulModules: partialResults.keys.toList(),
    );
  }

  /// 특정 모듈의 결과 가져오기
  T? getModuleResult<T>(String moduleName) {
    final result = results[moduleName];
    return result is T ? result : null;
  }

  /// 모듈 결과 존재 여부 확인
  bool hasModuleResult(String moduleName) {
    return results.containsKey(moduleName);
  }

  /// 성공 여부 확인
  bool get isSuccess => status == AnalysisStatus.completed;

  /// 실패 여부 확인
  bool get isFailure => status == AnalysisStatus.failed;

  /// 부분 성공 여부 확인
  bool get isPartialSuccess => status == AnalysisStatus.partiallyCompleted;

  /// 경고 존재 여부 확인
  bool get hasWarnings => warnings.isNotEmpty;

  /// 오류 존재 여부 확인
  bool get hasErrors => errorMessage != null || failedModules.isNotEmpty;

  /// 완전 성공 여부 확인 (경고 없음)
  bool get isCompleteSuccess => isSuccess && !hasWarnings && !hasErrors;

  /// 성공률 계산 (0-1)
  double get successRate {
    final totalModules = successfulModules.length + failedModules.length;
    if (totalModules == 0) return 0.0;
    return successfulModules.length / totalModules;
  }

  /// 높은 우선순위 추천 사항 가져오기
  List<Recommendation> getHighPriorityRecommendations() {
    return recommendations
        .where((r) => r.priority == RecommendationPriority.high)
        .toList();
  }

  /// 특정 카테고리의 추천 사항 가져오기
  List<Recommendation> getRecommendationsByCategory(String category) {
    return recommendations.where((r) => r.category == category).toList();
  }

  /// 특정 신뢰도 이상의 추천 사항 가져오기
  List<Recommendation> getRecommendationsByConfidence(double minConfidence) {
    return recommendations.where((r) => r.confidence >= minConfidence).toList();
  }

  /// 구현하기 쉬운 추천 사항 가져오기 (난이도 3 이하)
  List<Recommendation> getEasyRecommendations() {
    return recommendations
        .where((r) => r.implementationDifficulty <= 3)
        .toList();
  }

  /// 분석 결과 복사 (수정용)
  AnalysisResult copyWith({
    String? requestId,
    Map<String, dynamic>? results,
    List<Recommendation>? recommendations,
    AnalysisMetadata? metadata,
    double? overallScore,
    AnalysisStatus? status,
    String? errorMessage,
    List<String>? warnings,
    DateTime? completedAt,
    bool? fromCache,
    List<String>? failedModules,
    List<String>? successfulModules,
  }) {
    return AnalysisResult(
      requestId: requestId ?? this.requestId,
      results: results ?? this.results,
      recommendations: recommendations ?? this.recommendations,
      metadata: metadata ?? this.metadata,
      overallScore: overallScore ?? this.overallScore,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      warnings: warnings ?? this.warnings,
      completedAt: completedAt ?? this.completedAt,
      fromCache: fromCache ?? this.fromCache,
      failedModules: failedModules ?? this.failedModules,
      successfulModules: successfulModules ?? this.successfulModules,
    );
  }

  /// 결과 요약 생성
  AnalysisResultSummary getSummary() {
    return AnalysisResultSummary(
      requestId: requestId,
      status: status,
      overallScore: overallScore,
      moduleCount: results.length,
      recommendationCount: recommendations.length,
      warningCount: warnings.length,
      processingTime: metadata.processingTime,
      fromCache: fromCache,
      successRate: successRate,
    );
  }

  /// 상세 리포트 생성
  String generateDetailedReport() {
    final buffer = StringBuffer();

    buffer.writeln('=== 분석 결과 리포트 ===');
    buffer.writeln('요청 ID: $requestId');
    buffer.writeln('상태: ${status.displayName}');
    buffer.writeln('전체 점수: ${overallScore.toStringAsFixed(1)}/100');
    buffer.writeln('처리 시간: ${metadata.processingTime}ms');
    buffer.writeln('캐시 사용: ${fromCache ? "예" : "아니오"}');
    buffer.writeln('성공률: ${(successRate * 100).toStringAsFixed(1)}%');
    buffer.writeln();

    if (successfulModules.isNotEmpty) {
      buffer.writeln('성공한 모듈 (${successfulModules.length}개):');
      for (final module in successfulModules) {
        buffer.writeln('  ✓ $module');
      }
      buffer.writeln();
    }

    if (failedModules.isNotEmpty) {
      buffer.writeln('실패한 모듈 (${failedModules.length}개):');
      for (final module in failedModules) {
        buffer.writeln('  ✗ $module');
      }
      buffer.writeln();
    }

    if (warnings.isNotEmpty) {
      buffer.writeln('경고 (${warnings.length}개):');
      for (final warning in warnings) {
        buffer.writeln('  ⚠ $warning');
      }
      buffer.writeln();
    }

    if (recommendations.isNotEmpty) {
      buffer.writeln('추천 사항 (${recommendations.length}개):');
      final highPriority = getHighPriorityRecommendations();
      if (highPriority.isNotEmpty) {
        buffer.writeln('  높은 우선순위:');
        for (final rec in highPriority) {
          buffer.writeln('    • ${rec.title}');
        }
      }

      final mediumPriority = recommendations
          .where((r) => r.priority == RecommendationPriority.medium)
          .toList();
      if (mediumPriority.isNotEmpty) {
        buffer.writeln('  보통 우선순위:');
        for (final rec in mediumPriority) {
          buffer.writeln('    • ${rec.title}');
        }
      }
    }

    if (errorMessage != null) {
      buffer.writeln('오류 메시지:');
      buffer.writeln('  $errorMessage');
    }

    return buffer.toString();
  }

  /// JSON으로 직렬화
  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'results': results,
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
      'metadata': metadata.toJson(),
      'overallScore': overallScore,
      'status': status.name,
      'errorMessage': errorMessage,
      'warnings': warnings,
      'completedAt': completedAt.toIso8601String(),
      'fromCache': fromCache,
      'failedModules': failedModules,
      'successfulModules': successfulModules,
    };
  }

  /// JSON에서 역직렬화
  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      requestId: json['requestId'] as String,
      results: json['results'] as Map<String, dynamic>,
      recommendations: (json['recommendations'] as List)
          .map((r) => Recommendation.fromJson(r as Map<String, dynamic>))
          .toList(),
      metadata:
          AnalysisMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
      overallScore: (json['overallScore'] as num).toDouble(),
      status: AnalysisStatus.values.firstWhere((s) => s.name == json['status'],
          orElse: () => AnalysisStatus.failed),
      errorMessage: json['errorMessage'] as String?,
      warnings: List<String>.from(json['warnings'] ?? []),
      completedAt: DateTime.parse(json['completedAt'] as String),
      fromCache: json['fromCache'] as bool? ?? false,
      failedModules: List<String>.from(json['failedModules'] ?? []),
      successfulModules: List<String>.from(json['successfulModules'] ?? []),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AnalysisResult &&
        other.requestId == requestId &&
        other.status == status &&
        other.overallScore == overallScore;
  }

  @override
  int get hashCode {
    return Object.hash(requestId, status, overallScore);
  }

  @override
  String toString() {
    return 'AnalysisResult('
        'requestId: $requestId, '
        'status: ${status.displayName}, '
        'score: ${overallScore.toStringAsFixed(1)}, '
        'modules: ${results.length}, '
        'recommendations: ${recommendations.length}, '
        'fromCache: $fromCache'
        ')';
  }
}

/// 추천 사항 모델
class Recommendation {
  /// 추천 ID
  final String id;

  /// 추천 제목
  final String title;

  /// 추천 설명
  final String description;

  /// 추천 카테고리
  final String category;

  /// 우선순위
  final RecommendationPriority priority;

  /// 신뢰도 (0-1)
  final double confidence;

  /// 예상 개선 효과
  final String? expectedImprovement;

  /// 구현 난이도 (1-5)
  final int implementationDifficulty;

  /// 관련 데이터
  final Map<String, dynamic> data;

  /// 추천 타입
  final RecommendationType type;

  /// 적용 가능 여부
  final bool isApplicable;

  const Recommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.confidence,
    this.expectedImprovement,
    this.implementationDifficulty = 3,
    this.data = const {},
    this.type = RecommendationType.general,
    this.isApplicable = true,
  });

  /// 팩토리 생성자: 간단한 추천 생성
  factory Recommendation.simple({
    required String title,
    required String description,
    required String category,
    RecommendationPriority priority = RecommendationPriority.medium,
    double confidence = 0.8,
  }) {
    return Recommendation(
      id: _generateId(),
      title: title,
      description: description,
      category: category,
      priority: priority,
      confidence: confidence,
    );
  }

  /// 고유 ID 생성
  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'rec_$timestamp';
  }

  /// 높은 신뢰도 추천인지 확인
  bool get isHighConfidence => confidence >= 0.8;

  /// 쉬운 구현인지 확인
  bool get isEasyToImplement => implementationDifficulty <= 2;

  /// 중요한 추천인지 확인
  bool get isImportant =>
      priority == RecommendationPriority.high && isHighConfidence;

  /// JSON으로 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority.name,
      'confidence': confidence,
      'expectedImprovement': expectedImprovement,
      'implementationDifficulty': implementationDifficulty,
      'data': data,
      'type': type.name,
      'isApplicable': isApplicable,
    };
  }

  /// JSON에서 역직렬화
  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      priority: RecommendationPriority.values.firstWhere(
          (p) => p.name == json['priority'],
          orElse: () => RecommendationPriority.medium),
      confidence: (json['confidence'] as num).toDouble(),
      expectedImprovement: json['expectedImprovement'] as String?,
      implementationDifficulty: json['implementationDifficulty'] as int? ?? 3,
      data: json['data'] as Map<String, dynamic>? ?? {},
      type: RecommendationType.values.firstWhere((t) => t.name == json['type'],
          orElse: () => RecommendationType.general),
      isApplicable: json['isApplicable'] as bool? ?? true,
    );
  }

  @override
  String toString() {
    return 'Recommendation('
        'title: $title, '
        'category: $category, '
        'priority: ${priority.name}, '
        'confidence: ${(confidence * 100).toStringAsFixed(0)}%'
        ')';
  }
}

/// 추천 우선순위
enum RecommendationPriority {
  low('낮음'),
  medium('보통'),
  high('높음'),
  critical('긴급');

  const RecommendationPriority(this.displayName);

  final String displayName;
}

/// 추천 타입
enum RecommendationType {
  general('일반'),
  recipe('레시피'),
  ingredient('재료'),
  technique('기법'),
  equipment('장비'),
  timing('타이밍'),
  temperature('온도'),
  safety('안전');

  const RecommendationType(this.displayName);

  final String displayName;
}

/// 분석 결과 요약
class AnalysisResultSummary {
  final String requestId;
  final AnalysisStatus status;
  final double overallScore;
  final int moduleCount;
  final int recommendationCount;
  final int warningCount;
  final int processingTime;
  final bool fromCache;
  final double successRate;

  const AnalysisResultSummary({
    required this.requestId,
    required this.status,
    required this.overallScore,
    required this.moduleCount,
    required this.recommendationCount,
    required this.warningCount,
    required this.processingTime,
    required this.fromCache,
    required this.successRate,
  });

  /// 성능 등급 계산
  String get performanceGrade {
    if (processingTime <= 5000) return 'A'; // 5초 이내
    if (processingTime <= 15000) return 'B'; // 15초 이내
    if (processingTime <= 30000) return 'C'; // 30초 이내
    return 'D'; // 30초 초과
  }

  /// 품질 등급 계산
  String get qualityGrade {
    if (overallScore >= 90 && successRate >= 0.9) return 'A';
    if (overallScore >= 80 && successRate >= 0.8) return 'B';
    if (overallScore >= 70 && successRate >= 0.7) return 'C';
    return 'D';
  }

  @override
  String toString() {
    return 'Summary: ${status.displayName}, '
        'Score: ${overallScore.toStringAsFixed(1)}, '
        'Modules: $moduleCount, '
        'Time: ${processingTime}ms, '
        'Grade: $performanceGrade/$qualityGrade';
  }
}
