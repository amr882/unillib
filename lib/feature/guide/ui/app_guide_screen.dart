import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/core/theme/app_text_styles.dart';

class AppGuideScreen extends StatelessWidget {
  const AppGuideScreen({super.key});

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
                _TopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How to use UniLib',
                          style: AppTextStyles.heading.copyWith(
                            fontSize: 26,
                            color: Colors.white,
                          ),
                        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
                        SizedBox(height: 1.h),
                        Text(
                          'A quick guide to master your digital library',
                          style: AppTextStyles.subheading.copyWith(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                        SizedBox(height: 4.h),
                        _GuideStep(
                          number: '01',
                          title: 'Browse & Search',
                          description:
                              'Explore thousands of books by faculty, title, or author. Use the AI assistant for smart recommendations.',
                          icon: Icons.search_rounded,
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                        _GuideStep(
                          number: '02',
                          title: 'Add to Backpack',
                          description:
                              'Found something you like? Add it to your digital backpack to keep track of books you want to borrow.',
                          icon: Icons.shopping_bag_outlined,
                        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                        _GuideStep(
                          number: '03',
                          title: 'Digital Checkout',
                          description:
                              'Ready to borrow? Go to the library desk and show your digital QR code to the librarian.',
                          icon: Icons.qr_code_scanner_rounded,
                        ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),
                        _GuideStep(
                          number: '04',
                          title: 'Manage Profile',
                          description:
                              'Keep track of your borrowed books, renewal dates, and account status in your profile.',
                          icon: Icons.person_outline_rounded,
                        ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.1),
                        SizedBox(height: 4.h),
                        _StartButton(),
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

class _GuideStep extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final IconData icon;

  const _GuideStep({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
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
            child: Icon(icon, color: AppColors.gold, size: 28),
          ),
          SizedBox(width: 5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      number,
                      style: TextStyle(
                        color: AppColors.gold.withOpacity(0.3),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Monospace',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  description,
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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
                Icons.close_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'USER GUIDE',
            style: AppTextStyles.subheading.copyWith(
              color: Colors.white38,
              letterSpacing: 2,
              fontSize: 10,
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

class _StartButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: double.infinity,
        height: 6.5.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.gold, Color(0xFFC5A059)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'GET STARTED',
            style: AppTextStyles.heading.copyWith(
              color: AppColors.navy,
              fontSize: 16,
              letterSpacing: 1.5,
            ),
          ),
        ),
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
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
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
        ],
      ),
    );
  }
}
