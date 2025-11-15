import 'package:flutter/material.dart';
import '../common/app_card.dart';

enum WeatherStatus { good, moderate, poor }

class WeatherStatusCard extends StatelessWidget {
  final WeatherStatus status;
  final String message;
  final String location;

  const WeatherStatusCard({
    Key? key,
    required this.status,
    required this.message,
    this.location = 'Aktueller Standort',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return AppCard(
      backgroundColor: config.backgroundColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: config.iconBackgroundColor,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  config.icon,
                  color: config.iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: config.textColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          location,
                          style: TextStyle(
                            fontSize: 12,
                            color: config.textColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      config.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: config.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: config.textColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: config.textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(WeatherStatus status) {
    switch (status) {
      case WeatherStatus.good:
        return _StatusConfig(
          title: 'Gute Bedingungen',
          backgroundColor: const Color(0xFF66BB6A),
          iconBackgroundColor: Colors.white.withOpacity(0.3),
          iconColor: Colors.white,
          textColor: Colors.white,
          icon: Icons.check_circle,
        );
      case WeatherStatus.moderate:
        return _StatusConfig(
          title: 'Mäßige Belastung',
          backgroundColor: const Color(0xFFFBC02D),
          iconBackgroundColor: Colors.white.withOpacity(0.3),
          iconColor: Colors.white,
          textColor: Colors.white,
          icon: Icons.warning,
        );
      case WeatherStatus.poor:
        return _StatusConfig(
          title: 'Hohe Belastung',
          backgroundColor: const Color(0xFFE53935),
          iconBackgroundColor: Colors.white.withOpacity(0.3),
          iconColor: Colors.white,
          textColor: Colors.white,
          icon: Icons.error,
        );
    }
  }
}

class _StatusConfig {
  final String title;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;

  _StatusConfig({
    required this.title,
    required this.backgroundColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.icon,
  });
}