/// Repräsentiert einen Satz von Vitalparametern zu einem bestimmten Zeitpunkt.
/// Diese Klasse fasst mehrere medizinische Messwerte zusammen:
/// - Herzfrequenz
/// - Sauerstoffsättigung (SpO₂)
/// - Atemfrequenz
///
/// Alle Werte sind optional, da einzelne Sensoren oder Messungen
/// zeitweise nicht verfügbar sein können.
///
/// Die Klasse enthält zusätzlich einfache medizinische Bewertungen
/// (Normalbereich / Auffälligkeit) zur direkten Verwendung in der UI.
class VitalData {
  /// Eindeutige ID des Vitaldatensatzes.
  final String id;
  /// Zeitpunkt der Messung.
  final DateTime dateTime;
  /// Herzfrequenz in Schlägen pro Minute (bpm).
  /// Optional, da der Wert nicht immer verfügbar sein muss.
  final int? heartRate;
  /// Sauerstoffsättigung des Blutes (SpO₂) in Prozent.
  /// Optional.
  final int? oxygenSaturation;
  /// Atemfrequenz in Atemzügen pro Minute.
  /// Optional, abhängig von Messmethode oder Gerät.
  final int? respiratoryRate;

  /// Erstellt einen neuen [VitalData]-Datensatz.
  VitalData({
    required this.id,
    required this.dateTime,
    this.heartRate,
    this.oxygenSaturation,
    this.respiratoryRate,
  });

  /// Gibt an, ob die Herzfrequenz, Sauerstoffsättigung und die Atemfrequenz im Normbereich liegen.
  bool get heartRateNormal => heartRate != null && heartRate! >= 60 && heartRate! <= 100;
  bool get oxygenNormal => oxygenSaturation != null && oxygenSaturation! >= 95;
  bool get respiratoryNormal => respiratoryRate != null && respiratoryRate! >= 12 && respiratoryRate! <= 20;

  /// Textuelle Bewertung der Herzfrequenz.
  String get heartRateStatus {
    if (heartRate == null) return 'Keine Daten';
    if (heartRate! < 60) return 'Zu niedrig';
    if (heartRate! > 100) return 'Zu hoch';
    return 'Normal';
  }

  /// Textuelle Bewertung der Sauerstoffsättigung.
  String get oxygenStatus {
    if (oxygenSaturation == null) return 'Keine Daten';
    if (oxygenSaturation! < 90) return 'Kritisch';
    if (oxygenSaturation! < 95) return 'Niedrig';
    return 'Normal';
  }

  /// Textuelle Bewertung der Atemfrequenz.
  String get respiratoryStatus {
    if (respiratoryRate == null) return 'Keine Daten';
    if (respiratoryRate! < 12) return 'Zu niedrig';
    if (respiratoryRate! > 20) return 'Zu hoch';
    return 'Normal';
  }

  /// Erstellt ein [VitalData]-Objekt aus einer JSON-Struktur.
  factory VitalData.fromJson(Map<String, dynamic> json) {
    return VitalData(
      id: json['id'],
      dateTime: DateTime.parse(json['dateTime']),
      heartRate: json['heartRate'],
      oxygenSaturation: json['oxygenSaturation'],
      respiratoryRate: json['respiratoryRate'],
    );
  }

  /// Serialisiert den Vitaldatensatz in ein JSON-kompatibles Format.
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