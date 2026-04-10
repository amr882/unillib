import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:unilib/core/model/borrow_model.dart';

/// Result from an admin QR scan action.
class BorrowScanResult {
  final bool success;
  final String? error;
  final BorrowRecord? record;       // populated on success
  final BorrowStatus? actionTaken;  // what action was performed

  const BorrowScanResult._({
    required this.success,
    this.error,
    this.record,
    this.actionTaken,
  });

  factory BorrowScanResult.ok(BorrowRecord record, BorrowStatus action) =>
      BorrowScanResult._(success: true, record: record, actionTaken: action);

  factory BorrowScanResult.err(String message) =>
      BorrowScanResult._(success: false, error: message);
}

/// Service used by the admin QR scanner.
/// Handles confirming pickup and return via admin scanning.
class BorrowService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch a borrow record by its ID.
  Future<BorrowRecord?> fetchRecord(String borrowId) async {
    try {
      final doc = await _firestore.collection('borrows').doc(borrowId).get();
      if (!doc.exists || doc.data() == null) return null;
      return BorrowRecord.fromMap(doc.data()!);
    } catch (e) {
      debugPrint('BorrowService.fetchRecord error: $e');
      return null;
    }
  }

  /// Admin Scan #1 — Confirm the user picked up the book.
  ///
  /// Transitions: pending_pickup → active_borrow
  /// Sets: pickupConfirmedAt, returnDeadline (+14 days)
  Future<BorrowScanResult> confirmPickup(String borrowId) async {
    try {
      final docRef = _firestore.collection('borrows').doc(borrowId);

      late BorrowRecord updatedRecord;

      await _firestore.runTransaction((tx) async {
        final snap = await tx.get(docRef);
        if (!snap.exists) throw Exception('not_found');

        final record = BorrowRecord.fromMap(snap.data()!);
        if (record.status != BorrowStatus.pendingPickup) {
          throw Exception('wrong_status:${record.status.firestoreValue}');
        }

        final now = DateTime.now();
        final returnDeadline = now.add(const Duration(days: 14));

        tx.update(docRef, {
          'status': BorrowStatus.activeBorrow.firestoreValue,
          'pickupConfirmedAt': Timestamp.fromDate(now),
          'returnDeadline': Timestamp.fromDate(returnDeadline),
        });

        updatedRecord = record.copyWith(
          status: BorrowStatus.activeBorrow,
          pickupConfirmedAt: now,
          returnDeadline: returnDeadline,
        );
      });

      return BorrowScanResult.ok(updatedRecord, BorrowStatus.activeBorrow);
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('not_found')) {
        return BorrowScanResult.err('Borrow record not found. Invalid QR code.');
      } else if (msg.contains('wrong_status')) {
        final status = msg.split(':').last.replaceAll(')', '');
        if (status == 'active_borrow') {
          return BorrowScanResult.err('Book already confirmed as picked up.');
        } else if (status == 'returned') {
          return BorrowScanResult.err('This book has already been returned.');
        }
        return BorrowScanResult.err('Cannot confirm pickup: unexpected status.');
      }
      return BorrowScanResult.err('Failed to confirm pickup: $e');
    }
  }

  /// Admin Scan #2 — Confirm the user returned the book.
  ///
  /// Transitions: active_borrow → returned
  /// Restores: book's available_copies, removes from borrowed_by
  Future<BorrowScanResult> confirmReturn(String borrowId) async {
    try {
      final borrowDocRef = _firestore.collection('borrows').doc(borrowId);

      late BorrowRecord updatedRecord;

      await _firestore.runTransaction((tx) async {
        final snap = await tx.get(borrowDocRef);
        if (!snap.exists) throw Exception('not_found');

        final record = BorrowRecord.fromMap(snap.data()!);
        if (record.status != BorrowStatus.activeBorrow) {
          throw Exception('wrong_status:${record.status.firestoreValue}');
        }

        final bookRef = _firestore.collection('books').doc(record.bookId);
        final bookSnap = await tx.get(bookRef);

        final now = DateTime.now();

        // Mark borrow as returned
        tx.update(borrowDocRef, {
          'status': BorrowStatus.returned.firestoreValue,
          'returnConfirmedAt': Timestamp.fromDate(now),
        });

        // Restore book availability
        if (bookSnap.exists) {
          final bookData = bookSnap.data() ?? {};
          final availableCopies = (bookData['available_copies'] as num?)?.toInt() ?? 0;
          final reservations = Map<String, dynamic>.from(bookData['reservations'] ?? {});
          reservations.remove(record.userId);

          tx.update(bookRef, {
            'borrowed_by': FieldValue.arrayRemove([record.userId]),
            'available_copies': FieldValue.increment(1),
            'is_available': availableCopies + 1 > 0,
            'reservations': reservations,
          });
        }

        updatedRecord = record.copyWith(
          status: BorrowStatus.returned,
          returnConfirmedAt: now,
        );
      });

      return BorrowScanResult.ok(updatedRecord, BorrowStatus.returned);
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('not_found')) {
        return BorrowScanResult.err('Borrow record not found. Invalid QR code.');
      } else if (msg.contains('wrong_status')) {
        final status = msg.split(':').last.replaceAll(')', '');
        if (status == 'pending_pickup') {
          return BorrowScanResult.err('Book not confirmed as picked up yet. Scan for pickup first.');
        } else if (status == 'returned') {
          return BorrowScanResult.err('This book has already been returned.');
        }
        return BorrowScanResult.err('Cannot confirm return: unexpected status.');
      }
      return BorrowScanResult.err('Failed to confirm return: $e');
    }
  }
}
