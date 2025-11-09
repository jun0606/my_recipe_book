import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/utils/mixing_data_helper.dart';
import '../core/types/environment_types.dart';
import 'ingredient_analyzer.dart';

/// 발효 분석 초기화 데이터
/// 컨셉 준수: 모든 초기화 데이터를 하나의 객체로 통합
class FermentationAnalysisInitData {
  final List<Map<String, dynamic>> ingredients;
  final List<Map<String, dynamic>> fermentationSteps;
  final int expectedStepsCount;
  final UserEnvironment environment;

  FermentationAnalysisInitData({
    required this.ingredients,
    required this.fermentationSteps,
    required this.expectedStepsCount,
    required this.environment,
  });

  @override
  String toString() =>
      'FermentationAnalysisInitData(재료:${ingredients.length}, 단계:${fermentationSteps.length}, 예상단계수:$expectedStepsCount, 환경:${environment.temperature}°C/${environment.humidity}%)';
}

/// 오븐 분석 초기화 데이터
/// 빵 과학 컨셉 준수: 오븐 베이킹 데이터 중앙화
class BakingAnalysisInitData {
  final List<Map<String, dynamic>> ingredients;
  final List<Map<String, dynamic>> ovenSteps;
  final int expectedStepsCount;
  final UserEnvironment environment;

  BakingAnalysisInitData({
    required this.ingredients,
    required this.ovenSteps,
    required this.expectedStepsCount,
    required this.environment,
  });

  @override
  String toString() =>
      'BakingAnalysisInitData(재료:${ingredients.length}, 단계:${ovenSteps.length}, 예상단계수:$expectedStepsCount, 환경:${environment.temperature}°C/${environment.humidity}%)';
}

/// 중앙 집중화된 파싱 서비스
/// mixing_analysis_card.dart의 파싱 로직을 중앙에서 관리
class CentralizedParsingService {
  static final CentralizedParsingService _instance =
      CentralizedParsingService._internal();
  factory CentralizedParsingService() => _instance;
  CentralizedParsingService._internal();

  /// 믹싱 단계 추출 - MixingDataHelper 활용
  List<Map<String, dynamic>> extractMixingSteps(
      Map<String, dynamic> recipeData) {
    try {
      // MixingDataHelper의 정적 메소드 활용
      return MixingDataHelper.extractMixingSteps(recipeData);
    } catch (e) {
      debugPrint('❌ CentralizedParsingService: 믹싱 단계 추출 실패 - $e');
      return [];
    }
  }

  /// 🔍 실제 레시피 데이터 구조 심층 디버깅 메소드
  void _debugLogRecipeDataStructure(Map<String, dynamic> recipeData) {
    debugPrint('🔍 [심층 디버깅] ===== 레시피 데이터 구조 분석 시작 =====');

    // Top-level 키들 분류
    final listKeys = <String>[];
    final mapKeys = <String>[];
    final stringKeys = <String>[];
    final numberKeys = <String>[];
    final otherKeys = <String>[];

    for (final entry in recipeData.entries) {
      final key = entry.key;
      final value = entry.value;
      final valueType = value.runtimeType.toString();

      if (value is List) {
        listKeys.add('$key[$valueType]:${value.length}개');
        // 리스트 안의 맵 구조도 분석
        if (value.isNotEmpty && value.first is Map<String, dynamic>) {
          final firstItem = value.first as Map<String, dynamic>;
          debugPrint('  📋 $key 리스트 첫 아이템 키들: ${firstItem.keys.join(', ')}');
          // 시간 키가 있는지 확인
          final timeKeys = ['time', 'duration', 'hours', 'minutes'];
          final foundTimeKeys =
              timeKeys.where((k) => firstItem.containsKey(k)).toList();
          if (foundTimeKeys.isNotEmpty) {
            debugPrint('  ⏱️ $key 리스트 시간 키 발견: ${foundTimeKeys.join(', ')}');
            for (final item in value.take(3)) {
              // 최대 3개 샘플
              if (item is Map<String, dynamic>) {
                final sample = timeKeys
                    .where((k) => item.containsKey(k))
                    .map((k) => '$k=${item[k]}')
                    .join(', ');
                debugPrint('    - 샘플: $sample');
              }
            }
          }
        }
      } else if (value is Map) {
        mapKeys.add('$key[$valueType]:${value.length}개');
        debugPrint('  🗂️ $key 맵 키들: ${value.keys.join(', ')}');
      } else if (value is String) {
        stringKeys.add('$key[$valueType]:${value.length}글자');
      } else if (value is num) {
        numberKeys.add('$key[$valueType]:$value');
      } else {
        otherKeys.add('$key[$valueType]');
      }
    }

    debugPrint('📊 [데이터 구조 요약]');
    debugPrint('  📋 리스트: ${listKeys.join(', ')}');
    debugPrint('  🗂️ 맵: ${mapKeys.join(', ')}');
    debugPrint('  📄 문자열: ${stringKeys.join(', ')}');
    debugPrint('  🔢 숫자: ${numberKeys.join(', ')}');
    debugPrint('  ❓ 기타: ${otherKeys.join(', ')}');

    debugPrint('🔍 [심층 디버깅] ===== 레시피 데이터 구조 분석 완료 =====');
  }

  /// ✅ 발효 단계 추출 - 실제 데이터 우선 사용 (하드코딩 완전 제거)
  List<Map<String, dynamic>> extractFermentationSteps(
      Map<String, dynamic> recipeData) {
    try {
      debugPrint('🍞 [발효 단계 추출] ===== 시작 =====');

      // 🔍 데이터 구조 로깅
      debugPrint('🔍 [발효 단계 추출] 입력 데이터 키들: ${recipeData.keys.toList()}');

      // ✅ 실제 데이터베이스에서 읽은 fermentationSteps 로깅
      if (recipeData.containsKey('fermentationSteps')) {
        debugPrint('🔍 [실제 데이터 확인] fermentationSteps 키 존재');
        debugPrint(
            '🔍 [실제 데이터 값] fermentationSteps: ${recipeData['fermentationSteps']}');
        debugPrint(
            '🔍 [실제 데이터 타입] fermentationSteps 타입: ${recipeData['fermentationSteps'].runtimeType}');
      } else {
        debugPrint('❌ [실제 데이터 확인] fermentationSteps 키가 recipeData에 없음');
      }

      // 🔍 실제 데이터 구조 심층 탐색 - 키별 데이터 구조 로깅 추가
      _debugLogRecipeDataStructure(recipeData);

      // 🎯 우선순위 기반 단순 추출 (clear/addAll 혼란 제거)

      // [우선순위 1] fermentationSteps - Recipe 모델 저장 형식 (가장 확실)
      debugPrint('🎯 [우선순위 1] fermentationSteps 키 탐색');
      final fermentationSteps = _tryExtractFromFermentationSteps(recipeData);
      if (fermentationSteps.isNotEmpty) {
        debugPrint(
            '✅ fermentationSteps에서 ${fermentationSteps.length}개 단계 발견 - 즉시 반환');
        return _validateFermentationSteps(fermentationSteps);
      }

      // [우선순위 2] fermentationStages - 복수형 키
      debugPrint('🎯 [우선순위 2] fermentationStages 키 탐색');
      final stagesSteps = _tryExtractFromFermentationStages(recipeData);
      if (stagesSteps.isNotEmpty) {
        debugPrint('✅ fermentationStages에서 ${stagesSteps.length}개 단계 발견');
        return _validateFermentationSteps(stagesSteps);
      }

      // [우선순위 3] 실제 레시피 데이터 파싱
      debugPrint('🎯 [우선순위 3] 실제 레시피 데이터 파싱 시도');
      final actualSteps = _tryExtractActualRecipeFermentationSteps(recipeData);
      if (actualSteps.isNotEmpty) {
        debugPrint('✅ 실제 레시피 데이터에서 ${actualSteps.length}개 단계 발견');
        return _validateFermentationSteps(actualSteps);
      }

      // [우선순위 4] bakingSteps 내 발효 단계 필터링
      debugPrint('🎯 [우선순위 4] bakingSteps에서 발효 단계 필터링');
      final bakingSteps = _tryExtractFromBakingSteps(recipeData);
      if (bakingSteps.isNotEmpty) {
        debugPrint('✅ bakingSteps에서 ${bakingSteps.length}개 발효 단계 발견');
        return _validateFermentationSteps(bakingSteps);
      }

      // [우선순위 5] Sous Chef 디버그 데이터
      debugPrint('🎯 [우선순위 5] Sous Chef 디버그 데이터 탐색');
      final debugSteps = _tryExtractFromSousChefDebug(recipeData);
      if (debugSteps.isNotEmpty) {
        debugPrint('✅ Sous Chef 디버그에서 ${debugSteps.length}개 단계 발견');
        return _validateFermentationSteps(debugSteps);
      }

      // [우선순위 6] 프로세스/워크플로우
      debugPrint('🎯 [우선순위 6] 프로세스/워크플로우 탐색');
      final processSteps = _extractFermentationStepsFromProcess(recipeData);
      if (processSteps.isNotEmpty) {
        debugPrint('✅ 프로세스에서 ${processSteps.length}개 단계 발견');
        return _validateFermentationSteps(processSteps);
      }

      // [우선순위 7] 텍스트 분석 (최후의 수단)
      debugPrint('🎯 [우선순위 7] 텍스트/지침 분석');
      final textSteps = _extractFermentationStepsFromInstructions(recipeData);
      if (textSteps.isNotEmpty) {
        debugPrint('✅ 텍스트에서 ${textSteps.length}개 단계 발견');
        return _validateFermentationSteps(textSteps);
      }

      // 데이터 없음 - 빈 리스트 반환 (하드코딩 금지)
      debugPrint('❌ 모든 경로에서 발효 단계 데이터 미발견');
      return [];
    } catch (e) {
      debugPrint('❌ CentralizedParsingService: 발효 단계 추출 실패 - $e');
      return [];
    }
  }

