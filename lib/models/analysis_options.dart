/// 분석 옵션을 정의하는 모델 클래스
///
/// 분석 파이프라인의 동작을 제어하는 다양한 옵션들을 포함합니다.
class AnalysisOptions {
  /// 활성화할 분석 모듈 목록
  final List<String> enabledModules;

  /// 분석 깊이 레벨 (1: 기본, 2: 상세, 3: 전문가)
  final int analysisDepth;

  /// 캐시 사용 여부
  final bool useCache;

  /// 병렬 처리 사용 여부
  final bool enableParallelProcessing;

  /// 최대 처리 시간 (초)
  final int maxProcessingTime;

  /// 결과 정밀도 레벨 (1: 낮음, 2: 보통, 3: 높음)
  final int precisionLevel;

  /// 추천 생성 여부
  final bool generateRecommendations;

  /// 영양 정보 분석 포함 여부
  final bool includeNutritionalAnalysis;

  /// 비용 분석 포함 여부
  final bool includeCostAnalysis;

  /// 환경 영향 분석 포함 여부
  final bool includeEnvironmentalImpact;

  /// 알레르기 정보 분석 포함 여부
  final bool includeAllergyAnalysis;

  /// 사용자 정의 분석 매개변수
  final Map<String, dynamic> customParameters;

  /// 출력 형식 (json, xml, csv 등)
  final String outputFormat;

  /// 언어 설정
  final String language;

  /// 디버그 모드 활성화 여부
  final bool debugMode;

  /// 타임아웃 허용 여부
  final bool allowTimeout;

  /// 부분 결과 허용 여부
  final bool allowPartialResults;

  const AnalysisOptions({
    this.enabledModules = const [],
    this.analysisDepth = 2,
    this.useCache = true,
    this.enableParallelProcessing = true,
    this.maxProcessingTime = 30,
    this.precisionLevel = 2,
    this.generateRecommendations = true,
    this.includeNutritionalAnalysis = true,
    this.includeCostAnalysis = false,
    this.includeEnvironmentalImpact = false,
    this.includeAllergyAnalysis = true,
    this.customParameters = const {},
    this.outputFormat = 'json',
    this.language = 'ko',
    this.debugMode = false,
    this.allowTimeout = true,
    this.allowPartialResults = true,
  });

  /// 기본 옵션 생성
  factory AnalysisOptions.defaultOptions() {
    return const AnalysisOptions(
      enabledModules: [
        'recipe_analysis',
        'ingredient_analysis',
        'environment_analysis',
        'nutritional_analysis',
      ],
    );
  }

  /// 빠른 분석용 옵션
  factory AnalysisOptions.quickAnalysis() {
    return const AnalysisOptions(
      enabledModules: [
        'recipe_analysis',
        'ingredient_analysis',
      ],
      analysisDepth: 1,
      maxProcessingTime: 10,
      precisionLevel: 1,
      generateRecommendations: false,
      includeNutritionalAnalysis: false,
      enableParallelProcessing: true,
      useCache: true,
    );
  }

  /// 상세 분석용 옵션
  factory AnalysisOptions.detailedAnalysis() {
    return const AnalysisOptions(
      enabledModules: [
        'recipe_analysis',
        'ingredient_analysis',
        'environment_analysis',
        'nutritional_analysis',
        'cost_analysis',
        'allergy_analysis',
      ],
      analysisDepth: 3,
      maxProcessingTime: 60,
      precisionLevel: 3,
      generateRecommendations: true,
      includeNutritionalAnalysis: true,
      includeCostAnalysis: true,
      includeAllergyAnalysis: true,
      enableParallelProcessing: true,
      useCache: true,
    );
  }

  /// 전문가용 분석 옵션
  factory AnalysisOptions.expertAnalysis() {
    return const AnalysisOptions(
      enabledModules: [
        'recipe_analysis',
        'ingredient_analysis',
        'environment_analysis',
        'nutritional_analysis',
        'cost_analysis',
        'allergy_analysis',
        'environmental_impact_analysis',
        'texture_analysis',
        'flavor_analysis',
        'fermentation_analysis',
        'baking_science_analysis',
      ],
      analysisDepth: 3,
      maxProcessingTime: 120,
      precisionLevel: 3,
      generateRecommendations: true,
      includeNutritionalAnalysis: true,
      includeCostAnalysis: true,
      includeEnvironmentalImpact: true,
      includeAllergyAnalysis: true,
      enableParallelProcessing: true,
      useCache: true,
      debugMode: true,
    );
  }

