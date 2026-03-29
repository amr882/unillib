import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/home/ui/nav_pages/ai_page/widgets/ai_chat_avatar.dart';

class AiMessage extends StatelessWidget {
  final String msg;
  final String timeText;

  const AiMessage({super.key, required this.msg, this.timeText = "9:32 AM"});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AiChatAvatar(size: 9.w),
              SizedBox(width: 2.w),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 72.w),
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.2.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bubbleAiBg,
                    border: Border.all(
                      color: AppColors.bubbleAiBorder,
                      width: 0.5,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(18),
                    ),
                  ),
                  child: Text(
                    msg,
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.55,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 0.4.h),
          Padding(
            padding: EdgeInsets.only(left: 10.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  timeText,
                  style: TextStyle(
                    color: AppColors.gold500.withOpacity(0.35),
                    fontSize: 15.sp,
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
