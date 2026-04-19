import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/model/borrow_model.dart';
import 'package:unilib/feature/home/logic/book_catalog_provider.dart';

class UserBooksProvider extends ChangeNotifier {
  final BookCatalogProvider _catalogProvider;
  int _activeBorrowCount = 0;
  String? _error;

  int get activeBorrowCount => _activeBorrowCount;
  String? get error => _error;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserBooksProvider(this._catalogProvider);

  Future<bool> _checkConnectivity() async {
    final List<ConnectivityResult> results = await Connectivity()
        .checkConnectivity();
    if (results.contains(ConnectivityResult.none)) {
      _error =
          'No internet connection. Please check your network and try again.';
      notifyListeners();
      return false;
    }
    return true;
  }

  Future<bool> borrowBook({
    required String bookId,
    required String userId,
  }) async {
    if (!await _checkConnectivity()) return false;
    try {
      final docRef = _firestore.collection('books').doc(bookId);

      String borrowId = '';

      await _firestore.runTransaction((transaction) async {
        final snap = await transaction.get(docRef);
        final bookTitle = snap.data()?['title'] ?? 'Book';
        final bookAuthor = snap.data()?['author'] ?? 'Unknown';
        final bookCoverUrl = snap.data()?['cover_url'] ?? '';

        final available = (snap.data()?['available_copies'] ?? 0) as int;
        final borrowedBy = List<dynamic>.from(
          snap.data()?['borrowed_by'] ?? [],
        );
        final reservations = Map<String, dynamic>.from(
          snap.data()?['reservations'] ?? {},
        );

        if (available <= 0) throw Exception('no_copies');
        if (borrowedBy.contains(userId)) throw Exception('already_borrowed');

        // Enforce borrow limit of 3 books per user
        // Note: in transaction this is best-effort unless we use a counters doc or specific user collection limits
        QuerySnapshot activeBorrows = await _firestore
            .collection('borrows')
            .where('userId', isEqualTo: userId)
            .where('status', whereIn: ['pending_pickup', 'active_borrow'])
            .get();

        if (activeBorrows.docs.length >= 3) throw Exception('borrow_limit');

        final newBorrowRef = _firestore.collection('borrows').doc();
        borrowId = newBorrowRef.id;

        final now = DateTime.now();
        final expiry = Timestamp.fromDate(now.add(const Duration(hours: 48)));

        reservations[userId] = expiry;
        reservations['${userId}_borrowId'] = borrowId; // link them

        transaction.update(docRef, {
          'borrowed_by': FieldValue.arrayUnion([userId]),
          'available_copies': FieldValue.increment(-1),
          'borrow_count': FieldValue.increment(1),
          'is_available': available - 1 > 0,
          'reservations': reservations,
        });

        BorrowRecord record = BorrowRecord(
          borrowId: borrowId,
          userId: userId,
          bookId: bookId,
          bookTitle: bookTitle,
          bookAuthor: bookAuthor,
          bookCoverUrl: bookCoverUrl,
          status: BorrowStatus.pendingPickup,
          createdAt: now,
          pickupDeadline: now.add(const Duration(hours: 48)),
        );

        transaction.set(newBorrowRef, record.toMap());
      });

      _catalogProvider.updateBookLocally(bookId, userId, borrowed: true);
      await syncBorrowCount(userId);
      return true;
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('no_copies')) {
        _error = 'No copies available.';
      } else if (msg.contains('already_borrowed')) {
        _error = 'You already requested this book.';
      } else if (msg.contains('borrow_limit')) {
        _error = 'You can only borrow 3 books at a time.';
      } else {
        _error = 'Failed to borrow: $e';
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelPendingBorrow({
    required String bookId,
    required String userId,
    required String borrowId,
  }) async {
    if (!await _checkConnectivity()) return false;
    try {
      await _firestore.runTransaction((transaction) async {
        final bookRef = _firestore.collection('books').doc(bookId);
        final borrowRef = _firestore.collection('borrows').doc(borrowId);

        final borrowDoc = await transaction.get(borrowRef);
        final bookDoc = await transaction.get(bookRef);

        if (borrowDoc.exists) {
          final record = BorrowRecord.fromMap(borrowDoc.data()!);
          if (record.status != BorrowStatus.pendingPickup) {
            throw Exception('not_cancellable');
          }

          transaction.update(borrowRef, {'status': 'cancelled'});
        }

        if (bookDoc.exists) {
          final bookData = bookDoc.data()!;
          int copies = bookData['available_copies'] ?? 0;
          List borrowedBy = List.from(bookData['borrowed_by'] ?? []);
          Map reservations = Map.from(bookData['reservations'] ?? {});

          borrowedBy.remove(userId);
          reservations.remove(userId);
          reservations.remove('${userId}_borrowId');

          transaction.update(bookRef, {
            'available_copies': copies + 1,
            'is_available': true,
            'borrowed_by': borrowedBy,
            'reservations': reservations,
          });
        }
      });

      _catalogProvider.updateBookLocally(bookId, userId, borrowed: false);
      await syncBorrowCount(userId);
      return true;
    } catch (e) {
      _error = 'Failed to cancel: $e';
      if (e.toString().contains('not_cancellable')) {
        _error = 'Cannot cancel active borrows.';
      }
      notifyListeners();
      return false;
    }
  }

  // Legacy method for transition compatibility - if it exists elsewhere, it routes to cancel
  Future<bool> returnBook({
    required String bookId,
    required String userId,
  }) async {
    // This is a dangerous method now that admin controls return.
    _error = "Please bring the book to the library desk to return.";
    notifyListeners();
    return false;
  }

  Future<List<BorrowRecord>> fetchUserBorrows(String userId) async {
    if (!await _checkConnectivity()) return [];
    try {
      final snap = await _firestore
          .collection('borrows')
          .where('userId', isEqualTo: userId)
          .get();

      final records = snap.docs
          .map((doc) => BorrowRecord.fromMap(doc.data()))
          .where(
            (r) =>
                r.status == BorrowStatus.pendingPickup ||
                r.status == BorrowStatus.activeBorrow,
          )
          .toList();

      _activeBorrowCount = records.length;
      records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
      return records;
    } catch (e) {
      _error = 'Failed to load borrow records: $e';
      notifyListeners();
      return [];
    }
  }

  Future<void> syncBorrowCount(String userId) async {
    if (!await _checkConnectivity()) return;
    try {
      final snap = await _firestore
          .collection('borrows')
          .where('userId', isEqualTo: userId)
          .where('status', whereIn: ['pending_pickup', 'active_borrow'])
          .get();

      _activeBorrowCount = snap.docs.length;
      notifyListeners();
    } catch (e) {
      debugPrint('Error syncing borrow count: $e');
    }
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

  Future<List<BorrowRecord>> fetchBorrowHistory(String userId) async {
    if (!await _checkConnectivity()) return [];
    try {
      final snap = await _firestore
          .collection('borrows')
          .where('userId', isEqualTo: userId)
          .get();

      final records = snap.docs
          .map((doc) => BorrowRecord.fromMap(doc.data()))
          .toList();

      records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return records;
    } catch (e) {
      _error = 'Failed to load history: $e';
      notifyListeners();
      return [];
    }
  }

  Future<bool> clearBorrowHistory(String userId) async {
    if (!await _checkConnectivity()) return false;
    try {
      final snap = await _firestore
          .collection('borrows')
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      int count = 0;

      for (var doc in snap.docs) {
        final status = doc.data()['status'];
        // Only clear records that are finished (returned or cancelled)
        if (status == 'cancelled' || status == 'returned') {
          batch.delete(doc.reference);
          count++;
        }
      }

      if (count > 0) {
        await batch.commit();
      }
      return true;
    } catch (e) {
      _error = 'Failed to clear history: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBorrowRecord(String borrowId) async {
    if (!await _checkConnectivity()) return false;
    try {
      await _firestore.collection('borrows').doc(borrowId).delete();
      return true;
    } catch (e) {
      _error = 'Failed to delete record: $e';
      notifyListeners();
      return false;
    }
  }

  // ── Real-time Streams
  Stream<List<BorrowRecord>> getBorrowRecordsStream(String userId) {
    return _firestore
        .collection('borrows')
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['pending_pickup', 'active_borrow'])
        .snapshots()
        .map((snapshot) {
          final records = snapshot.docs
              .map((doc) => BorrowRecord.fromMap(doc.data()))
              .toList();
          records.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          _activeBorrowCount = records.length;
          return records;
        });
  }

  // Returns a stream of a specific borrow record for a user and book.
  Stream<BorrowRecord?> getBorrowRecordForBookStream(
    String userId,
    String bookId,
  ) {
    return _firestore
        .collection('borrows')
        .where('userId', isEqualTo: userId)
        .where('bookId', isEqualTo: bookId)
        .where('status', whereIn: ['pending_pickup', 'active_borrow'])
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;

          return BorrowRecord.fromMap(snapshot.docs.first.data());
        });
  }
}
