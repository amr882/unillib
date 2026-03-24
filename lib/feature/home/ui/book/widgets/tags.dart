import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';

class TagsRow extends StatelessWidget {
  final List<String> tags;
  const TagsRow({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: tags.map((tag) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
          decoration: BoxDecoration(
            color: AppColors.blue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.blue.withOpacity(0.2)),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }
}
