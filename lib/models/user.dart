/// Repräsentiert einen Benutzer der App.
/// Diese Klasse dient als zentrales Benutzermodell und enthält
/// sowohl grundlegende Identitätsdaten als auch medizinische Verknüpfungen (z. B. zu FHIR).
///
/// Verwendung:
/// - Authentifizierung
/// - Personalisierte Anzeige (Name, E-Mail)
/// - Zuordnung zu medizinischen Daten (FHIR Patient)
class AppUser {
  /// Eindeutige Benutzer-ID (User-ID aus Firebase Authentication).
  final String id;
  /// Vorname des Benutzers.
  final String firstName;
  /// Nachname des Benutzers.
  final String lastName;
  /// E-Mail-Adresse des Benutzers.
  /// Wird für Login, Kommunikation und Identifikation verwendet.
  final String email;
  /// FHIR-Patienten-ID.
  /// Dient zur Verknüpfung des App-Benutzers mit einem
  /// Patientenobjekt auf einem FHIR-Server.
  /// Kann `null` sein, wenn keine medizinische Anbindung besteht.
  final String? fhirPatientId;

  /// Erstellt einen neuen [AppUser].
  AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.fhirPatientId,
  });

  /// Anzeigename des Benutzers.
  /// Wird in Begrüßungen oder im Dashboard verwendet.
  /// Identisch mit dem Vornamen.
  String get displayName => firstName;
  /// Vollständiger Name des Benutzers.
  /// Zusammengesetzt aus Vor- und Nachname.
  String get fullName => '$firstName $lastName';

  /// Konvertiert den Benutzer in eine Map-Struktur.
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'fhirPatientId': fhirPatientId,
    };
  }
  /// Erstellt einen [AppUser] aus einer Map-Struktur.
  /// Der [id]-Parameter wird separat übergeben.
  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      firstName: data['firstName'],
      lastName: data['lastName'],
      email: data['email'],
      fhirPatientId: data['fhirPatientId'],
    );
  }
}