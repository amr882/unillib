import 'package:flutter/material.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/core/theme/app_dimens.dart';
import 'package:unilib/core/theme/app_text_styles.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final Widget? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimens.btnHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.blueGradient,
          borderRadius: AppDimens.btnRadius,
          boxShadow: [
            BoxShadow(
              color: AppColors.blue.withOpacity(0.40),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: AppDimens.btnRadius),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.navy,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      icon!,
                      const SizedBox(width: AppDimens.spXS),
                    ],
                    Text(label, style: AppTextStyles.buttonLabel),
                  ],
                ),
        ),
      ),
    );
  }
}
