import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unilib/core/model/book_model.dart';

/// Handles all Firestore book fetching operations.
class BookFetcherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Helpers ──────────────────────────────────────────────────

  int completenessScore(Book b) {
    int score = 0;
    if (b.coverUrl.isNotEmpty && b.coverUrl != '??') score += 2;
    if (b.description.isNotEmpty && b.description != '??') score += 1;
    return score;
  }

  void sortByCompleteness(List<Book> list) {
    list.sort((a, b) => completenessScore(b).compareTo(completenessScore(a)));
  }

  // ── Fetchers ─────────────────────────────────────────────────

  Future<Book?> fetchBookById(String id) async {
    try {
      final doc = await _firestore.collection('books').doc(id).get();
      if (doc.exists) {
        return Book.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('Error fetching book $id: $e');
    }
    return null;
  }

  Future<List<Book>> fetchFeatured() async {
    final snap = await _firestore
        .collection('books')
        .where('is_available', isEqualTo: true)
        .orderBy('created_at', descending: true)
        .limit(20)
        .get();

    final featured = snap.docs
        .map(Book.fromFirestore)
        .where((b) => b.hasCover)
        .take(5)
        .toList();
    sortByCompleteness(featured);
    return featured;
  }

  Future<List<Book>> fetchTrending() async {
    // Fetch a larger pool to ensure we find enough books with photos
    final snap = await _firestore
        .collection('books')
        .where('is_available', isEqualTo: true)
        .limit(100)
        .get();

    final booksWithCovers = snap.docs
        .map(Book.fromFirestore)
        .where((b) => b.hasCover)
        .toList();

    // Shuffle to provide random books as requested
    booksWithCovers.shuffle();

    return booksWithCovers.take(10).toList();
  }

  Future<List<Book>> fetchRecentlyViewedBooks(List<String> recentIds) async {
    if (recentIds.isEmpty) return [];

    final snap = await _firestore
        .collection('books')
        .where(FieldPath.documentId, whereIn: recentIds)
        .get();

    final fetchedBooks = snap.docs.map(Book.fromFirestore).toList();

    // Sort to match recentIds order
    return recentIds
        .map(
          (id) => fetchedBooks.firstWhere(
            (b) => b.id == id,
            orElse: () => Book(
              id: '??',
              rawId: '??',
              title: '??',
              titleLower: '??',
              author: '??',
              authorLower: '??',
              description: '??',
              isbn: '??',
              year: '??',
              language: '??',
              category: '??',
              faculty: '??',
              facultySlug: '??',
              coverUrl: '??',
              sourceUrl: '??',
              createdAt: '??',
              updatedAt: '??',
              availableCopies: 0,
              totalCopies: 0,
              borrowCount: 0,
              isAvailable: false,
              tags: [],
              reservedBy: [],
              borrowedBy: [],
              location: BookLocation(building: '??', floor: '??', shelf: '??'),
            ),
          ),
        )
        .where((b) => b.id != '??')
        .toList();
  }

  Future<List<Book>> fetchAllBooks({String? facultyFilter}) async {
    Query<Map<String, dynamic>> query = _firestore.collection('books');
    if (facultyFilter != null && facultyFilter.isNotEmpty) {
      query = query.where('faculty_slug', isEqualTo: facultyFilter);
    }

    final snap = await query.orderBy('title_lower').get();

    final books = snap.docs.map(Book.fromFirestore).toList();
    sortByCompleteness(books);
    return books;
  }

  Future<List<Book>> searchBooks(String query) async {
    final lower = query.toLowerCase().trim();

    final snap = await _firestore
        .collection('books')
        .where('title_lower', isGreaterThanOrEqualTo: lower)
        .where('title_lower', isLessThan: '${lower}z')
        .limit(20)
        .get();

    return snap.docs.map(Book.fromFirestore).toList();
  }

  Future<List<Book>> getRelatedBooks(Book book) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('books')
          .where('category', isEqualTo: book.category)
          .where('is_available', isEqualTo: true)
          .limit(6)
          .get();

      return snap.docs
          .map(Book.fromFirestore)
          .where((b) => b.id != book.id)
          .toList();
    } catch (e) {
      debugPrint('Failed to fetch related: $e');
      return [];
    }
  }

  // ── Recently Viewed Persistence ──────────────────────────────

  Future<List<String>> getRecentIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('recently_viewed') ?? [];
  }

  Future<void> addRecentId(String id) async {
    if (id == '??') return;
    final prefs = await SharedPreferences.getInstance();
    List<String> recentIds = prefs.getStringList('recently_viewed') ?? [];

    if (recentIds.contains(id)) {
      recentIds.remove(id);
    }
    recentIds.insert(0, id);

    if (recentIds.length > 5) {
      recentIds = recentIds.sublist(0, 5);
    }

    await prefs.setStringList('recently_viewed', recentIds);
  }
}
