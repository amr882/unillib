import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';

class AiChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const AiChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 3.w,
        right: 3.w,
        top: 1.5.h,
        bottom: MediaQuery.of(context).padding.bottom + 1.5.h,
      ),
      decoration: BoxDecoration(color: Colors.transparent),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [


          // Text field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.gold500.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.gold500.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: TextField(
                cursorColor: AppColors.white,
                controller: controller,
                onSubmitted: (_) => onSend(),
                style: TextStyle(color: AppColors.textLight, fontSize: 16.sp),
                maxLines: 4,
                minLines: 1,

                decoration: InputDecoration(
                  hintText: 'Ask UniLib AI...',
                  hintStyle: TextStyle(
                    color: AppColors.gold100.withOpacity(0.5),
                    fontSize: 16.sp,
                  ),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 1.2.h,
                    horizontal: 1.2.w,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 2.w),

          // Send button
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 13.w,
              height: 13.w,
              margin: EdgeInsets.only(bottom: 0.5.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [AppColors.gold400, AppColors.gold100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navyInput,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.send_rounded,
                  color: AppColors.white,
                  size: 6.5.w,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


}

// Playfair Display (serif) — used for the AI assistant name "UniLib AI" in the header. It gives that luxury, editorial feel that pairs well with the gold theme.
// DM Sans — used for all the body text, messages, timestamps, chips, and input placeholder. It's a clean, modern geometric sans-serif that keeps things readable and sleek.
