import 'dart:convert';
import 'dart:developer' as developer;

/// 믹싱 데이터 추출 및 변환을 위한 헬퍼 클래스
/// 중복 코드를 제거하고 재사용성을 높이기 위해 생성
class MixingDataHelper {
  /// 로깅 레벨 설정
  static const bool _enableDetailedLogging = true;

  /// 디버그 로그 출력 헬퍼
  static void _log(String message, {String level = 'INFO'}) {
    if (!_enableDetailedLogging) return;

    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] [$level] MixingDataHelper: $message';

    switch (level) {
      case 'ERROR':
        developer.log(logMessage, level: 1000, name: 'MixingDataHelper');
        break;
      case 'WARN':
        developer.log(logMessage, level: 900, name: 'MixingDataHelper');
        break;
      case 'DEBUG':
        developer.log(logMessage, level: 500, name: 'MixingDataHelper');
        break;
      default:
        developer.log(logMessage, level: 800, name: 'MixingDataHelper');
    }
  }

  /// 레시피 데이터에서 믹싱 단계 정보를 추출
  static List<Map<String, dynamic>> extractMixingSteps(
      Map<String, dynamic> recipeData) {
    try {
      // 디버그: 레시피 데이터의 모든 키 확인
      _log('레시피 데이터 키들: ${recipeData.keys.toList()}', level: 'DEBUG');

      // 레시피 데이터에서 믹싱 단계 추출 - 다양한 키 시도
      final possibleKeys = [
        'mixingSteps',
        'mixing_steps',
        'mixingData',
        'mixing_data',
        'mixing',
        'steps',
        'process',
        'mixingProcess',
        'mixing_process',
        'mixingStages',
        'mixing_stages',
        'stages',
        'phases',
        // 실제 레시피 데이터에서 사용되는 키들 추가
        'mixingStepsData',
        'mixing_steps_data',
        'mixingStepsJson',
        'mixingStepsString',
        // JSON 파서에서 사용하는 키
        'mixingSteps',
        // Recipe 객체에서 사용하는 속성
        'mixing_steps',
      ];

      dynamic mixingData;
      String usedKey = '';

      for (final key in possibleKeys) {
        if (recipeData.containsKey(key) && recipeData[key] != null) {
          dynamic rawData = recipeData[key];
          usedKey = key;

          // JSON 문자열인 경우 파싱 시도
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
            mixingData = rawData;
            _log(
                '믹싱 데이터 키 발견: $key (타입: ${mixingData.runtimeType}, 길이: ${mixingData.length})',
                level: 'INFO');
            break;
          } else {
            _log('키 $key의 데이터가 List 타입이 아님: ${rawData.runtimeType}',
                level: 'WARN');
          }
        }
      }

      if (mixingData == null) {
        _log('믹싱 데이터가 레시피에 존재하지 않음', level: 'WARN');
        return [];
      }

      if (mixingData is! List) {
        _log('믹싱 데이터가 List 타입이 아님: ${mixingData.runtimeType}', level: 'ERROR');
        return [];
      }

      if (mixingData.isEmpty) {
        _log('믹싱 데이터 리스트가 비어있음', level: 'WARN');
        return [];
      }

      final extractedSteps = <Map<String, dynamic>>[];

      for (int i = 0; i < mixingData.length; i++) {
        try {
          final step = mixingData[i];

          if (step is Map) {
            final stepMap = Map<String, dynamic>.from(step);

            // 속도 정보 추출 - 다양한 키 시도
            final speed = _extractSpeedFromStepCard(stepMap);

            // 시간 정보 추출 - 다양한 키 시도 (time -> durationMinutes 변환)
            final duration = _extractDurationFromStepCard(stepMap);

            // 설명 정보 추출
            final comment = _extractCommentFromStepCard(stepMap, i);

            extractedSteps.add({
              'step': i + 1,
              'speed': speed,
              'durationMinutes': duration,
              'comment': comment,
              // 원본 데이터 보존
              'originalData': stepMap,
            });
          } else {
            // 문자열인 경우 기본값 사용
            extractedSteps.add({
              'step': i + 1,
              'speed': '중속',
              'durationMinutes': 5,
              'comment': step.toString(),
            });
          }
        } catch (e) {
          _log('믹싱 단계 ${i + 1} 처리 중 오류: $e', level: 'ERROR');
          // 오류가 발생한 단계는 건너뛰고 계속 진행
          continue;
        }
      }

      _log('믹싱 단계 추출 완료: ${extractedSteps.length}개 단계', level: 'INFO');
      return extractedSteps;
    } catch (e) {
      _log('믹싱 단계 추출 중 치명적 오류: $e', level: 'ERROR');
      return [];
    }
  }

  /// 레시피 데이터에서 믹싱 데이터를 가져오고 검증
  static List<Map<String, dynamic>> getMixingDataFromRecipe(
      Map<String, dynamic> recipeData) {
    final mixingData = extractMixingSteps(recipeData);

    // 믹싱 데이터가 없는 경우 기본 데이터 생성
    if (mixingData.isEmpty) {
      // 조리법에서 믹싱 관련 키워드 검색
      final instructions = recipeData['instructions']?.toString() ?? '';
      final hasDetailedMixing = hasDetailedMixingInstructions(instructions);

      if (hasDetailedMixing) {
        // 상세한 믹싱 지침이 있는 경우 더 많은 단계 생성
        mixingData.addAll([
          {
            'step': 1,
            'speed': '저속',
            'durationMinutes': 3,
            'comment': '초기 재료 혼합',
          },
          {
            'step': 2,
            'speed': '중속',
            'durationMinutes': 5,
            'comment': '본 반죽 - 글루텐 형성',
          },
          {
            'step': 3,
            'speed': '고속',
            'durationMinutes': 8,
            'comment': '본 반죽 - 본격 믹싱',
          },
          {
            'step': 4,
            'speed': '저속',
            'durationMinutes': 2,
            'comment': '마무리 및 온도 조절',
          },
        ]);
        _log('상세 믹싱 기본 데이터 생성: ${mixingData.length}개 단계', level: 'INFO');
      } else {
        // 기본 믹싱 단계
        mixingData.addAll([
          {
            'step': 1,
            'speed': '저속',
            'durationMinutes': 3,
            'comment': '초기 재료 혼합',
          },
          {
            'step': 2,
            'speed': '중속',
            'durationMinutes': 8,
            'comment': '본 반죽 - 글루텐 형성',
          },
          {
            'step': 3,
            'speed': '저속',
            'durationMinutes': 2,
            'comment': '마무리 및 온도 조절',
          },
        ]);
        _log('기본 믹싱 기본 데이터 생성: ${mixingData.length}개 단계', level: 'INFO');
      }
    }

    // 데이터 검증 및 정리
    final validatedData = validateMixingData(mixingData);
    _log('최종 믹싱 데이터 검증 완료: ${validatedData.length}개 단계', level: 'INFO');

    return validatedData;
  }

  /// 믹싱 단계 데이터 정규화
  static List<Map<String, dynamic>> normalizeMixingSteps(List<dynamic> steps) {
    final normalized = <Map<String, dynamic>>[];

    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      if (step is Map) {
        final mapData = Map<String, dynamic>.from(step);
        normalized.add(normalizeMixingStep(mapData, stepNumber: i + 1));
      }
    }

    return normalized;
  }

  /// 단일 믹싱 단계 데이터 정규화
  static Map<String, dynamic> normalizeMixingStep(Map<String, dynamic> step,
      {int stepNumber = 1}) {
    return {
      'step': step['step'] ?? step['stepNumber'] ?? stepNumber,
      'speed': normalizeSpeed(step['speed'] ?? step['speedLevel'] ?? '중속'),
      'durationMinutes': (step['durationMinutes'] ??
          step['time'] ??
          step['duration'] ??
          5) as int,
      'comment': step['comment'] ??
          step['purpose'] ??
          step['description'] ??
          '믹싱 단계 ${stepNumber}',
      'targetGluten': step['targetGluten'] ?? 0.0,
      'temperature': step['temperature'] ?? 25.0,
    };
  }

  /// 속도 값 정규화
  static String normalizeSpeed(dynamic speed) {
    if (speed == null) return '중속';

    final lowerSpeed = speed.toString().toLowerCase();

    // 한국어 속도
    if (lowerSpeed.contains('저속') ||
        lowerSpeed.contains('low') ||
        lowerSpeed.contains('slow')) {
      return '저속';
    } else if (lowerSpeed.contains('고속') ||
        lowerSpeed.contains('high') ||
        lowerSpeed.contains('fast')) {
      return '고속';
    } else if (lowerSpeed.contains('중속') ||
        lowerSpeed.contains('medium') ||
        lowerSpeed.contains('중간')) {
      return '중속';
    }

    return '중속'; // 기본값
  }

  /// RPM을 속도로 변환
  static String rpmToSpeed(double rpm) {
    if (rpm < 100) {
      return '저속';
    } else if (rpm > 180) {
      return '고속';
    } else {
      return '중속';
    }
  }

  /// 텍스트에서 믹싱 단계 파싱
  static Map<String, dynamic>? parseMixingStepFromText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;

    // "속도: 중속, 시간: 10분, 설명: 본 반죽" 형태 파싱
    final speedMatch = RegExp(r'속도[:\s]*([^,\n]+)').firstMatch(trimmed);
    final timeMatch = RegExp(r'시간[:\s]*(\d+)').firstMatch(trimmed);
    final commentMatch =
        RegExp(r'설명[:\s]*([^\n]+)|([^,\n]+)$').firstMatch(trimmed);

    if (speedMatch != null || timeMatch != null) {
      return {
        'step': 1,
        'speed': speedMatch?.group(1)?.trim() ?? '중속',
        'durationMinutes': int.tryParse(timeMatch?.group(1) ?? '5') ?? 5,
        'comment': commentMatch?.group(1)?.trim() ??
            commentMatch?.group(2)?.trim() ??
            trimmed,
      };
    }

    return null;
  }

  /// 상세한 믹싱 지침이 있는지 확인
  static bool hasDetailedMixingInstructions(String instructions) {
    final lowerInstructions = instructions.toLowerCase();

    // 상세한 믹싱 관련 키워드들
    final detailedKeywords = [
      '글루텐',
      'gluten',
      '저속',
      '중속',
      '고속',
      '본 반죽',
      '초기 반죽',
      '마무리',
      'low speed',
      'medium speed',
      'high speed',
      'knead',
      'dough development',
      'windowpane test'
    ];

    return detailedKeywords
        .any((keyword) => lowerInstructions.contains(keyword));
  }

  /// 믹싱 데이터 검증 및 정리
  static List<Map<String, dynamic>> validateMixingData(
      List<Map<String, dynamic>> data) {
    return data.map((step) {
      return {
        'step': step['step'] ?? 1,
        'speed': normalizeSpeed(step['speed'] ?? '중속'),
        'durationMinutes': (step['durationMinutes'] as int?) ?? 5,
        'comment': step['comment'] ?? '믹싱 단계',
      };
    }).toList();
  }

  /// 단계에서 속도 정보 추출 (카드용)
  static String _extractSpeedFromStepCard(Map<String, dynamic> step) {
    final speedKeys = [
      'speed',
      'mixingSpeed',
      'mixing_speed',
      'rpm',
      'rate',
      'velocity'
    ];

    for (final key in speedKeys) {
      if (step.containsKey(key)) {
        final value = step[key];
        if (value is String) {
          return normalizeSpeed(value);
        } else if (value is int || value is double) {
          return rpmToSpeed(value.toDouble());
        }
      }
    }

    return '중속'; // 기본값
  }

  /// 단계에서 시간 정보 추출 (카드용)
  static int _extractDurationFromStepCard(Map<String, dynamic> step) {
    final durationKeys = [
      'durationMinutes',
      'duration',
      'time', // 레시피 데이터에서 사용하는 키
      'minutes',
      'durationMin',
      'mixingTime',
      'mixing_time'
    ];

    for (final key in durationKeys) {
      if (step.containsKey(key)) {
        final value = step[key];
        if (value is int) {
          return value;
        } else if (value is double) {
          return value.round();
        } else if (value is String) {
          return _parseDurationStringCard(value);
        }
      }
    }

    return 5; // 기본값
  }

  /// 단계에서 설명 정보 추출 (카드용)
  static String _extractCommentFromStepCard(
      Map<String, dynamic> step, int index) {
    final commentKeys = [
      'comment',
      'description',
      'desc',
      'instruction',
      'instructions',
      'text',
      'content',
      'note'
    ];

    for (final key in commentKeys) {
      if (step.containsKey(key)) {
        final value = step[key];
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
    }

    return '믹싱 단계 ${index + 1}'; // 기본값
  }

  /// 시간 문자열 파싱 (카드용)
  static int _parseDurationStringCard(String durationStr) {
    final lowerStr = durationStr.toLowerCase();

    // 숫자 추출 시도
    final numberMatch = RegExp(r'(\d+)').firstMatch(lowerStr);
    if (numberMatch != null) {
      final minutes = int.tryParse(numberMatch.group(1) ?? '5') ?? 5;

      // 시간 단위 확인
      if (lowerStr.contains('hour') || lowerStr.contains('시간')) {
        return minutes * 60; // 시간 -> 분 변환
      }

      return minutes; // 이미 분 단위
    }

    return 5; // 기본값
  }

  /// 믹싱 데이터가 비어있는지 확인하고 보장
  static List<Map<String, dynamic>> ensureMixingDataExists(
      Map<String, dynamic> recipeData) {
    final mixingData = getMixingDataFromRecipe(recipeData);

    // 여러 차례 확인하여 빈 리스트 방지
    if (mixingData.isEmpty) {
      _log('믹싱 데이터가 여전히 비어있음, 강제 기본 데이터 생성', level: 'WARN');

      // 레시피 내용을 기반으로 더 스마트한 기본 데이터 생성
      final instructions =
          recipeData['instructions']?.toString()?.toLowerCase() ?? '';
      final title = recipeData['title']?.toString()?.toLowerCase() ?? '';

      // 빵 종류에 따른 특화된 기본 데이터
      if (title.contains('바게트') || title.contains('baguette')) {
        return [
          {
            'step': 1,
            'speed': '저속',
            'durationMinutes': 3,
            'comment': '초기 재료 혼합 (바게트용)',
          },
          {
            'step': 2,
            'speed': '중속',
            'durationMinutes': 5,
            'comment': '본 반죽 - 글루텐 형성 (바게트용)',
          },
          {
            'step': 3,
            'speed': '저속',
            'durationMinutes': 2,
            'comment': '마무리 및 온도 조절 (바게트용)',
          },
        ];
      } else if (title.contains('사워도우') || title.contains('sourdough')) {
        return [
          {
            'step': 1,
            'speed': '저속',
            'durationMinutes': 4,
            'comment': '스타터와 재료 혼합 (사워도우용)',
          },
          {
            'step': 2,
            'speed': '중속',
            'durationMinutes': 6,
            'comment': '본 반죽 - 글루텐 형성 (사워도우용)',
          },
          {
            'step': 3,
            'speed': '저속',
            'durationMinutes': 3,
            'comment': '최종 혼합 및 온도 조절 (사워도우용)',
          },
        ];
      } else {
        // 일반 빵용 기본 데이터
        return [
          {
            'step': 1,
            'speed': '저속',
            'durationMinutes': 3,
            'comment': '초기 재료 혼합',
          },
          {
            'step': 2,
            'speed': '중속',
            'durationMinutes': 8,
            'comment': '본 반죽 - 글루텐 형성',
          },
          {
            'step': 3,
            'speed': '저속',
            'durationMinutes': 2,
            'comment': '마무리 및 온도 조절',
          },
        ];
      }
    }

    return mixingData;
  }

  /// 믹싱 단계 추출 메소드 (mixing_analysis_card.dart에서 이동)
  static List<Map<String, dynamic>> extractMixingStepsFromCard(
      Map<String, dynamic> recipeData) {
    try {
      // 디버그: 레시피 데이터의 모든 키 확인
      _log('레시피 데이터 키들: ${recipeData.keys.toList()}', level: 'DEBUG');

      // 레시피 데이터에서 믹싱 단계 추출 - 다양한 키 시도
      final possibleKeys = [
        'mixingSteps',
        'mixing_steps',
        'mixingData',
        'mixing_data',
        'mixing',
        'steps',
        'process',
        'mixingProcess',
        'mixing_process',
        'mixingStages',
        'mixing_stages',
        'stages',
        'phases',
        // 실제 레시피 데이터에서 사용되는 키들 추가
        'mixingStepsData',
        'mixing_steps_data',
        'mixingStepsJson',
        'mixingStepsString',
        // JSON 파서에서 사용하는 키
        'mixingSteps',
        // Recipe 객체에서 사용하는 속성
        'mixing_steps',
      ];

      dynamic mixingData;
      String usedKey = '';

      for (final key in possibleKeys) {
        if (recipeData.containsKey(key) && recipeData[key] != null) {
          dynamic rawData = recipeData[key];
          usedKey = key;

          // JSON 문자열인 경우 파싱 시도
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
            mixingData = rawData;
            _log(
                '믹싱 데이터 키 발견: $key (타입: ${mixingData.runtimeType}, 길이: ${mixingData.length})',
                level: 'INFO');
            break;
          } else {
            _log('키 $key의 데이터가 List 타입이 아님: ${rawData.runtimeType}',
                level: 'WARN');
          }
        }
      }

      if (mixingData == null) {
        _log('믹싱 데이터가 레시피에 존재하지 않음', level: 'WARN');
        return [];
      }

      if (mixingData is! List) {
        _log('믹싱 데이터가 List 타입이 아님: ${mixingData.runtimeType}', level: 'ERROR');
        return [];
      }

      if (mixingData.isEmpty) {
        _log('믹싱 데이터 리스트가 비어있음', level: 'WARN');
        return [];
      }

      final extractedSteps = <Map<String, dynamic>>[];

      for (int i = 0; i < mixingData.length; i++) {
        try {
          final step = mixingData[i];

          if (step is Map) {
            final stepMap = Map<String, dynamic>.from(step);

            // 속도 정보 추출 - 다양한 키 시도
            final speed = _extractSpeedFromStepCard(stepMap);

            // 시간 정보 추출 - 다양한 키 시도 (time -> durationMinutes 변환)
            final duration = _extractDurationFromStepCard(stepMap);

            // 설명 정보 추출
            final comment = _extractCommentFromStepCard(stepMap, i);

            extractedSteps.add({
              'step': i + 1,
              'speed': speed,
              'durationMinutes': duration,
              'comment': comment,
              // 원본 데이터 보존
              'originalData': stepMap,
            });
          } else {
            // 문자열인 경우 기본값 사용
            extractedSteps.add({
              'step': i + 1,
              'speed': '중속',
              'durationMinutes': 5,
              'comment': step.toString(),
            });
          }
        } catch (e) {
          _log('믹싱 단계 ${i + 1} 처리 중 오류: $e', level: 'ERROR');
          // 오류가 발생한 단계는 건너뛰고 계속 진행
          continue;
        }
      }

      _log('믹싱 단계 추출 완료: ${extractedSteps.length}개 단계', level: 'INFO');
      return extractedSteps;
    } catch (e) {
      _log('믹싱 단계 추출 중 치명적 오류: $e', level: 'ERROR');
      return [];
    }
  }

  /// 단계에서 속도 정보 추출
  static String _extractSpeedFromStep(Map<String, dynamic> step) {
    final speedKeys = [
      'speed',
      'mixingSpeed',
      'mixing_speed',
      'rpm',
      'rate',
      'velocity'
    ];

    for (final key in speedKeys) {
      if (step.containsKey(key)) {
        final value = step[key];
        if (value is String) {
          return normalizeSpeed(value);
        } else if (value is int || value is double) {
          return rpmToSpeed(value.toDouble());
        }
      }
    }

    return '중속'; // 기본값
  }

  /// 단계에서 시간 정보 추출
  static int _extractDurationFromStep(Map<String, dynamic> step) {
    final durationKeys = [
      'durationMinutes',
      'duration',
      'time', // 레시피 데이터에서 사용하는 키
      'minutes',
      'durationMin',
      'mixingTime',
      'mixing_time'
    ];

    for (final key in durationKeys) {
      if (step.containsKey(key)) {
        final value = step[key];
        if (value is int) {
          return value;
        } else if (value is double) {
          return value.round();
        } else if (value is String) {
          return _parseDurationString(value);
        }
      }
    }

    return 5; // 기본값
  }

  /// 단계에서 설명 정보 추출
  static String _extractCommentFromStep(Map<String, dynamic> step, int index) {
    final commentKeys = [
      'comment',
      'description',
      'desc',
      'instruction',
      'instructions',
      'text',
      'content',
      'note'
    ];

    for (final key in commentKeys) {
      if (step.containsKey(key)) {
        final value = step[key];
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
    }

    return '믹싱 단계 ${index + 1}'; // 기본값
  }

  /// 시간 문자열 파싱
  static int _parseDurationString(String durationStr) {
    final lowerStr = durationStr.toLowerCase();

    // 숫자 추출 시도
    final numberMatch = RegExp(r'(\d+)').firstMatch(lowerStr);
    if (numberMatch != null) {
      final minutes = int.tryParse(numberMatch.group(1) ?? '5') ?? 5;

      // 시간 단위 확인
      if (lowerStr.contains('hour') || lowerStr.contains('시간')) {
        return minutes * 60; // 시간 -> 분 변환
      }

      return minutes; // 이미 분 단위
    }

    return 5; // 기본값
  }
}
