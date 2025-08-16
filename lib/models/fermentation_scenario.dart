/// 발효 시나리오 모델
/// 사용자가 선택한 발효 단계들의 조합을 관리하고 분석합니다.

import 'sous_chef_models.dart';
import 'environmental_conditions.dart';

/// 발효 시나리오 클래스
class FermentationScenario {
  final String? id;
  final String? name;
  final String? description;
  final List<FermentationStage> selectedStages;
  final Map<FermentationStage, FermentationStageConfig> stageConfigs;
  final EnvironmentalConditions? environmentalConditions;
  final DateTime createdAt;

  FermentationScenario({
    this.id,
    this.name,
    this.description,
    required this.selectedStages,
    required this.stageConfigs,
    this.environmentalConditions,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 시나리오 타입 분석
  FermentationScenarioType get scenarioType {
    if (selectedStages.isEmpty) return FermentationScenarioType.none;
    
    // 일반적인 시나리오 패턴 분석
    if (selectedStages.contains(FermentationStage.bulk) && 
        selectedStages.contains(FermentationStage.finalProof)) {
      return FermentationScenarioType.standard; // 1차 + 최종발효
    }
    
    if (selectedStages.contains(FermentationStage.bulk) && 
        selectedStages.contains(FermentationStage.divided) &&
        selectedStages.contains(FermentationStage.shaped)) {
      return FermentationScenarioType.detailed; // 상세 단계별
    }
    
    if (selectedStages.contains(FermentationStage.overnight) ||
        selectedStages.contains(FermentationStage.coldRetard)) {
      return FermentationScenarioType.longFermentation; // 장시간 발효
    }
    
    if (selectedStages.length == 1) {
      return FermentationScenarioType.single; // 단일 단계
    }
    
    return FermentationScenarioType.custom; // 사용자 정의
  }

  /// 총 예상 발효 시간 계산 (분)
  double get totalEstimatedTime {
    double total = 0.0;
    for (final stage in selectedStages) {
      final config = stageConfigs[stage];
      if (config != null) {
        total += config.duration;
      }
    }
    return total;
  }

  /// 시나리오 유효성 검증
  List<String> validateScenario() {
    final warnings = <String>[];
    
    // 1. 논리적 순서 검증
    if (selectedStages.contains(FermentationStage.divided) && 
        !selectedStages.contains(FermentationStage.bulk)) {
      warnings.add('분할 후 발효를 선택했지만 1차 발효가 없습니다. 1차 발효를 추가하는 것을 권장합니다.');
    }
    
    if (selectedStages.contains(FermentationStage.shaped) && 
        !selectedStages.contains(FermentationStage.divided)) {
      warnings.add('성형 후 발효를 선택했지만 분할 과정이 없습니다. 분할 후 휴지를 추가하는 것을 권장합니다.');
    }
    
    // 2. 시간 검증
    if (totalEstimatedTime > 1440) { // 24시간 초과
      warnings.add('총 발효 시간이 24시간을 초과합니다. 과발효 위험이 있으니 주의하세요.');
    }
    
    if (totalEstimatedTime < 60) { // 1시간 미만
      warnings.add('총 발효 시간이 너무 짧습니다. 충분한 발효가 이루어지지 않을 수 있습니다.');
    }
    
    // 3. 온도 충돌 검증
    final coldStages = selectedStages.where((stage) => 
        stage == FermentationStage.coldRetard || 
        stage == FermentationStage.overnight).toList();
    final warmStages = selectedStages.where((stage) => 
        stage == FermentationStage.bulk || 
        stage == FermentationStage.finalProof).toList();
        
    if (coldStages.isNotEmpty && warmStages.isNotEmpty) {
      warnings.add('냉장 발효와 실온 발효가 함께 선택되었습니다. 온도 전환 시점을 명확히 하세요.');
    }
    
    return warnings;
  }

  /// 시나리오별 추천 재료 조정
  Map<String, double> getRecommendedAdjustments() {
    final adjustments = <String, double>{};
    final type = scenarioType;
    
    switch (type) {
      case FermentationScenarioType.standard:
        // 표준 발효: 약간의 이스트 감소
        adjustments['yeast_percentage'] = -0.1;
        break;
        
      case FermentationScenarioType.detailed:
        // 상세 단계: 이스트 더 감소, 소금 약간 증가
        adjustments['yeast_percentage'] = -0.2;
        adjustments['salt_percentage'] = 0.1;
        break;
        
      case FermentationScenarioType.longFermentation:
        // 장시간 발효: 이스트 대폭 감소, 소금 증가
        adjustments['yeast_percentage'] = -0.5;
        adjustments['salt_percentage'] = 0.2;
        adjustments['hydration'] = 1.0; // 수분 약간 증가
        break;
        
      case FermentationScenarioType.single:
        // 단일 단계: 이스트 증가
        adjustments['yeast_percentage'] = 0.2;
        break;
        
      default:
        break;
    }
    
    return adjustments;
  }

  /// 시나리오별 조언 생성
  List<String> getScenarioAdvice() {
    final advice = <String>[];
    final type = scenarioType;
    
    switch (type) {
      case FermentationScenarioType.standard:
        advice.add('🍞 표준 발효 시나리오입니다');
        advice.add('1차 발효 후 바로 최종 발효로 진행하는 일반적인 방법입니다');
        advice.add('발효 상태를 손가락 테스트로 확인하세요');
        break;
        
      case FermentationScenarioType.detailed:
        advice.add('🔬 상세 단계별 발효 시나리오입니다');
        advice.add('각 단계마다 반죽 상태를 세심하게 관찰하세요');
        advice.add('분할과 성형 사이의 휴지 시간을 충분히 주세요');
        break;
        
      case FermentationScenarioType.longFermentation:
        advice.add('⏰ 장시간 발효 시나리오입니다');
        advice.add('풍미 발달에 좋지만 과발효 위험이 있습니다');
        advice.add('냉장고 온도를 2-4°C로 유지하세요');
        break;
        
      case FermentationScenarioType.single:
        advice.add('⚡ 단일 단계 발효 시나리오입니다');
        advice.add('빠른 제빵에 적합하지만 풍미는 상대적으로 단순합니다');
        advice.add('이스트 양을 늘려 발효 시간을 단축했습니다');
        break;
        
      case FermentationScenarioType.custom:
        advice.add('🎯 사용자 정의 발효 시나리오입니다');
        advice.add('선택한 단계들의 순서와 시간을 주의깊게 관리하세요');
        break;
        
      case FermentationScenarioType.none:
        advice.add('❌ 발효 단계가 선택되지 않았습니다');
        advice.add('최소한 1차 발효는 선택하는 것을 권장합니다');
        break;
    }
    
    // 선택된 단계별 구체적 조언
    for (final stage in selectedStages) {
      advice.addAll(_getStageSpecificAdvice(stage));
    }
    
    return advice;
  }

  /// 단계별 구체적 조언
  List<String> _getStageSpecificAdvice(FermentationStage stage) {
    switch (stage) {
      case FermentationStage.bulk:
        return [
          '• 1차 발효: 반죽이 1.5-2배 부풀 때까지',
          '• 30분마다 폴딩하면 글루텐 형성에 도움됩니다'
        ];
      case FermentationStage.secondary:
        return [
          '• 2차 발효: 글루텐 구조 안정화 및 풍미 발달',
          '• 1차보다 온화한 조건에서 진행하세요'
        ];
      case FermentationStage.divided:
        return [
          '• 분할 후 휴지: 15-20분간 반죽을 쉬게 하세요',
          '• 표면이 마르지 않도록 덮개를 씌우세요'
        ];
      case FermentationStage.shaped:
        return [
          '• 성형 후 발효: 성형 스트레스를 완화시키는 단계',
          '• 10-15분 정도의 짧은 휴지가 적당합니다'
        ];
      case FermentationStage.finalProof:
        return [
          '• 최종 발효: 손가락 테스트로 80-85% 발효 확인',
          '• 과발효되면 오븐 스프링이 줄어듭니다'
        ];
      case FermentationStage.overnight:
        return [
          '• 오버나이트 발효: 8-12시간의 장시간 발효',
          '• 실온에서는 과발효 위험이 있으니 주의하세요'
        ];
      case FermentationStage.coldRetard:
        return [
          '• 냉장 숙성: 풍미 발달을 위한 저온 장시간 발효',
          '• 사용 전 1시간 정도 실온에서 적응시키세요'
        ];
    }
  }

  /// JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'selectedStages': selectedStages.map((e) => e.name).toList(),
      'stageConfigs': stageConfigs.map((k, v) => MapEntry(k.name, v.toJson())),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// JSON에서 생성
  factory FermentationScenario.fromJson(Map<String, dynamic> json) {
    final selectedStages = (json['selectedStages'] as List<dynamic>)
        .map((e) => FermentationStage.values.firstWhere((stage) => stage.name == e))
        .toList();
    
    final stageConfigs = <FermentationStage, FermentationStageConfig>{};
    final configsJson = json['stageConfigs'] as Map<String, dynamic>;
    configsJson.forEach((key, value) {
      final stage = FermentationStage.values.firstWhere((s) => s.name == key);
      stageConfigs[stage] = FermentationStageConfig.fromJson(value);
    });
    
    return FermentationScenario(
      selectedStages: selectedStages,
      stageConfigs: stageConfigs,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

/// 발효 시나리오 타입
enum FermentationScenarioType {
  none,              // 선택 없음
  single,            // 단일 단계 (예: 1차 발효만)
  standard,          // 표준 (1차 + 최종)
  detailed,          // 상세 (1차 + 분할 + 성형 + 최종)
  longFermentation,  // 장시간 발효 (오버나이트/냉장)
  custom,            // 사용자 정의
}

/// 발효 단계별 설정
class FermentationStageConfig {
  final double duration;        // 시간 (분)
  final double temperature;     // 온도 (°C)
  final double humidity;        // 습도 (%)
  final String notes;           // 메모

  const FermentationStageConfig({
    required this.duration,
    required this.temperature,
    required this.humidity,
    this.notes = '',
  });

  /// JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'duration': duration,
      'temperature': temperature,
      'humidity': humidity,
      'notes': notes,
    };
  }

  /// JSON에서 생성
  factory FermentationStageConfig.fromJson(Map<String, dynamic> json) {
    return FermentationStageConfig(
      duration: (json['duration'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      notes: json['notes'] as String? ?? '',
    );
  }

  /// 복사본 생성
  FermentationStageConfig copyWith({
    double? duration,
    double? temperature,
    double? humidity,
    String? notes,
  }) {
    return FermentationStageConfig(
      duration: duration ?? this.duration,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      notes: notes ?? this.notes,
    );
  }
}

/// 미리 정의된 발효 시나리오들
class PredefinedScenarios {
  /// 빠른 식빵 (2-3시간)
  static FermentationScenario get quickBread {
    return FermentationScenario(
      selectedStages: [FermentationStage.bulk, FermentationStage.finalProof],
      stageConfigs: {
        FermentationStage.bulk: const FermentationStageConfig(
          duration: 90,    // 1시간 30분
          temperature: 28,
          humidity: 75,
          notes: '빠른 1차 발효',
        ),
        FermentationStage.finalProof: const FermentationStageConfig(
          duration: 45,    // 45분
          temperature: 32,
          humidity: 80,
          notes: '최종 발효',
        ),
      },
    );
  }

  /// 표준 식빵 (4-5시간)
  static FermentationScenario get standardBread {
    return FermentationScenario(
      selectedStages: [
        FermentationStage.bulk,
        FermentationStage.divided,
        FermentationStage.shaped,
        FermentationStage.finalProof
      ],
      stageConfigs: {
        FermentationStage.bulk: const FermentationStageConfig(
          duration: 120,   // 2시간
          temperature: 26,
          humidity: 75,
          notes: '1차 발효',
        ),
        FermentationStage.divided: const FermentationStageConfig(
          duration: 20,    // 20분
          temperature: 24,
          humidity: 70,
          notes: '분할 후 휴지',
        ),
        FermentationStage.shaped: const FermentationStageConfig(
          duration: 15,    // 15분
          temperature: 24,
          humidity: 70,
          notes: '성형 후 휴지',
        ),
        FermentationStage.finalProof: const FermentationStageConfig(
          duration: 60,    // 1시간
          temperature: 30,
          humidity: 80,
          notes: '최종 발효',
        ),
      },
    );
  }

  /// 오버나이트 식빵 (12-16시간)
  static FermentationScenario get overnightBread {
    return FermentationScenario(
      selectedStages: [
        FermentationStage.bulk,
        FermentationStage.overnight,
        FermentationStage.finalProof
      ],
      stageConfigs: {
        FermentationStage.bulk: const FermentationStageConfig(
          duration: 60,    // 1시간
          temperature: 26,
          humidity: 75,
          notes: '짧은 1차 발효',
        ),
        FermentationStage.overnight: const FermentationStageConfig(
          duration: 720,   // 12시간
          temperature: 4,
          humidity: 85,
          notes: '냉장 오버나이트',
        ),
        FermentationStage.finalProof: const FermentationStageConfig(
          duration: 90,    // 1시간 30분
          temperature: 28,
          humidity: 80,
          notes: '실온 복귀 후 최종 발효',
        ),
      },
    );
  }

  /// 사워도우 (24-48시간)
  static FermentationScenario get sourdoughBread {
    return FermentationScenario(
      selectedStages: [
        FermentationStage.bulk,
        FermentationStage.coldRetard,
        FermentationStage.finalProof
      ],
      stageConfigs: {
        FermentationStage.bulk: const FermentationStageConfig(
          duration: 240,   // 4시간
          temperature: 24,
          humidity: 75,
          notes: '사워도우 1차 발효',
        ),
        FermentationStage.coldRetard: const FermentationStageConfig(
          duration: 1440,  // 24시간
          temperature: 2,
          humidity: 85,
          notes: '냉장 숙성',
        ),
        FermentationStage.finalProof: const FermentationStageConfig(
          duration: 120,   // 2시간
          temperature: 26,
          humidity: 80,
          notes: '실온 복귀 후 최종 발효',
        ),
      },
    );
  }

  /// 모든 미리 정의된 시나리오 목록
  static List<FermentationScenario> get allScenarios {
    return [quickBread, standardBread, overnightBread, sourdoughBread];
  }
}