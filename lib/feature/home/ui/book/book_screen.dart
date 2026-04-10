// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/logic/user_provider.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/model/borrow_model.dart';
import 'package:unilib/core/service/notification_service.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/home/logic/book_catalog_provider.dart';
import 'package:unilib/feature/home/logic/user_books_provider.dart';
import 'package:unilib/feature/home/ui/book/widgets/action_buttons.dart';
import 'package:unilib/feature/home/ui/nav_pages/home_page/widgets/small_book_card.dart';
import 'package:unilib/feature/home/ui/book/widgets/details.dart';
import 'package:unilib/feature/home/ui/book/widgets/header.dart';
import 'package:unilib/feature/home/ui/book/widgets/location.dart';
import 'package:unilib/feature/home/ui/book/widgets/tags.dart';
import 'package:unilib/feature/home/ui/book/widgets/success_ticket_dialog.dart';

class BookScreen extends StatefulWidget {
  final Book book;
  const BookScreen({super.key, required this.book});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  bool _isLoading = false;
  BorrowRecord? _currentBorrow;

  late Future<List<Book>> _relatedFuture;

  @override
  void initState() {
    super.initState();
    _fetchCurrentBorrow();

    Future.microtask(() {
      context.read<BookCatalogProvider>().addRecentlyViewed(widget.book.id);
    });

    _relatedFuture = context.read<BookCatalogProvider>().getRelatedBooks(
      widget.book,
    );
  }

  Future<void> _fetchCurrentBorrow() async {
    final userId = context.read<UserProvider>().user?.id ?? '';
    if (userId.isEmpty) return;

    final borrows = await context.read<UserBooksProvider>().fetchUserBorrows(
      userId,
    );
    if (mounted) {
      setState(() {
        _currentBorrow = borrows
            .where((b) => b.bookId == widget.book.id)
            .firstOrNull;
      });
    }
  }

  Future<void> _handleBorrow() async {
    final userProvider = context.read<UserProvider>();
    final userId = userProvider.user?.id ?? '';
    if (userId.isEmpty) return;

    final bool wasBorrowed = _currentBorrow != null;
    setState(() => _isLoading = true);

    if (wasBorrowed) {
      // "Return Book" is no longer user-initiated in the new flow.
      // This branch is kept for safety but should not be reachable
      // since the button is hidden for active_borrow state.
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text(
            'Please bring the book to the library desk to return it.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    final book = widget.book;
    final borrowId = await context.read<UserBooksProvider>().borrowBook(
      bookId: book.id,
      userId: userId,
      bookTitle: book.title,
      bookAuthor: book.author,
      bookCoverUrl: book.coverUrl,
    );

    if (borrowId != null) {
      NotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: 'Borrow Requested!',
        body: 'Show your QR pass to the librarian to pick up "${book.title}".',
      );
      Navigator.pop(context);
      final latestBook = context
          .read<BookCatalogProvider>()
          .recentlyViewed
          .firstWhere((b) => b.id == book.id, orElse: () => book);
      showDialog(
        context: context,
        barrierColor: Colors.black87,
        builder: (_) =>
            SuccessTicketDialog(book: latestBook, borrowId: borrowId),
      );

      await _fetchCurrentBorrow();
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            context.read<UserBooksProvider>().error ?? 'Something went wrong.',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<UserProvider>().user?.id ?? '';
    final catalog = context.watch<BookCatalogProvider>();

    // Find the most up-to-date version of the book in the catalog
    Book currentBook = widget.book;
    final allLists = [
      catalog.trending,
      catalog.featured,
      catalog.allBooks,
      catalog.searchResults,
      catalog.recentlyViewed,
    ];

    for (final list in allLists) {
      final found = list.where((b) => b.id == widget.book.id);
      if (found.isNotEmpty) {
        currentBook = found.first;
        break;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: BookHeader(
              book: currentBook,
            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1, end: 0),
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
                      currentBook.description,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textMuted,
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    BookDetailsRow(book: currentBook),
                    SizedBox(height: 3.h),
                    if (currentBook.tags.isNotEmpty) ...[
                      _SectionTitle(title: 'Tags'),
                      SizedBox(height: 1.h),
                      TagsRow(tags: currentBook.tags),
                      SizedBox(height: 3.h),
                    ],
                    _SectionTitle(title: 'Location'),
                    SizedBox(height: 1.h),
                    LocationCard(book: currentBook),
                    SizedBox(height: 4.h),
                    ActionButtons(
                          book: currentBook,
                          isLoading: _isLoading,
                          currentBorrow: _currentBorrow,
                          studentId: userId,
                          onBorrowTap: _handleBorrow,
                        )
                        .animate()
                        .fadeIn(delay: 500.ms)
                        .scale(begin: const Offset(0.95, 0.95)),
                    SizedBox(height: 4.h),

                    _SectionTitle(
                      title: 'You might also like',
                    ).animate().fadeIn(delay: 600.ms),
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
                                  )
                                  .animate()
                                  .fadeIn(delay: (index * 100).ms)
                                  .slideX(begin: 0.1, end: 0);
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
