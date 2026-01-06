import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

/// FhirPatientService ist ein Service, der dafür sorgt, dass ein FHIR-Patient für den angegebenen Benutzer existiert.
/// Falls noch kein FHIR-Patient existiert, wird dieser erstellt und die Patient-ID in Firestore gespeichert.
///
/// Der Service kommuniziert mit einem FHIR-Server (HAPI FHIR) und der Firebase Firestore-Datenbank.
///
/// Mit dieser Klasse können Benutzerinformationen wie der Name und die E-Mail-Adresse eines Benutzers in einem FHIR-Patienten-Datensatz gespeichert werden.
/// Falls der Benutzer bereits mit einem FHIR-Patienten verknüpft ist, wird die bereits vorhandene Patient-ID verwendet.
class FhirPatientService {
  static const String _baseUrl = 'https://hapi.fhir.org/baseR5';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stellt sicher, dass ein FHIR-Patient für den Benutzer existiert.
  /// Falls noch keiner existiert, wird ein neuer FHIR-Patient erstellt und die Patient-ID in Firestore gespeichert.
  ///
  /// [uid] ist die Benutzer-ID, die in Firebase gespeichert ist.
  /// [email] ist die E-Mail-Adresse des Benutzers, die im Patienten-Datensatz gespeichert wird.
  /// [firstName] ist der Vorname des Benutzers.
  /// [lastName] ist der Nachname des Benutzers.
  ///
  /// Diese Methode gibt die FHIR-Patienten-ID zurück, entweder eine bestehende oder die neu erstellte.
  ///
  /// **Fehlerbehandlung**:
  /// Falls die Erstellung des FHIR-Patienten fehlschlägt, wird eine Ausnahme ausgelöst.
  ///
  /// **Datenfluss**:
  /// Zuerst wird geprüft, ob der Benutzer bereits mit einem FHIR-Patienten verknüpft ist. Falls ja, wird die bestehende ID zurückgegeben.
  /// Falls kein FHIR-Patient existiert, wird ein neuer Patient mit den übergebenen Informationen erstellt.
  /// Die Patient-ID wird nach der erfolgreichen Erstellung in Firestore gespeichert.
  ///
  /// **Rückgabewert**:
  /// Gibt die Patient-ID des FHIR-Patienten zurück.
  Future<String> ensurePatientForUser({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    final userDoc = _firestore.collection('users').doc(uid);
    final snapshot = await userDoc.get();

    if (snapshot.data()?['fhirPatientId'] != null) {
      return snapshot['fhirPatientId'];
    }

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

    await userDoc.update({'fhirPatientId': patientId});

    return patientId;
  }
}
