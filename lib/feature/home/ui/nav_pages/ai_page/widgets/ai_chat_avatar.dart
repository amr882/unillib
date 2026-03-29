import 'package:flutter/material.dart';
import 'package:unilib/core/theme/app_colors.dart';

class AiChatAvatar extends StatelessWidget {
  final double size;

  const AiChatAvatar({super.key, this.size = 48.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.gold500,
                  AppColors.gold400,
                  AppColors.gold100,
                ],
              ),
            ),
            child: Center(
              child: Text(
                '✦',
                style: TextStyle(fontSize: size * 0.45, color: AppColors.white),
              ),
            ),
          ),

          Positioned(
            bottom: 1,
            right: 1,
            child: Container(
              width: size * 0.26,
              height: size * 0.26,
              decoration: BoxDecoration(
                color: AppColors.online,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.navy900, width: 2.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
