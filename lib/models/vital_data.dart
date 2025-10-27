class VitalData {
  final String id;
  final DateTime dateTime;
  final int? heartRate; // Puls in bpm
  final int? oxygenSaturation; // SpO2 in %
  final int? respiratoryRate; // Atemfrequenz in /min

  VitalData({
    required this.id,
    required this.dateTime,
    this.heartRate,
    this.oxygenSaturation,
    this.respiratoryRate,
  });

  // Bewertung der Werte
  bool get heartRateNormal => heartRate != null && heartRate! >= 60 && heartRate! <= 100;
  bool get oxygenNormal => oxygenSaturation != null && oxygenSaturation! >= 95;
  bool get respiratoryNormal => respiratoryRate != null && respiratoryRate! >= 12 && respiratoryRate! <= 20;

  String get heartRateStatus {
    if (heartRate == null) return 'Keine Daten';
    if (heartRate! < 60) return 'Zu niedrig';
    if (heartRate! > 100) return 'Zu hoch';
    return 'Normal';
  }

  String get oxygenStatus {
    if (oxygenSaturation == null) return 'Keine Daten';
    if (oxygenSaturation! < 90) return 'Kritisch';
    if (oxygenSaturation! < 95) return 'Niedrig';
    return 'Normal';
  }

  String get respiratoryStatus {
    if (respiratoryRate == null) return 'Keine Daten';
    if (respiratoryRate! < 12) return 'Zu niedrig';
    if (respiratoryRate! > 20) return 'Zu hoch';
    return 'Normal';
  }

  factory VitalData.fromJson(Map<String, dynamic> json) {
    return VitalData(
      id: json['id'],
      dateTime: DateTime.parse(json['dateTime']),
      heartRate: json['heartRate'],
      oxygenSaturation: json['oxygenSaturation'],
      respiratoryRate: json['respiratoryRate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'heartRate': heartRate,
      'oxygenSaturation': oxygenSaturation,
      'respiratoryRate': respiratoryRate,
    };
  }
}