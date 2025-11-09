// lib/core/models/analysis_result.dart
// 통합 분석 결과 모델 - 타입 안전성 확보 및 분석 결과 표준화

import 'dart:convert';

/// 분석 타입 열거형
enum AnalysisType {
  recipe, // 레시피 분석
  ingredient, // 재료 분석
  mixing, // 믹싱 분석
  dough, // 반죽 분석
  fermentation, // 발효 분석
  baking, // 굽기 분석
  bread, // 빵 종합 분석
  comprehensive, // 종합 분석
}

/// 분석 상태 열거형
enum AnalysisStatus {
  pending, // 분석 대기 중
  running, // 분석 진행 중
  completed, // 분석 완료
  failed, // 분석 실패
  cancelled, // 분석 취소
}

/// 분석 결과 모델 - 메인 모델
class AnalysisResult {
  final String analysisId;
  final AnalysisType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final double confidence;
  final bool isSuccessful;
  final AnalysisStatus status;
  final String? errorMessage;
  final Map<String, dynamic> metadata;

  const AnalysisResult({
    required this.analysisId,
    required this.type,
    required this.data,
    required this.timestamp,
    required this.confidence,
    required this.isSuccessful,
    this.status = AnalysisStatus.completed,
    this.errorMessage,
    this.metadata = const {},
  });

  /// 성공 케이스 팩토리
  factory AnalysisResult.success({
    required String analysisId,
    required AnalysisType type,
    required Map<String, dynamic> data,
    required DateTime timestamp,
    required double confidence,
    Map<String, dynamic> metadata = const {},
  }) {
    return AnalysisResult(
      analysisId: analysisId,
      type: type,
      data: data,
      timestamp: timestamp,
      confidence: confidence,
      isSuccessful: true,
      status: AnalysisStatus.completed,
      metadata: metadata,
    );
  }

  /// 실패 케이스 팩토리
  factory AnalysisResult.error({
    required String analysisId,
    required AnalysisType type,
    required String errorMessage,
    required DateTime timestamp,
    Map<String, dynamic> metadata = const {},
  }) {
    return AnalysisResult(
      analysisId: analysisId,
      type: type,
      data: {},
      timestamp: timestamp,
      confidence: 0.0,
      isSuccessful: false,
      status: AnalysisStatus.failed,
      errorMessage: errorMessage,
      metadata: metadata,
    );
  }

  /// 진행 중 케이스 팩토리
  factory AnalysisResult.running({
    required String analysisId,
    required AnalysisType type,
    required DateTime timestamp,
    Map<String, dynamic> metadata = const {},
  }) {
    return AnalysisResult(
      analysisId: analysisId,
      type: type,
      data: {},
      timestamp: timestamp,
      confidence: 0.0,
      isSuccessful: false,
      status: AnalysisStatus.running,
      metadata: metadata,
    );
  }

  /// Map에서 생성 (기존 코드 호환)
  factory AnalysisResult.fromMap(Map<String, dynamic> map) {
    return AnalysisResult(
      analysisId: map['analysisId'] as String? ?? '',
      type: _parseAnalysisType(map['type'] as String?),
      data: Map<String, dynamic>.from(map['data'] as Map? ?? {}),
      timestamp: DateTime.parse(
          map['timestamp'] as String? ?? DateTime.now().toIso8601String()),
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      isSuccessful: map['isSuccessful'] as bool? ?? false,
      status: _parseAnalysisStatus(map['status'] as String?),
      errorMessage: map['errorMessage'] as String?,
      metadata: Map<String, dynamic>.from(map['metadata'] as Map? ?? {}),
    );
  }

  /// Map으로 변환 (기존 코드 호환)
  Map<String, dynamic> toMap() {
    return {
      'analysisId': analysisId,
      'type': type.name,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'confidence': confidence,
      'isSuccessful': isSuccessful,
      'status': status.name,
      'errorMessage': errorMessage,
      'metadata': metadata,
    };
  }

  /// 타입 안전한 데이터 접근
  T getData<T>(String key, {T? defaultValue}) {
    final value = data[key];
    if (value is T) {
      return value;
    }
    if (defaultValue != null) {
      return defaultValue;
    }
    throw TypeError();
  }

  /// 안전한 데이터 접근 (nullable)
  T? getDataOrNull<T>(String key) {
    final value = data[key];
    return value is T ? value : null;
  }

  /// 데이터 존재 여부 확인
  bool hasData(String key) {
    return data.containsKey(key);
  }

