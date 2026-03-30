import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/user_model.dart';
import 'package:unilib/core/theme/app_colors.dart';

class ProfileInfoCard extends StatelessWidget {
  final UserModel? user;
  final bool isLoading;

  const ProfileInfoCard({
    super.key,
    this.user,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool effectivelyLoading = isLoading || user == null;

    return Container(
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
          _buildInfoRow('Faculty', user?.faculty, effectivelyLoading),
          Divider(color: AppColors.textSub.withOpacity(0.2), height: 3.h),
          _buildInfoRow('Student ID', user?.studentId, effectivelyLoading),
          Divider(color: AppColors.textSub.withOpacity(0.2), height: 3.h),
          _buildInfoRow('Academic Year', user?.academicYear, effectivelyLoading),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value, bool effectivelyLoading) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        effectivelyLoading
            ? Container(
                width: 25.w,
                height: 14.sp,
                decoration: BoxDecoration(
                  color: AppColors.textSub.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 1200.ms, color: AppColors.white.withOpacity(0.3))
            : Text(
                value ?? '??',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ],
    );
  }
}
