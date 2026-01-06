/// Repräsentiert einen einzelnen Notfall-Schritt.
///
/// Jede Instanz beschreibt eine Aufgabe, die abgearbeitet werden soll, und speichert, ob sie bereits erledigt wurde.
class EmergencyStep {
  final String text;
  bool completed;

  EmergencyStep({
    required this.text,
    this.completed = false,
  });
}