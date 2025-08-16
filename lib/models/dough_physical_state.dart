/// 반죽의 물리화학적 상태를 나타내는 모델
class DoughPhysicalState {
  /// 글루텐 강도 지수 (0.0 ~ 10.0)
  final double glutenStrengthIndex;
  
  /// 반죽 상태 평가 (excellent, good, fair, poor)
  final DoughQuality quality;
  
  /// 조정 제안 목록
  final List<DoughAdjustmentSuggestion> suggestions;
  
  /// 계산에 사용된 재료 비율
  final DoughIngredientRatios ingredientRatios;
  
  /// 계산 시간
  final DateTime calculatedAt;

  const DoughPhysicalState({
    required this.glutenStrengthIndex,
    required this.quality,
    required this.suggestions,
    required this.ingredientRatios,
    required this.calculatedAt,
  });

  /// JSON으로 직렬화
  Map<String, dynamic> toJson() {
    return {
      'glutenStrengthIndex': glutenStrengthIndex,
      'quality': quality.name,
      'suggestions': suggestions.map((s) => s.toJson()).toList(),
      'ingredientRatios': ingredientRatios.toJson(),
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }

  /// JSON에서 역직렬화
  factory DoughPhysicalState.fromJson(Map<String, dynamic> json) {
    return DoughPhysicalState(
      glutenStrengthIndex: json['glutenStrengthIndex']?.toDouble() ?? 0.0,
      quality: DoughQuality.values.firstWhere(
        (q) => q.name == json['quality'],
        orElse: () => DoughQuality.poor,
      ),
      suggestions: (json['suggestions'] as List<dynamic>?)
          ?.map((s) => DoughAdjustmentSuggestion.fromJson(s))
          .toList() ?? [],
      ingredientRatios: DoughIngredientRatios.fromJson(
        json['ingredientRatios'] ?? {},
      ),
      calculatedAt: DateTime.parse(json['calculatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// 복사본 생성
  DoughPhysicalState copyWith({
    double? glutenStrengthIndex,
    DoughQuality? quality,
    List<DoughAdjustmentSuggestion>? suggestions,
    DoughIngredientRatios? ingredientRatios,
    DateTime? calculatedAt,
  }) {
    return DoughPhysicalState(
      glutenStrengthIndex: glutenStrengthIndex ?? this.glutenStrengthIndex,
      quality: quality ?? this.quality,
      suggestions: suggestions ?? this.suggestions,
      ingredientRatios: ingredientRatios ?? this.ingredientRatios,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  String toString() {
    return 'DoughPhysicalState(glutenStrengthIndex: $glutenStrengthIndex, quality: $quality, suggestions: ${suggestions.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DoughPhysicalState &&
        other.glutenStrengthIndex == glutenStrengthIndex &&
        other.quality == quality &&
        other.suggestions.length == suggestions.length &&
        other.ingredientRatios == ingredientRatios;
  }

  @override
  int get hashCode {
    return glutenStrengthIndex.hashCode ^
        quality.hashCode ^
        suggestions.length.hashCode ^
        ingredientRatios.hashCode;
  }
}

/// 반죽 품질 등급
enum DoughQuality {
  excellent('우수', 8.0, 10.0),
  good('양호', 6.0, 7.9),
  fair('보통', 4.0, 5.9),
  poor('개선필요', 0.0, 3.9);

  const DoughQuality(this.displayName, this.minIndex, this.maxIndex);
  
  final String displayName;
  final double minIndex;
  final double maxIndex;

  /// 글루텐 강도 지수로부터 품질 등급 결정
  static DoughQuality fromGlutenStrengthIndex(double index) {
    for (final quality in DoughQuality.values) {
      if (index >= quality.minIndex && index <= quality.maxIndex) {
        return quality;
      }
    }
    return DoughQuality.poor;
  }
}

/// 반죽 조정 제안
class DoughAdjustmentSuggestion {
  /// 제안 유형
  final AdjustmentType type;
  
  /// 제안 내용
  final String message;
  
  /// 우선순위 (1: 높음, 2: 보통, 3: 낮음)
  final int priority;
  
  /// 예상 효과
  final String expectedEffect;

  const DoughAdjustmentSuggestion({
    required this.type,
    required this.message,
    required this.priority,
    required this.expectedEffect,
  });

  /// JSON으로 직렬화
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'message': message,
      'priority': priority,
      'expectedEffect': expectedEffect,
    };
  }

  /// JSON에서 역직렬화
  factory DoughAdjustmentSuggestion.fromJson(Map<String, dynamic> json) {
    return DoughAdjustmentSuggestion(
      type: AdjustmentType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => AdjustmentType.other,
      ),
      message: json['message'] ?? '',
      priority: json['priority'] ?? 3,
      expectedEffect: json['expectedEffect'] ?? '',
    );
  }

  @override
  String toString() {
    return 'DoughAdjustmentSuggestion(type: $type, message: $message, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DoughAdjustmentSuggestion &&
        other.type == type &&
        other.message == message &&
        other.priority == priority &&
        other.expectedEffect == expectedEffect;
  }

  @override
  int get hashCode {
    return type.hashCode ^ message.hashCode ^ priority.hashCode ^ expectedEffect.hashCode;
  }
}

/// 조정 제안 유형
enum AdjustmentType {
  protein('단백질 조정'),
  salt('소금 조정'),
  fat('지방 조정'),
  sugar('설탕 조정'),
  hydration('수분 조정'),
  kneading('반죽 시간 조정'),
  temperature('온도 조정'),
  other('기타');

  const AdjustmentType(this.displayName);
  final String displayName;
}

/// 반죽 재료 비율 정보
class DoughIngredientRatios {
  /// 유효 밀가루 단백질 비율 (%)
  final double flourProteinPercentage;
  
  /// 소금 비율 (%)
  final double saltPercentage;
  
  /// 지방 비율 (%)
  final double fatPercentage;
  
  /// 설탕 비율 (%)
  final double sugarPercentage;
  
  /// 수분 비율 (%)
  final double hydrationPercentage;

  const DoughIngredientRatios({
    required this.flourProteinPercentage,
    required this.saltPercentage,
    required this.fatPercentage,
    required this.sugarPercentage,
    required this.hydrationPercentage,
  });

  /// JSON으로 직렬화
  Map<String, dynamic> toJson() {
    return {
      'flourProteinPercentage': flourProteinPercentage,
      'saltPercentage': saltPercentage,
      'fatPercentage': fatPercentage,
      'sugarPercentage': sugarPercentage,
      'hydrationPercentage': hydrationPercentage,
    };
  }

  /// JSON에서 역직렬화
  factory DoughIngredientRatios.fromJson(Map<String, dynamic> json) {
    return DoughIngredientRatios(
      flourProteinPercentage: json['flourProteinPercentage']?.toDouble() ?? 0.0,
      saltPercentage: json['saltPercentage']?.toDouble() ?? 0.0,
      fatPercentage: json['fatPercentage']?.toDouble() ?? 0.0,
      sugarPercentage: json['sugarPercentage']?.toDouble() ?? 0.0,
      hydrationPercentage: json['hydrationPercentage']?.toDouble() ?? 0.0,
    );
  }

  /// 복사본 생성
  DoughIngredientRatios copyWith({
    double? flourProteinPercentage,
    double? saltPercentage,
    double? fatPercentage,
    double? sugarPercentage,
    double? hydrationPercentage,
  }) {
    return DoughIngredientRatios(
      flourProteinPercentage: flourProteinPercentage ?? this.flourProteinPercentage,
      saltPercentage: saltPercentage ?? this.saltPercentage,
      fatPercentage: fatPercentage ?? this.fatPercentage,
      sugarPercentage: sugarPercentage ?? this.sugarPercentage,
      hydrationPercentage: hydrationPercentage ?? this.hydrationPercentage,
    );
  }

  @override
  String toString() {
    return 'DoughIngredientRatios(protein: $flourProteinPercentage%, salt: $saltPercentage%, fat: $fatPercentage%, sugar: $sugarPercentage%, hydration: $hydrationPercentage%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DoughIngredientRatios &&
        other.flourProteinPercentage == flourProteinPercentage &&
        other.saltPercentage == saltPercentage &&
        other.fatPercentage == fatPercentage &&
        other.sugarPercentage == sugarPercentage &&
        other.hydrationPercentage == hydrationPercentage;
  }

  @override
  int get hashCode {
    return flourProteinPercentage.hashCode ^
        saltPercentage.hashCode ^
        fatPercentage.hashCode ^
        sugarPercentage.hashCode ^
        hydrationPercentage.hashCode;
  }
}