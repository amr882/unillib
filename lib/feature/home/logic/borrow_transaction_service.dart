import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unilib/core/model/borrow_model.dart';

/// Handles Firestore transactions for borrowing and cancelling books.
class BorrowTransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Executes a borrow transaction and returns the new borrowId on success.
  Future<String> borrowBook({
    required String bookId,
    required String userId,
  }) async {
    final docRef = _firestore.collection('books').doc(bookId);
    String borrowId = '';

    await _firestore.runTransaction((transaction) async {
      final snap = await transaction.get(docRef);
      final bookTitle = snap.data()?['title'] ?? 'Book';
      final bookAuthor = snap.data()?['author'] ?? 'Unknown';
      final bookCoverUrl = snap.data()?['cover_url'] ?? '';

      final available = (snap.data()?['available_copies'] ?? 0) as int;
      final borrowedBy = List<dynamic>.from(snap.data()?['borrowed_by'] ?? []);
      final reservations = Map<String, dynamic>.from(
        snap.data()?['reservations'] ?? {},
      );

      if (available <= 0) throw Exception('no_copies');
      if (borrowedBy.contains(userId)) throw Exception('already_borrowed');

      // Enforce borrow limit of 3 books per user
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

    return borrowId;
  }

  /// Cancels a pending borrow by reversing the book's state and updating the borrow record.
  Future<void> cancelPendingBorrow({
    required String bookId,
    required String userId,
    required String borrowId,
  }) async {
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
  }

  /// Returns a human-readable error message for known borrow exceptions.
  String? parseError(String errorMsg) {
    if (errorMsg.contains('no_copies')) {
      return 'No copies available.';
    } else if (errorMsg.contains('already_borrowed')) {
      return 'You already requested this book.';
    } else if (errorMsg.contains('borrow_limit')) {
      return 'You can only borrow 3 books at a time.';
    } else if (errorMsg.contains('not_cancellable')) {
      return 'Cannot cancel active borrows.';
    }
    return null;
  }
}
