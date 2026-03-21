import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserProvider() {
    _auth.authStateChanges().listen((firebaseUser) {
      if (firebaseUser != null) {
        fetchUser();
      } else {
        clearUser();
      }
    });
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
