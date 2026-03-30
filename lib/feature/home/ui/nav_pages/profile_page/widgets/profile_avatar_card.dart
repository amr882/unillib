import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/user_model.dart';
import 'package:unilib/core/theme/app_colors.dart';

class ProfileAvatarCard extends StatelessWidget {
  final UserModel? user;
  final bool isLoading;

  const ProfileAvatarCard({
    super.key,
    this.user,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool effectivelyLoading = isLoading || user == null;

    return Center(
      child: Container(
        padding: EdgeInsets.all(3.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            effectivelyLoading
                ? Container(
                    width: 12.h,
                    height: 12.h,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.blue,
                    ),
                  ).animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 1200.ms, color: AppColors.white.withOpacity(0.3))
                : CircleAvatar(
                    radius: 6.h,
                    backgroundColor: AppColors.blue,
                    child: Text(
                      user!.fullName.isEmpty ? '?' : user!.fullName[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
            SizedBox(height: 2.h),
            effectivelyLoading
                ? Container(
                    width: 40.w,
                    height: 18.sp,
                    decoration: BoxDecoration(
                      color: AppColors.textSub.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ).animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 1200.ms, color: AppColors.white.withOpacity(0.3))
                : Text(
                    user!.fullName,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
            SizedBox(height: 0.5.h),
            effectivelyLoading
                ? Container(
                    width: 30.w,
                    height: 16.sp,
                    decoration: BoxDecoration(
                      color: AppColors.textSub.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ).animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 1200.ms, color: AppColors.white.withOpacity(0.3))
                : Text(
                    user!.email,
                    style: TextStyle(fontSize: 16.sp, color: AppColors.textMuted),
                  ),
          ],
        ),
      ),
    );
  }
}