  /// 결과 복사본 생성 (데이터 수정)
  AnalysisResult copyWith({
    String? analysisId,
    AnalysisType? type,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    double? confidence,
    bool? isSuccessful,
    AnalysisStatus? status,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) {
    return AnalysisResult(
      analysisId: analysisId ?? this.analysisId,
      type: type ?? this.type,
      data: data ?? Map<String, dynamic>.from(this.data),
      timestamp: timestamp ?? this.timestamp,
      confidence: confidence ?? this.confidence,
      isSuccessful: isSuccessful ?? this.isSuccessful,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata ?? Map<String, dynamic>.from(this.metadata),
    );
  }

  /// 결과 병합
  AnalysisResult merge(AnalysisResult other) {
    if (analysisId != other.analysisId) {
      throw ArgumentError('Cannot merge results with different analysis IDs');
    }

    final mergedData = Map<String, dynamic>.from(data);
    mergedData.addAll(other.data);

    return copyWith(
      data: mergedData,
      timestamp:
          timestamp.isAfter(other.timestamp) ? timestamp : other.timestamp,
      confidence: (confidence + other.confidence) / 2,
      isSuccessful: isSuccessful && other.isSuccessful,
      status: _mergeStatus(status, other.status),
    );
  }

  /// JSON 직렬화 지원
  String toJson() => jsonEncode(toMap());

  /// JSON 역직렬화 지원
  factory AnalysisResult.fromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return AnalysisResult.fromMap(map);
  }

  static AnalysisType _parseAnalysisType(String? type) {
    if (type == null) return AnalysisType.comprehensive;

    return AnalysisType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => AnalysisType.comprehensive,
    );
  }

  static AnalysisStatus _parseAnalysisStatus(String? status) {
    if (status == null) return AnalysisStatus.completed;

    return AnalysisStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => AnalysisStatus.completed,
    );
  }

  static AnalysisStatus _mergeStatus(
      AnalysisStatus status1, AnalysisStatus status2) {
    // 더 나중 상태를 우선
    const statusOrder = {
      AnalysisStatus.pending: 0,
      AnalysisStatus.running: 1,
      AnalysisStatus.completed: 2,
      AnalysisStatus.cancelled: 3,
      AnalysisStatus.failed: 4,
    };

    final order1 = statusOrder[status1] ?? 0;
    final order2 = statusOrder[status2] ?? 0;

    return order1 >= order2 ? status1 : status2;
  }
}

/// 분석 입력 모델
class AnalysisInput {
  final String recipeId;
  final Map<String, dynamic> recipeData;
  final Map<String, dynamic> environmentData;
  final Map<String, dynamic> userPreferences;
  final Map<String, dynamic> analysisOptions;

  const AnalysisInput({
    required this.recipeId,
    required this.recipeData,
    required this.environmentData,
    required this.userPreferences,
    this.analysisOptions = const {},
  });

  /// 캐시 키 생성
  String get cacheKey {
    final keyData = {
      'recipeId': recipeId,
      'recipeHash': recipeData.hashCode,
      'envHash': environmentData.hashCode,
      'prefHash': userPreferences.hashCode,
      'optionsHash': analysisOptions.hashCode,
    };
    return keyData.toString();
  }

  /// 입력 유효성 검증
  bool get isValid {
    return recipeId.isNotEmpty &&
        recipeData.isNotEmpty &&
        environmentData.isNotEmpty;
  }

  /// Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'recipeData': recipeData,
      'environmentData': environmentData,
      'userPreferences': userPreferences,
      'analysisOptions': analysisOptions,
    };
  }

  /// Map에서 생성
  factory AnalysisInput.fromMap(Map<String, dynamic> map) {
    return AnalysisInput(
      recipeId: map['recipeId'] as String? ?? '',
      recipeData: Map<String, dynamic>.from(map['recipeData'] as Map? ?? {}),
      environmentData:
          Map<String, dynamic>.from(map['environmentData'] as Map? ?? {}),
      userPreferences:
          Map<String, dynamic>.from(map['userPreferences'] as Map? ?? {}),
      analysisOptions:
          Map<String, dynamic>.from(map['analysisOptions'] as Map? ?? {}),
    );
  }
}

/// 분석 메타데이터
class AnalysisMetadata {
  final String version;
  final String engine;
  final Duration processingTime;
  final int dataPoints;
  final Map<String, dynamic> additionalInfo;

  const AnalysisMetadata({
    required this.version,
    required this.engine,
    required this.processingTime,
    required this.dataPoints,
    this.additionalInfo = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'engine': engine,
      'processingTimeMs': processingTime.inMilliseconds,
      'dataPoints': dataPoints,
      'additionalInfo': additionalInfo,
    };
  }

  factory AnalysisMetadata.fromMap(Map<String, dynamic> map) {
    return AnalysisMetadata(
      version: map['version'] as String? ?? '1.0',
      engine: map['engine'] as String? ?? 'unknown',
      processingTime:
          Duration(milliseconds: map['processingTimeMs'] as int? ?? 0),
      dataPoints: map['dataPoints'] as int? ?? 0,
      additionalInfo:
          Map<String, dynamic>.from(map['additionalInfo'] as Map? ?? {}),
    );
  }
}
