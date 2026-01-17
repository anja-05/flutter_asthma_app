import 'package:flutter/material.dart';
import '../common/app_card.dart';
import '../../models/emergency_step.dart';

/// Zeigt eine Notfall-Checkliste mit mehreren Schritten an.
/// Die Karte stellt eine visuelle Übersicht bereit und erlaubt
/// einzelne Schritte anzutippen (z. B. für Details oder Aktionen).
class EmergencyChecklistCard extends StatelessWidget {
  /// Liste der anzuzeigenden Notfall-Schritte.
  final List<EmergencyStep> steps;

  /// Callback beim Antippen eines Schritts. Übergibt den Index des ausgewählten Schritts.
  final Function(int)? onStepTap;

  const EmergencyChecklistCard({
    Key? key,
    required this.steps,
    this.onStepTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: const Color(0xFFFFEBEE),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.warning,
                  color: Color(0xFFE53935),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Was tun im Notfall?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE53935),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: onStepTap != null
                    ? () => onStepTap!(index)
                    : null,
                child: _buildStep(index + 1, step),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStep(int number, EmergencyStep step) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: step.completed
            ? Border.all(color: Colors.green, width: 1.5)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Status-Icon statt nur Nummer
          Icon(
            step.completed ? Icons.check_circle : Icons.circle_outlined,
            color: step.completed ? Colors.green : const Color(0xFFE53935),
            size: 22,
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Text(
              '$number. ${step.text}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF212121),
              ),
            ),
          ),
        ],
      ),
    );
  }
}