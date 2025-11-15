import 'package:flutter/material.dart';
import '../widgets/emergency/emergency_checklist_card.dart';
import '../widgets/emergency/emergency_contact_list.dart';
import '../widgets/common/info_card.dart';
import '../widgets/emergency/floating_sos_button.dart';
import '../constants/app_colors.dart';

class EmergencyPlanScreen extends StatelessWidget {
  const EmergencyPlanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<EmergencyStep> emergencySteps = [
      EmergencyStep(text: 'Ruhe bewahren und aufrecht hinsetzen'),
      EmergencyStep(text: 'Schnellwirkendes Medikament (z. B. Inhalator) anwenden'),
      EmergencyStep(text: 'Peak-Flow messen'),
      EmergencyStep(text: 'Wenn keine Besserung: Notruf oder Kontaktperson verständigen'),
    ];

    final List<EmergencyContact> contacts = [
      EmergencyContact(
        id: '1',
        name: 'Anna Müller',
        phoneNumber: '0151 2345678',
        relationship: 'Kontaktperson',
        isPrimary: true,
      ),
    ];

    final List<String> importantHints = [
      'Bei akuter Atemnot sofort Notarzt rufen',
      'Notfallmedikation immer griffbereit haben',
      'Im Zweifel lieber einmal zu viel als zu wenig Hilfe holen',
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Notfallplan',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Im Notfall schnell handeln – dein persönlicher Plan und SOS-Kontakte.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: const [
                  Text(
                    'Donnerstag, 23. Oktober 2025',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.wb_sunny, color: Colors.orangeAccent, size: 18),
                ],
              ),
              const SizedBox(height: 24),

              // Emergency Steps
              EmergencyChecklistCard(steps: emergencySteps),
              const SizedBox(height: 24),

              // Contact List with 112 + contact
              EmergencyContactList(
                contacts: contacts,
                onCall: (contact) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Rufe ${contact.name} an...')),
                  );
                },
                onAdd: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Neuen Kontakt hinzufügen...')),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Important Tips
              const InfoCard(
                title: 'Wichtige Hinweise',
                items: [
                  'Bei akuter Atemnot sofort Notarzt rufen',
                  'Notfallmedikation immer griffbereit haben',
                  'Im Zweifel lieber einmal zu viel als zu wenig Hilfe holen',
                ],
                icon: Icons.lightbulb,
                backgroundColor: Color(0xFFFFF3E0),
                accentColor: Color(0xFFF57C00),
              ),
            ],
          ),
        ),
      ),

      // Floating SOS Button
      bottomNavigationBar: FloatingSOSButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('SOS gedrückt – Hilfe wird geholt...')),
          );
        },
        isActive: false,
      ),
    );
  }
}
