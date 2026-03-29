// widgets/browse_book_tile.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/theme/app_colors.dart';

class BrowseBookTile extends StatelessWidget {
  final Book book;
  const BrowseBookTile({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
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
              width: 16.w,
              height: 11.h,
              child: book.coverUrl != '??'
                  ? CachedNetworkImage(
                      imageUrl: book.coverUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => _fallback(),
                    )
                  : _fallback(),
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
                    color: AppColors.navy,
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
                    color: AppColors.textMuted,
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
                Row(
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
                      book.isAvailable ? 'Available' : 'Unavailable',
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChips() {
    final chips = <Widget>[];

    // Category chip
    if (book.category != '??') {
      chips.add(_chip(book.category, AppColors.blue));
    }

    // First tag as second chip (if available)
    if (book.tags.isNotEmpty) {
      chips.add(_chip(book.tags.first, AppColors.navy));
    } else if (book.faculty != '??' && book.category != book.faculty) {
      // Fallback: use faculty slug or short faculty name
      final label = book.facultySlug != '??' ? book.facultySlug : book.faculty;
      chips.add(_chip(label, AppColors.navy));
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

  Widget _fallback() {
    return Container(
      color: AppColors.navyCard,
      child: const Icon(Icons.menu_book_rounded, color: AppColors.textMuted),
    );
  }
}