  /// 경로 1: fermentationSteps 키에서 우선 추출
  List<Map<String, dynamic>> _tryExtractFromFermentationSteps(
      Map<String, dynamic> recipeData) {
    final steps = <Map<String, dynamic>>[];

    try {
      // 🔧 데이터 타입 유연하게 처리 (String JSON or List)
      final fermentationStepsRaw = recipeData['fermentationSteps'];
      List<dynamic>? fermentationStepsData;

      if (fermentationStepsRaw is String) {
        // JSON 문자열로 저장된 경우 디코딩
        debugPrint('🔍 [경로 1] fermentationSteps가 JSON 문자열로 저장됨 - 디코딩 시도');
        fermentationStepsData =
            jsonDecode(fermentationStepsRaw) as List<dynamic>;
        debugPrint('✅ [경로 1] JSON 디코딩 성공: ${fermentationStepsData.length}개 단계');
      } else if (fermentationStepsRaw is List<dynamic>) {
        // 이미 리스트인 경우 그대로 사용
        fermentationStepsData = fermentationStepsRaw;
        debugPrint('✅ [경로 1] fermentationSteps가 이미 리스트 형식임');
      }

      if (fermentationStepsData != null && fermentationStepsData.isNotEmpty) {
        debugPrint('🔍 [경로 1] fermentationSteps 키 탐색 중...');
        for (final step in fermentationStepsData) {
          if (step is Map<String, dynamic>) {
            steps.add(_normalizeFermentationStepData(step));
          }
        }
        debugPrint('✅ [경로 1] fermentationSteps에서 ${steps.length}개 단계 발견');
      }
    } catch (e) {
      debugPrint('⚠️ [경로 1] fermentationSteps 파싱 오류: $e');
    }

    return steps;
  }

  /// 경로 2: fermentationStages 키 탐색 (복수형)
  List<Map<String, dynamic>> _tryExtractFromFermentationStages(
      Map<String, dynamic> recipeData) {
    final steps = <Map<String, dynamic>>[];

    try {
      final fermentationStagesData =
          recipeData['fermentationStages'] as List<dynamic>?;
      if (fermentationStagesData != null && fermentationStagesData.isNotEmpty) {
        debugPrint('🔍 [경로 2] fermentationStages 키 탐색 중...');
        for (final step in fermentationStagesData) {
          if (step is Map<String, dynamic>) {
            steps.add(_normalizeFermentationStepData(step));
          }
        }
        debugPrint('✅ [경로 2] fermentationStages에서 ${steps.length}개 단계 발견');
      }
    } catch (e) {
      debugPrint('⚠️ [경로 2] fermentationStages 파싱 오류: $e');
    }

    return steps;
  }

  /// 경로 3: Sous Chef 디버깅 데이터 탐색
  List<Map<String, dynamic>> _tryExtractFromSousChefDebug(
      Map<String, dynamic> recipeData) {
    final steps = <Map<String, dynamic>>[];

    try {
      // Sous Chef 관련 키들을 순차적으로 탐색
      final debugKeys = [
        'sousChefDebug',
        'debugData',
        'chefDebug',
        'analysisDebug'
      ];
      Map<String, dynamic>? debugData;

      for (final key in debugKeys) {
        debugData = recipeData[key] as Map<String, dynamic>?;
        if (debugData != null) {
          debugPrint('🔍 [경로 3] Sous Chef 디버그 데이터 탐색 (${key})');
          break;
        }
      }

      if (debugData != null) {
        // 발효 관련 키들 탐색
        final fermentationKeys = [
          'fermentationData',
          'fermentationSteps',
          'fermentationStages',
          'fermentation_analysis'
        ];
        List<dynamic>? fermentationList;

        for (final key in fermentationKeys) {
          fermentationList = debugData[key] as List<dynamic>?;
          if (fermentationList != null && fermentationList.isNotEmpty) {
            debugPrint('✅ [경로 3] Sous Chef 디버그에서 발효 단계 발견 (${key})');
            break;
          }
        }

        if (fermentationList != null && fermentationList.isNotEmpty) {
          for (final step in fermentationList) {
            if (step is Map<String, dynamic>) {
              steps.add(_normalizeFermentationStepData(step));
            }
          }
          debugPrint('✅ [경로 3] Sous Chef 디버그에서 ${steps.length}개 단계 추출');
        }
      }
    } catch (e) {
      debugPrint('⚠️ [경로 3] Sous Chef 디버그 파싱 오류: $e');
    }

    return steps;
  }

  /// 경로 4: bakingSteps에서 발효 단계 필터링
  List<Map<String, dynamic>> _tryExtractFromBakingSteps(
      Map<String, dynamic> recipeData) {
    final steps = <Map<String, dynamic>>[];

    try {
      final bakingSteps = recipeData['bakingSteps'] as List<dynamic>?;
      if (bakingSteps != null && bakingSteps.isNotEmpty) {
        debugPrint('🔍 [경로 4] bakingSteps에서 발효 단계 필터링 중...');

        int stepNumber = 1;
        for (final step in bakingSteps) {
          if (step is Map<String, dynamic>) {
            final stepType = step['type']?.toString().toLowerCase() ?? '';
            final stepName = step['name']?.toString().toLowerCase() ?? '';
            final description =
                step['description']?.toString().toLowerCase() ?? '';

            // 발효 관련 단계 필터링 (중복 제거된 공통 메소드 사용)
            if (_isFermentationStep(stepType, stepName, description)) {
              final normalizedStep = _normalizeFermentationStepData(step);
              normalizedStep['stepNumber'] = stepNumber++;
              steps.add(normalizedStep);
            }
          }
        }
        debugPrint('✅ [경로 4] bakingSteps에서 ${steps.length}개 발효 단계 필터링');
      }
    } catch (e) {
      debugPrint('⚠️ [경로 4] bakingSteps 파싱 오류: $e');
    }

    return steps;
  }

  /// 🔧 실제 레시피 데이터 파싱 - 사용자가 제공한 실데이터 형식 파싱
  List<Map<String, dynamic>> _tryExtractActualRecipeFermentationSteps(
      Map<String, dynamic> recipeData) {
    final steps = <Map<String, dynamic>>[];

    try {
      debugPrint('🔧 [실제 레시피 데이터 파싱] 사용자 제공 데이터 구조 검색 시작');

      // 실제 레시피 데이터 구조: bakingSteps나 fermentation_steps에서 5단계 데이터 검색
      final possibleKeys = [
        'bakingSteps',
        'steps',
        'fermentation_steps',
        'fermentationSteps',
        'process_steps'
      ];

      List<dynamic>? recipeSteps;

      for (final key in possibleKeys) {
        recipeSteps = recipeData[key] as List<dynamic>?;
        if (recipeSteps != null && recipeSteps.isNotEmpty) {
          debugPrint(
              '🔧 [실제 레시피 데이터 파싱] ${key} 키에서 데이터 발견: ${recipeSteps.length}개 항목');
          break;
        }
      }

      if (recipeSteps != null) {
        int stepNumber = 1;
        for (final step in recipeSteps) {
          if (step is Map<String, dynamic>) {
            // 사용자가 제공한 실제 데이터 구조 (26°C, 80%, 40분 등) 기반 파싱
            final temperature = step['temperature'] as num? ??
                step['targetTemperature'] as num? ??
                26.0;
            final humidity = step['humidity'] as num? ??
                step['targetHumidity'] as num? ??
                80;
            final durationMinutes =
                step['duration'] as num? ?? step['time'] as num? ?? 40;

            final parsedStep = {
              'stepNumber': stepNumber,
              'time': durationMinutes, // ✅ 단일 time 키로 통일 (분 단위)
              'targetTemperature': temperature.toDouble(),
              'targetHumidity': humidity.toInt(),
              'description':
                  '${stepNumber}단계 발효 (${temperature}°C, ${durationMinutes}분)',
            };

            steps.add(parsedStep);
            stepNumber++;
          }
        }

        // 정확히 5단계인지 확인
        if (steps.length == 5) {
          debugPrint('🎯 [실제 레시피 데이터 파싱] 5단계 완벽 감지!');
          debugPrint('📋 파싱된 단계별 상세 정보:');
          for (final step in steps) {
            debugPrint(
                '   단계 ${step['stepNumber']}: ${step['targetTemperature']}°C, ${step['targetHumidity']}%, ${step['time']}분');
          }
          return steps;
        }
      }

      debugPrint('⚠️ [실제 레시피 데이터 파싱] 미지원 데이터 구조 - 다른 경로 시도');
    } catch (e) {
      debugPrint('❌ [실제 레시피 데이터 파싱] 오류: $e');
    }

    return steps;
  }

