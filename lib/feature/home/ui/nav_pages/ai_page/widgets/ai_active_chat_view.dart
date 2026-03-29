import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../logic/user/generative_ai_provider.dart';
import 'ai_chat_app_bar.dart';
import 'ai_chat_input_field.dart';
import 'ai_message.dart';
import 'user_message.dart';
import 'typing_indicator.dart';

class AiActiveChatView extends StatefulWidget {
  final GenerativeAiProvider aiProvider;

  const AiActiveChatView({super.key, required this.aiProvider});

  @override
  State<AiActiveChatView> createState() => _AiActiveChatViewState();
}

class _AiActiveChatViewState extends State<AiActiveChatView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    widget.aiProvider.sendMessage(_controller.text);
    _controller.clear();
  }

  String _formatTime(DateTime time) {
    return TimeOfDay.fromDateTime(time).format(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AiChatHeader(
          onBackPressed: () {
            widget.aiProvider.viewHistory();
          },
        ),
        Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            children: [
              if (widget.aiProvider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.aiProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (widget.aiProvider.isLoading) const TypingIndicator(),
              if (widget.aiProvider.messages.isNotEmpty) ...[
                ...widget.aiProvider.messages.reversed.map((msg) {
                  return msg.isUser
                      ? UserMessage(
                          msg: msg.text,
                          timeText: _formatTime(msg.timestamp),
                        )
                      : AiMessage(
                          msg: msg.text,
                          timeText: _formatTime(msg.timestamp),
                          animate:
                              msg.timestamp.compareTo(
                                widget.aiProvider.sessionStartTime,
                              ) >=
                              0,
                        );
                }),
              ] else ...[

                SizedBox(height: 1.5.h),
                AiMessage(
                  msg:
                      "Hello! I'm UniLib AI, your personal Books AI assistant. How can I help you today?",
                  timeText: _formatTime(DateTime.now()),
                  animate: true,
                ),
                SizedBox(height: 2.h),
              ],
            ],
          ),
        ),
        AiChatInputField(
          controller: _controller,
          onSend: _sendMessage,
        ),
      ],
    );
  }
}
