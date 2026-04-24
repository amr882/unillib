import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unilib/core/model/borrow_model.dart';
import 'package:unilib/core/model/user_model.dart';
import 'package:unilib/core/service/notification_service.dart';

/// Handles heavy Firestore transaction operations for admin borrow management:
/// confirmPickup, confirmReturn, and rejectRequest.
class AdminBorrowActions {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches a single borrow record by ID (used for QR scan results).
  Future<BorrowRecord?> fetchBorrowById(String borrowId) async {
    final doc = await _firestore.collection('borrows').doc(borrowId).get();
    if (!doc.exists) return null;
    return BorrowRecord.fromMap(doc.data()!);
  }

  /// Fetches user details by ID.
  Future<UserModel?> fetchUserDetails(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      debugPrint('Failed to fetch user: $e');
      return null;
    }
  }

  /// Confirms pickup: transitions a borrow from pending_pickup → active_borrow.
  /// Returns null on success, or an error message on failure.
  Future<String?> confirmPickup(String borrowId) async {
    final docRef = _firestore.collection('borrows').doc(borrowId);
    final doc = await docRef.get();
    if (!doc.exists) return 'Borrow record not found.';

    final record = BorrowRecord.fromMap(doc.data()!);
    if (record.status != BorrowStatus.pendingPickup) {
      return 'This borrow is not pending pickup.';
    }

    await docRef.update({
      'status': 'active_borrow',
      'pickupConfirmedAt': FieldValue.serverTimestamp(),
    });

    // Show local notification
    try {
      final nId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
      NotificationService().showNotification(
        id: nId,
        title: 'Pickup Confirmed ✅',
        body:
            '"${record.bookTitle}" has been picked up. Return within 14 days.',
      );
    } catch (_) {}

    return null; // success
  }

  /// Confirms return: transitions a borrow from active_borrow → returned,
  /// and restores the book's availability in a transaction.
  /// Returns null on success, or an error message on failure.
  Future<String?> confirmReturn(String borrowId) async {
    final docRef = _firestore.collection('borrows').doc(borrowId);
    final doc = await docRef.get();
    if (!doc.exists) return 'Borrow record not found.';

    final record = BorrowRecord.fromMap(doc.data()!);
    if (record.status != BorrowStatus.activeBorrow) {
      return 'This borrow is not active.';
    }

    await _firestore.runTransaction((transaction) async {
      final bookRef = _firestore.collection('books').doc(record.bookId);
      final bookDoc = await transaction.get(bookRef);

      if (bookDoc.exists) {
        final bookData = bookDoc.data()!;
        int copies = bookData['available_copies'] ?? 0;
        List borrowedBy = List.from(bookData['borrowed_by'] ?? []);
        Map reservations = Map.from(bookData['reservations'] ?? {});

        borrowedBy.remove(record.userId);
        reservations.remove(record.userId);
        reservations.remove('${record.userId}_borrowId');

        transaction.update(bookRef, {
          'available_copies': copies + 1,
          'is_available': true,
          'borrowed_by': borrowedBy,
          'reservations': reservations,
        });
      }

      transaction.update(docRef, {
        'status': 'returned',
        'returnConfirmedAt': FieldValue.serverTimestamp(),
      });
    });

    // Show local notification
    try {
      final nId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
      NotificationService().showNotification(
        id: nId,
        title: 'Book Returned 📚',
        body: '"${record.bookTitle}" has been returned successfully.',
      );
    } catch (_) {}

    return null; // success
  }

  /// Rejects/cancels a borrow request, restoring the book's availability.
  /// Returns null on success, or an error message on failure.
  Future<String?> rejectRequest(String borrowId) async {
    final docRef = _firestore.collection('borrows').doc(borrowId);
    final doc = await docRef.get();
    if (!doc.exists) return 'Borrow record not found.';

    final record = BorrowRecord.fromMap(doc.data()!);

    await _firestore.runTransaction((transaction) async {
      final bookRef = _firestore.collection('books').doc(record.bookId);
      final bookDoc = await transaction.get(bookRef);

      if (bookDoc.exists) {
        final bookData = bookDoc.data()!;
        int copies = bookData['available_copies'] ?? 0;
        List borrowedBy = List.from(bookData['borrowed_by'] ?? []);
        Map reservations = Map.from(bookData['reservations'] ?? {});

        borrowedBy.remove(record.userId);
        reservations.remove(record.userId);
        reservations.remove('${record.userId}_borrowId');

        transaction.update(bookRef, {
          'available_copies': copies + 1,
          'is_available': true,
          'borrowed_by': borrowedBy,
          'reservations': reservations,
        });
      }

      transaction.update(docRef, {'status': 'cancelled'});
    });

    return null; // success
  }
}
