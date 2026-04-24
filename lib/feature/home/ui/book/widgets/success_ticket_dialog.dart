import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/home/ui/book/widgets/metallic_ticket.dart';

class SuccessTicketDialog extends StatefulWidget {
  final Book book;
  final String borrowId;

  const SuccessTicketDialog({super.key, required this.book, required this.borrowId});

  @override
  State<SuccessTicketDialog> createState() => _SuccessTicketDialogState();
}

class _SuccessTicketDialogState extends State<SuccessTicketDialog> {
  double _rotationX = 0;
  double _rotationY = 0;
  late final String _qrData;
  StreamSubscription<DocumentSnapshot>? _statusSubscription;
  String? _initialStatus;

  @override
  void initState() {
    super.initState();
    _qrData = 'UNILIB-BORROW:${widget.borrowId}';

    // Listen to borrow record status changes to auto-pop dialog when scanned by admin
    _statusSubscription = FirebaseFirestore.instance
        .collection('borrows')
        .doc(widget.borrowId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && mounted) {
        final data = snapshot.data();
        final status = data?['status'] as String?;

        if (_initialStatus == null) {
          _initialStatus = status;
        } else if (status != _initialStatus) {
          // Status changed! Close the dialog as it's been processed by admin
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── The Ticket ──────────────────────────────────────────────────
          GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _rotationY += details.delta.dx / 100;
                    _rotationX -= details.delta.dy / 100;

                    // Clamp rotation for realism
                    _rotationX = _rotationX.clamp(-0.2, 0.2);
                    _rotationY = _rotationY.clamp(-0.2, 0.2);
                  });
                },
                onPanEnd: (_) {
                  setState(() {
                    _rotationX = 0;
                    _rotationY = 0;
                  });
                },
                child: Transform(
                  alignment: FractionalOffset.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // perspective
                    ..rotateX(_rotationX)
                    ..rotateY(_rotationY),
                  child: MetallicTicket(book: widget.book, qrData: _qrData),
                ),
              )
              .animate()
              .scale(
                duration: 600.ms,
                curve: Curves.elasticOut,
                begin: const Offset(0.5, 0.5),
              )
              .fadeIn(),

          SizedBox(height: 4.h),

          // ── Actions ─────────────────────────────────────────────────────
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.navy,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Done',
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
            ),
          ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}
