import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/peak_flow_measurement.dart';
import '../widgets/peak_flow/peak_flow_chart.dart';
import '../widgets/peak_flow/peak_flow_meter.dart';
import '../widgets/peak_flow/zone_indicator.dart';
import '../constants/app_colors.dart';
/// Der Screen ist nur ein Beispiel wie er einmal auschauen könnte.
/// Er ist nicht fertig impplementiert.
/// Er dient nur zur Veranschaulichung
/// Ziel des Screens:
/// - Visualisierung der aktuellen Peak-Flow-Messung
/// - Darstellung des zeitlichen Verlaufs
/// - Erklärung der medizinischen Zonen (grün / gelb / rot)
class PeakFlowScreen extends StatefulWidget {
  /// Erstellt einen neuen [PeakFlowScreen].
  const PeakFlowScreen({super.key});

  @override
  State<PeakFlowScreen> createState() => _PeakFlowScreenState();
}

/// Zustandsklasse für den [PeakFlowScreen].
/// Enthält:
/// - Beispielhafte Peak-Flow-Messdaten
/// - UI-Logik zur Darstellung von Messwerten und Zonen
class _PeakFlowScreenState extends State<PeakFlowScreen> {
  /// Beispielhafte Liste von Peak-Flow-Messungen.
  /// Diese Daten sind statisch und dienen ausschließlich zur Demonstration von Diagrammen und UI-Komponenten.
  final List<PeakFlowMeasurement> measurements = [
    PeakFlowMeasurement(
      id: '1',
      dateTime: DateTime(2025, 10, 15),
      value: 310,
      personalBest: 400,
      notes: '',
    ),
    PeakFlowMeasurement(
      id: '2',
      dateTime: DateTime(2025, 10, 16),
      value: 330,
      personalBest: 400,
      notes: '',
    ),
    PeakFlowMeasurement(
      id: '3',
      dateTime: DateTime(2025, 10, 17),
      value: 360,
      personalBest: 400,
    ),
    PeakFlowMeasurement(
      id: '4',
      dateTime: DateTime(2025, 10, 18),
      value: 340,
      personalBest: 400,
    ),
    PeakFlowMeasurement(
      id: '5',
      dateTime: DateTime(2025, 10, 19),
      value: 320,
      personalBest: 400,
    ),
    PeakFlowMeasurement(
      id: '6',
      dateTime: DateTime(2025, 10, 20),
      value: 300,
      personalBest: 400,
    ),
    PeakFlowMeasurement(
      id: '7',
      dateTime: DateTime(2025, 10, 21),
      value: 310,
      personalBest: 400,
    ),
  ];

  /// Startet eine neue Peak-Flow-Messung.
  /// Aktuell nur als Platzhalter implementiert.
  /// Später kann hier z. B. eine Geräteanbindung oder eine Eingabemaske integriert werden.
  void _startNewMeasurement() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Neue Messung starten...')),
    );
  }

  /// Baut die Benutzeroberfläche des Peak-Flow-Screens.
  @override
  Widget build(BuildContext context) {
    final latest = measurements.last;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/dashboard',
              (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            children: [
              const Text(
                'Peak-Flow Messungen',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Verfolge deine Lungenfunktion und erkenne Veränderungen frühzeitig.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    _formatDate(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Aktuelle Messung
              PeakFlowMeter(
                currentValue: latest.value.toDouble(),
                personalBest: latest.personalBest.toDouble(),
                onMeasure: _startNewMeasurement,
              ),

              const SizedBox(height: 24),

              // Verlauf als Chart
              PeakFlowChart(
                data: measurements
                    .map(
                      (m) => PeakFlowData(
                    date:
                    '${m.dateTime.day.toString().padLeft(2, '0')}.${m.dateTime.month.toString().padLeft(2, '0')}',
                    value: m.value.toDouble(),
                  ),
                )
                    .toList(),
                personalBest: latest.personalBest.toDouble(),
              ),

              const SizedBox(height: 32),

              // Zonen-Info
              _buildZoneExplanation(),
            ],
          ),
        ),
      ),
    );
  }

  /// Erstellt eine Infobox zur Interpretation der Peak-Flow-Zonen.
  /// Die Zonen basieren auf dem prozentualen Anteil des persönlichen Bestwerts:
  /// - Grün (≥ 80 %)
  /// - Gelb (50–79 %)
  /// - Rot (< 50 %)
  Widget _buildZoneExplanation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Hinweise zur Interpretation',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          _ZoneInfo(
            color: AppColors.greenZone,
            title: 'Grüne Zone (≥ 80%)',
            description: 'Alles in Ordnung. Keine Symptome.',
          ),
          SizedBox(height: 12),
          _ZoneInfo(
            color: AppColors.yellowZone,
            title: 'Gelbe Zone (50–79%)',
            description: 'Vorsicht! Symptome können auftreten.',
          ),
          SizedBox(height: 12),
          _ZoneInfo(
            color: AppColors.redZone,
            title: 'Rote Zone (< 50%)',
            description: 'Gefahr! Sofortige Maßnahmen erforderlich.',
          ),
        ],
      ),
    );
  }

  /// Formatiert ein Datum in ein lesbares deutsches Format.
  String _formatDate(DateTime date) {
    final weekdays = [
      'Montag',
      'Dienstag',
      'Mittwoch',
      'Donnerstag',
      'Freitag',
      'Samstag',
      'Sonntag',
    ];
    final months = [
      'Januar',
      'Februar',
      'März',
      'April',
      'Mai',
      'Juni',
      'Juli',
      'August',
      'September',
      'Oktober',
      'November',
      'Dezember',
    ];
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];

    return '$weekday, ${date.day}. $month ${date.year}';
  }
}

/// Interne UI-Komponente zur Darstellung einer Peak-Flow-Zone.
/// Wird ausschließlich innerhalb des [PeakFlowScreen] zur Erklärung der Zonen verwendet.
class _ZoneInfo extends StatelessWidget {
  /// Farbe der Zone.
  final Color color;
  /// Titel der Zone.
  final String title;
  /// Beschreibung der Zone.
  final String description;

  /// Erstellt ein neues [_ZoneInfo]-Widget.
  const _ZoneInfo({
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
