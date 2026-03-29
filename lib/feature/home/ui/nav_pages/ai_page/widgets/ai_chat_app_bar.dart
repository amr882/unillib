import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/home/ui/nav_pages/ai_page/widgets/ai_chat_avatar.dart';

class AiChatHeader extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const AiChatHeader({super.key, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.navy800, AppColors.navy900],
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColors.gold500.withOpacity(0.2),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              if (onBackPressed != null) {
                onBackPressed!();
              } else if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: Text(
              '‹',
              style: TextStyle(
                color: AppColors.gold500,
                fontSize: 30.sp,
                fontWeight: FontWeight.w300,
                height: 1,
              ),
            ),
          ),
          SizedBox(width: 3.w),

          AiChatAvatar(size: 11.w),
          SizedBox(width: 3.w),

          // Name + status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UniLib AI',
                  style: GoogleFonts.playfairDisplay(
                    color: AppColors.gold500,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          // Menu icon
          Text(
            '⋮',
            style: TextStyle(
              color: AppColors.gold500.withOpacity(0.8),
              fontSize: 18.sp,
            ),
          ),
        ],
      ),
    );
  }
}
