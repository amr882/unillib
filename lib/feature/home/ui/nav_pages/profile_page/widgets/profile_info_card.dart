import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/user_model.dart';
import 'package:unilib/core/theme/app_colors.dart';

class ProfileInfoCard extends StatelessWidget {
  final UserModel? user;
  final bool isLoading;

  const ProfileInfoCard({super.key, this.user, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final bool effectivelyLoading = isLoading || user == null;
    final bool isAdmin = user?.isAdmin ?? false;

    return Container(
      padding: EdgeInsets.all(3.h),
      decoration: BoxDecoration(
        color: AppColors.navyCard.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isAdmin 
              ? AppColors.gold.withOpacity(0.3) 
              : AppColors.gold.withOpacity(0.15),
          width: isAdmin ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isAdmin 
                ? AppColors.gold.withOpacity(0.1) 
                : Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            isAdmin ? 'Department' : 'Faculty', 
            user?.faculty, 
            isAdmin ? Icons.business_center_rounded : Icons.account_balance_rounded, 
            effectivelyLoading
          ),
          Divider(color: AppColors.gold.withOpacity(0.1), height: 3.h),
          _buildInfoRow(
            isAdmin ? 'Admin ID' : 'Student ID', 
            user?.studentId, 
            isAdmin ? Icons.admin_panel_settings_outlined : Icons.badge_rounded, 
            effectivelyLoading
          ),
          Divider(color: AppColors.gold.withOpacity(0.1), height: 3.h),
          _buildInfoRow(
            isAdmin ? 'Access Level' : 'Academic Year',
            isAdmin ? 'Full Access' : user?.academicYear,
            isAdmin ? Icons.gpp_good_rounded : Icons.event_note_rounded,
            effectivelyLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value, IconData icon, bool effectivelyLoading) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.gold, size: 18.sp),
        ),
        SizedBox(width: 4.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.textSub,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 0.5.h),
            effectivelyLoading
                ? Container(
                    width: 25.w,
                    height: 14.sp,
                    decoration: BoxDecoration(
                      color: AppColors.navyInput,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(
                      duration: 1200.ms,
                      color: AppColors.gold.withOpacity(0.1),
                    )
                : Text(
                    value ?? '??',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ],
        ),
      ],
    );
  }
}
