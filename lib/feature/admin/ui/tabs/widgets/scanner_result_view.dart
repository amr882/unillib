import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unilib/core/model/borrow_model.dart';
import 'package:unilib/core/model/user_model.dart';
import 'package:unilib/feature/admin/ui/widgets/borrow_detail_card.dart';

/// Shows the scanned QR result with the borrow detail card and action buttons.
class ScannerResultView extends StatelessWidget {
  final BorrowRecord borrow;
  final UserModel? user;
  final bool isProcessing;
  final VoidCallback? onConfirmPickup;
  final VoidCallback? onConfirmReturn;
  final VoidCallback? onReject;

  const ScannerResultView({
    super.key,
    required this.borrow,
    this.user,
    this.isProcessing = false,
    this.onConfirmPickup,
    this.onConfirmReturn,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Success scan indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.qr_code_2_rounded,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'QR Code scanned successfully',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Borrow detail card with actions
          BorrowDetailCard(
            borrow: borrow,
            user: user,
            isProcessing: isProcessing,
            onConfirmPickup: borrow.status == BorrowStatus.pendingPickup
                ? onConfirmPickup
                : null,
            onConfirmReturn: borrow.status == BorrowStatus.activeBorrow
                ? onConfirmReturn
                : null,
            onReject: borrow.status == BorrowStatus.pendingPickup
                ? onReject
                : null,
          ),
        ],
      ),
    );
  }
}
