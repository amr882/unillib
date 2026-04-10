import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'slide_to_act.dart';

String _formatDueDate(DateTime date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final day = date.day;
  String suffix = 'th';
  if (day == 1 || day == 21 || day == 31) suffix = 'st';
  if (day == 2 || day == 22) suffix = 'nd';
  if (day == 3 || day == 23) suffix = 'rd';
  return '${months[date.month - 1]} $day$suffix';
}

class BorrowActionSheet extends StatelessWidget {
  final Book book;
  final VoidCallback onConfirm;
  final bool isLoading;

  const BorrowActionSheet({
    super.key,
    required this.book,
    required this.onConfirm,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          border: Border.all(color: Colors.white.withOpacity(0.35)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.navy.withAlpha(50),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            SizedBox(height: 3.h),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.auto_stories_rounded, color: AppColors.gold),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resource Borrowing',
                        style: TextStyle(
                          fontSize: 11.sp,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                        ),
                      ),
                      Text(
                        book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 4.h),

            // Borrow Info Cards
            Builder(
              builder: (_) {
                final dueDate = DateTime.now().add(const Duration(hours: 48));
                return Row(
                  children: [
                    _InfoCard(
                      icon: Icons.calendar_today_rounded,
                      label: 'Pickup Before',
                      value: _formatDueDate(dueDate),
                    ),
                    SizedBox(width: 3.w),
                    _InfoCard(
                      icon: Icons.timer_outlined,
                      label: 'Time Limit',
                      value: '48 Hours',
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: 5.h),

            // Slide to Borrow
            SlideToAct(
              text: 'Slide to Borrow',
              isLoading: isLoading,
              onConfirm: onConfirm,
            ),

            SizedBox(height: 2.h),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel Request',
                  style: TextStyle(
                    color: AppColors.navy.withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.navy.withOpacity(0.04),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.navy.withOpacity(0.08)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.navy.withOpacity(0.6), size: 20),
            SizedBox(height: 1.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.sp,
                color: AppColors.navy.withOpacity(0.4),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.navy,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
