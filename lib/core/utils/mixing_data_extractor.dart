// lib/core/utils/mixing_data_extractor.dart
// 믹싱 파싱 데이터 추출기 - 타입 안전한 파싱 데이터 추출

import '../../models/recipe.dart';
import '../types/mixing_aliases.dart';
import '../../../features/chef/module/bread/types/unified_types.dart'
    as unified;

/// 믹싱 파싱 데이터 추출기
/// 실제 파싱된 시간 정보와 차수 정보를 추출하여 구조화된 데이터로 변환

class MixingDataExtractor {
  // 메인 추출 엔트리 포인트
  static ExtractionResult<ParsedMixingData> extractFromRecipe(
    unified.UnifiedRecipe recipe,
  ) {
    try {
      // 1. UnifiedRecipe의 프로세스에서 믹싱 단계 추출
      final processResult = _extractFromProcesses(recipe.processes);

      if (processResult.isSuccessful) {
        return processResult;
      }

      // 2. Recipe의 레거시 데이터에서 추출 시도
      final legacyRecipe = recipe.toRecipe();
      final legacyResult = _extractFromLegacyRecipe(legacyRecipe);

      if (legacyResult.isSuccessful) {
        return legacyResult;
      }

      // 3. 기본 추정 데이터 생성
      final estimatedResult = _createEstimatedData(recipe);

      return ExtractionResult.success(estimatedResult);
    } catch (e) {
      return ExtractionResult.error('파싱 데이터 추출 실패: $e');
    }
  }

  // UnifiedRecipe 프로세스에서 추출
  static ExtractionResult<ParsedMixingData> _extractFromProcesses(
    List<unified.UnifiedProcess> processes,
  ) {
    final mixingProcesses = <MixingProcess>[];

    // 믹싱 타입 프로세스 필터링 및 변환
    for (final process in processes) {
      if (process.type == 'mixing' || process.name.contains('믹싱')) {
        final mixingProcess = _convertToMixingProcess(process);
        if (mixingProcess != null) {
          mixingProcesses.add(mixingProcess);
        }
      }
    }

    if (mixingProcesses.isEmpty) {
      return ExtractionResult.error('믹싱 프로세스를 찾을 수 없습니다');
    }

    // 차수 정보 추출 및 정렬
    final sortedProcesses = _sortByStepNumber(mixingProcesses);

    // 파싱 데이터 생성
    final parsedData = ParsedMixingData(
      processes: sortedProcesses,
      totalDuration:
          sortedProcesses.fold(0, (sum, p) => sum + p.durationMinutes),
      confidence: _calculateConfidence(sortedProcesses),
      timestamp: DateTime.now(),
    );

    return ExtractionResult.success(parsedData);
  }

  // 레거시 Recipe에서 추출
  static ExtractionResult<ParsedMixingData> _extractFromLegacyRecipe(
    Recipe recipe,
  ) {
    final mixingProcesses = <MixingProcess>[];

    // mixingSteps에서 추출 시도
    if (recipe.mixingSteps != null && recipe.mixingSteps!.isNotEmpty) {
      for (int i = 0; i < recipe.mixingSteps!.length; i++) {
        final step = recipe.mixingSteps![i];
        final mixingProcess = _convertMixingStepToProcess(step, i);
        if (mixingProcess != null) {
          mixingProcesses.add(mixingProcess);
        }
      }
    }

    // instructions에서 추출 시도
    if (mixingProcesses.isEmpty && recipe.instructions.isNotEmpty) {
      final instructionProcesses =
          _extractFromInstructions(recipe.instructions);
      mixingProcesses.addAll(instructionProcesses);
    }

    if (mixingProcesses.isEmpty) {
      return ExtractionResult.error('레거시 데이터에서 믹싱 정보를 찾을 수 없습니다');
    }

    final parsedData = ParsedMixingData(
      processes: mixingProcesses,
      totalDuration:
          mixingProcesses.fold(0, (sum, p) => sum + p.durationMinutes),
      confidence: 0.7, // 레거시 데이터는 신뢰도 중간
      timestamp: DateTime.now(),
    );

    return ExtractionResult.success(parsedData);
  }

