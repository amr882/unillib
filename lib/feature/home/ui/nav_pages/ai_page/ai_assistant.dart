import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/home/ui/nav_pages/ai_page/logic/generative_ai.dart';
import 'package:unilib/feature/home/ui/nav_pages/ai_page/widgets/ai_message.dart';
import 'package:unilib/feature/home/ui/nav_pages/ai_page/widgets/user_message.dart';
import 'package:unilib/feature/home/ui/nav_pages/ai_page/widgets/ai_chat_app_bar.dart';
import 'package:unilib/feature/home/ui/nav_pages/ai_page/widgets/ai_chat_input_field.dart';
import 'package:unilib/feature/home/ui/nav_pages/ai_page/widgets/typing_indicator.dart';

class AiAssistant extends StatefulWidget {
  const AiAssistant({super.key});

  @override
  State<AiAssistant> createState() => _AiAssistantState();
}

class _AiAssistantState extends State<AiAssistant> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    context.read<GenerativeAiProvider>().sendMessage(_controller.text);
    _controller.clear();
  }

  void _showAnalyzeDialog() {
    final TextEditingController docIdController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Analyze Document',
          style: TextStyle(color: AppColors.navy900),
        ),
        content: TextField(
          controller: docIdController,
          decoration: const InputDecoration(
            hintText: 'Enter Firestore Document ID',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSub),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold500),
            onPressed: () {
              Navigator.pop(context);
              _analyzeDocument(docIdController.text);
            },
            child: const Text(
              'Analyze',
              style: TextStyle(
                color: AppColors.navy900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _analyzeDocument(String docId) async {
    if (docId.trim().isEmpty) return;
    try {
      await context.read<GenerativeAiProvider>().analyzeDocument(docId.trim());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildSuggestionChips() {
    final chips = ['✨ Summarize', '📝 Write', '🔍 Research'];
    return Padding(
      padding: EdgeInsets.only(left: 10.w, bottom: 1.5.h),
      child: Wrap(
        spacing: 2.w,
        children: chips
            .map(
              (label) => Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.7.h),
                decoration: BoxDecoration(
                  color: AppColors.gold500.withOpacity(0.06),
                  border: Border.all(
                    color: AppColors.gold500.withOpacity(0.25),
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppColors.gold500,
                    fontSize: 11.sp,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aiProvider = context.watch<GenerativeAiProvider>();

    return Scaffold(
      backgroundColor: AppColors.navy900,
      body: Stack(
        children: [
          // Ambient gold glow at top
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

          SafeArea(
            child: Column(
              children: [
                const AiChatHeader(),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                    children: [
                      if (aiProvider.messages.isEmpty) ...[
                        SizedBox(height: 2.h),
                        const AiMessage(
                          msg:
                              "Hello! I'm Aura, your personal AI assistant. How can I help you today?",
                          timeText: "Now",
                        ),
                        SizedBox(height: 1.5.h),
                        _buildSuggestionChips(),
                      ] else ...[
                        ...aiProvider.messages.map((msg) {
                          return msg.isUser
                              ? UserMessage(msg: msg.text)
                              : AiMessage(msg: msg.text);
                        }),
                      ],
                      if (aiProvider.isLoading) const TypingIndicator(),
                      if (aiProvider.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            aiProvider.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
                AiChatInputField(
                  controller: _controller,
                  onSend: _sendMessage,
                  onAddPressed: _showAnalyzeDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
