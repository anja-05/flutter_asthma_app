import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _usersKey = 'registered_users';

  // Registrierung
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Prüfe ob Email bereits existiert
      final users = await _getAllUsers();
      if (users.any((user) => user['user']['email'] == email)) {
        return false; // Email bereits registriert
      }

      // Erstelle neuen User
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        firstName: firstName,
        lastName: lastName,
        email: email,
      );

      // Speichere User in Liste
      users.add({
        'user': newUser.toJson(),
        'password': password, // In echter App: Password hashen!
      });

      await prefs.setString(_usersKey, jsonEncode(users));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Login
  Future<User?> login(String email, String password) async {
    try {
      final users = await _getAllUsers();

      // Finde User mit Email und Passwort
      final userData = users.firstWhere(
            (user) => user['user']['email'] == email && user['password'] == password,
        orElse: () => {},
      );

      if (userData.isEmpty) {
        return null; // Login fehlgeschlagen
      }

      final user = User.fromJson(userData['user']);

      // Speichere aktuellen User
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));

      return user;
    } catch (e) {
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Aktuell eingeloggten User abrufen
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson == null) return null;

      return User.fromJson(jsonDecode(userJson));
    } catch (e) {
      return null;
    }
  }

  // Prüfe ob User eingeloggt ist
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  // Hilfsfunktion: Alle registrierten User abrufen
  Future<List<Map<String, dynamic>>> _getAllUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);

      if (usersJson == null) return [];

      final List<dynamic> usersList = jsonDecode(usersJson);
      return usersList.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }
}