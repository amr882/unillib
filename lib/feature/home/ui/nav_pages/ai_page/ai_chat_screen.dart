import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/home/ui/nav_pages/ai_page/logic/user/generative_ai_provider.dart';
import 'package:unilib/feature/home/ui/nav_pages/ai_page/widgets/ai_active_chat_view.dart';

class AiChatScreen extends StatelessWidget {
  const AiChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final aiProvider = context.watch<GenerativeAiProvider>();

    return Scaffold(
      backgroundColor: AppColors.navy900,
      body: Stack(
        children: [
          // Ambient gold glow at top (keeping it for the dark theme chat)
          Positioned(
            top: -8.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gold500.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(child: AiActiveChatView(aiProvider: aiProvider)),
        ],
      ),
    );
  }
}
