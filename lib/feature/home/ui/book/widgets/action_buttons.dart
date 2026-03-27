import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/core/theme/app_text_styles.dart';

class ActionButtons extends StatefulWidget {
  final Book book;
  final bool isLoading;
  final bool alreadyBorrowed;
  final VoidCallback onBorrowTap;

  const ActionButtons({
    super.key,
    required this.book,
    required this.isLoading,
    required this.alreadyBorrowed,
    required this.onBorrowTap,
  });

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _showBorrowConfirm() async {
    _animController.forward(from: 0);

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _BorrowConfirmDialog(
        scaleAnim: _scaleAnim,
        fadeAnim: _fadeAnim,
        bookTitle: widget.book.title,
        alreadyBorrowed: widget.alreadyBorrowed,
      ),
    );

    if (confirmed == true) {
      widget.onBorrowTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isBorrowed = widget.alreadyBorrowed;
    final Color btnColor = isBorrowed
        ? const Color(0xFFB0BEC5)
        : AppColors.gold;
    final bool canTap = !widget.isLoading && !isBorrowed;

    return Column(
      children: [
        GestureDetector(
          onTap: canTap ? _showBorrowConfirm : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            width: double.infinity,
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
                          isBorrowed
                              ? Icons.check_circle_outline_rounded
                              : Icons.book_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          isBorrowed ? 'Already Borrowed' : 'Borrow Book',
                          style: AppTextStyles.buttonLabel.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // ── Bookmark ─────────────────────────────────────
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            height: 6.5.h,
            width: 6.5.h,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.gold.withOpacity(0.3)),
            ),
            child: const Icon(
              Icons.bookmark_border_rounded,
              color: AppColors.gold,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Confirmation Dialog ──────────────────────────────────────────────────────
class _BorrowConfirmDialog extends StatelessWidget {
  final Animation<double> scaleAnim;
  final Animation<double> fadeAnim;
  final String bookTitle;
  final bool alreadyBorrowed;

  const _BorrowConfirmDialog({
    required this.scaleAnim,
    required this.fadeAnim,
    required this.bookTitle,
    required this.alreadyBorrowed,
  });

  @override
  Widget build(BuildContext context) {
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
              // Icon badge
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.book_rounded,
                  color: AppColors.gold,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Confirm Borrow',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'You are about to borrow\n"$bookTitle".\nDo you want to continue?',
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
                        'Cancel',
                        style: TextStyle(color: AppColors.navy),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Borrow',
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
  }
}
