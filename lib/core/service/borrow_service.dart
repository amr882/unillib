import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unilib/core/model/borrow_model.dart';
import 'package:unilib/core/service/notification_service.dart';

class BorrowScanResult {
  final bool success;
  final String? error;
  BorrowScanResult({required this.success, this.error});
}

class BorrowService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<BorrowRecord?> fetchRecord(String borrowId) async {
    try {
      final doc = await _firestore.collection('borrows').doc(borrowId).get();
      if (!doc.exists) return null;
      return BorrowRecord.fromMap(doc.data()!);
    } catch (e) {
      return null;
    }
  }

  Future<BorrowScanResult> confirmPickup(String borrowId) async {
    try {
      final docRef = _firestore.collection('borrows').doc(borrowId);
      final doc = await docRef.get();
      if (!doc.exists) return BorrowScanResult(success: false, error: 'Record not found.');

      final record = BorrowRecord.fromMap(doc.data()!);
      if (record.status != BorrowStatus.pendingPickup) {
        return BorrowScanResult(success: false, error: 'Book already picked up or cancelled.');
      }

      await docRef.update({
        'status': 'active_borrow',
        'pickupConfirmedAt': FieldValue.serverTimestamp(),
      });

      return BorrowScanResult(success: true);
    } catch (e) {
      return BorrowScanResult(success: false, error: e.toString());
    }
  }

  Future<BorrowScanResult> confirmReturn(String borrowId) async {
    try {
      final docRef = _firestore.collection('borrows').doc(borrowId);
      final doc = await docRef.get();
      
      if (!doc.exists) return BorrowScanResult(success: false, error: 'Record not found.');

      final record = BorrowRecord.fromMap(doc.data()!);
      if (record.status != BorrowStatus.activeBorrow) {
        return BorrowScanResult(success: false, error: 'Book is not currently borrowed.');
      }

      // Run as transaction to safely increment book copies and clear reservations
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

      // Notification upon successful return
      try {
        final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
        NotificationService().showNotification(
          id: notificationId,
          title: 'Book Returned! 📚',
          body: 'Your return for "${record.bookTitle}" has been successfully confirmed. Thank you!',
        );
      } catch (e) {
        // Failing to send a local push should not fail the whole transaction
        print('Failed to show notification: $e');
      }

      return BorrowScanResult(success: true);
    } catch (e) {
      return BorrowScanResult(success: false, error: e.toString());
    }
  }
}
