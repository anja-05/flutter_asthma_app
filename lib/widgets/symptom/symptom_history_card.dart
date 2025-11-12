import 'package:flutter/material.dart';
import '../common/app_card.dart';

class SymptomHistoryCard extends StatelessWidget {
  final String date;
  final String time;
  final Map<String, int> symptoms;
  final String? notes;
  final String? trigger;

  const SymptomHistoryCard({
    super.key,
    required this.date,
    required this.time,
    required this.symptoms,
    this.notes,
    this.trigger,
  });

  IconData _getSymptomIcon(String symptom) {
    switch (symptom.toLowerCase()) {
      case 'husten':
        return Icons.sick;
      case 'atemnot':
        return Icons.air;
      case 'engegefühl':
        return Icons.favorite;
      case 'giemen':
        return Icons.graphic_eq;
      default:
        return Icons.circle;
    }
  }

  Color _getIntensityColor(int intensity) {
    if (intensity <= 2) {
      return const Color(0xFF4CAF50);
    } else if (intensity <= 4) {
      return const Color(0xFFFFC107);
    } else {
      return const Color(0xFFF44336);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: const Color(0xFFFFF3E0),
      borderRadius: 12,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFFFF9800),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Symptome:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 8),
          ...symptoms.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    _getSymptomIcon(entry.key),
                    size: 18,
                    color: _getIntensityColor(entry.value),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < entry.value
                            ? Icons.circle
                            : Icons.circle_outlined,
                        size: 12,
                        color: _getIntensityColor(entry.value),
                      );
                    }),
                  ),
                ],
              ),
            );
          }),
          if (trigger != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: Color(0xFFFF9800),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Auslöser: $trigger',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (notes != null && notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.note,
                    size: 16,
                    color: Color(0xFF757575),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notes!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}