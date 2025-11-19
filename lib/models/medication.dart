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
}
