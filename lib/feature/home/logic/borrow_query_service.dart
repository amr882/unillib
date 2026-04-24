import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/model/borrow_model.dart';

/// Handles all Firestore borrow record queries, streams, and history operations.
class BorrowQueryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches active borrow records (pending_pickup or active_borrow) for a user.
  Future<List<BorrowRecord>> fetchUserBorrows(String userId) async {
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

    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return records;
  }

  /// Counts active borrows for a user.
  Future<int> getActiveBorrowCount(String userId) async {
    final snap = await _firestore
        .collection('borrows')
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['pending_pickup', 'active_borrow'])
        .get();

    return snap.docs.length;
  }

  /// Fetches books currently borrowed by a user.
  Future<List<Book>> fetchUserBorrowedBooks(String userId) async {
    final snap = await _firestore
        .collection('books')
        .where('borrowed_by', arrayContains: userId)
        .get();

    return snap.docs.map(Book.fromFirestore).toList();
  }

  /// Fetches full borrow history for a user (all statuses).
  Future<List<BorrowRecord>> fetchBorrowHistory(String userId) async {
    final snap = await _firestore
        .collection('borrows')
        .where('userId', isEqualTo: userId)
        .get();

    final records = snap.docs
        .map((doc) => BorrowRecord.fromMap(doc.data()))
        .toList();

    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return records;
  }

  /// Clears completed borrow history (cancelled or returned records).
  Future<bool> clearBorrowHistory(String userId) async {
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
  }

  /// Deletes a single borrow record by ID.
  Future<void> deleteBorrowRecord(String borrowId) async {
    await _firestore.collection('borrows').doc(borrowId).delete();
  }

  // ── Real-time Streams ────────────────────────────────────────

  /// Returns a stream of active borrow records for a user.
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
          return records;
        });
  }

  /// Returns a stream of a specific borrow record for a user and book.
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
