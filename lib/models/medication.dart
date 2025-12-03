// lib/models/medication.dart
import 'package:uuid/uuid.dart';

const Uuid uuid = Uuid();

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String type; // Inhalator, Tablette, Spray
  final List<String> times;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.type,
    required this.times,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'dosage': dosage,
    'type': type,
    'times': times,
  };

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      type: json['type'] as String,
      times: List<String>.from(json['times'] as List),
    );
  }
}

class MedicationIntake {
  final String id;
  final String name;
  final String dosage;
  final String time;
  final String type;
  final bool taken;

  MedicationIntake({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    required this.type,
    this.taken = false,
  });

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'dosage': dosage,
    'time': time,
    'type': type,
    'taken': taken,
  };

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

class PastMedicationIntake {
  final String id;
  final String name;
  final String dosage;
  final String type;
  final DateTime dateTime;

  PastMedicationIntake({
    required this.id,
    required this.name,
    required this.dosage,
    required this.type,
    required this.dateTime,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'dosage': dosage,
    'type': type,
    'dateTime': dateTime.toIso8601String(), // Speichere Datum als String
  };

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