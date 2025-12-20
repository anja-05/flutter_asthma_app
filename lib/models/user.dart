class AppUser {
  final String id;        // Firebase UID
  final String firstName;
  final String lastName;
  final String email;

  AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  /// Anzeigename (z. B. "Hallo Lisa")
  String get displayName => firstName;

  /// Voller Name
  String get fullName => '$firstName $lastName';

  /// 🔹 Für Firestore
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };
  }

  /// 🔹 Aus Firestore lesen
  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      firstName: data['firstName'],
      lastName: data['lastName'],
      email: data['email'],
    );
  }
}
