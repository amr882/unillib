import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/core/theme/app_text_styles.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: 6.h,
        decoration: BoxDecoration(
          color: AppColors.navyInput,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.navyBorder, width: 1),
        ),
        child: Row(
          children: [
            SizedBox(width: 4.w),
            Icon(Icons.search_rounded, color: AppColors.white, size: 2.5.h),
            SizedBox(width: 3.w),
            Expanded(
              child: TextField(
                style: AppTextStyles.inputText,
                decoration: InputDecoration(
                  hintText: 'Search books...',
                  hintStyle: AppTextStyles.hintText,
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
