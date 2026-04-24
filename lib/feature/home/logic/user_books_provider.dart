import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/model/borrow_model.dart';
import 'package:unilib/feature/home/logic/book_catalog_provider.dart';
import 'package:unilib/feature/home/logic/borrow_query_service.dart';
import 'package:unilib/feature/home/logic/borrow_transaction_service.dart';

class UserBooksProvider extends ChangeNotifier {
  final BookCatalogProvider _catalogProvider;
  final BorrowTransactionService _transactionService =
      BorrowTransactionService();
  final BorrowQueryService _queryService = BorrowQueryService();

  int _activeBorrowCount = 0;
  String? _error;

  int get activeBorrowCount => _activeBorrowCount;
  String? get error => _error;

  UserBooksProvider(this._catalogProvider);

  Future<bool> _checkConnectivity() async {
    final List<ConnectivityResult> results = await Connectivity()
        .checkConnectivity();
    if (results.contains(ConnectivityResult.none)) {
      _error =
          'No internet connection. Please check your network and try again.';
      notifyListeners();
      return false;
    }
    return true;
  }

  Future<bool> borrowBook({
    required String bookId,
    required String userId,
  }) async {
    if (!await _checkConnectivity()) return false;
    try {
      await _transactionService.borrowBook(bookId: bookId, userId: userId);
      _catalogProvider.updateBookLocally(bookId, userId, borrowed: true);
      await syncBorrowCount(userId);
      return true;
    } on Exception catch (e) {
      _error =
          _transactionService.parseError(e.toString()) ??
          'Failed to borrow: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelPendingBorrow({
    required String bookId,
    required String userId,
    required String borrowId,
  }) async {
    if (!await _checkConnectivity()) return false;
    try {
      await _transactionService.cancelPendingBorrow(
        bookId: bookId,
        userId: userId,
        borrowId: borrowId,
      );
      _catalogProvider.updateBookLocally(bookId, userId, borrowed: false);
      await syncBorrowCount(userId);
      return true;
    } catch (e) {
      _error =
          _transactionService.parseError(e.toString()) ??
          'Failed to cancel: $e';
      notifyListeners();
      return false;
    }
  }

  // Legacy method for transition compatibility - if it exists elsewhere, it routes to cancel
  Future<bool> returnBook({
    required String bookId,
    required String userId,
  }) async {
    // This is a dangerous method now that admin controls return.
    _error = "Please bring the book to the library desk to return.";
    notifyListeners();
    return false;
  }

  Future<List<BorrowRecord>> fetchUserBorrows(String userId) async {
    if (!await _checkConnectivity()) return [];
    try {
      final records = await _queryService.fetchUserBorrows(userId);
      _activeBorrowCount = records.length;
      notifyListeners();
      return records;
    } catch (e) {
      _error = 'Failed to load borrow records: $e';
      notifyListeners();
      return [];
    }
  }

  Future<void> syncBorrowCount(String userId) async {
    if (!await _checkConnectivity()) return;
    try {
      _activeBorrowCount = await _queryService.getActiveBorrowCount(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error syncing borrow count: $e');
    }
  }

  Future<List<Book>> fetchUserBorrowedBooks(String userId) async {
    try {
      return await _queryService.fetchUserBorrowedBooks(userId);
    } catch (e) {
      _error = 'Failed to load borrowed books: $e';
      notifyListeners();
      return [];
    }
  }

  Future<List<BorrowRecord>> fetchBorrowHistory(String userId) async {
    if (!await _checkConnectivity()) return [];
    try {
      return await _queryService.fetchBorrowHistory(userId);
    } catch (e) {
      _error = 'Failed to load history: $e';
      notifyListeners();
      return [];
    }
  }

  Future<bool> clearBorrowHistory(String userId) async {
    if (!await _checkConnectivity()) return false;
    try {
      return await _queryService.clearBorrowHistory(userId);
    } catch (e) {
      _error = 'Failed to clear history: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBorrowRecord(String borrowId) async {
    if (!await _checkConnectivity()) return false;
    try {
      await _queryService.deleteBorrowRecord(borrowId);
      return true;
    } catch (e) {
      _error = 'Failed to delete record: $e';
      notifyListeners();
      return false;
    }
  }

  // ── Real-time Streams
  Stream<List<BorrowRecord>> getBorrowRecordsStream(String userId) {
    return _queryService.getBorrowRecordsStream(userId).map((records) {
      _activeBorrowCount = records.length;
      return records;
    });
  }

  // Returns a stream of a specific borrow record for a user and book.
  Stream<BorrowRecord?> getBorrowRecordForBookStream(
    String userId,
    String bookId,
  ) {
    return _queryService.getBorrowRecordForBookStream(userId, bookId);
  }
}
