import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/theme/app_colors.dart';

class SuccessTicketDialog extends StatefulWidget {
  final Book book;
  final String borrowId;

  const SuccessTicketDialog({
    super.key,
    required this.book,
    required this.borrowId,
  });

  @override
  State<SuccessTicketDialog> createState() => _SuccessTicketDialogState();
}

class _SuccessTicketDialogState extends State<SuccessTicketDialog> {
  double _rotationX = 0;
  double _rotationY = 0;
  late final String _qrData;
  late final String _dueDate;

  @override
  void initState() {
    super.initState();
    _qrData = 'UNILIB-BORROW:${widget.borrowId}';

    final due = DateTime.now().add(const Duration(hours: 48));
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    _dueDate = '${months[due.month - 1]} ${due.day}';
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
                  child: _MetallicTicket(
                    book: widget.book,
                    qrData: _qrData,
                    dueDate: _dueDate,
                  ),
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

class _MetallicTicket extends StatelessWidget {
  final Book book;
  final String qrData;
  final String dueDate;

  const _MetallicTicket({
    required this.book,
    required this.qrData,
    required this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85.w,
      height: 55.h,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // ── Background ────────────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E2A38), Color(0xFF0C1B2E)],
                ),
              ),
            ),

            // ── Metallic Shimmer Layer ────────────────────────────────────
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: AppColors.gold,
                  period: const Duration(seconds: 3),
                  child: Container(color: Colors.white),
                ),
              ),
            ),

            // ── Content ───────────────────────────────────────────────────
            Column(
              children: [
                // Top section (Book Info)
                Container(
                  padding: EdgeInsets.all(6.w),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.gold.withAlpha(80),
                          ),
                        ),
                        child: Text(
                          'OFFICIAL BORROW PASS',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        book.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        book.author,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                // Dashed separator
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Row(
                    children: List.generate(
                      15,
                      (index) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 1.5,
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom section (QR & Meta)
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withOpacity(0.15),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: 35.w,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: AppColors.navy,
                            ),
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _TicketMeta(
                              label: 'ID',
                              value:
                                  '#${book.id.substring(0, 5).toUpperCase()}',
                            ),
                            SizedBox(width: 8.w),
                            _TicketMeta(label: 'DUE', value: dueDate),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketMeta extends StatelessWidget {
  final String label;
  final String value;

  const _TicketMeta({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white38,
            fontSize: 9.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.gold,
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
