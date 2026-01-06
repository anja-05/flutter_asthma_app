import 'dart:convert';
import 'package:http/http.dart' as http;

/// FhirObservationService ist ein Service, der es ermöglicht, Symptome eines Patienten
/// als FHIR (Fast Healthcare Interoperability Resources) Observation zu speichern.
/// Der Service kommuniziert mit einer FHIR-Server-API (HAPI FHIR).
///
/// [FhirObservationService] bietet eine Methode, um ein Symptom für einen Patienten
/// in der FHIR-Datenbank zu speichern.
class FhirObservationService {
  static const String _baseUrl = 'https://hapi.fhir.org/baseR5';

  /// Speichert ein Symptom für einen Patienten in der FHIR-Datenbank.
  ///
  /// [patientId] ist die eindeutige ID des Patienten.
  /// [symptomName] ist der Name des Symptoms, das aufgezeichnet wird.
  /// [intensity] ist die Intensität des Symptoms (z. B. von 0 bis 10).
  /// [dateTime] ist der Zeitpunkt, an dem das Symptom erfasst wurde.
  /// [notes] sind optionale zusätzliche Anmerkungen zum Symptom.
  ///
  /// Diese Methode sendet eine POST-Anfrage an den FHIR-Server, um eine "Observation"-Ressource
  /// zu speichern. Die Antwort wird überprüft, und es wird eine Ausnahme ausgelöst,
  /// wenn die Anfrage fehlschlägt.
  Future<void> saveSymptom({
    required String patientId,
    required String symptomName,
    required int intensity,
    required DateTime dateTime,
    String? notes,
  }) async {
    final observation = {
      "resourceType": "Observation",
      "status": "final",
      "category": [
        {
          "coding": [
            {
              "system": "http://terminology.hl7.org/CodeSystem/observation-category",
              "code": "survey"
            }
          ]
        }
      ],
      "code": {"text": symptomName},
      "subject": {"reference": "Patient/$patientId"},
      "effectiveDateTime": dateTime.toIso8601String(),
      "valueQuantity": {
        "value": intensity,
        "unit": "severity"
      },
      if (notes != null && notes.isNotEmpty) "note": [
        {"text": notes}
      ]
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/Observation'),
      headers: {'Content-Type': 'application/fhir+json'},
      body: jsonEncode(observation),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('FHIR Observation failed');
    }
  }
}
