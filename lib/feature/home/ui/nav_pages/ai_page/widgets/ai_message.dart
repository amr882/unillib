import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/home/ui/nav_pages/ai_page/widgets/ai_chat_avatar.dart';

final Set<String> _animatedMessages = {};

class AiMessage extends StatefulWidget {
  final String msg;
  final String timeText;
  final bool animate;

  const AiMessage({
    super.key, 
    required this.msg, 
    this.timeText = "9:32 AM", 
    this.animate = false,
  });

  @override
  State<AiMessage> createState() => _AiMessageState();
}

class _AiMessageState extends State<AiMessage> {
  String _displayedText = "";
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    final messageKey = "${widget.timeText}_${widget.msg.hashCode}";
    if (widget.animate && !_animatedMessages.contains(messageKey)) {
      _animatedMessages.add(messageKey);
      _currentIndex = 0;
      _typeNextCharacter();
    } else {
      _displayedText = widget.msg;
    }
  }

  void _typeNextCharacter() {
    if (!mounted) return;
    if (_currentIndex < widget.msg.length) {
      setState(() {
        _displayedText += widget.msg[_currentIndex];
        _currentIndex++;
      });
      Future.delayed(const Duration(milliseconds: 15), _typeNextCharacter);
    }
  }

  @override
  void didUpdateWidget(AiMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.msg != oldWidget.msg) {
      final messageKey = "${widget.timeText}_${widget.msg.hashCode}";
      if (widget.animate && !_animatedMessages.contains(messageKey)) {
        _animatedMessages.add(messageKey);
        _currentIndex = 0;
        _displayedText = "";
        _typeNextCharacter();
      } else {
        _displayedText = widget.msg;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AiChatAvatar(size: 9.w),
              SizedBox(width: 2.w),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 72.w),
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.2.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bubbleAiBg,
                    border: Border.all(
                      color: AppColors.bubbleAiBorder,
                      width: 0.5,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(18),
                    ),
                  ),
                  child: Text(
                    _displayedText,
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.55,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 0.4.h),
          Padding(
            padding: EdgeInsets.only(left: 10.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.timeText,
                  style: TextStyle(
                    color: AppColors.gold500.withOpacity(0.35),
                    fontSize: 15.sp,
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
