// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/logic/user_provider.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/home/logic/book_catalog_provider.dart';

import 'package:unilib/feature/home/ui/book/book_screen.dart';
import 'widgets/home_top_card.dart';
import 'widgets/section_header.dart';
import 'widgets/small_book_card.dart';
import 'widgets/trending_book_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<BookCatalogProvider>().fetchTrending();
      context.read<BookCatalogProvider>().fetchRecentlyViewed();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final books = context.watch<BookCatalogProvider>();

    return Scaffold(
      backgroundColor: AppColors.backGround,
      body: Column(
        children: [
          HomeTopCard(
                userName: user != null
                    ? '${user.firstName} ${user.lastName}'.toUpperCase()
                    : '',
                isLoading: context.watch<UserProvider>().isLoading,
              )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.2, end: 0, curve: Curves.easeOutQuad),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: 3.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (books.recentlyViewed.isNotEmpty) ...[
                    SectionHeader(title: 'Recently Viewed'),
                    SizedBox(height: 1.5.h),
                    SizedBox(
                      height: 26.h,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        itemCount: books.recentlyViewed.length,
                        itemBuilder: (context, index) {
                          final book = books.recentlyViewed[index];
                          return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BookScreen(book: book),
                                    ),
                                  );
                                },
                                child: SmallBookCard(book: book),
                              )
                              .animate()
                              .fadeIn(delay: (index * 100).ms, duration: 400.ms)
                              .slideX(begin: 0.2, end: 0);
                        },
                      ),
                    ),
                    SizedBox(height: 3.h),
                  ],

                  SectionHeader(title: 'Trending This Week'),
                  SizedBox(height: 1.5.h),

                  if (books.isLoading)
                    SizedBox(
                      height: 30.h,
                      child: const Center(
                        child: CircularProgressIndicator(color: AppColors.gold),
                      ),
                    )
                  else if (books.error != null)
                    SizedBox(
                      height: 30.h,
                      child: Center(
                        child: Text(
                          'Something went wrong\n${books.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    )
                  else if (books.trending.isEmpty)
                    SizedBox(
                      height: 30.h,
                      child: Center(
                        child: Text(
                          'No trending books yet',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      itemCount: books.trending.length,
                      separatorBuilder: (_, _) => SizedBox(height: 1.5.h),
                      itemBuilder: (context, index) =>
                          GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BookScreen(
                                        book: books.trending[index],
                                      ),
                                    ),
                                  );
                                },
                                child: TrendingBookTile(
                                  rank: index + 1,
                                  book: books.trending[index],
                                ),
                              )
                              .animate()
                              .fadeIn(delay: (index * 100).ms, duration: 400.ms)
                              .slideY(begin: 0.2, end: 0),
                    ),

                  SizedBox(height: 3.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
