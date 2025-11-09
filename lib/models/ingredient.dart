class Ingredient {
  final String id;
  final String name;
  final double amount;
  final String unit;
  final String category;
  final String? notes;
  final Map<String, dynamic>? properties;

  double get quantity => amount; // Add this getter

  Ingredient({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
    this.category = 'other',
    this.notes,
    this.properties,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      category: json['category'] ?? 'other',
      notes: json['notes'],
      properties: json['properties'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'unit': unit,
      'category': category,
      'notes': notes,
      'properties': properties,
    };
  }

  Ingredient copyWith({
    String? id,
    String? name,
    double? amount,
    String? unit,
    String? category,
    String? notes,
    Map<String, dynamic>? properties,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      properties: properties ?? this.properties,
    );
  }

  /// 인덱스 연산자 오버로딩 (계산 엔진 호환성)
  dynamic operator [](String key) {
    switch (key) {
      case 'id':
        return id;
      case 'name':
        return name;
      case 'amount':
        return amount;
      case 'unit':
        return unit;
      case 'category':
        return category;
      case 'notes':
        return notes;
      case 'properties':
        return properties;
      default:
        return null;
    }
  }
}
