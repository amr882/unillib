import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/book_model.dart';

import 'package:unilib/core/theme/app_colors.dart';

class TrendingBookTile extends StatelessWidget {
  final int rank;
  final Book book;
  final Widget? trailingWidget;
  final bool isDark;
  final Color? backgroundColor;

  const TrendingBookTile({
    super.key,
    required this.rank,
    required this.book,
    this.trailingWidget,
    this.isDark = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? AppColors.navyCard : Colors.white),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.navyBorder.withOpacity(0.5) : AppColors.navy.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 19.w,
              height: 13.h,
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
                // Title
                Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.white : AppColors.navy,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 0.3.h),

                // Author
                Text(
                  book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark ? AppColors.textSub : AppColors.textMuted,
                  ),
                ),
                SizedBox(height: 0.8.h),

                // Category chips
                Wrap(
                  spacing: 1.5.w,
                  runSpacing: 0.5.h,
                  children: _buildChips(),
                ),
                SizedBox(height: 0.8.h),

                // Availability
                Container(
                  width: 20.w,
                  padding: EdgeInsets.symmetric(vertical: 1.w),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: book.isAvailable
                        ? const Color(0xffD1F7E9)
                        : const Color(0xffFFDADA),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        book.isAvailable
                            ? Icons.check_circle_outline_rounded
                            : Icons.cancel_outlined,
                        size: 1.8.h,
                        color: book.isAvailable
                            ? const Color(0xFF2E7D32)
                            : Colors.red,
                      ),
                      SizedBox(width: 1.w),

                      Text(
                        book.isAvailable ? 'Available' : 'Borrowed',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: book.isAvailable
                              ? const Color(0xFF2E7D32)
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (trailingWidget != null) ...[
            SizedBox(width: 2.w),
            trailingWidget!,
          ],
        ],
      ),
    );
  }

  List<Widget> _buildChips() {
    final chips = <Widget>[];

    if (book.category != '??') {
      chips.add(_chip(book.category, isDark ? AppColors.gold : AppColors.blue));
    }

    if (book.tags.isNotEmpty) {
      chips.add(_chip(book.tags.first, isDark ? AppColors.textLight : AppColors.navy));
    } else if (book.faculty != '??' && book.category != book.faculty) {
      final label = book.facultySlug != '??' ? book.facultySlug : book.faculty;
      chips.add(_chip(label, isDark ? AppColors.textLight : AppColors.navy));
    }

    return chips;
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
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
