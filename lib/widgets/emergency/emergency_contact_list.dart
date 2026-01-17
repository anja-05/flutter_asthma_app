import 'package:flutter/material.dart';
import '../common/app_card.dart';
import 'package:asthma_app/services/phone_service.dart';

/// Zeigt eine Liste wichtiger Notfallkontakte an.
/// Die Liste enthält persönliche Kontakte sowie eine feste Notrufnummer
/// und unterstützt Aktionen wie Anrufen, Hinzufügen und Löschen.
class EmergencyContactList extends StatelessWidget {
  /// Liste der gespeicherten Notfallkontakte.
  final List<EmergencyContact> contacts;

  /// Callback zum Anrufen eines Kontakts.
  /// Übergibt den ausgewählten Kontakt.
  final Function(EmergencyContact)? onCall;

  /// Callback zum Bearbeiten eines Kontakts.
  /// Übergibt den zu bearbeitenden Kontakt.
  final Function(EmergencyContact)? onEdit;

  /// Callback zum Hinzufügen eines neuen Kontakts.
  final VoidCallback? onAdd;

  /// Callback zum Löschen eines Kontakts.
  /// Übergibt den zu löschenden Kontakt.
  final Function(EmergencyContact)? onDelete;

  const EmergencyContactList({
    Key? key,
    required this.contacts,
    this.onCall,
    this.onAdd,
    this.onDelete,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: const Color(0xFFE8F5E9),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),

          _buildEmergencyNumber(context),

          if (contacts.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                'Noch keine persönlichen Notfallkontakte gespeichert.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757575),
                ),
              ),
            ),

          if (contacts.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Color(0xFFBDBDBD)),
            ),
            ...contacts.map(
              (contact) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildContact(context, contact),
              ),
            ),
          ],

          if (onAdd != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Kontakt hinzufügen'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4CAF50),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.phone,
            color: Color(0xFF4CAF50),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Wichtige Kontakte',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4CAF50),
            ),
          ),
        ),
      ],
    );
  }

  // NOTRUF 112 ist daweil nur Demo
  Widget _buildEmergencyNumber(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.phone, color: Color(0xFFE53935), size: 20),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notruf'),
                Text(
                  '112',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE53935),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              PhoneService.call('112');
            },
            icon: const Icon(Icons.phone),
            label: const Text('Notruf wählen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildContact(BuildContext context, EmergencyContact contact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              contact.isPrimary ? Icons.star : Icons.person_outline,
              color: contact.isPrimary
                  ? const Color(0xFFFF9800)
                  : const Color(0xFF4CAF50),
              size: 20,
            ),
            const SizedBox(width: 8),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (contact.isPrimary)
                    const Text(
                      'Primärer Kontakt',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFFF9800),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  Text(
                    contact.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  Text(
                    contact.relationship,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                    ),
                  ),
                  Text(
                    contact.phoneNumber,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  tooltip: 'Kontakt bearbeiten',
                  onPressed: () {
                    if (onEdit != null) {
                      onEdit!(contact);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Kontakt löschen',
                  onPressed: () => _confirmDelete(context, contact),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              if (onCall != null) {
                onCall!(contact);
              }
            },
            icon: const Icon(Icons.phone),
            label: Text('${contact.name} anrufen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, EmergencyContact contact) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Kontakt löschen'),
        content: Text(
          'Möchtest du den Kontakt "${contact.name}" wirklich entfernen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onDelete != null) {
                onDelete!(contact);
              }
            },
            child: const Text(
              'Löschen',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

/// Datenmodell für einen Notfallkontakt.
class EmergencyContact {
  /// Eindeutige ID des Kontakts.
  final String id;

  /// Name der Kontaktperson.
  final String name;

  /// Telefonnummer der Kontaktperson.
  final String phoneNumber;

  /// Beziehung zur Kontaktperson (z. B. Mutter, Freund).
  final String relationship;

  /// Gibt an, ob es sich um den primären Kontakt handelt.
  final bool isPrimary;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.relationship,
    this.isPrimary = false,
  });
}