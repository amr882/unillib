import 'package:cloud_firestore/cloud_firestore.dart';

/// Handles searching Firestore for books relevant to a user's AI query
/// and formatting the results as context for the AI model.
class BookContextSearch {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Words to ignore when extracting search keywords from user queries.
  static const _stopWords = {
    'the',
    'and',
    'for',
    'you',
    'have',
    'books',
    'book',
    'please',
    'find',
    'show',
    'search',
    'give',
    'any',
    'some',
    'about',
    'how',
    'many',
    'what',
    'who',
    'why',
    'where',
    'when',
    'which',
    'there',
    'their',
    'they',
    'this',
    'that',
    'these',
    'those',
    'does',
    'did',
    'can',
    'could',
    'would',
    'should',
    'will',
    'are',
    'was',
    'were',
    'has',
    'had',
    'been',
    'from',
    'with',
    'than',
    'then',
    'chapters',
    'pages',
    'tell',
    'much',
    'know',
    'want',
    'like',
  };

  /// Extracts meaningful keywords from a user query.
  List<String> extractKeywords(String query) {
    final lower = query.toLowerCase().trim();
    if (lower.isEmpty) return [];

    return lower
        .split(RegExp(r'[\s,.;:!?]+'))
        .where((w) => w.length > 2 && !_stopWords.contains(w))
        .toList();
  }

  /// Searches for books matching the query and returns formatted context.
  Future<String?> getRelevantBooksContext(String query) async {
    final words = extractKeywords(query);

    if (words.isEmpty) {
      return _getFallbackContext();
    }

    try {
      final List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs = [];
      final Set<String> seenIds = {};

      final searchTasks = <Future<QuerySnapshot<Map<String, dynamic>>>>[];

      for (final word in words.take(3)) {
        // 1. Title prefix search
        searchTasks.add(
          _firestore
              .collection('books')
              .where('title_lower', isGreaterThanOrEqualTo: word)
              .where('title_lower', isLessThan: '${word}z')
              .limit(5)
              .get(),
        );

        // 2. Tags array search
        searchTasks.add(
          _firestore
              .collection('books')
              .where('tags', arrayContains: word)
              .limit(5)
              .get(),
        );
      }

      final results = await Future.wait(searchTasks);

      for (final snap in results) {
        for (final doc in snap.docs) {
          if (!seenIds.contains(doc.id)) {
            allDocs.add(doc);
            seenIds.add(doc.id);
          }
        }
      }

      if (allDocs.isEmpty && words.isNotEmpty) {
        final catSnap = await _firestore
            .collection('books')
            .where('category', isGreaterThanOrEqualTo: words.first)
            .where('category', isLessThan: '${words.first}z')
            .limit(5)
            .get();

        for (final doc in catSnap.docs) {
          if (!seenIds.contains(doc.id)) {
            allDocs.add(doc);
            seenIds.add(doc.id);
          }
        }
      }

      if (allDocs.isEmpty) {
        return _getFallbackContext();
      }

      return _formatContext(allDocs);
    } catch (e) {
      return null;
    }
  }

  Future<String?> _getFallbackContext() async {
    try {
      final snap = await _firestore.collection('books').limit(5).get();
      if (snap.docs.isEmpty) return null;

      return "No exact keyword matches found. Standard library catalog fallback (popular books):\n\n${_formatContext(snap.docs)}";
    } catch (e) {
      return null;
    }
  }

  String _formatContext(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    if (docs.isEmpty) {
      return "The library catalog is currently unavailable.";
    }

    return "Relevant books from our library catalog:\n\n${docs.map((doc) {
      final b = doc.data();
      final id = doc.id;
      final location = b['location'] as Map<String, dynamic>?;
      final locStr = location != null ? "Building ${location['building'] ?? '??'}, Floor ${location['floor'] ?? '??'}, Shelf ${location['shelf'] ?? '??'}" : "Unknown location";

      return "- ID: $id\n"
          "  Title: ${b['title'] ?? 'Unknown'}\n"
          "  Author: ${b['author'] ?? 'Unknown'}\n"
          "  Category: ${b['category'] ?? 'N/A'}\n"
          "  Available: ${b['available_copies'] ?? 0}\n"
          "  Loc: $locStr";
    }).join('\n\n')}";
  }
}
