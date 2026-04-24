import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';

class CancelBorrowDialog extends StatelessWidget {
  final String bookTitle;
  final String actionText; // e.g. "cancel your borrow request"

  const CancelBorrowDialog({
    super.key,
    required this.bookTitle,
    this.actionText = 'cancel your borrow request',
  });

  static Future<bool?> show(
    BuildContext context,
    String bookTitle, {
    String? actionText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => CancelBorrowDialog(
        bookTitle: bookTitle,
        actionText: actionText ?? 'cancel your borrow request',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child:
          Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.navyCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.navyBorder, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cancel_rounded,
                        color: Colors.redAccent,
                        size: 32,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Cancel Request',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'You are about to $actionText for "$bookTitle". Do you want to continue?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSub,
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'No, Keep It',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: AppColors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Yes, Cancel',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
              .animate()
              .scale(
                duration: 300.ms,
                curve: Curves.easeOutBack,
                begin: const Offset(0.8, 0.8),
              )
              .fadeIn(duration: 200.ms),
    );
  }
}
