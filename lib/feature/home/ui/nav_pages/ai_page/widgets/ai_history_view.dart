import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';
import '../logic/user/generative_ai_provider.dart';
import 'ai_chat_app_bar.dart';

class AiHistoryView extends StatelessWidget {
  final GenerativeAiProvider aiProvider;
  
  const AiHistoryView({
    super.key,
    required this.aiProvider,
  });

  String _formatTime(BuildContext context, DateTime time) {
    return TimeOfDay.fromDateTime(time).format(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AiChatHeader(),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            itemCount: aiProvider.chatHistory.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold500,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      aiProvider.startNewChat();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, color: AppColors.navy900),
                        SizedBox(width: 2.w),
                        Text(
                          'Start New Chat',
                          style: TextStyle(
                            color: AppColors.navy900,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final chat = aiProvider.chatHistory[index - 1];
              return Card(
                color: AppColors.navy800,
                elevation: 2,
                margin: EdgeInsets.only(bottom: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.gold500.withOpacity(0.3), width: 0.5),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  title: Text(
                    chat.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Padding(
                    padding: EdgeInsets.only(top: 0.5.h),
                    child: Text(
                      _formatTime(context, chat.updatedAt),
                      style: TextStyle(
                        color: AppColors.textSub,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        onPressed: () => _showDeleteDialog(context, chat.id),
                      ),
                      Icon(Icons.chevron_right, color: AppColors.gold500),
                    ],
                  ),
                  onTap: () {
                    aiProvider.resumeChat(chat.id);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, String chatId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navy800,
        title: Text('Delete Chat?', style: TextStyle(color: AppColors.textLight, fontSize: 16.sp)),
        content: Text('This action cannot be undone.', style: TextStyle(color: AppColors.textSub, fontSize: 12.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSub)),
          ),
          TextButton(
            onPressed: () {
              aiProvider.deleteChat(chatId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
