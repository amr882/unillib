import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:unilib/core/model/borrow_model.dart';
import 'package:unilib/core/model/user_model.dart';
import 'package:unilib/core/theme/app_colors.dart';

class BorrowDetailCard extends StatelessWidget {
  final BorrowRecord borrow;
  final UserModel? user;
  final VoidCallback? onConfirmPickup;
  final VoidCallback? onConfirmReturn;
  final VoidCallback? onReject;
  final VoidCallback? onScanQR;
  final bool isProcessing;

  const BorrowDetailCard({
    super.key,
    required this.borrow,
    this.user,
    this.onConfirmPickup,
    this.onConfirmReturn,
    this.onReject,
    this.onScanQR,
    this.isProcessing = false,
  });

  bool get _isOverdue {
    if (borrow.status != BorrowStatus.activeBorrow) return false;
    if (borrow.pickupConfirmedAt == null) return false;
    final deadline = borrow.pickupConfirmedAt!.add(const Duration(days: 14));
    return DateTime.now().isAfter(deadline);
  }

  String get _statusLabel {
    switch (borrow.status) {
      case BorrowStatus.pendingPickup:
        return 'Pending Pickup';
      case BorrowStatus.activeBorrow:
        return _isOverdue ? 'OVERDUE' : 'Active Borrow';
      case BorrowStatus.returned:
        return 'Returned';
      case BorrowStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get _statusColor {
    switch (borrow.status) {
      case BorrowStatus.pendingPickup:
        return const Color(0xFFF59E0B);
      case BorrowStatus.activeBorrow:
        return _isOverdue ? const Color(0xFFEF4444) : const Color(0xFF3B82F6);
      case BorrowStatus.returned:
        return const Color(0xFF10B981);
      case BorrowStatus.cancelled:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E30),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isOverdue
              ? const Color(0xFFEF4444).withOpacity(0.4)
              : AppColors.navyBorder,
          width: _isOverdue ? 1.5 : 1,
        ),
        boxShadow: [
          if (_isOverdue)
            BoxShadow(
              color: const Color(0xFFEF4444).withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header with status badge ─────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(
              children: [
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isOverdue) ...[
                        const Icon(
                          Icons.warning_rounded,
                          size: 14,
                          color: Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        _statusLabel,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Book info row ────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child:
                      borrow.bookCoverUrl.isNotEmpty &&
                          borrow.bookCoverUrl != '??'
                      ? CachedNetworkImage(
                          imageUrl: borrow.bookCoverUrl,
                          width: 52,
                          height: 72,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Container(
                            width: 52,
                            height: 72,
                            color: AppColors.navyCard,
                            child: const Icon(
                              Icons.menu_book_rounded,
                              color: Colors.white24,
                              size: 20,
                            ),
                          ),
                          errorWidget: (_, _, _) => Container(
                            width: 52,
                            height: 72,
                            color: AppColors.navyCard,
                            child: const Icon(
                              Icons.menu_book_rounded,
                              color: Colors.white24,
                              size: 20,
                            ),
                          ),
                        )
                      : Container(
                          width: 52,
                          height: 72,
                          color: AppColors.navyCard,
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: Colors.white24,
                            size: 20,
                          ),
                        ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        borrow.bookTitle,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        borrow.bookAuthor,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: Colors.white54,
                        ),
                      ),
                      if (_isOverdue && borrow.pickupConfirmedAt != null) ...[
                        const SizedBox(height: 6),
                        _OverdueBanner(
                          deadline: borrow.pickupConfirmedAt!.add(
                            const Duration(days: 14),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── User details section ────────────────────────
          if (user != null) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF081420),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Student',
                    value: user!.fullName,
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user!.email,
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    icon: Icons.badge_outlined,
                    label: 'Student ID',
                    value: user!.studentId,
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    icon: Icons.school_outlined,
                    label: 'Faculty',
                    value: user!.faculty,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // ── Borrow ID & timeline ─────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.qr_code_2_rounded,
                  label: 'Borrow ID',
                  value: borrow.borrowId.length > 16
                      ? '${borrow.borrowId.substring(0, 16)}...'
                      : borrow.borrowId,
                ),
                if (borrow.pickupConfirmedAt != null) ...[
                  const SizedBox(height: 6),
                  _DetailRow(
                    icon: Icons.check_circle_outline,
                    label: 'Picked Up',
                    value: DateFormat(
                      'MMM d, yyyy • HH:mm',
                    ).format(borrow.pickupConfirmedAt!),
                  ),
                ],
                if (borrow.returnConfirmedAt != null) ...[
                  const SizedBox(height: 6),
                  _DetailRow(
                    icon: Icons.assignment_return_outlined,
                    label: 'Returned',
                    value: DateFormat(
                      'MMM d, yyyy • HH:mm',
                    ).format(borrow.returnConfirmedAt!),
                  ),
                ],
              ],
            ),
          ),

          // ── Action buttons ──────────────────────────────
          if (onConfirmPickup != null ||
              onConfirmReturn != null ||
              onReject != null ||
              onScanQR != null) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Row(
                children: [
                  if (onReject != null)
                    Expanded(
                      child: _ActionButton(
                        label: 'Reject',
                        icon: Icons.close_rounded,
                        color: const Color(0xFFEF4444),
                        onTap: isProcessing ? null : onReject,
                      ),
                    ),
                  if (onReject != null &&
                      (onConfirmPickup != null ||
                          onConfirmReturn != null ||
                          onScanQR != null))
                    const SizedBox(width: 12),
                  if (onScanQR != null)
                    Expanded(
                      flex: 2,
                      child: _ActionButton(
                        label: borrow.status == BorrowStatus.activeBorrow
                            ? 'Scan to Return'
                            : 'Scan to Confirm',
                        icon: Icons.qr_code_scanner_rounded,
                        color: AppColors.gold,
                        filled: true,
                        onTap: isProcessing ? null : onScanQR,
                      ),
                    ),
                  if (onConfirmPickup != null)
                    Expanded(
                      flex: 2,
                      child: _ActionButton(
                        label: 'Confirm Pickup',
                        icon: Icons.check_rounded,
                        color: const Color(0xFF10B981),
                        filled: true,
                        onTap: isProcessing ? null : onConfirmPickup,
                      ),
                    ),
                  if (onConfirmReturn != null)
                    Expanded(
                      flex: 2,
                      child: _ActionButton(
                        label: 'Confirm Return',
                        icon: Icons.assignment_return_rounded,
                        color: const Color(0xFF3B82F6),
                        filled: true,
                        onTap: isProcessing ? null : onConfirmReturn,
                      ),
                    ),
                ],
              ),
            ),
          ] else
            const SizedBox(height: 18),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white30),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white38),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _OverdueBanner extends StatelessWidget {
  final DateTime deadline;
  const _OverdueBanner({required this.deadline});

  @override
  Widget build(BuildContext context) {
    final overdueDays = DateTime.now().difference(deadline).inDays;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 14,
            color: Color(0xFFEF4444),
          ),
          const SizedBox(width: 4),
          Text(
            'Overdue by $overdueDays day${overdueDays != 1 ? 's' : ''}',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.filled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: filled ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(onTap != null ? 0.5 : 0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: onTap != null ? color : color.withOpacity(0.4),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: onTap != null ? color : color.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
