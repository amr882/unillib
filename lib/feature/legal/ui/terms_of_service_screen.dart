import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/core/theme/app_text_styles.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
                _TopBar(title: 'LEGAL'),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Terms of Service',
                          style: AppTextStyles.heading.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
                        SizedBox(height: 1.h),
                        Text(
                          'Last updated: April 2026',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white38,
                            fontWeight: FontWeight.w500,
                          ),
                        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                        SizedBox(height: 4.h),
                        ...[
                          _Section(
                            number: '01',
                            title: 'Acceptance of Terms',
                            content:
                                'By accessing and using UniLib, you agree to be bound by these Terms of Service and all applicable laws and regulations of Benha University.',
                          ),
                          _Section(
                            number: '02',
                            title: 'User Eligibility',
                            content:
                                'This application is exclusively for students and staff of Benha University. You must use your official university credentials to create an account.',
                          ),
                          _Section(
                            number: '03',
                            title: 'User Responsibilities',
                            content:
                                'You are responsible for maintaining the confidentiality of your account and for all activities that occur under your account. You agree to notify us immediately of any unauthorized use.',
                          ),
                          _Section(
                            number: '04',
                            title: 'Intel Property',
                            content:
                                'All content, including books, digital resources, and the application interface, are the property of Benha University or its content suppliers and are protected by copyright laws.',
                          ),
                          _Section(
                            number: '05',
                            title: 'Limitations of Liability',
                            content:
                                'UniLib and Benha University shall not be liable for any damages arising out of the use or inability to use the services provided by this application.',
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

class _Section extends StatelessWidget {
  final String number;
  final String title;
  final String content;

  const _Section({
    required this.number,
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                number,
                style: TextStyle(
                  color: AppColors.gold.withOpacity(0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Monospace',
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 16,
                    color: AppColors.gold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Text(
            content,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white70,
              fontSize: 13.5,
              height: 1.6,
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
            right: -100,
            child: Container(
              width: 400,
              height: 400,
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
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
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
