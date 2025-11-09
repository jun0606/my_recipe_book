/// 발효 분석 타입 정의
/// FermentationAnalysisCard와 FermentationStepCardEnhanced에서 사용하는 타입들

import '../../../../services/ingredient_analyzer.dart';

enum FermentationStage {
  primary(displayName: '1차 발효', description: '이스트 활성화 및 초기 발효'),
  secondary(displayName: '2차 발효', description: '글루텐 네트워킹 및 산 생성'),
  final_(displayName: '최종 발효', description: '풍미 성숙 및 최종 부피 확장');

  const FermentationStage({
    required this.displayName,
    required this.description,
  });

  final String displayName;
  final String description;
}

enum YeastActivityLevel {
  inactive(displayName: '비활성', colorCode: 0xFF9E9E9E),
  low(displayName: '저활성', colorCode: 0xFFFF9800),
  medium(displayName: '중활성', colorCode: 0xFF2196F3),
  high(displayName: '고활성', colorCode: 0xFF4CAF50),
  optimal(displayName: '최적', colorCode: 0xFF8BC34A);

  const YeastActivityLevel({
    required this.displayName,
    required this.colorCode,
  });

  final String displayName;
  final int colorCode;
}

enum VolumeExpansion {
  minimal(displayName: '최소 확장', factor: 1.0),
  moderate(displayName: '중간 확장', factor: 1.5),
  excellent(displayName: '우수 확장', factor: 2.0),
  excessive(displayName: '과도 확장', factor: 2.5);

  const VolumeExpansion({
    required this.displayName,
    required this.factor,
  });

  final String displayName;
  final double factor;
}

/// 발효 단계별 분석 결과
/// 중앙화 계산기를 통해 생성되는 단계별 분석 데이터
class FermentationStepAnalysis {
  final int stepNumber;
  final FermentationStage stage;
  final double temperature;
  final double targetHumidity;
  final Duration duration;

  // 중앙화 계산 결과 (빵 제조 과학 준수)
  final double fermentationProgress; // 발효 진행률 (0.0-1.0)
  final double yeastActivity; // 이스트 활성도 (0.0-1.0)
  final double acidity; // 산도 (pH 단위)
  final double volumeIncrease; // 부피 증가율 (%)
  final double gasProduction; // 가스 생성율 (mL/분)
  final double carbonationLevel; // 탄산화 정도 (0.0-1.0)

  // 품질 평가 메트릭
  final YeastActivityLevel yeastActivityLevel;
  final VolumeExpansion volumeExpansion;
  final String developmentNotes;

  // 누적 상태 추적용
  final double cumulativeCarbonation; // 누적 탄산화량
  final double cumulativeVolumeExpansion; // 누적 부피 확장율
  final double cumulativeCO2; // 누적 CO₂ 생산량

  // 단계별 상태 (중앙화 계산 결과 기반)
  final FermentationState? state; // 단계별 상태 추가

  // 타임스탬프
  final DateTime? analyzedAt;

  const FermentationStepAnalysis({
    required this.stepNumber,
    required this.stage,
    required this.temperature,
    required this.targetHumidity,
    required this.duration,
    required this.fermentationProgress,
    required this.yeastActivity,
    required this.acidity,
    required this.volumeIncrease,
    required this.gasProduction,
    required this.carbonationLevel,
    required this.yeastActivityLevel,
    required this.volumeExpansion,
    required this.developmentNotes,
    this.cumulativeCarbonation = 0.0,
    this.cumulativeVolumeExpansion = 0.0,
    this.cumulativeCO2 = 0.0, // cumulativeCO2 추가
    this.state,
    this.analyzedAt,
  });

