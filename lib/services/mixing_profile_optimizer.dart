// lib/services/mixing_profile_optimizer.dart
// 믹싱 프로파일 최적화 알고리즘 - AI 기반 최적 믹싱 프로파일 생성

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import '../core/types/mixing_aliases.dart';
import '../core/utils/mixing_data_integration_system.dart';
import 'real_time_adaptation_engine.dart';
import 'dynamic_environment_analyzer.dart';
import 'intelligent_mixing_recommendation_system.dart';

/// 믹싱 프로파일 최적화 알고리즘
/// AI 기반으로 최적의 믹싱 프로파일을 생성하고 실시간으로 조정합니다.
class MixingProfileOptimizer {
  final StreamController<OptimizationEvent> _optimizationController =
      StreamController<OptimizationEvent>.broadcast();

  // 통합된 시스템들
  final RealTimeAdaptationEngine _adaptationEngine;
  final DynamicEnvironmentAnalyzer _environmentAnalyzer;
  final IntelligentMixingRecommendationSystem? _recommendationSystem;

  Timer? _optimizationTimer;
  final Map<String, OptimizedMixingProfile> _activeProfiles = {};
  final List<OptimizationResult> _optimizationHistory = [];

  // 최적화 파라미터
  static const Duration _optimizationInterval = Duration(minutes: 10);
  static const int _maxHistoryItems = 500;
  static const double _minConfidenceThreshold = 0.7;
  static const int _maxIterations = 50;

  /// 최적화 이벤트 스트림
  Stream<OptimizationEvent> get optimizationEvents =>
      _optimizationController.stream;

  MixingProfileOptimizer({
    required RealTimeAdaptationEngine adaptationEngine,
    required DynamicEnvironmentAnalyzer environmentAnalyzer,
    IntelligentMixingRecommendationSystem? recommendationSystem,
  })  : _adaptationEngine = adaptationEngine,
        _environmentAnalyzer = environmentAnalyzer,
        _recommendationSystem = recommendationSystem;

  /// 최적화 시스템 시작
  void startOptimizationEngine() {
    _optimizationTimer?.cancel();
    _optimizationTimer =
        Timer.periodic(_optimizationInterval, _onOptimizationTick);

    _optimizationController.add(OptimizationEvent(
      type: OptimizationEventType.engineStarted,
      message: '믹싱 프로파일 최적화 엔진 시작됨',
      timestamp: DateTime.now(),
    ));
  }

  /// 최적화 시스템 중지
  void stopOptimizationEngine() {
    _optimizationTimer?.cancel();
    _optimizationTimer = null;

    _optimizationController.add(OptimizationEvent(
      type: OptimizationEventType.engineStopped,
      message: '믹싱 프로파일 최적화 엔진 중지됨',
      timestamp: DateTime.now(),
    ));
  }

