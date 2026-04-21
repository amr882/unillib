import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/core/helper/extention.dart';

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
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedImage;
  DateTime? _lastAnimatedTimestamp;
  String? _lastSessionId;

  @override
  void initState() {
    super.initState();
    if (widget.aiProvider.messages.isNotEmpty) {
      _lastAnimatedTimestamp = widget.aiProvider.messages.last.timestamp;
    }
    _lastSessionId = widget.aiProvider.activeChatId;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.gold),
                title: const Text('Take a photo', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.gold),
                title: const Text('Choose from gallery', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 70);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = bytes;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty && _selectedImage == null) return;
    widget.aiProvider.sendMessage(_controller.text, imageBytes: _selectedImage);
    _controller.clear();
    setState(() {
      _selectedImage = null;
    });
  }

  String _formatTime(DateTime time) {
    return TimeOfDay.fromDateTime(time).format(context);
  }

  @override
  Widget build(BuildContext context) {
    // Reset animation tracking if we switched chats
    if (_lastSessionId != widget.aiProvider.activeChatId) {
      _lastSessionId = widget.aiProvider.activeChatId;
      _lastAnimatedTimestamp = null;
    }

    return Column(
      children: [
        AiChatHeader(
          onBackPressed: () {
            widget.aiProvider.viewHistory();
            context.pop();
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
                ...widget.aiProvider.messages.reversed.toList().asMap().entries.map((
                  entry,
                ) {
                  final index = entry.key;
                  final msg = entry.value;

                  bool shouldAnimate = false;
                  // Only animate the very last AI message if it hasn't been animated yet
                  if (index == 0 && !msg.isUser) {
                    if (_lastAnimatedTimestamp == null ||
                        msg.timestamp.isAfter(_lastAnimatedTimestamp!)) {
                      shouldAnimate = true;
                      // We'll update the timestamp after this frame to prevent re-animation
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _lastAnimatedTimestamp = msg.timestamp;
                          });
                        }
                      });
                    }
                  }

                  return msg.isUser
                      ? UserMessage(
                          msg: msg.text,
                          timeText: _formatTime(msg.timestamp),
                          tempImage: msg.tempImage,
                        )
                      : AiMessage(
                          msg: msg.text,
                          timeText: _formatTime(msg.timestamp),
                          shouldAnimate: shouldAnimate,
                        );
                }),
              ] else ...[
                SizedBox(height: 1.5.h),
                AiMessage(
                  msg:
                      "Hello! I'm UniLib AI, your personal Books AI assistant. How can I help you today?\n\nأهلاً بك! أنا مساعد UniLib الذكي، كيف يمكنني مساعدتك اليوم؟",
                  timeText: _formatTime(DateTime.now()),
                ),
                SizedBox(height: 2.h),
              ],
            ],
          ),
        ),
        AiChatInputField(
          controller: _controller,
          onSend: _sendMessage,
          onAttachImage: _pickImage,
          onRemoveImage: () => setState(() => _selectedImage = null),
          selectedImage: _selectedImage,
          onStop: () {
            widget.aiProvider.stopGenerating();
          },
          isLoading: widget.aiProvider.isLoading,
        ),
      ],
    );
  }
}