  // 추정 데이터 생성 (파싱 데이터가 없을 때)
  static ParsedMixingData _createEstimatedData(unified.UnifiedRecipe recipe) {
    // 재료 기반 추정
    final flourAmount = _estimateFlourAmount(recipe);
    final estimatedTime = _estimateMixingTime(flourAmount);

    final estimatedProcess = MixingProcess(
      name: '추정 믹싱 단계',
      speed: '중속',
      durationMinutes: estimatedTime,
      comment: '재료 양 기반 추정치',
    );

    return ParsedMixingData(
      processes: [estimatedProcess],
      totalDuration: estimatedTime,
      confidence: 0.5, // 추정 데이터는 신뢰도 낮음
      timestamp: DateTime.now(),
    );
  }

  // UnifiedProcess를 MixingProcess로 변환
  static MixingProcess? _convertToMixingProcess(
      unified.UnifiedProcess process) {
    try {
      // 차수 정보 추출
      final stepNumber = _extractStepNumber(process.name);

      // 속도 정보 추출
      final speed = _extractSpeedFromParameters(process.parameters);

      // 시간 정보 추출
      final duration = _extractDurationFromProcess(process);

      if (speed == null || duration == null) {
        return null;
      }

      return MixingProcess(
        name: process.name,
        speed: speed,
        durationMinutes: duration,
        comment: process.parameters['comment'] ?? '',
      );
    } catch (e) {
      return null;
    }
  }

  // mixingStep을 MixingProcess로 변환
  static MixingProcess? _convertMixingStepToProcess(
    Map<String, dynamic> step,
    int index,
  ) {
    try {
      final stepName = step['name'] ?? '믹싱 ${index + 1}차';
      final speed = _normalizeSpeed(step['speed'] ?? '중속');
      final duration = _parseDuration(step['time'] ?? step['duration'] ?? 5);

      return MixingProcess(
        name: stepName,
        speed: speed,
        durationMinutes: duration,
        comment: step['comment'] ?? '',
      );
    } catch (e) {
      return null;
    }
  }

  // instructions에서 믹싱 프로세스 추출
  static List<MixingProcess> _extractFromInstructions(
    List<Map<String, dynamic>> instructions,
  ) {
    final processes = <MixingProcess>[];

    for (int i = 0; i < instructions.length; i++) {
      final instruction = instructions[i];
      final description = instruction['description']?.toString() ?? '';
      final step = instruction['step']?.toString() ?? '';

      // 믹싱 관련 키워드 확인
      if (_isMixingInstruction(description) || _isMixingInstruction(step)) {
        final process = _parseInstructionToProcess(description, step, i);
        if (process != null) {
          processes.add(process);
        }
      }
    }

    return processes;
  }

  // 차수 정보 추출
  static int _extractStepNumber(String processName) {
    // "믹싱 1차", "1차 믹싱" 등 다양한 표현에서 차수 추출
    final stepMatch = RegExp(r'(\d+)차').firstMatch(processName);
    if (stepMatch != null) {
      return int.parse(stepMatch.group(1)!);
    }

    // 순서 기반 차수 추론
    if (processName.contains('1') || processName.contains('첫')) return 1;
    if (processName.contains('2') || processName.contains('두')) return 2;
    if (processName.contains('3') || processName.contains('세')) return 3;

    return 1; // 기본값
  }

  // 속도 정보 추출
  static String? _extractSpeedFromParameters(Map<String, dynamic> parameters) {
    final speed = parameters['speed'];
    if (speed is String) {
      return _normalizeSpeed(speed);
    }
    return null;
  }

  // 시간 정보 추출
  static int? _extractDurationFromProcess(unified.UnifiedProcess process) {
    // Duration에서 시간 추출
    final duration = process.duration;
    if (duration.inMinutes > 0) {
      return duration.inMinutes;
    }

    // 파라미터에서 시간 추출
    final timeParam = process.parameters['duration_minutes'] ??
        process.parameters['duration'] ??
        process.parameters['time'];

    if (timeParam is int) {
      return timeParam;
    } else if (timeParam is String) {
      return _parseDuration(timeParam);
    }

    return null;
  }

