import 'package:flutter/material.dart';
import 'package:unilib/core/model/borrow_model.dart';

class StatusCountdown extends StatelessWidget {
  final BorrowRecord record;

  const StatusCountdown({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    Duration? remaining;
    String prefix = '';

    final isActiveBorrow = record.status == BorrowStatus.activeBorrow;

    if (isActiveBorrow) {
      remaining = record.returnTimeRemaining;
      prefix = 'Return due: ';
    } else if (record.status == BorrowStatus.pendingPickup) {
      remaining = record.pickupTimeRemaining;
      prefix = 'Pickup by: ';
    }

    if (remaining == null) {
      return const SizedBox.shrink();
    }

    final color = _getTimerColor(remaining, isActiveBorrow);
    final icon = _getTimerIcon(remaining);
    final text = '$prefix${_formatDuration(remaining)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d == Duration.zero || d.isNegative) return 'Expired';
    final hours = d.inHours.remainder(24);
    final minutes = d.inMinutes.remainder(60);

    final totalHours = d.inHours;

    if (totalHours >= 24) {
      final displayDays = (totalHours / 24).ceil();
      return '$displayDays days left';
    }
    if (hours > 0) {
      return '${hours}h ${minutes}m left';
    }
    return '${minutes}m left';
  }

  Color _getTimerColor(Duration d, bool isActiveBorrow) {
    if (d.isNegative || d == Duration.zero) return Colors.red.shade900;

    if (isActiveBorrow) {
      if (d.inDays > 7) return Colors.green;
      if (d.inDays >= 3) return Colors.orange;
      return Colors.red;
    } else {
      if (d.inHours < 4) return Colors.red;
      if (d.inHours < 12) return Colors.orange;
      return Colors.green;
    }
  }

  IconData _getTimerIcon(Duration d) {
    if (d.isNegative || d == Duration.zero) return Icons.error_outline_rounded;
    if (d.inDays > 7) return Icons.calendar_today_rounded;
    if (d.inHours < 24) return Icons.schedule_rounded;
    return Icons.timer_outlined;
  }
}
