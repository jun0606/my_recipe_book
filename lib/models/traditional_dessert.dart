// lib/models/traditional_dessert.dart

class TraditionalDessert {
  final String id;
  final String name;
  final String country;
  final String description;
  final Map<String, dynamic> properties; // For specific calculation formulas and data
  final Map<String, dynamic> environmentalAdjustments; // Country-specific environmental adjustments

  TraditionalDessert({
    required this.id,
    required this.name,
    required this.country,
    required this.description,
    required this.properties,
    required this.environmentalAdjustments,
  });

  factory TraditionalDessert.fromJson(Map<String, dynamic> json) {
    return TraditionalDessert(
      id: json['id'] as String,
      name: json['name'] as String,
      country: json['country'] as String,
      description: json['description'] as String,
      properties: Map<String, dynamic>.from(json['properties'] as Map),
      environmentalAdjustments: Map<String, dynamic>.from(json['environmentalAdjustments'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'description': description,
      'properties': properties,
      'environmentalAdjustments': environmentalAdjustments,
    };
  }
}
