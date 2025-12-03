// lib/screens/medication_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../constants/app_colors.dart';
import '../../models/medication.dart';
import '../../widgets/medication/medication_intake_card.dart';
import '../../widgets/medication/past_intake_card.dart';
import '../../services/medication_service.dart';

const Uuid uuid = Uuid();

// --- ZUSÄTZLICHE KLASSE: DIALOG FÜR DIE EINGABE (Unverändert) ---
class _AddMedicationDialog extends StatefulWidget {
  final Function(Medication) onAdd;

  const _AddMedicationDialog({required this.onAdd});

  @override
  State<_AddMedicationDialog> createState() => _AddMedicationDialogState();
}

class _AddMedicationDialogState extends State<_AddMedicationDialog> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _dosage = '';
  String _type = 'Tablette';
  List<String> _times = ['12:00'];
  final List<String> _types = ['Tablette', 'Inhalator', 'Spray', 'Kapsel', 'Tropfen', 'Sonstiges'];

  void _addTimeField() {
    setState(() {
      _times.add('00:00');
    });
  }
  void _removeTimeField(int index) {
    if (_times.length > 1) {
      setState(() {
        _times.removeAt(index);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final cleanTimes = _times.where((t) => RegExp(r'^\d{2}:\d{2}$').hasMatch(t)).toList();

      if (cleanTimes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mindestens eine gültige Einnahmezeit (HH:MM) erforderlich.')),
        );
        return;
      }

      final newMedication = Medication(
        id: uuid.v4(),
        name: _name.trim(),
        dosage: _dosage.trim(),
        type: _type,
        times: cleanTimes,
      );
      widget.onAdd(newMedication);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Neues Medikament planen'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                onSaved: (value) => _name = value ?? '',
                validator: (value) => value!.trim().isEmpty ? 'Name erforderlich' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Dosierung/Menge (z.B. 500 mg, 2 Hübe)'),
                onSaved: (value) => _dosage = value ?? '',
                validator: (value) => value!.trim().isEmpty ? 'Dosierung erforderlich' : null,
              ),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Typ'),
                items: _types.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              const Text('Einnahmezeiten (HH:MM)', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._times.asMap().entries.map((entry) {
                final index = entry.key;
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _times[index],
                        decoration: InputDecoration(
                          hintText: 'HH:MM',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () async {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                  hour: int.tryParse(_times[index].split(':')[0]) ?? 12,
                                  minute: int.tryParse(_times[index].split(':')[1]) ?? 0,
                                ),
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  _times[index] = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                                });
                              }
                            },
                          ),
                        ),
                        onChanged: (value) => _times[index] = value,
                        validator: (value) {
                          if (value == null || !RegExp(r'^\d{2}:\d{2}$').hasMatch(value)) return 'Format HH:MM';
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline, color: _times.length > 1 ? Colors.red : Colors.grey),
                      onPressed: _times.length > 1 ? () => _removeTimeField(index) : null,
                    ),
                  ],
                );
              }).toList(),
              TextButton.icon(
                onPressed: _addTimeField,
                icon: const Icon(Icons.add),
                label: const Text('Weitere Zeit hinzufügen'),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Abbrechen'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}
// --- ENDE DIALOG KLASSE ---


class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final MedicationService _service = MedicationService();

  List<Medication> _medicationPlans = [];
  List<MedicationIntake> _allTodayIntakesWithStatus = [];
  List<MedicationIntake> _todayIntakes = [];
  List<PastMedicationIntake> _pastIntakes = [];
  bool _remindersEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  // Funktion zur Überprüfung, ob ein Tageswechsel stattgefunden hat
  bool _isNewDay(DateTime? lastAccess) {
    if (lastAccess == null) return true;
    final now = DateTime.now();
    // Prüfen, ob das Jahr, der Monat oder der Tag anders ist
    return now.year != lastAccess.year || now.month != lastAccess.month || now.day != lastAccess.day;
  }

  // Funktion, die die Pläne in tägliche Einnahme-Einträge umwandelt
  List<MedicationIntake> _generateTodayIntakes(List<Medication> plans) {
    final allIntakes = plans.expand((plan) {
      return plan.times.map((time) {
        return MedicationIntake(
          id: uuid.v4(),
          name: plan.name,
          dosage: '1x ${plan.dosage} (${plan.type})',
          time: time,
          type: plan.type,
          taken: false,
        );
      });
    }).toList();

    allIntakes.sort((a, b) => a.time.compareTo(b.time));
    return allIntakes;
  }

  // Ladefunktion (für Persistenz)
  Future<void> _loadMedications() async {
    final loadedPlans = await _service.loadMedications();
    final loadedRemindersStatus = await _service.loadRemindersStatus();
    final lastAccess = await _service.loadLastAccessedDate();
    final loadedPastIntakes = await _service.loadPastIntakes();

    List<MedicationIntake> currentIntakes;

    if (_isNewDay(lastAccess)) {
      // Neuer Tag: Generiere Intakes neu (alle sind *nicht* genommen)
      currentIntakes = _generateTodayIntakes(loadedPlans);
      await _service.saveTodayIntakes(currentIntakes); // Speichere den neuen Tagesplan
    } else {
      // Gleicher Tag: Lade den gespeicherten Zustand der Intakes
      currentIntakes = await _service.loadTodayIntakes();

      // OPTIMIERUNG: Falls sich die Pläne geändert haben (durch Löschen/Hinzufügen),
      // MÜSSEN wir die Liste abgleichen. Da die ID bei jedem Start neu generiert wird,
      // ist der direkte Vergleich schwierig. Wir nutzen hier die vereinfachte Logik.
      final totalExpectedIntakes = loadedPlans.expand((p) => p.times).length;
      if (currentIntakes.length != totalExpectedIntakes) {
        // Vereinfachte Logik zur Vermeidung von Fehlern: Neu generieren.
        // Beim Neuladen wird der Zustand des aktuellen Tages immer neu gesetzt,
        // wenn die Anzahl der Pläne nicht übereinstimmt.
        currentIntakes = _generateTodayIntakes(loadedPlans);
        await _service.saveTodayIntakes(currentIntakes);
      }
    }

    // Speichere das aktuelle Zugriffsdatum für den nächsten Start
    await _service.saveLastAccessedDate();

    setState(() {
      _medicationPlans = loadedPlans;
      _allTodayIntakesWithStatus = currentIntakes;
      // Filter: Nur die, die NICHT genommen wurden, sind heute relevant
      _todayIntakes = currentIntakes.where((i) => !i.taken).toList();
      _pastIntakes = loadedPastIntakes;
      _remindersEnabled = loadedRemindersStatus;
      _isLoading = false;
    });
  }

  // KORRIGIERT: Fügt nur das NEUE Medikament zur bestehenden Intakes-Liste hinzu
  void _addNewPlan(Medication newMedication) async {
    // 1. Füge das neue Medikament zur Plan-Liste hinzu
    final updatedPlans = [..._medicationPlans, newMedication];

    // 2. Erstelle die Intakes nur für das NEUE Medikament (alle sind 'taken: false')
    final newIntakesForToday = _generateTodayIntakes([newMedication]);

    // 3. Kombiniere die neuen Intakes mit den bestehenden Intakes, die den Status halten
    // Wichtig: _allTodayIntakesWithStatus enthält den aktuellen "taken" Status
    final combinedIntakes = [..._allTodayIntakesWithStatus, ...newIntakesForToday];

    // 4. Speichere den aktualisierten Plan und die COMBINED Intakes
    await _service.saveMedications(updatedPlans);
    await _service.saveTodayIntakes(combinedIntakes);

    setState(() {
      _medicationPlans = updatedPlans;
      _allTodayIntakesWithStatus = combinedIntakes;
      // 5. Aktualisiere die gefilterte Liste für die Anzeige
      _todayIntakes = combinedIntakes.where((i) => !i.taken).toList();
    });

    _showSnackBar('Medikament ${newMedication.name} hinzugefügt!');
  }

  // Löscht einen Einnahme-Eintrag und den dazugehörigen Plan
  void _deleteIntakeAndPlan(String intakeId) async {
    final allTodayIntakes = _allTodayIntakesWithStatus;

    final intakeToDelete = allTodayIntakes.firstWhere((intake) => intake.id == intakeId,
        orElse: () => _todayIntakes.firstWhere((i) => i.id == intakeId));

    final medicationName = intakeToDelete.name;

    // 2. Entferne den zugehörigen Plan
    final updatedPlans = _medicationPlans.where((p) => p.name != medicationName).toList();
    await _service.saveMedications(updatedPlans);

    // 3. Entferne alle heutigen Intake-Einträge des Plans
    final updatedIntakes = allTodayIntakes.where((i) => i.name != medicationName).toList();
    await _service.saveTodayIntakes(updatedIntakes);

    setState(() {
      _medicationPlans = updatedPlans;
      _allTodayIntakesWithStatus = updatedIntakes;
      // Zeige nur die nicht genommenen an
      _todayIntakes = updatedIntakes.where((i) => !i.taken).toList();
    });

    _showSnackBar('Medikament "${medicationName}" gelöscht.');
  }

  // Schaltet den Erinnerungs-Status um
  void _toggleReminders(bool value) async {
    setState(() {
      _remindersEnabled = value;
    });
    await _service.saveRemindersStatus(value);
    _showSnackBar('Erinnerungen ${value ? "aktiviert" : "deaktiviert"}.');
  }

  // Funktion zum Markieren als genommen und Verschieben
  void _markAsTaken(MedicationIntake intake) async {
    // 1. PastIntake Eintrag erstellen
    final pastIntake = PastMedicationIntake(
      id: uuid.v4(),
      name: intake.name,
      dosage: intake.dosage,
      type: intake.type,
      dateTime: DateTime.now(),
    );

    // 2. Aktualisiere den Status in der vollen Liste
    final int indexToUpdate = _allTodayIntakesWithStatus.indexWhere((i) => i.id == intake.id);
    if (indexToUpdate != -1) {
      _allTodayIntakesWithStatus[indexToUpdate] = intake.markAsTaken();
    }

    // 3. Speichere den neuen Status der Intakes und der Historie
    await _service.saveTodayIntakes(_allTodayIntakesWithStatus);
    final updatedPastIntakes = [pastIntake, ..._pastIntakes];
    await _service.savePastIntakes(updatedPastIntakes);

    setState(() {
      // 4. Entferne den Eintrag aus der gefilterten Liste im State (er verschwindet)
      _todayIntakes.removeWhere((i) => i.id == intake.id);

      // 5. Aktualisiere die Historie
      _pastIntakes = updatedPastIntakes;
    });

    _showSnackBar('${intake.name} eingenommen und verschoben.');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _addMedication() {
    showDialog(
      context: context,
      builder: (context) => _AddMedicationDialog(onAdd: _addNewPlan),
    );
  }

  // --- BUILD METHODE ---
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadMedications,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            children: [
              // ... (Überschriften und Datum)
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
                DateFormat('EEEE, dd. MMMM yyyy', 'de_DE').format(DateTime.now()),
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

              // Liste heutiger Einnahmen
              if (_todayIntakes.isEmpty)
                const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Text('Keine Medikamente mehr für heute geplant!'),
                )),

              ..._todayIntakes.map((intake) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MedicationIntakeCard(
                    intake: intake,
                    onMarkAsTaken: () => _markAsTaken(intake),
                    onDelete: () => _deleteIntakeAndPlan(intake.id),
                  ),
                );
              }),

              const SizedBox(height: 12),

              // Button hinzufügen
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

              // Erinnerungen CONTAINER
              Container(
                decoration: BoxDecoration(
                  color: AppColors.lightGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      _remindersEnabled ? Icons.notifications_active : Icons.notifications_off,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Erinnerungen sind aktiviert. Du erhältst Benachrichtigungen zur Einnahmezeit.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),

                    Switch(
                      value: _remindersEnabled,
                      onChanged: _toggleReminders,
                      activeColor: AppColors.primaryGreen,
                    )
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

              // Vergangene Einnahmen
              if (_pastIntakes.isEmpty)
                const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Text('Noch keine vergangenen Einnahmen gespeichert.'),
                )),

              ..._pastIntakes.map((intake) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PastIntakeCard(intake: intake),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}