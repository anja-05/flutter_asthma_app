import 'package:flutter/material.dart';

enum PeakFlowZone { green, yellow, red }

class ZoneIndicator extends StatelessWidget {
  final PeakFlowZone zone;
  final bool showLabels;

  const ZoneIndicator({
    Key? key,
    required this.zone,
    this.showLabels = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildZoneCircle(PeakFlowZone.green),
        const SizedBox(width: 8),
        _buildZoneCircle(PeakFlowZone.yellow),
        const SizedBox(width: 8),
        _buildZoneCircle(PeakFlowZone.red),
      ],
    );
  }

  Widget _buildZoneCircle(PeakFlowZone zoneType) {
    final isActive = zone == zoneType;
    final color = _getColorForZone(zoneType);

    return Container(
      width: isActive ? 50 : 40,
      height: isActive ? 50 : 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? color : color.withOpacity(0.3),
        border: Border.all(
          color: color,
          width: isActive ? 3 : 2,
        ),
        boxShadow: isActive
            ? [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ]
            : null,
      ),
      child: Center(
        child: Text(
          _getPercentageForZone(zoneType),
          style: TextStyle(
            fontSize: isActive ? 14 : 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  Color _getColorForZone(PeakFlowZone zoneType) {
    switch (zoneType) {
      case PeakFlowZone.green:
        return const Color(0xFF4CAF50);
      case PeakFlowZone.yellow:
        return const Color(0xFFFFC107);
      case PeakFlowZone.red:
        return const Color(0xFFF44336);
    }
  }

  String _getPercentageForZone(PeakFlowZone zoneType) {
    switch (zoneType) {
      case PeakFlowZone.green:
        return '80%';
      case PeakFlowZone.yellow:
        return '50%';
      case PeakFlowZone.red:
        return '<50%';
    }
  }
}