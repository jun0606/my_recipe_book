// lib/modules/bread/models/integrated_mixing_analysis_types.dart
// 통합 믹싱 분석 엔진의 기반 타입 시스템
// 타입 안전성과 데이터 흐름을 최우선으로 고려

import 'dart:convert';
import '../../../../../core/types/unified_types.dart';
import '../types/bread_types.dart';

/// 반죽 타입 열거형
enum DoughType {
  /// 팡 도우 (Lean Dough) - 기본 빵 반죽
  lean,

  /// 리치 도우 (Rich Dough) - 버터, 설탕, 계란 등 풍부한 재료
  rich,

  /// 브리오슈 도우 (Brioche Dough) - 지방 함량 20% 이상의 고지방 반죽
  brioche,

  /// 특수 도우 (Specialty Dough) - 특별한 성분이나 방법
  specialty,

  /// 고단백 도우 (High Protein) - 강력분 위주
  highProtein,

  /// 저수분 도우 (Low Hydration) - 수분 함량 낮음
  lowHydration,

  /// 과수분 도우 (High Hydration) - 수분 함량 높음
  highHydration,

  /// 사워 도우 (Sourdough) - 천연 효모 사용
  sourdough,

  /// 알코올 도우 (Alcohol Dough) - 맥주, 와인 등 사용
  alcohol,

  /// 결정되지 않음
  unknown;

  /// 반죽 타입 설명
  String get description {
    switch (this) {
      case DoughType.lean:
        return '기본 빵 반죽 (물, 밀가루, 소금, 효모)';
      case DoughType.rich:
        return '풍부한 재료의 반죽 (버터, 설탕, 계란 등)';
      case DoughType.brioche:
        return '브리오슈 반죽 (지방 함량 20% 이상의 고지방 반죽)';
      case DoughType.specialty:
        return '특별한 성분이나 방법을 사용하는 반죽';
      case DoughType.highProtein:
        return '강력분 위주의 고단백 반죽';
      case DoughType.lowHydration:
        return '저수분 반죽 (60% 미만)';
      case DoughType.highHydration:
        return '고수분 반죽 (75% 이상)';
      case DoughType.sourdough:
        return '천연 효모를 사용하는 사워도우';
      case DoughType.alcohol:
        return '맥주, 와인 등 알코올 성분을 사용하는 반죽';
      case DoughType.unknown:
        return '분석 필요';
    }
  }

  /// 최적 믹싱 전략
  Map<String, dynamic> get optimalMixingStrategy {
    switch (this) {
      case DoughType.lean:
        return {
          'speed_profile': [5, 4, 3], // 저속 → 중속 → 고속
          'time_minutes': [3, 8, 2], // 각 단계별 시간
          'total_time': 13,
        };
      case DoughType.rich:
        return {
          'speed_profile': [3, 6, 5],
          'time_minutes': [4, 10, 3],
          'total_time': 17,
        };
      case DoughType.brioche:
        return {
          'speed_profile': [3, 5, 4], // 버터 전: 중저속, 통합: 중속, 마무리: 저속
          'time_minutes': [5, 8, 2], // 버터 전: 5분, 통합: 8분, 마무리: 2분
          'total_time': 15,
          'phases': ['pre_butter', 'butter_integration', 'final'],
          'temperature_range': '22-24°C',
          'notes': '버터는 실온에서 준비, 지방 에멀전화에 주의',
        };
      case DoughType.highProtein:
        return {
          'speed_profile': [3, 6, 5],
          'time_minutes': [5, 12, 3],
          'total_time': 20,
        };
      case DoughType.lowHydration:
        return {
          'speed_profile': [5, 5, 3],
          'time_minutes': [4, 6, 2],
          'total_time': 12,
        };
      case DoughType.highHydration:
        return {
          'speed_profile': [3, 4, 2],
          'time_minutes': [3, 12, 2],
          'total_time': 17,
        };
      default:
        return {
          'speed_profile': [5, 4, 3],
          'time_minutes': [3, 8, 2],
          'total_time': 13,
        };
    }
  }
}

