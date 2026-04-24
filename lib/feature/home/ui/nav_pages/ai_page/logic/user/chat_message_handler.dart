import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:unilib/core/model/chat_session_model.dart';
import '../general/ai_core_service.dart';
import 'chat_persistence_service.dart';

/// Handles sending messages, processing AI responses, and persisting chat data.
class ChatMessageHandler {
  final AiCoreService aiCore;
  final ChatPersistenceService persistence;

  ChatMessageHandler({required this.aiCore, required this.persistence});

  /// Builds the full prompt by augmenting the user text with book context.
  Future<String> buildFullPrompt(String text) async {
    final context = await aiCore.getRelevantBooksContext(text);
    if (context != null && context.isNotEmpty) {
      return "$text\n\n---\n[SYSTEM NOTE: Automated Catalog Search Results]\n"
          "$context\n"
          "(Instruction: The above search results are provided automatically. "
          "They indicate which books are physically available in the library. "
          "If the user is asking a follow-up question about a book already discussed in this conversation, "
          "you MUST ignore these search results and continue discussing the book from the conversation history. "
          "Answer the user's message above.)\n---\n";
    }
    return text;
  }

  /// Sends a text message (optionally with an image) to the chat session.
  Future<String?> sendToModel(
    ChatSession chat,
    String fullPrompt, {
    Uint8List? imageBytes,
  }) async {
    if (imageBytes != null) {
      final content = Content.multi([
        TextPart(fullPrompt),
        DataPart('image/jpeg', imageBytes),
      ]);
      final response = await chat.sendMessage(content);
      return response.text;
    } else {
      final response = await chat.sendMessage(Content.text(fullPrompt));
      return response.text;
    }
  }

  /// Creates a user Message object.
  Message createUserMessage(String text, {Uint8List? imageBytes}) {
    return Message(
      text: text.isEmpty && imageBytes != null ? "Uploaded an image" : text,
      isUser: true,
      timestamp: DateTime.now(),
      tempImage: imageBytes,
    );
  }

  /// Creates an AI response Message object.
  Message createAiMessage(String? responseText) {
    return Message(
      text:
          responseText ??
          "I'm sorry, I couldn't generate a response. Please try rephrasing your request or checking our catalog directly.",
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  /// Finalizes a new chat session by saving it to Firestore and local storage.
  Future<ChatSessionModel> finalizeNewSession({
    required String uid,
    required String titleText,
    required List<Message> messages,
  }) async {
    final id = persistence.generateSessionId(uid);
    final title = titleText.length > 30
        ? '${titleText.substring(0, 30)}...'
        : titleText;

    final newSession = ChatSessionModel(
      id: id,
      title: title,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messages: List.from(messages),
    );

    await persistence.saveSessionToRemote(uid, newSession);
    return newSession;
  }

  /// Updates an existing session with a new timestamp and re-saves it.
  Future<ChatSessionModel> updateExistingSession({
    required String uid,
    required ChatSessionModel session,
  }) async {
    final updatedSession = ChatSessionModel(
      id: session.id,
      title: session.title,
      createdAt: session.createdAt,
      updatedAt: DateTime.now(),
      messages: session.messages,
    );

    await persistence.saveSessionToRemote(uid, updatedSession);
    return updatedSession;
  }

  /// Saves the full chat history locally.
  Future<void> saveHistoryLocally(
    String uid,
    List<ChatSessionModel> chatHistory,
  ) async {
    await persistence.saveHistoryLocally(uid, chatHistory);
  }

  /// Deletes a session from remote and local storage.
  Future<void> deleteSession(String uid, String chatId) async {
    try {
      await persistence.deleteSession(uid, chatId);
    } catch (e) {
      debugPrint('Delete failed: $e');
    }
  }
}
