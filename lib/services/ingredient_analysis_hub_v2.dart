// 재료 분석 허브 v2 - Week 3 마이그레이션 버전
// 새로운 타입 시스템과 컨트롤러 패턴 적용

import 'package:flutter/foundation.dart';
import '../core/types/comprehensive_types.dart';
import '../core/controllers/base_analysis_controller.dart';
import '../core/validation/type_validator.dart';

/// 재료 분석 컨트롤러 구현
class IngredientAnalysisControllerV2 extends BaseAnalysisController<
        AnalysisRequest, ComprehensiveIngredientAnalysis>
    with
        CacheableAnalysisController<AnalysisRequest,
            ComprehensiveIngredientAnalysis>,
        LoggableAnalysisController<AnalysisRequest,
            ComprehensiveIngredientAnalysis>,
        ValidatableAnalysisController<AnalysisRequest,
            ComprehensiveIngredientAnalysis> {
  // 싱글톤 패턴
  static final IngredientAnalysisControllerV2 _instance =
      IngredientAnalysisControllerV2._internal();
  static IngredientAnalysisControllerV2 get instance => _instance;

  IngredientAnalysisControllerV2._internal() {
    // 타입 검증기 초기화
    initializeTypeValidators();
  }

  @override
  String get controllerName => 'IngredientAnalysisControllerV2';

  @override
  List<String> get supportedAnalysisTypes => [
        'syrup_analysis',
        'fat_analysis',
        'special_dough_detection',
        'integrated_effects'
      ];

  @override
  AnalysisSettings get defaultSettings => const AnalysisSettings(
        enableCaching: true,
        confidenceThreshold: 0.7,
      );

  @override
  bool validateInput(AnalysisRequest input) {
    final validation =
        RuntimeTypeValidator.validateType(input, 'AnalysisRequest');
    validation.logValidationResult('IngredientAnalysis');
    return validation.isValid;
  }

  @override
  Future<AnalysisResult<ComprehensiveIngredientAnalysis>> analyze(
    AnalysisRequest input,
  ) async {
    final startTime = DateTime.now();

    // 입력 검증
    if (!validateInput(input)) {
      return AnalysisResult.failure(
        '입력 데이터 검증 실패',
        DateTime.now().difference(startTime),
      );
    }

    // 사전 검증
    final preValidation = preValidateInput(input);
    if (!preValidation.isValid) {
      return AnalysisResult.failure(
        '사전 검증 실패: ${preValidation.errors.join(", ")}',
        DateTime.now().difference(startTime),
      );
    }

    try {
      // 캐시 확인
      if (supportsCaching) {
        final cacheKey = generateCacheKey(input);
        final cachedResult = await getCachedResult(cacheKey);
        if (cachedResult != null) {
          return AnalysisResult.success(
            cachedResult,
            DateTime.now().difference(startTime),
            0.9, // 캐시된 결과는 높은 신뢰도
          );
        }
      }

      // 분석 시작 로깅
      logAnalysisStart(input, input.requestId);

      // 시럽 분석
      final syrupResult = await analyzeSyrup(input.ingredients);

      // 지방 분석
      final fatResult = await analyzeFat(input.ingredients);

      // 특수 반죽 감지
      final doughResult = await detectSpecialDough(input.ingredients);

      // 통합 효과 계산
      final integratedResult = await calculateIntegratedEffects(
        syrupResult.data!,
        fatResult.data!,
        doughResult.data!,
      );

      // 최종 결과 생성
      final analysisId = 'analysis_${DateTime.now().millisecondsSinceEpoch}';
      final result = ComprehensiveIngredientAnalysis(
        syrupAnalysis: syrupResult.data!,
        fatAnalysis: fatResult.data!,
        specialDoughDetection: doughResult.data!,
        integratedEffects: integratedResult.data ?? {},
        analysisId: analysisId,
      );

      // 사후 검증
      final postValidation = postValidateOutput(result);
      if (!postValidation.isValid) {
        return AnalysisResult.failure(
          '결과 검증 실패: ${postValidation.errors.join(", ")}',
          DateTime.now().difference(startTime),
        );
      }

      // 캐시 저장
      if (supportsCaching) {
        final cacheKey = generateCacheKey(input);
        await cacheResult(cacheKey, result);
      }

      // 분석 완료 로깅
      final processingTime = DateTime.now().difference(startTime);
      logAnalysisComplete(
        AnalysisResult.success(
            result, processingTime, result.overallConfidence),
        input.requestId,
      );

      return AnalysisResult.success(
        result,
        processingTime,
        result.overallConfidence,
      );
    } catch (e, stackTrace) {
      final processingTime = DateTime.now().difference(startTime);
      logAnalysisFailure(e.toString(), input.requestId, processingTime);

      debugPrint('❌ [IngredientAnalysisControllerV2] 분석 오류: $e');
      debugPrint('StackTrace: $stackTrace');

      return AnalysisResult.failure(
        '분석 중 오류 발생: $e',
        processingTime,
      );
    }
  }

  @override
  Future<AnalysisResult<SyrupAnalysisResult>> analyzeSyrup(
    List<Map<String, dynamic>> ingredients,
  ) async {
    final startTime = DateTime.now();

    try {
      final syrupEffects = <String, dynamic>{};
      final detectedSyrups = <String>[];
      double totalSugarContent = 0.0;
      double averageViscosity = 1.0;
      double confidence = 0.0;

      for (final ingredient in ingredients) {
        final name = ingredient['name']?.toString().toLowerCase() ?? '';
        final amount = (ingredient['amount'] as num?)?.toDouble() ?? 0.0;

        if (_isSyrupIngredient(name)) {
          detectedSyrups.add(name);
          final sugarContent = _calculateSugarContent(name, amount);
          final viscosity = _calculateViscosity(name);
          final effect = _getSyrupEffect(name);

          syrupEffects[name] = {
            'sugarContent': sugarContent,
            'viscosity': viscosity,
            'effect': effect,
            'impact': sugarContent * 0.1,
          };

          totalSugarContent += sugarContent;
          averageViscosity = (averageViscosity + viscosity) / 2;
          confidence += 0.2;
        }
      }

      confidence = confidence.clamp(0.0, 1.0);

      final result = SyrupAnalysisResult(
        sugarContent: totalSugarContent,
        viscosity: averageViscosity,
        effects: syrupEffects,
        confidence: confidence,
      );

      return AnalysisResult.success(
        result,
        DateTime.now().difference(startTime),
        confidence,
      );
    } catch (e) {
      return AnalysisResult.failure(
        '시럽 분석 실패: $e',
        DateTime.now().difference(startTime),
      );
    }
  }

  @override
  Future<AnalysisResult<FatAnalysisResult>> analyzeFat(
    List<Map<String, dynamic>> ingredients,
  ) async {
    final startTime = DateTime.now();

    try {
      final fatEffects = <String, dynamic>{};
      double totalFatContent = 0.0;
      String primaryFatType = 'unknown';
      double confidence = 0.0;

      for (final ingredient in ingredients) {
        final name = ingredient['name']?.toString().toLowerCase() ?? '';
        final amount = (ingredient['amount'] as num?)?.toDouble() ?? 0.0;

        if (_isFatIngredient(name)) {
          final fatContent = _calculateFatContent(name, amount);
          final fatType = _getFatType(name);
          final effect = _getFatEffect(name);

          fatEffects[name] = {
            'fatContent': fatContent,
            'fatType': fatType,
            'effect': effect,
            'impact': fatContent * 0.08,
          };

          totalFatContent += fatContent;
          if (primaryFatType == 'unknown') {
            primaryFatType = fatType;
          }
          confidence += 0.2;
        }
      }

      confidence = confidence.clamp(0.0, 1.0);

      final result = FatAnalysisResult(
        fatContent: totalFatContent,
        fatType: primaryFatType,
        effects: fatEffects,
        confidence: confidence,
      );

      return AnalysisResult.success(
        result,
        DateTime.now().difference(startTime),
        confidence,
      );
    } catch (e) {
      return AnalysisResult.failure(
        '지방 분석 실패: $e',
        DateTime.now().difference(startTime),
      );
    }
  }

  @override
  Future<AnalysisResult<SpecialDoughDetectionResult>> detectSpecialDough(
    List<Map<String, dynamic>> ingredients,
  ) async {
    final startTime = DateTime.now();

    try {
      final detectedTypes = <String>[];
      final confidenceScores = <String, double>{};
      final effects = <String, dynamic>{};

      // 시럽 함량 분석
      final syrupPercentage = _calculateSyrupPercentage(ingredients);
      if (syrupPercentage > 15) {
        detectedTypes.add('brioche');
        confidenceScores['brioche'] = 0.8;
        effects['brioche'] = '시럽 함량이 높아 풍미가 강화됩니다';
      }

      // 지방 함량 분석
      final fatPercentage = _calculateFatPercentage(ingredients);
      if (fatPercentage > 10) {
        if (!detectedTypes.contains('brioche')) {
          detectedTypes.add('enriched');
          confidenceScores['enriched'] = 0.7;
          effects['enriched'] = '지방 함량이 높아 텍스처가 개선됩니다';
        }
      }

      // 기본 타입
      if (detectedTypes.isEmpty) {
        detectedTypes.add('standard');
        confidenceScores['standard'] = 1.0;
        effects['standard'] = '표준 빵 반죽입니다';
      }

      final result = SpecialDoughDetectionResult(
        detectedTypes: detectedTypes,
        confidenceScores: confidenceScores,
        effects: effects,
      );

      return AnalysisResult.success(
        result,
        DateTime.now().difference(startTime),
        result.highestConfidence,
      );
    } catch (e) {
      return AnalysisResult.failure(
        '특수 반죽 감지 실패: $e',
        DateTime.now().difference(startTime),
      );
    }
  }

  @override
  Future<AnalysisResult<Map<String, dynamic>>> calculateIntegratedEffects(
    SyrupAnalysisResult syrupAnalysis,
    FatAnalysisResult fatAnalysis,
    SpecialDoughDetectionResult specialDoughDetection,
  ) async {
    final startTime = DateTime.now();

    try {
      final effects = <String, dynamic>{};

      // 시럽과 지방의 상호작용
      final syrupFatInteraction = {
        'strength': syrupAnalysis.sugarContent + fatAnalysis.fatContent,
        'description': _getSyrupFatInteractionDescription(
          syrupAnalysis.sugarContent,
          fatAnalysis.fatContent,
        ),
      };
      effects['syrupFatInteraction'] = syrupFatInteraction;

      // 특수 반죽 효과
      effects['specialDoughEffects'] = {
        'primaryType': specialDoughDetection.detectedTypes.first,
        'confidence': specialDoughDetection.highestConfidence,
        'effects': specialDoughDetection.effects,
      };

      return AnalysisResult.success(
        effects,
        DateTime.now().difference(startTime),
        0.85,
      );
    } catch (e) {
      return AnalysisResult.failure(
        '통합 효과 계산 실패: $e',
        DateTime.now().difference(startTime),
      );
    }
  }

  // 캐싱 인터페이스 구현
  @override
  String generateCacheKey(AnalysisRequest input) {
    final ingredientsHash = input.ingredients
        .map((ing) => '${ing['name']}_${ing['amount']}')
        .join('_')
        .hashCode;
    return 'ingredient_analysis_${input.breadType}_${ingredientsHash}';
  }

  @override
  Future<ComprehensiveIngredientAnalysis?> getCachedResult(
      String cacheKey) async {
    // 캐시 구현 (실제로는 캐시 매니저 사용)
    return null;
  }

  @override
  Future<void> cacheResult(
      String cacheKey, ComprehensiveIngredientAnalysis result) async {
    // 캐시 저장 구현
    debugPrint('캐시 저장: $cacheKey');
  }

  @override
  Future<void> clearCache() async {
    // 캐시 클리어 구현
    debugPrint('캐시 클리어');
  }

  @override
  Future<Map<String, dynamic>> getCacheStats() async {
    // 캐시 통계 반환
    return {'totalEntries': 0, 'hitRate': 0.0};
  }

  // 로깅 인터페이스 구현
  @override
  void logAnalysisStart(AnalysisRequest input, String requestId) {
    debugPrint(
        '🔍 [IngredientAnalysis] 분석 시작: $requestId, 재료 수: ${input.ingredients.length}');
  }

  @override
  void logAnalysisComplete(
      AnalysisResult<ComprehensiveIngredientAnalysis> result,
      String requestId) {
    debugPrint(
        '✅ [IngredientAnalysis] 분석 완료: $requestId, 성공: ${result.success}');
  }

  @override
  void logAnalysisFailure(
      String error, String requestId, Duration processingTime) {
    debugPrint(
        '❌ [IngredientAnalysis] 분석 실패: $requestId, 오류: $error, 시간: ${processingTime.inMilliseconds}ms');
  }

  @override
  void logPerformanceMetrics(AnalysisMetrics metrics) {
    debugPrint(
        '📊 [IngredientAnalysis] 성능: 총 ${metrics.totalRequests}회, 성공률 ${metrics.successRate}');
  }

  // 검증 인터페이스 구현
  @override
  ValidationResult preValidateInput(AnalysisRequest input) {
    final errors = <String>[];
    final warnings = <String>[];

    if (input.ingredients.isEmpty) {
      errors.add('재료 목록이 비어있습니다');
    }

    if (input.breadType.isEmpty) {
      errors.add('빵 타입이 지정되지 않았습니다');
    }

    if (input.ingredients.length > 50) {
      warnings.add('재료 목록이 너무 많습니다 (50개 초과)');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  @override
  ValidationResult postValidateOutput(ComprehensiveIngredientAnalysis output) {
    final errors = <String>[];
    final warnings = <String>[];

    if (output.analysisId.isEmpty) {
      errors.add('분석 ID가 생성되지 않았습니다');
    }

    if (output.overallConfidence < 0 || output.overallConfidence > 1) {
      errors.add('신뢰도가 유효 범위를 벗어났습니다');
    }

    if (output.overallConfidence < 0.5) {
      warnings.add('전체 신뢰도가 낮습니다');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  @override
  Map<String, ValidationRule> get validationRules => {
        'ingredients': ValidationRule(
          name: 'ingredients',
          required: true,
        ),
        'breadType': ValidationRule(
          name: 'breadType',
          required: true,
          minValue: 1,
        ),
        'requestId': ValidationRule(
          name: 'requestId',
          required: true,
          minValue: 1,
        ),
      };

  // 헬퍼 메서드들
  bool _isSyrupIngredient(String name) {
    final syrupKeywords = [
      'sugar',
      'syrup',
      'honey',
      'molasses',
      '시럽',
      '설탕',
      '꿀'
    ];
    return syrupKeywords.any((keyword) => name.contains(keyword));
  }

  bool _isFatIngredient(String name) {
    final fatKeywords = ['butter', 'oil', 'fat', 'margarine', '버터', '기름', '지방'];
    return fatKeywords.any((keyword) => name.contains(keyword));
  }

  double _calculateSugarContent(String name, double amount) {
    if (name.contains('honey') || name.contains('꿀')) {
      return amount * 0.8; // 꿀은 80% 설탕
    } else if (name.contains('sugar') || name.contains('설탕')) {
      return amount * 0.99; // 정제 설탕은 99% 설탕
    }
    return amount * 0.7; // 기타 시럽류
  }

  double _calculateViscosity(String name) {
    if (name.contains('honey') || name.contains('꿀')) {
      return 2.5; // 꿀은 점성이 높음
    } else if (name.contains('syrup') || name.contains('시럽')) {
      return 1.8; // 시럽은 중간 점성
    }
    return 1.2; // 설탕은 낮은 점성
  }

  double _calculateFatContent(String name, double amount) {
    if (name.contains('butter') || name.contains('버터')) {
      return amount * 0.8; // 버터는 80% 지방
    } else if (name.contains('oil') || name.contains('기름')) {
      return amount * 0.95; // 기름은 95% 지방
    }
    return amount * 0.75; // 기타 지방
  }

  String _getFatType(String name) {
    if (name.contains('butter') || name.contains('버터')) return 'butter';
    if (name.contains('oil') || name.contains('기름')) return 'oil';
    return 'fat';
  }

  String _getSyrupEffect(String name) {
    if (name.contains('honey') || name.contains('꿀')) return '풍미 향상 및 수분 유지';
    if (name.contains('molasses') || name.contains('당밀'))
      return '색상 심화 및 풍미 강화';
    return '단맛 제공 및 구조 강화';
  }

  String _getFatEffect(String name) {
    if (name.contains('butter') || name.contains('버터')) return '풍미 향상 및 텍스처 개선';
    if (name.contains('oil') || name.contains('기름')) return '연화 효과 및 수분 유지';
    return '텍스처 개선';
  }

  double _calculateSyrupPercentage(List<Map<String, dynamic>> ingredients) {
    final totalAmount = ingredients.fold<double>(
      0.0,
      (sum, ing) => sum + (ing['amount'] as num? ?? 0.0),
    );

    if (totalAmount == 0) return 0.0;

    final syrupAmount = ingredients
        .where((ing) =>
            _isSyrupIngredient(ing['name']?.toString().toLowerCase() ?? ''))
        .fold<double>(
          0.0,
          (sum, ing) => sum + (ing['amount'] as num? ?? 0.0),
        );

    return (syrupAmount / totalAmount) * 100;
  }

  double _calculateFatPercentage(List<Map<String, dynamic>> ingredients) {
    final totalAmount = ingredients.fold<double>(
      0.0,
      (sum, ing) => sum + (ing['amount'] as num? ?? 0.0),
    );

    if (totalAmount == 0) return 0.0;

    final fatAmount = ingredients
        .where((ing) =>
            _isFatIngredient(ing['name']?.toString().toLowerCase() ?? ''))
        .fold<double>(
          0.0,
          (sum, ing) => sum + (ing['amount'] as num? ?? 0.0),
        );

    return (fatAmount / totalAmount) * 100;
  }

  String _getSyrupFatInteractionDescription(
      double syrupContent, double fatContent) {
    if (syrupContent > 10 && fatContent > 5) {
      return '시럽과 지방의 강한 상호작용으로 풍미와 텍스처가 크게 향상될 수 있습니다';
    } else if (syrupContent > 5 && fatContent > 2) {
      return '시럽과 지방의 적절한 밸런스로 좋은 결과를 기대할 수 있습니다';
    } else {
      return '시럽과 지방의 밸런스가 표준 범위입니다';
    }
  }
}
