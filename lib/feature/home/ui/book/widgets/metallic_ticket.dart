import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/theme/app_colors.dart';

class MetallicTicket extends StatelessWidget {
  final Book book;
  final String qrData;

  const MetallicTicket({super.key, required this.book, required this.qrData});

  @override
  Widget build(BuildContext context) {
    final dueDate = DateTime.now().add(const Duration(days: 14));
    final months = [
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
    final dueString = '${months[dueDate.month - 1]} ${dueDate.day}';

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
                            TicketMeta(
                              label: 'ID',
                              value:
                                  '#${book.id.substring(0, 5).toUpperCase()}',
                            ),
                            SizedBox(width: 8.w),
                            TicketMeta(label: 'DUE', value: dueString),
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

class TicketMeta extends StatelessWidget {
  final String label;
  final String value;

  const TicketMeta({super.key, required this.label, required this.value});

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
