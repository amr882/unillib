import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/core/theme/app_text_styles.dart';
import 'package:unilib/feature/sign_up/logic/signup_controller.dart';
import 'package:unilib/feature/sign_up/ui/account_setup_step.dart';
import 'package:unilib/feature/sign_up/ui/personal_info_step.dart';
import 'package:unilib/feature/sign_up/ui/review_step.dart';
import 'package:unilib/feature/sign_up/ui/widget/step_indicator.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  final _pageCtrl = PageController();

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  static const _stepLabels = ['Personal', 'Account', 'Review'];
  static const _stepTitles = [
    'SIGN UP — STEP 1 / 3 PERSONAL INFO',
    'SIGN UP — STEP 2 / 3 ACCOUNT SETUP',
    'SIGN UP — STEP 3 / 3 ACCOUNT SETUP',
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignupController(),
      child: Consumer<SignupController>(
        builder: (context, ctrl, _) {
          // Sync PageView whenever step changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageCtrl.hasClients && _pageCtrl.page?.round() != ctrl.step) {
              _pageCtrl.animateToPage(
                ctrl.step,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
              );
            }
          });

          return Scaffold(
            backgroundColor: AppColors.navyMid,
            body: Stack(
              children: [
                // ── Ambient glow (same as login) ─────────────
                _BackgroundGlow(),

                SafeArea(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Column(
                        children: [
                          // ── Top bar ────────────────────────
                          _TopBar(
                            title: _stepTitles[ctrl.step],
                            canGoBack: ctrl.step > 0,
                            onBack: ctrl.prevStep,
                          ),

                          // ── Logo ───────────────────────────
                          SvgPicture.asset(
                            'assets/svgs/logo.svg',
                            height: 10.h,
                          ),
                          SizedBox(height: 2.h),

                          // ── Step indicator ─────────────────
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.w),
                            child: StepIndicator(
                              currentStep: ctrl.step,
                              totalSteps: 3,
                              labels: _stepLabels,
                            ),
                          ),
                          SizedBox(height: 3.h),

                          // ── Page content ───────────────────
                          Expanded(
                            child: PageView(
                              controller: _pageCtrl,
                              physics: const NeverScrollableScrollPhysics(),
                              children: const [
                                _StepPage(child: PersonalInfoStep()),
                                _StepPage(child: AccountSetupStep()),
                                _StepPage(child: ReviewStep()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────

class _StepPage extends StatelessWidget {
  final Widget child;
  const _StepPage({required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
      child: child,
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final bool canGoBack;
  final VoidCallback onBack;

  const _TopBar({
    required this.title,
    required this.canGoBack,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          if (canGoBack)
            GestureDetector(
              onTap: onBack,
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Colors.white70,
              ),
            )
          else
            const SizedBox(width: 18),
          const Spacer(),
          Text(
            title,
            style: AppTextStyles.subheading.copyWith(
              color: Colors.white38,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 18),
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
            top: -80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.blue.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.navyMid.withOpacity(0.6),
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
