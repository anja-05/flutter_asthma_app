import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

enum WarningLevel { good, moderate, high, veryHigh }

class WarningBanner extends StatelessWidget {
  final WarningLevel level;
  final String title;
  final String description;

  const WarningBanner({
    Key? key,
    required this.level,
    required this.title,
    required this.description,
  }) : super(key: key);

  Color _getColorForLevel() {
    switch (level) {
      case WarningLevel.good:
        return AppColors.successGreen;
      case WarningLevel.moderate:
        return AppColors.warningYellow;
      case WarningLevel.high:
        return Colors.orange;
      case WarningLevel.veryHigh:
        return AppColors.emergencyRed;
    }
  }

  IconData _getIconForLevel() {
    switch (level) {
      case WarningLevel.good:
        return Icons.check_circle;
      case WarningLevel.moderate:
        return Icons.warning_amber;
      case WarningLevel.high:
        return Icons.warning;
      case WarningLevel.veryHigh:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForLevel();
    final icon = _getIconForLevel();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}