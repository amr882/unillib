// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/borrow_model.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/home/logic/user_books_provider.dart';
import 'package:unilib/feature/home/ui/nav_pages/profile_page/widgets/borrow_item_card.dart';

class BorrowedBooksSection extends StatefulWidget {
  final String userId;

  const BorrowedBooksSection({super.key, required this.userId});

  @override
  State<BorrowedBooksSection> createState() => _BorrowedBooksSectionState();
}

class _BorrowedBooksSectionState extends State<BorrowedBooksSection> {
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();

    // Tick every minute to update countdown displays
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Borrowed Books',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
        SizedBox(height: 2.h),
        StreamBuilder<List<BorrowRecord>>(
          stream: context.read<UserBooksProvider>().getBorrowRecordsStream(
            widget.userId,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              );
            }

            final records = snapshot.data ?? [];
            if (records.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: Text(
                    "You have not borrowed any books yet",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.length,
              separatorBuilder: (context, index) => SizedBox(height: 2.h),
              itemBuilder: (context, index) {
                final record = records[index];
                return BorrowItemCard(
                  userId: widget.userId,
                  record: record,
                  index: index,
                  isDark: true,
                );
              },
            );
          },
        ),
      ],
    );
  }
}