  // 차수별 정렬
  static List<MixingProcess> _sortByStepNumber(List<MixingProcess> processes) {
    final sorted = List<MixingProcess>.from(processes);

    // 차수 정보가 있는 경우 차수별 정렬
    sorted.sort((a, b) {
      final aStep = _extractStepNumber(a.name);
      final bStep = _extractStepNumber(b.name);
      return aStep.compareTo(bStep);
    });

    return sorted;
  }

  // 신뢰도 계산
  static double _calculateConfidence(List<MixingProcess> processes) {
    if (processes.isEmpty) return 0.0;

    double totalConfidence = 0.0;

    for (final process in processes) {
      double processConfidence = 1.0;

      // 속도 정보 검증
      if (process.speed.isEmpty) processConfidence -= 0.3;

      // 시간 정보 검증
      if (process.durationMinutes <= 0) processConfidence -= 0.4;

      // 시간 범위 검증
      if (process.durationMinutes < 1 || process.durationMinutes > 30) {
        processConfidence -= 0.2;
      }

      // 차수 정보 검증
      if (_extractStepNumber(process.name) <= 0) {
        processConfidence -= 0.1;
      }

      totalConfidence += processConfidence;
    }

    return (totalConfidence / processes.length).clamp(0.0, 1.0);
  }

  // 믹싱 관련 instruction인지 확인
  static bool _isMixingInstruction(String text) {
    final mixingKeywords = [
      '반죽',
      '믹싱',
      'mixing',
      'knead',
      '혼합',
      '섞기',
      'mix',
      '저속',
      '중속',
      '고속',
      'speed',
      '속도',
      '글루텐',
      'gluten',
      '발달',
      'develop',
      '1차',
      '2차',
      '3차',
      '첫',
      '두',
      '세'
    ];

    return mixingKeywords
        .any((keyword) => text.toLowerCase().contains(keyword.toLowerCase()));
  }

  // instruction을 MixingProcess로 파싱
  static MixingProcess? _parseInstructionToProcess(
    String description,
    String step,
    int index,
  ) {
    // 속도 추출
    String speed = '중속';
    if (description.contains('저속') || description.contains('low')) {
      speed = '저속';
    } else if (description.contains('고속') || description.contains('high')) {
      speed = '고속';
    }

    // 시간 추출
    int duration = 5; // 기본값
    final timeMatch = RegExp(r'(\d+)\s*분').firstMatch(description);
    if (timeMatch != null) {
      duration = int.tryParse(timeMatch.group(1)!) ?? 5;
      duration = duration.clamp(1, 30);
    }

    // 차수 추출
    final stepNumber = _extractStepNumber(description) + index;

    return MixingProcess(
      name: '믹싱 ${stepNumber}차',
      speed: speed,
      durationMinutes: duration,
      comment: description,
    );
  }

  // 속도 정규화
  static String _normalizeSpeed(String speed) {
    final normalized = speed.toLowerCase();

    if (normalized.contains('저속') || normalized.contains('low')) {
      return '저속';
    } else if (normalized.contains('중속') || normalized.contains('medium')) {
      return '중속';
    } else if (normalized.contains('고속') || normalized.contains('high')) {
      return '고속';
    }

    return '중속'; // 기본값
  }

  // 시간 파싱
  static int _parseDuration(dynamic duration) {
    if (duration is int) {
      return duration.clamp(1, 30);
    } else if (duration is String) {
      final parsed = int.tryParse(duration);
      if (parsed != null) {
        return parsed.clamp(1, 30);
      }
    }
    return 5; // 기본값
  }

  // 밀가루 양 추정
  static double _estimateFlourAmount(unified.UnifiedRecipe recipe) {
    return recipe.ingredients
        .where((ing) =>
            ing.name.toLowerCase().contains('밀가루') ||
            ing.name.toLowerCase().contains('flour') ||
            ing.properties['type'] == 'flour')
        .fold(0.0, (sum, ing) => sum + (ing.amount ?? 0.0));
  }

  // 믹싱 시간 추정
  static int _estimateMixingTime(double flourAmount) {
    // 밀가루 100g당 0.8분으로 추정
    final estimated = (flourAmount / 100 * 0.8).round();
    return estimated.clamp(5, 20); // 5-20분 범위
  }
}

