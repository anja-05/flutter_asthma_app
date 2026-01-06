/// Repräsentiert einen Eintrag in einer Asthma‑App.
/// Enthält eine eindeutige ID, Datum/Zeit, die erfassten Symptome mit Intensitäten (0–5),
/// die Häufigkeit, Notizen,Auslöser und einen Trend (true = besser, false = schlechter).
class SymptomEntry {
  /// Eindeutiger Bezeichner für den Eintrag.
  final String id;
  /// Datum und Uhrzeit des Eintrags.
  final DateTime date;
  /// Map mit Symptomnamen und Intensität (0–5).
  final Map<String, int> symptoms;
  /// Häufigkeit der Symptome.
  final String frequency;
  /// Optionale Notizen zum Eintrag.
  final String? notes;
  /// Optionaler Auslöser für die Symptome.
  final String? trigger;
  /// Trend: true = besser, false = schlechter.
  final bool trend;

  /// Erstellt einen neuen Symptom-Eintrag mit den angegebenen Werten.
  SymptomEntry({
    required this.id,
    required this.date,
    required this.symptoms,
    required this.frequency,
    this.notes,
    this.trigger,
    this.trend = false,
  });

  /// Fabrikmethode für Test‑ oder Mock‑Daten.
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

  /// Liefert das Datum des Eintrags im Format „TT.MM.JJJJ“.
  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  /// Liefert die Uhrzeit des Eintrags im Format „HH:MM“.
  String get formattedTime {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Berechnet die durchschnittliche Intensität aller Symptome; bei leerer Liste wird 0 zurückgegeben.
  double get averageIntensity {
    if (symptoms.isEmpty) return 0;
    final total = symptoms.values.reduce((a, b) => a + b);
    return total / symptoms.length;
  }

  /// Erzeugt eine kommagetrennte Liste der Symptomnamen.
  String get symptomsList {
    return symptoms.keys.join(', ');
  }

  /// Serialisiert den Eintrag in ein JSON‑kompatibles Map-Objekt.
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

  /// Erzeugt einen `SymptomEntry` aus einer JSON‑Map.
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

