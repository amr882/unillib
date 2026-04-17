import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/model/borrow_model.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/home/logic/book_catalog_provider.dart';
import 'package:unilib/feature/home/logic/user_books_provider.dart';
import 'package:unilib/feature/home/ui/book/book_screen.dart';
import 'package:unilib/feature/home/ui/nav_pages/home_page/widgets/trending_book_tile.dart';
import 'package:unilib/feature/home/ui/widgets/status_countdown.dart';

class _BorrowItem {
  final BorrowRecord record;
  final Book book;
  _BorrowItem(this.record, this.book);
}

class BorrowedBooksSheet extends StatefulWidget {
  final String userId;
  final ScrollController? scrollController;

  const BorrowedBooksSheet({
    super.key,
    required this.userId,
    this.scrollController,
  });

  @override
  State<BorrowedBooksSheet> createState() => _BorrowedBooksSheetState();
}

class _BorrowedBooksSheetState extends State<BorrowedBooksSheet> {
  List<_BorrowItem>? _borrowItems;
  bool _isLoading = true;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchBooks() async {
    final provider = context.read<UserBooksProvider>();
    final catalog = context.read<BookCatalogProvider>();

    final records = await provider.fetchUserBorrows(widget.userId);
    final List<_BorrowItem> items = [];

    for (final record in records) {
      Book? book = catalog.allBooks.cast<Book?>().firstWhere(
        (b) => b?.id == record.bookId,
        orElse: () => null,
      );

      // Fetch from Firestore if not found in local catalog to ensure we have tags/info
      book ??= await catalog.fetchBookById(record.bookId);

      book ??= Book(
        id: record.bookId,
        rawId: record.bookId,
        title: record.bookTitle,
        titleLower: record.bookTitle.toLowerCase(),
        author: record.bookAuthor,
        authorLower: record.bookAuthor.toLowerCase(),
        description: '',
        isbn: '',
        year: '',
        language: '',
        category: '',
        faculty: '',
        facultySlug: '',
        coverUrl: record.bookCoverUrl,
        sourceUrl: '',
        createdAt: '',
        updatedAt: '',
        availableCopies: 0,
        totalCopies: 0,
        borrowCount: 0,
        isAvailable: false,
        tags: [],
        reservedBy: [],
        borrowedBy: [record.userId],
        location: BookLocation(building: '', floor: '', shelf: ''),
      );

      items.add(_BorrowItem(record, book));
    }

    if (mounted) {
      setState(() {
        _borrowItems = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelBorrow(
    BuildContext context,
    _BorrowItem item,
    int index,
  ) async {
    final book = item.book;
    final record = item.record;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child:
            Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.navyCard,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.navyBorder, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cancel_rounded,
                          color: Colors.redAccent,
                          size: 32,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'cancle Borrow',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'You are about to cancle your borrow request for "${book.title}". Do you want to continue?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSub,
                          fontSize: 13.sp,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'No, Keep It',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: AppColors.white,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Yes, cancle',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                .animate()
                .scale(
                  duration: 300.ms,
                  curve: Curves.easeOutBack,
                  begin: const Offset(0.8, 0.8),
                )
                .fadeIn(duration: 200.ms),
      ),
    );

    if (confirm == true && mounted) {
      if (!context.mounted) return;
      final provider = context.read<UserBooksProvider>();
      final success = await provider.cancelPendingBorrow(
        bookId: book.id,
        userId: widget.userId,
        borrowId: record.borrowId,
      );

      if (!mounted) return;

      if (success) {
        setState(() {
          _borrowItems?.removeAt(index);
        });
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cancel successfully'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to cancel request'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  )
                : (_borrowItems == null || _borrowItems!.isEmpty)
                ? _buildEmptyState()
                : _buildBookList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.navy.withOpacity(0.12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Backpack',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: AppColors.navy),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Your currently borrowed and reserved books.',
            style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted),
          ),
          SizedBox(height: 1.h),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      controller: widget.scrollController,
      children: [
        SizedBox(height: 10.h),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 60,
                color: AppColors.gold.withOpacity(0.3),
              ),
              SizedBox(height: 2.h),
              Text(
                "Your backpack is empty",
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                "Borrow some books to see them here!",
                style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookList() {
    return ListView.separated(
      controller: widget.scrollController,
      padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 4.h),
      itemCount: _borrowItems!.length,
      separatorBuilder: (context, index) => SizedBox(height: 2.h),
      itemBuilder: (context, index) {
        final item = _borrowItems![index];
        final book = item.book;
        final record = item.record;
        final canCancel = record.canUserCancel;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BookScreen(book: book)),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TrendingBookTile(
                rank: index + 1,
                book: book,
                isDark: false,
                trailingWidget: canCancel
                    ? SizedBox(
                        height: 4.5.h,
                        child: ElevatedButton(
                          onPressed: () => _cancelBorrow(context, item, index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.navy,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: AppColors.navy.withOpacity(0.12),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            'cancle',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(
                          Icons.lock_outline,
                          color: Colors.grey,
                        ),
                        tooltip: 'Return at library desk',
                        onPressed: () {},
                      ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  children: [
                    StatusCountdown(record: item.record),
                    if (!canCancel) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: const Text(
                          'Reading',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
