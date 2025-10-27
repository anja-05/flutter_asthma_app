/*class Medication {
  final String id;
  final String name;
  final String dosage; // z.B. "2 Hubs", "1 Tablette"
  final List<String> times; // z.B. ["08:00", "20:00"]
  final String type; // "Inhalator", "Tablette", "Spray"
  final bool reminderEnabled;
  final String? notes;
  final List<DateTime> takenHistory; // Wann wurde es eingenommen

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.times,
    required this.type,
    this.reminderEnabled = true,
    this.notes,
    this.takenHistory = const [],
  });

  // Nächste geplante Einnahme
  String? get nextDoseTime {
    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;

    for (final time in times) {
      final parts = time.split(':');
      final timeMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);

      if (timeMinutes > currentMinutes) {
        return time;
      }
    }

    // Wenn alle Zeiten heute vorbei sind, gib die erste Zeit von morgen zurück
    return times.isNotEmpty ? times.first : null;
  }

  // Wurde heute schon eingenommen?
  bool get takenToday {
    final today = DateTime.now();
    return takenHistory.any((date) =>
    date.year == today.year &&
        date.month == today.month &&
        date.day == today.day
    );
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      name: json['name'],
      dosage: json['dosage'],
      times: List<String>.from(json['times']),
      type: json['type'],
      reminderEnabled: json['reminderEnabled'] ?? true,
      notes: json['notes'],
      takenHistory: (json['takenHistory'] as List?)
          ?.map((e) => DateTime.parse(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'times': times,
      'type': type,
      'reminderEnabled': reminderEnabled,
      'notes': notes,
      'takenHistory': takenHistory.map((e) => e.toIso8601String()).toList(),
    };
  }
}*/