  /// JSON에서 생성
  factory FermentationStepAnalysis.fromJson(Map<String, dynamic> json) {
    return FermentationStepAnalysis(
      stepNumber: json['stepNumber'] as int? ?? 1,
      stage: FermentationStage.values.firstWhere(
        (e) => e.name == json['stage'],
        orElse: () => FermentationStage.primary,
      ),
      temperature: (json['temperature'] as num?)?.toDouble() ?? 25.0,
      targetHumidity: (json['targetHumidity'] as num?)?.toDouble() ?? 70.0,
      duration: Duration(seconds: json['durationSeconds'] as int? ?? 0),
      fermentationProgress:
          (json['fermentationProgress'] as num?)?.toDouble() ?? 0.0,
      yeastActivity: (json['yeastActivity'] as num?)?.toDouble() ?? 0.0,
      acidity: (json['acidity'] as num?)?.toDouble() ?? 4.5,
      volumeIncrease: (json['volumeIncrease'] as num?)?.toDouble() ?? 0.0,
      gasProduction: (json['gasProduction'] as num?)?.toDouble() ?? 0.0,
      carbonationLevel: (json['carbonationLevel'] as num?)?.toDouble() ?? 0.0,
      yeastActivityLevel: YeastActivityLevel.values.firstWhere(
        (e) => e.name == json['yeastActivityLevel'],
        orElse: () => YeastActivityLevel.medium,
      ),
      volumeExpansion: VolumeExpansion.values.firstWhere(
        (e) => e.name == json['volumeExpansion'],
        orElse: () => VolumeExpansion.moderate,
      ),
      developmentNotes: json['developmentNotes'] as String? ?? '',
      cumulativeCarbonation:
          (json['cumulativeCarbonation'] as num?)?.toDouble() ?? 0.0,
      cumulativeVolumeExpansion:
          (json['cumulativeVolumeExpansion'] as num?)?.toDouble() ?? 0.0,
      cumulativeCO2: (json['cumulativeCO2'] as num?)?.toDouble() ??
          0.0, // cumulativeCO2 추가
      analyzedAt: json['analyzedAt'] != null
          ? DateTime.parse(json['analyzedAt'] as String)
          : null,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'stepNumber': stepNumber,
      'stage': stage.name,
      'temperature': temperature,
      'targetHumidity': targetHumidity,
      'durationSeconds': duration.inSeconds,
      'fermentationProgress': fermentationProgress,
      'yeastActivity': yeastActivity,
      'acidity': acidity,
      'volumeIncrease': volumeIncrease,
      'gasProduction': gasProduction,
      'carbonationLevel': carbonationLevel,
      'yeastActivityLevel': yeastActivityLevel.name,
      'volumeExpansion': volumeExpansion.name,
      'developmentNotes': developmentNotes,
      'cumulativeCarbonation': cumulativeCarbonation,
      'cumulativeVolumeExpansion': cumulativeVolumeExpansion,
      'cumulativeCO2': cumulativeCO2, // cumulativeCO2 추가
      'analyzedAt': analyzedAt?.toIso8601String(),
    };
  }

  /// 복사본 생성
  FermentationStepAnalysis copyWith({
    int? stepNumber,
    FermentationStage? stage,
    double? temperature,
    double? targetHumidity,
    Duration? duration,
    double? fermentationProgress,
    double? yeastActivity,
    double? acidity,
    double? volumeIncrease,
    double? gasProduction,
    double? carbonationLevel,
    YeastActivityLevel? yeastActivityLevel,
    VolumeExpansion? volumeExpansion,
    String? developmentNotes,
    double? cumulativeCarbonation,
    double? cumulativeVolumeExpansion,
    double? cumulativeCO2, // cumulativeCO2 추가
    DateTime? analyzedAt,
  }) {
    return FermentationStepAnalysis(
      stepNumber: stepNumber ?? this.stepNumber,
      stage: stage ?? this.stage,
      temperature: temperature ?? this.temperature,
      targetHumidity: targetHumidity ?? this.targetHumidity,
      duration: duration ?? this.duration,
      fermentationProgress: fermentationProgress ?? this.fermentationProgress,
      yeastActivity: yeastActivity ?? this.yeastActivity,
      acidity: acidity ?? this.acidity,
      volumeIncrease: volumeIncrease ?? this.volumeIncrease,
      gasProduction: gasProduction ?? this.gasProduction,
      carbonationLevel: carbonationLevel ?? this.carbonationLevel,
      yeastActivityLevel: yeastActivityLevel ?? this.yeastActivityLevel,
      volumeExpansion: volumeExpansion ?? this.volumeExpansion,
      developmentNotes: developmentNotes ?? this.developmentNotes,
      cumulativeCarbonation:
          cumulativeCarbonation ?? this.cumulativeCarbonation,
      cumulativeVolumeExpansion:
          cumulativeVolumeExpansion ?? this.cumulativeVolumeExpansion,
      cumulativeCO2: cumulativeCO2 ?? this.cumulativeCO2, // cumulativeCO2 추가
      analyzedAt: analyzedAt ?? this.analyzedAt,
    );
  }

