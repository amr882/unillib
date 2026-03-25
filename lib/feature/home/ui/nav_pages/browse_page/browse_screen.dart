// browse_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/home/logic/book_provider.dart';
import 'package:unilib/feature/home/ui/book/book_screen.dart';
import 'widgets/browse_search_bar.dart';
import 'widgets/browse_book_tile.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});
  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<BooksProvider>().fetchAllBooks());
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) {
      context.read<BooksProvider>().clearSearch();
    } else {
      context.read<BooksProvider>().searchBooks(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final books = context.watch<BooksProvider>();
    final isSearching = _searchController.text.trim().isNotEmpty;
    final displayList = isSearching ? books.searchResults : books.allBooks;

    return Scaffold(
      backgroundColor: AppColors.backGround,
      body: Column(
        children: [
          // ── Fixed Top Card ──────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Browse',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    BrowseSearchBar(
                      controller: _searchController,
                      onChanged: _onSearch,
                      onClear: () {
                        _searchController.clear();
                        context.read<BooksProvider>().clearSearch();
                        setState(() {});
                      },
                    ),

                    SizedBox(height: 1.h),
                  ],
                ),
              ),
            ),
          ),

          // ── Results count ───────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
            child: Row(
              children: [
                Text(
                  isSearching
                      ? '${displayList.length} results for "${_searchController.text}"'
                      : '${displayList.length} books found',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ── Book List ───────────────────────────────
          Expanded(
            child: books.isLoading || books.isSearching
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  )
                : books.error != null
                ? Center(
                    child: Text(
                      'Something went wrong\n${books.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                  )
                : displayList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 8.h,
                          color: AppColors.textMuted,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          isSearching
                              ? 'No results found'
                              : 'No books available',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 1.h,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: displayList.length,
                    separatorBuilder: (_, _) => SizedBox(height: 1.5.h),
                    itemBuilder: (context, index) {
                      final book = displayList[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookScreen(book: book),
                          ),
                        ),
                        child: Hero(
                          tag: book.id,
                          child: BrowseBookTile(book: book),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
