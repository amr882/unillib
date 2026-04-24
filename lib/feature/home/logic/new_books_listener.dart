import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unilib/core/service/notification_service.dart';

/// Listens for new books added to Firestore and notifies users
/// whose interests match the new book's category.
class NewBooksListener {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription? _newBooksSubscription;
  String? _lastKnownBookTimestamp;
  Set<String> _interestedCategories = {};

  Set<String> get interestedCategories => _interestedCategories;

  /// Updates user interests based on recently viewed and searched books.
  void updateInterests({
    required List<String> recentCategories,
    required List<String> searchCategories,
  }) {
    final newInterests = <String>{};
    newInterests.addAll(recentCategories.where((cat) => cat != '??'));
    newInterests.addAll(searchCategories.where((cat) => cat != '??'));

    if (newInterests.isNotEmpty &&
        !_setEquals(_interestedCategories, newInterests)) {
      _interestedCategories = newInterests;
      debugPrint('Updated interests: $_interestedCategories');
      // Restart listener if it wasn't running
      if (_newBooksSubscription == null) {
        startListening();
      }
    }
  }

  bool _setEquals(Set a, Set b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  /// Starts listening for new books added to the collection.
  void startListening() {
    _newBooksSubscription?.cancel();

    // Initial fetch to get the current latest timestamp
    _firestore
        .collection('books')
        .orderBy('created_at', descending: true)
        .limit(1)
        .get()
        .then((snap) {
          if (snap.docs.isNotEmpty) {
            _lastKnownBookTimestamp = snap.docs.first.data()['created_at'];
          }

          _newBooksSubscription = _firestore
              .collection('books')
              .snapshots()
              .listen((snap) {
                for (var change in snap.docChanges) {
                  if (change.type == DocumentChangeType.added) {
                    final data = change.doc.data();
                    if (data == null) continue;

                    final createdAt = data['created_at'] as String? ?? '';

                    // Only notify if it's newer than the last known book
                    if (_lastKnownBookTimestamp == null ||
                        createdAt.compareTo(_lastKnownBookTimestamp!) > 0) {
                      final category = data['category'] as String? ?? '??';
                      if (_interestedCategories.contains(category)) {
                        NotificationService().showNotification(
                          id: change.doc.id.hashCode,
                          title: 'New Book for You!',
                          body:
                              'A new book in "$category" is now available: ${data['title']}',
                        );
                      }
                      // Update last known timestamp
                      if (_lastKnownBookTimestamp == null ||
                          createdAt.compareTo(_lastKnownBookTimestamp!) > 0) {
                        _lastKnownBookTimestamp = createdAt;
                      }
                    }
                  }
                }
              });
        });
  }

  /// Cancels the listener subscription.
  void dispose() {
    _newBooksSubscription?.cancel();
  }
}
