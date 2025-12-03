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

class EmergencyPlanScreen extends StatefulWidget {
  const EmergencyPlanScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyPlanScreen> createState() => _EmergencyPlanScreenState();
}

class _EmergencyPlanScreenState extends State<EmergencyPlanScreen> {
  final List<EmergencyContact> contacts = [];

  // ---------------------------------------------------
  // 🔹 Kontakte beim App-Start laden
  // ---------------------------------------------------
  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  // ---------------------------------------------------
  // 🔹 Kontakte aus SharedPreferences laden
  // ---------------------------------------------------
  void _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('contacts');

    if (jsonString != null) {
      final List decoded = json.decode(jsonString);

      setState(() {
        contacts.clear();
        contacts.addAll(decoded.map((c) => EmergencyContact(
          id: c['id'],
          name: c['name'],
          phoneNumber: c['phoneNumber'],
          relationship: c['relationship'],
          isPrimary: c['isPrimary'],
        )));
      });
    }
  }

  // ---------------------------------------------------
  // 🔹 Kontakte speichern
  // ---------------------------------------------------
  void _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();

    final List mapList = contacts.map((c) => {
      'id': c.id,
      'name': c.name,
      'phoneNumber': c.phoneNumber,
      'relationship': c.relationship,
      'isPrimary': c.isPrimary,
    }).toList();

    prefs.setString('contacts', json.encode(mapList));
  }

  // ---------------------------------------------------
  // 🔹 Dialog zum Kontakt hinzufügen
  // ---------------------------------------------------
  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Neuen Kontakt hinzufügen"),
        content: SizedBox(
          height: 150,
          child: Column(
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

              if (name.isEmpty || phone.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Bitte beide Felder ausfüllen."),
                  ),
                );
                return;
              }

              setState(() {
                contacts.add(
                  EmergencyContact(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    phoneNumber: phone,
                    relationship: "Kontaktperson",
                    isPrimary: contacts.isEmpty,
                  ),
                );
              });

              _saveContacts(); // 🔹 speichern nach hinzufügen
              Navigator.pop(context);
            },
            child: const Text("Hinzufügen"),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // 🔹 Oberfläche
  // ---------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final List<EmergencyStep> emergencySteps = [
      EmergencyStep(text: 'Ruhe bewahren und aufrecht hinsetzen'),
      EmergencyStep(text: 'Schnellwirkendes Medikament (z. B. Inhalator) anwenden'),
      EmergencyStep(text: 'Peak-Flow messen'),
      EmergencyStep(text: 'Wenn keine Besserung: Notruf oder Kontaktperson verständigen'),
    ];

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
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Text(
                    DateFormat('EEEE, dd. MMMM yyyy', 'de_DE')
                        .format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.wb_sunny, color: Colors.orangeAccent, size: 18),
                ],
              ),

              const SizedBox(height: 24),

              EmergencyChecklistCard(steps: emergencySteps),

              const SizedBox(height: 24),

              // 🔹 Kontaktliste MIT löschen
              EmergencyContactList(
                contacts: contacts,
                onCall: (contact) {
                  PhoneService.call(contact.phoneNumber);
                },
                onAdd: _showAddContactDialog,
                onDelete: (contact) {
                  setState(() {
                    contacts.removeWhere((c) => c.id == contact.id);
                  });
                  _saveContacts(); // 🔹 speichern nach löschen
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
            const SnackBar(content: Text('SOS gedrückt – Hilfe wird geholt...')),
          );
        },
        isActive: false,
      ),
    );
  }
}
