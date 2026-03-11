import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';

import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/core/theme/app_dimens.dart';
import 'package:unilib/core/theme/app_text_styles.dart';
import 'package:unilib/feature/login/widgets/app_input_field.dart';
import 'package:unilib/feature/login/widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // ── Lifecycle ──────────────────────────────────────────────
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
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────
  Future<void> _onSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyMid,
      body: Stack(
        children: [
          // ── Ambient background glow ──────────────────────
          _BackgroundGlow(),

          // ── Main scroll content ──────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: AppDimens.screenPadding.copyWith(
                    top: 40,
                    bottom: 40,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo
                        Center(
                          child: SvgPicture.asset(
                            'assets/svgs/logo.svg',
                            height: 15.h,
                          ),
                        ),
                        const SizedBox(height: AppDimens.spXL),

                        // Heading
                        Text('Welcome Back', style: AppTextStyles.heading),
                        const SizedBox(height: AppDimens.spXS),
                        Text(
                          'Sign in to borrow books from\nBenha University Library',
                          style: AppTextStyles.subheading,
                        ),
                        const SizedBox(height: AppDimens.spXL),

                        // Email field
                        AppInputField(
                          label: 'University Email',
                          hint: 'student@bu.edu.eg',
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailCtrl,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: AppDimens.spMD),

                        // Password field
                        AppInputField(
                          label: 'Password',
                          hint: 'Enter your password',
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                          controller: _passCtrl,
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: AppDimens.spSM),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: AppTextStyles.link,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimens.spLG),

                        // Sign in button
                        PrimaryButton(
                          label: 'Sign In',
                          onPressed: _onSignIn,
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: AppDimens.spLG),

                        // Sign up row
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: AppTextStyles.bodySmall,
                              ),
                              const SizedBox(width: 4),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Create Account',
                                  style: AppTextStyles.link,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Validators ────────────────────────────────────────────
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    if (!value.contains('@') || !value.contains('bu.edu.eg')) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
}

// ── Private helpers ────────────────────────────────────────────────────────

class _BackgroundGlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Top center glow
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
          // Bottom right glow
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