  /// 품질 점수 계산 (0.0-1.0) - 산도 제거한 버전
  double getQualityScore() {
    int validMetrics = 0;

    // 이스트 활성도 체크 (0.6-1.0)
    if (yeastActivity >= 0.4 && yeastActivity <= 1.0) validMetrics++;

    // 발효 진행률 체크 (0.7-1.0)
    if (fermentationProgress >= 0.4 && fermentationProgress <= 1.0)
      validMetrics++;

    // 산도 체크 제거 (컨셉 준수)

    // 부피 증가율 체크 (50% 이상)
    if (volumeIncrease >= 50.0) validMetrics++;

    return validMetrics / 3.0; // 메트릭 수를 3으로 줄임
  }

  /// 표시용 품질 텍스트
  String getQualityLabel() {
    final score = getQualityScore();
    if (score >= 0.8) return '양호';
    if (score >= 0.6) return '보통';
    if (score >= 0.4) return '주의';
    return '관리 필요';
  }

  /// 디버그용 포맷팅
  @override
  String toString() {
    // 🛡️ NaN/Infinity 방지: 안전한 toString 표시
    final safeProgress =
        fermentationProgress.isNaN || fermentationProgress.isInfinite
            ? 0.0
            : fermentationProgress;

    // 안전한 정수 변환: round() 호출 전에 검증
    final progressPercent = safeProgress.isFinite ? safeProgress.round() : 0;

    return 'FermentationStepAnalysis(step: $stepNumber, '
        'progress: ${progressPercent}%, '
        'yeast: ${yeastActivityLevel.displayName}, '
        'acidity: ${acidity.toStringAsFixed(1)} pH, '
        'volume: ${volumeExpansion.displayName})';
  }
}

/*  /// 발효 상태 추적용 클래스
/// 단계별 누적 계산을 위한 상태 저장
class FermentationState {
  final double cumulativeCarbonation; // 누적 탄산화량 (mL)
  final double cumulativeVolumeExpansion; // 누적 부피 확장율 (%)
  final double totalAcidity; // 누적 산도 (pH)
  final double yeastViability; // 이스트 생존력 (%)
  final double fermentationProgress; // 총 발효 진행률 (0.0-1.0) - 계산기에서 사용을 위해 추가
  final FermentationStage currentStage;
  final String statusNotes;

  const FermentationState({
    required this.cumulativeCarbonation,
    required this.cumulativeVolumeExpansion,
    required this.totalAcidity,
    required this.yeastViability,
    required this.fermentationProgress,
    required this.currentStage,
    required this.statusNotes,
  });*/

/// 발효 상태 클래스 - 중앙화 계산기 호환
class FermentationState {
  final double cumulativeCO2; // 누적 CO₂ 생산량 (ml)
  final double cumulativeCarbonation; // 누적 탄산화량 (mL)
  final double cumulativeVolumeExpansion; // 누적 부피 확장율 (%)
  final double totalAcidity; // 누적 산도 (pH)
  final double yeastViability; // 이스트 생존력 (%)
  final double fermentationProgress; // 총 발효 진행률 (0.0-1.0) - 계산기에서 사용을 위해 추가
  final FermentationStage currentStage;
  final String statusNotes;

  const FermentationState({
    required this.cumulativeCO2,
    required this.cumulativeCarbonation,
    required this.cumulativeVolumeExpansion,
    required this.totalAcidity,
    required this.yeastViability,
    required this.fermentationProgress,
    required this.currentStage,
    required this.statusNotes,
  });

