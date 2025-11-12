import 'package:flutter/material.dart';
import '../common/app_card.dart';

class AqiCard extends StatelessWidget {
  final int aqiValue;
  final String location;
  final String category;
  final String? recommendation;
  final VoidCallback? onTap;

  const AqiCard({
    super.key,
    required this.aqiValue,
    required this.location,
    required this.category,
    this.recommendation,
    this.onTap,
  });

  Color _getAqiColor() {
    if (aqiValue <= 50) {
      return const Color(0xFF4CAF50);
    } else if (aqiValue <= 100) {
      return const Color(0xFFFFC107);
    } else if (aqiValue <= 150) {
      return const Color(0xFFFF9800);
    } else {
      return const Color(0xFFF44336);
    }
  }

  IconData _getAqiIcon() {
    if (aqiValue <= 50) {
      return Icons.check_circle;
    } else if (aqiValue <= 100) {
      return Icons.warning_amber_rounded;
    } else {
      return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: _getAqiColor().withOpacity(0.1),
      borderRadius: 12,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getAqiColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.air,
                  color: _getAqiColor(),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Luftqualität',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          location,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'AQI: ',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757575),
                ),
              ),
              Text(
                '$aqiValue',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _getAqiColor(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getAqiColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getAqiIcon(),
                        size: 16,
                        color: _getAqiColor(),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getAqiColor(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (recommendation != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: _getAqiColor(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}