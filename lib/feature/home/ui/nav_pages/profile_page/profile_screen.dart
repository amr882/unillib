import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/logic/user_provider.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/home/ui/nav_pages/profile_page/widgets/profile_avatar_card.dart';
import 'package:unilib/feature/home/ui/nav_pages/profile_page/widgets/profile_info_card.dart';
import 'package:unilib/feature/home/ui/nav_pages/profile_page/widgets/borrowed_books_section.dart';

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
                child: Center(
                  child: Text(
                    'My Profile',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: userProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  )
                : user == null
                ? Center(
                    child: Text(
                      "No user data available",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 3.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileAvatarCard(user: user),
                        SizedBox(height: 3.h),
                        ProfileInfoCard(user: user),
                        SizedBox(height: 4.h),
                        BorrowedBooksSection(userId: user.id),
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
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                            },
                            child: Text(
                              "Sign Out",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
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
