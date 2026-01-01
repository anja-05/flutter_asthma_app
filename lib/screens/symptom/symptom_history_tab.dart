import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:Asthma_Assist/widgets/symptom/symptom_history_card.dart';
import 'package:Asthma_Assist/widgets/symptom/symptom_line_chart.dart';
import 'package:Asthma_Assist/widgets/symptom/symptom_trigger_bar_chart.dart';

class SymptomHistoryTab extends StatelessWidget {
  final List<Map<String, dynamic>> history;

  const SymptomHistoryTab({
    super.key,
    required this.history,
  });

  List<Map<String, dynamic>> get currentWeekEntries {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1)); // Mo
    final endOfWeek = startOfWeek.add(const Duration(days: 7)); // exklusiv

    return history.where((e) {
      final d = DateFormat('dd.MM.yyyy').parse(e['date']);
      return (d.isAtSameMomentAs(startOfWeek) || d.isAfter(startOfWeek)) && d.isBefore(endOfWeek);
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

        // ✅ 3 Linien + Legende + Mo–So + 0..5
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