  /// 초기 상태 생성 (재료량 기반 동적 산도 계산)
  factory FermentationState.initial({
    List<Map<String, dynamic>>? ingredients,
    String? recipeTitle,
  }) {
    // 기본 산도 값
    double initialAcidity = 4.5; // 일반 빵의 초기 pH

    // 재료량 기반 산도 조정 (빅데이터 준수: 범위 제한 없음)
    if (ingredients != null && ingredients.isNotEmpty) {
      try {
        // 이스트량 분석
        final yeastIngredients = IngredientAnalyzer.findYeastIngredients(
          ingredients,
          recipeTitle: recipeTitle,
        );

        // 물량 분석
        final liquidIngredients = IngredientAnalyzer.findLiquidIngredients(
          ingredients,
          recipeTitle: recipeTitle,
        );

        // 밀가루량 분석 (기준량)
        final flourIngredients = IngredientAnalyzer.findFlourIngredients(
          ingredients,
          recipeTitle: recipeTitle,
        );

        // 총량 계산
        double totalYeast = 0.0;
        double totalLiquid = 0.0;
        double totalFlour = 0.0;

        for (final yeast in yeastIngredients) {
          final amount = yeast['amount'] as double? ?? 0.0;
          final unit = yeast['unit'] as String? ?? 'g';
          totalYeast += IngredientAnalyzer.convertToGrams(
              amount, unit, yeast['name'] as String? ?? '');
        }

        for (final liquid in liquidIngredients) {
          final amount = liquid['amount'] as double? ?? 0.0;
          final unit = liquid['unit'] as String? ?? 'g';
          totalLiquid += IngredientAnalyzer.convertToGrams(
              amount, unit, liquid['name'] as String? ?? '');
        }

        for (final flour in flourIngredients) {
          final amount = flour['amount'] as double? ?? 0.0;
          final unit = flour['unit'] as String? ?? 'g';
          totalFlour += IngredientAnalyzer.convertToGrams(
              amount, unit, flour['name'] as String? ?? '');
        }

        // 빵 과학적 산도 조정 계산
        if (totalFlour > 0) {
          final yeastRatio = totalYeast / totalFlour; // 이스트 비율 (%)
          final hydrationRatio = totalLiquid / totalFlour; // 수분율

          // 이스트량에 따른 산도 조정 (더 많은 이스트 = 초기 산도 낮아짐)
          double yeastAdjustment = 0.0;
          if (yeastRatio > 0.02) {
            // 2% 이상
            yeastAdjustment = -(yeastRatio - 0.02) * 50; // 2% 초과분당 0.05 pH 낮아짐
          }

          // 수분량에 따른 희석 효과 (더 많은 물 = 산도 약간 높아짐)
          double hydrationAdjustment = 0.0;
          if (hydrationRatio > 0.7) {
            // 70% 이상
            hydrationAdjustment =
                (hydrationRatio - 0.7) * 0.1; // 70% 초과분당 0.1 pH 높아짐
          }

          // 최종 산도 계산 (빅데이터 준수: 범위 제한 없음)
          initialAcidity = 4.5 + yeastAdjustment + hydrationAdjustment;

          print('🧪 [동적 초기 산도 계산]');
          print(
              '   - 이스트량: ${totalYeast.toStringAsFixed(1)}g (${(yeastRatio * 100).toStringAsFixed(2)}%)');
          print(
              '   - 수분량: ${totalLiquid.toStringAsFixed(1)}g (${(hydrationRatio * 100).toStringAsFixed(1)}%)');
          print('   - 밀가루량: ${totalFlour.toStringAsFixed(1)}g');
          print('   - 이스트 조정: ${yeastAdjustment.toStringAsFixed(3)} pH');
          print('   - 수분 조정: ${hydrationAdjustment.toStringAsFixed(3)} pH');
          print('   - 최종 초기 산도: ${initialAcidity.toStringAsFixed(2)} pH');
        }
      } catch (e) {
        print('⚠️ [동적 산도 계산 오류] 기본값 사용: $e');
        initialAcidity = 4.5; // 오류 시 기본값
      }
    }

    return FermentationState(
      cumulativeCO2: 0.0,
      cumulativeCarbonation: 0.0,
      cumulativeVolumeExpansion: 0.0,
      totalAcidity: initialAcidity,
      yeastViability: 95.0, // 신선한 이스트의 생존력
      fermentationProgress: 0.0, // 발효 시작
      currentStage: FermentationStage.primary,
      statusNotes: '발효 시작',
    );
  }

