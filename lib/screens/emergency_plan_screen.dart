import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/phone_service.dart';
import '../widgets/emergency/emergency_checklist_card.dart';
import '../widgets/emergency/emergency_contact_list.dart';
import '../widgets/common/info_card.dart';
import '../widgets/emergency/floating_sos_button.dart';
import '../constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/emergency_step.dart';

/// Bildschirm zur Anzeige des persönlichen Notfallplans.
/// Der Screen zeigt:
/// - eine Schritt-für-Schritt-Notfallanleitung
/// - persönliche Notfallkontakte
/// - allgemeine Hinweise
/// - einen jederzeit erreichbaren SOS-Button
class EmergencyPlanScreen extends StatefulWidget {
  const EmergencyPlanScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyPlanScreen> createState() => _EmergencyPlanScreenState();
}

class _EmergencyPlanScreenState extends State<EmergencyPlanScreen> {
  /// Liste der gespeicherten Notfallkontakte.
  final List<EmergencyContact> contacts = [];

  /// Liste der Notfall-Schritte, deren Status (abgehakt / offen)
  /// während der Laufzeit geändert werden kann.
  late List<EmergencyStep> emergencySteps;

  @override
  void initState() {
    super.initState();

    emergencySteps = [
      EmergencyStep(text: 'Ruhe bewahren und aufrecht hinsetzen'),
      EmergencyStep(
        text: 'Schnellwirkendes Medikament (z. B. Inhalator) anwenden',
      ),
      EmergencyStep(text: 'Peak-Flow messen'),
      EmergencyStep(
        text: 'Wenn keine Besserung: Notruf oder Kontaktperson verständigen',
      ),
    ];

    _loadContacts();
  }

  /// Lädt die gespeicherten Notfallkontakte aus den lokalen Einstellungen.
  /// Bei fehlerhaften oder ungültigen Daten wird die Kontaktliste geleert.
  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('contacts');

    if (jsonString == null) return;

    try {
      final List decoded = json.decode(jsonString);

      setState(() {
        contacts
          ..clear()
          ..addAll(
            decoded.map(
                  (c) => EmergencyContact(
                id: c['id'],
                name: c['name'],
                phoneNumber: c['phoneNumber'],
                relationship: c['relationship'],
                isPrimary: c['isPrimary'] ?? false,
              ),
            ),
          );
      });
    } catch (_) {
      setState(() => contacts.clear());
    }
  }

  /// Speichert die aktuellen Notfallkontakte lokal.
  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();

    final List mapList = contacts
        .map((c) => {
      'id': c.id,
      'name': c.name,
      'phoneNumber': c.phoneNumber,
      'relationship': c.relationship,
      'isPrimary': c.isPrimary,
    })
        .toList();

    await prefs.setString('contacts', json.encode(mapList));
  }

  /// Öffnet einen Dialog zum Hinzufügen eines neuen Notfallkontakts.
  /// Der erste angelegte Kontakt wird automatisch als primärer Kontakt markiert.
  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Neuen Kontakt hinzufügen"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Telefonnummer"),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Abbrechen"),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();

              if (name.isEmpty || phone.length < 5) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Bitte gültigen Namen und Telefonnummer eingeben.",
                    ),
                  ),
                );
                return;
              }

              setState(() {
                if (contacts.isEmpty) {
                  contacts.add(
                    EmergencyContact(
                      id: DateTime.now()
                          .millisecondsSinceEpoch
                          .toString(),
                      name: name,
                      phoneNumber: phone,
                      relationship: "Kontaktperson",
                      isPrimary: true,
                    ),
                  );
                } else {
                  contacts.add(
                    EmergencyContact(
                      id: DateTime.now()
                          .millisecondsSinceEpoch
                          .toString(),
                      name: name,
                      phoneNumber: phone,
                      relationship: "Kontaktperson",
                    ),
                  );
                }
              });

              _saveContacts();
              Navigator.pop(context);
            },
            child: const Text("Hinzufügen"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('EEEE, dd. MMMM yyyy', 'de_DE')
                    .format(DateTime.now()),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),

              EmergencyChecklistCard(
                steps: emergencySteps,
                onStepTap: (index) {
                  setState(() {
                    emergencySteps[index].completed =
                    !emergencySteps[index].completed;
                  });
                },
              ),
              const SizedBox(height: 24),

              EmergencyContactList(
                contacts: contacts,
                onCall: (c) => PhoneService.call(c.phoneNumber),
                onAdd: _showAddContactDialog,
                onDelete: (c) {
                  setState(() {
                    contacts.removeWhere((e) => e.id == c.id);
                  });
                  _saveContacts();
                },
              ),

              const SizedBox(height: 24),

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
      bottomNavigationBar: FloatingSOSButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
              Text('Demo: SOS-Funktion – in echter App Notrufauslösung.'),
            ),
          );
        },
      ),
    );
  }
}