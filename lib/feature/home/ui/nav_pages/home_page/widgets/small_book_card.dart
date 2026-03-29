import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/theme/app_colors.dart';

class SmallBookCard extends StatelessWidget {
  final Book book;

  const SmallBookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 35.w,
      margin: EdgeInsets.only(right: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Image
          Container(
            height: 20.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  book.coverUrl.isNotEmpty &&
                      book.coverUrl != '??' &&
                      book.coverUrl != "NO_IMAGE_PLACEHOLDER"
                  ? CachedNetworkImage(
                      imageUrl: book.coverUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _FallbackCover(),
                      errorWidget: (context, url, error) => _FallbackCover(),
                    )
                  : _FallbackCover(),
            ),
          ),
          SizedBox(height: 1.h),

          // Title
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
              height: 1.2,
            ),
          ),
          SizedBox(height: 0.4.h),

          // Author
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10.sp, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _FallbackCover extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navyCard,
      child: const Center(
        child: Icon(
          Icons.menu_book_rounded,
          color: AppColors.textMuted,
          size: 40,
        ),
      ),
    );
  }
}
