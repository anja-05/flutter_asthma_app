import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

enum PollenLevel { none, low, medium, high, veryHigh }

class PollenData {
  final String type;
  final PollenLevel level;

  PollenData({required this.type, required this.level});
}

class PollenCard extends StatelessWidget {
  final List<PollenData> pollenData;

  const PollenCard({
    Key? key,
    required this.pollenData,
  }) : super(key: key);

  Color _getColorForLevel(PollenLevel level) {
    switch (level) {
      case PollenLevel.none:
        return Colors.grey;
      case PollenLevel.low:
        return AppColors.successGreen;
      case PollenLevel.medium:
        return AppColors.warningYellow;
      case PollenLevel.high:
        return Colors.orange;
      case PollenLevel.veryHigh:
        return AppColors.emergencyRed;
    }
  }

  String _getLabelForLevel(PollenLevel level) {
    switch (level) {
      case PollenLevel.none:
        return 'Keine';
      case PollenLevel.low:
        return 'Niedrig';
      case PollenLevel.medium:
        return 'Mittel';
      case PollenLevel.high:
        return 'Hoch';
      case PollenLevel.veryHigh:
        return 'Sehr hoch';
    }
  }

  @override
  Widget build(BuildContext context) {
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
              children: [
                Icon(
                  Icons.local_florist,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Pollenbelastung',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...pollenData.map((data) {
              final color = _getColorForLevel(data.level);
              final label = _getLabelForLevel(data.level);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data.type,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: _getValueForLevel(data.level),
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  double _getValueForLevel(PollenLevel level) {
    switch (level) {
      case PollenLevel.none:
        return 0.0;
      case PollenLevel.low:
        return 0.25;
      case PollenLevel.medium:
        return 0.5;
      case PollenLevel.high:
        return 0.75;
      case PollenLevel.veryHigh:
        return 1.0;
    }
  }
}