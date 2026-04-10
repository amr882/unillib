import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/model/borrow_model.dart';
import 'package:unilib/core/service/notification_service.dart';
import 'package:unilib/feature/home/logic/book_catalog_provider.dart';

class UserBooksProvider extends ChangeNotifier {
  final BookCatalogProvider _catalogProvider;
  String? _error;

  String? get error => _error;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserBooksProvider(this._catalogProvider) {
    releaseExpiredReservations();
  }

  Future<bool> _checkConnectivity() async {
    final List<ConnectivityResult> results =
        await Connectivity().checkConnectivity();
    if (results.contains(ConnectivityResult.none)) {
      _error =
          'No internet connection. Please check your network and try again.';
      notifyListeners();
      return false;
    }
    return true;
  }

  /// User initiates a borrow request.
  ///
  /// Creates a `borrows` doc with [BorrowStatus.pendingPickup].
  /// Decrements [available_copies] immediately so other users see correct
  /// availability. Admin must scan the QR to confirm actual pickup.
  Future<String?> borrowBook({
    required String bookId,
    required String userId,
    required String bookTitle,
    required String bookAuthor,
    required String bookCoverUrl,
  }) async {
    if (!await _checkConnectivity()) return null;
    try {
      final bookRef = _firestore.collection('books').doc(bookId);
      final borrowRef = _firestore.collection('borrows').doc(); // auto-ID
      final borrowId = borrowRef.id;

      await _firestore.runTransaction((transaction) async {
        final snap = await transaction.get(bookRef);
        final data = snap.data() ?? {};

        final available = (data['available_copies'] as num?)?.toInt() ?? 0;
        final borrowedBy = List<dynamic>.from(data['borrowed_by'] ?? []);
        final reservations = Map<String, dynamic>.from(
          data['reservations'] ?? {},
        );

        // Clear expired reservations before checking
        final now = DateTime.now();
        reservations.removeWhere((uid, val) {
          if (val is Timestamp) return val.toDate().isBefore(now);
          if (val is Map) {
            final ts = val['expiresAt'];
            if (ts is Timestamp) return ts.toDate().isBefore(now);
          }
          return false;
        });

        if (available <= 0) throw Exception('no_copies');
        if (borrowedBy.contains(userId)) throw Exception('already_borrowed');
        if (reservations.containsKey(userId)) {
          throw Exception('already_reserved');
        }

        // Enforce borrow limit of 3 books per user
        final userBorrowSnap = await _firestore
            .collection('borrows')
            .where('userId', isEqualTo: userId)
            .where('status', whereIn: [
              BorrowStatus.pendingPickup.firestoreValue,
              BorrowStatus.activeBorrow.firestoreValue,
            ])
            .count()
            .get();
        final totalBorrowed = userBorrowSnap.count ?? 0;
        if (totalBorrowed >= 3) throw Exception('borrow_limit');

        final pickupDeadline = Timestamp.fromDate(
          now.add(const Duration(hours: 48)),
        );

        // Store borrowId reference inside reservation entry
        reservations[userId] = {
          'expiresAt': pickupDeadline,
          'borrowId': borrowId,
        };

        // Update book
        transaction.update(bookRef, {
          'borrowed_by': FieldValue.arrayUnion([userId]),
          'available_copies': FieldValue.increment(-1),
          'borrow_count': FieldValue.increment(1),
          'is_available': available - 1 > 0,
          'reservations': reservations,
          'reservation_expires_at': pickupDeadline,
        });

        // Create borrow record
        transaction.set(borrowRef, {
          'borrowId': borrowId,
          'userId': userId,
          'bookId': bookId,
          'bookTitle': bookTitle,
          'bookAuthor': bookAuthor,
          'bookCoverUrl': bookCoverUrl,
          'status': BorrowStatus.pendingPickup.firestoreValue,
          'createdAt': Timestamp.fromDate(now),
          'pickupDeadline': pickupDeadline,
        });
      });

      _catalogProvider.updateBookLocally(bookId, userId, borrowed: true);

      // Schedule reminder 44h after borrow (4h before 48h expiry)
      await NotificationService().scheduleNotification(
        id: bookId.hashCode,
        title: '⏰ Pickup Reminder!',
        body:
            'You have only 4 hours left to pick up "$bookTitle" from the library or your request will be automatically cancelled!',
        scheduledDate: DateTime.now().add(const Duration(hours: 44)),
      );

      return borrowId;
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('no_copies')) {
        _error = 'No copies available.';
      } else if (msg.contains('already_borrowed')) {
        _error = 'You already borrowed this book.';
      } else if (msg.contains('already_reserved')) {
        _error = 'You already have a pending request for this book.';
      } else if (msg.contains('borrow_limit')) {
        _error = 'You can only borrow 3 books at a time.';
      } else {
        _error = 'Failed to borrow: $e';
      }
      notifyListeners();
      return null;
    }
  }

  /// User cancels their own borrow — only allowed while [BorrowStatus.pendingPickup].
  ///
  /// Once admin confirms pickup (`active_borrow`), only the admin can complete
  /// the return via a second QR scan.
  Future<bool> cancelPendingBorrow({
    required String bookId,
    required String userId,
    required String borrowId,
  }) async {
    if (!await _checkConnectivity()) return false;
    try {
      final borrowRef = _firestore.collection('borrows').doc(borrowId);
      final bookRef = _firestore.collection('books').doc(bookId);

      await _firestore.runTransaction((tx) async {
        final borrowSnap = await tx.get(borrowRef);
        if (!borrowSnap.exists) throw Exception('not_found');

        final record = BorrowRecord.fromMap(borrowSnap.data()!);
        if (!record.canUserCancel) {
          throw Exception('already_picked_up');
        }

        final bookSnap = await tx.get(bookRef);
        final bookData = bookSnap.data() ?? {};
        final reservations = Map<String, dynamic>.from(
          bookData['reservations'] ?? {},
        );
        reservations.remove(userId);

        // Remove borrow record
        tx.delete(borrowRef);

        // Restore book
        tx.update(bookRef, {
          'borrowed_by': FieldValue.arrayRemove([userId]),
          'available_copies': FieldValue.increment(1),
          'is_available': true,
          'reservations': reservations,
        });
      });

      _catalogProvider.updateBookLocally(bookId, userId, borrowed: false);
      await NotificationService().cancelNotification(bookId.hashCode);

      return true;
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('already_picked_up')) {
        _error =
            'Book already confirmed as picked up. Only the librarian can process the return.';
      } else {
        _error = 'Failed to cancel: $e';
      }
      notifyListeners();
      return false;
    }
  }

  /// Fetch all active borrow records for a user (pending or active).
  Future<List<BorrowRecord>> fetchUserBorrows(String userId) async {
    try {
      final snap = await _firestore
          .collection('borrows')
          .where('userId', isEqualTo: userId)
          .where('status', whereIn: [
            BorrowStatus.pendingPickup.firestoreValue,
            BorrowStatus.activeBorrow.firestoreValue,
          ])
          .orderBy('createdAt', descending: true)
          .get();

      return snap.docs
          .map((d) => BorrowRecord.fromMap(d.data()))
          .toList();
    } catch (e) {
      _error = 'Failed to load your borrows: $e';
      notifyListeners();
      return [];
    }
  }

  /// Legacy: fetch borrowed books as Book objects (used for catalog state).
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

  /// Auto-release expired pending_pickup borrows (runs on app startup).
  Future<void> releaseExpiredReservations() async {
    try {
      final now = Timestamp.now();

      // Find borrows that are still pending_pickup but past their pickup deadline
      final snap = await _firestore
          .collection('borrows')
          .where('status', isEqualTo: BorrowStatus.pendingPickup.firestoreValue)
          .where('pickupDeadline', isLessThan: now)
          .get();

      for (final doc in snap.docs) {
        final record = BorrowRecord.fromMap(doc.data());
        try {
          final bookRef = _firestore.collection('books').doc(record.bookId);
          final bookSnap = await bookRef.get();
          final bookData = bookSnap.data() ?? {};
          final reservations = Map<String, dynamic>.from(
            bookData['reservations'] ?? {},
          );
          reservations.remove(record.userId);

          // Delete borrow record
          await doc.reference.delete();

          // Restore book
          await bookRef.update({
            'borrowed_by': FieldValue.arrayRemove([record.userId]),
            'available_copies': FieldValue.increment(1),
            'is_available': true,
            'reservations': reservations,
          });
        } catch (e) {
          debugPrint('releaseExpiredReservations: error for ${record.borrowId}: $e');
        }
      }
    } catch (e) {
      debugPrint('releaseExpiredReservations error: $e');
    }
  }
}
