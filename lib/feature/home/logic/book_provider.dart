import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unilib/core/model/book_model.dart';

class BooksProvider extends ChangeNotifier {
  List<Book> _featured = [];
  List<Book> _trending = [];
  List<Book> _searchResults = [];
  List<Book> _allBooks = [];

  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;

  List<Book> get featured => _featured;
  List<Book> get trending => _trending;
  List<Book> get searchResults => _searchResults;
  List<Book> get allBooks => _allBooks;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BooksProvider() {
    releaseExpiredReservations();
  }

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

  // ── fetchers ──────────────────────────────────────────────────────────────

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
    await Future.wait([fetchFeatured(), fetchTrending()]);
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

  Future<bool> borrowBook({
    required String bookId,
    required String userId,
  }) async {
    try {
      final docRef = _firestore.collection('books').doc(bookId);

      await _firestore.runTransaction((transaction) async {
        final snap = await transaction.get(docRef);
        final available = (snap.data()?['available_copies'] ?? 0) as int;
        final borrowedBy = List<dynamic>.from(
          snap.data()?['borrowed_by'] ?? [],
        );
        final reservations = Map<String, dynamic>.from(
          snap.data()?['reservations'] ?? {},
        );
        final now = DateTime.now();
        reservations.removeWhere((uid, expiryTs) {
          final expiry = (expiryTs as Timestamp).toDate();
          return expiry.isBefore(now);
        });

        if (available <= 0) throw Exception('no_copies');
        if (borrowedBy.contains(userId)) throw Exception('already_borrowed');
        if (reservations.containsKey(userId)) {
          throw Exception('already_reserved');
        }

        // Enforce borrow limit of 3 books per user
        final userBorrowSnap = await _firestore
            .collection('books')
            .where('borrowed_by', arrayContains: userId)
            .count()
            .get();
        final totalBorrowed = userBorrowSnap.count ?? 0;
        if (totalBorrowed >= 3) throw Exception('borrow_limit');

        // Reserve for 3 days
        final expiry = Timestamp.fromDate(now.add(const Duration(days: 3)));
        reservations[userId] = expiry;

        transaction.update(docRef, {
          'borrowed_by': FieldValue.arrayUnion([userId]),
          'available_copies': FieldValue.increment(-1),
          'borrow_count': FieldValue.increment(1),
          'is_available': available - 1 > 0,
          'reservations': reservations,
          'reservation_expires_at': expiry,
        });
      });

      _updateBookLocally(bookId, userId, borrowed: true);
      return true;
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('no_copies')) {
        _error = 'No copies available.';
      } else if (msg.contains('already_borrowed')) {
        _error = 'You already borrowed this book.';
      } else if (msg.contains('already_reserved')) {
        _error = 'You already reserved this book.';
      } else if (msg.contains('borrow_limit')) {
        _error = 'You can only borrow 3 books at a time.';
      } else {
        _error = 'Failed to borrow: $e';
      }
      notifyListeners();
      return false;
    }
  }

  Future<void> releaseExpiredReservations() async {
    try {
      final now = Timestamp.now();
      final snap = await _firestore
          .collection('books')
          .where('reservation_expires_at', isLessThan: now)
          .get();

      for (final doc in snap.docs) {
        final data = doc.data();
        final reservations = Map<String, dynamic>.from(
          data['reservations'] ?? {},
        );

        // Find expired user IDs
        final expiredUsers = reservations.entries
            .where(
              (e) => (e.value as Timestamp).toDate().isBefore(now.toDate()),
            )
            .map((e) => e.key)
            .toList();

        if (expiredUsers.isEmpty) continue;

        reservations.removeWhere((uid, _) => expiredUsers.contains(uid));

        await doc.reference.update({
          'borrowed_by': FieldValue.arrayRemove(expiredUsers),
          'available_copies': FieldValue.increment(expiredUsers.length),
          'reservations': reservations,
          'is_available': true,
        });
      }
    } catch (e) {
      debugPrint('releaseExpiredReservations error: $e');
    }
  }

  Future<bool> returnBook({
    required String bookId,
    required String userId,
  }) async {
    try {
      await _firestore.collection('books').doc(bookId).update({
        'borrowed_by': FieldValue.arrayRemove([userId]),
        'available_copies': FieldValue.increment(1),
      });

      _updateBookLocally(bookId, userId, borrowed: false);
      return true;
    } catch (e) {
      _error = 'Failed to return: $e';
      notifyListeners();
      return false;
    }
  }

  void _updateBookLocally(
    String bookId,
    String userId, {
    required bool borrowed,
  }) {
    for (final list in [_trending, _featured, _allBooks, _searchResults]) {
      final idx = list.indexWhere((b) => b.id == bookId);
      if (idx == -1) continue;
      final b = list[idx];
      final updatedReservedBy = List<dynamic>.from(b.reservedBy);
      if (borrowed) {
        updatedReservedBy.add(userId);
      } else {
        updatedReservedBy.remove(userId);
      }
      list[idx] = b.copyWith(
        reservedBy: updatedReservedBy,
        availableCopies: borrowed
            ? b.availableCopies - 1
            : b.availableCopies + 1,
        borrowCount: borrowed ? b.borrowCount + 1 : b.borrowCount,
      );
    }
    notifyListeners();
  }

  Future<List<Book>> fetchUserBorrowedBooks(String userId) async {
    try {
      final snap = await _firestore
          .collection('books')
          .where('borrowed_by', arrayContains: userId)
          .get();

      return snap.docs.map(Book.fromFirestore).toList();
    } catch (e) {
      _error = 'Failed to load borrowed books: $e';
      notifyListeners();
      return [];
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
