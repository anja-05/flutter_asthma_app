import 'package:flutter/material.dart';

class SymptomIntensitySlider extends StatelessWidget {
  final String symptomName;
  final int intensity;
  final ValueChanged<int> onChanged;
  final IconData? icon;

  const SymptomIntensitySlider({
    Key? key,
    required this.symptomName,
    required this.intensity,
    required this.onChanged,
    this.icon,
  }) : super(key: key);

  Color _getColorForIntensity(int value) {
    if (value <= 2) {
      return const Color(0xFF4CAF50);
    } else if (value <= 4) {
      return const Color(0xFFFFC107);
    } else {
      return const Color(0xFFF44336);
    }
  }

  String _getIntensityLabel(int value) {
    switch (value) {
      case 1:
        return 'Sehr leicht';
      case 2:
        return 'Leicht';
      case 3:
        return 'Mittel';
      case 4:
        return 'Stark';
      case 5:
        return 'Sehr stark';
      default:
        return 'Keine';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 24,
                  color: _getColorForIntensity(intensity),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  symptomName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getColorForIntensity(intensity).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getIntensityLabel(intensity),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getColorForIntensity(intensity),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _getColorForIntensity(intensity),
              inactiveTrackColor:
              _getColorForIntensity(intensity).withOpacity(0.2),
              thumbColor: _getColorForIntensity(intensity),
              overlayColor: _getColorForIntensity(intensity).withOpacity(0.2),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 10,
              ),
            ),
            child: Slider(
              value: intensity.toDouble(),
              min: 0,
              max: 5,
              divisions: 5,
              onChanged: (value) => onChanged(value.toInt()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return Text(
                '$index',
                style: TextStyle(
                  fontSize: 12,
                  color: intensity == index
                      ? _getColorForIntensity(intensity)
                      : const Color(0xFF9E9E9E),
                  fontWeight:
                  intensity == index ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}