import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/borrow_model.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/home/logic/user_books_provider.dart';
import 'package:unilib/feature/home/ui/nav_pages/profile_page/widgets/borrow_item_card.dart';

class BorrowedBooksSheet extends StatefulWidget {
  final String userId;
  final ScrollController? scrollController;

  const BorrowedBooksSheet({
    super.key,
    required this.userId,
    this.scrollController,
  });

  @override
  State<BorrowedBooksSheet> createState() => _BorrowedBooksSheetState();
}

class _BorrowedBooksSheetState extends State<BorrowedBooksSheet> {
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();

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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          Expanded(
            child: StreamBuilder<List<BorrowRecord>>(
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
                  return _buildEmptyState();
                }

                return ListView.separated(
                  controller: widget.scrollController,
                  padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 4.h),
                  itemCount: records.length,
                  separatorBuilder: (context, index) => SizedBox(height: 2.h),
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return BorrowItemCard(
                      userId: widget.userId,
                      record: record,
                      index: index,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.navy.withOpacity(0.12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Backpack',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: AppColors.navy),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Your currently borrowed and reserved books.',
            style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted),
          ),
          SizedBox(height: 1.h),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      controller: widget.scrollController,
      children: [
        SizedBox(height: 10.h),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_stories_outlined,
                size: 60,
                color: AppColors.gold.withOpacity(0.3),
              ),
              SizedBox(height: 2.h),
              Text(
                "Your backpack is empty",
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                "Borrow some books to see them here!",
                style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
