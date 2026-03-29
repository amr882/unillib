import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/core/theme/app_text_styles.dart';
import 'package:unilib/feature/home/ui/nav_pages/ai_page/logic/generative_ai.dart';
import 'package:unilib/feature/home/ui/nav_pages/ai_page/widgets/ai_message.dart';
import 'package:unilib/feature/home/ui/nav_pages/ai_page/widgets/user_message.dart';

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
        title: const Text('Analyze Document', style: TextStyle(color: AppColors.navy)),
        content: TextField(
          controller: docIdController,
          decoration: const InputDecoration(hintText: 'Enter Firestore Document ID'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSub)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
            onPressed: () {
              Navigator.pop(context);
              _analyzeDocument(docIdController.text);
            },
            child: const Text('Analyze', style: TextStyle(color: AppColors.white)),
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
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiProvider = context.watch<GenerativeAiProvider>();

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
                    'AI Assistant',
                    style: TextStyle(
                      fontFamily: 'Georgia',
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
          if (aiProvider.messages.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  "How can I help you today?",
                  style: AppTextStyles.heading,
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                itemCount: aiProvider.messages.length,
                itemBuilder: (context, index) {
                  final msg = aiProvider.messages[index];
                  return msg.isUser
                      ? UserMessage(msg: msg.text)
                      : AiMessage(msg: msg.text);
                },
              ),
            ),
          if (aiProvider.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: AppColors.gold),
            ),
          if (aiProvider.errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                aiProvider.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: AppColors.navy),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.white,
                      hintText: 'Ask AI...',
                      hintStyle: const TextStyle(color: AppColors.textSub),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 14.0,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.navy,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.description, color: AppColors.white, size: 20),
                    onPressed: _showAnalyzeDialog,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: AppColors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
