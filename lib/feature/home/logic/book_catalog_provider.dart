import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unilib/core/model/book_model.dart';

class BookCatalogProvider extends ChangeNotifier {
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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── helpers ──
  int _completenessScore(Book b) {
    int score = 0;
    if (b.coverUrl.isNotEmpty && b.coverUrl != '??') score += 2;
    if (b.description.isNotEmpty && b.description != '??') score += 1;
    return score;
  }

  void _sortByCompleteness(List<Book> list) {
    list.sort((a, b) => _completenessScore(b).compareTo(_completenessScore(a)));
  }

  // ── fetchers ──
  
  Future<Book?> fetchBookById(String id) async {
    try {
      final doc = await _firestore.collection('books').doc(id).get();
      if (doc.exists) {
        return Book.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('Error fetching book $id: $e');
    }
    return null;
  }

  Future<void> fetchFeatured() async {
    _setLoading(true);

    try {
      final snap = await _firestore
          .collection('books')
          .where('is_available', isEqualTo: true)
          .orderBy('created_at', descending: true)
          .limit(5)
          .get();

      _featured = snap.docs.map(Book.fromFirestore).toList();
      _sortByCompleteness(_featured);
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
      final snap = await _firestore
          .collection('books')
          .where('is_available', isEqualTo: true)
          .orderBy('borrow_count', descending: true)
          .limit(10)
          .get();

      _trending = snap.docs.map(Book.fromFirestore).toList();
      _sortByCompleteness(_trending);
      _error = null;
    } catch (e) {
      _error = 'Failed to load trending: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchHomeData() async {
    await Future.wait([fetchFeatured(), fetchTrending(), fetchRecentlyViewed()]);
  }

  Future<void> fetchRecentlyViewed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentIds = prefs.getStringList('recently_viewed') ?? [];
      
      if (recentIds.isEmpty) {
        _recentlyViewed = [];
        notifyListeners();
        return;
      }

      final snap = await _firestore
          .collection('books')
          .where(FieldPath.documentId, whereIn: recentIds)
          .get();

      final fetchedBooks = snap.docs.map(Book.fromFirestore).toList();
      
      // Sort to match recentIds order
      _recentlyViewed = recentIds
          .map((id) => fetchedBooks.firstWhere(
                (b) => b.id == id,
                orElse: () => Book(id: '??', rawId: '??', title: '??', titleLower: '??', author: '??', authorLower: '??', description: '??', isbn: '??', year: '??', language: '??', category: '??', faculty: '??', facultySlug: '??', coverUrl: '??', sourceUrl: '??', createdAt: '??', updatedAt: '??', availableCopies: 0, totalCopies: 0, borrowCount: 0, isAvailable: false, tags: [], reservedBy: [], borrowedBy: [], location: BookLocation(building: '??', floor: '??', shelf: '??')),
              ))
          .where((b) => b.id != '??')
          .toList();
          
    } catch (e) {
      debugPrint('Failed to load recent: $e');
    }
    notifyListeners();
  }

  Future<void> addRecentlyViewed(String id) async {
    if (id == '??') return;
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> recentIds = prefs.getStringList('recently_viewed') ?? [];
      
      if (recentIds.contains(id)) {
        recentIds.remove(id);
      }
      recentIds.insert(0, id);
      
      if (recentIds.length > 5) {
        recentIds = recentIds.sublist(0, 5);
      }
      
      await prefs.setStringList('recently_viewed', recentIds);
      await fetchRecentlyViewed();
    } catch (e) {
      debugPrint('Failed to add recent: $e');
    }
  }

  Future<List<Book>> getRelatedBooks(Book book) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('books')
          .where('category', isEqualTo: book.category)
          .where('is_available', isEqualTo: true)
          .limit(6)
          .get();

      List<Book> related = snap.docs
          .map(Book.fromFirestore)
          .where((b) => b.id != book.id)
          .toList();

      return related;
    } catch (e) {
      debugPrint('Failed to fetch related: $e');
      return [];
    }
  }

  Future<void> fetchAllBooks({String? facultyFilter}) async {
    _setLoading(true);
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('books');
      if (facultyFilter != null && facultyFilter.isNotEmpty) {
        query = query.where('faculty_slug', isEqualTo: facultyFilter);
      }

      final snap = await query.orderBy('title_lower').get();

      _allBooks = snap.docs.map(Book.fromFirestore).toList();
      _sortByCompleteness(_allBooks);
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
      final lower = query.toLowerCase().trim();

      final snap = await _firestore
          .collection('books')
          .where('title_lower', isGreaterThanOrEqualTo: lower)
          .where('title_lower', isLessThan: '${lower}z')
          .limit(20)
          .get();

      _searchResults = snap.docs.map(Book.fromFirestore).toList();
      _error = null;
    } catch (e) {
      _error = 'Search failed: $e';
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

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
      _recentlyViewed
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
      // According to Firestore queries, only is_available=true books are shown.
      if (borrowed && newAvailableCount == 0 && (list == _trending || list == _featured)) {
        list.removeAt(idx);
      } else {
        list[idx] = updatedBook;
      }
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
