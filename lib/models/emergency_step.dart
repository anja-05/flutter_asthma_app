/// Repräsentiert einen einzelnen Notfall-Schritt.
///
/// Jede Instanz beschreibt eine Aufgabe, die abgearbeitet werden soll, und speichert, ob sie bereits erledigt wurde.
class EmergencyStep {
  /// Beschreibung des durchzuführenden Schritts
  final String text;

  /// Status des Schritts: `true`, wenn erledigt
  bool completed;

  /// Erstellt neuen Notfall-Schritt.
  EmergencyStep({
    required this.text,
    this.completed = false,
  });
}