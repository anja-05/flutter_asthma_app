import 'package:flutter/material.dart';
import '../common/app_card.dart';

class EmergencyContactCard extends StatelessWidget {
  final String name;
  final String relationship;
  final String phoneNumber;
  final VoidCallback? onCall;
  final VoidCallback? onEdit;

  const EmergencyContactCard({
    Key? key,
    required this.name,
    required this.relationship,
    required this.phoneNumber,
    this.onCall,
    this.onEdit,
  }) : super(key: key);

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