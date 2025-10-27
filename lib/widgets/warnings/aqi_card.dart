import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class AQICard extends StatelessWidget {
  final int aqi; // Air Quality Index 0-500
  final String location;

  const AQICard({
    Key? key,
    required this.aqi,
    required this.location,
  }) : super(key: key);

  String _getAQICategory() {
    if (aqi <= 50) return 'Gut';
    if (aqi <= 100) return 'Mäßig';
    if (aqi <= 150) return 'Ungesund für empfindliche Gruppen';
    if (aqi <= 200) return 'Ungesund';
    if (aqi <= 300) return 'Sehr ungesund';
    return 'Gefährlich';
  }

  Color _getAQIColor() {
    if (aqi <= 50) return AppColors.successGreen;
    if (aqi <= 100) return AppColors.warningYellow;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return AppColors.emergencyRed;
    if (aqi <= 300) return const Color(0xFF9C27B0);
    return const Color(0xFF6D1B7B);
  }

  String _getAQIAdvice() {
    if (aqi <= 50) return 'Luftqualität ist ausgezeichnet. Ideale Bedingungen für Outdoor-Aktivitäten.';
    if (aqi <= 100) return 'Luftqualität ist akzeptabel. Keine Einschränkungen nötig.';
    if (aqi <= 150) return 'Empfindliche Personen sollten längere Aufenthalte im Freien reduzieren.';
    if (aqi <= 200) return 'Alle sollten längere Anstrengungen im Freien vermeiden.';
    if (aqi <= 300) return 'Gesundheitliche Warnmeldung. Jeder kann gesundheitliche Auswirkungen erleben.';
    return 'Gesundheitsalarm. Bleiben Sie drinnen und schließen Sie Fenster.';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getAQIColor();
    final category = _getAQICategory();
    final advice = _getAQIAdvice();

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Luftqualität',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.15),
                  border: Border.all(
                    color: color,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        aqi.toString(),
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        'AQI',
                        style: TextStyle(
                          fontSize: 14,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.veryLightGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      advice,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}