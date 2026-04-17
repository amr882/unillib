import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unilib/core/model/borrow_model.dart';
import 'package:unilib/core/model/user_model.dart';
import 'package:unilib/core/service/notification_service.dart';

class AdminProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<BorrowRecord> _allBorrows = [];
  bool _isLoading = false;
  String? _error;

  List<BorrowRecord> get allBorrows => _allBorrows;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Computed filters ─────────────────────────────────────────
  List<BorrowRecord> get pendingBorrows =>
      _allBorrows.where((b) => b.status == BorrowStatus.pendingPickup).toList();

  List<BorrowRecord> get activeBorrows =>
      _allBorrows.where((b) => b.status == BorrowStatus.activeBorrow).toList();

  List<BorrowRecord> get overdueBorrows => _allBorrows.where((b) {
        if (b.status != BorrowStatus.activeBorrow) return false;
        if (b.pickupConfirmedAt == null) return false;
        final deadline = b.pickupConfirmedAt!.add(const Duration(days: 14));
        return DateTime.now().isAfter(deadline);
      }).toList();

  List<BorrowRecord> get returnedBorrows {
    final returned = _allBorrows.where((b) => b.status == BorrowStatus.returned).toList();
    // Sort by returnConfirmedAt descending (latest first)
    returned.sort((a, b) {
      if (a.returnConfirmedAt == null) return 1;
      if (b.returnConfirmedAt == null) return -1;
      return b.returnConfirmedAt!.compareTo(a.returnConfirmedAt!);
    });
    return returned;
  }

  int get todayReturnedCount {
    final now = DateTime.now();
    return returnedBorrows.where((b) {
      if (b.returnConfirmedAt == null) return false;
      return b.returnConfirmedAt!.year == now.year &&
          b.returnConfirmedAt!.month == now.month &&
          b.returnConfirmedAt!.day == now.day;
    }).length;
  }

  // ── Fetch all borrows ────────────────────────────────────────
  Future<void> fetchAllBorrows() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snap = await _firestore
          .collection('borrows')
          .orderBy('createdAt', descending: true)
          .get();

      _allBorrows =
          snap.docs.map((doc) => BorrowRecord.fromMap(doc.data())).toList();
    } catch (e) {
      _error = 'Failed to load borrows: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Fetch single borrow by ID (for QR scan) ─────────────────
  Future<BorrowRecord?> fetchBorrowById(String borrowId) async {
    try {
      final doc = await _firestore.collection('borrows').doc(borrowId).get();
      if (!doc.exists) return null;
      return BorrowRecord.fromMap(doc.data()!);
    } catch (e) {
      _error = 'Failed to fetch borrow: $e';
      notifyListeners();
      return null;
    }
  }

  // ── Fetch user details ──────────────────────────────────────
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

  // ── Confirm Pickup (pending → active) ───────────────────────
  Future<bool> confirmPickup(String borrowId) async {
    try {
      final docRef = _firestore.collection('borrows').doc(borrowId);
      final doc = await docRef.get();
      if (!doc.exists) {
        _error = 'Borrow record not found.';
        notifyListeners();
        return false;
      }

      final record = BorrowRecord.fromMap(doc.data()!);
      if (record.status != BorrowStatus.pendingPickup) {
        _error = 'This borrow is not pending pickup.';
        notifyListeners();
        return false;
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

      await fetchAllBorrows();
      return true;
    } catch (e) {
      _error = 'Failed to confirm pickup: $e';
      notifyListeners();
      return false;
    }
  }

  // ── Confirm Return (active → returned) ──────────────────────
  Future<bool> confirmReturn(String borrowId) async {
    try {
      final docRef = _firestore.collection('borrows').doc(borrowId);
      final doc = await docRef.get();
      if (!doc.exists) {
        _error = 'Borrow record not found.';
        notifyListeners();
        return false;
      }

      final record = BorrowRecord.fromMap(doc.data()!);
      if (record.status != BorrowStatus.activeBorrow) {
        _error = 'This borrow is not active.';
        notifyListeners();
        return false;
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
          body:
              '"${record.bookTitle}" has been returned successfully.',
        );
      } catch (_) {}

      await fetchAllBorrows();
      return true;
    } catch (e) {
      _error = 'Failed to confirm return: $e';
      notifyListeners();
      return false;
    }
  }

  // ── Reject / Cancel Request ─────────────────────────────────
  Future<bool> rejectRequest(String borrowId) async {
    try {
      final docRef = _firestore.collection('borrows').doc(borrowId);
      final doc = await docRef.get();
      if (!doc.exists) {
        _error = 'Borrow record not found.';
        notifyListeners();
        return false;
      }

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

        transaction.update(docRef, {
          'status': 'cancelled',
        });
      });

      await fetchAllBorrows();
      return true;
    } catch (e) {
      _error = 'Failed to reject request: $e';
      notifyListeners();
      return false;
    }
  }

  // ── Search borrows by student name / ID ─────────────────────
  List<BorrowRecord> searchBorrows(String query) {
    if (query.isEmpty) return _allBorrows;
    final q = query.toLowerCase();
    return _allBorrows.where((b) {
      return b.bookTitle.toLowerCase().contains(q) ||
          b.userId.toLowerCase().contains(q) ||
          b.borrowId.toLowerCase().contains(q);
    }).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
