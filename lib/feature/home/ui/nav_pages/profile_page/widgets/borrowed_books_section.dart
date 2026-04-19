// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
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


class BorrowedBooksSection extends StatefulWidget {
  final String userId;

  const BorrowedBooksSection({super.key, required this.userId});

  @override
  State<BorrowedBooksSection> createState() => _BorrowedBooksSectionState();
}

class _BorrowedBooksSectionState extends State<BorrowedBooksSection> {
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();

    // Tick every minute to update countdown displays
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Borrowed Books',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
        SizedBox(height: 2.h),
        StreamBuilder<List<BorrowRecord>>(
          stream: context.read<UserBooksProvider>().getBorrowRecordsStream(
            widget.userId,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              );
            }

            final records = snapshot.data ?? [];
            if (records.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: Text(
                    "You have not borrowed any books yet",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.length,
              separatorBuilder: (context, index) => SizedBox(height: 2.h),
              itemBuilder: (context, index) {
                final record = records[index];
                return _BorrowItemWidget(
                  userId: widget.userId,
                  record: record,
                  index: index,
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _BorrowItemWidget extends StatefulWidget {
  final String userId;
  final BorrowRecord record;
  final int index;

  const _BorrowItemWidget({
    required this.userId,
    required this.record,
    required this.index,
  });

  @override
  State<_BorrowItemWidget> createState() => _BorrowItemWidgetState();
}

class _BorrowItemWidgetState extends State<_BorrowItemWidget> {
  Book? _book;
  bool _isLoadingBook = true;

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  @override
  void didUpdateWidget(covariant _BorrowItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.record.bookId != widget.record.bookId) {
      _loadBook();
    }
  }

  Future<void> _loadBook() async {
    final catalog = context.read<BookCatalogProvider>();
    Book? book = catalog.allBooks.cast<Book?>().firstWhere(
      (b) => b?.id == widget.record.bookId,
      orElse: () => null,
    );

    book ??= await catalog.fetchBookById(widget.record.bookId);

    book ??= Book(
      id: widget.record.bookId,
      rawId: widget.record.bookId,
      title: widget.record.bookTitle,
      titleLower: widget.record.bookTitle.toLowerCase(),
      author: widget.record.bookAuthor,
      authorLower: widget.record.bookAuthor.toLowerCase(),
      description: '',
      isbn: '',
      year: '',
      language: '',
      category: '',
      faculty: '',
      facultySlug: '',
      coverUrl: widget.record.bookCoverUrl,
      sourceUrl: '',
      createdAt: '',
      updatedAt: '',
      availableCopies: 0,
      totalCopies: 0,
      borrowCount: 0,
      isAvailable: false,
      tags: [],
      reservedBy: [],
      borrowedBy: [widget.userId],
      location: BookLocation(building: '', floor: '', shelf: ''),
    );

    if (mounted) {
      setState(() {
        _book = book;
        _isLoadingBook = false;
      });
    }
  }

  Future<void> _cancelBorrow() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
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
                'Cancel Borrow',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'You are about to cancel your borrow request for "${widget.record.bookTitle}". Do you want to continue?',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSub, fontSize: 13.sp),
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'No, Keep It',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13.sp,
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Yes, Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true && mounted) {
      final provider = context.read<UserBooksProvider>();
      final success = await provider.cancelPendingBorrow(
        bookId: widget.record.bookId,
        userId: widget.userId,
        borrowId: widget.record.borrowId,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cancelled successfully')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingBook || _book == null) {
      return SizedBox(
        height: 10.h,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final book = _book!;
    final record = widget.record;
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
            rank: widget.index + 1,
            book: book,
            trailingWidget: canCancel
                ? SizedBox(
                    height: 4.5.h,
                    child: ElevatedButton(
                      onPressed: _cancelBorrow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.navy,
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: AppColors.navy.withOpacity(0.12),
                          ),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.lock_outline, color: Colors.grey),
                    tooltip: 'Return at library desk',
                    onPressed: () {},
                  ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              children: [
                StatusCountdown(record: record),
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
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
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
  }
}
