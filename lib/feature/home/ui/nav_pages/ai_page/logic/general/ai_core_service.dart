import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unilib/keys.dart';

class AiCoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Fetches context from Firestore (books) and initializes the GenerativeModel.
  Future<GenerativeModel> initModel() async {
    final snapshot = await _firestore.collection('books').get();
    final booksList = snapshot.docs.map((doc) => doc.data()).toList();
    
    final booksContext = booksList.map((b) {
      final location = b['location'] as Map<String, dynamic>?;
      final locStr = location != null 
          ? "Building ${location['building'] ?? '??'}, Floor ${location['floor'] ?? '??'}, Shelf ${location['shelf'] ?? '??'}"
          : "Unknown location";
      
      return "- Title: ${b['title'] ?? 'Unknown'}\n"
             "  Author: ${b['author'] ?? 'Unknown'}\n"
             "  Description: ${b['description'] ?? 'No description'}\n"
             "  Category: ${b['category'] ?? 'N/A'}\n"
             "  Language: ${b['language'] ?? 'N/A'}\n"
             "  Available Copies: ${b['available_copies'] ?? 0}\n"
             "  Total Copies: ${b['total_copies'] ?? 0}\n"
             "  Location: $locStr";
    }).join('\n\n');

    final systemInstruction = Content.system(
      "You are the Unilib AI Assistant, a friendly and expert library assistant. "
      "Your ONLY purpose is to help users find books, suggest books based on their interests, tell them "
      "if a book is available, and guide them to its location in the library. "
      "Do NOT answer questions that are outside the scope of books, reading, studying, or the library itself. "
      "If a user asks about general knowledge, programming, math, or anything unrelated to the library catalog, "
      "politely decline and remind them you are only here to help with the library's books. "
      "Format your responses nicely and keep them helpful and concise.\n\n"
      "Here is the database of ALL currently available books in the library:\n\n"
      "$booksContext"
    );

    return GenerativeModel(
      model: 'gemini-2.5-flash-lite', 
      apiKey: aiApiKey,
      systemInstruction: systemInstruction,
    );
  }

  /// Convenience method to start a new chat with history or without.
  ChatSession startChat(GenerativeModel model, {List<Content>? history}) {
    return model.startChat(history: history);
  }
}
