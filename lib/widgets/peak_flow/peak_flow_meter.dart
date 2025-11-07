import 'package:flutter/material.dart';
import '../common/app_card.dart';
import 'zone_indicator.dart';

class PeakFlowMeter extends StatelessWidget {
  final double currentValue;
  final double personalBest;
  final VoidCallback? onMeasure;

  const PeakFlowMeter({
    super.key,
    required this.currentValue,
    required this.personalBest,
    this.onMeasure,
  });

  PeakFlowZone _getZone() {
    final percentage = (currentValue / personalBest) * 100;
    if (percentage >= 80) {
      return PeakFlowZone.green;
    } else if (percentage >= 50) {
      return PeakFlowZone.yellow;
    } else {
      return PeakFlowZone.red;
    }
  }

  String _getZoneText() {
    switch (_getZone()) {
      case PeakFlowZone.green:
        return 'Grüne Zone - Alles in Ordnung';
      case PeakFlowZone.yellow:
        return 'Gelbe Zone - Vorsicht';
      case PeakFlowZone.red:
        return 'Rote Zone - Achtung!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Aktuelle Messung',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: currentValue / 600,
                  strokeWidth: 20,
                  backgroundColor: Colors.grey.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getZone() == PeakFlowZone.green
                        ? const Color(0xFF4CAF50)
                        : _getZone() == PeakFlowZone.yellow
                        ? const Color(0xFFFFC107)
                        : const Color(0xFFF44336),
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${currentValue.toInt()}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const Text(
                    'L/min',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          ZoneIndicator(zone: _getZone()),
          const SizedBox(height: 12),
          Text(
            _getZoneText(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Persönlicher Bestwert: ${personalBest.toInt()} L/min',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
            ),
          ),
          if (onMeasure != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onMeasure,
                icon: const Icon(Icons.speed),
                label: const Text('Neue Messung'),
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
        ],
      ),
    );
  }
}