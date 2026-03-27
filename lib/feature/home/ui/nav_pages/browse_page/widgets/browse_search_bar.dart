// widgets/browse_search_bar.dart
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/core/theme/app_text_styles.dart';

class BrowseSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const BrowseSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: 6.h,
        decoration: BoxDecoration(
          color: AppColors.navyInput,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.navyBorder, width: 1),
        ),
        child: Row(
          children: [
            SizedBox(width: 4.w),
            Icon(Icons.search_rounded, color: AppColors.white, size: 2.5.h),
            SizedBox(width: 3.w),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: AppTextStyles.inputText,
                decoration: InputDecoration(
                  hintText: 'Search resources...',
                  hintStyle: AppTextStyles.hintText,
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            // Clear button
            if (controller.text.isNotEmpty)
              GestureDetector(
                onTap: onClear,
                child: Padding(
                  padding: EdgeInsets.only(right: 3.w),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.textMuted,
                    size: 2.h,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
