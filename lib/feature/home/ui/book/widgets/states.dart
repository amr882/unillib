import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/theme/app_colors.dart';

class StatsRow extends StatelessWidget {
  final Book book;
  const StatsRow({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StatItem(value: book.totalCopies.toString(), label: 'Copies'),
        _Divider(),
        _StatItem(value: book.year, label: 'Edition'),
        _Divider(),
        _StatItem(value: book.language, label: 'Language'),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 0.3.h),
        Text(
          label,
          style: TextStyle(fontSize: 15.sp, color: AppColors.textSub),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 1,
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      color: Colors.white.withOpacity(0.2),
    );
  }
}
