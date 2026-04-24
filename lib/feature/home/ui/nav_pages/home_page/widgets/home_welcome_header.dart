import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/core/theme/app_text_styles.dart';

class HomeWelcomeHeader extends StatelessWidget {
  final String userName;
  final bool isLoading;

  const HomeWelcomeHeader({
    super.key,
    required this.userName,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // If loading or name is literally "NULL NULL", treat as loading
    final bool effectivelyLoading =
        isLoading || userName.toUpperCase().contains('NULL');
    final String displayUserName = effectivelyLoading ? '...' : userName;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: AppTextStyles.heading.copyWith(
                color: AppColors.textSub,
                fontSize: 20.sp,
              ),
            ),
            SizedBox(height: 0.3.h),
            effectivelyLoading
                ? Container(
                        width: 40.w,
                        height: 22.sp,
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(
                        duration: 1200.ms,
                        color: AppColors.white.withOpacity(0.3),
                      )
                : Text(
                    displayUserName,
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
          ],
        ),
        effectivelyLoading
            ? Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold,
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(
                    duration: 1200.ms,
                    color: AppColors.white.withOpacity(0.3),
                  )
            : CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.gold,
                child: Text(
                  displayUserName.isNotEmpty && displayUserName != '...'
                      ? displayUserName[0]
                      : 'U',
                  style: AppTextStyles.heading.copyWith(
                    color: AppColors.white,
                    fontSize: 18,
                  ),
                ),
              ),
      ],
    );
  }
}