  /// JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'cumulativeCO2': cumulativeCO2, // cumulativeCO2 추가
      'cumulativeCarbonation': cumulativeCarbonation,
      'cumulativeVolumeExpansion': cumulativeVolumeExpansion,
      'totalAcidity': totalAcidity,
      'yeastViability': yeastViability,
      'currentStage': currentStage.name,
      'statusNotes': statusNotes,
    };
  }

  factory FermentationState.fromJson(Map<String, dynamic> json) {
    return FermentationState(
      cumulativeCO2: (json['cumulativeCO2'] as num?)?.toDouble() ??
          0.0, // cumulativeCO2 추가
      cumulativeCarbonation:
          (json['cumulativeCarbonation'] as num?)?.toDouble() ?? 0.0,
      cumulativeVolumeExpansion:
          (json['cumulativeVolumeExpansion'] as num?)?.toDouble() ?? 0.0,
      totalAcidity: (json['totalAcidity'] as num?)?.toDouble() ?? 0.0,
      yeastViability: (json['yeastViability'] as num?)?.toDouble() ?? 0.0,
      fermentationProgress:
          (json['fermentationProgress'] as num?)?.toDouble() ?? 0.0,
      currentStage: FermentationStage.values.firstWhere(
        (e) => e.name == json['currentStage'],
        orElse: () => FermentationStage.primary,
      ),
      statusNotes: json['statusNotes'] as String? ?? '불러온 상태',
    );
  }

  /// 복사 생성
  FermentationState copyWith({
    double? cumulativeCO2, // cumulativeCO2 추가
    double? cumulativeCarbonation,
    double? cumulativeVolumeExpansion,
    double? totalAcidity,
    double? yeastViability,
    double? fermentationProgress,
    FermentationStage? currentStage,
    String? statusNotes,
  }) {
    return FermentationState(
      cumulativeCO2: cumulativeCO2 ?? this.cumulativeCO2, // cumulativeCO2 추가
      cumulativeCarbonation:
          cumulativeCarbonation ?? this.cumulativeCarbonation,
      cumulativeVolumeExpansion:
          cumulativeVolumeExpansion ?? this.cumulativeVolumeExpansion,
      totalAcidity: totalAcidity ?? this.totalAcidity,
      yeastViability: yeastViability ?? this.yeastViability,
      fermentationProgress: fermentationProgress ?? this.fermentationProgress,
      currentStage: currentStage ?? this.currentStage,
      statusNotes: statusNotes ?? this.statusNotes,
    );
  }

  @override
  String toString() {
    return 'FermentationState(carbonation: ${cumulativeCarbonation.toStringAsFixed(1)}, '
        'volume: ${cumulativeVolumeExpansion.toStringAsFixed(1)}%, '
        'acidity: ${totalAcidity.toStringAsFixed(1)}, '
        'yeast: ${yeastViability.toStringAsFixed(1)}%)';
  }
}

/// 발효 단계 정의
class FermentationStep {
  final int stepNumber;
  final double targetTemperature;
  final double targetHumidity;
  final Duration duration;
  final FermentationStage expectedStage;
  final String stepNotes;

  const FermentationStep({
    required this.stepNumber,
    required this.targetTemperature,
    required this.targetHumidity,
    required this.duration,
    required this.expectedStage,
    required this.stepNotes,
  });

  // Core 타입과의 호환성을 위한 getter들
  int get durationHours => duration.inHours;
  double get durationMinutes => duration.inMinutes.toDouble();

  /// JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'stepNumber': stepNumber,
      'targetTemperature': targetTemperature,
      'targetHumidity': targetHumidity,
      'durationSeconds': duration.inSeconds,
      'expectedStage': expectedStage.name,
      'stepNotes': stepNotes,
    };
  }

  factory FermentationStep.fromJson(Map<String, dynamic> json) {
    return FermentationStep(
      stepNumber: json['stepNumber'] as int? ?? 1,
      targetTemperature:
          (json['targetTemperature'] as num?)?.toDouble() ?? 25.0,
      targetHumidity: (json['targetHumidity'] as num?)?.toDouble() ?? 70.0,
      duration:
          Duration(seconds: json['durationSeconds'] as int? ?? 7200), // 2시간 기본
      expectedStage: FermentationStage.values.firstWhere(
        (e) => e.name == json['expectedStage'],
        orElse: () => FermentationStage.primary,
      ),
      stepNotes: json['stepNotes'] as String? ?? '',
    );
  }

  @override
  String toString() {
    return 'FermentationStep(step: $stepNumber, temp: ${targetTemperature}°C, '
        'humidity: ${targetHumidity}%, duration: ${duration.inHours}h ${duration.inMinutes.remainder(60)}m)';
  }
}

/// 발효 분석 진행 상태
class FermentationProgress {
  final AnalysisStatus status;
  final double progress;
  final String message;
  final int? currentStep;
  final int? totalSteps;
  final DateTime? startTime;
  final DateTime? endTime;

  const FermentationProgress({
    required this.status,
    required this.progress,
    required this.message,
    this.currentStep,
    this.totalSteps,
    this.startTime,
    this.endTime,
  });

  /// 진행 중 상태 생성
  factory FermentationProgress.running({
    required int currentStep,
    required int totalSteps,
    required String message,
    DateTime? startTime,
  }) {
    final progress = totalSteps > 0 ? currentStep / totalSteps : 0.0;
    return FermentationProgress(
      status: AnalysisStatus.analyzing,
      progress: progress,
      message: message,
      currentStep: currentStep,
      totalSteps: totalSteps,
      startTime: startTime,
    );
  }