  /// 베이킹 전용 분석 옵션
  factory AnalysisOptions.bakingFocused() {
    return const AnalysisOptions(
      enabledModules: [
        'recipe_analysis',
        'ingredient_analysis',
        'environment_analysis',
        'fermentation_analysis',
        'baking_science_analysis',
        'texture_analysis',
      ],
      analysisDepth: 3,
      maxProcessingTime: 90,
      precisionLevel: 3,
      generateRecommendations: true,
      includeNutritionalAnalysis: true,
      includeAllergyAnalysis: true,
      enableParallelProcessing: true,
      useCache: true,
    );
  }

  /// 옵션 복사본 생성
  AnalysisOptions copyWith({
    List<String>? enabledModules,
    int? analysisDepth,
    bool? useCache,
    bool? enableParallelProcessing,
    int? maxProcessingTime,
    int? precisionLevel,
    bool? generateRecommendations,
    bool? includeNutritionalAnalysis,
    bool? includeCostAnalysis,
    bool? includeEnvironmentalImpact,
    bool? includeAllergyAnalysis,
    Map<String, dynamic>? customParameters,
    String? outputFormat,
    String? language,
    bool? debugMode,
    bool? allowTimeout,
    bool? allowPartialResults,
  }) {
    return AnalysisOptions(
      enabledModules: enabledModules ?? this.enabledModules,
      analysisDepth: analysisDepth ?? this.analysisDepth,
      useCache: useCache ?? this.useCache,
      enableParallelProcessing:
          enableParallelProcessing ?? this.enableParallelProcessing,
      maxProcessingTime: maxProcessingTime ?? this.maxProcessingTime,
      precisionLevel: precisionLevel ?? this.precisionLevel,
      generateRecommendations:
          generateRecommendations ?? this.generateRecommendations,
      includeNutritionalAnalysis:
          includeNutritionalAnalysis ?? this.includeNutritionalAnalysis,
      includeCostAnalysis: includeCostAnalysis ?? this.includeCostAnalysis,
      includeEnvironmentalImpact:
          includeEnvironmentalImpact ?? this.includeEnvironmentalImpact,
      includeAllergyAnalysis:
          includeAllergyAnalysis ?? this.includeAllergyAnalysis,
      customParameters: customParameters ?? this.customParameters,
      outputFormat: outputFormat ?? this.outputFormat,
      language: language ?? this.language,
      debugMode: debugMode ?? this.debugMode,
      allowTimeout: allowTimeout ?? this.allowTimeout,
      allowPartialResults: allowPartialResults ?? this.allowPartialResults,
    );
  }

  /// 모듈 활성화
  AnalysisOptions enableModule(String moduleName) {
    final newModules = List<String>.from(enabledModules);
    if (!newModules.contains(moduleName)) {
      newModules.add(moduleName);
    }
    return copyWith(enabledModules: newModules);
  }

  /// 모듈 비활성화
  AnalysisOptions disableModule(String moduleName) {
    final newModules = List<String>.from(enabledModules);
    newModules.remove(moduleName);
    return copyWith(enabledModules: newModules);
  }

  /// 여러 모듈 활성화
  AnalysisOptions enableModules(List<String> moduleNames) {
    final newModules = List<String>.from(enabledModules);
    for (final moduleName in moduleNames) {
      if (!newModules.contains(moduleName)) {
        newModules.add(moduleName);
      }
    }
    return copyWith(enabledModules: newModules);
  }

  /// 여러 모듈 비활성화
  AnalysisOptions disableModules(List<String> moduleNames) {
    final newModules = List<String>.from(enabledModules);
    newModules.removeWhere((module) => moduleNames.contains(module));
    return copyWith(enabledModules: newModules);
  }

  /// 특정 모듈이 활성화되어 있는지 확인
  bool isModuleEnabled(String moduleName) {
    return enabledModules.contains(moduleName);
  }

  /// 사용자 정의 매개변수 추가
  AnalysisOptions addCustomParameter(String key, dynamic value) {
    final newParameters = Map<String, dynamic>.from(customParameters);
    newParameters[key] = value;
    return copyWith(customParameters: newParameters);
  }

  /// 사용자 정의 매개변수 제거
  AnalysisOptions removeCustomParameter(String key) {
    final newParameters = Map<String, dynamic>.from(customParameters);
    newParameters.remove(key);
    return copyWith(customParameters: newParameters);
  }

  /// 사용자 정의 매개변수 값 가져오기
  T? getCustomParameter<T>(String key) {
    final value = customParameters[key];
    return value is T ? value : null;
  }

  /// JSON으로 직렬화
  Map<String, dynamic> toJson() {
    return {
      'enabledModules': enabledModules,
      'analysisDepth': analysisDepth,
      'useCache': useCache,
      'enableParallelProcessing': enableParallelProcessing,
      'maxProcessingTime': maxProcessingTime,
      'precisionLevel': precisionLevel,
      'generateRecommendations': generateRecommendations,
      'includeNutritionalAnalysis': includeNutritionalAnalysis,
      'includeCostAnalysis': includeCostAnalysis,
      'includeEnvironmentalImpact': includeEnvironmentalImpact,
      'includeAllergyAnalysis': includeAllergyAnalysis,
      'customParameters': customParameters,
      'outputFormat': outputFormat,
      'language': language,
      'debugMode': debugMode,
      'allowTimeout': allowTimeout,
      'allowPartialResults': allowPartialResults,
    };
  }

