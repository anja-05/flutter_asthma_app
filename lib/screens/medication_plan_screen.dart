import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../constants/app_colors.dart';
import '../../models/medication.dart';
import '../../widgets/medication/medication_intake_card.dart';
import '../../widgets/medication/past_intake_card.dart';
import '../../services/medication_service.dart';
import '../../services/fhir_medication_service.dart';
import '../../services/fhir_patient_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

const Uuid uuid = Uuid();

/// Dialog-Widget zum Hinzufügen eines neuen Medikaments.
///
/// Eingabe von:
/// - Medikamentenname
/// - Dosierung
/// - Typ (z.B. Tablette)
/// - Einnahmeintervall (Täglich, Alle X Tage, Wochentage)
/// - Einnahmezeiten
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
  String _frequencyType = 'daily';
  int _everyXDays = 1;
  Set<int> _weekdays = {};

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _initializeNotifications();
  }

  /// Initialisiert die lokalen Benachrichtigungen und Android-Kanäle.
  void _initializeNotifications() async {
    // 1. Android-Einstellungen definieren
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    // 2. Plugin initialisieren
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Hier könnte man reagieren, wenn der User auf die Notification klickt
        debugPrint("Benachrichtigung geklickt: ${details.payload}");
      },
    );

    // 3. Den Kanal für Android 8.0+ explizit im System registrieren
    // Ohne diesen Schritt "kennt" Android die App in den Settings oft nicht.
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'medication_channel_id',
      'Medikations-Erinnerungen',
      importance: Importance.max,
    );

    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);

      // 4. DAS löst das System-Pop-up aus (Android 13+)
      final bool? grantedNotification = await androidPlugin.requestNotificationsPermission();
      debugPrint("Benachrichtigungs-Berechtigung: $grantedNotification");

      // 5. Fragt nach exakten Alarmen (hast du schon im Menü gemacht, sicherheitshalber hier auch)
      final bool? grantedExact = await androidPlugin.requestExactAlarmsPermission();
      debugPrint("Exakte Alarm-Berechtigung: $grantedExact");
    }
  }

  /// Plant Benachrichtigungen für neu erstellte Medikamente
  void _scheduleNotifications(Medication med) async {
    final location = tz.getLocation('Europe/Berlin'); // Einheitliche Zeitzone
    final now = tz.TZDateTime.now(location);

    for (int i = 0; i < med.times.length; i++) {
      final timeParts = med.times[i].split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // EINDEUTIGE ID GENERIEREN:
      // Wir nehmen den Hash-Code des Namens und addieren den Index der Uhrzeit.
      // Das stellt sicher, dass verschiedene Medikamente unterschiedliche IDs haben.
      final int notificationId = med.name.hashCode + i;

      var scheduledTime = tz.TZDateTime(
        location,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // Falls die Zeit heute schon vorbei ist -> morgen starten
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      // Logik für die Wiederholung
      DateTimeComponents? matchComponent;
      if (med.frequencyType == 'daily') {
        matchComponent = DateTimeComponents.time; // Täglich zur selben Zeit
      } else if (med.frequencyType == 'weekly') {
        matchComponent = DateTimeComponents.dayOfWeekAndTime; // Wochentag + Zeit
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId, // Jetzt eindeutig!
        'Medikament einnehmen',
        'Es ist Zeit für ${med.name} (${med.dosage})',
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_channel_id',
            'Medikations-Erinnerungen',
            channelDescription: 'Erinnerungen für Medikamenteneinnahme',
            importance: Importance.max,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(''), // Erlaubt längeren Text
          ),
        ),
        matchDateTimeComponents: matchComponent,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint("Benachrichtigung geplant: ${med.name} um $scheduledTime mit ID $notificationId");
    }
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
          const SnackBar(content: Text('Mindestens eine gültige Einnahmezeit erforderlich.')),
        );
        return;
      }

      // 1. Objekt erstellen
      final newMedication = Medication(
        id: uuid.v4(),
        name: _name.trim(),
        dosage: _dosage.trim(),
        type: _type,
        times: cleanTimes,
        frequencyType: _frequencyType,
        everyXDays: _frequencyType == 'everyX' ? _everyXDays : null,
        weekdays: _frequencyType == 'weekly' ? _weekdays.toList() : null,
      );

      // 2. Speichern & UI aktualisieren
      widget.onAdd(newMedication);
      Navigator.of(context).pop();

      // 3. Benachrichtigungen mit dem GANZEN OBJEKT planen
      _scheduleNotifications(newMedication);
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
                validator: (value) =>
                value!.trim().isEmpty
                    ? 'Name erforderlich'
                    : null,
              ),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Dosierung/Menge (z.B. 500 mg, 2 Hübe)'),
                onSaved: (value) => _dosage = value ?? '',
                validator: (value) =>
                value!.trim().isEmpty
                    ? 'Dosierung erforderlich'
                    : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Typ'),
                items: _types.map((type) =>
                    DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Einnahmeintervall',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DropdownButtonFormField<String>(
                initialValue: _frequencyType,
                decoration: const InputDecoration(labelText: 'Intervall'),
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('Täglich')),
                  DropdownMenuItem(value: 'everyX', child: Text('Alle X Tage')),
                  DropdownMenuItem(
                      value: 'weekly', child: Text('Bestimmte Wochentage')),
                ],
                onChanged: (value) {
                  setState(() {
                    _frequencyType = value!;
                  });
                },
              ),
              if (_frequencyType == 'everyX')
                TextFormField(
                  initialValue: '1',
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Alle wie viele Tage?',
                  ),
                  onChanged: (value) {
                    _everyXDays = int.tryParse(value) ?? 1;
                  },
                ),
              if (_frequencyType == 'weekly')
                Wrap(
                  spacing: 6,
                  children: List.generate(7, (index) {
                    final day = index + 1;
                    const labels = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
                    return ChoiceChip(
                      label: Text(labels[index]),
                      selected: _weekdays.contains(day),
                      onSelected: (selected) {
                        setState(() {
                          selected ? _weekdays.add(day) : _weekdays.remove(day);
                        });
                      },
                    );
                  }),
                ),
              const Text('Einnahmezeiten (HH:MM)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ..._times
                  .asMap()
                  .entries
                  .map((entry) {
                final index = entry.key;
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        key: Key('time_field_${index}_${_times[index]}'),
                        initialValue: _times[index],
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'HH:MM',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () async {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                  hour: int.tryParse(
                                      _times[index].split(':')[0]) ?? 12,
                                  minute: int.tryParse(
                                      _times[index].split(':')[1]) ?? 0,
                                ),
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  _times[index] =
                                  '${pickedTime.hour.toString().padLeft(
                                      2, '0')}:${pickedTime.minute.toString()
                                      .padLeft(2, '0')}';
                                });
                              }
                            },
                          ),
                        ),
                        onChanged: (value) => _times[index] = value,
                        validator: (value) {
                          if (value == null ||
                              !RegExp(r'^\d{2}:\d{2}$').hasMatch(value))
                            return 'Format HH:MM';
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline,
                          color: _times.length > 1 ? Colors.red : Colors.grey),
                      onPressed: _times.length > 1
                          ? () => _removeTimeField(index)
                          : null,
                    ),
                  ],
                );
              }).toList(),
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

