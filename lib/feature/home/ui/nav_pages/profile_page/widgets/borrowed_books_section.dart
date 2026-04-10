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

class _BorrowItem {
  final BorrowRecord record;
  final Book book;
  _BorrowItem(this.record, this.book);
}

class BorrowedBooksSection extends StatefulWidget {
  final String userId;

  const BorrowedBooksSection({super.key, required this.userId});

  @override
  State<BorrowedBooksSection> createState() => _BorrowedBooksSectionState();
}

class _BorrowedBooksSectionState extends State<BorrowedBooksSection> {
  List<_BorrowItem>? _borrowItems;
  bool _isLoading = true;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
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

  Future<void> _fetchBooks() async {
    final provider = context.read<UserBooksProvider>();
    final catalog = context.read<BookCatalogProvider>();
    
    final records = await provider.fetchUserBorrows(widget.userId);
    final List<_BorrowItem> items = [];
    
    for (final record in records) {
      Book? book = catalog.allBooks.cast<Book?>().firstWhere(
        (b) => b?.id == record.bookId, 
        orElse: () => null
      );
      
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

  String _formatDuration(Duration d) {
    if (d == Duration.zero || d.isNegative) return 'Expired';
    final days = d.inDays;
    final hours = d.inHours.remainder(24);
    final minutes = d.inMinutes.remainder(60);
    
    if (days > 0) {
      return '$days days left';
    }
    if (hours > 0) {
      return '${hours}h ${minutes}m left';
    }
    return '${minutes}m left';
  }

  Color _getTimerColor(Duration d, bool isActiveBorrow) {
    if (d.isNegative || d == Duration.zero) return Colors.red.shade900; // Deep Red for overdue
    
    if (isActiveBorrow) {
      // 14-day return window colors
      if (d.inDays > 7) return Colors.green;
      if (d.inDays >= 3) return Colors.orange;
      return Colors.red;
    } else {
      // 48 hour pickup window colors
      if (d.inHours < 4) return Colors.red;
      if (d.inHours < 12) return Colors.orange;
      return Colors.green;
    }
  }

  IconData _getTimerIcon(Duration d) {
    if (d.isNegative || d == Duration.zero) return Icons.error_outline_rounded;
    if (d.inDays > 7) return Icons.calendar_today_rounded;
    if (d.inHours < 24) return Icons.schedule_rounded;
    return Icons.timer_outlined;
  }

  Future<void> _cancelBorrow(BuildContext context, _BorrowItem item, int index) async {
    final book = item.book;
    final record = item.record;
    final confirm = await showGeneralDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      barrierLabel: 'Cancel Borrow',
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, anim, secondaryAnim) => const SizedBox(),
      transitionBuilder: (context, anim, secondaryAnim, child) {
        final scaleAnim = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        final fadeAnim = CurvedAnimation(parent: anim, curve: Curves.easeIn);

        return FadeTransition(
          opacity: fadeAnim,
          child: ScaleTransition(
            scale: scaleAnim,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cancel_rounded,
                      color: Colors.red,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cancel Borrow',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'You are about to cancel your\nborrow request for "${book.title}".\nDo you want to continue?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: AppColors.navy.withOpacity(0.25),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                          ),
                          child: const Text(
                            'No, Keep It',
                            style: TextStyle(color: AppColors.navy),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Yes, Cancel',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (confirm == true && mounted) {
      final provider = context.read<UserBooksProvider>();
      final success = await provider.cancelPendingBorrow(
        bookId: book.id,
        userId: widget.userId,
        borrowId: record.borrowId,
      );

      if (success && mounted) {
        setState(() {
          _borrowItems?.removeAt(index);
        });
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
      } else if (mounted) {
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

  Widget _buildCountdownChip(_BorrowItem item) {
    Duration? remaining;
    String prefix = '';
    
    final isActiveBorrow = item.record.status == BorrowStatus.activeBorrow;

    if (isActiveBorrow) {
      remaining = item.record.returnTimeRemaining;
      prefix = 'Return due: ';
    } else if (item.record.status == BorrowStatus.pendingPickup) {
      remaining = item.record.pickupTimeRemaining;
      prefix = 'Pickup by: ';
    }
    
    if (remaining == null) {
      return const SizedBox.shrink();
    }

    final color = _getTimerColor(remaining, isActiveBorrow);
    final icon = _getTimerIcon(remaining);
    final text = '$prefix${_formatDuration(remaining)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
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
        if (_isLoading)
          const Center(child: CircularProgressIndicator(color: AppColors.gold))
        else if (_borrowItems == null || _borrowItems!.isEmpty)
          Center(
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
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
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
                      trailingWidget: canCancel 
                        ? IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => _cancelBorrow(context, item, index),
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
                          _buildCountdownChip(item),
                          if (!canCancel) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.withOpacity(0.3)),
                              ),
                              child: const Text(
                                'Reading', 
                                style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ]
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
