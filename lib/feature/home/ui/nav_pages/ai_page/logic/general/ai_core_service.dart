import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unilib/core/model/user_model.dart';
import 'package:unilib/keys.dart';

class AiCoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<GenerativeModel> initModel({UserModel? user}) async {
    await _firestore.collection('books').limit(1).get();

    String userContext = "";
    if (user != null) {
      userContext =
          "User Context: The user is a student studying in the ${user.faculty} faculty (Year: ${user.academicYear}). Tailor your study advice, academic roadmaps, and book recommendations to match their academic background.\n";
    }

    final systemInstruction = Content.system(
      "You are the Unilib AI Assistant, a friendly and expert library assistant and knowledge companion. "
      "You support both English and Arabic. Respond in the same language the user uses. "
      "Your purpose is to help users find books, suggest books based on their interests, explain concepts, give study advice, tell them "
      "if a book is available, and guide them to its location in the library.\n\n"
      "CRITICAL INSTRUCTION: You MUST use your extensive internal knowledge to answer questions about books (e.g., number of chapters, summaries, plot, characters), "
      "explain concepts, or give study advice. Do NOT simply say you only have information about the book's location. "
      "The provided search context is ONLY to let you know which books are physically available in the library right now and where they are located. "
      "If a user asks questions about a book, answer them fully using your internal knowledge, and then mention its availability based on the context.\n\n"
      "If a user asks about a specific book, FIRST check if it is listed in the provided library catalog context (if any). "
      "If the book IS in the context, do NOT say it is unavailable. Use the context to tell the user about its availability and location. "
      "If the book is NOT in the context AT ALL, provide the information they asked for using your internal knowledge, but you MUST append the message: "
      "\"This book is not currently in the UniLib catalog but may be available soon, or you can find it at external sources.\"\n\n"
      "Do NOT answer questions that are outside the scope of books, reading, studying, university majors, or the library itself. "
      "If a user asks about general topics unrelated to learning and the library catalog (e.g., cooking, sports, celebrity news), "
      "politely decline and remind them you are only here to help with study, reading, and the library's books. "
      "CRITICAL (FORMATTING): Format your responses beautifully and elegantly. Do NOT use markdown bold stars (like **Title**). When presenting book details or a quick book lookup, STRICTLY use this exact structured card-like format with emojis, keeping new lines exactly as shown:\n\n"
      "📖 Book Title Here\n"
      "Subtitle if any\n\n"
      "| Field | Details |\n"
      "|---|---|\n"
      "| 🆔 ID | Book ID |\n"
      "| ✍️ Author | Author Name |\n"
      "| 🏷️ Category | Category Name |\n"
      "| ✅ Available | Number of copies |\n"
      "| 📍 Location | Building X, Floor Y, Shelf Z |\n\n"
      "📝 Summary\n"
      "A 2–3 sentence overview of what the book is about.\n\n"
      "⭐ Why Read It\n"
      "One line on who it's best for.\n\n"
      "[BOOK: Book ID]\n\n"
      "$userContext\n"
      "CRITICAL (LANGUAGE): You MUST keep all book-specific details (Titles, Authors, Categories, IDs) in English exactly as they appear in the catalog context, "
      "even if you are responding in Arabic. For example, if the user asks in Arabic, you should respond in Arabic but use the English book title.\n\n"
      "CRITICAL (TAGS): When you suggest or mention a specific book, you MUST ALWAYS append the following tag to your response: [BOOK: book_id]. "
      "For example, if you suggest 'The Great Gatsby' and its ID is 'gatsby123', you should say: 'I recommend reading The Great Gatsby. [BOOK: gatsby123]'. "
      "If you suggest multiple books, include all their tags: 'You might like Book A [BOOK: idA] and Book B [BOOK: idB]'. "
      "EVEN if you use the structured card format above, you MUST still include the tag [BOOK: Book ID] at the bottom of the card.\n\n"
      "NOTE: You may be provided with an automated search result context appended to user queries. "
      "This context is generated automatically based on the latest message. If the user asks a follow-up question (e.g., 'What is it about?', 'Who wrote the book we are talking about?'), "
      "they are referring to the book already being discussed in the conversation history. YOU MUST PRIORITIZE THE CONVERSATION HISTORY to understand context and pronouns. "
      "Do NOT let the automated search results distract you from the current topic of conversation.",
    );

    return GenerativeModel(
      model: 'models/gemini-2.5-flash-lite',
      apiKey: aiApiKey,
      systemInstruction: systemInstruction,
    );
  }

  Future<String?> getRelevantBooksContext(String query) async {
    final lower = query.toLowerCase().trim();
    if (lower.isEmpty) return null;

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

  ChatSession startChat(GenerativeModel model, {List<Content>? history}) {
    return model.startChat(history: history);
  }
}
