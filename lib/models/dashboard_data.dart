// lib/models/dashboard_data.dart

class DashboardData {
  final double volumeIndex;
  final String crustColorCode; // e.g., hex code
  final Map<int, int> crumbScoreHistogram; // e.g., {pore_size: count}
  final double temperature;
  final double humidity;
  final double pressure;

  DashboardData({
    required this.volumeIndex,
    required this.crustColorCode,
    required this.crumbScoreHistogram,
    required this.temperature,
    required this.humidity,
    required this.pressure,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      volumeIndex: json['volumeIndex'] as double,
      crustColorCode: json['crustColorCode'] as String,
      crumbScoreHistogram: Map<int, int>.from(json['crumbScoreHistogram'] as Map),
      temperature: json['temperature'] as double,
      humidity: json['humidity'] as double,
      pressure: json['pressure'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'volumeIndex': volumeIndex,
      'crustColorCode': crustColorCode,
      'crumbScoreHistogram': crumbScoreHistogram,
      'temperature': temperature,
      'humidity': humidity,
      'pressure': pressure,
    };
  }
}
