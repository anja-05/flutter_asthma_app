import 'package:uuid/uuid.dart';

const Uuid uuid = Uuid();

/// Repräsentiert ein Medikament im Medikationsplan.
///
/// Diese Klasse speichert grundlegende Informationen über ein Medikament,
/// wie Name, Dosierung, Typ (z.B. Tablette oder Inhalator) und die geplanten Einnahmezeiten.
/// Zusätzlich werden Informationen zur Wiederholungshäufigkeit (täglich, alle X Tage, bestimmte Wochentage) verwaltet.
class Medication {
  /// Eindeutige ID des Medikaments
  final String id;
  /// Name des Medikaments
  final String name;
  /// Die Dosierung, z. B. "1 Tablette" oder "2 Hübe"
  final String dosage;
  /// Art des Medikaments, z. B. "Tablette", "Inhalator", "Spritze"
  final String type;
  /// Liste der geplanten Einnahmezeiten im Format "HH:MM"
  final List<String> times;
  /// Art der Wiederholung: 'daily' (täglich), 'everyXDays' (alle X Tage) oder 'weekly' (wöchentlich).
  final String frequencyType;
  /// Intervall in Tagen, falls [frequencyType] 'everyXDays' ist.
  final int? everyXDays;
  /// Liste der Wochentage (1=Montag, 7=Sonntag), an denen das Medikament eingenommen wird (bei 'weekly').
  final List<int>? weekdays;

  /// Erstellt ein neues [Medication]-Objekt.
  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.type,
    required this.times,
    this.frequencyType = 'daily',
    this.everyXDays,
    this.weekdays,
  });

  /// Konvertiert Medikament in ein JSON-kompatibles Format.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'type': type,
        'times': times,
        'frequencyType': frequencyType,
        'everyXDays': everyXDays,
        'weekdays': weekdays,
      };

  /// Erstellt [Medication]-Objekt aus einer JSON-Struktur
  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      type: json['type'] as String,
      times: List<String>.from(json['times'] as List),
      frequencyType: json['frequencyType'] ?? 'daily',
      everyXDays: json['everyXDays'],
      weekdays: json['weekdays'] != null
          ? List<int>.from(json['weekdays'])
          : null,
    );
  }
}

/// Repräsentiert spezifische, geplante Einnahme eines Medikaments an einem Tag.
///
/// Wird verwendet, um den täglichen Einnahmeplan darzustellen und den Status
/// (genommen/nicht genommen) zu verfolgen.
class MedicationIntake {
  /// Referenz-ID (kann sich auf das Medikament oder die spezifische Einnahme beziehen).
  final String id;
  /// Name des Medikaments
  final String name;
  /// Zu nehmende Dosis
  final String dosage;
  /// Geplante Uhrzeit der Einnahme im Format "HH:MM"
  final String time;
  /// Art des Medikaments
  final String type;
  /// Status der Einnahme: `true`, wenn bereits eingenommen
  final bool taken;

  /// Erstellt neue [MedicationIntake]-Instanz.
  MedicationIntake({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    required this.type,
    this.taken = false,
  });

  /// Erstellt Kopie dieser Einnahme mit [taken] auf `true`
  MedicationIntake markAsTaken() {
    return MedicationIntake(
      id: id,
      name: name,
      dosage: dosage,
      time: time,
      type: type,
      taken: true,
    );
  }

  /// Konvertiert Einnahme in JSON-Objekt
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'time': time,
        'type': type,
        'taken': taken,
      };

  /// Erstellt [MedicationIntake]-Instanz aus JSON
  factory MedicationIntake.fromJson(Map<String, dynamic> json) {
    return MedicationIntake(
      id: json['id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      time: json['time'] as String,
      type: json['type'] as String,
      taken: json['taken'] as bool,
    );
  }
}

/// Repräsentiert historisch protokollierte Einnahme in der Vergangenheit.
///
/// Dient zur Anzeige im Verlauf oder in Statistiken. Im Gegensatz zu [MedicationIntake]
/// speichert dies den tatsächlichen Zeitpunkt ([dateTime]) der Einnahme (oder des Eintrags).
class PastMedicationIntake {
  /// ID des Eintrags
  final String id;
  /// Name des Medikaments
  final String name;
  /// Eingenommene Dosis
  final String dosage;
  /// Art des Medikaments
  final String type;
  /// Zeitpunkt der Einnahme/Protokollierung
  final DateTime dateTime;

  /// Erstellt historischen Einnahmeeintrag
  PastMedicationIntake({
    required this.id,
    required this.name,
    required this.dosage,
    required this.type,
    required this.dateTime,
  });

  /// Konvertiert Eintrag in JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'type': type,
        'dateTime': dateTime.toIso8601String(),
      };

  /// Erstellt [PastMedicationIntake]-Eintrag aus JSON.
  factory PastMedicationIntake.fromJson(Map<String, dynamic> json) {
    return PastMedicationIntake(
      id: json['id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      type: json['type'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
    );
  }
}