/// 믹싱 단계 상태 열거형
enum MixingStageStatus {
  /// 최적 상태
  optimal,

  /// 양호한 상태
  good,

  /// 개선 필요
  needsImprovement,

  /// 심각한 문제
  critical,

  /// 분석 불가
  unknown;

  /// 상태 설명
  String get description {
    switch (this) {
      case MixingStageStatus.optimal:
        return '최적 상태 - 추가 조치 불필요';
      case MixingStageStatus.good:
        return '양호한 상태 - 약간의 개선 가능';
      case MixingStageStatus.needsImprovement:
        return '개선 필요 - 권장사항 참고';
      case MixingStageStatus.critical:
        return '심각한 문제 - 즉시 조치 필요';
      case MixingStageStatus.unknown:
        return '분석 불가 - 추가 정보 필요';
    }
  }

  /// 상태별 색상 코드
  String get colorCode {
    switch (this) {
      case MixingStageStatus.optimal:
        return '#4CAF50'; // 녹색
      case MixingStageStatus.good:
        return '#8BC34A'; // 연녹색
      case MixingStageStatus.needsImprovement:
        return '#FF9800'; // 주황색
      case MixingStageStatus.critical:
        return '#F44336'; // 빨간색
      case MixingStageStatus.unknown:
        return '#9E9E9E'; // 회색
    }
  }
}

/// 믹싱 단계 평가 결과
class MixingStageEvaluation {
  /// 단계 식별자
  final String stageId;

  /// 단계 이름
  final String stageName;

  /// 단계 순서 (1부터 시작)
  final int stageOrder;

  /// 평가 상태
  final MixingStageStatus status;

  /// 성공 확률 (0.0 ~ 1.0)
  final double successProbability;

  /// 문제점 목록
  final List<String> issues;

  /// 개선 권장사항
  final List<String> recommendations;

  /// 상세 분석 데이터
  final Map<String, dynamic> analysisData;

  /// 평가 타임스탬프
  final DateTime evaluatedAt;

  /// 생성자 - 타입 안전성 보장
  MixingStageEvaluation({
    required this.stageId,
    required this.stageName,
    required this.stageOrder,
    required this.status,
    required this.successProbability,
    required this.issues,
    required this.recommendations,
    required this.analysisData,
    required this.evaluatedAt,
  })  : assert(stageOrder > 0, 'stageOrder must be greater than 0'),
        assert(successProbability >= 0.0 && successProbability <= 1.0,
            'successProbability must be between 0.0 and 1.0'),
        assert(stageId.isNotEmpty, 'stageId cannot be empty'),
        assert(stageName.isNotEmpty, 'stageName cannot be empty');

  /// JSON에서 생성
  factory MixingStageEvaluation.fromJson(Map<String, dynamic> json) {
    return MixingStageEvaluation(
      stageId: json['stageId'] as String,
      stageName: json['stageName'] as String,
      stageOrder: json['stageOrder'] as int,
      status: MixingStageStatus.values[json['status'] as int],
      successProbability: (json['successProbability'] as num).toDouble(),
      issues: List<String>.from(json['issues'] as List),
      recommendations: List<String>.from(json['recommendations'] as List),
      analysisData: Map<String, dynamic>.from(json['analysisData'] as Map),
      evaluatedAt: DateTime.parse(json['evaluatedAt'] as String),
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'stageId': stageId,
      'stageName': stageName,
      'stageOrder': stageOrder,
      'status': status.index,
      'successProbability': successProbability,
      'issues': issues,
      'recommendations': recommendations,
      'analysisData': analysisData,
      'evaluatedAt': evaluatedAt.toIso8601String(),
    };
  }

