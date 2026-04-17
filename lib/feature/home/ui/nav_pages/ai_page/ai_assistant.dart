import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/home/ui/nav_pages/ai_page/logic/user/generative_ai_provider.dart';
import 'package:unilib/feature/home/ui/nav_pages/ai_page/widgets/ai_history_view.dart';

class AiAssistant extends StatelessWidget {
  const AiAssistant({super.key});

  @override
  Widget build(BuildContext context) {
    final aiProvider = context.watch<GenerativeAiProvider>();

    return Scaffold(
      backgroundColor: AppColors.backGround,
      body: AiHistoryView(aiProvider: aiProvider),
    );
  }
}
