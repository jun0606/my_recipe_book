/// 공정 메타데이터
import 'baking_phase.dart';
import '../../../services/environment_defaults_calculator.dart';

class ProcessMetadata {
  final MixingMeta mixing;
  final FermentationMeta fermentation;
  final BakingMeta baking;

  const ProcessMetadata({
    required this.mixing,
    required this.fermentation,
    required this.baking,
  });

  factory ProcessMetadata.fromJson(Map<String, dynamic> json) {
    return ProcessMetadata(
      mixing: MixingMeta.fromJson(json['mixing'] as Map<String, dynamic>),
      fermentation: FermentationMeta.fromJson(
          json['fermentation'] as Map<String, dynamic>),
      baking: BakingMeta.fromJson(json['baking'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mixing': mixing.toJson(),
      'fermentation': fermentation.toJson(),
      'baking': baking.toJson(),
    };
  }

  ProcessMetadata copyWith({
    MixingMeta? mixing,
    FermentationMeta? fermentation,
    BakingMeta? baking,
  }) {
    return ProcessMetadata(
      mixing: mixing ?? this.mixing,
      fermentation: fermentation ?? this.fermentation,
      baking: baking ?? this.baking,
    );
  }

  /// 총 예상 시간 계산
  Duration get totalEstimatedTime {
    return mixing.estimatedDuration +
        fermentation.estimatedDuration +
        baking.estimatedDuration;
  }

  /// 공정 진행률 계산 (0.0 ~ 1.0)
  double calculateProgress(DateTime currentTime, DateTime startTime) {
    final elapsed = currentTime.difference(startTime);
    final total = totalEstimatedTime;

    if (total.inSeconds == 0) return 1.0;
    return (elapsed.inSeconds / total.inSeconds).clamp(0.0, 1.0);
  }

  /// 현재 단계 파악
  ProcessStage getCurrentStage(DateTime currentTime, DateTime startTime) {
    final elapsed = currentTime.difference(startTime);

    if (elapsed < mixing.estimatedDuration) {
      return ProcessStage.mixing;
    } else if (elapsed <
        mixing.estimatedDuration + fermentation.estimatedDuration) {
      return ProcessStage.fermentation;
    } else {
      return ProcessStage.baking;
    }
  }

  @override
  String toString() {
    return 'ProcessMetadata(mixing: ${mixing.estimatedDuration.inMinutes}분, '
        'fermentation: ${fermentation.estimatedDuration.inMinutes}분, '
        'baking: ${baking.estimatedDuration.inMinutes}분)';
  }
}

/// 공정 단계
enum ProcessStage {
  mixing,
  fermentation,
  baking,
}

extension ProcessStageExtension on ProcessStage {
  String get displayName {
    switch (this) {
      case ProcessStage.mixing:
        return '반죽 단계';
      case ProcessStage.fermentation:
        return '발효 단계';
      case ProcessStage.baking:
        return '굽기 단계';
    }
  }

  String get description {
    switch (this) {
      case ProcessStage.mixing:
        return '밀가루와 재료를 섞어 반죽을 만드는 단계';
      case ProcessStage.fermentation:
        return '이스트가 활동하여 반죽이 부풀어 오르는 단계';
      case ProcessStage.baking:
        return '오븐에서 반죽을 구워 빵을 완성하는 단계';
    }
  }
}

/// 믹싱 메타데이터
class MixingMeta {
  final double predictedTime; // 예측 시간 (분)
  final double frictionHeat; // 마찰열 (°C)
  final double mixerTypeCoefficient; // 반죽기 유형 계수
  final double glutenDevelopmentTarget; // 글루텐 발달 목표 계수
  final double equipmentCalibration; // 장비 캘리브레이션 계수

  const MixingMeta({
    required this.predictedTime,
    required this.frictionHeat,
    required this.mixerTypeCoefficient,
    required this.glutenDevelopmentTarget,
    required this.equipmentCalibration,
  });

  factory MixingMeta.fromJson(Map<String, dynamic> json) {
    return MixingMeta(
      predictedTime: (json['predictedTime'] as num).toDouble(),
      frictionHeat: (json['frictionHeat'] as num).toDouble(),
      mixerTypeCoefficient: (json['mixerTypeCoefficient'] as num).toDouble(),
      glutenDevelopmentTarget:
          (json['glutenDevelopmentTarget'] as num).toDouble(),
      equipmentCalibration: (json['equipmentCalibration'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'predictedTime': predictedTime,
      'frictionHeat': frictionHeat,
      'mixerTypeCoefficient': mixerTypeCoefficient,
      'glutenDevelopmentTarget': glutenDevelopmentTarget,
      'equipmentCalibration': equipmentCalibration,
    };
  }

  MixingMeta copyWith({
    double? predictedTime,
    double? frictionHeat,
    double? mixerTypeCoefficient,
    double? glutenDevelopmentTarget,
    double? equipmentCalibration,
  }) {
    return MixingMeta(
      predictedTime: predictedTime ?? this.predictedTime,
      frictionHeat: frictionHeat ?? this.frictionHeat,
      mixerTypeCoefficient: mixerTypeCoefficient ?? this.mixerTypeCoefficient,
      glutenDevelopmentTarget:
          glutenDevelopmentTarget ?? this.glutenDevelopmentTarget,
      equipmentCalibration: equipmentCalibration ?? this.equipmentCalibration,
    );
  }

  /// 예상 소요 시간
  Duration get estimatedDuration => Duration(minutes: predictedTime.round());

  /// 최적 믹싱 속도 계산
  double get optimalMixingSpeed {
    // 글루텐 발달 목표에 따른 속도 계산
    if (glutenDevelopmentTarget > 1.2) {
      return 80.0; // 강력한 글루텐 형성
    } else if (glutenDevelopmentTarget > 1.0) {
      return 100.0; // 중간 글루텐 형성
    } else {
      return 120.0; // 약한 글루텐 형성
    }
  }

  @override
  String toString() {
    return 'MixingMeta(time: ${predictedTime.toStringAsFixed(1)}분, '
        'heat: ${frictionHeat.toStringAsFixed(1)}°C, '
        'speed: ${optimalMixingSpeed.toStringAsFixed(0)} RPM)';
  }
}

/// 발효 메타데이터
class FermentationMeta {
  final double predictedTime; // 예측 시간 (분)
  final double volumeIncrease; // 부피 증가 (배수)
  final double microbialActivityCoefficient; // 미생물 활성 계수
  final double doughPhysicalChemicalCoefficient; // 반죽 물리화학 계수
  final double environmentalClimateCoefficient; // 환경 기후 계수
  final double doughTypeCorrection; // 반죽 유형 보정 계수

  const FermentationMeta({
    required this.predictedTime,
    required this.volumeIncrease,
    required this.microbialActivityCoefficient,
    required this.doughPhysicalChemicalCoefficient,
    required this.environmentalClimateCoefficient,
    required this.doughTypeCorrection,
  });

  factory FermentationMeta.fromJson(Map<String, dynamic> json) {
    return FermentationMeta(
      predictedTime: (json['predictedTime'] as num).toDouble(),
      volumeIncrease: (json['volumeIncrease'] as num).toDouble(),
      microbialActivityCoefficient:
          (json['microbialActivityCoefficient'] as num).toDouble(),
      doughPhysicalChemicalCoefficient:
          (json['doughPhysicalChemicalCoefficient'] as num).toDouble(),
      environmentalClimateCoefficient:
          (json['environmentalClimateCoefficient'] as num).toDouble(),
      doughTypeCorrection: (json['doughTypeCorrection'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'predictedTime': predictedTime,
      'volumeIncrease': volumeIncrease,
      'microbialActivityCoefficient': microbialActivityCoefficient,
      'doughPhysicalChemicalCoefficient': doughPhysicalChemicalCoefficient,
      'environmentalClimateCoefficient': environmentalClimateCoefficient,
      'doughTypeCorrection': doughTypeCorrection,
    };
  }

  FermentationMeta copyWith({
    double? predictedTime,
    double? volumeIncrease,
    double? microbialActivityCoefficient,
    double? doughPhysicalChemicalCoefficient,
    double? environmentalClimateCoefficient,
    double? doughTypeCorrection,
  }) {
    return FermentationMeta(
      predictedTime: predictedTime ?? this.predictedTime,
      volumeIncrease: volumeIncrease ?? this.volumeIncrease,
      microbialActivityCoefficient:
          microbialActivityCoefficient ?? this.microbialActivityCoefficient,
      doughPhysicalChemicalCoefficient: doughPhysicalChemicalCoefficient ??
          this.doughPhysicalChemicalCoefficient,
      environmentalClimateCoefficient: environmentalClimateCoefficient ??
          this.environmentalClimateCoefficient,
      doughTypeCorrection: doughTypeCorrection ?? this.doughTypeCorrection,
    );
  }

  /// 예상 소요 시간
  Duration get estimatedDuration => Duration(minutes: predictedTime.round());

  /// 최적 발효 온도 계산 - 동적 계산 적용
  double get optimalTemperature {
    // 미생물 활성 계수 기반 온도 계산
    if (microbialActivityCoefficient > 1.2) {
      return EnvironmentDefaultsCalculator.getDefaultEnvironment().temperature +
          3.0; // 빠른 발효
    } else if (microbialActivityCoefficient > 1.0) {
      return EnvironmentDefaultsCalculator.getDefaultEnvironment()
          .temperature; // 표준 발효
    } else {
      return EnvironmentDefaultsCalculator.getDefaultEnvironment().temperature -
          3.0; // 느린 발효
    }
  }

  /// 최적 발효 습도 계산
  double get optimalHumidity {
    // 환경 계수 기반 습도 계산
    if (environmentalClimateCoefficient > 1.1) {
      return 75.0; // 고습도 환경
    } else if (environmentalClimateCoefficient > 0.9) {
      return 70.0; // 표준 습도
    } else {
      return 80.0; // 저습도 환경 (수분 보충 필요)
    }
  }

  @override
  String toString() {
    return 'FermentationMeta(time: ${predictedTime.toStringAsFixed(1)}분, '
        'volume: ${volumeIncrease.toStringAsFixed(1)}배, '
        'temp: ${optimalTemperature.toStringAsFixed(1)}°C)';
  }
}

/// 굽기 메타데이터
class BakingMeta {
  final List<BakingPhase> temperatureProfile; // 단계별 온도 프로파일
  final double totalBakingTime; // 총 굽기 시간 (분)
  final double weightCorrection; // 무게 보정
  final double hydrationCorrection; // 하이드레이션 보정
  final double ovenEfficiency; // 오븐 효율
  final double breadTypeCorrection; // 빵 종류 보정

  const BakingMeta({
    required this.temperatureProfile,
    required this.totalBakingTime,
    required this.weightCorrection,
    required this.hydrationCorrection,
    required this.ovenEfficiency,
    required this.breadTypeCorrection,
  });

  factory BakingMeta.fromJson(Map<String, dynamic> json) {
    return BakingMeta(
      temperatureProfile: (json['temperatureProfile'] as List<dynamic>?)
              ?.map(
                  (item) => BakingPhase.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalBakingTime: (json['totalBakingTime'] as num).toDouble(),
      weightCorrection: (json['weightCorrection'] as num).toDouble(),
      hydrationCorrection: (json['hydrationCorrection'] as num).toDouble(),
      ovenEfficiency: (json['ovenEfficiency'] as num).toDouble(),
      breadTypeCorrection: (json['breadTypeCorrection'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperatureProfile':
          temperatureProfile.map((phase) => phase.toJson()).toList(),
      'totalBakingTime': totalBakingTime,
      'weightCorrection': weightCorrection,
      'hydrationCorrection': hydrationCorrection,
      'ovenEfficiency': ovenEfficiency,
      'breadTypeCorrection': breadTypeCorrection,
    };
  }

  BakingMeta copyWith({
    List<BakingPhase>? temperatureProfile,
    double? totalBakingTime,
    double? weightCorrection,
    double? hydrationCorrection,
    double? ovenEfficiency,
    double? breadTypeCorrection,
  }) {
    return BakingMeta(
      temperatureProfile: temperatureProfile ?? this.temperatureProfile,
      totalBakingTime: totalBakingTime ?? this.totalBakingTime,
      weightCorrection: weightCorrection ?? this.weightCorrection,
      hydrationCorrection: hydrationCorrection ?? this.hydrationCorrection,
      ovenEfficiency: ovenEfficiency ?? this.ovenEfficiency,
      breadTypeCorrection: breadTypeCorrection ?? this.breadTypeCorrection,
    );
  }

  /// 예상 소요 시간
  Duration get estimatedDuration => Duration(minutes: totalBakingTime.round());

  /// 평균 굽기 온도 계산
  double get averageBakingTemperature {
    if (temperatureProfile.isEmpty) return 180.0;

    double totalTemp = 0;
    int totalTime = 0;

    for (final phase in temperatureProfile) {
      totalTemp += phase.temperature * phase.time;
      totalTime += phase.time;
    }

    return totalTime > 0 ? totalTemp / totalTime : 180.0;
  }

  /// 최대 굽기 온도
  double get maxBakingTemperature {
    if (temperatureProfile.isEmpty) return 180.0;
    return temperatureProfile
        .map((phase) => phase.temperature)
        .reduce((a, b) => a > b ? a : b);
  }

  @override
  String toString() {
    return 'BakingMeta(time: ${totalBakingTime.toStringAsFixed(1)}분, '
        'avg_temp: ${averageBakingTemperature.toStringAsFixed(1)}°C, '
        'max_temp: ${maxBakingTemperature.toStringAsFixed(1)}°C)';
  }
}
