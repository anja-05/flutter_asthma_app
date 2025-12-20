import 'package:flutter/material.dart';
import '../common/app_card.dart';

/// Zeigt eine Notfall-Kontaktkarte mit Name, Beziehung und Telefonnummer an.
/// Anruf- und Bearbeitungsaktionen sind nur vorhanden, wenn sie gesetzt sind.
class EmergencyContactCard extends StatelessWidget {
  /// Name der Kontaktperson.
  final String name;

  /// Beziehung zur Kontaktperson (z. B. Mutter, Freund, Arzt).
  final String relationship;

  /// Telefonnummer der Kontaktperson.
  final String phoneNumber;

  /// Callback zum direkten Anrufen des Kontakts.
  final VoidCallback? onCall;

  /// Callback zum Bearbeiten des Kontakts.
  final VoidCallback? onEdit;

  const EmergencyContactCard({
    super.key,
    required this.name,
    required this.relationship,
    required this.phoneNumber,
    this.onCall,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: const Color(0xFFFFF9E6),
      borderRadius: 12,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.person,
              color: Color(0xFFFF9800),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  relationship,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.phone,
                      size: 14,
                      color: Color(0xFF757575),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      phoneNumber,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onCall != null)
            IconButton(
              icon: const Icon(Icons.call, color: Color(0xFF4CAF50)),
              onPressed: onCall,
            ),
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF757575)),
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }
}