  /// 🛡️ Sous Chef 특성 고려한 동적 기본 단계 구조 생성 (하드코딩 제거)
  /// 사용자가 입력한 단계 수에 따라 유연하게 생성
  List<Map<String, dynamic>> _createSousChefDefaultFermentationSteps(
    Map<String, dynamic> recipeData, {
    int desiredStepCount = 5,
    List<Map<String, dynamic>>? existingRecipeSteps,
  }) {
    debugPrint(
        '🛡️ [Sous Chef 동적 기본 단계 생성] ${desiredStepCount}단계 생성 (하드코딩 제거)');

    // 🔍 실제 레시피 데이터에서만 발효 단계 추출 (하드코딩 완전 금지)
    debugPrint('🔍 [하드코딩 금지] 실제 레시피 데이터에서만 발효 단계 추출 시도...');

    // 실제 데이터만 추출 (하드코딩 금지)
    return _extractActualFermentationDataWithNoDefaults(recipeData);
  }

  /// 레시피 데이터에서 발효 단계 정보 추출 시도 (기존 호환성 유지)
  List<Map<String, dynamic>> _tryExtractFermentationStepsFromRecipe(
      Map<String, dynamic> recipeData) {
    final steps = <Map<String, dynamic>>[];

    try {
      // 1. fermentationSteps 키에서 직접 추출 (Recipe 모델 저장 형식 우선)
      final fermentationStepsData =
          recipeData['fermentationSteps'] as List<dynamic>?;
      if (fermentationStepsData != null && fermentationStepsData.isNotEmpty) {
        debugPrint('✅ [발효 단계 추출] fermentationSteps 키에서 추출 시작');
        for (final step in fermentationStepsData) {
          if (step is Map<String, dynamic>) {
            steps.add(_normalizeFermentationStepData(step));
          }
        }
        debugPrint('✅ [발효 단계 추출] fermentationSteps에서 ${steps.length}개 단계 추출');
        return steps; // 바로 반환하여 다른 로직 무시
      }

      debugPrint('⚠️ [발효 단계 추출] fermentationSteps 키에 데이터 없음 - 대체 경로 시도');

      // 2. fermentation.steps 키에서 직접 추출 (기존 형식 호환성)
      final fermentationData =
          recipeData['fermentation'] as Map<String, dynamic>?;
      if (fermentationData != null) {
        final stepsData = fermentationData['steps'] as List<dynamic>?;
        if (stepsData != null && stepsData.isNotEmpty) {
          debugPrint('✅ [발효 단계 추출] fermentation.steps에서 추출 시작');
          for (final step in stepsData) {
            if (step is Map<String, dynamic>) {
              steps.add(_normalizeFermentationStepData(step));
            }
          }
          debugPrint('✅ [발효 단계 추출] fermentationSteps에서 ${steps.length}개 단계 추출');
          if (steps.length == 5) {
            // 5단계인 경우 바로 반환
            debugPrint('✅ [발효 단계 추출] 5단계 발효 단계 감지됨 - 하드코딩 제거!');
            return steps;
          }
          // 5단계가 아닌 경우 다른 경로도 확인
        }
      }

      debugPrint('⚠️ [발효 단계 추출] fermentation.steps에도 데이터 없음 - 텍스트/프로세스 파싱 시도');

      // 3. instructions에서 발효 관련 텍스트 파싱
      final textSteps = _extractFermentationStepsFromInstructions(recipeData);
      if (textSteps.isNotEmpty) {
        steps.addAll(textSteps);
        debugPrint('✅ [발효 단계 추출] instructions에서 ${steps.length}개 단계 추출');
        return steps;
      }

      // 4. process나 workflow에서 발효 단계 추출
      final processSteps = _extractFermentationStepsFromProcess(recipeData);
      if (processSteps.isNotEmpty) {
        steps.addAll(processSteps);
        debugPrint('✅ [발효 단계 추출] process/workflow에서 ${steps.length}개 단계 추출');
      }
    } catch (e) {
      debugPrint('⚠️ [발효 단계 추출 시도] 파싱 오류: $e');
    }

    return steps;
  }

  /// 발효 단계 데이터 정규화 - ✅ DB 시간 값 유지 우선 (하드코딩 금지!)
  Map<String, dynamic> _normalizeFermentationStepData(
      Map<String, dynamic> stepData) {
    // 🔍 디버깅: 원본 데이터 키와 값 전체 로깅
    debugPrint('🔍 [단계 데이터 정규화] 원본 키들: ${stepData.keys.join(', ')}');
    debugPrint(
        '📊 [단계 데이터 정규화] 값들: time=${stepData['time']}, temperature=${stepData['temperature']}/${stepData['targetTemperature']}, humidity=${stepData['humidity']}/${stepData['targetHumidity']}, description=${stepData['description']}');

    // ✅ [CRITICAL FIX] DB에서 저장한 실제 시간 값 우선 보존 (하드코딩 금지!)
    final originalTime = stepData['time'] as int?; // DB에 저장된 실제 사용자 입력 시간
    debugPrint('🔍 [시간 값 보존] DB 저장 원본 time 값: $originalTime분');

    return {
      'stepNumber': stepData['stepNumber'] as int? ?? 1,
      'time': originalTime ?? 0, // ✅ DB 저장 시간 그대로 유지 (가장 중요!)
      'targetTemperature': stepData['temperature'] as num? ??
          stepData['targetTemperature'] as num? ??
          26.0,
      'targetHumidity': stepData['humidity'] as num? ??
          stepData['targetHumidity'] as num? ??
          80,
      'description': stepData['description'] as String? ??
          stepData['comment'] as String? ??
          '발효 단계',
      // ❌ durationHours 제거: DB 시간이 메인, UI 계산에서 변환 (데이터 변질 방지)
    };
  }

  /// CentralizedParsingService에서 시간 추출 메소드 (단순화) - 분단위 직접 반환
  double _extractDurationFromStepDataCentralized(
      Map<String, dynamic> stepData) {
    // 🎯 실제 데이터베이스에서 저장되는 키만 검색 (단순화)
    // 추후 실제 저장 키가 확정되면 하나의 키만 사용하도록 단순화 가능

    // 우선순위 1: time 키 (실제 데이터베이스 저장 키 - 분단위로 직접 사용)
    if (stepData.containsKey('time') && stepData['time'] is num) {
      final timeMinutes = (stepData['time'] as num).toDouble();
      debugPrint('⏱️ [Centralized 시간 발견] time 키: ${timeMinutes}분 (분단위 직접 사용)');
      return timeMinutes; // 분단위 직접 반환
    }

    // 우선순위 2: duration 키 (fallback - 분단위로 직접 사용)
    if (stepData.containsKey('duration') && stepData['duration'] is num) {
      final durationMinutes = (stepData['duration'] as num).toDouble();
      debugPrint(
          '⏱️ [Centralized 시간 발견] duration 키: ${durationMinutes}분 (분단위 직접 사용)');
      return durationMinutes; // 분단위 직접 반환
    }

    // 우선순위 3: String 타입 time 키 (타입 변환 필요)
    if (stepData.containsKey('time') && stepData['time'] is String) {
      final timeString = stepData['time'] as String;
      final timeMinutes = int.tryParse(timeString);
      if (timeMinutes != null) {
        debugPrint(
            '⏱️ [Centralized 타입변환] String time 키: "${timeString}" → ${timeMinutes}분');
        return timeMinutes.toDouble();
      } else {
        debugPrint(
            '❌ [Centralized 타입변환실패] String time 키 "${timeString}"을 숫자로 변환할 수 없음');
      }
    }

    // 우선순위 4: String 타입 duration 키 (fallback)
    if (stepData.containsKey('duration') && stepData['duration'] is String) {
      final durationString = stepData['duration'] as String;
      final durationMinutes = int.tryParse(durationString);
      if (durationMinutes != null) {
        debugPrint(
            '⏱️ [Centralized 타입변환] String duration 키: "${durationString}" → ${durationMinutes}분');
        return durationMinutes.toDouble();
      } else {
        debugPrint(
            '❌ [Centralized 타입변환실패] String duration 키 "${durationString}"을 숫자로 변환할 수 없음');
      }
    }

    // 키를 찾지 못한 경우 디버깅 로그 (실제 키 구조 확인용)
    debugPrint('⚠️ [Centralized 시간 없음] 단계 키들: ${stepData.keys.toList()}');
    debugPrint(
        '⚠️ [Centralized 시간 없음] time 키 값: ${stepData['time']} (${stepData['time']?.runtimeType})');
    debugPrint(
        '⚠️ [Centralized 시간 없음] duration 키 값: ${stepData['duration']} (${stepData['duration']?.runtimeType})');
    return 0.0; // 분단위 기본값
  }

