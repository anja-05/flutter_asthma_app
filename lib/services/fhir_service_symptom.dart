import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service responsible for sending medical data to a HAPI FHIR server
class FhirService {
  /// Public HAPI FHIR R5 test server
  static const String _baseUrl = 'https://hapi.fhir.org/baseR5';

  /// IMPORTANT:
  /// In a real system this would come from authentication / patient creation
  /// For your project, a fixed demo patient is totally fine
  static const String _patientId = 'asthma-demo-patient';

  /// Saves ONE symptom as ONE Observation resource
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
