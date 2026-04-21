import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/home/logic/book_catalog_provider.dart';
import 'package:unilib/feature/home/ui/book/book_screen.dart';
import 'package:unilib/feature/home/ui/nav_pages/ai_page/widgets/ai_chat_avatar.dart';
import 'package:unilib/feature/home/ui/nav_pages/home_page/widgets/small_book_card.dart';


class AiMessage extends StatefulWidget {
  final String msg;
  final String timeText;
  final bool shouldAnimate;

  const AiMessage({
    super.key, 
    required this.msg, 
    this.timeText = "9:32 AM", 
    this.shouldAnimate = false,
  });

  @override
  State<AiMessage> createState() => _AiMessageState();
}

class _AiMessageState extends State<AiMessage> {
  String _displayedText = "";
  String _cleanMsg = "";
  List<Book> _suggestedBooks = [];
  bool _isFetchingBooks = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _prepareMessage();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }

  void _prepareMessage() {
    final bookIdRegex = RegExp(r'\[BOOK:\s*(.+?)\]');
    final matches = bookIdRegex.allMatches(widget.msg);
    final bookIds = matches.map((m) => m.group(1)!.trim()).toList();
    _cleanMsg = widget.msg.replaceAll(bookIdRegex, '').trim();

    if (bookIds.isNotEmpty) {
      _fetchBooks(bookIds);
    }

    if (widget.shouldAnimate) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) _startTypingAnimation();
      });
    } else {
      _displayedText = _cleanMsg;
    }
  }

  void _startTypingAnimation() {
    _typingTimer?.cancel();
    _displayedText = "";
    int index = 0;
    
    final int maxAnimationMs = 2000;
    final int tickMs = 15;
    
    final chars = _cleanMsg.characters;
    final int totalLength = chars.length;
    
    int charsPerTick = 1;
    if (totalLength * tickMs > maxAnimationMs) {
      charsPerTick = (totalLength * tickMs / maxAnimationMs).ceil();
    }
    
    _typingTimer = Timer.periodic(Duration(milliseconds: tickMs), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (index < totalLength) {
        int endIndex = index + charsPerTick;
        if (endIndex > totalLength) endIndex = totalLength;
        
        setState(() {
          _displayedText = chars.take(endIndex).toString();
        });
        index = endIndex;
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _fetchBooks(List<String> ids) async {
    if (!mounted) return;
    setState(() => _isFetchingBooks = true);
    
    List<Book> books = [];
    final provider = context.read<BookCatalogProvider>();
    
    for (final id in ids) {
      final book = await provider.fetchBookById(id);
      if (book != null) books.add(book);
    }

    if (mounted) {
      setState(() {
        _suggestedBooks = books;
        _isFetchingBooks = false;
      });
    }
  }

  @override
  void didUpdateWidget(AiMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.msg != oldWidget.msg) {
      _typingTimer?.cancel();
      _suggestedBooks = [];
      _prepareMessage();
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
                    textAlign: TextAlign.start,
                    textDirection: _displayedText.trim().startsWith(RegExp(r'[\u0600-\u06FF]')) ? TextDirection.rtl : TextDirection.ltr,
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
            padding: EdgeInsets.only(left: 10.w, top: 0.5.h),
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

          if (_isFetchingBooks)
            Padding(
              padding: EdgeInsets.only(left: 10.w, top: 1.5.h),
              child: SizedBox(
                height: 28.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 2,
                  itemBuilder: (context, index) => Container(
                    width: 35.w,
                    margin: EdgeInsets.only(right: 4.w),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ).animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 1200.ms, color: AppColors.white.withOpacity(0.1)),
                ),
              ),
            )
          else if (_suggestedBooks.isNotEmpty)
            Container(
              height: 28.h,
              margin: EdgeInsets.only(top: 1.5.h, left: 10.w),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _suggestedBooks.length,
                itemBuilder: (context, index) {
                  final book = _suggestedBooks[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookScreen(book: book),
                        ),
                      );
                    },
                    child: SmallBookCard(
                      book: book,
                      titleColor: Colors.white,
                      authorColor: Colors.white,
                      titleFontSize: 14.sp,
                      authorFontSize: 13.sp,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
