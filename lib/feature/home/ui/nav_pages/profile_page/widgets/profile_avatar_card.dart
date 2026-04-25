import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/user_model.dart';
import 'package:unilib/core/theme/app_colors.dart';

class ProfileAvatarCard extends StatelessWidget {
  final UserModel? user;
  final bool isLoading;

  const ProfileAvatarCard({super.key, this.user, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final bool effectivelyLoading = isLoading || user == null;
    final bool isAdmin = user?.isAdmin ?? false;

    return Center(
      child: Container(
        padding: EdgeInsets.all(3.h),
        decoration: BoxDecoration(
          color: AppColors.navyCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: isAdmin
                  ? AppColors.gold.withOpacity(0.1)
                  : Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            effectivelyLoading
                ? Container(
                        width: 10.h,
                        height: 10.h,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.navyInput,
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(
                        duration: 1200.ms,
                        color: AppColors.gold.withOpacity(0.1),
                      )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isAdmin)
                        // Admin Blur Border Thing
                        Container(
                              width: 10.5.h,
                              height: 10.5.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.gold.withOpacity(0.4),
                                    blurRadius: 25,
                                    spreadRadius: 3,
                                  ),
                                  BoxShadow(
                                    color: AppColors.gold.withOpacity(0.2),
                                    blurRadius: 45,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                            )
                            .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true),
                            )
                            .scale(
                              duration: 2.seconds,
                              begin: const Offset(1, 1),
                              end: const Offset(1.15, 1.15),
                              curve: Curves.easeInOut,
                            )
                            .fadeIn(duration: 1.seconds),

                      Container(
                        width: 10.h,
                        height: 10.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              isAdmin
                                  ? AppColors.gold.withOpacity(0.6)
                                  : AppColors.gold.withOpacity(0.4),
                              AppColors.gold.withOpacity(0.1),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withOpacity(0.2),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                          border: Border.all(
                            color: AppColors.gold.withOpacity(
                              isAdmin ? 0.8 : 0.5,
                            ),
                            width: isAdmin ? 3 : 2.5,
                          ),
                        ),
                        child:
                            Icon(
                                  isAdmin
                                      ? Icons.admin_panel_settings_rounded
                                      : Icons.school_rounded,
                                  color: AppColors.gold,
                                  size: 4.5.h,
                                )
                                .animate(
                                  onPlay: (controller) => controller.repeat(),
                                )
                                .shimmer(
                                  duration: isAdmin ? 2000.ms : 2500.ms,
                                  color: Colors.white.withOpacity(0.4),
                                )
                                .scale(
                                  duration: 1500.ms,
                                  begin: const Offset(1, 1),
                                  end: const Offset(1.1, 1.1),
                                  curve: Curves.easeInOut,
                                )
                                .then()
                                .scale(
                                  duration: 1500.ms,
                                  begin: const Offset(1.1, 1.1),
                                  end: const Offset(1, 1),
                                  curve: Curves.easeInOut,
                                )
                                .animate(
                                  onPlay: (controller) => controller.repeat(),
                                )
                                .rotate(
                                  duration: isAdmin ? 4.seconds : 0.ms,
                                  begin: 0,
                                  end: isAdmin ? 0.05 : 0,
                                  curve: Curves.easeInOut,
                                )
                                .then()
                                .rotate(
                                  duration: isAdmin ? 4.seconds : 0.ms,
                                  begin: 0.05,
                                  end: 0,
                                  curve: Curves.easeInOut,
                                ),
                      ),
                    ],
                  ),
            SizedBox(height: 2.h),
            effectivelyLoading
                ? Container(
                        width: 45.w,
                        height: 20.sp,
                        decoration: BoxDecoration(
                          color: AppColors.navyInput,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(
                        duration: 1200.ms,
                        color: AppColors.gold.withOpacity(0.1),
                      )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isAdmin) ...[
                        Icon(
                          Icons.verified_rounded,
                          color: AppColors.gold,
                          size: 18.sp,
                        ).animate().fadeIn(duration: 500.ms).scale(),
                        SizedBox(width: 2.w),
                      ],
                      Text(
                        user!.fullName,
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
            SizedBox(height: 0.8.h),
            effectivelyLoading
                ? Container(
                        width: 35.w,
                        height: 18.sp,
                        decoration: BoxDecoration(
                          color: AppColors.navyInput,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(
                        duration: 1200.ms,
                        color: AppColors.gold.withOpacity(0.1),
                      )
                : Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 0.8.h,
                    ),
                    decoration: BoxDecoration(
                      color: isAdmin
                          ? AppColors.gold.withOpacity(0.15)
                          : AppColors.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.gold.withOpacity(isAdmin ? 0.4 : 0.2),
                      ),
                    ),
                    child: Text(
                      isAdmin ? "Administrator" : user!.email,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.gold.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
