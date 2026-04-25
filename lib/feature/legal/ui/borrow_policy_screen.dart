import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/core/theme/app_text_styles.dart';

class BorrowPolicyScreen extends StatelessWidget {
  const BorrowPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          _BackgroundGlow(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBar(title: 'POLICY'),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Borrowing Policy',
                          style: AppTextStyles.heading.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
                        SizedBox(height: 1.h),
                        Text(
                          'Library Regulations & Guidelines',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white38,
                            fontWeight: FontWeight.w500,
                          ),
                        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                        SizedBox(height: 4.h),
                        ...[
                          _PolicyItem(
                            icon: Icons.auto_stories_outlined,
                            title: 'Loan Periods',
                            content:
                                'Students can borrow up to 3 books for a period of 14 days. Faculty members can borrow up to 10 books for 30 days.',
                          ),
                          _PolicyItem(
                            icon: Icons.update_outlined,
                            title: 'Renewals',
                            content:
                                'Books can be renewed once for an additional 7 days, provided there is no pending request from another user.',
                          ),
                          _PolicyItem(
                            icon: Icons.payments_outlined,
                            title: 'Overdue Fines',
                            content:
                                'A fine of 5 EGP per day is charged for each overdue item. Failure to return items may result in suspension of borrowing privileges.',
                          ),
                          _PolicyItem(
                            icon: Icons.gpp_bad_outlined,
                            title: 'Damaged Items',
                            content:
                                'Borrowers are responsible for the condition of the books. Damaged or lost items must be replaced or paid for at full current market value.',
                          ),
                          _PolicyItem(
                            icon: Icons.qr_code_scanner_outlined,
                            title: 'Digital Checkout',
                            content:
                                'All physical books must be checked out and returned using the digital QR code system within the app at the library desk.',
                          ),
                        ]
                            .animate(interval: 100.ms)
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: 0.1, end: 0),
                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _PolicyItem({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.5.h),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gold.withOpacity(0.2), AppColors.gold.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gold.withOpacity(0.2)),
            ),
            child: Icon(icon, color: AppColors.gold, size: 24),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 0.8.h),
                Text(
                  content,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white60,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;

  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: AppTextStyles.subheading.copyWith(
              color: Colors.white38,
              letterSpacing: 2,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.blue.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold.withOpacity(0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
