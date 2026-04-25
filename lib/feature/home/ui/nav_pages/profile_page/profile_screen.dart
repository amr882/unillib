import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/logic/user_provider.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/home/ui/nav_pages/profile_page/widgets/profile_avatar_card.dart';
import 'package:unilib/feature/home/ui/nav_pages/profile_page/widgets/profile_info_card.dart';
import 'package:unilib/feature/home/ui/nav_pages/profile_page/widgets/sign_out_dialog.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          // Background Glow Animation
          Positioned(
            top: -10.h,
            right: -10.w,
            child:
                Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: user?.isAdmin ?? false 
                            ? AppColors.gold.withOpacity(0.12) 
                            : AppColors.gold.withOpacity(0.05),
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scale(
                      duration: 5.seconds,
                      begin: const Offset(1, 1),
                      end: const Offset(1.5, 1.5),
                      curve: Curves.easeInOut,
                    )
                    .blur(
                      begin: const Offset(50, 50),
                      end: const Offset(100, 100),
                    ),
          ),
          if (user?.isAdmin ?? false)
            Positioned(
              bottom: 10.h,
              left: -20.w,
              child: Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withOpacity(0.08),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(duration: 7.seconds, begin: const Offset(1, 1), end: const Offset(1.3, 1.3))
              .blur(begin: const Offset(60, 60), end: const Offset(120, 120)),
            ),

          Column(
            children: [
              // Header Gradient with Title
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppColors.backgroundGradient,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5.w, 4.h, 5.w, 3.h),
                    child: Center(
                      child:
                          Text(
                                'My Profile',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                  letterSpacing: 0.3,
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 500.ms)
                              .scale(begin: const Offset(0.9, 0.9)),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileAvatarCard(
                            user: user,
                            isLoading: userProvider.isLoading,
                          )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 600.ms)
                          .slideY(begin: 0.1, end: 0),
                      SizedBox(height: 3.h),
                      ProfileInfoCard(
                            user: user,
                            isLoading: userProvider.isLoading,
                          )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 600.ms)
                          .slideY(begin: 0.1, end: 0),
                      SizedBox(height: 5.h),
                      // Sign Out Button
                      SizedBox(
                            width: double.infinity,
                            height: 6.5.h,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.gold,
                                side: BorderSide(
                                  color: AppColors.gold.withOpacity(0.5),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                SignOutDialog.show(context);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.logout_rounded, size: 20),
                                  SizedBox(width: 2.w),
                                  Text(
                                    "Sign Out",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 600.ms)
                          .scale(begin: const Offset(0.95, 0.95)),
                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
