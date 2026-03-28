import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/feature/home/logic/book_catalog_provider.dart';

class UserBooksProvider extends ChangeNotifier {
  final BookCatalogProvider _catalogProvider;
  String? _error;

  String? get error => _error;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserBooksProvider(this._catalogProvider) {
    releaseExpiredReservations();
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

      _catalogProvider.updateBookLocally(bookId, userId, borrowed: true);
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
        'reservations.$userId': FieldValue.delete(),
      });

      _catalogProvider.updateBookLocally(bookId, userId, borrowed: false);
      return true;
    } catch (e) {
      _error = 'Failed to return: $e';
      notifyListeners();
      return false;
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
}
