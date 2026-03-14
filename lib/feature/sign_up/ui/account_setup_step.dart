import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/helper/extention.dart';
import 'package:unilib/core/theme/app_text_styles.dart';
import 'package:unilib/feature/login/ui/widgets/app_input_field.dart';
import 'package:unilib/feature/login/ui/widgets/primary_button.dart';
import 'package:unilib/feature/sign_up/logic/signup_controller.dart';

class AccountSetupStep extends StatelessWidget {
  const AccountSetupStep({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<SignupController>();

    return Form(
      key: ctrl.formKeyStep1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Account Setup', style: AppTextStyles.heading),
          SizedBox(height: 1.h),
          Text(
            'Create your UniLib login credentials',
            style: AppTextStyles.subheading,
          ),
          SizedBox(height: 3.h),

          // University email
          AppInputField(
            label: 'University Email',
            hint: 'student@bu.edu.eg',
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            controller: ctrl.emailCtrl,
            validator: ctrl.validateEmail,
          ),
          SizedBox(height: 2.h),

          // Password
          AppInputField(
            label: 'Password',
            hint: 'Create a strong password',
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
            controller: ctrl.passwordCtrl,
            validator: ctrl.validatePassword,
          ),
          SizedBox(height: 2.h),

          // Confirm Password
          AppInputField(
            label: 'Confirm Password',
            hint: 'Repeat your password',
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
            controller: ctrl.confirmPasswordCtrl,
            validator: ctrl.validateConfirmPassword,
          ),
          SizedBox(height: 4.h),

          PrimaryButton(
            label: 'Continue →',
            onPressed: () => ctrl.nextStep(),
            isLoading: false,
          ),
          SizedBox(height: 2.h),

          // Already have an account
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Already have an account?',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: () => context.pop(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('Sign In', style: AppTextStyles.link),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
