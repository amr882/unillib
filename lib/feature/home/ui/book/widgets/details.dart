import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/theme/app_colors.dart';

class BookDetailsRow extends StatelessWidget {
  final Book book;
  const BookDetailsRow({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.navy.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.navy.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          _DetailItem(
            icon: Icons.school_rounded,
            label: 'Faculty',
            value: book.faculty,
          ),
          Divider(color: AppColors.navy.withOpacity(0.08), height: 2.h),
          _DetailItem(
            icon: Icons.category_rounded,
            label: 'Category',
            value: book.category,
          ),
          Divider(color: AppColors.navy.withOpacity(0.08), height: 2.h),
          _DetailItem(icon: Icons.tag_rounded, label: 'ISBN', value: book.isbn),
          Divider(color: AppColors.navy.withOpacity(0.08), height: 2.h),
          _DetailItem(
            icon: book.isAvailable
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            label: 'Availability',
            value: book.isAvailable
                ? '${book.availableCopies} of ${book.totalCopies} available'
                : 'Currently unavailable',
            valueColor: book.isAvailable ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.blue),
        SizedBox(width: 3.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.navy,
            ),
          ),
        ),
      ],
    );
  }
}
