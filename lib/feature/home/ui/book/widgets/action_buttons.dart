import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/model/borrow_model.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/core/theme/app_text_styles.dart';
import 'package:unilib/feature/home/logic/user_books_provider.dart';
import 'borrow_action_sheet.dart';
import 'success_ticket_dialog.dart';


class ActionButtons extends StatefulWidget {
  final Book book;
  final bool isLoading;
  final BorrowRecord? userBorrowRecord;
  final String studentId;
  final VoidCallback onBorrowTap;

  const ActionButtons({
    super.key,
    required this.book,
    required this.isLoading,
    this.userBorrowRecord,
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
      builder: (sheetContext) => BorrowActionSheet(
        book: widget.book,
        isLoading: false,
        onConfirm: () {
          Navigator.pop(sheetContext);
          widget.onBorrowTap();
        },
      ),
    );
  }

  Future<void> _cancelBorrow() async {
    final confirm = await showGeneralDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      barrierLabel: 'Cancel Borrow',
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, anim, secondaryAnim) => const SizedBox(),
      transitionBuilder: (context, anim, secondaryAnim, child) {
        final scaleAnim = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        final fadeAnim = CurvedAnimation(parent: anim, curve: Curves.easeIn);

        return FadeTransition(
          opacity: fadeAnim,
          child: ScaleTransition(
            scale: scaleAnim,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
              contentPadding: const EdgeInsets.all(24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cancel_rounded, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Cancel Request',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.navy),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Do you want to cancel your pickup request for "${widget.book.title}"?',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('No'),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Yes, Cancel'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (confirm == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cancelling...')),
      );
      final provider = context.read<UserBooksProvider>();
      final success = await provider.cancelPendingBorrow(
        bookId: widget.book.id,
        userId: widget.studentId,
        borrowId: widget.userBorrowRecord!.borrowId,
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request Cancelled'), backgroundColor: Colors.green),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isBorrowed = widget.userBorrowRecord != null;
    final bool isAvailable = widget.book.isAvailable;
    
    Color btnColor = AppColors.gold;
    String btnText = 'Borrow Book';
    IconData btnIcon = Icons.book_rounded;
    bool canTap = !widget.isLoading;
    VoidCallback? onTapAction = canTap ? _showBorrowConfirm : null;

    if (isBorrowed) {
      if (widget.userBorrowRecord!.status == BorrowStatus.pendingPickup) {
        btnColor = Colors.red.shade400;
        btnText = 'Cancel Request';
        btnIcon = Icons.cancel_rounded;
        onTapAction = _cancelBorrow;
      } else {
        btnColor = const Color(0xFFB0BEC5);
        btnText = 'Currently Reading';
        btnIcon = Icons.menu_book_rounded;
        onTapAction = null; // Cannot interact, disabled
      }
    } else if (!isAvailable) {
      btnColor = Colors.grey.withOpacity(0.5);
      btnText = 'Unavailable';
      btnIcon = Icons.block_rounded;
      onTapAction = null;
    }

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTapAction,
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
                          Icon(
                            btnIcon,
                            color: Colors.white,
                            size: 18,
                          ),
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
                  borrowId: widget.userBorrowRecord!.borrowId,
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
              child: const Icon(
                Icons.qr_code_rounded,
                color: AppColors.gold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
