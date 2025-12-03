// lib/services/medication_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medication.dart';

class MedicationService {
  static const _keyMedications = 'medicationList';
  static const _keyRemindersEnabled = 'remindersEnabled';
  static const _keyTodayIntakes = 'todayIntakeList';
  static const _keyPastIntakes = 'pastIntakeList';
  static const _keyLastAccessedDate = 'lastAccessedDate';

  // --- Medication Plans ---
  Future<List<Medication>> loadMedications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyMedications);

    if (jsonString == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Medication.fromJson(json)).toList();
  }

  Future<void> saveMedications(List<Medication> medications) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = medications.map((med) => med.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_keyMedications, jsonString);
  }

  // --- Reminders Status ---
  Future<bool> loadRemindersStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRemindersEnabled) ?? true;
  }

  Future<void> saveRemindersStatus(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRemindersEnabled, isEnabled);
  }

  // --- Einnahme Status heute (MedicationIntake) ---
  Future<List<MedicationIntake>> loadTodayIntakes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyTodayIntakes);

    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => MedicationIntake.fromJson(json)).toList();
  }

  Future<void> saveTodayIntakes(List<MedicationIntake> intakes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = intakes.map((i) => i.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_keyTodayIntakes, jsonString);
  }

  // --- Vergangene Einnahmen (PastMedicationIntake) ---
  Future<List<PastMedicationIntake>> loadPastIntakes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyPastIntakes);

    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => PastMedicationIntake.fromJson(json)).toList();
  }

  Future<void> savePastIntakes(List<PastMedicationIntake> intakes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = intakes.map((i) => i.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_keyPastIntakes, jsonString);
  }

  // --- Datum für Tageswechsel ---
  Future<DateTime?> loadLastAccessedDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_keyLastAccessedDate);
    if (dateString == null) return null;
    return DateTime.parse(dateString);
  }

  Future<void> saveLastAccessedDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastAccessedDate, DateTime.now().toIso8601String());
  }
}