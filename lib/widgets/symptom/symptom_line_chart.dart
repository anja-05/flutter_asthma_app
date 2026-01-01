import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SymptomLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> history;

  const SymptomLineChart({super.key, required this.history});

  static const Color atemnotColor = Color(0xFF2E7D32);
  static const Color hustenColor = Color(0xFF66BB6A);
  static const Color pfeifenColor = Color(0xFF26A69A);

  @override
  Widget build(BuildContext context) {
    final weekDays = _currentWeekDaysMonToSun();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verlauf dieser Woche (Mo–So)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: 5,

              gridData: FlGridData(
                show: true,
                horizontalInterval: 1,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.2),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ),

              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),

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

                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1, // ✅ verhindert doppelte Labels
                    getTitlesWidget: (value, _) {
                      if (value % 1 != 0) return const SizedBox.shrink();
                      final i = value.toInt();
                      if (i < 0 || i > 6) return const SizedBox.shrink();

                      // ✅ fix Mo–So (nicht "rollierend")
                      return Text(
                        _weekdayLabelMonToSun(i),
                        style: const TextStyle(fontSize: 12),
                      );
                    },
                  ),
                ),
              ),

              borderData: FlBorderData(show: false),

              lineBarsData: [
                _line(_spotsForWeek(weekDays, 'Atemnot'), atemnotColor),
                _line(_spotsForWeek(weekDays, 'Husten'), hustenColor),
                _line(_spotsForWeek(weekDays, 'Pfeifende Atmung'), pfeifenColor),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _legend(),
      ],
    );
  }

  LineChartBarData _line(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      barWidth: 3,
      color: color,
      dotData: FlDotData(show: true),
      belowBarData: BarAreaData(show: false),

      // ✅ verhindert dass die Kurve unter 0 "durchschießt"
      preventCurveOverShooting: true,
      preventCurveOvershootingThreshold: 0.1,
    );
  }

  /// ✅ aktuelle Woche (Start Montag, Ende Sonntag)
  List<DateTime> _currentWeekDaysMonToSun() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Dart weekday: Mo=1 ... So=7
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }

  /// i = 0..6 -> Mo..So
  String _weekdayLabelMonToSun(int i) {
    const labels = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    return labels[i];
  }

  List<FlSpot> _spotsForWeek(List<DateTime> weekDays, String symptom) {
    return List.generate(weekDays.length, (index) {
      final day = weekDays[index];
      final dateKey = DateFormat('dd.MM.yyyy').format(day);

      // Wenn du pro Tag mehrere Einträge hast:
      // -> hier wird der "erste" genommen (bei dir meist der neueste, wenn _history vorne insertt).
      final entry = history.firstWhere(
            (e) => e['date'] == dateKey,
        orElse: () => {},
      );

      double value = 0.0;
      if (entry.isNotEmpty) {
        final raw = entry['symptoms']?[symptom] ?? 0;
        value = (raw is num) ? raw.toDouble() : 0.0;
      }

      // ✅ Sicherheit: niemals unter 0 oder über 5
      if (value < 0) value = 0;
      if (value > 5) value = 5;

      return FlSpot(index.toDouble(), value);
    });
  }

  Widget _legend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        _LegendItem(color: atemnotColor, label: 'Atemnot'),
        _LegendItem(color: hustenColor, label: 'Husten'),
        _LegendItem(color: pfeifenColor, label: 'Pfeifende Atmung'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
