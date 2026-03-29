import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:unilib/keys.dart';
import 'package:unilib/services/ai_repository.dart';

class Message {
  final String text;
  final bool isUser;

  Message({required this.text, required this.isUser});
}

class GenerativeAiProvider extends ChangeNotifier {
  late GenerativeModel _model;
  late ChatSession _chat;

  final List<Message> _messages = [];
  List<Message> get messages => _messages;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isInitialized = false;

  GenerativeAiProvider() {
    _initModel();
  }

  Future<void> _initModel() async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      final snapshot = await FirebaseFirestore.instance.collection('books').get();
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

      _model = GenerativeModel(
        model: 'gemini-2.5-flash-lite', 
        apiKey: aiApiKey,
        systemInstruction: systemInstruction,
      );
      
      _chat = _model.startChat();
      
      if (_messages.isEmpty) {
         _messages.add(Message(
           text: "Hello! I am the Unilib AI Assistant. I can help you find books, check availability, or suggest something to read. How can I help you today?", 
           isUser: false
         ));
      }
      
      _isInitialized = true;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to initialize AI: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    if (!_isInitialized) {
      _errorMessage = 'AI is still initializing or failed to load. Please try again.';
      notifyListeners();
      return;
    }

    final userMessage = Message(text: text, isUser: true);
    _messages.add(userMessage);

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _chat.sendMessage(Content.text(text));
      final responseText = response.text;
      if (responseText != null) {
        _messages.add(Message(text: responseText, isUser: false));
      }
    } catch (e) {
      _errorMessage = 'Failed to get response: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> analyzeDocument(String docId) async {
    final userMessage = Message(text: 'Summarize Document: $docId', isUser: true);
    _messages.add(userMessage);

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final repository = AIRepository();
      final summary = await repository.fetchAndAnalyze(docId);
      _messages.add(Message(text: summary, isUser: false));
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    if (_isInitialized) {
      _chat = _model.startChat();
      _messages.add(Message(
        text: "Hello! I am the Unilib AI Assistant. I can help you find books, check availability, or suggest something to read. How can I help you today?", 
        isUser: false
      ));
    }
    notifyListeners();
  }
}
