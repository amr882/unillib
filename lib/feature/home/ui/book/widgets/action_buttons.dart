import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/core/theme/app_text_styles.dart';

class ActionButtons extends StatelessWidget {
  final Book book;
  const ActionButtons({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Read Online
        Expanded(
          child: GestureDetector(
            onTap: () {
              // TODO: open sourceUrl in browser
            },
            child: Container(
              height: 6.5.h,
              decoration: BoxDecoration(
                gradient: AppColors.blueGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 2.w),
                  Text('Read Online', style: AppTextStyles.buttonLabel),
                ],
              ),
            ),
          ),
        ),

        SizedBox(width: 3.w),

        // Download / Borrow
        Expanded(
          child: GestureDetector(
            onTap: () {
              // TODO: borrow action
            },
            child: Container(
              height: 6.5.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.navy.withOpacity(0.15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_rounded, color: AppColors.navy, size: 18),
                  SizedBox(width: 2.w),
                  Text(
                    'Download',
                    style: AppTextStyles.buttonLabel.copyWith(
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        SizedBox(width: 3.w),

        // Bookmark icon
        Container(
          height: 6.5.h,
          width: 6.5.h,
          decoration: BoxDecoration(
            color: AppColors.gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.gold.withOpacity(0.3)),
          ),
          child: const Icon(
            Icons.bookmark_border_rounded,
            color: AppColors.gold,
          ),
        ),
      ],
    );
  }
}
