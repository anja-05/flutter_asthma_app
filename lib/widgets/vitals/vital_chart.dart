/*import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/vital_data.dart';
import '../../constants/app_colors.dart';

class VitalChart extends StatelessWidget {
  final List<VitalData> data;
  final String type; // 'heartRate', 'oxygenSaturation', 'respiratoryRate'

  const VitalChart({
    Key? key,
    required this.data,
    required this.type,
  }) : super(key: key);

  String get chartTitle {
    switch (type) {
      case 'heartRate':
        return 'Puls-Verlauf';
      case 'oxygenSaturation':
        return 'Sauerstoffsättigung-Verlauf';
      case 'respiratoryRate':
        return 'Atemfrequenz-Verlauf';
      default:
        return '';
    }
  }

  Color get chartColor {
    switch (type) {
      case 'heartRate':
        return AppColors.emergencyRed;
      case 'oxygenSaturation':
        return AppColors.primaryGreen;
      case 'respiratoryRate':
        return AppColors.tealAccent;
      default:
        return AppColors.primaryGreen;
    }
  }

  List<FlSpot> get spots {
    final filteredData = data.where((d) {
      switch (type) {
        case 'heartRate':
          return d.heartRate != null;
        case 'oxygenSaturation':
          return d.oxygenSaturation != null;
        case 'respiratoryRate':
          return d.respiratoryRate != null;
        default:
          return false;
      }
    }).toList();

    if (filteredData.isEmpty) return [];

    // Sortiere nach Datum
    filteredData.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    // Nehme die letzten 10 Messungen
    final displayData = filteredData.length > 10
        ? filteredData.sublist(filteredData.length - 10)
        : filteredData;

    return displayData.asMap().entries.map((entry) {
      double value = 0;
      switch (type) {
        case 'heartRate':
          value = entry.value.heartRate!.toDouble();
          break;
        case 'oxygenSaturation':
          value = entry.value.oxygenSaturation!.toDouble();
          break;
        case 'respiratoryRate':
          value = entry.value.respiratoryRate!.toDouble();
          break;
      }
      return FlSpot(entry.key.toDouble(), value);
    }).toList();
  }

  double get minY {
    switch (type) {
      case 'heartRate':
        return 40;
      case 'oxygenSaturation':
        return 85;
      case 'respiratoryRate':
        return 8;
      default:
        return 0;
    }
  }

  double get maxY {
    switch (type) {
      case 'heartRate':
        return 120;
      case 'oxygenSaturation':
        return 100;
      case 'respiratoryRate':
        return 25;
      default:
        return 100;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) {
      return Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'Keine Daten verfügbar',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

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
            Text(
              chartTitle,
              style: const TextStyle(
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
                          if (value.toInt() >= data.length) {
                            return const SizedBox.shrink();
                          }
                          final measurement = data[value.toInt()];
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
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: chartColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: chartColor,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: chartColor.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/