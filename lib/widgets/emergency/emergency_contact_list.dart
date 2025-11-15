import 'package:flutter/material.dart';
import '../common/app_card.dart';

class EmergencyContactList extends StatelessWidget {
  final List<EmergencyContact> contacts;
  final Function(EmergencyContact)? onCall;
  final VoidCallback? onAdd;

  const EmergencyContactList({
    Key? key,
    required this.contacts,
    this.onCall,
    this.onAdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: const Color(0xFFE8F5E9),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.2),
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
          ),
          const SizedBox(height: 16),

          // Emergency Number 112
          _buildEmergencyNumber(context),

          if (contacts.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Color(0xFFBDBDBD)),
            ),
            ...contacts.map((contact) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildContact(context, contact),
            )).toList(),
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

  Widget _buildEmergencyNumber(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.phone, color: Color(0xFFE53935), size: 20),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notruf',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF212121),
                  ),
                ),
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
              // Launch phone dialer
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notruf 112 wird gewählt...')),
              );
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
              contact.isPrimary ? Icons.person : Icons.person_outline,
              color: const Color(0xFF4CAF50),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.relationship,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
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
                    contact.phoneNumber,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
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
}

class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String relationship;
  final bool isPrimary;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.relationship,
    this.isPrimary = false,
  });
}