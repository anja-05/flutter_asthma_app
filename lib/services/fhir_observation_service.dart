import 'dart:convert';
import 'package:http/http.dart' as http;

class FhirObservationService {
  static const String _baseUrl = 'https://hapi.fhir.org/baseR5';

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
              "system":
              "http://terminology.hl7.org/CodeSystem/observation-category",
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
      if (notes != null && notes.isNotEmpty)
        "note": [
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
