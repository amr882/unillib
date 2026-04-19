import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/borrow_model.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/home/logic/user_books_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
              return _HistoryCard(
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

class _HistoryCard extends StatelessWidget {
  final BorrowRecord record;
  final VoidCallback? onRemove;
  const _HistoryCard({required this.record, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  record.bookCoverUrl,
                  width: 45,
                  height: 65,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 45,
                    height: 65,
                    color: Colors.grey[200],
                    child: const Icon(Icons.book, size: 20, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.bookTitle,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          record.bookAuthor,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textMuted,
                          ),
                        ),
                        if (record.status == BorrowStatus.cancelled) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              'Cancelled',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (record.status == BorrowStatus.returned ||
                  record.status == BorrowStatus.cancelled)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: IconButton(
                    onPressed: onRemove,
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20.sp,
                      color: AppColors.textMuted.withOpacity(0.6),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                  ),
                ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildTimeline(),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    if (record.status == BorrowStatus.cancelled) {
      return Row(
        children: [
          _TimelineNode(
            label: 'Borrowed',
            date: DateFormat('MMM d, HH:mm').format(record.createdAt),
            isSuccess: true,
            isCompleted: true,
            isFirst: true,
          ),
          _TimelineNode(
            label: 'Cancelled',
            date: DateFormat(
              'MMM d, HH:mm',
            ).format(record.createdAt), // Or use an updatedAt if available
            isSuccess: false,
            isCompleted: true,
            isLast: true,
            customColor: Colors.red,
            customIcon: Icons.close_rounded,
          ),
        ],
      );
    }

    final hasPickedUp =
        record.status == BorrowStatus.activeBorrow ||
        record.status == BorrowStatus.returned;
    final hasReturned = record.status == BorrowStatus.returned;

    return Row(
      children: [
        _TimelineNode(
          label: 'Borrowed',
          date: DateFormat('MMM d, HH:mm').format(record.createdAt),
          isSuccess: true,
          isCompleted: true,
          isFirst: true,
        ),
        _TimelineNode(
          label: 'Picked Up',
          date: record.pickupConfirmedAt != null
              ? DateFormat('MMM d, HH:mm').format(record.pickupConfirmedAt!)
              : 'Pending',
          isSuccess: hasPickedUp,
          isCompleted: hasPickedUp,
        ),
        _TimelineNode(
          label: 'Returned',
          date: record.returnConfirmedAt != null
              ? DateFormat('MMM d, HH:mm').format(record.returnConfirmedAt!)
              : 'Waiting',
          isSuccess: hasReturned,
          isCompleted: hasReturned,
          isLast: true,
        ),
      ],
    );
  }
}

class _TimelineNode extends StatelessWidget {
  final String label;
  final String date;
  final bool isSuccess;
  final bool isCompleted;
  final bool isFirst;
  final bool isLast;

  final Color? customColor;
  final IconData? customIcon;

  const _TimelineNode({
    required this.label,
    required this.date,
    required this.isSuccess,
    required this.isCompleted,
    this.isFirst = false,
    this.isLast = false,
    this.customColor,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        customColor ?? (isSuccess ? AppColors.gold : Colors.grey.shade300);
    final lineColor = isCompleted ? color : Colors.grey.shade200;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 2,
                  color: isFirst ? Colors.transparent : lineColor,
                ),
              ),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: isCompleted ? color : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: isCompleted
                    ? Icon(
                        customIcon ?? Icons.check,
                        size: 9,
                        color: Colors.white,
                      )
                    : null,
              ),
              Expanded(
                child: Container(
                  height: 2,
                  color: isLast ? Colors.transparent : lineColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: isCompleted ? AppColors.navy : Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            date,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp, // INCREASED
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
