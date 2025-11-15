import 'package:flutter/material.dart';
import '../../models/medication.dart';
import '../common/app_card.dart';
import '../../constants//app_colors.dart';

class PastIntakeCard extends StatelessWidget {
  final PastMedicationIntake intake;
  final VoidCallback? onTap;

  const PastIntakeCard({
    Key? key,
    required this.intake,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateStr = "${intake.dateTime.day.toString().padLeft(2, '0')}."
        "${intake.dateTime.month.toString().padLeft(2, '0')}."
        "${intake.dateTime.year}";

    final timeStr = "${intake.dateTime.hour.toString().padLeft(2, '0')}:"
        "${intake.dateTime.minute.toString().padLeft(2, '0')}";

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      backgroundColor: AppColors.cardBackground,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ICON-KREIS
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.lightGreen.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: AppColors.primaryGreen,
              size: 20,
            ),
          ),

          const SizedBox(width: 16),

          // TEXTE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // DATUM + ZEIT
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateStr,
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.textPrimary)),
                    Text(timeStr,
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 4),

                Text(
                  intake.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
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
