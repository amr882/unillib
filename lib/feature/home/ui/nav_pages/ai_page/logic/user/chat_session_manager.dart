import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/model/chat_session_model.dart';
import '../general/ai_core_service.dart';

/// Handles chat session lifecycle: starting, resuming, and managing chat sessions.
class ChatSessionManager {
  final AiCoreService aiCore;

  ChatSessionManager({required this.aiCore});

  ChatSession startNewChatSession(GenerativeModel model) {
    return aiCore.startChat(model);
  }

  ChatSession startChatWithHistory(
    GenerativeModel model,
    List<Message> messages,
  ) {
    final history = messages
        .map(
          (m) => m.isUser
              ? Content.text(m.text)
              : Content.model([TextPart(m.text)]),
        )
        .toList();
    return aiCore.startChat(model, history: history);
  }

  ChatSession startBookContextChatSession(GenerativeModel model, Book book) {
    final userMessage = Content.text(
      "I am looking at this book. Please keep it in your context for our discussion:\n"
      "Title: ${book.title}\n"
      "Author: ${book.author}\n"
      "Category: ${book.category}\n"
      "Description: ${book.description}\n"
      "ISBN: ${book.isbn}\n"
      "Tags: ${book.tags.join(', ')}",
    );
    final modelResponse = Content.model([
      TextPart(
        "Understood. I have securely kept '${book.title}' in my context. "
        "I am ready to answer any questions, summarize its concepts, or help you understand how it relates to your studies.",
      ),
    ]);
    return aiCore.startChat(model, history: [userMessage, modelResponse]);
  }

  /// Builds the welcome message for a new chat.
  Message buildWelcomeMessage() {
    return Message(
      text:
          "Hello! I am UniLib AI, your personal AI assistant. How can I help you today?",
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  /// Builds the welcome message for a book context chat.
  Message buildBookWelcomeMessage(Book book) {
    return Message(
      text:
          "I see you are interested in '${book.title}'. I have loaded its details. What would you like to know or discuss about it?",
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  /// Tries to restore a chat session from history.
  ChatSession? restoreFromHistory(
    GenerativeModel model,
    List<ChatSessionModel> chatHistory,
    String chatId,
  ) {
    try {
      final session = chatHistory.firstWhere((s) => s.id == chatId);
      return startChatWithHistory(model, session.messages);
    } catch (_) {
      debugPrint('Chat $chatId not found in history, starting fresh.');
      return aiCore.startChat(model);
    }
  }
}
