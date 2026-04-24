import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/helper/extention.dart';
import 'package:unilib/core/routes/routes.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/core/theme/app_text_styles.dart';
import 'package:unilib/feature/login/ui/widgets/primary_button.dart';
import 'package:unilib/feature/sign_up/logic/signup_controller.dart';
import 'package:unilib/feature/sign_up/ui/widget/review_row.dart';

class ReviewStep extends StatelessWidget {
  const ReviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<SignupController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Almost Done!', style: AppTextStyles.heading),
        SizedBox(height: 1.h),
        Text(
          'Review your details and confirm your account',
          style: AppTextStyles.subheading,
        ),
        SizedBox(height: 3.h),

        // Avatar + name card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppColors.navyCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.navyBorder.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              // Avatar circle
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.gold,
                child: Text(
                  _initials(ctrl),
                  style: AppTextStyles.heading.copyWith(
                    color: AppColors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                '${ctrl.firstNameCtrl.text} ${ctrl.lastNameCtrl.text}',
                style: AppTextStyles.heading.copyWith(fontSize: 16),
              ),
              Text(
                ctrl.emailCtrl.text,
                style: AppTextStyles.inputText.copyWith(color: Colors.white54),
              ),
              SizedBox(height: 2.h),
              const Divider(color: Colors.white10),
              SizedBox(height: 1.h),

              ReviewRow(
                icon: Icons.badge_outlined,
                label: 'Student ID',
                value: ctrl.studentIdCtrl.text,
              ),
              ReviewRow(
                icon: Icons.school_outlined,
                label: 'Faculty',
                value: ctrl.selectedFaculty ?? '',
              ),
              ReviewRow(
                icon: Icons.calendar_today_outlined,
                label: 'Academic Year',
                value: ctrl.selectedYear,
              ),
              ReviewRow(
                icon: Icons.account_balance_outlined,
                label: 'University',
                value: 'Benha University',
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),

        // Terms note
        RichText(
          text: TextSpan(
            style: AppTextStyles.subheading.copyWith(
              color: Colors.white38,
              height: 1.5,
            ),
            children: const [
              TextSpan(text: 'By creating an account you agree to '),
              TextSpan(
                text: 'Terms of Service',
                style: TextStyle(color: Color(0xFF4A9EFF)),
              ),
              TextSpan(text: ' and our '),
              TextSpan(
                text: 'Borrowing Policy',
                style: TextStyle(color: Color(0xFF4A9EFF)),
              ),
              TextSpan(text: ' of Benha University.'),
            ],
          ),
        ),
        SizedBox(height: 3.h),

        // Error message
        if (ctrl.errorMessage != null) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Text(
              ctrl.errorMessage!,
              style: AppTextStyles.subheading.copyWith(color: Colors.redAccent),
            ),
          ),
          SizedBox(height: 2.h),
        ],

        // Create account button
        PrimaryButton(
          label: 'Create My Account',
          onPressed: () async {
            final success = await ctrl.createAccount();
            if (success && context.mounted) {
              context.pushNamedAndRemoveUntil(
                Routes.mainScaffold,
                predicate: (_) => false,
              );
            }
          },
          isLoading: ctrl.isLoading,
        ),
        SizedBox(height: 2.h),

        // Already have an account
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Already have an account?', style: AppTextStyles.bodySmall),
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
    );
  }

  String _initials(SignupController ctrl) {
    final f = ctrl.firstNameCtrl.text;
    final l = ctrl.lastNameCtrl.text;
    return '${f.isNotEmpty ? f[0] : ''}${l.isNotEmpty ? l[0] : ''}'
        .toUpperCase();
  }
}
