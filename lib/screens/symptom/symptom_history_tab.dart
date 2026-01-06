import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:Asthma_Assist/widgets/symptom/symptom_history_card.dart';
import 'package:Asthma_Assist/widgets/symptom/symptom_line_chart.dart';
import 'package:Asthma_Assist/widgets/symptom/symptom_trigger_bar_chart.dart';



/// Tab zum Anzeigen des Symptomverlaufs der aktuellen Woche.
///
/// Dieses stateless Widget filtert die übergebene [history] auf die aktuelle
/// Kalenderwoche (Montag bis Sonntag) und visualisiert die Daten. Es zeigt
/// sowohl den Verlauf der Symptome in einem Liniendiagramm als auch die
/// Häufigkeiten der Auslöser in einem Balkendiagramm. Anschließend folgt eine
/// Liste der einzelnen Tagebuch‑Einträge. Bei fehlenden Einträgen wird ein
/// Hinweistext angezeigt.
class SymptomHistoryTab extends StatelessWidget {
  /// Liste aller vorhandenen Tagebuch‑Einträge.
  ///
  /// Jeder Eintrag ist eine `Map` mit den Schlüsseln:
  /// - `date` – String im Format `dd.MM.yyyy`
  /// - `time` – String im Format `HH:mm`
  /// - `symptoms` – `Map<String, int>` mit Symptomintensitäten
  /// - `trigger` – String der ausgewählten Auslöser
  /// - `notes` – optionale Notizen
  final List<Map<String, dynamic>> history;

  /// Erstellt eine neue [SymptomHistoryTab].
  const SymptomHistoryTab({
    super.key,
    required this.history,
  });

  /// Liefert alle Einträge der aktuellen Kalenderwoche.
  ///
  /// Die Woche beginnt am Montag und endet am Sonntag. Einträge, deren Datum
  /// größer oder gleich dem Wochenstart und kleiner als der Beginn der
  /// folgenden Woche ist, werden berücksichtigt.
  List<Map<String, dynamic>> get currentWeekEntries {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek =
    today.subtract(Duration(days: today.weekday - 1)); // Montag
    final endOfWeek = startOfWeek.add(const Duration(days: 7)); // exklusiv

    return history.where((e) {
      final d = DateFormat('dd.MM.yyyy').parse(e['date']);
      return (d.isAtSameMomentAs(startOfWeek) || d.isAfter(startOfWeek)) &&
          d.isBefore(endOfWeek);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = currentWeekEntries;

    if (data.isEmpty) {
      return const Center(
        child: Text(
          'Keine Einträge in dieser Woche.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Symptomverlauf (diese Woche)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),


        SymptomLineChart(history: data),

        const SizedBox(height: 32),

        const Text(
          'Trigger-Häufigkeit (diese Woche)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),


        SizedBox(
          height: 220,
          child: SymptomTriggerBarChart(history: data),
        ),

        const SizedBox(height: 32),

        const Text(
          'Einträge',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),


        ...data.map(
              (e) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SymptomHistoryCard(
              date: e['date'],
              time: e['time'],
              symptoms: Map<String, int>.from(e['symptoms']),
              trigger: e['trigger'],
              notes: e['notes'],
            ),
          ),
        ),
      ],
    );
  }
}