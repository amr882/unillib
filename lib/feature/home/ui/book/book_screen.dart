// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/logic/user_provider.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/home/logic/user_books_provider.dart';
import 'package:unilib/feature/home/ui/book/widgets/action_buttons.dart';
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

  @override
  void initState() {
    super.initState();
    final userId = context.read<UserProvider>().user?.id ?? '';
    _alreadyBorrowed = widget.book.borrowedBy.contains(userId);
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
              ? (_alreadyBorrowed ? 'Book returned!' : 'Book borrowed!')
              : context.read<UserBooksProvider>().error ?? 'Something went wrong.',
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
          SliverToBoxAdapter(child: BookHeader(book: widget.book)),
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
                    _SectionTitle(title: 'About this Resource'),
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