  /// 최적화 틱 - 정기적인 프로파일 최적화
  void _onOptimizationTick(Timer timer) async {
    try {
      // 현재 활성 프로파일들 최적화
      await _optimizeActiveProfiles();

      // 새로운 최적화 기회 탐색
      await _exploreOptimizationOpportunities();

      _optimizationController.add(OptimizationEvent(
        type: OptimizationEventType.optimizationCompleted,
        message: '주기적 프로파일 최적화 완료',
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _optimizationController.add(OptimizationEvent(
        type: OptimizationEventType.optimizationError,
        message: '프로파일 최적화 오류: $e',
        data: {'error': e.toString()},
        timestamp: DateTime.now(),
      ));
    }
  }

  /// 활성 프로파일 최적화
  Future<void> _optimizeActiveProfiles() async {
    final profilesToOptimize =
        Map<String, OptimizedMixingProfile>.from(_activeProfiles);

    for (final entry in profilesToOptimize.entries) {
      final profileId = entry.key;
      final profile = entry.value;

      // 프로파일이 여전히 유효한지 확인
      if (!_isProfileStillValid(profile)) {
        _activeProfiles.remove(profileId);
        continue;
      }

      // 실시간 최적화 수행
      final optimizedProfile = await _performRealTimeOptimization(profile);

      if (optimizedProfile != null) {
        _activeProfiles[profileId] = optimizedProfile;

        // 최적화 결과 기록
        _recordOptimizationResult(
          originalProfile: profile,
          optimizedProfile: optimizedProfile,
          optimizationType: OptimizationType.realTime,
        );
      }
    }
  }

  /// 새로운 최적화 기회 탐색
  Future<void> _exploreOptimizationOpportunities() async {
    // 환경 변화 기반 최적화 기회 탐색
    final environmentOpportunities = await _findEnvironmentBasedOpportunities();
    for (final opportunity in environmentOpportunities) {
      await _processOptimizationOpportunity(opportunity);
    }

    // 성능 기반 최적화 기회 탐색
    final performanceOpportunities = await _findPerformanceBasedOpportunities();
    for (final opportunity in performanceOpportunities) {
      await _processOptimizationOpportunity(opportunity);
    }

    // 예측 기반 최적화 기회 탐색
    final predictionOpportunities = await _findPredictionBasedOpportunities();
    for (final opportunity in predictionOpportunities) {
      await _processOptimizationOpportunity(opportunity);
    }
  }

  /// 최적 믹싱 프로파일 생성
  Future<OptimizedMixingProfile?> generateOptimalMixingProfile({
    required String userId,
    required String recipeId,
    required Map<String, dynamic> currentEnvironment,
    required Map<String, dynamic> constraints,
    required OptimizationGoal goal,
  }) async {
    final startTime = DateTime.now();

    // 초기 프로파일 생성
    final initialProfile = await _createInitialProfile(
      userId: userId,
      recipeId: recipeId,
      environment: currentEnvironment,
      constraints: constraints,
      goal: goal,
    );

    if (initialProfile == null) {
      _optimizationController.add(OptimizationEvent(
        type: OptimizationEventType.optimizationFailed,
        message: '초기 프로파일 생성 실패',
        data: {'userId': userId, 'recipeId': recipeId},
        timestamp: DateTime.now(),
      ));
      return null;
    }

    // 다단계 최적화 수행
    var currentProfile = initialProfile;
    var iteration = 0;
    var bestProfile = currentProfile;

    while (iteration < _maxIterations) {
      // 현재 프로파일 평가
      final currentScore = await _evaluateProfile(currentProfile, goal);

      // 최적화 방향 탐색
      final optimizationDirection = await _findOptimizationDirection(
        currentProfile,
        goal,
        currentEnvironment,
      );

      if (optimizationDirection.improvementPotential < 0.01) {
        // 더 이상 개선 여지가 없음
        break;
      }

      // 최적화 적용
      final optimizedProfile = await _applyOptimizationDirection(
        currentProfile,
        optimizationDirection,
        constraints,
      );

      if (optimizedProfile == null) break;

      // 새로운 프로파일 평가
      final newScore = await _evaluateProfile(optimizedProfile, goal);

      if (newScore > currentScore) {
        // 개선됨
        currentProfile = optimizedProfile;
        bestProfile = currentProfile;
      } else {
        // 개선되지 않음 - 다른 방향 탐색
        break;
      }

      iteration++;
    }

    // 최적화된 프로파일 생성
    final finalProfile = OptimizedMixingProfile(
      id: 'opt_${userId}_${recipeId}_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      recipeId: recipeId,
      profile: bestProfile.profile,
      optimizationScore: await _evaluateProfile(bestProfile, goal),
      confidence: bestProfile.confidence,
      optimizationType: OptimizationType.multiStep,
      createdAt: DateTime.now(),
      environmentSnapshot: Map<String, dynamic>.from(currentEnvironment),
      constraints: Map<String, dynamic>.from(constraints),
      goal: goal,
      iterations: iteration,
    );

    // 활성 프로파일에 추가
    _activeProfiles[finalProfile.id] = finalProfile;

    // 최적화 결과 기록
    _recordOptimizationResult(
      originalProfile: initialProfile,
      optimizedProfile: finalProfile,
      optimizationType: OptimizationType.multiStep,
    );

    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);

    _optimizationController.add(OptimizationEvent(
      type: OptimizationEventType.profileOptimized,
      message: '최적 믹싱 프로파일 생성 완료',
      data: {
        'profileId': finalProfile.id,
        'userId': userId,
        'recipeId': recipeId,
        'optimizationScore': finalProfile.optimizationScore,
        'iterations': iteration,
        'duration': duration.inMilliseconds,
      },
      timestamp: DateTime.now(),
    ));

    return finalProfile;
  }

  /// 초기 프로파일 생성
  Future<OptimizedMixingProfile?> _createInitialProfile({
    required String userId,
    required String recipeId,
    required Map<String, dynamic> environment,
    required Map<String, dynamic> constraints,
    required OptimizationGoal goal,
  }) async {
    try {
      // 기본 프로파일 생성
      final baseProfile = MixingProfileData.defaultProfile();

      // 환경 기반 조정
      var adjustedProfile =
          await _adjustForEnvironment(baseProfile, environment);

      // 제약 조건 적용
      adjustedProfile = _applyConstraints(adjustedProfile, constraints);

      // 목표 기반 최적화
      adjustedProfile =
          await _optimizeForGoal(adjustedProfile, goal, environment);

      return OptimizedMixingProfile(
        id: 'init_${userId}_${recipeId}_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        recipeId: recipeId,
        profile: adjustedProfile,
        optimizationScore: 0.5, // 초기 점수
        confidence: 0.6,
        optimizationType: OptimizationType.initial,
        createdAt: DateTime.now(),
        environmentSnapshot: Map<String, dynamic>.from(environment),
        constraints: Map<String, dynamic>.from(constraints),
        goal: goal,
        iterations: 0,
      );
    } catch (e) {
      return null;
    }
  }

  /// 실시간 최적화 수행
  Future<OptimizedMixingProfile?> _performRealTimeOptimization(
    OptimizedMixingProfile profile,
  ) async {
    try {
      // 현재 환경 데이터 수집
      final currentEnvironment = await _getCurrentEnvironment();

      // 환경 변화 계산
      final environmentChange = _calculateEnvironmentChange(
        profile.environmentSnapshot,
        currentEnvironment,
      );

      if (environmentChange.magnitude < 0.1) {
        // 환경 변화가 미미함
        return null;
      }

      // 변화에 따른 프로파일 조정
      final adjustedProfile = await _adjustProfileForEnvironmentChange(
        profile,
        environmentChange,
      );

      if (adjustedProfile == null) return null;

      // 조정된 프로파일 평가
      final newScore = await _evaluateProfile(adjustedProfile, profile.goal);

      if (newScore > profile.optimizationScore) {
        return OptimizedMixingProfile(
          id: profile.id,
          userId: profile.userId,
          recipeId: profile.recipeId,
          profile: adjustedProfile.profile,
          optimizationScore: newScore,
          confidence: adjustedProfile.confidence,
          optimizationType: OptimizationType.realTime,
          createdAt: DateTime.now(),
          environmentSnapshot: currentEnvironment,
          constraints: profile.constraints,
          goal: profile.goal,
          iterations: profile.iterations + 1,
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// 프로파일 유효성 확인
  bool _isProfileStillValid(OptimizedMixingProfile profile) {
    final age = DateTime.now().difference(profile.createdAt);
    final maxAge = Duration(hours: 2); // 2시간 후 만료

    if (age > maxAge) return false;

    // 신뢰도가 너무 낮으면 유효하지 않음
    if (profile.confidence < _minConfidenceThreshold) return false;

    return true;
  }

  /// 최적화 기회 처리
  Future<void> _processOptimizationOpportunity(
    OptimizationOpportunity opportunity,
  ) async {
    final optimizedProfile = await generateOptimalMixingProfile(
      userId: opportunity.userId,
      recipeId: opportunity.recipeId,
      currentEnvironment: opportunity.environment,
      constraints: opportunity.constraints,
      goal: opportunity.goal,
    );

    if (optimizedProfile != null) {
      _optimizationController.add(OptimizationEvent(
        type: OptimizationEventType.opportunityProcessed,
        message: '최적화 기회 처리 완료',
        data: {
          'opportunityId': opportunity.id,
          'profileId': optimizedProfile.id,
          'improvement': optimizedProfile.optimizationScore,
        },
        timestamp: DateTime.now(),
      ));
    }
  }

  /// 환경 변화 계산
  EnvironmentChange _calculateEnvironmentChange(
    Map<String, dynamic> oldEnvironment,
    Map<String, dynamic> newEnvironment,
  ) {
    var totalChange = 0.0;
    var maxChange = 0.0;
    var changeCount = 0;

    final keys = {...oldEnvironment.keys, ...newEnvironment.keys};

    for (final key in keys) {
      final oldValue = oldEnvironment[key] as num?;
      final newValue = newEnvironment[key] as num?;

      if (oldValue != null && newValue != null) {
        final change = (newValue - oldValue).abs();
        final relativeChange = oldValue != 0 ? change / oldValue.abs() : 0.0;

        totalChange += relativeChange;
        maxChange = max(maxChange, relativeChange);
        changeCount++;
      }
    }

    final averageChange = changeCount > 0 ? totalChange / changeCount : 0.0;

    return EnvironmentChange(
      magnitude: averageChange,
      maxChange: maxChange,
      significantChange: averageChange > 0.1,
      changedFactors: _identifyChangedFactors(oldEnvironment, newEnvironment),
    );
  }

  /// 환경 기반 프로파일 조정
  Future<MixingProfileData> _adjustForEnvironment(
    MixingProfileData profile,
    Map<String, dynamic> environment,
  ) async {
    var adjustedSteps = List<MixingStepData>.from(profile.steps);
    var totalTime = profile.totalTime;
    var confidence = profile.confidence;

    // 온도 기반 조정
    final temperature = environment['temperature'] as double? ?? 20.0;
    if (temperature < 18) {
      // 저온: 믹싱 시간 증가
      totalTime = (totalTime * 1.15).round();
      adjustedSteps = adjustedSteps.map((step) {
        return MixingStepData(
          stepNumber: step.stepNumber,
          speed: step.speed == '고속' ? '중속' : step.speed,
          durationMinutes: (step.durationMinutes * 1.15).round(),
          purpose: step.purpose,
          source: TimeDataSource.adjusted,
        );
      }).toList();
      confidence *= 0.95;
    } else if (temperature > 28) {
      // 고온: 믹싱 시간 감소
      totalTime = (totalTime * 0.9).round();
      adjustedSteps = adjustedSteps.map((step) {
        return MixingStepData(
          stepNumber: step.stepNumber,
          speed: step.speed,
          durationMinutes: (step.durationMinutes * 0.9).round(),
          purpose: step.purpose,
          source: TimeDataSource.adjusted,
        );
      }).toList();
      confidence *= 0.95;
    }

    // 습도 기반 조정
    final humidity = environment['humidity'] as double? ?? 60.0;
    if (humidity < 45) {
      // 건조: 수분 보충 고려
      adjustedSteps = adjustedSteps.map((step) {
        if (step.stepNumber == 1) {
          return MixingStepData(
            stepNumber: step.stepNumber,
            speed: '저속',
            durationMinutes: step.durationMinutes + 1,
            purpose: step.purpose,
            source: TimeDataSource.adjusted,
          );
        }
        return step;
      }).toList();
      totalTime += 1;
      confidence *= 0.98;
    }

    return MixingProfileData(
      steps: adjustedSteps,
      totalTime: totalTime,
      primarySource: TimeDataSource.adjusted,
      confidence: confidence,
    );
  }

  /// 제약 조건 적용
  MixingProfileData _applyConstraints(
    MixingProfileData profile,
    Map<String, dynamic> constraints,
  ) {
    var adjustedSteps = List<MixingStepData>.from(profile.steps);
    var totalTime = profile.totalTime;
    var confidence = profile.confidence;

    // 최대 시간 제약
    final maxTime = constraints['maxTime'] as int?;
    if (maxTime != null && totalTime > maxTime) {
      final ratio = maxTime / totalTime;
      adjustedSteps = adjustedSteps.map((step) {
        return MixingStepData(
          stepNumber: step.stepNumber,
          speed: step.speed,
          durationMinutes: max(1, (step.durationMinutes * ratio).round()),
          purpose: step.purpose,
          source: TimeDataSource.adjusted,
        );
      }).toList();
      totalTime = maxTime;
      confidence *= 0.9;
    }

    // 최소 시간 제약
    final minTime = constraints['minTime'] as int?;
    if (minTime != null && totalTime < minTime) {
      final ratio = minTime / totalTime;
      adjustedSteps = adjustedSteps.map((step) {
        return MixingStepData(
          stepNumber: step.stepNumber,
          speed: step.speed,
          durationMinutes: (step.durationMinutes * ratio).round(),
          purpose: step.purpose,
          source: TimeDataSource.adjusted,
        );
      }).toList();
      totalTime = minTime;
      confidence *= 0.9;
    }

    // 속도 제약
    final allowedSpeeds = constraints['allowedSpeeds'] as List<String>?;
    if (allowedSpeeds != null) {
      adjustedSteps = adjustedSteps.map((step) {
        if (!allowedSpeeds.contains(step.speed)) {
          return MixingStepData(
            stepNumber: step.stepNumber,
            speed: allowedSpeeds.first,
            durationMinutes: step.durationMinutes,
            purpose: step.purpose,
            source: TimeDataSource.adjusted,
          );
        }
        return step;
      }).toList();
      confidence *= 0.95;
    }

    return MixingProfileData(
      steps: adjustedSteps,
      totalTime: totalTime,
      primarySource: TimeDataSource.adjusted,
      confidence: confidence,
    );
  }

  /// 목표 기반 최적화
  Future<MixingProfileData> _optimizeForGoal(
    MixingProfileData profile,
    OptimizationGoal goal,
    Map<String, dynamic> environment,
  ) async {
    switch (goal) {
      case OptimizationGoal.quality:
        return await _optimizeForQuality(profile, environment);
      case OptimizationGoal.speed:
        return _optimizeForSpeed(profile, environment);
      case OptimizationGoal.consistency:
        return await _optimizeForConsistency(profile, environment);
      case OptimizationGoal.energyEfficiency:
        return _optimizeForEnergyEfficiency(profile, environment);
      case OptimizationGoal.adaptability:
        return await _optimizeForAdaptability(profile, environment);
    }
  }

  /// 품질 최적화
  Future<MixingProfileData> _optimizeForQuality(
    MixingProfileData profile,
    Map<String, dynamic> environment,
  ) async {
    // 품질 최적화를 위한 세밀한 믹싱 프로파일
    var adjustedSteps = List<MixingStepData>.from(profile.steps);
    var totalTime = profile.totalTime;
    var confidence = profile.confidence;

    // 각 단계 최적화
    for (var i = 0; i < adjustedSteps.length; i++) {
      final step = adjustedSteps[i];
      switch (step.stepNumber) {
        case 1: // 초기 글루텐 형성
          adjustedSteps[i] = MixingStepData(
            stepNumber: step.stepNumber,
            speed: '저속',
            durationMinutes: (step.durationMinutes * 1.2).round(),
            purpose: step.purpose,
            source: TimeDataSource.adjusted,
          );
          totalTime += (step.durationMinutes * 0.2).round();
          break;
        case 2: // 글루텐 네트워크 강화
          adjustedSteps[i] = MixingStepData(
            stepNumber: step.stepNumber,
            speed: '중속',
            durationMinutes: (step.durationMinutes * 1.1).round(),
            purpose: step.purpose,
            source: TimeDataSource.adjusted,
          );
          totalTime += (step.durationMinutes * 0.1).round();
          break;
        case 3: // 최종 혼합
          adjustedSteps[i] = MixingStepData(
            stepNumber: step.stepNumber,
            speed: '고속',
            durationMinutes: step.durationMinutes,
            purpose: step.purpose,
            source: TimeDataSource.adjusted,
          );
          break;
      }
    }

    confidence *= 0.95; // 품질 최적화로 인한 시간 증가로 신뢰도 약간 감소

    return MixingProfileData(
      steps: adjustedSteps,
      totalTime: totalTime,
      primarySource: TimeDataSource.adjusted,
      confidence: confidence,
    );
  }

  /// 속도 최적화
  MixingProfileData _optimizeForSpeed(
    MixingProfileData profile,
    Map<String, dynamic> environment,
  ) {
    // 속도 최적화를 위한 빠른 믹싱 프로파일
    final speedMultiplier = 0.8; // 20% 시간 감소
    final adjustedSteps = profile.steps.map((step) {
      return MixingStepData(
        stepNumber: step.stepNumber,
        speed: _getFasterSpeed(step.speed),
        durationMinutes:
            max(1, (step.durationMinutes * speedMultiplier).round()),
        purpose: step.purpose,
        source: TimeDataSource.adjusted,
      );
    }).toList();

    final newTotalTime = (profile.totalTime * speedMultiplier).round();

    return MixingProfileData(
      steps: adjustedSteps,
      totalTime: newTotalTime,
      primarySource: TimeDataSource.adjusted,
      confidence: profile.confidence * 0.9, // 속도 최적화로 신뢰도 감소
    );
  }

  /// 일관성 최적화
  Future<MixingProfileData> _optimizeForConsistency(
    MixingProfileData profile,
    Map<String, dynamic> environment,
  ) async {
    // 일관성을 위한 표준화된 믹싱 프로파일
    var adjustedSteps = List<MixingStepData>.from(profile.steps);
    var confidence = profile.confidence;

    // 각 단계 시간을 표준화
    const standardTimes = [6, 5, 4]; // 단계별 표준 시간
    var totalTime = 0;

    for (var i = 0; i < adjustedSteps.length && i < standardTimes.length; i++) {
      adjustedSteps[i] = MixingStepData(
        stepNumber: adjustedSteps[i].stepNumber,
        speed: adjustedSteps[i].speed,
        durationMinutes: standardTimes[i],
        purpose: adjustedSteps[i].purpose,
        source: TimeDataSource.adjusted,
      );
      totalTime += standardTimes[i];
    }

    confidence *= 1.1; // 표준화로 일관성 향상

    return MixingProfileData(
      steps: adjustedSteps,
      totalTime: totalTime,
      primarySource: TimeDataSource.adjusted,
      confidence: min(confidence, 1.0),
    );
  }

  /// 에너지 효율 최적화
  MixingProfileData _optimizeForEnergyEfficiency(
    MixingProfileData profile,
    Map<String, dynamic> environment,
  ) {
    // 에너지 효율을 위한 최적화된 믹싱 프로파일
    final adjustedSteps = profile.steps.map((step) {
      return MixingStepData(
        stepNumber: step.stepNumber,
        speed: _getEnergyEfficientSpeed(step.speed),
        durationMinutes: step.durationMinutes,
        purpose: step.purpose,
        source: TimeDataSource.adjusted,
      );
    }).toList();

    return MixingProfileData(
      steps: adjustedSteps,
      totalTime: profile.totalTime,
      primarySource: TimeDataSource.adjusted,
      confidence: profile.confidence * 0.95,
    );
  }

  /// 적응성 최적화
  Future<MixingProfileData> _optimizeForAdaptability(
    MixingProfileData profile,
    Map<String, dynamic> environment,
  ) async {
    // 다양한 상황에 적응할 수 있는 유연한 프로파일
    var adjustedSteps = List<MixingStepData>.from(profile.steps);
    var confidence = profile.confidence;

    // 각 단계에 유연성 추가
    for (var i = 0; i < adjustedSteps.length; i++) {
      final step = adjustedSteps[i];
      final flexibleDuration = (step.durationMinutes * 1.2).round();

      adjustedSteps[i] = MixingStepData(
        stepNumber: step.stepNumber,
        speed: step.speed,
        durationMinutes: flexibleDuration,
        purpose: step.purpose,
        source: TimeDataSource.adjusted,
      );
    }

    confidence *= 0.9; // 유연성 추가로 예측 가능성 감소

    return MixingProfileData(
      steps: adjustedSteps,
      totalTime: (profile.totalTime * 1.2).round(),
      primarySource: TimeDataSource.adjusted,
      confidence: confidence,
    );
  }

  /// 프로파일 평가
  Future<double> _evaluateProfile(
    OptimizedMixingProfile profile,
    OptimizationGoal goal,
  ) async {
    var score = 0.0;

    switch (goal) {
      case OptimizationGoal.quality:
        score = await _evaluateQuality(profile);
        break;
      case OptimizationGoal.speed:
        score = _evaluateSpeed(profile);
        break;
      case OptimizationGoal.consistency:
        score = await _evaluateConsistency(profile);
        break;
      case OptimizationGoal.energyEfficiency:
        score = _evaluateEnergyEfficiency(profile);
        break;
      case OptimizationGoal.adaptability:
        score = await _evaluateAdaptability(profile);
        break;
    }

    return score * profile.confidence;
  }

  /// 최적화 방향 탐색
  Future<OptimizationDirection> _findOptimizationDirection(
    OptimizedMixingProfile profile,
    OptimizationGoal goal,
    Map<String, dynamic> environment,
  ) async {
    // 여러 방향으로 탐색하여 최적 방향 찾기
    final directions = <OptimizationDirection>[];

    // 시간 조정 방향
    directions.add(OptimizationDirection(
      type: OptimizationAdjustment.timeAdjustment,
      magnitude: 0.1,
      direction: 1,
      improvementPotential: 0.05,
    ));

    directions.add(OptimizationDirection(
      type: OptimizationAdjustment.timeAdjustment,
      magnitude: 0.1,
      direction: -1,
      improvementPotential: 0.03,
    ));

    // 속도 조정 방향
    directions.add(OptimizationDirection(
      type: OptimizationAdjustment.speedAdjustment,
      magnitude: 0.2,
      direction: 1,
      improvementPotential: 0.08,
    ));

    directions.add(OptimizationDirection(
      type: OptimizationAdjustment.speedAdjustment,
      magnitude: 0.2,
      direction: -1,
      improvementPotential: 0.04,
    ));

    // 각 방향 평가
    for (final direction in directions) {
      final testProfile = await _applyOptimizationDirection(
        profile,
        direction,
        profile.constraints,
      );

      if (testProfile != null) {
        final testScore = await _evaluateProfile(testProfile, goal);
        direction.improvementPotential = testScore - profile.optimizationScore;
      }
    }

    // 가장 좋은 방향 선택
    directions.sort(
        (a, b) => b.improvementPotential.compareTo(a.improvementPotential));
    return directions.first;
  }

  /// 최적화 방향 적용
  Future<OptimizedMixingProfile?> _applyOptimizationDirection(
    OptimizedMixingProfile profile,
    OptimizationDirection direction,
    Map<String, dynamic> constraints,
  ) async {
    try {
      var adjustedProfile = profile.profile;

      switch (direction.type) {
        case OptimizationAdjustment.timeAdjustment:
          adjustedProfile = _adjustTime(
            adjustedProfile,
            direction.magnitude * direction.direction,
          );
          break;
        case OptimizationAdjustment.speedAdjustment:
          adjustedProfile = _adjustSpeed(
            adjustedProfile,
            direction.magnitude * direction.direction,
          );
          break;
        case OptimizationAdjustment.stepCountAdjustment:
          adjustedProfile = _adjustStepCount(
            adjustedProfile,
            direction.direction > 0 ? 1 : -1,
          );
          break;
      }

      // 제약 조건 재적용
      adjustedProfile = _applyConstraints(adjustedProfile, constraints);

      return OptimizedMixingProfile(
        id: profile.id,
        userId: profile.userId,
        recipeId: profile.recipeId,
        profile: adjustedProfile,
        optimizationScore: profile.optimizationScore,
        confidence: profile.confidence * 0.98,
        optimizationType: OptimizationType.iterative,
        createdAt: DateTime.now(),
        environmentSnapshot: profile.environmentSnapshot,
        constraints: constraints,
        goal: profile.goal,
        iterations: profile.iterations + 1,
      );
    } catch (e) {
      return null;
    }
  }

  /// 헬퍼 함수들
  String _getFasterSpeed(String speed) {
    switch (speed) {
      case '저속':
        return '중속';
      case '중속':
        return '고속';
      case '고속':
        return '고속';
      default:
        return speed;
    }
  }

  String _getEnergyEfficientSpeed(String speed) {
    switch (speed) {
      case '고속':
        return '중속';
      case '중속':
        return '저속';
      case '저속':
        return '저속';
      default:
        return speed;
    }
  }

  MixingProfileData _adjustTime(MixingProfileData profile, double ratio) {
    final adjustedSteps = profile.steps.map((step) {
      return MixingStepData(
        stepNumber: step.stepNumber,
        speed: step.speed,
        durationMinutes: max(1, (step.durationMinutes * (1 + ratio)).round()),
        purpose: step.purpose,
        source: TimeDataSource.adjusted,
      );
    }).toList();

    final newTotalTime =
        adjustedSteps.fold(0, (sum, step) => sum + step.durationMinutes);

    return MixingProfileData(
      steps: adjustedSteps,
      totalTime: newTotalTime,
      primarySource: TimeDataSource.adjusted,
      confidence: profile.confidence,
    );
  }

  MixingProfileData _adjustSpeed(MixingProfileData profile, double ratio) {
    final adjustedSteps = profile.steps.map((step) {
      final newSpeed = ratio > 0
          ? _getFasterSpeed(step.speed)
          : _getEnergyEfficientSpeed(step.speed);
      return MixingStepData(
        stepNumber: step.stepNumber,
        speed: newSpeed,
        durationMinutes: step.durationMinutes,
        purpose: step.purpose,
        source: TimeDataSource.adjusted,
      );
    }).toList();

    return MixingProfileData(
      steps: adjustedSteps,
      totalTime: profile.totalTime,
      primarySource: TimeDataSource.adjusted,
      confidence: profile.confidence,
    );
  }

  MixingProfileData _adjustStepCount(MixingProfileData profile, int delta) {
    var adjustedSteps = List<MixingStepData>.from(profile.steps);

    if (delta > 0 && adjustedSteps.length < 5) {
      // 단계 추가
      adjustedSteps.add(MixingStepData(
        stepNumber: adjustedSteps.length + 1,
        speed: '중속',
        durationMinutes: 3,
        purpose: '추가 믹싱 단계',
        source: TimeDataSource.adjusted,
      ));
    } else if (delta < 0 && adjustedSteps.length > 2) {
      // 단계 제거
      adjustedSteps.removeLast();
    }

    final newTotalTime =
        adjustedSteps.fold(0, (sum, step) => sum + step.durationMinutes);

    return MixingProfileData(
      steps: adjustedSteps,
      totalTime: newTotalTime,
      primarySource: TimeDataSource.adjusted,
      confidence: profile.confidence * 0.95,
    );
  }

  Future<double> _evaluateQuality(OptimizedMixingProfile profile) async {
    // 품질 평가 로직
    var qualityScore = 0.0;

    // 글루텐 형성 단계 평가
    final firstStep =
        profile.profile.steps.firstWhere((step) => step.stepNumber == 1);
    if (firstStep.durationMinutes >= 5) qualityScore += 0.3;

    // 네트워크 강화 단계 평가
    final secondStep =
        profile.profile.steps.firstWhere((step) => step.stepNumber == 2);
    if (secondStep.speed == '중속') qualityScore += 0.2;

    // 최종 혼합 단계 평가
    final thirdStep =
        profile.profile.steps.firstWhere((step) => step.stepNumber == 3);
    if (thirdStep.durationMinutes <= 5) qualityScore += 0.2;

    // 총 시간 평가
    if (profile.profile.totalTime >= 12) qualityScore += 0.3;

    return min(qualityScore, 1.0);
  }

  double _evaluateSpeed(OptimizedMixingProfile profile) {
    // 속도 평가 로직
    const idealTime = 10;
    final timeRatio = idealTime / profile.profile.totalTime;
    return min(timeRatio, 1.0);
  }

  Future<double> _evaluateConsistency(OptimizedMixingProfile profile) async {
    // 일관성 평가 로직
    var consistencyScore = 0.0;

    // 단계별 시간 표준화 평가
    final steps = profile.profile.steps;
    if (steps.length >= 3) {
      final times = steps.map((step) => step.durationMinutes).toList();
      final avgTime = times.reduce((a, b) => a + b) / times.length;
      final variance =
          times.map((t) => pow(t - avgTime, 2)).reduce((a, b) => a + b) /
              times.length;
      final stdDev = sqrt(variance);

      consistencyScore = 1.0 / (1.0 + stdDev / 2.0);
    }

    return consistencyScore;
  }

  double _evaluateEnergyEfficiency(OptimizedMixingProfile profile) {
    // 에너지 효율 평가 로직
    var efficiencyScore = 0.0;

    for (final step in profile.profile.steps) {
      switch (step.speed) {
        case '저속':
          efficiencyScore += 0.4;
          break;
        case '중속':
          efficiencyScore += 0.3;
          break;
        case '고속':
          efficiencyScore += 0.2;
          break;
      }
    }

    return efficiencyScore / profile.profile.steps.length;
  }

  Future<double> _evaluateAdaptability(OptimizedMixingProfile profile) async {
    // 적응성 평가 로직
    var adaptabilityScore = 0.0;

    // 시간 유연성 평가
    final timeVariance = profile.profile.steps
            .map((step) => step.durationMinutes)
            .toSet()
            .length /
        profile.profile.steps.length;
    adaptabilityScore += timeVariance * 0.4;

    // 속도 다양성 평가
    final speedVariance =
        profile.profile.steps.map((step) => step.speed).toSet().length /
            3.0; // 최대 3가지 속도
    adaptabilityScore += speedVariance * 0.6;

    return min(adaptabilityScore, 1.0);
  }

  List<String> _identifyChangedFactors(
    Map<String, dynamic> oldEnv,
    Map<String, dynamic> newEnv,
  ) {
    final changedFactors = <String>[];

    for (final key in oldEnv.keys) {
      final oldValue = oldEnv[key] as num?;
      final newValue = newEnv[key] as num?;

      if (oldValue != null && newValue != null) {
        final change = (newValue - oldValue).abs();
        final relativeChange = oldValue != 0 ? change / oldValue.abs() : 0.0;

        if (relativeChange > 0.1) {
          changedFactors.add(key);
        }
      }
    }

    return changedFactors;
  }

  Future<Map<String, dynamic>> _getCurrentEnvironment() async {
    // 실제로는 센서 데이터 수집
    final now = DateTime.now();
    return {
      'temperature': 22.0 + 2 * sin(now.hour * pi / 12),
      'humidity': 55.0 + 10 * sin(now.hour * pi / 6),
      'pressure': 1013.25 + 3 * sin(now.hour * pi / 24),
      'timeOfDay': now.hour,
    };
  }

  Future<OptimizedMixingProfile?> _adjustProfileForEnvironmentChange(
    OptimizedMixingProfile profile,
    EnvironmentChange change,
  ) async {
    if (!change.significantChange) return null;

    final adjustedProfile = await _adjustForEnvironment(
      profile.profile,
      profile.environmentSnapshot,
    );

    return OptimizedMixingProfile(
      id: profile.id,
      userId: profile.userId,
      recipeId: profile.recipeId,
      profile: adjustedProfile,
      optimizationScore: profile.optimizationScore,
      confidence: profile.confidence * 0.95,
      optimizationType: OptimizationType.realTime,
      createdAt: DateTime.now(),
      environmentSnapshot: profile.environmentSnapshot,
      constraints: profile.constraints,
      goal: profile.goal,
      iterations: profile.iterations + 1,
    );
  }

  Future<List<OptimizationOpportunity>>
      _findEnvironmentBasedOpportunities() async {
    // 환경 변화 기반 최적화 기회 탐색
    return [];
  }

  Future<List<OptimizationOpportunity>>
      _findPerformanceBasedOpportunities() async {
    // 성능 기반 최적화 기회 탐색
    return [];
  }

  Future<List<OptimizationOpportunity>>
      _findPredictionBasedOpportunities() async {
    // 예측 기반 최적화 기회 탐색
    return [];
  }

  void _recordOptimizationResult({
    required OptimizedMixingProfile originalProfile,
    required OptimizedMixingProfile optimizedProfile,
    required OptimizationType optimizationType,
  }) {
    final result = OptimizationResult(
      originalProfileId: originalProfile.id,
      optimizedProfileId: optimizedProfile.id,
      userId: originalProfile.userId,
      recipeId: originalProfile.recipeId,
      optimizationType: optimizationType,
      originalScore: originalProfile.optimizationScore,
      optimizedScore: optimizedProfile.optimizationScore,
      improvement: optimizedProfile.optimizationScore -
          originalProfile.optimizationScore,
      confidence: optimizedProfile.confidence,
      iterations: optimizedProfile.iterations,
      timestamp: DateTime.now(),
    );

    _optimizationHistory.add(result);

    // 최대 히스토리 수 유지
    if (_optimizationHistory.length > _maxHistoryItems) {
      _optimizationHistory.removeAt(0);
    }
  }

  /// 현재 최적화 상태 조회
  Map<String, dynamic> getCurrentOptimizationState() {
    return {
      'isActive': _optimizationTimer?.isActive ?? false,
      'activeProfiles': _activeProfiles.length,
      'optimizationHistory': _optimizationHistory.length,
      'systems': {
        'adaptation': _adaptationEngine.getCurrentAdaptationState(),
        'environment': {'isActive': true},
        'recommendation': _recommendationSystem != null,
      },
    };
  }

  /// 리소스 정리
  void dispose() {
    stopOptimizationEngine();
    _optimizationController.close();
  }
}

/// 최적화 목표
enum OptimizationGoal {
  quality, // 최고 품질
  speed, // 최단 시간
  consistency, // 일관성
  energyEfficiency, // 에너지 효율
  adaptability, // 적응성
}

/// 최적화 타입
enum OptimizationType {
  initial, // 초기 최적화
  realTime, // 실시간 최적화
  multiStep, // 다단계 최적화
  iterative, // 반복 최적화
}

/// 최적화 조정 타입
enum OptimizationAdjustment {
  timeAdjustment, // 시간 조정
  speedAdjustment, // 속도 조정
  stepCountAdjustment, // 단계 수 조정
}

/// 최적화 이벤트 타입
enum OptimizationEventType {
  engineStarted,
  engineStopped,
  optimizationCompleted,
  optimizationError,
  profileOptimized,
  opportunityProcessed,
  optimizationFailed,
}

/// 최적화 이벤트
class OptimizationEvent {
  final OptimizationEventType type;
  final String message;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  const OptimizationEvent({
    required this.type,
    required this.message,
    this.data,
    required this.timestamp,
  });

  @override
  String toString() => '[$timestamp] $type: $message';
}

/// 최적화된 믹싱 프로파일
class OptimizedMixingProfile {
  final String id;
  final String userId;
  final String recipeId;
  final MixingProfileData profile;
  final double optimizationScore;
  final double confidence;
  final OptimizationType optimizationType;
  final DateTime createdAt;
  final Map<String, dynamic> environmentSnapshot;
  final Map<String, dynamic> constraints;
  final OptimizationGoal goal;
  final int iterations;

  const OptimizedMixingProfile({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.profile,
    required this.optimizationScore,
    required this.confidence,
    required this.optimizationType,
    required this.createdAt,
    required this.environmentSnapshot,
    required this.constraints,
    required this.goal,
    required this.iterations,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'recipeId': recipeId,
        'profile': profile.toJson(),
        'optimizationScore': optimizationScore,
        'confidence': confidence,
        'optimizationType': optimizationType.name,
        'createdAt': createdAt.toIso8601String(),
        'environmentSnapshot': environmentSnapshot,
        'constraints': constraints,
        'goal': goal.name,
        'iterations': iterations,
      };
}

/// 최적화 기회
class OptimizationOpportunity {
  final String id;
  final String userId;
  final String recipeId;
  final Map<String, dynamic> environment;
  final Map<String, dynamic> constraints;
  final OptimizationGoal goal;
  final double potentialImprovement;
  final DateTime timestamp;

  const OptimizationOpportunity({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.environment,
    required this.constraints,
    required this.goal,
    required this.potentialImprovement,
    required this.timestamp,
  });
}

/// 환경 변화
class EnvironmentChange {
  final double magnitude;
  final double maxChange;
  final bool significantChange;
  final List<String> changedFactors;

  const EnvironmentChange({
    required this.magnitude,
    required this.maxChange,
    required this.significantChange,
    required this.changedFactors,
  });
}

/// 최적화 방향
class OptimizationDirection {
  final OptimizationAdjustment type;
  final double magnitude;
  final int direction; // 1: 증가, -1: 감소
  double improvementPotential;

  OptimizationDirection({
    required this.type,
    required this.magnitude,
    required this.direction,
    required this.improvementPotential,
  });
}

/// 최적화 결과
class OptimizationResult {
  final String originalProfileId;
  final String optimizedProfileId;
  final String userId;
  final String recipeId;
  final OptimizationType optimizationType;
  final double originalScore;
  final double optimizedScore;
  final double improvement;
  final double confidence;
  final int iterations;
  final DateTime timestamp;

  const OptimizationResult({
    required this.originalProfileId,
    required this.optimizedProfileId,
    required this.userId,
    required this.recipeId,
    required this.optimizationType,
    required this.originalScore,
    required this.optimizedScore,
    required this.improvement,
    required this.confidence,
    required this.iterations,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'originalProfileId': originalProfileId,
        'optimizedProfileId': optimizedProfileId,
        'userId': userId,
        'recipeId': recipeId,
        'optimizationType': optimizationType.name,
        'originalScore': originalScore,
        'optimizedScore': optimizedScore,
        'improvement': improvement,
        'confidence': confidence,
        'iterations': iterations,
        'timestamp': timestamp.toIso8601String(),
      };
}
