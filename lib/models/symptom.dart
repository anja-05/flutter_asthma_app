/*class Symptom {
  final String id;
  final DateTime dateTime;
  final String type; // 'Husten', 'Kurzatmigkeit', 'Keuchen', etc.
  final int intensity; // 1-10
  final String? notes;
  final List<String> triggers; // ['Pollen', 'Anstrengung', etc.]

  Symptom({
    required this.id,
    required this.dateTime,
    required this.type,
    required this.intensity,
    this.notes,
    this.triggers = const [],
  });

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(
      id: json['id'],
      dateTime: DateTime.parse(json['dateTime']),
      type: json['type'],
      intensity: json['intensity'],
      notes: json['notes'],
      triggers: List<String>.from(json['triggers'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'type': type,
      'intensity': intensity,
      'notes': notes,
      'triggers': triggers,
    };
  }

  Color get intensityColor {
    if (intensity <= 3) return AppColors.successGreen;
    if (intensity <= 6) return AppColors.warningYellow;
    return AppColors.emergencyRed;
  }

  String get intensityText {
    if (intensity <= 3) return 'Leicht';
    if (intensity <= 6) return 'Mittel';
    return 'Schwer';
  }
}*/