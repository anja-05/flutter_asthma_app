import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/user.dart';

/// Service zur Kommunikation mit dem FHIR-Server bezüglich Vitaldaten.
///
/// Dieser Service ist verantwortlich für das Speichern und Abrufen von Vitalwerten
/// (Herzfrequenz, Sauerstoffsättigung, Atemfrequenz) als FHIR Observation-Ressourcen.
/// Er stellt sicher, dass alle Daten dem aktuell eingeloggten Benutzer zugeordnet werden.
class FhirVitalService {
  /// Basis-URL des öffentlichen HAPI FHIR Test-Servers.
  static const String _baseUrl = 'https://hapi.fhir.org/baseR5';

  /// LOINC-Code für Herzfrequenz (Heart rate).
  static const String codeHeartRate = '8867-4';

  /// LOINC-Code für Sauerstoffsättigung im Blut (Oxygen saturation).
  static const String codeOxygen = '2708-6';

  /// LOINC-Code für Atemfrequenz (Respiratory rate).
  static const String codeRespiratoryRate = '9279-1';

  final AuthService _authService = AuthService();

  /// Speichert einen einzelnen Vitalwert auf dem FHIR-Server.
  ///
  /// Erstellt eine `Observation`-Ressource und verknüpft sie mit der `fhirPatientId`
  /// des aktuell eingeloggten Benutzers.
  ///
  /// Parameter:
  /// * [code] - Der LOINC-Code des Vitalwerts (z.B. [codeHeartRate]).
  /// * [display] - Der lesbare Name des Wertes (z.B. "Heart rate").
  /// * [value] - Der numerische Messwert (z.B. 72.0).
  /// * [unit] - Die Einheit des Messwertes (z.B. "beats/min" oder "%").
  ///
  /// Wirft eine [Exception], wenn kein Benutzer eingeloggt ist oder der Server einen Fehler zurückgibt.
  Future<void> saveVital({
    required String code,      // Use the constants above
    required String display,   // e.g., "Heart rate"
    required double value,     // e.g., 72.0
    required String unit,      // e.g., "beats/min"
  }) async {
    // Den eingeloggten Benutzer abrufen
    final AppUser? user = await _authService.getCurrentUser();

    if (user == null || user.fhirPatientId == null) {
      throw Exception("Kein Benutzer eingeloggt oder keine FHIR Patient ID gefunden.");
    }

    // Die FHIR Observation Ressource zusammenbauen
    final observation = {
      "resourceType": "Observation",
      "status": "final",
      "category": [
        {
          "coding": [
            {
              "system": "http://terminology.hl7.org/CodeSystem/observation-category",
              "code": "vital-signs",
              "display": "Vital Signs"
            }
          ]
        }
      ],
      "code": {
        "coding": [
          {
            "system": "http://loinc.org",
            "code": code,
            "display": display
          }
        ]
      },
      "subject": {
        "reference": "Patient/${user.fhirPatientId}"
      },
      "effectiveDateTime": DateTime.now().toIso8601String(),
      "valueQuantity": {
        "value": value,
        "unit": unit,
        "system": "http://unitsofmeasure.org",
        "code": unit
      }
    };

    // An den Server senden (POST Request)
    final response = await http.post(
      Uri.parse('$_baseUrl/Observation'),
      headers: {'Content-Type': 'application/fhir+json'},
      body: jsonEncode(observation),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to save vital: ${response.statusCode}');
    }
  }

  /// Ruft den allerneuesten Vitalwert für einen bestimmten Code ab.
  ///
  /// Diese Methode wird verwendet, um die "Aktuellen Werte" im Dashboard anzuzeigen.
  ///
  /// Parameter:
  /// * [code] - Der LOINC-Code des gewünschten Vitalwerts.
  ///
  /// Rückgabe:
  /// * Ein [String] mit dem gerundeten Wert (z.B. "72").
  /// * Gibt "--" zurück, wenn keine Daten gefunden wurden oder ein Fehler auftrat.
  Future<String> getLatestVital(String code) async {
    try {
      final AppUser? user = await _authService.getCurrentUser();

      if (user == null || user.fhirPatientId == null) {
        return "--"; // No user logged in
      }

      // Query: Gib mir Observations für DIESEN Patienten, mit DIESEM Code, sortiert nach Datum (neueste zuerst)
      final url = Uri.parse(
          '$_baseUrl/Observation?patient=${user.fhirPatientId}&code=$code&_sort=-date&_count=1'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Prüfen, ob Einträge vorhanden sind
        if (data['entry'] != null && data['entry'].isNotEmpty) {
          final value = data['entry'][0]['resource']['valueQuantity']['value'];
          return value.toStringAsFixed(0);
        }
      }

    } catch (e) {
      print("Fehler beim Abrufen des Vitalwerts: $e");
    }
    return "--";
  }

  /// Ruft den Verlauf eines Vitalwerts für das Diagramm ab.
  ///
  /// Holt die letzten 10 Einträge für den angegebenen Vital-Code.
  ///
  /// Parameter:
  /// * [code] - Der LOINC-Code des Vitalwerts.
  ///
  /// Rückgabe:
  /// * Eine Liste von Maps mit `value` (double) und `time` (DateTime).
  /// * Gibt eine leere Liste `[]` zurück, wenn keine Daten vorhanden sind.
  Future<List<Map<String, dynamic>>> getVitalHistory(String code) async {
    try {
      final AppUser? user = await _authService.getCurrentUser();
      if (user == null || user.fhirPatientId == null) return [];

      // Query: Die letzten 10 Einträge abrufen
      final url = Uri.parse(
          '$_baseUrl/Observation?patient=${user.fhirPatientId}&code=$code&_sort=-date&_count=10'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['entry'] != null) {
          // Mapping der FHIR-Antwort auf eine einfache Liste für das Chart
          return List<Map<String, dynamic>>.from(
              data['entry'].map((e) {
                final resource = e['resource'];
                final double val = resource['valueQuantity']['value'].toDouble();
                // Parse timestamp (e.g., "2025-10-21T18:00:00...")
                final DateTime date = DateTime.parse(resource['effectiveDateTime']);

                return {
                  'value': val,
                  'time': date,
                };
              })
          );
        }
      }
    } catch (e) {
      print("Fehler beim Abrufen der Historie: $e");
    }
    return [];
  }
}