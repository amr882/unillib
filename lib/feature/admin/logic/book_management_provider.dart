import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unilib/core/model/book_model.dart';
import 'dart:developer' as dev;

class BookManagementProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Adds a new book to Firestore.
  Future<bool> addBook(Book book) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Use the book's ID if provided, otherwise let Firestore generate one
      final docRef = _firestore.collection('books').doc(book.id == '??' ? null : book.id);
      
      final bookToSave = book.copyWith(
        id: docRef.id,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      await docRef.set(bookToSave.toMap());
      
      dev.log('Book added successfully: ${bookToSave.title}');
      return true;
    } catch (e) {
      _error = 'Failed to add book: $e';
      dev.log(_error!, error: e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates an existing book.
  Future<bool> updateBook(Book book) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final bookToUpdate = book.copyWith(
        updatedAt: DateTime.now().toIso8601String(),
      );

      await _firestore.collection('books').doc(book.id).update(bookToUpdate.toMap());
      return true;
    } catch (e) {
      _error = 'Failed to update book: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes a book from Firestore.
  Future<bool> deleteBook(String bookId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('books').doc(bookId).delete();
      return true;
    } catch (e) {
      _error = 'Failed to delete book: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
