import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/home/ui/book/widgets/action_buttons.dart';
import 'package:unilib/feature/home/ui/book/widgets/details.dart';
import 'package:unilib/feature/home/ui/book/widgets/header.dart';
import 'package:unilib/feature/home/ui/book/widgets/location.dart';
import 'package:unilib/feature/home/ui/book/widgets/tags.dart';

class BookScreen extends StatelessWidget {
  final Book book;
  const BookScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero Header ────────────────────────────────
          SliverToBoxAdapter(child: BookHeader(book: book)),

          // ── White Body ─────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(5.w, 3.h, 5.w, 4.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // About
                    _SectionTitle(title: 'About this Resource'),
                    SizedBox(height: 1.h),
                    Text(
                      book.description,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textMuted,
                        height: 1.6,
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Details row
                    BookDetailsRow(book: book),

                    SizedBox(height: 3.h),

                    // Tags
                    if (book.tags.isNotEmpty) ...[
                      _SectionTitle(title: 'Tags'),
                      SizedBox(height: 1.h),
                      TagsRow(tags: book.tags),
                      SizedBox(height: 3.h),
                    ],

                    // Location
                    _SectionTitle(title: 'Location'),
                    SizedBox(height: 1.h),
                    LocationCard(book: book),

                    SizedBox(height: 4.h),

                    // Action buttons
                    ActionButtons(book: book),

                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.navy,
      ),
    );
  }
}
