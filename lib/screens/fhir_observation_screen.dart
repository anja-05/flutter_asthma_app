import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FhirObservationScreen extends StatelessWidget {
  const FhirObservationScreen({Key? key}) : super(key: key);

  Future<void> createObservation() async {
    final url = Uri.parse('https://hapi.fhir.org/baseR5/Observation');

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
      "code": {
        "coding": [
          {
            "system": "http://loinc.org",
            "code": "75325-1",
            "display": "Asthma symptom diary entry"
          }
        ],
        "text": "Hustenfrequenz"
      },
      "subject": {"reference": "Patient/example"},
      "effectiveDateTime": DateTime.now().toIso8601String(),
      "valueString": "Täglicher Husten dokumentiert"
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/fhir+json"},
      body: jsonEncode(observation),
    );

    if (response.statusCode == 201) {
      print('Observation erfolgreich erstellt!');
    } else {
      print('Fehler beim Erstellen: ${response.statusCode}');
      print('Antwort: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FHIR Test')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            createObservation();
          },
          child: const Text('Neue Observation anlegen'),
        ),
      ),
    );
  }
}
