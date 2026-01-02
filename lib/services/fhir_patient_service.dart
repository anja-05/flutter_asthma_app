import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class FhirPatientService {
  static const String _baseUrl = 'https://hapi.fhir.org/baseR5';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Ensure that a FHIR Patient exists for this user
  /// If not: create one and store patientId in Firestore
  Future<String> ensurePatientForUser({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    final userDoc = _firestore.collection('users').doc(uid);
    final snapshot = await userDoc.get();

    // ✅ Patient already linked
    if (snapshot.data()?['fhirPatientId'] != null) {
      return snapshot['fhirPatientId'];
    }

    // 🆕 Create FHIR Patient
    final patient = {
      "resourceType": "Patient",
      "identifier": [
        {
          "system": "urn:firebase:uid",
          "value": uid
        }
      ],
      "name": [
        {
          "family": lastName,
          "given": [firstName]
        }
      ],
      "telecom": [
        {
          "system": "email",
          "value": email
        }
      ]
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/Patient'),
      headers: {'Content-Type': 'application/fhir+json'},
      body: jsonEncode(patient),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('FHIR Patient creation failed');
    }

    final body = jsonDecode(response.body);
    final patientId = body['id'];

    // 🔗 Store mapping
    await userDoc.update({'fhirPatientId': patientId});

    return patientId;
  }
}
