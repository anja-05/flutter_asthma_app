/// Datenmodell für einen einzelnen Notfall-Schritt.
class EmergencyStep {
  final String text;
  bool completed;

  EmergencyStep({
    required this.text,
    this.completed = false,
  });
}