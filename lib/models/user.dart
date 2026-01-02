class AppUser {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? fhirPatientId;

  AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.fhirPatientId,
  });

  String get displayName => firstName;
  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'fhirPatientId': fhirPatientId,
    };
  }

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