  /// 완료 상태 생성
  factory FermentationProgress.completed({
    required String message,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    return FermentationProgress(
      status: AnalysisStatus.completed,
      progress: 1.0,
      message: message,
      startTime: startTime,
      endTime: endTime,
    );
  }

  /// 오류 상태 생성
  factory FermentationProgress.error({
    required String message,
    DateTime? startTime,
  }) {
    return FermentationProgress(
      status: AnalysisStatus.error,
      progress: 0.0,
      message: message,
      startTime: startTime,
    );
  }
}

/// 중앙화 계산 결과 타입들

/// 발효 프로세스 전체 결과
class FermentationProcessResult {
  final List<FermentationStepResult> stepResults;
  final int totalElapsedTime; // 전체 소요 시간 (분)
  final double finalYeastActivity; // 최종 이스트 활성도
  final bool overallSuccess; // 전체 성공 여부

  const FermentationProcessResult({
    required this.stepResults,
    required this.totalElapsedTime,
    required this.finalYeastActivity,
    required this.overallSuccess,
  });

  Map<String, dynamic> toJson() {
    return {
      'stepResults': stepResults.map((e) => e.toJson()).toList(),
      'totalElapsedTime': totalElapsedTime,
      'finalYeastActivity': finalYeastActivity,
      'overallSuccess': overallSuccess,
    };
  }

  factory FermentationProcessResult.fromJson(Map<String, dynamic> json) {
    return FermentationProcessResult(
      stepResults: (json['stepResults'] as List<dynamic>?)
              ?.map((e) =>
                  FermentationStepResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalElapsedTime: (json['totalElapsedTime'] as num?)?.toInt() ?? 0,
      finalYeastActivity:
          (json['finalYeastActivity'] as num?)?.toDouble() ?? 0.0,
      overallSuccess: json['overallSuccess'] as bool? ?? false,
    );
  }
}

//// 단계별 계산 결과
class FermentationStepResult {
  final int stepNumber;
  final double fermentationProgress;
  final double co2Generation;
  final double volumeIncrease;
  final double yeastActivity;
  final double acidity; // 산도 (pH 단위)
  final FermentationMethod method;
  final double cumulativeCO2; // 누적 CO₂ 생산량 추가

  const FermentationStepResult({
    required this.stepNumber,
    required this.fermentationProgress,
    required this.co2Generation,
    required this.volumeIncrease,
    required this.yeastActivity,
    required this.acidity,
    required this.method,
    this.cumulativeCO2 = 0.0, // 누적 CO₂ 추가, 기본값 0.0
  });

  Map<String, dynamic> toJson() {
    return {
      'stepNumber': stepNumber,
      'fermentationProgress': fermentationProgress,
      'co2Generation': co2Generation,
      'volumeIncrease': volumeIncrease,
      'yeastActivity': yeastActivity,
      'acidity': acidity,
      'method': method.name,
      'cumulativeCO2': cumulativeCO2, // cumulativeCO2 추가
    };
  }

  factory FermentationStepResult.fromJson(Map<String, dynamic> json) {
    return FermentationStepResult(
      stepNumber: (json['stepNumber'] as num?)?.toInt() ?? 1,
      fermentationProgress:
          (json['fermentationProgress'] as num?)?.toDouble() ?? 0.0,
      co2Generation: (json['co2Generation'] as num?)?.toDouble() ?? 0.0,
      volumeIncrease: (json['volumeIncrease'] as num?)?.toDouble() ?? 0.0,
      yeastActivity: (json['yeastActivity'] as num?)?.toDouble() ?? 0.0,
      acidity: (json['acidity'] as num?)?.toDouble() ?? 4.5,
      method: FermentationMethod.values.firstWhere(
        (e) => e.name == json['method'],
        orElse: () => FermentationMethod.roomTemperature,
      ),
      cumulativeCO2: (json['cumulativeCO2'] as num?)?.toDouble() ??
          0.0, // cumulativeCO2 추가
    );
  }
}

/// 발효 방법 종류
enum FermentationMethod {
  roomTemperature(displayName: '실온 발효'),
  coldRoom(displayName: '냉장 발효'),
  warmRoom(displayName: '온장 발효'),
  sourdough(displayName: '사워도우 발효');

  const FermentationMethod({
    required this.displayName,
  });

  final String displayName;
}

// 기존 타입 정의 퇴출된 부분
enum AnalysisStatus {
  idle,
  analyzing,
  completed,
  error,
}