  /// 복사본 생성 (불변성 유지)
  MixingStageEvaluation copyWith({
    String? stageId,
    String? stageName,
    int? stageOrder,
    MixingStageStatus? status,
    double? successProbability,
    List<String>? issues,
    List<String>? recommendations,
    Map<String, dynamic>? analysisData,
    DateTime? evaluatedAt,
  }) {
    return MixingStageEvaluation(
      stageId: stageId ?? this.stageId,
      stageName: stageName ?? this.stageName,
      stageOrder: stageOrder ?? this.stageOrder,
      status: status ?? this.status,
      successProbability: successProbability ?? this.successProbability,
      issues: issues ?? this.issues,
      recommendations: recommendations ?? this.recommendations,
      analysisData: analysisData ?? this.analysisData,
      evaluatedAt: evaluatedAt ?? this.evaluatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MixingStageEvaluation &&
        other.stageId == stageId &&
        other.stageName == stageName &&
        other.stageOrder == stageOrder &&
        other.status == status &&
        other.successProbability == successProbability &&
        other.issues == issues &&
        other.recommendations == recommendations &&
        other.analysisData == analysisData;
  }

  @override
  int get hashCode {
    return Object.hash(
      stageId,
      stageName,
      stageOrder,
      status,
      successProbability,
      issues,
      recommendations,
      analysisData,
    );
  }

  @override
  String toString() {
    return 'MixingStageEvaluation('
        'stageId: $stageId, '
        'stageName: $stageName, '
        'status: ${status.description}, '
        'successProbability: ${(successProbability * 100).toStringAsFixed(1)}%)';
  }
}

/// 믹싱 분석 입력 데이터
class MixingAnalysisInput {
  /// 사용자 데이터
  final BreadUserData userData;

  /// 레시피 데이터
  final UnifiedRecipe recipe;

  /// 분석 요청 타임스탬프
  final DateTime requestedAt;

  /// 추가 환경 파라미터 (선택사항)
  final Map<String, dynamic>? additionalParameters;

  /// 생성자 - 타입 안전성 보장
  MixingAnalysisInput({
    required this.userData,
    required this.recipe,
    required this.requestedAt,
    this.additionalParameters,
  })  : assert(userData.userId.isNotEmpty, 'userId cannot be empty'),
        assert(recipe.title.isNotEmpty, 'recipe title cannot be empty');

  /// JSON에서 생성
  factory MixingAnalysisInput.fromJson(Map<String, dynamic> json) {
    return MixingAnalysisInput(
      userData:
          BreadUserData.fromJson(json['userData'] as Map<String, dynamic>),
      recipe: UnifiedRecipe.fromJson(json['recipe'] as Map<String, dynamic>),
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      additionalParameters: json['additionalParameters'] != null
          ? Map<String, dynamic>.from(json['additionalParameters'] as Map)
          : null,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'userData': userData.toJson(),
      'recipe': recipe.toJson(),
      'requestedAt': requestedAt.toIso8601String(),
      'additionalParameters': additionalParameters,
    };
  }

  /// 복사본 생성 (불변성 유지)
  MixingAnalysisInput copyWith({
    BreadUserData? userData,
    UnifiedRecipe? recipe,
    DateTime? requestedAt,
    Map<String, dynamic>? additionalParameters,
  }) {
    return MixingAnalysisInput(
      userData: userData ?? this.userData,
      recipe: recipe ?? this.recipe,
      requestedAt: requestedAt ?? this.requestedAt,
      additionalParameters: additionalParameters ?? this.additionalParameters,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MixingAnalysisInput &&
        other.userData == userData &&
        other.recipe == recipe &&
        other.additionalParameters == additionalParameters;
  }

  @override
  int get hashCode {
    return Object.hash(userData, recipe, additionalParameters);
  }

  @override
  String toString() {
    return 'MixingAnalysisInput('
        'userId: ${userData.userId}, '
        'recipe: ${recipe.title}, '
        'requestedAt: $requestedAt)';
  }
}

/// 믹싱 분석 결과
class MixingAnalysisResult {
  /// 분석 식별자
  final String analysisId;

  /// 분석 입력 데이터 (참조용)
  final MixingAnalysisInput input;

  /// 파악된 반죽 타입
  final DoughType doughType;

  /// 각 단계별 평가 결과
  final List<MixingStageEvaluation> stageEvaluations;

  /// 최종 성공 확률 (0.0 ~ 1.0)
  final double overallSuccessProbability;

