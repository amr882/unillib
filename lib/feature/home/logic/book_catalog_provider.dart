import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/service/notification_service.dart';

class BookCatalogProvider extends ChangeNotifier {
  List<Book> _featured = [];
  List<Book> _trending = [];
  List<Book> _searchResults = [];
  List<Book> _allBooks = [];
  List<Book> _recentlyViewed = [];

  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;

  Set<String> _interestedCategories = {};
  StreamSubscription? _newBooksSubscription;
  String? _lastKnownBookTimestamp;

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

  void _updateInterests() {
    final newInterests = _recentlyViewed.map((b) => b.category).where((cat) => cat != '??').toSet();
    if (_searchResults.isNotEmpty) {
      newInterests.addAll(_searchResults.take(5).map((b) => b.category).where((cat) => cat != '??'));
    }
    
    if (newInterests.isNotEmpty && !setEquals(_interestedCategories, newInterests)) {
      _interestedCategories = newInterests;
      debugPrint('Updated interests: $_interestedCategories');
      // Restart listener if it wasn't running
      if (_newBooksSubscription == null) {
        startNewBooksListener();
      }
    }
  }

  bool setEquals(Set a, Set b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  void startNewBooksListener() {
    _newBooksSubscription?.cancel();

    // Initial fetch to get the current latest timestamp
    _firestore
        .collection('books')
        .orderBy('created_at', descending: true)
        .limit(1)
        .get()
        .then((snap) {
      if (snap.docs.isNotEmpty) {
        _lastKnownBookTimestamp = snap.docs.first.data()['created_at'];
      }

      _newBooksSubscription = _firestore
          .collection('books')
          .snapshots()
          .listen((snap) {
        for (var change in snap.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final data = change.doc.data();
            if (data == null) continue;
            
            final createdAt = data['created_at'] as String? ?? '';
            
            // Only notify if it's newer than the last known book
            if (_lastKnownBookTimestamp == null || createdAt.compareTo(_lastKnownBookTimestamp!) > 0) {
              final category = data['category'] as String? ?? '??';
              if (_interestedCategories.contains(category)) {
                NotificationService().showNotification(
                  id: change.doc.id.hashCode,
                  title: 'New Book for You!',
                  body: 'A new book in "$category" is now available: ${data['title']}',
                );
              }
              // Update last known timestamp to avoid duplicate alerts if multiple changes come in
              if (_lastKnownBookTimestamp == null || createdAt.compareTo(_lastKnownBookTimestamp!) > 0) {
                _lastKnownBookTimestamp = createdAt;
              }
            }
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _newBooksSubscription?.cancel();
    super.dispose();
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
          .limit(20)
          .get();

      _featured = snap.docs
          .map(Book.fromFirestore)
          .where((b) => b.hasCover)
          .take(5)
          .toList();
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
      // Fetch a larger pool to ensure we find enough books with photos
      final snap = await _firestore
          .collection('books')
          .where('is_available', isEqualTo: true)
          .limit(100)
          .get();

      final booksWithCovers = snap.docs
          .map(Book.fromFirestore)
          .where((b) => b.hasCover)
          .toList();
      
      // Shuffle to provide random books as requested
      booksWithCovers.shuffle();

      _trending = booksWithCovers.take(10).toList();
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
                orElse: () => Book(id: '??', rawId: '??', title: '??', titleLower: '??', author: '??', authorLower: '??', description: '??', isbn: '??', year: '??', language: '??', category: '??', faculty: '??', facultySlug: '??', coverUrl: '??', sourceUrl: '??', createdAt: '??', updatedAt: '??', availableCopies: 0, totalCopies: 0, borrowCount: 0, isAvailable: false, tags: [], reservedBy: [], borrowedBy: [], reservations: {}, location: BookLocation(building: '??', floor: '??', shelf: '??')),
              ))
          .where((b) => b.id != '??')
          .toList();
          
    } catch (e) {
      debugPrint('Failed to load recent: $e');
    }
    _updateInterests();
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
      _updateInterests();
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
