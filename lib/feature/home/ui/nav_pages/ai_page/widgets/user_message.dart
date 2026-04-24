import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';

class UserMessage extends StatelessWidget {
  final String msg;
  final String timeText;
  final Uint8List? tempImage;

  const UserMessage({
    super.key,
    required this.msg,
    this.timeText = "9:34 AM",
    this.tempImage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 72.w),
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.2.h,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.gold500, AppColors.gold200],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (tempImage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: 30.h,
                                maxWidth: 65.w,
                              ),
                              child: Image.memory(
                                tempImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      if (msg.isNotEmpty)
                        Text(
                          msg,
                          textAlign: TextAlign.start,
                          textDirection:
                              msg.trim().startsWith(RegExp(r'[\u0600-\u06FF]'))
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          style: TextStyle(
                            color: AppColors.navy900,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            height: 1.55,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 2.w),
            ],
          ),
          SizedBox(height: 0.4.h),
          Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  timeText,
                  style: TextStyle(color: AppColors.white, fontSize: 15.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