/// Hauptscreen für Medikationsübersicht
///
/// Zeigt:
/// - Die für heute geplanten Einnahmen (mit Checkboxen zum Abhaken).
/// - Eine Liste vergangener Einnahmen (Historie).
/// - Einen Button zum Hinzufügen neuer Medikamente.
///
/// Verwaltet zudem die Synchronisation mit dem [MedicationService] und FHIR.
class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen>
    with WidgetsBindingObserver {
  final MedicationService _service = MedicationService();
  final FhirMedicationService _fhirMedicationService = FhirMedicationService();
  final FhirPatientService _fhirPatientService = FhirPatientService();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<Medication> _medicationPlans = [];
  List<MedicationIntake> _allTodayIntakesWithStatus = [];
  List<MedicationIntake> _todayIntakes = [];
  List<PastMedicationIntake> _pastIntakes = [];
  bool _remindersEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadMedications();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionStatus();
    }
  }

  Future<void> _checkPermissionStatus() async {
    final status = await Permission.notification.status;
    if (mounted) {
      setState(() {
        _remindersEnabled = status.isGranted;
      });
    }
  }

  /// Prüft, ob seit dem letzten Zugriff ein neuer Tag begonnen hat.
  bool _isNewDay(DateTime? lastAccess) {
    if (lastAccess == null) return true;
    final now = DateTime.now();
    return now.year != lastAccess.year ||
        now.month != lastAccess.month ||
        now.day != lastAccess.day;
  }

  /// Prüft anhand des Intervalls, ob ein Medikament heute eingenommen werden muss.
  bool _shouldTakeToday(Medication med) {
    final today = DateTime.now();

    if (med.frequencyType == 'daily') {
      return true;
    }

    if (med.frequencyType == 'everyX' && med.everyXDays != null) {
      final start = DateTime(today.year, today.month, today.day);
      final diffDays = start.difference(start).inDays;
      return diffDays % med.everyXDays! == 0;
    }

    if (med.frequencyType == 'weekly' && med.weekdays != null) {
      return med.weekdays!.contains(today.weekday);
    }

    return false;
  }

  /// Generiert Liste der heutigen Einnahmen basierend auf den Plänen.
  List<MedicationIntake> _generateTodayIntakes(List<Medication> plans) {
    final allIntakes = plans
        .where(_shouldTakeToday)
        .expand((plan) {
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

  /// Lädt alle Medikamentendaten (Pläne, Einnahmen, Historie).
  ///
  /// Führt bei einem neuen Tag auch die Generierung der neuen Tagesliste durch.
  Future<void> _loadMedications() async {
    final loadedPlans = await _service.loadMedications();
    final loadedRemindersStatus = await _service.loadRemindersStatus();
    final lastAccess = await _service.loadLastAccessedDate();
    final loadedPastIntakes = await _service.loadPastIntakes();

    List<MedicationIntake> currentIntakes;

    if (_isNewDay(lastAccess)) {
      currentIntakes = _generateTodayIntakes(loadedPlans);
      await _service.saveTodayIntakes(currentIntakes);
    } else {
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

    await _service.saveLastAccessedDate();

    setState(() {
      _medicationPlans = loadedPlans;
      _allTodayIntakesWithStatus = currentIntakes;
      _todayIntakes = currentIntakes.where((i) => !i.taken).toList();
      _pastIntakes = loadedPastIntakes;
      _remindersEnabled = loadedRemindersStatus;
      _isLoading = false;
    });
  }

  /// Fügt einen neuen Medikationsplan hinzu und speichert ihn in:
  /// 1. Lokalen App-Daten (SharedPreferences)
  /// 2. FHIR-Server (MedicationRequest)
  void _addNewPlan(Medication newMedication) async {
    final updatedPlans = [..._medicationPlans, newMedication];
    final newIntakesForToday = _generateTodayIntakes([newMedication]);
    final combinedIntakes = [..._allTodayIntakesWithStatus, ...newIntakesForToday];

    // lokal speichern (wie bisher)
    await _service.saveMedications(updatedPlans);
    await _service.saveTodayIntakes(combinedIntakes);

    // FHIR: Patient sicherstellen + MedicationRequest speichern
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final patientId = await _fhirPatientService.ensurePatientForUser(
        uid: user.uid,
        email: user.email ?? '',
        firstName: 'Demo',   // falls du später aus user.dart ersetzen willst
        lastName: 'User',
      );

      await _fhirMedicationService.saveMedicationPlan(
        medication: newMedication,
        patientId: patientId,
      );
    } catch (e) {
      // bewusst nur Logging / Snackbar – App soll nicht abbrechen
      _showSnackBar('FHIR-Speicherung fehlgeschlagen');
    }

    setState(() {
      _medicationPlans = updatedPlans;
      _allTodayIntakesWithStatus = combinedIntakes;
      _todayIntakes = combinedIntakes.where((i) => !i.taken).toList();
    });

    _showSnackBar('Medikament ${newMedication.name} hinzugefügt!');
  }

  void _deleteIntakeAndPlan(String intakeId) async {
    final allTodayIntakes = _allTodayIntakesWithStatus;

    final intakeToDelete = allTodayIntakes.firstWhere((intake) => intake.id == intakeId,
        orElse: () => _todayIntakes.firstWhere((i) => i.id == intakeId));

    final medicationName = intakeToDelete.name;

    final updatedPlans = _medicationPlans.where((p) => p.name != medicationName).toList();
    await _service.saveMedications(updatedPlans);

    final updatedIntakes = allTodayIntakes.where((i) => i.name != medicationName).toList();
    await _service.saveTodayIntakes(updatedIntakes);

    setState(() {
      _medicationPlans = updatedPlans;
      _allTodayIntakesWithStatus = updatedIntakes;
      _todayIntakes = updatedIntakes.where((i) => !i.taken).toList();
    });

    _flutterLocalNotificationsPlugin.cancelAll();

    _showSnackBar('Medikament "${medicationName}" gelöscht.');
  }

  void _markAsTaken(MedicationIntake intake) async {
    final pastIntake = PastMedicationIntake(
      id: uuid.v4(),
      name: intake.name,
      dosage: intake.dosage,
      type: intake.type,
      dateTime: DateTime.now(),
    );

    final int indexToUpdate = _allTodayIntakesWithStatus.indexWhere((i) => i.id == intake.id);
    if (indexToUpdate != -1) {
      _allTodayIntakesWithStatus[indexToUpdate] = intake.markAsTaken();
    }

    await _service.saveTodayIntakes(_allTodayIntakesWithStatus);
    final updatedPastIntakes = [pastIntake, ..._pastIntakes];
    await _service.savePastIntakes(updatedPastIntakes);

    setState(() {
      _todayIntakes.removeWhere((i) => i.id == intake.id);

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryGreen,
          ),
        ),
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
                DateFormat('EEEE, dd. MMMM yyyy', 'de_DE')
                    .format(DateTime.now()),
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
              if (_todayIntakes.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text('Keine Medikamente mehr für heute geplant!'),
                  ),
                ),
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
              Container(
                decoration: BoxDecoration(
                  color: (_remindersEnabled)
                      ? AppColors.lightGreen.withValues(alpha: 0.15)
                      : Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      _remindersEnabled
                          ? Icons.notifications_active
                          : Icons.notifications_off,
                      color: _remindersEnabled
                          ? AppColors.primaryGreen
                          : Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _remindersEnabled
                            ? 'Erinnerungen sind aktiviert.'
                            : 'Erinnerungen sind deaktiviert. Bitte in den Einstellungen prüfen.',
                        style: TextStyle(
                          fontSize: 14,
                          color: _remindersEnabled
                              ? AppColors.textSecondary
                              : Colors.orange,
                          fontWeight: _remindersEnabled
                              ? FontWeight.normal
                              : FontWeight.bold,
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
              if (_pastIntakes.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'Noch keine vergangenen Einnahmen gespeichert.',
                    ),
                  ),
                ),
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