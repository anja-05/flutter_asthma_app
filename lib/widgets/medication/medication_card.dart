/*import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/medication.dart';
import '../../constants/app_colors.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback? onTaken;
  final VoidCallback? onEdit;

  const MedicationCard({
    Key? key,
    required this.medication,
    this.onTaken,
    this.onEdit,
  }) : super(key: key);

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'inhalator':
        return Icons.air;
      case 'tablette':
        return Icons.medication;
      case 'spray':
        return Icons.water_drop;
      default:
        return Icons.medication;
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextDose = medication.nextDoseTime;
    final takenToday = medication.takenToday;

    return Card(
      elevation: 0,
      color: AppColors.medicationCardBg,
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconForType(medication.type),
                    color: AppColors.primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        medication.dosage,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    color: AppColors.textSecondary,
                    onPressed: onEdit,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Zeiten: ${medication.times.join(", ")}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (nextDose != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    size: 16,
                    color: medication.reminderEnabled
                        ? AppColors.primaryGreen
                        : AppColors.textLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Nächste Einnahme: $nextDose',
                    style: TextStyle(
                      fontSize: 14,
                      color: medication.reminderEnabled
                          ? AppColors.primaryGreen
                          : AppColors.textSecondary,
                      fontWeight: medication.reminderEnabled
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
            if (medication.notes != null && medication.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        medication.notes!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (onTaken != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: takenToday ? null : onTaken,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: takenToday
                        ? AppColors.successGreen.withOpacity(0.5)
                        : AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        takenToday ? Icons.check_circle : Icons.check,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        takenToday ? 'Bereits eingenommen' : 'Als eingenommen markieren',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}*/