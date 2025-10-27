/*import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/peak_flow_measurement.dart';
import '../../constants/app_colors.dart';

class PeakFlowChart extends StatelessWidget {
  final List<PeakFlowMeasurement> measurements;
  final int personalBest;

  const PeakFlowChart({
    Key? key,
    required this.measurements,
    required this.personalBest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (measurements.isEmpty) {
      return const Center(
        child: Text('Keine Daten verfügbar'),
      );
    }

    // Sortiere Messungen nach Datum
    final sortedMeasurements = List<PeakFlowMeasurement>.from(measurements)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    // Nehme die letzten 7 Messungen
    final displayMeasurements = sortedMeasurements.length > 7
        ? sortedMeasurements.sublist(sortedMeasurements.length - 7)
        : sortedMeasurements;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verlauf (letzte 7 Tage)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 100,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= displayMeasurements.length) {
                            return const SizedBox.shrink();
                          }
                          final measurement = displayMeasurements[value.toInt()];
                          return Text(
                            '${measurement.dateTime.day}.${measurement.dateTime.month}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: 0,
                  maxY: personalBest.toDouble() + 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: displayMeasurements.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value.value.toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      color: AppColors.primaryGreen,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          final measurement = displayMeasurements[index];
                          return FlDotCirclePainter(
                            radius: 4,
                            color: measurement.zoneColor,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primaryGreen.withOpacity(0.1),
                      ),
                    ),
                  ],
                  // Zone-Linien
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: personalBest * 0.8,
                        color: AppColors.greenZone.withOpacity(0.3),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      ),
                      HorizontalLine(
                        y: personalBest * 0.5,
                        color: AppColors.yellowZone.withOpacity(0.3),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/