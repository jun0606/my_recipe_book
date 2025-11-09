// lib/models/alert.dart

enum AlertType {
  fermentationTime,
  bakingTemp,
  environmental,
}

class Alert {
  final String id;
  final AlertType type;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic> details;

  Alert({
    required this.id,
    required this.type,
    required this.message,
    required this.timestamp,
    this.details = const {},
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] as String,
      type: AlertType.values.byName(json['type'] as String),
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      details: Map<String, dynamic>.from(json['details'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'details': details,
    };
  }
}
