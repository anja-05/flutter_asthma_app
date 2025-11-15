// lib/widgets/medication/medication_card.dart
import 'package:flutter/material.dart';
import '../../models/medication.dart';
import '../common/app_card.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback? onEdit;

  const MedicationCard({
    Key? key,
    required this.medication,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onEdit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            medication.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text('Dosierung: ${medication.dosage}'),
          Text('Typ: ${medication.type}'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: medication.times
                .map((t) => Chip(
              label: Text(t),
              backgroundColor: const Color(0xFFE8F5E9),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }
}