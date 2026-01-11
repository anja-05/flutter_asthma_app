import 'package:flutter/material.dart';
import '../../models/medication.dart';
import '../common/app_card.dart';
import '../../constants//app_colors.dart';

class MedicationIntakeCard extends StatelessWidget {
  final MedicationIntake intake;
  final VoidCallback onMarkAsTaken;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const MedicationIntakeCard({
    Key? key,
    required this.intake,
    required this.onMarkAsTaken,
    this.onTap,
    this.onDelete, // NEU
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taken = intake.taken;

    return AppCard(
      backgroundColor: AppColors.medicationCardBg,
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.lightGreen.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medication,
              size: 22,
              color: AppColors.primaryGreen,
            ),
          ),

          const SizedBox(width: 16),

          // TEXTE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  intake.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  intake.dosage,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.schedule,
                        size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      intake.time,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // STATUS ICON & LÖSCHEN-ICON RECHTS
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 1. LÖSCHEN ICON
              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 26,
                  ),
                ),
              const SizedBox(height: 10),

              // 2. STATUS ICON
              taken
                  ? const Icon(
                Icons.check_circle,
                color: AppColors.primaryGreen,
                size: 26,
              )
                  : GestureDetector(
                onTap: onMarkAsTaken,
                child: const Icon(
                  Icons.schedule,
                  color: AppColors.textSecondary,
                  size: 26,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}