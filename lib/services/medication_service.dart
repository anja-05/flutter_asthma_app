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

  Future<void> saveMedicationTimes(List<String> times) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyMedicationTimes, times);
  }

  Future<List<String>> loadMedicationTimes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyMedicationTimes) ?? [];
  }

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

  Future<void> saveMedications(List<Medication> medications) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = medications.map((med) => med.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_keyMedications, jsonString);
  }

  Future<bool> loadRemindersStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRemindersEnabled) ?? true;
  }

  Future<void> saveRemindersStatus(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRemindersEnabled, isEnabled);
  }

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

  Future<void> saveTodayIntakes(List<MedicationIntake> intakes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = intakes.map((i) => i.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_keyTodayIntakes, jsonString);
  }

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

  Future<void> savePastIntakes(List<PastMedicationIntake> intakes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = intakes.map((i) => i.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_keyPastIntakes, jsonString);
  }

  Future<DateTime?> loadLastAccessedDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_keyLastAccessedDate);
    if (dateString == null) return null;
    return DateTime.parse(dateString);
  }

  Future<void> saveLastAccessedDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyLastAccessedDate,
      DateTime.now().toIso8601String(),
    );
  }
}
