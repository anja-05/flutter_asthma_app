class SymptomEntry {
  final String id;
  final DateTime date;
  final Map<String, int> symptoms; // Symptom name -> Intensity (0-5)
  final String frequency; // "Selten", "Gelegentlich", "Häufig"
  final String? notes;
  final String? trigger;
  final bool trend; // true = besser, false = schlechter

  SymptomEntry({
    required this.id,
    required this.date,
    required this.symptoms,
    required this.frequency,
    this.notes,
    this.trigger,
    this.trend = false,
  });

  // Für Mock-Daten
  factory SymptomEntry.mock({
    required String id,
    required DateTime date,
    required Map<String, int> symptoms,
    required String frequency,
    String? notes,
    String? trigger,
    bool trend = false,
  }) {
    return SymptomEntry(
      id: id,
      date: date,
      symptoms: symptoms,
      frequency: frequency,
      notes: notes,
      trigger: trigger,
      trend: trend,
    );
  }

  // Formatiertes Datum
  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  // Formatierte Zeit
  String get formattedTime {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Durchschnittliche Intensität aller Symptome
  double get averageIntensity {
    if (symptoms.isEmpty) return 0;
    final total = symptoms.values.reduce((a, b) => a + b);
    return total / symptoms.length;
  }

  // Liste der Symptom-Namen
  String get symptomsList {
    return symptoms.keys.join(', ');
  }

  // JSON Serialisierung (für später mit Backend)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'symptoms': symptoms,
      'frequency': frequency,
      'notes': notes,
      'trigger': trigger,
      'trend': trend,
    };
  }

  factory SymptomEntry.fromJson(Map<String, dynamic> json) {
    return SymptomEntry(
      id: json['id'],
      date: DateTime.parse(json['date']),
      symptoms: Map<String, int>.from(json['symptoms']),
      frequency: json['frequency'],
      notes: json['notes'],
      trigger: json['trigger'],
      trend: json['trend'] ?? false,
    );
  }
}

