import 'dart:convert';
import 'dart:developer' as developer;

import '../../features/chef/screen/widgets/fermentation_analysis_types.dart'
    as art;

/// 발효 데이터 추출 및 변환을 위한 헬퍼 클래스
/// MixingDataHelper와 동일한 패턴으로 컨셉 준수를 보장
/// 사용자 입력 레시피에서 발효 단계들을 추출하여 실제 차수/시간/온도/습도 사용
class FermentationDataHelper {
  /// 로깅 레벨 설정
  static const bool _enableDetailedLogging = true;

  /// 디버그 로그 출력 헬퍼
  static void _log(String message, {String level = 'INFO'}) {
    if (!_enableDetailedLogging) return;

    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] [$level] FermentationDataHelper: $message';

    switch (level) {
      case 'ERROR':
        developer.log(logMessage, level: 1000, name: 'FermentationDataHelper');
        break;
      case 'WARN':
        developer.log(logMessage, level: 900, name: 'FermentationDataHelper');
        break;
      case 'DEBUG':
        developer.log(logMessage, level: 500, name: 'FermentationDataHelper');
        break;
      default:
        developer.log(logMessage, level: 800, name: 'FermentationDataHelper');
    }
  }

  /// 레시피 데이터에서 발효 단계 정보를 추출 (믹싱 패턴 동일 적용)
  /// ✅ 컨셉 준수: 사용자 입력 레시피에서 실제 발효 단계들 추출
  static List<Map<String, dynamic>> extractFermentationSteps(
      Map<String, dynamic> recipeData) {
    try {
      _log('레시피 데이터에서 발효 단계 추출 시작', level: 'INFO');

      // 레시피 데이터에서 발효 단계 추출 - 다양한 키 시도 (믹싱 패턴과 동일)
      final possibleKeys = [
        'fermentationSteps',
        'fermentation_steps',
        'fermentationData',
        'fermentation_data',
        'fermentation',
        'fermentationStages',
        'fermentation_stages',
        'stages',
        'proofingSteps',
        'proofing_steps',
        'proofing',
        // 추가 가능한 키들
        'fermentationStepsData',
        'fermentation_steps_data',
        'fermentationStepsJson',
        'fermentationStepsString',
        // Recipe 객체에서 사용하는 속성
        'fermentation_steps',
      ];

      dynamic fermentationData;
      String usedKey = '';

      for (final key in possibleKeys) {
        if (recipeData.containsKey(key) && recipeData[key] != null) {
          dynamic rawData = recipeData[key];
          usedKey = key;

          // JSON 문자열인 경우 파싱 시도 (믹싱 패턴과 동일)
          if (rawData is String) {
            try {
              rawData = jsonDecode(rawData);
              _log('JSON 문자열 파싱 성공: $key → ${rawData.runtimeType}',
                  level: 'INFO');
            } catch (e) {
              _log('JSON 파싱 실패: $key - $e', level: 'ERROR');
              continue; // 다음 키 시도
            }
          }

          // List 타입인지 확인
          if (rawData is List) {
            fermentationData = rawData;
            _log(
                '발효 데이터 키 발견: $key (타입: ${fermentationData.runtimeType}, 길이: ${fermentationData.length})',
                level: 'INFO');
            break;
          } else {
            _log('키 $key의 데이터가 List 타입이 아님: ${rawData.runtimeType}',
                level: 'WARN');
          }
        }
      }

      if (fermentationData == null) {
        _log('발효 데이터가 레시피에 존재하지 않음', level: 'WARN');
        return [];
      }

      if (fermentationData is! List) {
        _log('발효 데이터가 List 타입이 아님: ${fermentationData.runtimeType}',
            level: 'ERROR');
        return [];
      }

      if (fermentationData.isEmpty) {
        _log('발효 데이터 리스트가 비어있음', level: 'WARN');
        return [];
      }

      final extractedSteps = <Map<String, dynamic>>[];

      for (int i = 0; i < fermentationData.length; i++) {
        try {
          final step = fermentationData[i];

          if (step is Map) {
            final stepMap = Map<String, dynamic>.from(step);

            // ✅ 컨셉 준수: 실제 레시피에서 값들 추출
            final stepNumber = _extractStepNumberFromFermentationStep(stepMap);
            final duration = _extractDurationFromFermentationStep(stepMap);
            final temperature =
                _extractTemperatureFromFermentationStep(stepMap);
            final humidity = _extractHumidityFromFermentationStep(stepMap);
            final comment = _extractCommentFromFermentationStep(stepMap, i);

            // ✅ 텍스트 기반 stage 추출 (사용자 레시피 발효차수 반영)
            final stage =
                _extractFermentationStageFromFermentationStep(stepMap);

            extractedSteps.add({
              'stepNumber': stepNumber,
              'stage': stage, // 실제 사용자 발효차수 정보 추가
              'duration': duration, // 시간 (시간 단위)
              'temperature': temperature, // 온도 (°C)
              'humidity': humidity, // 습도 (%)
              'comment': comment,
              // 원본 데이터 보존 (믹싱 패턴과 동일)
              'originalData': stepMap,
            });
          } else {
            // 문자열인 경우 기본값 사용
            extractedSteps.add({
              'stepNumber': i + 1,
              'duration': 2.0, // 2시간 기본값
              'temperature': 25.0, // 실온 기본값
              'humidity': 70.0, // 일반 습도 기본값
              'comment': step.toString(),
            });
          }
        } catch (e) {
          _log('발효 단계 ${i + 1} 처리 중 오류: $e', level: 'ERROR');
          // 오류가 발생한 단계는 건너뛰고 계속 진행 (믹싱 패턴과 동일)
          continue;
        }
      }

      _log('발효 단계 추출 완료: ${extractedSteps.length}개 단계', level: 'INFO');
      return extractedSteps;
    } catch (e) {
      _log('발효 단계 추출 중 치명적 오류: $e', level: 'ERROR');
      return [];
    }
  }

  /// 단계에서 차수 정보 추출 (stepNumber/step/차수 등)
  static int _extractStepNumberFromFermentationStep(Map<String, dynamic> step) {
    final stepKeys = ['stepNumber', 'step', '차수', 'phase', 'stage', 'sequence'];

    for (final key in stepKeys) {
      if (step.containsKey(key)) {
        final value = step[key];
        if (value is int) {
          return value;
        } else if (value is String) {
          return int.tryParse(value) ?? 1;
        }
      }
    }

    return 1; // 기본값
  }

  /// 단계에서 시간 정보 추출 (시간 단위, duration/durationHours/time 등)
  static double _extractDurationFromFermentationStep(
      Map<String, dynamic> step) {
    final durationKeys = [
      'duration',
      'durationHours',
      'duration_hours',
      'time',
      'hours',
      '시간',
      '증발시간'
    ];

    for (final key in durationKeys) {
      if (step.containsKey(key)) {
        final value = step[key];
        if (value is num) {
          return value.toDouble();
        } else if (value is String) {
          return _parseDurationString(value);
        }
      }
    }

    return 2.0; // 2시간 기본값
  }

  /// 단계에서 온도 정보 추출 (온도 단위, temperature/temp/온도 등)
  static double _extractTemperatureFromFermentationStep(
      Map<String, dynamic> step) {
    final tempKeys = [
      'temperature',
      'temp',
      '온도',
      '온도c',
      '온도°C',
      'targetTemp',
      'targetTemperature'
    ];

    for (final key in tempKeys) {
      if (step.containsKey(key)) {
        final value = step[key];
        if (value is num) {
          return value.toDouble();
        } else if (value is String) {
          return _parseTemperatureString(value);
        }
      }
    }

    return 25.0; // 실온 기본값
  }

  /// 단계에서 습도 정보 추출 (퍼센트 단위, humidity/습도 등)
  static int _extractHumidityFromFermentationStep(Map<String, dynamic> step) {
    final humidityKeys = [
      'humidity',
      '습도',
      'targetHumidity',
      'target_humidity'
    ];

    for (final key in humidityKeys) {
      if (step.containsKey(key)) {
        final value = step[key];
        if (value is int) {
          return value;
        } else if (value is num) {
          return value.round();
        } else if (value is String) {
          return _parseHumidityString(value);
        }
      }
    }

    return 70; // 일반 습도 기본값
  }

  /// 단계에서 설명 정보 추출
  static String _extractCommentFromFermentationStep(
      Map<String, dynamic> step, int index) {
    final commentKeys = [
      'comment',
      'description',
      'desc',
      'instruction',
      'instructions',
      'text',
      'content',
      'note',
      '설명'
    ];

    for (final key in commentKeys) {
      if (step.containsKey(key)) {
        final value = step[key];
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
    }

    return '발효 단계 ${index + 1}'; // 기본값
  }

  /// 시간 문자열 파싱 헬퍼
  static double _parseDurationString(String durationStr) {
    final lowerStr = durationStr.toLowerCase();

    // 숫자 추출 시도
    final numberMatch = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(lowerStr);
    if (numberMatch != null) {
      final minutes = double.tryParse(numberMatch.group(1) ?? '2') ?? 2.0;

      // 시간 단위 확인
      if (lowerStr.contains('시간') || lowerStr.contains('hour')) {
        return minutes; // 이미 시간 단위
      } else if (lowerStr.contains('분') ||
          lowerStr.contains('minute') ||
          lowerStr.contains('min')) {
        return minutes / 60.0; // 분 → 시간 변환
      }

      return minutes; // 기본적으로 시간 단위로 가정
    }

    return 2.0; // 기본값
  }

  /// 온도 문자열 파싱 헬퍼
  static double _parseTemperatureString(String tempStr) {
    final numberMatch = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(tempStr);
    if (numberMatch != null) {
      return double.tryParse(numberMatch.group(1) ?? '25') ?? 25.0;
    }

    return 25.0; // 기본값
  }

  /// 습도 문자열 파싱 헬퍼
  static int _parseHumidityString(String humidityStr) {
    final numberMatch = RegExp(r'(\d+)').firstMatch(humidityStr);
    if (numberMatch != null) {
      return int.tryParse(numberMatch.group(1) ?? '70') ?? 70;
    }

    return 70; // 기본값
  }

  /// 단계에서 텍스트 기반 발효차수 추출 (사용자 레시피 발효차수 반영)
  /// ✅ 컨셉 준수: 텍스트로 작성된 발효차수를 실제 FermentationStage로 매핑
  static art.FermentationStage _extractFermentationStageFromFermentationStep(
      Map<String, dynamic> step) {
    // 발효차수를 추출할 수 있는 키들을 시도 (텍스트 우선)
    final stageKeys = [
      'stage',
      '발효단계',
      '차수이름',
      'stepType',
      'fermentationStage',
      'fermentation_stage',
      'phase',
      // 한글 키 추가
      '발효 종류',
      '단계 설정',
      '차수 설정',
    ];

    for (final key in stageKeys) {
      if (step.containsKey(key)) {
        final value = step[key];
        if (value is String) {
          final stageText = value.toLowerCase().trim();

          // 텍스트 기반 FermentationStage 매핑
          if (_isPrimaryStage(stageText)) {
            _log('✅ 텍스트 기반 차수 추출: "$value" → primary', level: 'INFO');
            return art.FermentationStage.primary;
          } else if (_isSecondaryStage(stageText)) {
            _log('✅ 텍스트 기반 차수 추출: "$value" → secondary', level: 'INFO');
            return art.FermentationStage.secondary;
          } else if (_isFinalStage(stageText)) {
            _log('✅ 텍스트 기반 차수 추출: "$value" → final_', level: 'INFO');
            return art.FermentationStage.final_;
          }
        } else if (value is art.FermentationStage) {
          _log('✅ enum 값 발견: $value', level: 'INFO');
          return value;
        }
      }
    }

    // 텍스트 추출이 안된 경우 기본값 primary 사용
    _log('⚠️ 발효차수 텍스트 미발견 - 기본값 primary 사용', level: 'WARN');
    return art.FermentationStage.primary; // 기본값
  }

  /// 1차 발효 단계 텍스트 판별
  static bool _isPrimaryStage(String stageText) {
    final primaryKeywords = [
      '1차',
      '첫 번째',
      '초기',
      '본',
      'bulk',
      '기본',
      'first',
      'initial',
      '본 발효',
      '초기 발효',
      '1차 발효',
      '본 단계',
    ];

    return primaryKeywords.any((keyword) => stageText.contains(keyword));
  }

  /// 2차 발효 단계 텍스트 판별
  static bool _isSecondaryStage(String stageText) {
    final secondaryKeywords = [
      '2차',
      '두 번째',
      '중기',
      '증해',
      'proof',
      'proofing',
      'second',
      '증해 단계',
      '2차 발효',
      '중기 발효',
      '증해 발효',
      '프루핑',
    ];

    return secondaryKeywords.any((keyword) => stageText.contains(keyword));
  }

  /// 최종 발효 단계 텍스트 판별
  static bool _isFinalStage(String stageText) {
    final finalKeywords = [
      '최종',
      '마무리',
      '풀림',
      '냉장',
      'final',
      '마무리 발효',
      '최종 발효',
      '풀림 발효',
      '냉장 발효',
      'finish',
      'completion',
      'folding',
      'refrigeration',
      '3차',
      '세 번째',
      'third',
      'late stage',
      'final stage',
    ];

    return finalKeywords.any((keyword) => stageText.contains(keyword));
  }
}
