import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/helper/extention.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/core/theme/app_text_styles.dart';
import 'package:unilib/feature/login/ui/widgets/app_input_field.dart';
import 'package:unilib/feature/login/ui/widgets/primary_button.dart';
import 'package:unilib/feature/login/logic/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

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
    super.dispose();
  }

  Future<void> _onSignIn(LoginController controller) async {
    if (!_formKey.currentState!.validate()) return;

    bool success = await controller.login(context);
    if (success && mounted) {
      context.pushNamedAndRemoveUntil('homeScreen', predicate: (_) => false);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Login Failed'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LoginController>();

    return Scaffold(
      backgroundColor: AppColors.navyMid,
      body: Stack(
        children: [
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: SvgPicture.asset(
                            'assets/svgs/logo.svg',
                            height: 20.h,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text('Welcome Back', style: AppTextStyles.heading),
                        SizedBox(height: 1.h),
                        Text(
                          'Sign in to borrow books from\nBenha University Library',
                          style: AppTextStyles.subheading,
                        ),
                        SizedBox(height: 4.h),

                        AppInputField(
                          label: 'University Email',
                          hint: 'student@bu.edu.eg',
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          controller: controller.emailCtrl,
                          validator: controller.validateEmail,
                        ),
                        SizedBox(height: 2.h),

                        AppInputField(
                          label: 'Password',
                          hint: 'Enter your password',
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                          controller: controller.passwordCtrl,
                          validator: controller.validatePassword,
                        ),
                        SizedBox(height: 2.h),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              'Forgot Password?',
                              style: AppTextStyles.link,
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),

                        PrimaryButton(
                          label: 'Sign In',
                          onPressed: () => _onSignIn(controller),
                          isLoading: controller.isLoading,
                        ),
                        SizedBox(height: 2.h),

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
                                onPressed: () =>
                                    context.pushNamed('signupScreen'),
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
}