// 파싱 데이터 검증 헬퍼
class ParsingDataValidator {
  static ValidationResult validateParsedData(ParsedMixingData data) {
    final issues = <String>[];

    // 기본 구조 검증
    if (data.processes.isEmpty) {
      issues.add('믹싱 프로세스가 없습니다');
    }

    // 각 프로세스 검증
    for (int i = 0; i < data.processes.length; i++) {
      final process = data.processes[i];

      if (!process.isValid) {
        issues.add('프로세스 ${i + 1}: 유효하지 않은 데이터');
      }

      // 시간 합리성 검증
      if (process.durationMinutes < 1) {
        issues.add('프로세스 ${i + 1}: 시간이 너무 짧습니다 (${process.durationMinutes}분)');
      } else if (process.durationMinutes > 30) {
        issues.add('프로세스 ${i + 1}: 시간이 너무 깁니다 (${process.durationMinutes}분)');
      }
    }

    // 총 시간 검증
    if (data.totalDuration < 3) {
      issues.add('총 믹싱 시간이 너무 짧습니다 (${data.totalDuration}분)');
    } else if (data.totalDuration > 45) {
      issues.add('총 믹싱 시간이 너무 깁니다 (${data.totalDuration}분)');
    }

    // 신뢰도 검증
    if (data.confidence < 0.3) {
      issues.add(
          '파싱 데이터 신뢰도가 너무 낮습니다 (${(data.confidence * 100).toStringAsFixed(1)}%)');
    }

    if (issues.isEmpty) {
      return ValidationResult.success();
    } else {
      return ValidationResult.error('파싱 데이터 검증 실패: ${issues.join(", ")}');
    }
  }

  static ValidationResult validateStepSequence(List<MixingProcess> processes) {
    if (processes.isEmpty) {
      return ValidationResult.success();
    }

    final issues = <String>[];

    // 속도 전환 검증
    for (int i = 1; i < processes.length; i++) {
      final currentSpeed = processes[i].speed;
      final previousSpeed = processes[i - 1].speed;

      // 고속에서 저속으로 돌아가는 것은 비정상
      if (previousSpeed == '고속' && currentSpeed == '저속') {
        issues
            .add('프로세스 ${i + 1}: ${previousSpeed} → ${currentSpeed} 전환은 비정상적');
      }

      // 저속에서 고속으로 바로 뛰는 것은 경고
      if (previousSpeed == '저속' &&
          currentSpeed == '고속' &&
          processes.length > 2) {
        issues.add(
            '프로세스 ${i + 1}: ${previousSpeed} → ${currentSpeed} 전환은 중간 단계 필요');
      }
    }

    return issues.isEmpty
        ? ValidationResult.success()
        : ValidationResult.error('프로세스 시퀀스 검증 실패: ${issues.join(", ")}');
  }
}

// 타입 안전한 파싱 데이터 모델
class MixingProcess {
  final String name;
  final String speed;
  final int durationMinutes;
  final String comment;

  const MixingProcess({
    required this.name,
    required this.speed,
    required this.durationMinutes,
    required this.comment,
  });

  bool get isValid =>
      name.isNotEmpty &&
      speed.isNotEmpty &&
      durationMinutes > 0 &&
      durationMinutes <= 30;

  Map<String, dynamic> toJson() => {
        'name': name,
        'speed': speed,
        'durationMinutes': durationMinutes,
        'comment': comment,
      };
}

// 타입 안전한 파싱 데이터
class ParsedMixingData {
  final List<MixingProcess> processes;
  final int totalDuration;
  final double confidence;
  final DateTime timestamp;

  const ParsedMixingData({
    required this.processes,
    required this.totalDuration,
    required this.confidence,
    required this.timestamp,
  });

  bool get isValid =>
      processes.isNotEmpty &&
      totalDuration > 0 &&
      confidence >= 0.0 &&
      confidence <= 1.0;

  bool get isHighConfidence => confidence > 0.8;

  Map<String, dynamic> toJson() => {
        'processes': processes.map((p) => p.toJson()).toList(),
        'totalDuration': totalDuration,
        'confidence': confidence,
        'timestamp': timestamp.toIso8601String(),
      };
}
