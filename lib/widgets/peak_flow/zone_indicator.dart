import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class ZoneIndicator extends StatelessWidget {
  final int personalBest;

  const ZoneIndicator({
    Key? key,
    required this.personalBest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final greenMin = (personalBest * 0.8).toInt();
    final yellowMin = (personalBest * 0.5).toInt();

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
              'Zonen-Übersicht',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildZoneRow(
              'Grüne Zone',
              AppColors.greenZone,
              '$greenMin - $personalBest l/min',
              'Alles in Ordnung',
            ),
            const SizedBox(height: 12),
            _buildZoneRow(
              'Gelbe Zone',
              AppColors.yellowZone,
              '$yellowMin - ${greenMin - 1} l/min',
              'Vorsicht geboten',
            ),
            const SizedBox(height: 12),
            _buildZoneRow(
              'Rote Zone',
              AppColors.redZone,
              '< $yellowMin l/min',
              'Sofortige Maßnahmen',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneRow(String title, Color color, String range, String description) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                '$range - $description',
                style: const TextStyle(
                  fontSize: 12,
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