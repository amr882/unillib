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

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      itemCount: _history!.length,
      itemBuilder: (context, index) {
        final record = _history![index];
        return _HistoryCard(record: record)
            .animate()
            .fadeIn(delay: (index * 80).ms)
            .slideY(begin: 0.1, duration: 400.ms);
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final BorrowRecord record;
  const _HistoryCard({required this.record});

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
                  errorBuilder: (_, __, ___) => Container(
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
                    Text(
                      record.bookAuthor,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
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

  const _TimelineNode({
    required this.label,
    required this.date,
    required this.isSuccess,
    required this.isCompleted,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSuccess ? AppColors.gold : Colors.grey.shade300;
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
                    ? const Icon(Icons.check, size: 9, color: Colors.white)
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
