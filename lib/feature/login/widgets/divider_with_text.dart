import 'package:flutter/material.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/core/theme/app_text_styles.dart';

class DividerWithText extends StatelessWidget {
  final String text;

  const DividerWithText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: AppColors.navyBorder,
            thickness: 1,
            endIndent: 12,
          ),
        ),
        Text(text, style: AppTextStyles.dividerLabel),
        const Expanded(
          child: Divider(color: AppColors.navyBorder, thickness: 1, indent: 12),
        ),
      ],
    );
  }
}
