import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/home/ui/nav_pages/ai_page/widgets/ai_chat_avatar.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _typingController;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _dotAnimations = List.generate(3, (i) {
      return Tween<double>(begin: 0, end: -5).animate(
        CurvedAnimation(
          parent: _typingController,
          curve: Interval(i * 0.2, 0.6 + i * 0.2, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _typingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AiChatAvatar(size: 7.5.w),
          SizedBox(width: 2.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
            decoration: BoxDecoration(
              color: AppColors.bubbleAiBg,
              border: Border.all(color: AppColors.bubbleAiBorder, width: 0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: AnimatedBuilder(
              animation: _typingController,
              builder: (context, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    return Transform.translate(
                      offset: Offset(0, _dotAnimations[i].value),
                      child: Container(
                        width: 2.w,
                        height: 2.w,
                        margin: EdgeInsets.symmetric(horizontal: 0.8.w),
                        decoration: BoxDecoration(
                          color: AppColors.gold500.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
