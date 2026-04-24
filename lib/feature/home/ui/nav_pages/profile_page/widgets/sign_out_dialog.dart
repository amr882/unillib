import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/helper/extention.dart';
import 'package:unilib/core/routes/routes.dart';
import 'package:unilib/core/theme/app_colors.dart';

/// User sign-out confirmation dialog with animation.
class SignOutDialog extends StatelessWidget {
  const SignOutDialog({super.key});

  static void show(BuildContext context) {
    showDialog(context: context, builder: (_) => const SignOutDialog());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child:
          Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.navyCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.navyBorder, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                        color: Colors.redAccent,
                        size: 32,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Sign Out',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Are you sure you want to log out of your account?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSub,
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await FirebaseAuth.instance.signOut();
                              if (context.mounted) {
                                context.pushNamedAndRemoveUntil(
                                  Routes.loginScreen,
                                  predicate: (route) => false,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: AppColors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Sign Out',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
              .animate()
              .scale(
                duration: 300.ms,
                curve: Curves.easeOutBack,
                begin: const Offset(0.8, 0.8),
              )
              .fadeIn(duration: 200.ms),
    );
  }
}
