/// 품질 메타데이터
class QualityMetadata {
  final double volumeIndex; // 볼륨 지수 (예측 배수)
  final double crustColorIndex; // 크러스트 색상 지수
  final double poreStructureScore; // 내부 기공 점수
  final double moistureRetention; // 수분 보유율

  const QualityMetadata({
    required this.volumeIndex,
    required this.crustColorIndex,
    required this.poreStructureScore,
    required this.moistureRetention,
  });

  factory QualityMetadata.fromJson(Map<String, dynamic> json) {
    return QualityMetadata(
      volumeIndex: (json['volumeIndex'] as num).toDouble(),
      crustColorIndex: (json['crustColorIndex'] as num).toDouble(),
      poreStructureScore: (json['poreStructureScore'] as num).toDouble(),
      moistureRetention: (json['moistureRetention'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'volumeIndex': volumeIndex,
      'crustColorIndex': crustColorIndex,
      'poreStructureScore': poreStructureScore,
      'moistureRetention': moistureRetention,
    };
  }

  QualityMetadata copyWith({
    double? volumeIndex,
    double? crustColorIndex,
    double? poreStructureScore,
    double? moistureRetention,
  }) {
    return QualityMetadata(
      volumeIndex: volumeIndex ?? this.volumeIndex,
      crustColorIndex: crustColorIndex ?? this.crustColorIndex,
      poreStructureScore: poreStructureScore ?? this.poreStructureScore,
      moistureRetention: moistureRetention ?? this.moistureRetention,
    );
  }

  /// 종합 품질 점수 계산 (0-100)
  double get overallQualityScore {
    // 각 요소의 가중 평균 계산
    final volumeScore = (volumeIndex / 3.0) * 100; // 최대 3배까지
    final colorScore = crustColorIndex * 20; // 색상 지수에 따른 점수
    final structureScore = poreStructureScore;
    final moistureScore = moistureRetention * 100;

    // 가중치 적용 (볼륨 40%, 색상 20%, 기공 20%, 수분 20%)
    return (volumeScore * 0.4) +
        (colorScore * 0.2) +
        (structureScore * 0.2) +
        (moistureScore * 0.2);
  }

  /// 품질 등급 반환
  String get qualityGrade {
    final score = overallQualityScore;
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Very Good';
    if (score >= 70) return 'Good';
    if (score >= 60) return 'Fair';
    return 'Poor';
  }

  /// 품질 평가 요약
  String get qualitySummary {
    final grade = qualityGrade;
    final score = overallQualityScore.toStringAsFixed(1);

    return '$grade ($score/100): 볼륨 ${volumeIndex.toStringAsFixed(1)}배, '
        '색상 ${(crustColorIndex * 100).toStringAsFixed(0)}%, '
        '기공 ${poreStructureScore.toStringAsFixed(1)}점, '
        '수분 ${(moistureRetention * 100).toStringAsFixed(0)}%';
  }

  @override
  String toString() {
    return 'QualityMetadata(volume: ${volumeIndex.toStringAsFixed(1)}, '
        'color: ${(crustColorIndex * 100).toStringAsFixed(0)}%, '
        'structure: ${poreStructureScore.toStringAsFixed(1)}, '
        'moisture: ${(moistureRetention * 100).toStringAsFixed(0)}%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QualityMetadata &&
        other.volumeIndex == volumeIndex &&
        other.crustColorIndex == crustColorIndex &&
        other.poreStructureScore == poreStructureScore &&
        other.moistureRetention == moistureRetention;
  }

  @override
  int get hashCode {
    return volumeIndex.hashCode ^
        crustColorIndex.hashCode ^
        poreStructureScore.hashCode ^
        moistureRetention.hashCode;
  }
}

/// 품질 메트릭 계산기
class QualityCalculator {
  /// 기본 품질 메타데이터 생성
  static QualityMetadata createDefault() {
    return const QualityMetadata(
      volumeIndex: 2.5, // 기본 2.5배 부풀음
      crustColorIndex: 0.8, // 80% 색상 발달
      poreStructureScore: 75.0, // 75점 기공 구조
      moistureRetention: 0.85, // 85% 수분 보유
    );
  }

  /// 레시피 기반 품질 예측
  static QualityMetadata predictFromRecipe({
    required double hydration,
    required double yeastAmount,
    required double saltAmount,
    required String flourType,
    required String fermentationMethod,
  }) {
    // 하이드레이션 기반 볼륨 예측
    double volumeIndex = 2.0 + (hydration - 60) * 0.02;
    volumeIndex = volumeIndex.clamp(1.5, 4.0);

    // 이스트량 기반 색상 예측 (이스트가 많을수록 색이 진해짐)
    double colorIndex = 0.6 + (yeastAmount * 0.5);
    colorIndex = colorIndex.clamp(0.3, 1.0);

    // 소금량 기반 기공 구조 예측 (적절한 소금이 기공을 좋게 함)
    double structureScore = 70.0;
    if (saltAmount >= 1.8 && saltAmount <= 2.2) {
      structureScore = 85.0; // 최적 소금량
    } else if (saltAmount < 1.0 || saltAmount > 3.0) {
      structureScore = 60.0; // 과다 또는 부족
    }

    // 밀가루 타입 기반 수분 보유 예측
    double moistureRetention = 0.8;
    if (flourType.contains('강력분') || flourType.contains('bread')) {
      moistureRetention = 0.85;
    } else if (flourType.contains('박력분') || flourType.contains('cake')) {
      moistureRetention = 0.75;
    }

    // 발효 방식 보정
    if (fermentationMethod.contains('cold') ||
        fermentationMethod.contains('retard')) {
      volumeIndex *= 1.1; // 냉장 발효는 부풀음 증가
      structureScore += 5; // 기공 구조 향상
    }

    return QualityMetadata(
      volumeIndex: volumeIndex,
      crustColorIndex: colorIndex,
      poreStructureScore: structureScore,
      moistureRetention: moistureRetention,
    );
  }

  /// 환경 조건 기반 품질 조정
  static QualityMetadata adjustForEnvironment(
    QualityMetadata base, {
    required double temperature,
    required double humidity,
    required double fermentationTime,
  }) {
    double adjustedVolume = base.volumeIndex;
    double adjustedColor = base.crustColorIndex;
    double adjustedStructure = base.poreStructureScore;
    double adjustedMoisture = base.moistureRetention;

    // 온도 영향
    if (temperature > 28) {
      adjustedVolume *= 0.9; // 고온은 부풀음 감소
      adjustedColor *= 1.2; // 고온은 색상 증가
      adjustedStructure *= 0.95; // 고온은 기공 악화
    } else if (temperature < 20) {
      adjustedVolume *= 1.1; // 저온은 부풀음 증가 (시간 더 걸림)
      adjustedColor *= 0.8; // 저온은 색상 감소
      adjustedStructure *= 1.05; // 저온은 기공 향상
    }

    // 습도 영향
    if (humidity < 50) {
      adjustedMoisture *= 0.9; // 저습도는 수분 손실 증가
      adjustedStructure *= 0.95; // 건조하면 기공 악화
    } else if (humidity > 80) {
      adjustedMoisture *= 1.1; // 고습도는 수분 유지 증가
      adjustedStructure *= 1.05; // 습하면 기공 향상
    }

    return QualityMetadata(
      volumeIndex: adjustedVolume.clamp(1.0, 5.0),
      crustColorIndex: adjustedColor.clamp(0.0, 1.0),
      poreStructureScore: adjustedStructure.clamp(0.0, 100.0),
      moistureRetention: adjustedMoisture.clamp(0.0, 1.0),
    );
  }
}
