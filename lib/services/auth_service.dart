import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import 'package:asthma_app/services/fhir_patient_service.dart';
import 'package:logger/logger.dart';

/// AuthService ist ein Service, der die Benutzer-Authentifizierung und das Management des Benutzerprofils über Firebase Auth und Firestore übernimmt.
/// Dieser Service verwaltet alle relevanten Authentifizierungsoperationen wie Registrierung, Login, Logout und die Verwaltung des aktuellen Benutzers.
///
/// Der Service verwendet Firebase Auth für die Authentifizierung und Firestore zur Speicherung der Benutzerprofile.
/// Außerdem stellt der Service sicher, dass jeder Benutzer mit einem FHIR-Patienten-Datensatz verknüpft ist (mithilfe des [FhirPatientService]).
class AuthService {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  /// Firebase Auth-State-Stream (für AuthWrapper):
  /// Dieser Stream gibt den Authentifizierungsstatus des Benutzers zurück (z. B. ob der Benutzer eingeloggt ist).
  /// Der Stream sendet Ereignisse, wenn sich der Authentifizierungsstatus des Benutzers ändert.
  Stream<fb_auth.User?> get authStateChanges => _auth.authStateChanges();

  /// Registriert einen neuen Benutzer in Firebase Auth und speichert das Benutzerprofil in Firestore.
  /// Nach der Registrierung wird der Benutzer automatisch ausgeloggt.
  ///
  /// [firstName] ist der Vorname des Benutzers.
  /// [lastName] ist der Nachname des Benutzers.
  /// [email] ist die E-Mail-Adresse des Benutzers.
  /// [password] ist das Passwort des Benutzers.
  ///
  /// Gibt `true` zurück, wenn die Registrierung erfolgreich war, andernfalls `false`.
  ///
  /// **Fehlerbehandlung**: Falls ein Fehler bei der Firebase Auth-Registrierung oder der Speicherung in Firestore auftritt,
  /// wird `false` zurückgegeben.
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _auth.signOut();

      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      _logger.w("Firebase Auth Error during registration", error: e);
      return false;
    } catch (e) {
      _logger.e("General Error during registration", error: e);
      return false;
    }
  }


  /// Meldet einen Benutzer mit den angegebenen Anmeldedaten (E-Mail und Passwort) an.
  /// Wenn der Login erfolgreich ist, wird das Benutzerprofil aus Firestore geladen.
  /// Zusätzlich wird überprüft, ob der Benutzer bereits mit einem FHIR-Patienten verknüpft ist.
  ///
  /// [email] ist die E-Mail-Adresse des Benutzers.
  /// [password] ist das Passwort des Benutzers.
  ///
  /// Gibt ein [AppUser]-Objekt zurück, das den Benutzer darstellt, wenn der Login erfolgreich war,
  /// andernfalls `null`, falls der Login fehlschlägt.
  Future<AppUser?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      final docRef = _firestore.collection('users').doc(uid);
      final doc = await docRef.get();

      if (!doc.exists) return null;

      AppUser user = AppUser.fromMap(uid, doc.data()!);


      final fhirService = FhirPatientService();
      final patientId = await fhirService.ensurePatientForUser(
        uid: uid,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
      );


      if (user.fhirPatientId == null) {
        await docRef.update({
          'fhirPatientId': patientId,
        });
      }


      final updatedDoc = await docRef.get();
      return AppUser.fromMap(uid, updatedDoc.data()!);
    } on fb_auth.FirebaseAuthException catch (e) {
      _logger.w("Firebase Auth Error during login", error: e);
      return null;
    } catch (e) {
      _logger.e("General Error during login", error: e);
      return null;
    }
  }


  /// Meldet den aktuellen Benutzer ab, indem die `signOut()`-Methode von Firebase Auth aufgerufen wird.
  Future<void> logout() async {
    await _auth.signOut();
  }


  /// Gibt den aktuell angemeldeten Benutzer als [AppUser] zurück.
  /// Falls kein Benutzer eingeloggt ist, wird `null` zurückgegeben.
  ///
  /// **Fehlerbehandlung**: Wenn der Benutzer in Firestore nicht gefunden wird, wird `null` zurückgegeben.
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final doc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!doc.exists) return null;

      return AppUser.fromMap(firebaseUser.uid, doc.data()!);
    } catch (e) {
      _logger.e("Error loading current user", error: e);
      return null;
    }
  }

  /// Gibt `true` zurück, wenn der Benutzer derzeit eingeloggt ist, andernfalls `false`.
  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }
}