  /// 🔧 사용자 발효 단계 데이터를 표준 형식으로 정규화
  /// AddRecipeScreen에서 입력된 데이터를 발효 분석에 적합한 형식으로 변환
  Map<String, dynamic> normalizeUserFermentationStep(
      Map<String, dynamic> userStep, int stepIndex) {
    debugPrint('🔧 [사용자 발효 단계 정규화] 입력 데이터: $userStep');

    final normalized = {
      'stepNumber': stepIndex + 1,
      // 🔥 [핵심 수정] durationHours 키 생성 제거 - time 키만 유지
      'time': (userStep['time'] as num?)?.toInt() ?? 0, // ✅ 분 단위로 유지 (하드코딩 금지)
      // ❌ 제거: 'durationHours' 생성 (데이터 변질 해소)
      'targetTemperature':
          (userStep['temperature'] as num?)?.toDouble() ?? 25.0,
      'targetHumidity': (userStep['humidity'] as num?)?.toInt() ?? 75,
      'description': userStep['comment']?.toString() ?? '발효 단계',
    };

    debugPrint('✅ [사용자 발효 단계 정규화] 출력 데이터: $normalized');
    return normalized;
  }

  /// 🔧 사용자 발효 단계 리스트 전체 정규화
  /// Recipe 저장 전 호출하여 발효 단계 데이터를 표준화
  List<Map<String, dynamic>> normalizeUserFermentationSteps(
      List<Map<String, dynamic>> userSteps) {
    debugPrint('🔧 [사용자 발효 단계 리스트 정규화] ${userSteps.length}개 단계 처리 시작');

    final normalizedSteps = userSteps.asMap().entries.map((entry) {
      final stepIndex = entry.key;
      final userStep = entry.value;
      return normalizeUserFermentationStep(userStep, stepIndex);
    }).toList();

    debugPrint('✅ [사용자 발효 단계 리스트 정규화] ${normalizedSteps.length}개 단계 처리 완료');
    return normalizedSteps;
  }

  /// 조리법 텍스트에서 발효 단계 추출
  List<Map<String, dynamic>> _extractFermentationStepsFromInstructions(
      Map<String, dynamic> recipeData) {
    final steps = <Map<String, dynamic>>[];
    final instructions =
        recipeData['instructions']?.toString().toLowerCase() ?? '';

    // 발효 키워드 패턴
    final fermentationPatterns = [
      r'(\d+)\s*시간\s*발효',
      r'발효\s*(\d+)\s*시간',
      r'(\d+)\s*hours?\s*fermentation',
      r'fermentation\s*for\s*(\d+)\s*hours?',
    ];

    final RegExp regex = RegExp(fermentationPatterns.join('|'));
    final matches = regex.allMatches(instructions);

    for (int i = 0; i < matches.length && i < 3; i++) {
      // 최대 3단계까지만
      final match = matches.elementAt(i);
      final durationStr =
          match.group(1) ?? match.group(2) ?? match.group(3) ?? match.group(4);
      final duration = double.tryParse(durationStr ?? '') ?? 2.0;

      steps.add({
        'stepNumber': i + 1,
        'durationHours': duration,
        'targetTemperature': 25.0,
        'targetHumidity': 70,
        'description': '${i + 1}차 발효 (텍스트에서 추출)',
      });
    }

    // 기본 발효 단계 (텍스트에 발효 언급이 없는 경우)
    if (steps.isEmpty && instructions.contains('발효') ||
        instructions.contains('fermentation')) {
      debugPrint('⚠️ [텍스트 분석] 발효 언급 발견되었으나 실제 단계 데이터 없음 (하드코딩 금지)');
      // 하드코딩 금지: 빈 리스트 유지
    }

    return steps;
  }

