import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unilib/keys.dart';

class AiCoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<GenerativeModel> initModel() async {
    await _firestore.collection('books').limit(1).get();

    final systemInstruction = Content.system(
      "You are the Unilib AI Assistant, a friendly and expert library assistant. "
      "You support both English and Arabic. Respond in the same language the user uses. "
      "Your ONLY purpose is to help users find books, suggest books based on their interests, tell them "
      "if a book is available, and guide them to its location in the library. "
      "Do NOT answer questions that are outside the scope of books, reading, studying, or the library itself. "
      "If a user asks about general knowledge, programming, math, or anything unrelated to the library catalog, "
      "politely decline and remind them you are only here to help with the library's books. "
      "Format your responses nicely and keep them helpful and concise.\n\n"
      "CRITICAL (LANGUAGE): You MUST keep all book-specific details (Titles, Authors, Categories, IDs) in English exactly as they appear in the catalog context, "
      "even if you are responding in Arabic. For example, if the user asks in Arabic, you should respond in Arabic but use the English book title.\n\n"
      "CRITICAL (TAGS): When you suggest or mention a specific book, you MUST append the following tag to your response: [BOOK: book_id]. "
      "For example, if you suggest 'The Great Gatsby' and its ID is 'gatsby123', you should say: 'I recommend reading The Great Gatsby. [BOOK: gatsby123]'. "
      "If you suggest multiple books, include all their tags: 'You might like Book A [BOOK: idA] and Book B [BOOK: idB]'.\n\n"
      "NOTE: You will be provided with a search result context for each query containing relevant books from our library.",
    );

    return GenerativeModel(
      model: 'models/gemini-2.5-flash',
      apiKey: aiApiKey,
      systemInstruction: systemInstruction,
    );
  }

  Future<String> getRelevantBooksContext(String query) async {
    final lower = query.toLowerCase().trim();
    if (lower.isEmpty) return "No relevant books found.";

    final words = lower
        .split(RegExp(r'[\s,.;:!?]+'))
        .where(
          (w) =>
              w.length > 2 &&
              ![
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
              ].contains(w),
        )
        .toList();

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
      return "Error fetching library context: $e";
    }
  }

  Future<String> _getFallbackContext() async {
    try {
      final snap = await _firestore.collection('books').limit(5).get();
      if (snap.docs.isEmpty) return "The library catalog is currently empty.";

      return "I couldn't find exact matches for your specific keywords, but here are some popular books in our library:\n\n${_formatContext(snap.docs)}";
    } catch (e) {
      return "Error fetching fallback context: $e";
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

  ChatSession startChat(GenerativeModel model, {List<Content>? history}) {
    return model.startChat(history: history);
  }
}