  /// JSON에서 역직렬화
  factory AnalysisOptions.fromJson(Map<String, dynamic> json) {
    return AnalysisOptions(
      enabledModules: List<String>.from(json['enabledModules'] ?? []),
      analysisDepth: json['analysisDepth'] as int? ?? 2,
      useCache: json['useCache'] as bool? ?? true,
      enableParallelProcessing:
          json['enableParallelProcessing'] as bool? ?? true,
      maxProcessingTime: json['maxProcessingTime'] as int? ?? 30,
      precisionLevel: json['precisionLevel'] as int? ?? 2,
      generateRecommendations: json['generateRecommendations'] as bool? ?? true,
      includeNutritionalAnalysis:
          json['includeNutritionalAnalysis'] as bool? ?? true,
      includeCostAnalysis: json['includeCostAnalysis'] as bool? ?? false,
      includeEnvironmentalImpact:
          json['includeEnvironmentalImpact'] as bool? ?? false,
      includeAllergyAnalysis: json['includeAllergyAnalysis'] as bool? ?? true,
      customParameters: json['customParameters'] as Map<String, dynamic>? ?? {},
      outputFormat: json['outputFormat'] as String? ?? 'json',
      language: json['language'] as String? ?? 'ko',
      debugMode: json['debugMode'] as bool? ?? false,
      allowTimeout: json['allowTimeout'] as bool? ?? true,
      allowPartialResults: json['allowPartialResults'] as bool? ?? true,
    );
  }

  /// 옵션 유효성 검증
  bool isValid() {
    // 분석 깊이 범위 검증
    if (analysisDepth < 1 || analysisDepth > 3) {
      return false;
    }

    // 정밀도 레벨 범위 검증
    if (precisionLevel < 1 || precisionLevel > 3) {
      return false;
    }

    // 최대 처리 시간 검증
    if (maxProcessingTime <= 0 || maxProcessingTime > 300) {
      return false;
    }

    // 출력 형식 검증
    const validFormats = ['json', 'xml', 'csv', 'yaml'];
    if (!validFormats.contains(outputFormat.toLowerCase())) {
      return false;
    }

    // 언어 코드 검증
    const validLanguages = ['ko', 'en', 'ja', 'zh'];
    if (!validLanguages.contains(language.toLowerCase())) {
      return false;
    }

    // 모듈 목록이 비어있지 않은지 확인
    if (enabledModules.isEmpty) {
      return false;
    }

    return true;
  }

  /// 예상 처리 시간 계산 (초)
  int estimateProcessingTime() {
    int baseTime = 5; // 기본 5초

    // 모듈 수에 따른 시간 증가
    baseTime += enabledModules.length * 2;

    // 분석 깊이에 따른 시간 증가
    baseTime *= analysisDepth;

    // 정밀도 레벨에 따른 시간 증가
    baseTime = (baseTime * (precisionLevel * 0.5)).round();

    // 병렬 처리 시 시간 단축
    if (enableParallelProcessing && enabledModules.length > 1) {
      baseTime = (baseTime * 0.7).round();
    }

    // 캐시 사용 시 시간 단축 가능성
    if (useCache) {
      baseTime = (baseTime * 0.8).round();
    }

    return baseTime.clamp(1, maxProcessingTime);
  }

  /// 메모리 사용량 추정 (MB)
  int estimateMemoryUsage() {
    int baseMemory = 10; // 기본 10MB

    // 모듈 수에 따른 메모리 증가
    baseMemory += enabledModules.length * 5;

    // 분석 깊이에 따른 메모리 증가
    baseMemory *= analysisDepth;

    // 정밀도 레벨에 따른 메모리 증가
    baseMemory = (baseMemory * (precisionLevel * 0.3)).round();

    // 디버그 모드 시 추가 메모리
    if (debugMode) {
      baseMemory = (baseMemory * 1.2).round();
    }

    return baseMemory.clamp(5, 200); // 최소 5MB, 최대 200MB
  }

  /// 복잡도 점수 계산 (1-10)
  double calculateComplexityScore() {
    double score = 1.0;

    // 모듈 수에 따른 복잡도
    score += enabledModules.length * 0.3;

    // 분석 깊이에 따른 복잡도
    score += analysisDepth * 1.5;

    // 정밀도 레벨에 따른 복잡도
    score += precisionLevel * 1.0;

    // 추가 분석 옵션에 따른 복잡도
    if (includeCostAnalysis) score += 0.5;
    if (includeEnvironmentalImpact) score += 0.5;
    if (includeAllergyAnalysis) score += 0.3;
    if (generateRecommendations) score += 0.7;

    return score.clamp(1.0, 10.0);
  }

