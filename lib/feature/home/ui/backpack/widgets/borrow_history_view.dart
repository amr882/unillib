import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/borrow_model.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/home/logic/user_books_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unilib/feature/home/ui/backpack/widgets/borrow_history_components.dart';

class BorrowHistoryView extends StatefulWidget {
  final String userId;
  const BorrowHistoryView({super.key, required this.userId});

  @override
  State<BorrowHistoryView> createState() => _BorrowHistoryViewState();
}

class _BorrowHistoryViewState extends State<BorrowHistoryView> {
  List<BorrowRecord>? _history;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final provider = context.read<UserBooksProvider>();
    final history = await provider.fetchBorrowHistory(widget.userId);

    if (mounted) {
      setState(() {
        _history = history;
        _isLoading = false;
      });
    }
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.navyCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.navyBorder, width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Clear History',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Are you sure you want to clear your borrowing history? This will only remove completed or cancle records.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSub, fontSize: 13.sp),
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Clear All'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isLoading = true);
      final success = await context
          .read<UserBooksProvider>()
          .clearBorrowHistory(widget.userId);
      if (success) {
        await _fetchHistory();
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _removeIndividualRecord(String borrowId) async {
    final provider = context.read<UserBooksProvider>();
    final success = await provider.deleteBorrowRecord(borrowId);
    if (success && mounted) {
      setState(() {
        _history?.removeWhere((r) => r.borrowId == borrowId);
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

    if (_history == null || _history!.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 64,
            color: AppColors.navy.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
          Text(
            'No history yet',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your borrow activity will appear here.',
            style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms);
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 1.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'History',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              if (_history != null && _history!.isNotEmpty)
                IconButton(
                  onPressed: _clearHistory,
                  icon: const Icon(
                    Icons.delete_rounded,
                    color: AppColors.textLight,
                  ),
                  tooltip: 'Clear history',
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
            itemCount: _history!.length,
            itemBuilder: (context, index) {
              final record = _history![index];
              return BorrowHistoryCard(
                record: record,
                onRemove: () => _removeIndividualRecord(record.borrowId),
              )
                  .animate()
                  .fadeIn(delay: (index * 80).ms)
                  .slideY(begin: 0.1, duration: 400.ms);
            },
          ),
        ),
      ],
    );
  }
}
