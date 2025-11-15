import 'package:flutter/material.dart';

class GreetingHeader extends StatelessWidget {
  final String userName;
  final String? subtitle;

  const GreetingHeader({
    Key? key,
    required this.userName,
    this.subtitle,
  }) : super(key: key);

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Guten Morgen';
    } else if (hour < 18) {
      return 'Guten Tag';
    } else {
      return 'Guten Abend';
    }
  }

  String _getWeatherEmoji() {
    // Simplified - in real app, get from weather API
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 20) {
      return '☀️';
    } else {
      return '🌙';
    }
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final days = [
      'Sonntag',
      'Montag',
      'Dienstag',
      'Mittwoch',
      'Donnerstag',
      'Freitag',
      'Samstag'
    ];
    final months = [
      'Januar',
      'Februar',
      'März',
      'April',
      'Mai',
      'Juni',
      'Juli',
      'August',
      'September',
      'Oktober',
      'November',
      'Dezember'
    ];

    return '${days[now.weekday % 7]}, ${now.day}. ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_getGreeting()}, $userName!',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 8),
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                _getCurrentDate(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757575),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getWeatherEmoji(),
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}