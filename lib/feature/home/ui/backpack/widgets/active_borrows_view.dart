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
import 'package:flutter_animate/flutter_animate.dart';

class _BorrowItem {
  final BorrowRecord record;
  final Book book;
  _BorrowItem(this.record, this.book);
}

class ActiveBorrowsView extends StatefulWidget {
  final String userId;
  const ActiveBorrowsView({super.key, required this.userId});

  @override
  State<ActiveBorrowsView> createState() => _ActiveBorrowsViewState();
}

class _ActiveBorrowsViewState extends State<ActiveBorrowsView> {
  List<_BorrowItem>? _items;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
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
        _items = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelBorrow(BuildContext context, _BorrowItem item, int index) async {
    final book = item.book;
    final record = item.record;

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
            .scale(duration: 300.ms, curve: Curves.easeOutBack, begin: const Offset(0.8, 0.8))
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

      if (success && mounted) {
        if (!context.mounted) return;
        setState(() => _items?.removeAt(index));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cancelled successfully')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.gold));
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 4.h),
      itemCount: _items!.length + 1,
      separatorBuilder: (_, index) => index == 0 ? const SizedBox.shrink() : SizedBox(height: 2.h),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: 2.h, top: 1.h),
            child: Text(
              'Active Borrow',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
                letterSpacing: 0.2,
              ),
            ),
          );
        }
        final item = _items![index - 1];
        final book = item.book;
        final record = item.record;
        final canCancel = record.canUserCancel;

        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookScreen(book: book))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TrendingBookTile(
                rank: index,
                book: book,
                isDark: false,
                trailingWidget: canCancel
                    ? SizedBox(
                        height: 4.5.h,
                        child: ElevatedButton(
                          onPressed: () => _cancelBorrow(context, item, index - 1),
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
                    : const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  children: [
                    StatusCountdown(record: record),
                    if (!canCancel) ...[
                      const SizedBox(width: 8),
                      _buildStatusBadge('Reading', Colors.blue),
                    ],
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1, duration: 400.ms),
        );
      },
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11.sp, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
