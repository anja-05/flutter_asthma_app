import 'package:flutter/material.dart';
import '../common/app_card.dart';

class PollenCard extends StatelessWidget {
  final Map<String, int> pollenLevels;
  final String? location;
  final VoidCallback? onTap;

  const PollenCard({
    super.key,
    required this.pollenLevels,
    this.location,
    this.onTap,
  });

  Color _getLevelColor(int level) {
    switch (level) {
      case 0:
        return const Color(0xFF4CAF50);
      case 1:
        return const Color(0xFF8BC34A);
      case 2:
        return const Color(0xFFFFC107);
      case 3:
        return const Color(0xFFFF9800);
      case 4:
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String _getLevelText(int level) {
    switch (level) {
      case 0:
        return 'Keine';
      case 1:
        return 'Gering';
      case 2:
        return 'Mittel';
      case 3:
        return 'Hoch';
      case 4:
        return 'Sehr hoch';
      default:
        return 'Unbekannt';
    }
  }

  IconData _getPollenIcon(String pollenType) {
    switch (pollenType.toLowerCase()) {
      case 'gräser':
        return Icons.grass;
      case 'birke':
      case 'erle':
      case 'hasel':
        return Icons.park;
      case 'beifuß':
      case 'ambrosia':
        return Icons.eco;
      default:
        return Icons.local_florist;
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxLevel = pollenLevels.values.reduce((a, b) => a > b ? a : b);

    return AppCard(
      backgroundColor: _getLevelColor(maxLevel).withValues(alpha: 0.1),
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
                  color: _getLevelColor(maxLevel).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.local_florist,
                  color: _getLevelColor(maxLevel),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pollenflug',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                    ),
                    if (location != null && location!.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            location!,
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getLevelColor(maxLevel).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getLevelText(maxLevel),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getLevelColor(maxLevel),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...pollenLevels.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(
                    _getPollenIcon(entry.key),
                    size: 20,
                    color: _getLevelColor(entry.value),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(4, (index) {
                      return Container(
                        width: 8,
                        height: 20,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: index < entry.value
                              ? _getLevelColor(entry.value)
                              : Colors.grey.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    child: Text(
                      _getLevelText(entry.value),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getLevelColor(entry.value),
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