  /// 최종 평가 상태
  final MixingStageStatus overallStatus;

  /// 총 믹싱 시간 (사용자가 입력한 모든 차수의 합산)
  final Duration totalMixingTime;

  /// 예상 결과 요약
  final Map<String, dynamic> predictionSummary;

  /// 분석 완료 타임스탬프
  final DateTime completedAt;

  /// 생성자 - 타입 안전성 보장
  MixingAnalysisResult({
    required this.analysisId,
    required this.input,
    required this.doughType,
    required this.stageEvaluations,
    required this.overallSuccessProbability,
    required this.overallStatus,
    required this.totalMixingTime,
    required this.predictionSummary,
    required this.completedAt,
  })  : assert(analysisId.isNotEmpty, 'analysisId cannot be empty'),
        assert(
            overallSuccessProbability >= 0.0 &&
                overallSuccessProbability <= 1.0,
            'overallSuccessProbability must be between 0.0 and 1.0'),
        assert(stageEvaluations.isNotEmpty, 'stageEvaluations cannot be empty');

  /// 성공 결과 생성 팩토리 메서드
  factory MixingAnalysisResult.success({
    required String analysisId,
    required MixingAnalysisInput input,
    required DoughType doughType,
    required List<MixingStageEvaluation> stageEvaluations,
    required double overallSuccessProbability,
    required MixingStageStatus overallStatus,
    required Duration totalMixingTime,
    required Map<String, dynamic> predictionSummary,
  }) {
    return MixingAnalysisResult(
      analysisId: analysisId,
      input: input,
      doughType: doughType,
      stageEvaluations: List<MixingStageEvaluation>.from(stageEvaluations),
      overallSuccessProbability: overallSuccessProbability,
      overallStatus: overallStatus,
      totalMixingTime: totalMixingTime,
      predictionSummary: Map<String, dynamic>.from(predictionSummary),
      completedAt: DateTime.now(),
    );
  }

  /// 에러 결과 생성 팩토리 메서드
  factory MixingAnalysisResult.error({
    required String analysisId,
    required MixingAnalysisInput input,
    required String errorMessage,
  }) {
    return MixingAnalysisResult(
      analysisId: analysisId,
      input: input,
      doughType: DoughType.unknown,
      stageEvaluations: const [],
      overallSuccessProbability: 0.0,
      overallStatus: MixingStageStatus.unknown,
      totalMixingTime: Duration.zero,
      predictionSummary: {'error': errorMessage},
      completedAt: DateTime.now(),
    );
  }

