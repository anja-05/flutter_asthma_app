import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service zur Übermittlung von medizinischen Daten an einen HAPI-FHIR-Server.
class FhirService {
  /// Öffentlicher HAPI FHIR R5 Testserver.
  static const String _baseUrl = 'https://hapi.fhir.org/baseR5';

  /// WICHTIG:
  /// In echten System würde diese ID aus der Authentifizierung / Patientenerstellung stammen.
  /// Für dieses Projekt ist ein fester Demo-Patient völlig ausreichend.
  static const String _patientId = 'asthma-demo-patient';

  /// Speichert EIN Symptom als EINE Observation-Ressource.
  ///
  /// Erstellt eine `Observation`-Ressource vom Typ `survey` und sendet sie an den FHIR-Server.
  ///
  /// Parameter:
  /// - [symptomName]: Der Name des Symptoms (z.B. "Husten").
  /// - [intensity]: Die Intensität des Symptoms (Wert).
  /// - [dateTime]: Der Zeitpunkt der Aufzeichnung.
  /// - [notes]: Optionale Notizen.
  Future<void> saveSymptomObservation({
    required String symptomName,
    required int intensity,
    required DateTime dateTime,
    String? notes,
  }) async {
    final observation = {
      'resourceType': 'Observation',
      'status': 'final',
      'category': [
        {
          'coding': [
            {
              'system':
                  'http://terminology.hl7.org/CodeSystem/observation-category',
              'code': 'survey',
            }
          ]
        }
      ],
      'code': {
        'text': symptomName,
      },
      'subject': {
        'reference': 'Patient/$_patientId',
      },
      'effectiveDateTime': dateTime.toIso8601String(),
      'valueQuantity': {
        'value': intensity,
        'unit': 'severity',
        'system': 'http://unitsofmeasure.org',
      },
      if (notes != null && notes.isNotEmpty)
        'note': [
          {'text': notes}
        ],
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/Observation'),
      headers: {'Content-Type': 'application/fhir+json'},
      body: jsonEncode(observation),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'FHIR Observation failed: ${response.statusCode}',
      );
    }
  }
}
