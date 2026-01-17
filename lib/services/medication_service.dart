import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medication.dart';
import 'package:logger/logger.dart';

class MedicationService {
  final Logger _logger = Logger();
  static const _keyMedications = 'medicationList';
  static const _keyRemindersEnabled = 'remindersEnabled';
  static const _keyTodayIntakes = 'todayIntakeList';
  static const _keyPastIntakes = 'pastIntakeList';
  static const _keyLastAccessedDate = 'lastAccessedDate';
  static const _keyMedicationTimes = 'medicationTimes';

  /// Speichert Liste der geplanten Einnahmezeiten
  ///
  /// Wird verwendet, um Benachrichtigungen effizienter zu planen oder
  /// um schnell auf alle relevanten Zeitpunkte zugreifen zu können.
  Future<void> saveMedicationTimes(List<String> times) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyMedicationTimes, times);
  }

  /// Lädt Liste der gespeicherten Einnahmezeiten
  Future<List<String>> loadMedicationTimes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyMedicationTimes) ?? [];
  }

  /// Lädt alle gespeicherten Medikamente aus lokalen Speicher (`SharedPreferences`).
  ///
  /// Gibt eine Liste von [Medication]-Objekten zurück.
  /// Bei Fehlern (z.B. defektes JSON) wird eine leere Liste zurückgegeben und der Fehler geloggt.
  Future<List<Medication>> loadMedications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyMedications);

    if (jsonString == null) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Medication.fromJson(json)).toList();
    } catch (e) {
      _logger.e('Error parsing medications JSON', error: e);
      return [];
    }
  }

  /// Speichert die Liste der Medikamente lokal in den `SharedPreferences`.
  Future<void> saveMedications(List<Medication> medications) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = medications.map((med) => med.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_keyMedications, jsonString);
  }

  /// Prüft, ob Erinnerungen (Benachrichtigungen) aktiviert sind.
  /// Standardmäßig `true`.
  Future<bool> loadRemindersStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRemindersEnabled) ?? true;
  }

  /// Speichert den Status der Erinnerungen (An/Aus).
  Future<void> saveRemindersStatus(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRemindersEnabled, isEnabled);
  }

  /// Lädt die heutigen Einnahme-Einträge
  ///
  /// Diese Liste verfolgt, welche Medikamente heute bereits eingenommen wurden ([MedicationIntake.taken] = true).
  Future<List<MedicationIntake>> loadTodayIntakes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyTodayIntakes);

    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => MedicationIntake.fromJson(json)).toList();
    } catch (e) {
      _logger.e('Error parsing today intakes JSON', error: e);
      return [];
    }
  }

  /// Speichert die Liste der heutigen Einnahmen.
  Future<void> saveTodayIntakes(List<MedicationIntake> intakes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = intakes.map((i) => i.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_keyTodayIntakes, jsonString);
  }

  /// Lädt die Historie vergangener Einnahmen.
  Future<List<PastMedicationIntake>> loadPastIntakes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyPastIntakes);

    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => PastMedicationIntake.fromJson(json))
          .toList();
    } catch (e) {
      _logger.e('Error parsing past intakes JSON', error: e);
      return [];
    }
  }

  /// Speichert die Historie vergangener Einnahmen.
  Future<void> savePastIntakes(List<PastMedicationIntake> intakes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = intakes.map((i) => i.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_keyPastIntakes, jsonString);
  }

  /// Lädt das Datum des letzten angezeigten Tages-Plans.
  ///
  /// Wird verwendet, um festzustellen, ob ein neuer Tag begonnen hat und
  /// die Tagesliste zurückgesetzt werden muss.
  Future<DateTime?> loadLastAccessedDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_keyLastAccessedDate);
    if (dateString == null) return null;
    return DateTime.parse(dateString);
  }

  /// Aktualisiert das "Zuletzt zugegriffen"-Datum auf "Jetzt".
  Future<void> saveLastAccessedDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyLastAccessedDate,
      DateTime.now().toIso8601String(),
    );
  }
}
