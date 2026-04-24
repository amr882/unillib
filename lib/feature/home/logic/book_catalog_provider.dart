import 'package:flutter/material.dart';
import 'package:unilib/core/model/book_model.dart';
import 'book_fetcher_service.dart';
import 'new_books_listener.dart';

class BookCatalogProvider extends ChangeNotifier {
  final BookFetcherService _fetcher = BookFetcherService();
  final NewBooksListener _newBooksListener = NewBooksListener();

  List<Book> _featured = [];
  List<Book> _trending = [];
  List<Book> _searchResults = [];
  List<Book> _allBooks = [];
  List<Book> _recentlyViewed = [];

  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;

  List<Book> get featured => _featured;
  List<Book> get trending => _trending;
  List<Book> get searchResults => _searchResults;
  List<Book> get allBooks => _allBooks;
  List<Book> get recentlyViewed => _recentlyViewed;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;

  // ── Fetchers ─────────────────────────────────────────────────

  Future<Book?> fetchBookById(String id) => _fetcher.fetchBookById(id);

  Future<void> fetchFeatured() async {
    _setLoading(true);
    try {
      _featured = await _fetcher.fetchFeatured();
      _error = null;
    } catch (e) {
      _error = 'Failed to load featured: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchTrending() async {
    _setLoading(true);
    try {
      _trending = await _fetcher.fetchTrending();
      _error = null;
    } catch (e) {
      _error = 'Failed to load trending: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchHomeData() async {
    await Future.wait([
      fetchFeatured(),
      fetchTrending(),
      fetchRecentlyViewed(),
    ]);
  }

  Future<void> fetchRecentlyViewed() async {
    try {
      final recentIds = await _fetcher.getRecentIds();
      _recentlyViewed = await _fetcher.fetchRecentlyViewedBooks(recentIds);
    } catch (e) {
      debugPrint('Failed to load recent: $e');
    }
    _updateInterests();
    notifyListeners();
  }

  Future<void> addRecentlyViewed(String id) async {
    try {
      await _fetcher.addRecentId(id);
      await fetchRecentlyViewed();
    } catch (e) {
      debugPrint('Failed to add recent: $e');
    }
  }

  Future<List<Book>> getRelatedBooks(Book book) =>
      _fetcher.getRelatedBooks(book);

  Future<void> fetchAllBooks({String? facultyFilter}) async {
    _setLoading(true);
    try {
      _allBooks = await _fetcher.fetchAllBooks(facultyFilter: facultyFilter);
      _error = null;
    } catch (e) {
      _error = 'Failed to load books: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchBooks(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    _isSearching = true;
    notifyListeners();

    try {
      _searchResults = await _fetcher.searchBooks(query);
      _error = null;
    } catch (e) {
      _error = 'Search failed: $e';
    } finally {
      _isSearching = false;
      _updateInterests();
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  // ── New Books Listener ───────────────────────────────────────

  void startNewBooksListener() => _newBooksListener.startListening();

  void _updateInterests() {
    _newBooksListener.updateInterests(
      recentCategories: _recentlyViewed.map((b) => b.category).toList(),
      searchCategories: _searchResults.take(5).map((b) => b.category).toList(),
    );
  }

  // ── Local Updates ────────────────────────────────────────────

  void updateBookLocally(
    String bookId,
    String userId, {
    required bool borrowed,
  }) {
    for (final list in [
      _trending,
      _featured,
      _allBooks,
      _searchResults,
      _recentlyViewed,
    ]) {
      final idx = list.indexWhere((b) => b.id == bookId);
      if (idx == -1) continue;
      final b = list[idx];
      final updatedBorrowedBy = List<dynamic>.from(b.borrowedBy);
      if (borrowed) {
        updatedBorrowedBy.add(userId);
      } else {
        updatedBorrowedBy.remove(userId);
      }

      final int newAvailableCount = borrowed
          ? b.availableCopies - 1
          : b.availableCopies + 1;

      final updatedBook = b.copyWith(
        borrowedBy: updatedBorrowedBy,
        availableCopies: newAvailableCount,
        isAvailable: newAvailableCount > 0,
        borrowCount: borrowed ? b.borrowCount + 1 : b.borrowCount,
      );

      // Special handling for trending/featured if they become unavailable
      if (borrowed &&
          newAvailableCount == 0 &&
          (list == _trending || list == _featured)) {
        list.removeAt(idx);
      } else {
        list[idx] = updatedBook;
      }
    }
    notifyListeners();
  }

  // ── Helpers ──────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _newBooksListener.dispose();
    super.dispose();
  }
}
