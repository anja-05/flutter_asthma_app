import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SymptomTriggerBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> history;

  const SymptomTriggerBarChart({
    super.key,
    required this.history,
  });

  Map<String, int> _countTriggers() {
    final Map<String, int> counts = {};

    for (final entry in history) {
      final t = entry['trigger'] as String?;
      if (t == null || t.isEmpty) continue;

      for (final trigger in t.split(', ')) {
        counts[trigger] = (counts[trigger] ?? 0) + 1;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final counts = _countTriggers();

    if (counts.isEmpty) {
      return const Center(
        child: Text('Keine Trigger erfasst.'),
      );
    }

    final keys = counts.keys.toList();
    final values = counts.values.toList();

    final maxValue = values.reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,

        minY: 0,
        maxY: (maxValue + 1).toDouble(), // ✅ sauberer Ganzzahl-Raum

        gridData: FlGridData(
          show: true,
          horizontalInterval: 1, // ✅ nur ganze Schritte
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.25),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),

        borderData: FlBorderData(show: false),

        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          // ✅ Y-ACHSE NUR 0,1,2,3,...
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 28,
              getTitlesWidget: (value, _) {
                if (value % 1 != 0) return const SizedBox.shrink();
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),

          // X-Achse: Trigger-Namen
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= keys.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    keys[i],
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ),
        ),

        barGroups: List.generate(keys.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: counts[keys[i]]!.toDouble(),
                width: 26,
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          );
        }),
      ),
    );
  }
}
