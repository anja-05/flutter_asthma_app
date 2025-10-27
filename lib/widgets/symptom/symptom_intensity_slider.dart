import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class SymptomIntensitySlider extends StatelessWidget {
  final double value; // 1-10
  final ValueChanged<double> onChanged;

  const SymptomIntensitySlider({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  Color _getColorForValue(double value) {
    if (value <= 3) return AppColors.successGreen;
    if (value <= 6) return AppColors.warningYellow;
    return AppColors.emergencyRed;
  }

  String _getLabelForValue(double value) {
    if (value <= 3) return 'Leicht';
    if (value <= 6) return 'Mittel';
    return 'Schwer';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForValue(value);
    final label = _getLabelForValue(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Intensität',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$label (${value.toInt()})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.2),
            thumbColor: color,
            overlayColor: color.withOpacity(0.2),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: value,
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: onChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(10, (index) {
              return Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}