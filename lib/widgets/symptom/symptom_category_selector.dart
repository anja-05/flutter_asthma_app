import 'package:flutter/material.dart';

enum SymptomCategory {
  breathing,
  cough,
  throat,
  sleep,
  physical,
  other,
}

class SymptomCategorySelector extends StatelessWidget {
  final SymptomCategory? selectedCategory;
  final Function(SymptomCategory) onCategorySelected;

  const SymptomCategorySelector({
    Key? key,
    this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: SymptomCategory.values.map((category) {
        final isSelected = selectedCategory == category;
        return _buildCategoryChip(category, isSelected);
      }).toList(),
    );
  }

  Widget _buildCategoryChip(SymptomCategory category, bool isSelected) {
    final config = _getCategoryConfig(category);

    return InkWell(
      onTap: () => onCategorySelected(category),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4CAF50)
              : const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4CAF50)
                : const Color(0xFFE8F5E9),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              config.icon,
              size: 18,
              color: isSelected ? Colors.white : const Color(0xFF4CAF50),
            ),
            const SizedBox(width: 8),
            Text(
              config.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : const Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _CategoryConfig _getCategoryConfig(SymptomCategory category) {
    switch (category) {
      case SymptomCategory.breathing:
        return _CategoryConfig(
          label: 'Atmung',
          icon: Icons.air,
        );
      case SymptomCategory.cough:
        return _CategoryConfig(
          label: 'Husten',
          icon: Icons.sick,
        );
      case SymptomCategory.throat:
        return _CategoryConfig(
          label: 'Hals',
          icon: Icons.coronavirus,
        );
      case SymptomCategory.sleep:
        return _CategoryConfig(
          label: 'Schlaf',
          icon: Icons.bedtime,
        );
      case SymptomCategory.physical:
        return _CategoryConfig(
          label: 'Körperlich',
          icon: Icons.directions_run,
        );
      case SymptomCategory.other:
        return _CategoryConfig(
          label: 'Sonstiges',
          icon: Icons.more_horiz,
        );
    }
  }
}

class _CategoryConfig {
  final String label;
  final IconData icon;

  _CategoryConfig({
    required this.label,
    required this.icon,
  });
}