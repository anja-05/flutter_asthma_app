import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';
import 'package:Asthma_Assist/services/fhir_patient_service.dart';

class AuthService {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Firebase Auth-State-Stream (für AuthWrapper)
  Stream<fb_auth.User?> get authStateChanges =>
      _auth.authStateChanges();

  // =========================
  // REGISTRIERUNG
  // =========================
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      // 🔐 Firebase Authentication
      final credential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // 👤 User-Profil in Firestore speichern
      await _firestore.collection('users').doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ✅ WICHTIG: User wieder ausloggen
      await _auth.signOut();

      return true;
    } on fb_auth.FirebaseAuthException {
      return false;
    } catch (_) {
      return false;
    }
  }

  // =========================
  // LOGIN
  // =========================
  Future<AppUser?> login(String email, String password) async {
    try {
      final credential =
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      final docRef = _firestore.collection('users').doc(uid);
      final doc = await docRef.get();

      if (!doc.exists) return null;

      AppUser user = AppUser.fromMap(uid, doc.data()!);

      // 🏥 FHIR Patient sicherstellen
      final fhirService = FhirPatientService();
      final patientId = await fhirService.ensurePatientForUser(
        uid: uid,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
      );

      // 🔁 Falls noch keine FHIR-ID gespeichert ist
      if (user.fhirPatientId == null) {
        await docRef.update({
          'fhirPatientId': patientId,
        });
      }

      // 🔄 User erneut laden (jetzt inkl. fhirPatientId)
      final updatedDoc = await docRef.get();
      return AppUser.fromMap(uid, updatedDoc.data()!);

    } on fb_auth.FirebaseAuthException {
      return null;
    }
  }


  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    await _auth.signOut();
  }

  // =========================
  // AKTUELLER USER
  // =========================
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    final doc = await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (!doc.exists) return null;

    return AppUser.fromMap(firebaseUser.uid, doc.data()!);
  }

  // =========================
  // IST EINGELOGGT?
  // =========================
  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }
}
