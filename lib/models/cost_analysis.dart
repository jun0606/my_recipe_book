/// 비용 분석 정보
class CostAnalysis {
  final Map<String, double> ingredientCosts; // 재료별 비용
  final double totalCost; // 총 재료비
  final double profitMargin; // 이익률 (0.0 - 1.0)
  final double suggestedPrice; // 권장 판매가
  final double laborCost; // 인건비
  final double overheadCost; // 간접비
  final String currency; // 통화

  const CostAnalysis({
    required this.ingredientCosts,
    required this.totalCost,
    required this.profitMargin,
    required this.suggestedPrice,
    this.laborCost = 0.0,
    this.overheadCost = 0.0,
    this.currency = 'KRW',
  });

  /// 총 제조원가 (재료비 + 인건비 + 간접비)
  double get totalManufacturingCost => totalCost + laborCost + overheadCost;

  /// 실제 이익
  double get actualProfit => suggestedPrice - totalManufacturingCost;

  /// 실제 이익률
  double get actualProfitMargin => 
      totalManufacturingCost > 0 ? actualProfit / totalManufacturingCost : 0.0;

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'ingredientCosts': ingredientCosts,
      'totalCost': totalCost,
      'profitMargin': profitMargin,
      'suggestedPrice': suggestedPrice,
      'laborCost': laborCost,
      'overheadCost': overheadCost,
      'currency': currency,
    };
  }

  /// JSON에서 생성
  factory CostAnalysis.fromJson(Map<String, dynamic> json) {
    return CostAnalysis(
      ingredientCosts: Map<String, double>.from(
        json['ingredientCosts']?.map((k, v) => MapEntry(k, v?.toDouble() ?? 0.0)) ?? {},
      ),
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0.0,
      profitMargin: (json['profitMargin'] as num?)?.toDouble() ?? 0.0,
      suggestedPrice: (json['suggestedPrice'] as num?)?.toDouble() ?? 0.0,
      laborCost: (json['laborCost'] as num?)?.toDouble() ?? 0.0,
      overheadCost: (json['overheadCost'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'KRW',
    );
  }

  /// 복사본 생성
  CostAnalysis copyWith({
    Map<String, double>? ingredientCosts,
    double? totalCost,
    double? profitMargin,
    double? suggestedPrice,
    double? laborCost,
    double? overheadCost,
    String? currency,
  }) {
    return CostAnalysis(
      ingredientCosts: ingredientCosts ?? this.ingredientCosts,
      totalCost: totalCost ?? this.totalCost,
      profitMargin: profitMargin ?? this.profitMargin,
      suggestedPrice: suggestedPrice ?? this.suggestedPrice,
      laborCost: laborCost ?? this.laborCost,
      overheadCost: overheadCost ?? this.overheadCost,
      currency: currency ?? this.currency,
    );
  }

  @override
  String toString() {
    return 'CostAnalysis(totalCost: $totalCost, suggestedPrice: $suggestedPrice, profitMargin: ${(profitMargin * 100).toStringAsFixed(1)}%)';
  }
}