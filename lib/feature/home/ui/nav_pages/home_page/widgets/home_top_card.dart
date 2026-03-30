import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'home_welcome_header.dart';
import 'home_search_bar.dart';

class HomeTopCard extends StatelessWidget {
  final String userName;
  final bool isLoading;

  const HomeTopCard({
    super.key,
    required this.userName,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 3.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeWelcomeHeader(
                userName: userName,
                isLoading: isLoading,
              ),
              SizedBox(height: 2.h),
              const HomeSearchBar(),
            ],
          ),
        ),
      ),
    );
  }
}
