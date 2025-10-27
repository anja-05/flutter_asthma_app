import 'package:flutter/material.dart';
import '../../models/peak_flow_measurement.dart';
import '../../constants/app_colors.dart';

class PeakFlowMeter extends StatelessWidget {
  final PeakFlowMeasurement measurement;

  const PeakFlowMeter({
    Key? key,
    required this.measurement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: measurement.zoneColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: measurement.zoneColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Aktuelle Messung',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${measurement.value}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: measurement.zoneColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'l/min',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: measurement.zoneColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              measurement.zone,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${measurement.percentageOfBest.toStringAsFixed(0)}% vom Bestwert',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            measurement.zoneDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: measurement.zoneColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}