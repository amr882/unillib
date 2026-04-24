import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/logic/user_provider.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/model/borrow_model.dart';
import 'package:unilib/core/service/notification_service.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/core/helper/extention.dart';
import 'package:unilib/core/routes/routes.dart';
import 'package:unilib/feature/home/logic/book_catalog_provider.dart';
import 'package:unilib/feature/home/logic/user_books_provider.dart';
import 'package:unilib/feature/home/ui/nav_pages/ai_page/logic/user/generative_ai_provider.dart';
import 'package:unilib/feature/home/ui/book/widgets/action_buttons.dart';
import 'package:unilib/feature/home/ui/book/widgets/related_books_section.dart';
import 'package:unilib/feature/home/ui/book/widgets/details.dart';
import 'package:unilib/feature/home/ui/book/widgets/header.dart';
import 'package:unilib/feature/home/ui/book/widgets/location.dart';
import 'package:unilib/feature/home/ui/book/widgets/tags.dart';
import 'package:unilib/feature/home/ui/book/widgets/success_ticket_dialog.dart';
import 'package:unilib/feature/home/ui/widgets/status_countdown.dart';

class BookScreen extends StatefulWidget {
  final Book book;
  const BookScreen({super.key, required this.book});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  bool _isLoading = false;
  Timer? _countdownTimer;

  late Future<List<Book>> _relatedFuture;

  @override
  void initState() {
    super.initState();

    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });

    Future.microtask(() {
      if (mounted) {
        context.read<BookCatalogProvider>().addRecentlyViewed(widget.book.id);
      }
    });

    _relatedFuture = context.read<BookCatalogProvider>().getRelatedBooks(
      widget.book,
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleBorrow() async {
    final userId = context.read<UserProvider>().user?.id ?? '';
    if (userId.isEmpty) return;

    setState(() => _isLoading = true);

    final userBooksProvider = context.read<UserBooksProvider>();
    final success = await userBooksProvider.borrowBook(
      bookId: widget.book.id,
      userId: userId,
    );

    if (success) {
      NotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: 'Borrowing Successful!',
        body:
            'You have successfully requested "${widget.book.title}". Pick it up within 48h!',
      );

      // Show ticket dialog - we can fetch it once here or rely on the fact it was just created
      final records = await userBooksProvider.fetchUserBorrows(userId);
      final newRecord = records.firstWhere((r) => r.bookId == widget.book.id);

      if (mounted) {
        showDialog(
          context: context,
          barrierColor: Colors.black87,
          builder: (_) => SuccessTicketDialog(
            book: widget.book,
            borrowId: newRecord.borrowId,
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              userBooksProvider.error ?? 'Something went wrong.',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SectionTitle(title: 'About this Resource')
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .slideY(begin: 0.1, end: 0),

                        GestureDetector(
                          onTap: () {
                            context
                                .read<GenerativeAiProvider>()
                                .startBookContextChat(currentBook);
                            context.pushNamed(Routes.aiChatScreen);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.gold.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  color: AppColors.gold,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Ask AI",
                                  style: TextStyle(
                                    color: AppColors.gold,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(delay: 300.ms),
                      ],
                    ),
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

                    StreamBuilder<BorrowRecord?>(
                      stream: context
                          .read<UserBooksProvider>()
                          .getBorrowRecordForBookStream(userId, currentBook.id),
                      builder: (context, snapshot) {
                        final record = snapshot.data;

                        return Column(
                          children: [
                            if (record != null) ...[
                              StatusCountdown(record: record),
                              SizedBox(height: 1.5.h),
                            ],
                            ActionButtons(
                                  book: currentBook,
                                  isLoading: _isLoading,
                                  userBorrowRecord: record,
                                  studentId: userId,
                                  onBorrowTap: _handleBorrow,
                                  onRefreshRequested:
                                      () {}, // No longer needed with streams
                                )
                                .animate()
                                .fadeIn(delay: 500.ms)
                                .scale(begin: const Offset(0.95, 0.95)),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 4.h),

                    RelatedBooksSection(relatedFuture: _relatedFuture),
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
