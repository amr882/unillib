import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/logic/user_provider.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/home/ui/nav_pages/profile_page/widgets/profile_avatar_card.dart';
import 'package:unilib/feature/home/ui/nav_pages/profile_page/widgets/profile_info_card.dart';
import 'package:unilib/feature/home/ui/nav_pages/profile_page/widgets/borrowed_books_section.dart';
import 'package:unilib/core/routes/routes.dart';
import 'package:unilib/core/helper/extention.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    return Scaffold(
      backgroundColor: AppColors.backGround,
      body: Column(
        children: [
          // Header Gradient with Title
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(13),
                bottomRight: Radius.circular(13),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(5.w, 4.h, 5.w, 3.h),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        'My Profile',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                          letterSpacing: 0.3,
                        ),
                      ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9)),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: const Icon(Icons.qr_code_scanner, color: Colors.white54),
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.adminQrScanner);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 5.w,
                vertical: 3.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileAvatarCard(
                    user: user,
                    isLoading: userProvider.isLoading,
                  ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.2, end: 0),
                  SizedBox(height: 3.h),
                  ProfileInfoCard(
                    user: user,
                    isLoading: userProvider.isLoading,
                  ).animate().fadeIn(delay: 250.ms).slideX(begin: 0.2, end: 0),
                  SizedBox(height: 4.h),
                  if (user != null)
                    BorrowedBooksSection(userId: user.id)
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideX(begin: 0.2, end: 0)
                  else
                    const SizedBox.shrink(),
                  SizedBox(height: 5.h),
                  // Sign Out Button
                  SizedBox(
                    width: double.infinity,
                    height: 6.5.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withOpacity(
                          0.1,
                        ),
                        foregroundColor: Colors.redAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.redAccent.withOpacity(0.5),
                          ),
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.transparent,
                            child: Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.navyCard,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: AppColors.navyBorder,
                                  width: 1.5,
                                ),
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
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 1.5.h,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                                            await FirebaseAuth.instance
                                                .signOut();
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
                                            padding: EdgeInsets.symmetric(
                                              vertical: 1.5.h,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                            ).animate().scale(
                                  duration: 300.ms,
                                  curve: Curves.easeOutBack,
                                  begin: const Offset(0.8, 0.8),
                                ).fadeIn(duration: 200.ms),
                          ),
                        );
                      },
                      child: Text(
                        "Sign Out",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                  SizedBox(height: 2.h), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
