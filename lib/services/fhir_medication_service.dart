// lib/services/fhir_medication_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/medication.dart';

/// Service zur Kommunikation mit dem FHIR-Server bezüglich Medikationsplänen.
///
/// Dieser Service ist verantwortlich für das Speichern von Medikationsplänen
/// als FHIR MedicationRequest-Ressourcen. Er stellt sicher, dass alle Medikamente
/// dem angegebenen Patienten zugeordnet werden.
class FhirMedicationService {
  /// Basis-URL des öffentlichen HAPI FHIR Test-Servers.
  static const String _baseUrl = 'https://hapi.fhir.org/baseR5';

  /// Speichert einen Medikationsplan als MedicationRequest auf dem FHIR-Server.
  ///
  /// Erstellt eine `MedicationRequest`-Ressource und verknüpft sie mit der
  /// angegebenen `patientId`. Die Medikamentendaten (Name, Dosierung, Typ und
  /// Einnahmezeiten) werden in der FHIR-konformen Struktur gespeichert.
  ///
  /// Parameter:
  /// * [medication] - Das Medikament, das gespeichert werden soll.
  /// * [patientId] - Die FHIR Patient-ID, der das Medikament zugeordnet wird.
  ///
  /// Wirft eine [Exception], wenn der Server einen Fehler zurückgibt (Statuscode außerhalb 200-299).
  Future<void> saveMedicationPlan({
    required Medication medication,
    required String patientId,
  }) async {
    final medicationRequest = {
      "resourceType": "MedicationRequest",
      "status": "active",
      "intent": "order",
      "subject": {
        "reference": "Patient/$patientId"
      },
      "medicationCodeableConcept": {
        "text": medication.name
      },
      "dosageInstruction": [
        {
          "text": "${medication.dosage} (${medication.type})",
          "timing": {
            "repeat": {
              "timeOfDay": medication.times
            }
          }
        }
      ]
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/MedicationRequest'),
      headers: {'Content-Type': 'application/fhir+json'},
      body: jsonEncode(medicationRequest),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'FHIR MedicationRequest failed: ${response.statusCode}',
      );
    }
  }
}
