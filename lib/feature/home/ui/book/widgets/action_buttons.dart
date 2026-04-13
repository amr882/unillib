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
  final VoidCallback? onRefreshRequested;

  const ActionButtons({
    super.key,
    required this.book,
    required this.isLoading,
    this.userBorrowRecord,
    required this.studentId,
    required this.onBorrowTap,
    this.onRefreshRequested,
  });

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  bool _isCancelling = false;

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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cancel_rounded,
                      color: Colors.red,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cancel Request',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Do you want to cancel your\npickup request for "${widget.book.title}"?\nDo you want to continue?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: AppColors.navy.withOpacity(0.25),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                          ),
                          child: const Text(
                            'No, Keep It',
                            style: TextStyle(color: AppColors.navy),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Yes, Cancel',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
      setState(() => _isCancelling = true);
      
      final provider = context.read<UserBooksProvider>();
      final success = await provider.cancelPendingBorrow(
        bookId: widget.book.id,
        userId: widget.studentId,
        borrowId: widget.userBorrowRecord!.borrowId,
      );

      if (mounted) {
        setState(() => _isCancelling = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Cancel successfully'),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          // Notify parent to refresh data
          widget.onRefreshRequested?.call();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Failed to cancel request'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
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
    bool canTap = !widget.isLoading && !_isCancelling;
    VoidCallback? onTapAction = canTap ? _showBorrowConfirm : null;

    if (isBorrowed) {
      if (widget.userBorrowRecord!.status == BorrowStatus.pendingPickup) {
        btnColor = Colors.red;
        btnText = 'Cancel Request';
        btnIcon = Icons.cancel_rounded;
        onTapAction = canTap ? _cancelBorrow : null;
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
                child: (widget.isLoading || _isCancelling)
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
