import 'package:flutter/material.dart';
import '../models/filter_type.dart';
import '../theme/glassmorphism_theme.dart';

class FilterTabs extends StatelessWidget {
  final FilterType currentFilter;
  final Function(FilterType) onFilterChanged;

  const FilterTabs({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: FilterType.values.map((filter) {
            final isSelected = filter == currentFilter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter.displayName),
                selected: isSelected,
                onSelected: (_) => onFilterChanged(filter),
                backgroundColor: GlassmorphismColors.backgroundTertiary,
                selectedColor: GlassmorphismColors.primary.withValues(alpha: 0.1),
                checkmarkColor: GlassmorphismColors.primary,
                labelStyle: TextStyle(
                  color: isSelected 
                      ? GlassmorphismColors.primary 
                      : GlassmorphismColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isSelected 
                        ? GlassmorphismColors.primary 
                        : GlassmorphismColors.divider,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}