import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PeakFlowMeasurement {
  final String id;
  final DateTime dateTime;
  final int value;
  final int personalBest;
  final String? notes;

  PeakFlowMeasurement({
    required this.id,
    required this.dateTime,
    required this.value,
    required this.personalBest,
    this.notes,
  });

  // Berechne Prozent vom persönlichen Bestwert
  double get percentageOfBest => (value / personalBest) * 100;

  // Bestimme Zone basierend auf Prozentsatz
  String get zone {
    if (percentageOfBest >= 80) return 'Grüne Zone';
    if (percentageOfBest >= 50) return 'Gelbe Zone';
    return 'Rote Zone';
  }

  Color get zoneColor {
    if (percentageOfBest >= 80) return AppColors.greenZone;
    if (percentageOfBest >= 50) return AppColors.yellowZone;
    return AppColors.redZone;
  }

  String get zoneDescription {
    if (percentageOfBest >= 80) {
      return 'Alles in Ordnung. Keine Symptome.';
    } else if (percentageOfBest >= 50) {
      return 'Vorsicht! Symptome können auftreten.';
    }
    return 'Gefahr! Sofortige Maßnahmen erforderlich.';
  }

  factory PeakFlowMeasurement.fromJson(Map<String, dynamic> json) {
    return PeakFlowMeasurement(
      id: json['id'],
      dateTime: DateTime.parse(json['dateTime']),
      value: json['value'],
      personalBest: json['personalBest'],
      notes: json['notes'],
    );
  }

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