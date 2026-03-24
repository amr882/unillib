import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/core/theme/app_text_styles.dart';

class HomeWelcomeHeader extends StatelessWidget {
  final String userName;
  const HomeWelcomeHeader({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
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
            Text(
              userName,
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 18.sp,
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.gold,
          child: Text(
            userName.isNotEmpty ? userName[0] : 'U',
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
