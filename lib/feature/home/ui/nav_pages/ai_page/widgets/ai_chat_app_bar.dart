import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/home/ui/nav_pages/ai_page/widgets/ai_chat_avatar.dart';

import 'package:unilib/core/helper/extention.dart';

class AiChatHeader extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final bool isDarkMode;

  const AiChatHeader({
    super.key,
    this.onBackPressed,
    this.showBackButton = true,
    this.isDarkMode = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: isDarkMode ? null : AppColors.backGround,
        gradient: isDarkMode
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.navy800, AppColors.navy900],
              )
            : null,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode
                ? AppColors.gold500.withOpacity(0.2)
                : AppColors.navyBorder.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          if (showBackButton) ...[
            GestureDetector(
              onTap: () {
                if (onBackPressed != null) {
                  onBackPressed!();
                } else {
                  context.pop();
                }
              },
              child: Text(
                '‹',
                style: TextStyle(
                  color: isDarkMode ? AppColors.gold500 : AppColors.gold,
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w300,
                  height: 1,
                ),
              ),
            ),
            SizedBox(width: 3.w),
          ],

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
                    color: isDarkMode ? AppColors.gold500 : AppColors.blue,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
