import 'package:flutter/material.dart';
import '../common/app_card.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String content;
  final VoidCallback onTap;

  const DashboardCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.content,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: backgroundColor,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 34,
            color: iconColor,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.3,
                    color: Color(0xFF212121),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}