import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';

class AiChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onStop;
  final bool isLoading;
  final Uint8List? selectedImage;
  final VoidCallback onAttachImage;
  final VoidCallback onRemoveImage;

  const AiChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onAttachImage,
    required this.onRemoveImage,
    this.selectedImage,
    this.onStop,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 3.w,
        right: 3.w,
        top: 1.5.h,
        bottom: MediaQuery.of(context).padding.bottom + 1.5.h,
      ),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Camera button
          GestureDetector(
            onTap: onAttachImage,
            child: Container(
              width: 12.w,
              height: 12.w,
              margin: EdgeInsets.only(bottom: 0.5.h),
              decoration: BoxDecoration(
                color: AppColors.navy900.withOpacity(0.5),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold100.withOpacity(0.3)),
              ),
              child: Icon(Icons.camera_alt_rounded, color: AppColors.gold100, size: 20.sp),
            ),
          ),
          SizedBox(width: 2.w),

          // Text field and Optional Image Thumbnail
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, value, child) {
                final isArabic = value.text.trim().startsWith(RegExp(r'[\u0600-\u06FF]'));
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.gold500.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.gold500.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedImage != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  selectedImage!,
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: -5,
                                right: -5,
                                child: IconButton(
                                  icon: const Icon(Icons.cancel, color: Colors.white, size: 20),
                                  onPressed: onRemoveImage,
                                ),
                              ),
                            ],
                          ),
                        ),
                      TextField(
                        cursorColor: AppColors.white,
                        controller: controller,
                        onSubmitted: (_) => isLoading ? onStop?.call() : onSend(),
                        style: TextStyle(color: AppColors.textLight, fontSize: 16.sp),
                        maxLines: 4,
                        minLines: 1,
                        textAlign: TextAlign.start,
                        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                        decoration: InputDecoration(
                          hintText: 'Ask UniLib AI...',
                          hintStyle: TextStyle(
                            color: AppColors.gold100.withOpacity(0.5),
                            fontSize: 16.sp,
                          ),
                          border: OutlineInputBorder(borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 1.2.h,
                            horizontal: 1.2.w,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(width: 2.w),

          // Send/Stop button
          GestureDetector(
            onTap: isLoading ? onStop : onSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 13.w,
              height: 13.w,
              margin: EdgeInsets.only(bottom: 0.5.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: isLoading 
                    ? [Colors.redAccent.withOpacity(0.8), Colors.red.withOpacity(0.6)]
                    : [AppColors.gold400, AppColors.gold100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isLoading ? Colors.red.withOpacity(0.2) : AppColors.navyInput,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  isLoading ? Icons.stop_rounded : Icons.send_rounded,
                  color: AppColors.white,
                  size: 6.5.w,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Playfair Display (serif) — used for the AI assistant name "UniLib AI" in the header. It gives that luxury, editorial feel that pairs well with the gold theme.
// DM Sans — used for all the body text, messages, timestamps, chips, and input placeholder. It's a clean, modern geometric sans-serif that keeps things readable and sleek.
