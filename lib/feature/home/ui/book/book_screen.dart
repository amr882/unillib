// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/logic/user_provider.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/home/logic/book_catalog_provider.dart';
import 'package:unilib/feature/home/logic/user_books_provider.dart';
import 'package:unilib/feature/home/ui/book/widgets/action_buttons.dart';
import 'package:unilib/feature/home/ui/nav_pages/home_page/widgets/small_book_card.dart';
import 'package:unilib/feature/home/ui/book/widgets/details.dart';
import 'package:unilib/feature/home/ui/book/widgets/header.dart';
import 'package:unilib/feature/home/ui/book/widgets/location.dart';
import 'package:unilib/feature/home/ui/book/widgets/tags.dart';

class BookScreen extends StatefulWidget {
  final Book book;
  const BookScreen({super.key, required this.book});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  bool _isLoading = false;
  late bool _alreadyBorrowed;

  late Future<List<Book>> _relatedFuture;

  @override
  void initState() {
    super.initState();
    final userId = context.read<UserProvider>().user?.id ?? '';
    _alreadyBorrowed = widget.book.borrowedBy.contains(userId);

    Future.microtask(() {
      context.read<BookCatalogProvider>().addRecentlyViewed(widget.book.id);
    });

    _relatedFuture = context.read<BookCatalogProvider>().getRelatedBooks(
      widget.book,
    );
  }

  Future<void> _handleBorrow() async {
    final userId = context.read<UserProvider>().user?.id ?? '';
    if (userId.isEmpty) return;

    setState(() => _isLoading = true);

    final success = _alreadyBorrowed
        ? await context.read<UserBooksProvider>().returnBook(
            bookId: widget.book.id,
            userId: userId,
          )
        : await context.read<UserBooksProvider>().borrowBook(
            bookId: widget.book.id,
            userId: userId,
          );

    if (!mounted) return;

    if (success) {
      setState(() {
        _alreadyBorrowed = !_alreadyBorrowed;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success ? AppColors.gold : Colors.redAccent,
        content: Text(
          success
              ? (_alreadyBorrowed ? 'Book borrowed!' : 'Book returned!')
              : context.read<UserBooksProvider>().error ??
                    'Something went wrong.',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: BookHeader(book: widget.book)
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: -0.1, end: 0),
          ),
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
                    _SectionTitle(title: 'About this Resource')
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.1, end: 0),
                    SizedBox(height: 1.h),
                    Text(
                      widget.book.description,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textMuted,
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    BookDetailsRow(book: widget.book),
                    SizedBox(height: 3.h),
                    if (widget.book.tags.isNotEmpty) ...[
                      _SectionTitle(title: 'Tags'),
                      SizedBox(height: 1.h),
                      TagsRow(tags: widget.book.tags),
                      SizedBox(height: 3.h),
                    ],
                    _SectionTitle(title: 'Location'),
                    SizedBox(height: 1.h),
                    LocationCard(book: widget.book),
                    SizedBox(height: 4.h),
                    ActionButtons(
                      book: widget.book,
                      isLoading: _isLoading,
                      alreadyBorrowed: _alreadyBorrowed,
                      onBorrowTap: _handleBorrow,
                    ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.95, 0.95)),
                    SizedBox(height: 4.h),

                    _SectionTitle(title: 'You might also like')
                        .animate()
                        .fadeIn(delay: 600.ms),
                    SizedBox(height: 1.5.h),
                    FutureBuilder<List<Book>>(
                      future: _relatedFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.gold,
                            ),
                          );
                        }
                        if (snapshot.hasError ||
                            !snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Text(
                            'No related resources found.',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12.sp,
                            ),
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
                                      builder: (_) =>
                                          BookScreen(book: relatedBook),
                                    ),
                                  );
                                },
                                child: SmallBookCard(book: relatedBook),
                              ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1, end: 0);
                            },
                          ),
                        );
                      },
                    ),
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
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.navy,
      ),
    );
  }
}