  /// JSON에서 생성
  factory MixingAnalysisResult.fromJson(Map<String, dynamic> json) {
    return MixingAnalysisResult(
      analysisId: json['analysisId'] as String,
      input:
          MixingAnalysisInput.fromJson(json['input'] as Map<String, dynamic>),
      doughType: DoughType.values[json['doughType'] as int],
      stageEvaluations: (json['stageEvaluations'] as List)
          .map((item) => MixingStageEvaluation.fromJson(item))
          .toList(),
      overallSuccessProbability:
          (json['overallSuccessProbability'] as num).toDouble(),
      overallStatus: MixingStageStatus.values[json['overallStatus'] as int],
      totalMixingTime: Duration(
        minutes:
            (json['totalMixingTime'] as Map<String, dynamic>)['minutes'] ?? 0,
        seconds:
            (json['totalMixingTime'] as Map<String, dynamic>)['seconds'] ?? 0,
      ),
      predictionSummary:
          Map<String, dynamic>.from(json['predictionSummary'] as Map),
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'analysisId': analysisId,
      'input': input.toJson(),
      'doughType': doughType.index,
      'stageEvaluations': stageEvaluations.map((e) => e.toJson()).toList(),
      'overallSuccessProbability': overallSuccessProbability,
      'overallStatus': overallStatus.index,
      'totalMixingTime': {
        'minutes': totalMixingTime.inMinutes,
        'seconds': totalMixingTime.inSeconds.remainder(60),
      },
      'predictionSummary': predictionSummary,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  /// 분석 성공 여부
  bool get isSuccessful =>
      stageEvaluations.isNotEmpty && overallSuccessProbability > 0.0;

  /// 에러 메시지 (실패 시)
  String? get errorMessage =>
      !isSuccessful ? predictionSummary['error'] as String? : null;

  /// 주요 문제점들 추출
  List<String> get allIssues {
    return stageEvaluations.expand((stage) => stage.issues).toList();
  }

  /// 모든 개선 권장사항 추출
  List<String> get allRecommendations {
    return stageEvaluations.expand((stage) => stage.recommendations).toList();
  }

  /// 단계별 성공 확률 평균
  double get averageStageSuccessProbability {
    if (stageEvaluations.isEmpty) return 0.0;
    final sum = stageEvaluations.fold<double>(
        0.0, (sum, stage) => sum + stage.successProbability);
    return sum / stageEvaluations.length;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MixingAnalysisResult &&
        other.analysisId == analysisId &&
        other.input == input &&
        other.doughType == doughType &&
        other.stageEvaluations == stageEvaluations &&
        other.overallSuccessProbability == overallSuccessProbability &&
        other.overallStatus == overallStatus &&
        other.predictionSummary == predictionSummary;
  }

  @override
  int get hashCode {
    return Object.hash(
      analysisId,
      input,
      doughType,
      stageEvaluations,
      overallSuccessProbability,
      overallStatus,
      predictionSummary,
    );
  }

  @override
  String toString() {
    return 'MixingAnalysisResult('
        'analysisId: $analysisId, '
        'doughType: ${doughType.description}, '
        'overallStatus: ${overallStatus.description}, '
        'overallSuccessProbability: ${(overallSuccessProbability * 100).toStringAsFixed(1)}%, '
        'stageCount: ${stageEvaluations.length})';
  }
}

/// 통합 믹싱 분석 엔진 인터페이스
abstract class IntegratedMixingAnalyzer {
  /// 분석 실행
  Future<MixingAnalysisResult> analyze(MixingAnalysisInput input);

  /// 빠른 분석 (간단한 결과만)
  Future<MixingAnalysisResult> quickAnalyze(MixingAnalysisInput input);

  /// 분석 검증
  Future<bool> validateInput(MixingAnalysisInput input);

  /// 지원되는 반죽 타입 목록
  List<DoughType> get supportedDoughTypes;

  /// 엔진 버전
  String get version;
}

/// 믹싱 분석 팩토리 클래스
class MixingAnalysisFactory {
  /// 기본 분석 엔진 생성
  static IntegratedMixingAnalyzer createDefaultAnalyzer() {
    // 실제 구현에서는 의존성 주입을 통해 생성
    throw UnimplementedError('Default analyzer implementation needed');
  }

  /// 커스텀 분석 엔진 생성
  static IntegratedMixingAnalyzer createCustomAnalyzer({
    required List<DoughType> supportedTypes,
    required String version,
  }) {
    // 실제 구현에서는 의존성 주입을 통해 생성
    throw UnimplementedError('Custom analyzer implementation needed');
  }
}

/// 타입 검증 헬퍼 클래스
class MixingAnalysisValidator {
  /// 입력 데이터 검증
  static bool validateInput(MixingAnalysisInput input) {
    if (input.userData.userId.isEmpty) return false;
    if (input.recipe.title.isEmpty) return false;
    if (input.recipe.ingredients.isEmpty) return false;
    return true;
  }

  /// 결과 데이터 검증
  static bool validateResult(MixingAnalysisResult result) {
    if (result.analysisId.isEmpty) return false;
    if (result.stageEvaluations.isEmpty) return false;
    if (result.overallSuccessProbability < 0.0 ||
        result.overallSuccessProbability > 1.0) {
      return false;
    }
    return true;
  }

  /// 타입 안전성 검증
  static bool validateTypeSafety(dynamic object) {
    if (object is MixingAnalysisInput) {
      return validateInput(object);
    } else if (object is MixingAnalysisResult) {
      return validateResult(object);
    }
    return false;
  }
}