  /// 성능 등급 반환 (A, B, C, D)
  String getPerformanceGrade() {
    final complexity = calculateComplexityScore();
    final estimatedTime = estimateProcessingTime();

    if (complexity <= 3 && estimatedTime <= 10) return 'A';
    if (complexity <= 5 && estimatedTime <= 30) return 'B';
    if (complexity <= 7 && estimatedTime <= 60) return 'C';
    return 'D';
  }

  /// 옵션 요약 정보 생성
  String getSummary() {
    return 'Analysis Options: '
        '${enabledModules.length} modules, '
        'depth: $analysisDepth, '
        'precision: $precisionLevel, '
        'maxTime: ${maxProcessingTime}s, '
        'grade: ${getPerformanceGrade()}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AnalysisOptions &&
        other.enabledModules.length == enabledModules.length &&
        other.analysisDepth == analysisDepth &&
        other.useCache == useCache &&
        other.enableParallelProcessing == enableParallelProcessing &&
        other.maxProcessingTime == maxProcessingTime &&
        other.precisionLevel == precisionLevel;
  }

  @override
  int get hashCode {
    return Object.hash(
      enabledModules.length,
      analysisDepth,
      useCache,
      enableParallelProcessing,
      maxProcessingTime,
      precisionLevel,
    );
  }

  @override
  String toString() {
    return 'AnalysisOptions('
        'modules: ${enabledModules.length}, '
        'depth: $analysisDepth, '
        'precision: $precisionLevel, '
        'maxTime: ${maxProcessingTime}s, '
        'parallel: $enableParallelProcessing, '
        'cache: $useCache'
        ')';
  }
}

/// 분석 옵션 프리셋 관리 클래스
class AnalysisOptionsPresets {
  static const Map<String, AnalysisOptions> _presets = {
    'quick': AnalysisOptions(
      enabledModules: ['recipe_analysis', 'ingredient_analysis'],
      analysisDepth: 1,
      maxProcessingTime: 10,
      precisionLevel: 1,
    ),
    'standard': AnalysisOptions(
      enabledModules: [
        'recipe_analysis',
        'ingredient_analysis',
        'environment_analysis',
        'nutritional_analysis',
      ],
      analysisDepth: 2,
      maxProcessingTime: 30,
      precisionLevel: 2,
    ),
    'detailed': AnalysisOptions(
      enabledModules: [
        'recipe_analysis',
        'ingredient_analysis',
        'environment_analysis',
        'nutritional_analysis',
        'cost_analysis',
        'allergy_analysis',
      ],
      analysisDepth: 3,
      maxProcessingTime: 60,
      precisionLevel: 3,
    ),
    'baking': AnalysisOptions(
      enabledModules: [
        'recipe_analysis',
        'ingredient_analysis',
        'environment_analysis',
        'fermentation_analysis',
        'baking_science_analysis',
      ],
      analysisDepth: 3,
      maxProcessingTime: 90,
      precisionLevel: 3,
    ),
    'expert': AnalysisOptions(
      enabledModules: [
        'recipe_analysis',
        'ingredient_analysis',
        'environment_analysis',
        'nutritional_analysis',
        'cost_analysis',
        'allergy_analysis',
        'environmental_impact_analysis',
        'texture_analysis',
        'flavor_analysis',
        'fermentation_analysis',
        'baking_science_analysis',
      ],
      analysisDepth: 3,
      maxProcessingTime: 120,
      precisionLevel: 3,
      debugMode: true,
    ),
  };

  /// 프리셋 목록 반환
  static List<String> getPresetNames() {
    return _presets.keys.toList();
  }

  /// 프리셋 옵션 반환
  static AnalysisOptions? getPreset(String name) {
    return _presets[name];
  }

  /// 프리셋 존재 여부 확인
  static bool hasPreset(String name) {
    return _presets.containsKey(name);
  }

  /// 모든 프리셋 반환
  static Map<String, AnalysisOptions> getAllPresets() {
    return Map.from(_presets);
  }

  /// 프리셋 설명 반환
  static String getPresetDescription(String name) {
    switch (name) {
      case 'quick':
        return '빠른 기본 분석 (10초 이내)';
      case 'standard':
        return '표준 분석 (30초 이내)';
      case 'detailed':
        return '상세 분석 (60초 이내)';
      case 'baking':
        return '베이킹 전용 분석 (90초 이내)';
      case 'expert':
        return '전문가 수준 분석 (120초 이내)';
      default:
        return '알 수 없는 프리셋';
    }
  }
}
