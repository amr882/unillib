import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/borrow_model.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/home/logic/user_books_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unilib/feature/home/ui/nav_pages/profile_page/widgets/borrow_item_card.dart';

class ActiveBorrowsView extends StatefulWidget {
  final String userId;
  const ActiveBorrowsView({super.key, required this.userId});

  @override
  State<ActiveBorrowsView> createState() => _ActiveBorrowsViewState();
}

class _ActiveBorrowsViewState extends State<ActiveBorrowsView> {
  List<BorrowRecord>? _records;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    final provider = context.read<UserBooksProvider>();
    final records = await provider.fetchUserBorrows(widget.userId);

    if (mounted) {
      setState(() {
        _records = records;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      );
    }

    if (_records == null || _records!.isEmpty) {
      return Center(
        child: Text(
          'No active borrows',
          style: TextStyle(fontSize: 14.sp, color: AppColors.textMuted),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 4.h),
      itemCount: _records!.length + 1,
      separatorBuilder: (_, index) =>
          index == 0 ? const SizedBox.shrink() : SizedBox(height: 2.h),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: 2.h, top: 1.h),
            child: Text(
              'Active Borrow',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
                letterSpacing: 0.2,
              ),
            ),
          );
        }

        final recordIndex = index - 1;
        final record = _records![recordIndex];

        return BorrowItemCard(
              userId: widget.userId,
              record: record,
              index: recordIndex,
              onCancel: () {
                setState(() {
                  _records?.removeAt(recordIndex);
                });
              },
            )
            .animate()
            .fadeIn(delay: (index * 100).ms)
            .slideX(begin: 0.1, duration: 400.ms);
      },
    );
  }
}
