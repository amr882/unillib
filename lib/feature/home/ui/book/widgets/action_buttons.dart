import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/model/borrow_model.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/core/theme/app_text_styles.dart';
import 'borrow_action_sheet.dart';
import 'success_ticket_dialog.dart';

class ActionButtons extends StatefulWidget {
  final Book book;
  final bool isLoading;
  final BorrowRecord? currentBorrow;
  final String studentId;
  final VoidCallback onBorrowTap;

  const ActionButtons({
    super.key,
    required this.book,
    required this.isLoading,
    required this.currentBorrow,
    required this.studentId,
    required this.onBorrowTap,
  });

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  Future<void> _showBorrowConfirm() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BorrowActionSheet(
        book: widget.book,
        isLoading: widget.isLoading,
        onConfirm: widget.onBorrowTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final borrow = widget.currentBorrow;
    final bool isBorrowed = borrow != null;
    final bool isActiveBorrow = borrow?.status == BorrowStatus.activeBorrow;
    final bool isPendingPickup = borrow?.status == BorrowStatus.pendingPickup;
    final bool isAvailable = widget.book.isAvailable;

    // Main button logic
    Color btnColor = AppColors.gold;
    String btnText = 'Borrow Book';
    IconData btnIcon = Icons.book_rounded;
    bool canTap = !widget.isLoading;

    if (isActiveBorrow) {
      btnColor = const Color(0xFFB0BEC5);
      btnText = 'Currently Reading';
      btnIcon = Icons.menu_book_rounded;
      canTap = false; // Cannot cancel, only admin can return
    } else if (isPendingPickup) {
      btnColor = Colors.red.shade400;
      btnText = 'Cancel Request';
      btnIcon = Icons.cancel_outlined;
    } else if (!isAvailable) {
      btnColor = Colors.grey.withOpacity(0.5);
      btnText = 'Unavailable';
      btnIcon = Icons.block_rounded;
      canTap = false;
    }

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: canTap ? _showBorrowConfirm : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              height: 6.5.h,
              decoration: BoxDecoration(
                color: btnColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isBorrowed
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.gold.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        height: 2.5.h,
                        width: 2.5.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(btnIcon, color: Colors.white, size: 18),
                          SizedBox(width: 2.w),
                          Text(
                            btnText,
                            style: AppTextStyles.buttonLabel.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),

        // ── Show QR (Conditional) ───────────────────────────────────
        if (isBorrowed) ...[
          SizedBox(width: 3.w),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                barrierColor: Colors.black87,
                builder: (_) => SuccessTicketDialog(
                  book: widget.book,
                  borrowId: borrow.borrowId,
                ),
              );
            },
            child: Container(
              height: 6.5.h,
              width: 6.5.h,
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.gold.withOpacity(0.3)),
              ),
              child: const Icon(Icons.qr_code_rounded, color: AppColors.gold),
            ),
          ),
        ],
      ],
    );
  }
}