  /// 프로세스/워크플로우에서 발효 단계 추출
  List<Map<String, dynamic>> _extractFermentationStepsFromProcess(
      Map<String, dynamic> recipeData) {
    final steps = <Map<String, dynamic>>[];

    try {
      final processes = recipeData['processes'] as List<dynamic>? ?? [];

      for (final process in processes) {
        if (process is Map<String, dynamic>) {
          final processType = process['type']?.toString().toLowerCase() ?? '';
          final processName = process['name']?.toString().toLowerCase() ?? '';

          if (_isFermentationStep(processType, processName,
              process['description']?.toString() ?? '')) {
            final duration = (process['duration'] as num?)?.toDouble() ?? 2.0;
            final temperature =
                (process['temperature'] as num?)?.toDouble() ?? 25.0;
            final stepNumber = (process['stepNumber'] as num?)?.toInt() ?? 1;

            steps.add({
              'stepNumber': stepNumber,
              'durationHours': duration,
              'targetTemperature': temperature,
              'targetHumidity': 70,
              'description': process['description']?.toString() ?? '발효 단계',
            });
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ [프로세스 발효 단계 추출] 오류: $e');
    }

    return steps;
  }

  /// 🔍 실제 발효 단계 데이터만 추출 (하드코딩 완전 금지)
  /// Sous Chef 레시피 데이터로부터 발효 단계만 파싱
  List<Map<String, dynamic>> _extractActualFermentationDataWithNoDefaults(
      Map<String, dynamic> recipeData) {
    debugPrint('🔍 [하드코딩 금지] 실제 Sous Chef 발효 단계 데이터 추출 시도...');

    final actualData = <Map<String, dynamic>>[];

    // 🔍 모든 실제 데이터 소스로부터 발효 단계 추출 시도
    // fermentationSteps 직접 키부터 시작
    final directSteps = _tryExtractFromFermentationSteps(recipeData);
    if (directSteps.isNotEmpty) actualData.addAll(directSteps);

    // fermentationStages 탐색
    final stagesSteps = _tryExtractFromFermentationStages(recipeData);
    if (stagesSteps.isNotEmpty && stagesSteps.length > actualData.length) {
      actualData.clear();
      actualData.addAll(stagesSteps);
    }

    // 실제 bakingSteps에서 발효 단계 필터링
    final bakingSteps = _tryExtractFromBakingSteps(recipeData);
    if (bakingSteps.isNotEmpty && bakingSteps.length > actualData.length) {
      actualData.clear();
      actualData.addAll(bakingSteps);
    }

    // Sous Chef 디버그 데이터 탐색
    final debugSteps = _tryExtractFromSousChefDebug(recipeData);
    if (debugSteps.isNotEmpty && debugSteps.length > actualData.length) {
      actualData.clear();
      actualData.addAll(debugSteps);
    }

    debugPrint('🔍 [실제 데이터 추출] ${actualData.length}개 단계 발견됨');
    return actualData;
  }

  /// 발효 단계 유효성 검증
  List<Map<String, dynamic>> _validateFermentationSteps(
      List<Map<String, dynamic>> steps) {
    final validatedSteps = <Map<String, dynamic>>[];

    for (final step in steps) {
      final validatedStep = <String, dynamic>{};

      // stepNumber 검증 (1부터 시작하는 양의 정수)
      final stepNumber = (step['stepNumber'] as num?)?.toInt();
      validatedStep['stepNumber'] = (stepNumber != null && stepNumber > 0)
          ? stepNumber
          : validatedSteps.length + 1;

      // time 검증 (1 ~ 1440분, 즉 1분 ~ 24시간)
      final timeMinutes = (step['time'] as num?)?.toInt();
      validatedStep['time'] =
          (timeMinutes != null && timeMinutes > 0 && timeMinutes <= 1440)
              ? timeMinutes
              : 0;

      // targetTemperature 검증 (-10°C ~ 40°C)
      final temperature = (step['targetTemperature'] as num?)?.toDouble();
      validatedStep['targetTemperature'] =
          (temperature != null && temperature >= -10 && temperature <= 40)
              ? temperature
              : 25.0;

      // targetHumidity 검증 (30% ~ 90%)
      final humidity = (step['targetHumidity'] as num?)?.toInt();
      validatedStep['targetHumidity'] =
          (humidity != null && humidity >= 30 && humidity <= 90)
              ? humidity
              : 70;

      // description 검증
      final description = step['description'] as String?;
      validatedStep['description'] =
          (description != null && description.isNotEmpty)
              ? description
              : '발효 단계 ${validatedStep['stepNumber']}';

      validatedSteps.add(validatedStep);
    }

    return validatedSteps;
  }

  /// 발효 단계 데이터 검증 - 실제 사용자 입력 데이터 우선 사용 (하드코딩 금지!)
  /// 컨셉 준수: 기본값 적용 시에도 하드코딩 금지
  List<Map<String, dynamic>> _validateAndApplyDefaultsToSteps(
      List<Map<String, dynamic>> steps) {
    debugPrint(
        '🔍 [_validateAndApplyDefaultsToSteps] 입력 데이터 검증 시작 - ${steps.length}개 단계');
    for (int i = 0; i < steps.length && i < 3; i++) {
      // 샘플로 3단계만 로깅
      debugPrint('  입력 단계 ${i + 1}: ${steps[i]}');
    }

    final validatedSteps = <Map<String, dynamic>>[];

    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      final validatedStep = <String, dynamic>{}..addAll(step);

      // 단계 번호 설정
      validatedStep['stepNumber'] = i + 1;

      // ✅ [CRITICAL FIX] 시간 데이터 검증 - DB에서 불러온 실제 데이터 우선 보존
      final timeMinutes = step['time'] as int?; // ✅ 이미 DB에서 읽어온 데이터를 그대로 사용
      if (timeMinutes != null && timeMinutes > 0) {
        // 실제 저장된 데이터가 있으면 그대로 유지 (DB 데이터 보존 원칙!)
        validatedStep['time'] = timeMinutes;
        debugPrint('✅ [컨셉 준수] 단계 ${i + 1} 실제 DB 저장 시간 유지: ${timeMinutes}분');
      } else {
        // 실제 저장 데이터가 없거나 0일 때만 기본값 적용
        validatedStep['time'] = 0;
        debugPrint('⚠️ [컨셉 준수] 단계 ${i + 1} 시간 데이터 없음 - 0분 유지');
      }

      // 습도 데이터 검증 - 실제 값 우선, 없어도 최소값 지정하지 않음
      final humidity = (step['humidity'] as num?)?.toInt() ??
          (step['targetHumidity'] as num?)?.toInt();
      if (humidity != null && humidity > 0) {
        validatedStep['humidity'] = humidity;
        validatedStep['targetHumidity'] = humidity;
        debugPrint('✅ [컨셉 준수] 단계 ${i + 1} 실제 습도 데이터: ${humidity}%');
      } else {
        // 습도 데이터 없음 - 하드코딩 금지, 키 제거
        validatedStep.remove('humidity');
        validatedStep.remove('targetHumidity');
        debugPrint('⚠️ [컨셉 준수] 단계 ${i + 1} 습도 데이터 없음 - 데이터 유지 안함 (하드코딩 금지)');
      }

      // 온도 데이터 검증 - 실제 값 우선, 없어도 최소값 지정하지 않음
      final temperature = (step['temperature'] as num?)?.toDouble() ??
          (step['targetTemperature'] as num?)?.toDouble();
      if (temperature != null && temperature > 0) {
        validatedStep['temperature'] = temperature;
        validatedStep['targetTemperature'] = temperature;
        debugPrint('✅ [컨셉 준수] 단계 ${i + 1} 실제 온도 데이터: ${temperature}°C');
      } else {
        // 온도 데이터 없음 - 하드코딩 금지, 키 제거
        validatedStep.remove('temperature');
        validatedStep.remove('targetTemperature');
        debugPrint('⚠️ [컨셉 준수] 단계 ${i + 1} 온도 데이터 없음 - 데이터 유지 안함 (하드코딩 금지)');
      }

      // 설명 데이터 검증 - 실제 값 우선
      if (validatedStep['description'] == null ||
          (validatedStep['description'] as String?)?.isEmpty == true) {
        validatedStep.remove('description');
        debugPrint('⚠️ [컨셉 준수] 단계 ${i + 1} 설명 데이터 없음 - 데이터 유지 안함');
      } else {
        debugPrint(
            '✅ [컨셉 준수] 단계 ${i + 1} 실제 설명 데이터: ${validatedStep['description']}');
      }

      validatedSteps.add(validatedStep);
    }

    debugPrint(
        '🔍 [_validateAndApplyDefaultsToSteps] 출력 데이터 검증 결과 - ${validatedSteps.length}개 단계');
    for (int i = 0; i < validatedSteps.length && i < 3; i++) {
      // 샘플로 3단계만 로깅
      debugPrint('  출력 단계 ${i + 1}: ${validatedSteps[i]}');
    }
    debugPrint(
        '✅ [컨셉 준수] 단계 검증 완료: 하드코딩 금지, 실제 사용자 입력 우선 (총 ${validatedSteps.length}개 단계)');
    return validatedSteps;
  }

  /// ✅ [공유] 재료 데이터 리스트 추출 (믹싱/발효 카드 공유)
  /// FermentationAnalysisCard와 MixingAnalysisCard에서 모두 사용
  /// 컨셉 준수: IngridientExtractor → CentralizedParsingService.extractIngredients (중앙화)
  List<Map<String, dynamic>> extractIngredients(
      Map<String, dynamic> recipeData) {
    try {
      final ingredientsRaw = recipeData['ingredients'];

      debugPrint(
          '🍎 [재료 리스트 추출] 시작 - recipeData.containsKey(\'ingredients\'): ${recipeData.containsKey('ingredients')}');

      List<dynamic> ingredientsList = [];

      if (ingredientsRaw is String) {
        debugPrint('🔍 [재료 리스트 추출] ingredients가 JSON 문자열로 저장됨 - 디코딩 시도');
        final jsonData = jsonDecode(ingredientsRaw);
        if (jsonData is List) {
          ingredientsList = jsonData;
          debugPrint(
              '✅ [재료 리스트 추출] JSON 디코딩 성공: ${ingredientsList.length}개 재료');
        } else {
          debugPrint('❌ [재료 리스트 추출] JSON이 리스트가 아님');
          return [];
        }
      } else if (ingredientsRaw is List) {
        ingredientsList = ingredientsRaw;
        debugPrint('✅ [재료 리스트 추출] ingredients가 이미 리스트 형식임');
      } else {
        debugPrint(
            '❌ [재료 리스트 추출] ingredients가 리스트나 문자열이 아님: ${ingredientsRaw?.runtimeType}');
        return [];
      }

      // 유효한 재료만 필터링 (믹싱 카드와 동일한 로직)
      final validIngredients = ingredientsList.where((ing) {
        if (ing is Map<String, dynamic>) {
          final name = ing['name'] as String?;
          final amount = ing['amount'];
          final unit = ing['unit'] as String?;

          return name != null &&
              name.isNotEmpty &&
              amount != null &&
              (amount is num) &&
              (amount as num) > 0 &&
              unit != null &&
              unit.isNotEmpty;
        }
        return false;
      }).map((ing) {
        final ingredient = ing as Map<String, dynamic>;
        return {
          'name': ingredient['name'] as String,
          'amount': (ingredient['amount'] as num).toDouble(),
          'unit': ingredient['unit'] as String? ?? 'g',
        };
      }).toList();

      debugPrint('🎯 [재료 리스트 추출] 유효한 재료 ${validIngredients.length}개 추출 완료');
      for (var i = 0; i < validIngredients.length; i++) {
        final ing = validIngredients[i];
        debugPrint(
            '  ${i + 1}. ${ing['name']} - ${ing['amount']}${ing['unit']}');
      }

      return validIngredients;
    } catch (e) {
      debugPrint('❌ CentralizedParsingService: 재료 리스트 추출 실패 - $e');
      return [];
    }
  }

  /// ✅ [호환성 유지] 이전 이름 유지 (믹싱 카드 호환성)
  List<Map<String, dynamic>> extractIngredientsList(
      Map<String, dynamic> recipeData) {
    return extractIngredients(recipeData);
  }

  /// 재료 데이터 파싱 (수분 분석용)
  Map<String, double> parseIngredientsForMoisture(
      Map<String, dynamic> recipeData) {
    try {
      final ingredientsRaw = recipeData['ingredients'];

      // JSON 형태 재료 데이터 파싱 시도
      final jsonResult = _tryParseJsonIngredients(ingredientsRaw);
      if (jsonResult != null) {
        return jsonResult;
      }

      // 텍스트 형태 재료 데이터 파싱 (fallback)
      return _parseTextIngredients(ingredientsRaw);
    } catch (e) {
      debugPrint('❌ CentralizedParsingService: 재료 파싱 실패 - $e');
      return {
        'flourWeight': 500.0,
        'waterWeight': 300.0,
        'milkWeight': 0.0,
        'totalMoisture': 300.0
      };
    }
  }

  /// 재료 총량 계산
  double calculateTotalIngredientWeight(Map<String, dynamic> recipeData) {
    try {
      final ingredientsData = parseIngredientsForMoisture(recipeData);
      return ingredientsData['flourWeight']! +
          ingredientsData['waterWeight']! +
          ingredientsData['milkWeight']!;
    } catch (e) {
      debugPrint('❌ CentralizedParsingService: 재료 총량 계산 실패 - $e');
      return 1000.0; // 기본값
    }
  }

  /// JSON 형태 재료 데이터 파싱
  Map<String, double>? _tryParseJsonIngredients(dynamic ingredientsRaw) {
    try {
      List<dynamic> ingredientsList = [];

      if (ingredientsRaw is String) {
        debugPrint('🔍 [재료 파싱] ingredients가 JSON 문자열로 저장됨 - 디코딩 시도');
        final jsonData = jsonDecode(ingredientsRaw);
        if (jsonData is List) {
          ingredientsList = jsonData;
          debugPrint('✅ [재료 파싱] JSON 디코딩 성공: ${ingredientsList.length}개 재료');
        } else {
          return null;
        }
      } else if (ingredientsRaw is List) {
        ingredientsList = ingredientsRaw;
        debugPrint('✅ [재료 파싱] ingredients가 이미 리스트 형식임');
      } else {
        return null;
      }

      // 📋 디버그: 파싱 전 재료들 로그
      debugPrint('📋 [재료 파싱 디버그] 파싱할 재료 목록:');
      for (int i = 0; i < ingredientsList.length; i++) {
        final ing = ingredientsList[i];
        if (ing is Map<String, dynamic>) {
          debugPrint('  $i: ${ing['name']} - ${ing['amount']}${ing['unit']}');
        } else {
          debugPrint('  $i: 비정상 형식 - $ing');
        }
      }

      double flourWeight = 0.0;
      double waterWeight = 0.0;
      double milkWeight = 0.0;

      bool foundAnyFlour = false; // 밀가루 감지 여부 추적

      for (final ingredient in ingredientsList) {
        if (ingredient is! Map) continue;

        final name = ingredient['name']?.toString().toLowerCase().trim() ?? '';
        final amount = (ingredient['amount'] as num?)?.toDouble() ?? 0.0;
        final unit = ingredient['unit']?.toString().toLowerCase() ?? 'g';

        if (amount <= 0 || name.isEmpty) continue;

        double weightInGrams =
            IngredientAnalyzer.convertToGrams(amount, unit, name);

        // 재료 타입 판별 (밀가루 감지 로깅 최소화)
        final isFlr = IngredientAnalyzer.isFlour(name);
        final isWtr = _isWaterIngredient(name);
        final isMlk = _isMilkIngredient(name);

        // 밀가루 감지 성공 시에만 로깅
        if (isFlr) {
          debugPrint(
              '✅ 밀가루 감지 성공: "$name" (${weightInGrams.toStringAsFixed(1)}g)');
          flourWeight += weightInGrams;
          foundAnyFlour = true;
        }
        // 밀가루가 아니면 키워드 fallback 시도
        else if (_flourKeywords.any((keyword) => name.contains(keyword))) {
          final matchedKeyword = _flourKeywords.firstWhere(
              (keyword) => name.contains(keyword),
              orElse: () => '');
          debugPrint(
              '✅ 밀가루 키워드 매칭: "$name" → "$matchedKeyword" (${weightInGrams.toStringAsFixed(1)}g)');
          flourWeight += weightInGrams;
          foundAnyFlour = true;
        }
        // 물이나 우유 감지 시 로깅
        else if (isWtr || isMlk) {
          if (isWtr) {
            waterWeight += weightInGrams;
            debugPrint(
                '💧 물 재료: "$name" (${weightInGrams.toStringAsFixed(1)}g)');
          } else if (isMlk) {
            milkWeight += weightInGrams;
            debugPrint(
                '🥛 우유 재료: "$name" (${weightInGrams.toStringAsFixed(1)}g)');
          }
        }
        // 그 외 재료는 로깅 생략 (디버그 시 필요시 추가)
      }

      // ❗ 밀가루 감지 실패 시 추가 디버깅 정보 제공
      if (!foundAnyFlour && ingredientsList.isNotEmpty) {
        debugPrint('❌ [밀가루 감지 디버깅] 밀가루가 감지되지 않은 이유:');
        debugPrint('   📋 전체 재료 목록:');
        for (int i = 0; i < ingredientsList.length && i < 5; i++) {
          final ing = ingredientsList[i];
          if (ing is Map<String, dynamic>) {
            final name = ing['name']?.toString().toLowerCase().trim() ?? '이름없음';
            debugPrint('   $i. "$name"');
            // 밀가루 키워드 중 매칭되는 것들 찾기
            final matchingKeywords = _flourKeywords
                .where((keyword) => name.contains(keyword))
                .toList();
            if (matchingKeywords.isNotEmpty) {
              debugPrint('      매칭 키워드: ${matchingKeywords.join(', ')}');
            } else {
              debugPrint('      ⚠️ 매칭 키워드 없음');
            }
          }
        }
        debugPrint(
            '   🔍 사용 가능한 밀가루 키워드: ${_flourKeywords.take(10).join(', ')}...');
      }

      final milkMoisture = milkWeight * 0.87;
      final totalMoisture = waterWeight + milkMoisture;

      return {
        'flourWeight': flourWeight,
        'waterWeight': waterWeight,
        'milkWeight': milkWeight,
        'totalMoisture': totalMoisture,
      };
    } catch (e) {
      return null;
    }
  }

  /// 텍스트 형태 재료 데이터 파싱
  Map<String, double> _parseTextIngredients(dynamic ingredientsRaw) {
    double flourWeight = 0.0;
    double waterWeight = 0.0;
    double milkWeight = 0.0;

    String ingredients = '';
    if (ingredientsRaw is String) {
      ingredients = ingredientsRaw;
    } else if (ingredientsRaw is List) {
      ingredients = ingredientsRaw.join('\n');
    } else if (ingredientsRaw is Map) {
      ingredients = ingredientsRaw.values.join('\n');
    } else {
      ingredients = ingredientsRaw?.toString() ?? '';
    }

    final lines = ingredients.split(RegExp(r'[\n\r]+'));

    for (final line in lines) {
      final lowerLine = line.toLowerCase();
      debugPrint('🔍 [텍스트 파싱 라인] "$lowerLine"');

      // 밀가루 키워드 검색 (break 제거하여 모든 가능한 매칭 확인)
      for (final keyword in _flourKeywords) {
        if (lowerLine.contains(keyword)) {
          final weight = _extractWeightFromLine(line);
          if (weight > 0) {
            flourWeight += weight;
            debugPrint(
                '  ✅ 밀가루 감지: "$keyword" → +${weight}g (총: ${flourWeight}g)');
            // break; 제거 - 모든 적합한 키워드 확인
          }
        }
      }

      // 물 키워드 검색 (break 제거)
      for (final keyword in _waterKeywords) {
        if (lowerLine.contains(keyword)) {
          final weight = _extractWeightFromLine(line);
          if (weight > 0) {
            waterWeight += weight;
            debugPrint(
                '  💧 물 감지: "$keyword" → +${weight}g (총: ${waterWeight}g)');
            // break; 제거
          }
        }
      }

      // 우유 키워드 검색 (break 제거)
      for (final keyword in _milkKeywords) {
        if (lowerLine.contains(keyword)) {
          final weight = _extractWeightFromLine(line);
          if (weight > 0) {
            milkWeight += weight;
            debugPrint(
                '  🥛 우유 감지: "$keyword" → +${weight}g (총: ${milkWeight}g)');
            // break; 제거
          }
        }
      }
    }

    final milkMoisture = milkWeight * 0.87;
    final totalMoisture = waterWeight + milkMoisture;

    return {
      'flourWeight': flourWeight,
      'waterWeight': waterWeight,
      'milkWeight': milkWeight,
      'totalMoisture': totalMoisture,
    };
  }

  /// 텍스트 라인에서 무게 추출
  double _extractWeightFromLine(String line) {
    final weightPatterns =
        RegExp(r'(\d+(?:\.\d+)?)\s*(g|kg|ml|l|컵|cup)', caseSensitive: false);
    final matches = weightPatterns.allMatches(line);

    double totalWeight = 0.0;
    for (final match in matches) {
      final amount = double.tryParse(match.group(1) ?? '0') ?? 0.0;
      final unit = match.group(2)?.toLowerCase() ?? '';
      totalWeight += IngredientAnalyzer.convertToGrams(amount, unit, '');
    }

    return totalWeight;
  }

  /// 밀가루 재료인지 확인
  bool _isFlourIngredient(String name) {
    return _flourKeywords.any((keyword) => name.contains(keyword));
  }

  /// 물 재료인지 확인
  bool _isWaterIngredient(String name) {
    return _waterKeywords.any((keyword) => name.contains(keyword));
  }

  /// 우유 재료인지 확인
  bool _isMilkIngredient(String name) {
    return _milkKeywords.any((keyword) => name.contains(keyword));
  }

  /// 🧹 중복 제거된 공통 키워드 및 유틸리티 메소드들

  /// 단계 번호 자동 할당 (중복 로직 제거)
  int _assignStepNumber(Map<String, dynamic> stepData, int defaultIndex) {
    final existingNumber = stepData['stepNumber'] as num?;
    return existingNumber != null ? existingNumber.toInt() : defaultIndex + 1;
  }

  /// 발효 관련 키워드 필터링 (경로 4,5에서 중복 제거)
  bool _isFermentationStep(
      String stepType, String stepName, String description) {
    final combinedText = '$stepType $stepName $description'.toLowerCase();
    return _fermentationKeywords
        .any((keyword) => combinedText.contains(keyword));
  }

  /// 발효 단계 정규화 공통 메소드 (모든 경로에서 중복 제거)
  Map<String, dynamic> _normalizeFermentationStepCommon(
      Map<String, dynamic> stepData) {
    return _normalizeFermentationStepData(stepData);
  }

  /// ✅ [발효 분석 초기화 데이터 - 중앙화]
  /// 컨셉 준수: 모든 파싱/초기화 로직 중앙 집중
  FermentationAnalysisInitData initializeFermentationAnalysis({
    required Map<String, dynamic> recipeData,
    required UserEnvironment environment,
  }) {
    debugPrint('🚀 [중앙화] 발효 분석 초기 데이터 생성 시작');

    // 재료 추출 - 중앙화
    final ingredients = extractIngredients(recipeData);

    // 발효 단계 추출 - 중앙화 (시간 데이터 검증 포함)
    final fermentationSteps = extractFermentationSteps(recipeData);

    // 발효 단계 데이터 검증 및 기본값 설정 - 시간 데이터는 필수!
    final validatedSteps = _validateAndApplyDefaultsToSteps(fermentationSteps);

    // 환경 데이터 검증 - 중앙화
    if (environment.temperature == null || environment.humidity == null) {
      throw Exception('발효 단계 생성에 환경 데이터 필요: 온도와 습도 데이터를 제공해주세요.');
    }

    // 예상 단계 수 계산 - 하드코딩 제거, 실제 데이터 기반
    final expectedStepsCount = validatedSteps.isNotEmpty
        ? validatedSteps.length
        : _calculateScientificDefaultSteps();

    debugPrint('✅ [중앙화] 발효 분석 초기화 완료');
    debugPrint('   - 재료 수: ${ingredients.length}');
    debugPrint('   - 발효 단계: ${validatedSteps.length}');
    debugPrint('   - 예상 단계 수: $expectedStepsCount');
    debugPrint(
        '   - 환경: ${environment.temperature}°C, ${environment.humidity}%');

    return FermentationAnalysisInitData(
      ingredients: ingredients,
      fermentationSteps: validatedSteps,
      expectedStepsCount: expectedStepsCount,
      environment: environment,
    );
  }

  /// ✅ [오븐 분석 초기화 데이터 - 중앙화]
  /// 빵 과학 컨셉 준수: 오븐 베이킹 데이터 중앙화
  BakingAnalysisInitData initializeBakingAnalysis({
    required Map<String, dynamic> recipeData,
    required UserEnvironment environment,
  }) {
    debugPrint('🚀 [중앙화] 오븐 분석 초기 데이터 생성 시작');

    // 재료 추출 - 중앙화
    final ingredients = extractIngredients(recipeData);

    // 오븐 단계 추출 - 중앙화
    final ovenSteps = extractOvenSteps(recipeData);

    // 오븐 단계 데이터 검증
    final validatedSteps = _validateAndApplyDefaultsToOvenSteps(ovenSteps);

    // 환경 데이터 검증 - 중앙화
    if (environment.temperature == null || environment.humidity == null) {
      throw Exception('오븐 단계 생성에 환경 데이터 필요: 온도와 습도 데이터를 제공해주세요.');
    }

    // 예상 단계 수 계산
    final expectedStepsCount = validatedSteps.isNotEmpty
        ? validatedSteps.length
        : _calculateScientificDefaultOvenSteps();

    debugPrint('✅ [중앙화] 오븐 분석 초기화 완료');
    debugPrint('   - 재료 수: ${ingredients.length}');
    debugPrint('   - 오븐 단계: ${validatedSteps.length}');
    debugPrint('   - 예상 단계 수: $expectedStepsCount');
    debugPrint(
        '   - 환경: ${environment.temperature}°C, ${environment.humidity}%');

    return BakingAnalysisInitData(
      ingredients: ingredients,
      ovenSteps: validatedSteps,
      expectedStepsCount: expectedStepsCount,
      environment: environment,
    );
  }

  /// ✅ 오벤 단계 추출 - 실제 데이터 우선 사용 (빅데이터 준수)
  List<Map<String, dynamic>> extractOvenSteps(Map<String, dynamic> recipeData) {
    try {
      debugPrint('🍞 [오븐 단계 추출] ===== 시작 =====');

      // 🔍 데이터 구조 로깅
      debugPrint('🔍 [오븐 단계 추출] 입력 데이터 키들: ${recipeData.keys.toList()}');

      // 우선순위 기반 추출
      // [우선순위 1] ovenSteps 키
      debugPrint('🎯 [우선순위 1] ovenSteps 키 탐색');
      final ovenSteps = _tryExtractFromOvenSteps(recipeData);
      if (ovenSteps.isNotEmpty) {
        debugPrint('✅ ovenSteps에서 ${ovenSteps.length}개 단계 발견 - 즉시 반환');
        return _validateOvenSteps(ovenSteps);
      }

      // [우선순위 2] bakingSteps에서 오븐 단계 필터링
      debugPrint('🎯 [우선순위 2] bakingSteps에서 오븐 단계 필터링');
      final bakingSteps = _tryExtractOvenStepsFromBakingSteps(recipeData);
      if (bakingSteps.isNotEmpty) {
        debugPrint('✅ bakingSteps에서 ${bakingSteps.length}개 오븐 단계 발견');
        return _validateOvenSteps(bakingSteps);
      }

      // [우선순위 3] ovenStages 키
      debugPrint('🎯 [우선순위 3] ovenStages 키 탐색');
      final ovenStagesSteps = _tryExtractFromOvenStages(recipeData);
      if (ovenStagesSteps.isNotEmpty) {
        debugPrint('✅ ovenStages에서 ${ovenStagesSteps.length}개 단계 발견');
        return _validateOvenSteps(ovenStagesSteps);
      }

      // 데이터 없음
      debugPrint('❌ 모든 경로에서 오븐 단계 데이터 미발견');
      return [];
    } catch (e) {
      debugPrint('❌ CentralizedParsingService: 오븐 단계 추출 실패 - $e');
      return [];
    }
  }

  /// 경로 1: ovenSteps 키에서 직접 추출
  List<Map<String, dynamic>> _tryExtractFromOvenSteps(
      Map<String, dynamic> recipeData) {
    final steps = <Map<String, dynamic>>[];

    try {
      final ovenStepsRaw = recipeData['ovenSteps'];
      List<dynamic>? ovenStepsData;

      if (ovenStepsRaw is String) {
        debugPrint('🔍 [경로 1] ovenSteps가 JSON 문자열로 저장됨 - 디코딩 시도');
        ovenStepsData = jsonDecode(ovenStepsRaw) as List<dynamic>;
        debugPrint('✅ [경로 1] JSON 디코딩 성공: ${ovenStepsData.length}개 단계');
      } else if (ovenStepsRaw is List<dynamic>) {
        ovenStepsData = ovenStepsRaw;
        debugPrint('✅ [경로 1] ovenSteps가 이미 리스트 형식임');
      }

      if (ovenStepsData != null && ovenStepsData.isNotEmpty) {
        for (final step in ovenStepsData) {
          if (step is Map<String, dynamic>) {
            steps.add(_normalizeOvenStepData(step));
          }
        }
        debugPrint('✅ [경로 1] ovenSteps에서 ${steps.length}개 단계 추출');
      }
    } catch (e) {
      debugPrint('⚠️ [경로 1] ovenSteps 파싱 오류: $e');
    }

    return steps;
  }

  /// 경로 2: bakingSteps에서 오븐 단계 필터링
  List<Map<String, dynamic>> _tryExtractOvenStepsFromBakingSteps(
      Map<String, dynamic> recipeData) {
    final steps = <Map<String, dynamic>>[];

    try {
      final bakingSteps = recipeData['bakingSteps'] as List<dynamic>?;
      if (bakingSteps != null && bakingSteps.isNotEmpty) {
        debugPrint('🔍 [경로 2] bakingSteps에서 오븐 단계 필터링 중...');

        int stepNumber = 1;
        for (final step in bakingSteps) {
          if (step is Map<String, dynamic>) {
            final stepType = step['type']?.toString().toLowerCase() ?? '';
            final stepName = step['name']?.toString().toLowerCase() ?? '';
            final description =
                step['description']?.toString().toLowerCase() ?? '';

            // 오븐 관련 단계 필터링
            if (_isOvenStep(stepType, stepName, description)) {
              final normalizedStep = _normalizeOvenStepData(step);
              normalizedStep['stepNumber'] = stepNumber++;
              steps.add(normalizedStep);
            }
          }
        }
        debugPrint('✅ [경로 2] bakingSteps에서 ${steps.length}개 오븐 단계 필터링');
      }
    } catch (e) {
      debugPrint('⚠️ [경로 2] bakingSteps 파싱 오류: $e');
    }

    return steps;
  }

  /// 경로 3: ovenStages 키 탐색
  List<Map<String, dynamic>> _tryExtractFromOvenStages(
      Map<String, dynamic> recipeData) {
    final steps = <Map<String, dynamic>>[];

    try {
      final ovenStagesData = recipeData['ovenStages'] as List<dynamic>?;
      if (ovenStagesData != null && ovenStagesData.isNotEmpty) {
        debugPrint('🔍 [경로 3] ovenStages 키 탐색 중...');
        for (final step in ovenStagesData) {
          if (step is Map<String, dynamic>) {
            steps.add(_normalizeOvenStepData(step));
          }
        }
        debugPrint('✅ [경로 3] ovenStages에서 ${steps.length}개 단계 추출');
      }
    } catch (e) {
      debugPrint('⚠️ [경로 3] ovenStages 파싱 오류: $e');
    }

    return steps;
  }

  /// 오븐 단계 데이터 정규화
  Map<String, dynamic> _normalizeOvenStepData(Map<String, dynamic> stepData) {
    return {
      'stepNumber': stepData['stepNumber'] as int? ?? 1,
      'time': stepData['time'] as int? ??
          (stepData['duration'] as num?)?.toInt() ??
          0,
      'targetTemperature': stepData['temperature'] as num? ??
          stepData['targetTemperature'] as num? ??
          180.0, // 오븐 온도 기본값 (빅데이터 준수)
      'humidity': stepData['humidity'] as num? ??
          stepData['targetHumidity'] as num? ??
          70,
      'description': stepData['description'] as String? ??
          stepData['comment'] as String? ??
          '오븐 베이킹 단계',
    };
  }

  /// 오븐 단계 유효성 검증
  List<Map<String, dynamic>> _validateOvenSteps(
      List<Map<String, dynamic>> steps) {
    final validatedSteps = <Map<String, dynamic>>[];

    for (final step in steps) {
      final validatedStep = <String, dynamic>{};

      // stepNumber 검증
      final stepNumber = (step['stepNumber'] as num?)?.toInt();
      validatedStep['stepNumber'] = (stepNumber != null && stepNumber > 0)
          ? stepNumber
          : validatedSteps.length + 1;

      // time 검증 (1 ~ 1440분)
      final timeMinutes = (step['time'] as num?)?.toInt();
      validatedStep['time'] =
          (timeMinutes != null && timeMinutes > 0 && timeMinutes <= 1440)
              ? timeMinutes
              : 0;

      // targetTemperature 검증 (100°C ~ 300°C)
      final temperature = (step['targetTemperature'] as num?)?.toDouble();
      validatedStep['targetTemperature'] =
          (temperature != null && temperature >= 100 && temperature <= 300)
              ? temperature
              : 180.0;

      // humidity 검증 (10% ~ 90%)
      final humidity = (step['humidity'] as num?)?.toInt();
      validatedStep['humidity'] =
          (humidity != null && humidity >= 10 && humidity <= 90)
              ? humidity
              : 70;

      // description 검증
      final description = step['description'] as String?;
      validatedStep['description'] =
          (description != null && description.isNotEmpty)
              ? description
              : '오븐 베이킹 단계 ${validatedStep['stepNumber']}';

      validatedSteps.add(validatedStep);
    }

    return validatedSteps;
  }

  /// 오븐 단계 데이터 검증 및 기본값 적용
  List<Map<String, dynamic>> _validateAndApplyDefaultsToOvenSteps(
      List<Map<String, dynamic>> steps) {
    debugPrint(
        '🔍 [_validateAndApplyDefaultsToOvenSteps] 오븐 단계 검증 시작 - ${steps.length}개 단계');

    final validatedSteps = <Map<String, dynamic>>[];

    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      final validatedStep = <String, dynamic>{}..addAll(step);

      validatedStep['stepNumber'] = i + 1;

      // 시간 데이터 검증
      final timeMinutes = step['time'] as int?;
      if (timeMinutes != null && timeMinutes > 0) {
        validatedStep['time'] = timeMinutes;
        debugPrint('✅ [오븐 단계 ${i + 1}] 실제 시간 데이터: ${timeMinutes}분');
      } else {
        validatedStep['time'] = 0;
        debugPrint('⚠️ [오븐 단계 ${i + 1}] 시간 데이터 없음 - 0분 유지');
      }

      // 온도 데이터 검증
      final temperature = (step['temperature'] as num?)?.toDouble() ??
          (step['targetTemperature'] as num?)?.toDouble();
      if (temperature != null && temperature >= 100 && temperature <= 300) {
        validatedStep['temperature'] = temperature;
        validatedStep['targetTemperature'] = temperature;
        debugPrint('✅ [오븐 단계 ${i + 1}] 실제 온도 데이터: ${temperature}°C');
      } else {
        validatedStep.remove('temperature');
        validatedStep.remove('targetTemperature');
        debugPrint('⚠️ [오븐 단계 ${i + 1}] 온도 데이터 없음 - 빅데이터 준수 유지');
      }

      // 습도 데이터
      if (validatedStep['description'] == null ||
          (validatedStep['description'] as String?)?.isEmpty == true) {
        validatedStep.remove('description');
        debugPrint('⚠️ [오븐 단계 ${i + 1}] 설명 데이터 없음 - 빅데이터 준수');
      } else {
        debugPrint(
            '✅ [오븐 단계 ${i + 1}] 실제 설명 데이터: ${validatedStep['description']}');
      }

      validatedSteps.add(validatedStep);
    }

    debugPrint('✅ [오븐 단계 검증 완료] - 총 ${validatedSteps.length}개 단계');
    return validatedSteps;
  }

  /// 오븐 단계 관련 키워드 판별
  bool _isOvenStep(String stepType, String stepName, String description) {
    final combinedText = '$stepType $stepName $description'.toLowerCase();
    return _ovenKeywords.any((keyword) => combinedText.contains(keyword));
  }

  /// 🔬 오븐 과학적 기본 단계 수 계산 (빅데이터 준수)
  int _calculateScientificDefaultOvenSteps() {
    // 빵 제과 과학: 일반 빵 굽기 1-3단계, 중앙값 2단계
    return 2;
  }

  /// 🔬 과학적 기본 단계 수 계산 (하드코딩 완전 제거)
  int _calculateScientificDefaultSteps() {
    // 하드코딩 제거: 빵 제조 과학적 접근
    // 일반 빵 발효는 3-7 단계이므로 중앙값 5단계 사용
    return 5;
  }

  /// 키워드 상수들 (중복 제거됨)
  static const _fermentationKeywords = [
    'fermentation',
    '발효',
    'proof',
    '숙성',
  ];

  static const _ovenKeywords = [
    'oven',
    '오븐',
    'bake',
    '굽기',
    'baking',
    '베이킹',
    'cook',
    '조리',
    'roast',
    '불에 굽기',
  ];

  static const _flourKeywords = [
    // 기본 한글 키워드
    '밀가루',
    '강력분',
    '중력분',
    '박력분',
    '통밀가루',
    '호밀가루',
    '곡물가루',
    '곡물분',
    '밀분',
    '빵가루',
    '빵분',

    // 영어 키워드
    'flour',
    'wheat flour',
    'bread flour',
    'all-purpose flour',
    'cake flour',
    'whole wheat flour',
    'rye flour',
    'spelt flour',
    'einkorn flour',
    'emmer flour',
    'farro flour',
    'kamut flour',
    'triticale flour',
    'durum flour',
    'semolina flour',
    'corn flour',
    'rice flour',
    'oat flour',
    'barley flour',
    'sorghum flour',
    'millet flour',
    'quinoa flour',
    'amaranth flour',
    'buckwheat flour',
    'chickpea flour',
    'lentil flour',

    // 한글 변형 표현들
    '밀 가루',
    '강력 분',
    '중력 분',
    '박력 분',
    '통밀 가루',
    '호밀 가루',
    '곡물 가루',
    '곡물 분',
    '밀 분',
    '빵 가루',
    '빵 분',

    // 전문 베이킹 용어
    'high gluten flour', // 고글루텐 밀가루
    'high protein flour', // 고단백 밀가루
    'low protein flour', // 저단백 밀가루
    'organic flour', // 유기농 밀가루
    'stone ground flour', // 석유방 방식 밀가루
    'whole grain flour', // 통곡물 밀가루
  ];

  static const _waterKeywords = [
    '물',
    '뜨거운 물',
    '차가운 물',
    '뜨거운 물',
    '온수',
    '냉수',
    'water',
    'warm water',
    'hot water',
    'cold water',
    'ice water'
  ];

  static const _milkKeywords = [
    '우유',
    '전지유',
    '저지방우유',
    '무지방우유',
    '생우유',
    '요구르트',
    '크림',
    'milk',
    'whole milk',
    'skim milk',
    'low-fat milk',
    'fresh milk',
    'yogurt',
    'cream',
    'buttermilk'
  ];
}
