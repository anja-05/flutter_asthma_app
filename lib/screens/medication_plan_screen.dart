import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';
import '../../models/medication.dart';
import '../../widgets/medication/medication_intake_card.dart';
import '../../widgets/medication/past_intake_card.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  // Beispiel-Daten
  final List<MedicationIntake> todayIntakes = [
    MedicationIntake(
      id: '1',
      name: 'Salbutamol Inhalator',
      dosage: '2 Hübe à 100 µg',
      time: '08:00 Uhr',
      type: 'Inhalator',
      taken: true,
    ),
    MedicationIntake(
      id: '2',
      name: 'Kortison Spray',
      dosage: '1 Hub à 250 µg',
      time: '12:00 Uhr',
      type: 'Spray',
      taken: true,
    ),
    MedicationIntake(
      id: '3',
      name: 'Salbutamol Inhalator',
      dosage: '2 Hübe à 100 µg',
      time: '18:00 Uhr',
      type: 'Inhalator',
      taken: false,
    ),
    MedicationIntake(
      id: '4',
      name: 'Kortison Spray',
      dosage: '1 Hub à 250 µg',
      time: '20:00 Uhr',
      type: 'Spray',
      taken: false,
    ),
  ];

  final List<PastMedicationIntake> pastIntakes = [
    PastMedicationIntake(
      id: '5',
      name: 'Salbutamol Inhalator',
      dosage: '2 Hübe à 100 µg',
      type: 'Inhalator',
      dateTime: DateTime(2025, 10, 20, 18, 0),
    ),
    PastMedicationIntake(
      id: '6',
      name: 'Kortison Spray',
      dosage: '1 Hub à 250 µg',
      type: 'Spray',
      dateTime: DateTime(2025, 10, 20, 12, 0),
    ),
    PastMedicationIntake(
      id: '7',
      name: 'Salbutamol Inhalator',
      dosage: '2 Hübe à 100 µg',
      type: 'Inhalator',
      dateTime: DateTime(2025, 10, 19, 18, 0),
    ),
  ];

  void _markAsTaken(MedicationIntake intake) {
    setState(() {
      final index = todayIntakes.indexWhere((i) => i.id == intake.id);
      if (index != -1) {
        todayIntakes[index] = intake.markAsTaken();
      }
    });
  }

  void _addMedication() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Medikament hinzufügen gedrückt')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: [
            // ✅ Überschrift
            const Text(
              'Medikationsplan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Plane deine Medikamenteneinnahmen und erhalte Erinnerungen.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('EEEE, dd. MMMM yyyy', 'de_DE').format(DateTime(2025, 10, 22)),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Heutige Medikamente',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 12),

            // ✅ Liste heutiger Einnahmen
            ...todayIntakes.map((intake) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MedicationIntakeCard(
                  intake: intake,
                  onMarkAsTaken: () => _markAsTaken(intake),
                ),
              );
            }),

            const SizedBox(height: 12),

            // ✅ Button hinzufügen
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addMedication,
                icon: const Icon(Icons.add),
                label: const Text('Medikament hinzufügen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ✅ Erinnerungen
            Container(
              decoration: BoxDecoration(
                color: AppColors.lightGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.notifications_active,
                      color: AppColors.primaryGreen),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Erinnerungen sind aktiviert. Du erhältst Benachrichtigungen zur Einnahmezeit.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Vergangene Einnahmen',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 12),

            ...pastIntakes.map((intake) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PastIntakeCard(intake: intake),
              );
            }),
          ],
        ),
      ),
    );
  }
}
