import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Die Datei zeigt eine einzelne Peak-Flow-Messung.
/// Diese Klasse kapselt:
/// - den gemessenen Peak-Flow-Wert
/// - den persönlichen Bestwert
/// - die zeitliche Einordnung
/// - die medizinische Bewertung (Zonenmodell)
///
/// Das Zonenmodell basiert auf der prozentualen Abweichung vom persönlichen Bestwert:
/// ≥ 80 % → Grüne Zone
/// 50–79 % → Gelbe Zone
/// < 50 % → Rote Zone
class PeakFlowMeasurement {
  /// Eindeutige ID der Messung.
  final String id;
  /// Zeitpunkt der Messung.
  final DateTime dateTime;
  /// Gemessener Peak-Flow-Wert
  final int value;
  /// Persönlicher Bestwert des Nutzers.
  final int personalBest;
  /// Optionaler Freitext-Kommentar zur Messung.
  final String? notes;

  /// Erstellt eine neue [PeakFlowMeasurement].
  PeakFlowMeasurement({
    required this.id,
    required this.dateTime,
    required this.value,
    required this.personalBest,
    this.notes,
  });

  /// Prozentualer Anteil des aktuellen Werts im Vergleich zum persönlichen Bestwert.
  double get percentageOfBest => (value / personalBest) * 100;

  /// Bestimmt die medizinische Zone basierend auf [percentageOfBest].
  /// Rückgabewerte:
  /// "Grüne Zone" bei ≥ 80 %
  /// "Gelbe Zone" bei ≥ 50 %
  /// "Rote Zone" bei < 50 %
  String get zone {
    if (percentageOfBest >= 80) return 'Grüne Zone';
    if (percentageOfBest >= 50) return 'Gelbe Zone';
    return 'Rote Zone';
  }

  /// Gibt die passende UI-Farbe zur aktuellen Zone zurück.
  Color get zoneColor {
    if (percentageOfBest >= 80) return AppColors.greenZone;
    if (percentageOfBest >= 50) return AppColors.yellowZone;
    return AppColors.redZone;
  }

  /// Medizinisch verständliche Beschreibung der aktuellen Zone.
  String get zoneDescription {
    if (percentageOfBest >= 80) {
      return 'Alles in Ordnung. Keine Symptome.';
    } else if (percentageOfBest >= 50) {
      return 'Vorsicht! Symptome können auftreten.';
    }
    return 'Gefahr! Sofortige Maßnahmen erforderlich.';
  }

  /// Erstellt eine [PeakFlowMeasurement] aus einer JSON-Struktur.
  factory PeakFlowMeasurement.fromJson(Map<String, dynamic> json) {
    return PeakFlowMeasurement(
      id: json['id'],
      dateTime: DateTime.parse(json['dateTime']),
      value: json['value'],
      personalBest: json['personalBest'],
      notes: json['notes'],
    );
  }
  /// Serialisiert die Messung in ein JSON-kompatibles Format.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'value': value,
      'personalBest': personalBest,
      'notes': notes,
    };
  }
}