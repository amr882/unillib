import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/book_model.dart';

import 'package:unilib/core/theme/app_colors.dart';

class TrendingBookTile extends StatelessWidget {
  final int rank;
  final Book book;

  const TrendingBookTile({super.key, required this.rank, required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 8.w,
            child: Text(
              rank.toString().padLeft(2, '0'),
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.gold,
              ),
            ),
          ),

          // Cover
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              width: 15.w,
              height: 10.5.h,
              child:
                  book.coverUrl.isNotEmpty &&
                      book.coverUrl != '??' &&
                      book.coverUrl != "NO_IMAGE_PLACEHOLDER"
                  ? CachedNetworkImage(
                      imageUrl: book.coverUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => _CoverFallback(),
                    )
                  : _CoverFallback(),
            ),
          ),

          SizedBox(width: 3.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 0.4.h),
                Text(
                  '${book.author} · ${book.category}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted),
                ),
              ],
            ),
          ),

          SizedBox(width: 2.w),

          // Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: book.isAvailable
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              book.isAvailable ? 'Available' : 'Borrowed',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: book.isAvailable ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navyCard,
      child: const Icon(
        Icons.menu_book_rounded,
        color: AppColors.textMuted,
        size: 40,
      ),
    );
  }
}
