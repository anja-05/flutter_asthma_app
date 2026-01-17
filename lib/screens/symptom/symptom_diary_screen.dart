import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_colors.dart';
import 'symptom_entry_tab.dart';
import 'symptom_history_tab.dart';
import '../../services/auth_service.dart';
import '../../services/fhir_observation_service.dart';

/// Bildschirm für das Symptomtagebuch.
///
/// Zeigt zwei Registerkarten an: Eine zum Eingeben neuer Symptome und eine zum
/// Anzeigen der bisherigen Einträge. Einträge werden lokal gespeichert und
/// über den [FhirObservationService] an einen FHIR‐Server übertragen.
class SymptomDiaryScreen extends StatefulWidget {
  /// Erstellt einen neuen [SymptomDiaryScreen].
  const SymptomDiaryScreen({super.key});

  @override
  State<SymptomDiaryScreen> createState() => _SymptomDiaryScreenState();
}

class _SymptomDiaryScreenState extends State<SymptomDiaryScreen> {
  /// Liste der bisherigen Einträge im Tagebuch.
  ///
  /// Jeder Eintrag ist eine `Map` mit Schlüsseln wie `date`, `time`, `symptoms`
  /// und optional `notes`. Die Liste wird beim Laden der Seite aus dem
  /// persistenten Speicher befüllt.
  final List<Map<String, dynamic>> _history = [];

  /// Service zum Speichern von Symptomen als FHIR‐Observation.
  final _observationService = FhirObservationService();

  /// Service zur Authentifizierung und zum Abrufen des aktuellen Benutzers.
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  /// Fügt einen neuen Tagebuch-Eintrag hinzu und speichert ihn.
  ///
  /// Der Eintrag wird an den Anfang von [_history] eingefügt, in den
  /// persistenten Speicher geschrieben und anschließend über den
  /// [_observationService] als einzelne Observations für jeden Symptom‐Eintrag
  /// an den FHIR‐Server gesendet. Enthält der aktuelle Benutzer keine gültige
  /// `fhirPatientId`, werden keine Observations gesendet.
  ///
  /// Parameter:
  /// * [entry] – Eine Map mit den Schlüsseln `date`, `time`, `symptoms`,
  ///   optional `notes` und weiteren Metadaten. `symptoms` muss eine Map von
  ///   Symptomnamen auf Intensitäten (als `int`) sein.
  void addEntry(Map<String, dynamic> entry) async {
    setState(() => _history.insert(0, entry));
    _persistHistory();

    final currentDate = DateFormat('dd.MM.yyyy').format(DateTime.now());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_entry_date', currentDate);

    String trend = "Weniger Anfälle";
    if (_history.length > 1) {
      final lastEntry = _history[1];
      final lastIntensity =
          lastEntry['symptoms'].values.reduce((a, b) => a + b);
      final currentIntensity = entry['symptoms'].values.reduce((a, b) => a + b);

      if (currentIntensity > lastIntensity) {
        trend = "Mehr Anfälle";
      } else if (currentIntensity == lastIntensity) {
        trend = "Stabil";
      }
    }

    await prefs.setString('trend', trend);

    final user = await _authService.getCurrentUser();
    if (user == null || user.fhirPatientId == null) return;

    final dateTime = DateFormat('dd.MM.yyyy HH:mm')
        .parse('${entry['date']} ${entry['time']}');

    final symptoms = Map<String, int>.from(entry['symptoms']);

    for (final s in symptoms.entries) {
      await _observationService.saveSymptom(
        patientId: user.fhirPatientId!,
        symptomName: s.key,
        intensity: s.value,
        dateTime: dateTime,
        notes: entry['notes'],
      );
    }
  }

  /// Lädt die gespeicherte Historie aus dem persistenten Speicher.
  ///
  /// Liest die gespeicherte JSON‐Zeichenkette aus `SharedPreferences` und
  /// befüllt damit [_history]. Wenn keine Daten vorhanden sind, bleibt die
  /// Liste unverändert.
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('symptom_history');

    if (jsonString != null) {
      final List decoded = jsonDecode(jsonString);
      setState(() {
        _history
          ..clear()
          ..addAll(decoded.cast<Map<String, dynamic>>());
      });
    }
  }

  /// Persistiert die aktuelle Historie in `SharedPreferences`.
  Future<void> _persistHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('symptom_history', jsonEncode(_history));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Symptomtagebuch',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Geben Sie Ihre Symtopme ein und beobachten Sie Ihre Symptomveränderungen in der Historie',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          DateFormat(
                            'EEEE, d. MMMM yyyy',
                            'de_DE',
                          ).format(DateTime.now()),
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.wb_sunny,
                          size: 18,
                          color: Colors.orangeAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const TabBar(
                labelColor: Colors.black,
                indicatorColor: AppColors.primaryGreen,
                tabs: [
                  Tab(text: 'Eintrag'),
                  Tab(text: 'Verlauf'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    SymptomEntryTab(onSave: addEntry),
                    SymptomHistoryTab(history: _history),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
