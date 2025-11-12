import 'package:flutter/material.dart';
import '../common/app_card.dart';

class MedicationCard extends StatelessWidget {
  final String name;
  final String dosage;
  final String type;
  final List<String> times;
  final String? nextDoseTime;
  final bool reminderEnabled;
  final String? notes;
  final bool takenToday;
  final VoidCallback? onTaken;
  final VoidCallback? onEdit;

  const MedicationCard({
    super.key,
    required this.name,
    required this.dosage,
    required this.type,
    required this.times,
    this.nextDoseTime,
    this.reminderEnabled = true,
    this.notes,
    this.takenToday = false,
    this.onTaken,
    this.onEdit,
  });

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
    return AppCard(
      backgroundColor: const Color(0xFFE8F5E9),
      borderRadius: 12,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForType(type),
                  color: const Color(0xFF4CAF50),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                    ),
                    Text(
                      dosage,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  color: const Color(0xFF757575),
                  onPressed: onEdit,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: Color(0xFF757575),
              ),
              const SizedBox(width: 6),
              Text(
                'Zeiten: ${times.join(", ")}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757575),
                ),
              ),
            ],
          ),
          if (nextDoseTime != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  size: 16,
                  color: reminderEnabled
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFBDBDBD),
                ),
                const SizedBox(width: 6),
                Text(
                  'Nächste Einnahme: $nextDoseTime',
                  style: TextStyle(
                    fontSize: 14,
                    color: reminderEnabled
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF757575),
                    fontWeight: reminderEnabled
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
          if (notes != null && notes!.isNotEmpty) ...[
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
                    color: Color(0xFF757575),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      notes!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF757575),
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
                      ? const Color(0xFF81C784).withOpacity(0.5)
                      : const Color(0xFF4CAF50),
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
                      takenToday
                          ? 'Bereits eingenommen'
                          : 'Als eingenommen markieren',
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
    );
  }
}