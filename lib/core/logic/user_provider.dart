import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../service/notification_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  StreamSubscription? _borrowsSubscription;
  final Map<String, String> _knownBorrowStatuses = {};
  bool _isBorrowsListenerInitialized = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserProvider() {
    _auth.authStateChanges().listen((firebaseUser) {
      if (firebaseUser != null) {
        fetchUser();
        _initBorrowsListener(firebaseUser.uid);
      } else {
        clearUser();
        _clearBorrowsListener();
      }
    });
  }

  @override
  void dispose() {
    _clearBorrowsListener();
    super.dispose();
  }

  void _initBorrowsListener(String userId) {
    _clearBorrowsListener();

    _borrowsSubscription = _firestore
        .collection('borrows')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
          if (!_isBorrowsListenerInitialized) {
            for (var doc in snapshot.docs) {
              _knownBorrowStatuses[doc.id] =
                  doc.data()['status'] as String? ?? '';
            }
            _isBorrowsListenerInitialized = true;
            return;
          }

          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added ||
                change.type == DocumentChangeType.modified) {
              final doc = change.doc;
              final newStatus = doc.data()?['status'] as String? ?? '';
              final oldStatus = _knownBorrowStatuses[doc.id];
              final bookTitle = doc.data()?['bookTitle'] as String? ?? 'Book';

              if (oldStatus != null && oldStatus != newStatus) {
                final nId = doc.id.hashCode.abs().remainder(100000);
                if (newStatus == 'active_borrow' &&
                    oldStatus == 'pending_pickup') {
                  NotificationService().showNotification(
                    id: nId,
                    title: 'Pickup Confirmed ✅',
                    body:
                        'Your pickup for "$bookTitle" has been confirmed. Enjoy your book!',
                  );
                } else if (newStatus == 'returned' &&
                    oldStatus == 'active_borrow') {
                  NotificationService().showNotification(
                    id: nId,
                    title: 'Return Confirmed 📚',
                    body:
                        'Your return for "$bookTitle" has been confirmed. Thank you!',
                  );
                } else if (newStatus == 'cancelled' &&
                    oldStatus == 'pending_pickup') {
                  NotificationService().showNotification(
                    id: nId,
                    title: 'Request Cancelled ❌',
                    body:
                        'Your request for "$bookTitle" has been cancelled by the library.',
                  );
                }
              }
              _knownBorrowStatuses[doc.id] = newStatus;
            } else if (change.type == DocumentChangeType.removed) {
              _knownBorrowStatuses.remove(change.doc.id);
            }
          }
        });
  }

  void _clearBorrowsListener() {
    _borrowsSubscription?.cancel();
    _borrowsSubscription = null;
    _knownBorrowStatuses.clear();
    _isBorrowsListenerInitialized = false;
  }

  Future<void> fetchUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return;

    _setLoading(true);

    try {
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        _user = UserModel.fromMap(doc.data()!, firebaseUser.uid);
      } else {
        _user = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '??',
          firstName: '??',
          lastName: '??',
          studentId: '??',
          faculty: '??',
          academicYear: '??',
          createdAt: '??',
        );
      }

      _error = null;
    } catch (e) {
      _error = 'Failed to load user: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUser(UserModel updated) async {
    _setLoading(true);

    try {
      await _firestore
          .collection('users')
          .doc(updated.id)
          .update(updated.toMap());

      _user = updated;
      _error = null;
    } catch (e) {
      _error = 'Failed to update user: $e';
    } finally {
      _setLoading(false);
    }
  }

  void clearUser() {
    _user = null;
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
