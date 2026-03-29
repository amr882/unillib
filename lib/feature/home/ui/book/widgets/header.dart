import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/home/ui/book/widgets/states.dart';

class BookHeader extends StatelessWidget {
  final Book book;
  const BookHeader({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: SafeArea(
        child: Column(
          children: [
            // Back button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 1.h),

            // cover, title, author, stats
            Container(
              height: 20.h,
              width: 30.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: book.coverUrl != '??'
                    ? Image.network(
                        book.coverUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          final total = loadingProgress.expectedTotalBytes;
                          final loaded = loadingProgress.cumulativeBytesLoaded;
                          return Container(
                            color: AppColors.navyCard,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: total != null ? loaded / total : null,
                                color: AppColors.gold,
                                strokeWidth: 2.5,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, _, _) => _CoverFallback(),
                      )
                    : _CoverFallback(),
              ),
            ),

            SizedBox(height: 2.h),

            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                book.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.3,
                  letterSpacing: 0.2,
                ),
              ),
            ),

            SizedBox(height: 0.8.h),

            // Author
            Text(
              book.author,
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.gold,
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: 2.h),

            // Stats row
            StatsRow(book: book),

            SizedBox(height: 3.h),
          ],
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
