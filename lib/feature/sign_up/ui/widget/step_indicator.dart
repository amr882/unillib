import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/core/theme/app_text_styles.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> labels;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps * 2 - 1, (i) {
        if (i.isOdd) return _Connector(filled: i ~/ 2 < currentStep);

        final stepIndex = i ~/ 2;
        final isDone = stepIndex < currentStep;
        final isActive = stepIndex == currentStep;

        return _StepDot(
          index: stepIndex + 1,
          isDone: isDone,
          isActive: isActive,
          label: labels[stepIndex],
        );
      }),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final bool isDone;
  final bool isActive;
  final String label;

  const _StepDot({
    required this.index,
    required this.isDone,
    required this.isActive,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = isDone
        ? AppColors.blue
        : isActive
        ? AppColors.navy
        : AppColors.navyBorder;

    final Color borderColor = isActive
        ? AppColors.navyBorder
        : Colors.transparent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 2),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.navyCard.withOpacity(0.35),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : Text(
                    '$index',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isActive ? AppColors.navyCard : Colors.white54,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 0.4.h),
        Text(
          label,
          style: AppTextStyles.fieldLabel.copyWith(
            color: isActive ? AppColors.navyBorder : Colors.white38,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _Connector extends StatelessWidget {
  final bool filled;
  const _Connector({required this.filled});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        height: 2,
        margin: EdgeInsets.only(bottom: 1.8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          gradient: filled
              ? LinearGradient(colors: [AppColors.blue, AppColors.navy])
              : null,
          color: filled ? null : AppColors.navyBorder,
        ),
      ),
    );
  }
}
