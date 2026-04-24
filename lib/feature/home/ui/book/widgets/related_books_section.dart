import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/home/ui/book/book_screen.dart';
import 'package:unilib/feature/home/ui/nav_pages/home_page/widgets/small_book_card.dart';

class RelatedBooksSection extends StatelessWidget {
  final Future<List<Book>> relatedFuture;

  const RelatedBooksSection({super.key, required this.relatedFuture});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'You might also like',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ).animate().fadeIn(delay: 600.ms),
        SizedBox(height: 1.5.h),
        FutureBuilder<List<Book>>(
          future: relatedFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              );
            }
            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return Text(
                'No related resources found.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
              );
            }
            return SizedBox(
              height: 27.h,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final relatedBook = snapshot.data![index];
                  return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookScreen(book: relatedBook),
                            ),
                          );
                        },
                        child: SmallBookCard(book: relatedBook),
                      )
                      .animate()
                      .fadeIn(delay: (index * 100).ms)
                      .slideX(begin: 0.1, end: 0);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
