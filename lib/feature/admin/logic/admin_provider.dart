import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unilib/core/model/borrow_model.dart';
import 'package:unilib/core/model/user_model.dart';
import 'admin_borrow_actions.dart';

class AdminProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AdminBorrowActions _actions = AdminBorrowActions();

  List<BorrowRecord> _allBorrows = [];
  List<UserModel> _allUsers = [];
  bool _isLoading = false;
  String? _error;

  List<BorrowRecord> get allBorrows => _allBorrows;
  List<UserModel> get allUsers => _allUsers;
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
    final returned = _allBorrows
        .where((b) => b.status == BorrowStatus.returned)
        .toList();
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

      _allBorrows = snap.docs
          .map((doc) => BorrowRecord.fromMap(doc.data()))
          .toList();
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
      return await _actions.fetchBorrowById(borrowId);
    } catch (e) {
      _error = 'Failed to fetch borrow: $e';
      notifyListeners();
      return null;
    }
  }

  // ── Fetch user details ──────────────────────────────────────
  Future<UserModel?> fetchUserDetails(String userId) async {
    return await _actions.fetchUserDetails(userId);
  }

  // ── Confirm Pickup (pending → active) ───────────────────────
  Future<bool> confirmPickup(String borrowId) async {
    try {
      final errorMsg = await _actions.confirmPickup(borrowId);
      if (errorMsg != null) {
        _error = errorMsg;
        notifyListeners();
        return false;
      }
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
      final errorMsg = await _actions.confirmReturn(borrowId);
      if (errorMsg != null) {
        _error = errorMsg;
        notifyListeners();
        return false;
      }
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
      final errorMsg = await _actions.rejectRequest(borrowId);
      if (errorMsg != null) {
        _error = errorMsg;
        notifyListeners();
        return false;
      }
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

  // ── Fetch all users ─────────────────────────────────────────
  Future<void> fetchAllUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snap = await _firestore
          .collection('users')
          .orderBy('firstName')
          .get();

      _allUsers = snap.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .where((user) => user.role != 'admin')
          .toList();
    } catch (e) {
      _error = 'Failed to load users: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Search users by name / ID / Email ───────────────────────
  List<UserModel> searchUsers(String query) {
    if (query.isEmpty) return _allUsers;
    final q = query.toLowerCase();
    return _allUsers.where((u) {
      return u.fullName.toLowerCase().contains(q) ||
          u.studentId.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q);
    }).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── Dynamic Analytics Helpers ────────────────────────────────

  int get totalBorrowsCount => _allBorrows.length;

  int get newUsersCount {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return _allUsers.where((u) {
      try {
        final dt = DateTime.parse(u.createdAt);
        return dt.isAfter(sevenDaysAgo);
      } catch (_) {
        return false;
      }
    }).length;
  }

  String get onTimeReturnRate {
    final returned = returnedBorrows;
    if (returned.isEmpty) return '0%';

    int onTime = 0;
    for (var b in returned) {
      if (b.pickupConfirmedAt != null && b.returnConfirmedAt != null) {
        final deadline = b.pickupConfirmedAt!.add(const Duration(days: 14));
        if (b.returnConfirmedAt!.isBefore(deadline) ||
            b.returnConfirmedAt!.isAtSameMomentAs(deadline)) {
          onTime++;
        }
      }
    }
    return '${((onTime / returned.length) * 100).toStringAsFixed(0)}%';
  }
}
