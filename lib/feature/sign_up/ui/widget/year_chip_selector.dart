import 'package:flutter/material.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/core/theme/app_text_styles.dart';

class YearChipSelector extends StatelessWidget {
  final List<String> years;
  final String selected;
  final ValueChanged<String> onSelected;

  const YearChipSelector({
    super.key,
    required this.years,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: years.map((year) {
        final isSelected = year == selected;
        return GestureDetector(
          onTap: () => onSelected(year),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.navyBorder : AppColors.navy,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppColors.gold
                    : AppColors.navyBorder.withOpacity(0.6),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.navy.withOpacity(0.25),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              year,
              style: AppTextStyles.subheading.copyWith(
                color: isSelected ? AppColors.white : Colors.white60,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
