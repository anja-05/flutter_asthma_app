import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/medication.dart';

/// Service zur Kommunikation mit dem HAPI-FHIR-Server für Medikationspläne.
/// Diese Klasse kapselt die gesamte FHIR-spezifische Logik zur Speicherung von Medikamentenplänen.
/// Medikationen werden als FHIR `MedicationRequest` Ressourcen modelliert und eindeutig einem Patienten zugeordnet.
class FhirMedicationService {
  /// Basis-URL des öffentlichen HAPI FHIR Testservers (FHIR R5).
  static const String _baseUrl = 'https://hapi.fhir.org/baseR5';

  /// Speichert einen Medikationsplan als FHIR `MedicationRequest`.
  /// Für jedes Medikament wird:
  /// - eine `MedicationRequest` mit Status `active` und Intent `order` erstellt
  /// - der Patient über `subject.reference` eindeutig referenziert
  /// - der Medikamentenname in einer *contained* `Medication`-Ressource gespeichert
  /// - die Dosierung und Einnahmezeiten über `dosageInstruction` abgebildet
  ///
  /// Parameter:
  /// - [medication]: Das in der App erfasste Medikament (Name, Dosierung, Typ, Zeiten)
  /// - [patientId]: Die FHIR-Patienten-ID, der der Medikationsplan zugeordnet wird
  ///
  /// Wirft eine [Exception], wenn der FHIR-Server einen Fehlerstatus zurückliefert.
  Future<void> saveMedicationPlan({
    required Medication medication,
    required String patientId,
  }) async {
    /// Aufbau der FHIR MedicationRequest Ressource
    final medicationRequest = {
      "resourceType": "MedicationRequest",
      "status": "active",
      "intent": "order",

      /// Eindeutige Zuordnung zum Patienten
      "subject": {
        "reference": "Patient/$patientId"
      },

      /// Contained Medication zur sicheren Speicherung des Medikamentennamens
      "contained": [
        {
          "resourceType": "Medication",
          "id": "med1",
          "code": {
            "text": medication.name
          }
        }
      ],

      /// Referenz auf die enthaltene Medication
      "medicationReference": {
        "reference": "#med1"
      },

      /// Dosierungs- und Einnahmeinformationen
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

    /// POST-Request an den HAPI-FHIR-Server
    final response = await http.post(
      Uri.parse('$_baseUrl/MedicationRequest'),
      headers: {'Content-Type': 'application/fhir+json'},
      body: jsonEncode(medicationRequest),
    );

    /// Fehlerbehandlung bei fehlgeschlagenem Request
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('FHIR MedicationRequest failed');
    }
  }
}
