import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/borrow_model.dart';
import 'package:unilib/core/theme/app_colors.dart';

class BorrowHistoryCard extends StatelessWidget {
  final BorrowRecord record;
  final VoidCallback? onRemove;

  const BorrowHistoryCard({super.key, required this.record, this.onRemove});

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
          BorrowTimelineNode(
            label: 'Borrowed',
            date: DateFormat('MMM d, HH:mm').format(record.createdAt),
            isSuccess: true,
            isCompleted: true,
            isFirst: true,
          ),
          BorrowTimelineNode(
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
        BorrowTimelineNode(
          label: 'Borrowed',
          date: DateFormat('MMM d, HH:mm').format(record.createdAt),
          isSuccess: true,
          isCompleted: true,
          isFirst: true,
        ),
        BorrowTimelineNode(
          label: 'Picked Up',
          date: record.pickupConfirmedAt != null
              ? DateFormat('MMM d, HH:mm').format(record.pickupConfirmedAt!)
              : 'Pending',
          isSuccess: hasPickedUp,
          isCompleted: hasPickedUp,
        ),
        BorrowTimelineNode(
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

class BorrowTimelineNode extends StatelessWidget {
  final String label;
  final String date;
  final bool isSuccess;
  final bool isCompleted;
  final bool isFirst;
  final bool isLast;
  final Color? customColor;
  final IconData? customIcon;

  const BorrowTimelineNode({
    super.key,
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
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
