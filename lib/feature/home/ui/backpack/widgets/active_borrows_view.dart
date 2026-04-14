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
      builder: (context) => AlertDialog(
        title: const Text('Cancel Request'),
        content: Text('Do you want to cancel your request for "${book.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
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

    if (_items == null || _items!.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.navy.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            'Backpack is empty',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: AppColors.navy),
          ),
          const SizedBox(height: 8),
          Text(
            'Borrow some books to see them here!',
            style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms);
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      itemCount: _items!.length,
      separatorBuilder: (_, _) => SizedBox(height: 2.h),
      itemBuilder: (context, index) {
        final item = _items![index];
        final book = item.book;
        final record = item.record;
        final canCancel = record.canUserCancel;

        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookScreen(book: book))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TrendingBookTile(
                rank: index + 1,
                book: book,
                isDark: false,
                trailingWidget: canCancel
                    ? IconButton(
                        icon: const Icon(Icons.cancel_rounded, color: Colors.red),
                        onPressed: () => _cancelBorrow(context, item, index),
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
