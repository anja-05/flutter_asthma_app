import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart'; // enthält AppUser

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
      // 🔐 Firebase Authentication
      final credential =
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // 📄 User-Profil aus Firestore laden
      final doc =
      await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) return null;

      return AppUser.fromMap(uid, doc.data()!);
    } on fb_auth.FirebaseAuthException {
      return null;
    } catch (_) {
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
