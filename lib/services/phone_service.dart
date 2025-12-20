import 'package:url_launcher/url_launcher.dart';

/// Service zum Auslösen eines Telefonanrufs über das Gerätesystem.
class PhoneService {
  /// Startet einen Telefonanruf zur angegebenen Telefonnummer.
  /// Gibt `true` zurück, wenn der Anruf erfolgreich gestartet wurde, andernfalls `false`.
  static Future<bool> call(String number) async {
    final uri = Uri(scheme: 'tel', path: number);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return true;
    }
    return false;
  }
}