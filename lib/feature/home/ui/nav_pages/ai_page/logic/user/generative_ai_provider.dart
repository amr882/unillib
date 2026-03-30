import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:unilib/core/model/chat_session_model.dart';
import '../general/ai_core_service.dart';
import 'chat_persistence_service.dart';

class GenerativeAiProvider extends ChangeNotifier {
  final AiCoreService _aiCore = AiCoreService();
  final ChatPersistenceService _persistence = ChatPersistenceService();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  late GenerativeModel _model;
  ChatSession? _chat;

  List<ChatSessionModel> _chatHistory = [];
  List<ChatSessionModel> get chatHistory => _chatHistory;

  String? _activeChatId;
  String? get activeChatId => _activeChatId;

  bool _isViewingHistory = true;
  bool get isViewingHistory => _isViewingHistory;

  DateTime _sessionStartTime = DateTime.now();
  DateTime get sessionStartTime => _sessionStartTime;

  List<Message> _tempNewChatMessages = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isRequestCancelled = false;
  bool _isInitialized = false;

  GenerativeAiProvider() {
    _initModel();
  }

  List<Message> get messages {
    if (_activeChatId == null) {
      return (!_isViewingHistory && _tempNewChatMessages.isNotEmpty)
          ? _tempNewChatMessages
          : [];
    }
    return _chatHistory
        .firstWhere(
          (s) => s.id == _activeChatId,
          orElse: () => ChatSessionModel(
            id: '',
            title: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            messages: [],
          ),
        )
        .messages;
  }

  Future<void> _initModel() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _model = await _aiCore.initModel();
      await loadChatHistory();
      _isInitialized = true;
      _errorMessage = null;
    } catch (e) {
      _isInitialized = false;
      _errorMessage = 'Failed to initialize AI: $e';
      debugPrint('AI Init Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _ensureChatReady() async {
    if (_isInitialized && _chat != null) return true;

    if (!_isInitialized) {
      await _initModel();
    }

    if (!_isInitialized) return false;

    if (_chat == null) {
      if (_activeChatId == null) {
        _chat = _aiCore.startChat(_model);
      } else {
        try {
          final session = _chatHistory.firstWhere((s) => s.id == _activeChatId);
          final history = session.messages
              .map(
                (m) => m.isUser
                    ? Content.text(m.text)
                    : Content.model([TextPart(m.text)]),
              )
              .toList();
          _chat = _aiCore.startChat(_model, history: history);
        } catch (_) {
          _chat = _aiCore.startChat(_model);
        }
      }
    }
    return _chat != null;
  }

  Future<void> loadChatHistory() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _chatHistory = await _persistence.fetchLocalHistory(uid);
    _chatHistory.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    notifyListeners();

    try {
      _chatHistory = await _persistence.fetchRemoteHistory(uid);
      await _persistence.saveHistoryLocally(uid, _chatHistory);
      notifyListeners();
    } catch (e) {
      debugPrint('Firestore fetch failed: $e');
    }
  }

  void startNewChat() {
    _isViewingHistory = false;
    _activeChatId = null;
    _sessionStartTime = DateTime.now();
    _tempNewChatMessages = [
      Message(
        text:
            "Hello! I am UniLib AI, your personal AI assistant. How can I help you today?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ];
    if (_isInitialized) _chat = _aiCore.startChat(_model);
    notifyListeners();
  }

  void resumeChat(String chatId) {
    try {
      final session = _chatHistory.firstWhere((s) => s.id == chatId);
      _activeChatId = chatId;
      _isViewingHistory = false;
      _sessionStartTime = DateTime.now();
      _tempNewChatMessages = [];
      if (_isInitialized) {
        final history = session.messages
            .map(
              (m) => m.isUser
                  ? Content.text(m.text)
                  : Content.model([TextPart(m.text)]),
            )
            .toList();
        _chat = _aiCore.startChat(_model, history: history);
      }
    } catch (_) {
      _errorMessage = "Chat not found.";
    }
    notifyListeners();
  }

  void viewHistory() {
    _isViewingHistory = true;
    _activeChatId = null;
    _tempNewChatMessages = [];
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _isRequestCancelled = false;

    if (!await _ensureChatReady()) return;

    await _processFlow(
      userText: text,
      action: () async {
        final context = await _aiCore.getRelevantBooksContext(text);
        final fullPrompt = "Library Context:\n$context\n\nUser Question: $text";
        final response = await _chat?.sendMessage(Content.text(fullPrompt));
        return response?.text;
      },
    );
  }

  void stopGenerating() {
    if (_isLoading) {
      _isRequestCancelled = true;
      _isLoading = false;
      _errorMessage = "Response stopped by user.";
      notifyListeners();
    }
  }

  Future<void> _processFlow({
    required String userText,
    required Future<String?> Function() action,
    String? customTitle,
  }) async {
    if (_chat == null) {
      _errorMessage = 'AI session not ready. Please try again.';
      notifyListeners();
      return;
    }

    final userMsg = Message(
      text: userText,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _addMessageToActiveSession(userMsg);

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final responseText = await action();

      // If the request was cancelled while waiting, don't add the AI message
      if (_isRequestCancelled) return;

      if (responseText == null && !_isRequestCancelled) {
        debugPrint(
          'AI Response was null. This might be due to safety filters or a model error.',
        );
      }

      final aiMsg = Message(
        text:
            responseText ??
            "I'm sorry, I couldn't generate a response. Please try rephrasing your request or checking our catalog directly.",
        isUser: false,
        timestamp: DateTime.now(),
      );

      _addMessageToActiveSession(aiMsg);

      if (_activeChatId == null) {
        await _finalizeNewSession(customTitle ?? userText);
      } else {
        await _updateExistingSession();
      }
    } catch (e) {
      if (!_isRequestCancelled) {
        _errorMessage = 'Error: $e';
      }
    } finally {
      if (!_isRequestCancelled) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void _addMessageToActiveSession(Message msg) {
    if (_activeChatId == null) {
      _tempNewChatMessages.add(msg);
    } else {
      final index = _chatHistory.indexWhere((s) => s.id == _activeChatId);
      if (index >= 0) _chatHistory[index].messages.add(msg);
    }
  }

  Future<void> _finalizeNewSession(String titleText) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final id = _persistence.generateSessionId(uid);
    final title = titleText.length > 30
        ? '${titleText.substring(0, 30)}...'
        : titleText;

    final newSession = ChatSessionModel(
      id: id,
      title: title,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messages: List.from(_tempNewChatMessages),
    );

    _chatHistory.insert(0, newSession);
    _activeChatId = id;
    _tempNewChatMessages = [];

    await _persistence.saveSessionToRemote(uid, newSession);
    await _persistence.saveHistoryLocally(uid, _chatHistory);
  }

  Future<void> _updateExistingSession() async {
    final uid = _auth.currentUser?.uid;
    final index = _chatHistory.indexWhere((s) => s.id == _activeChatId);
    if (uid == null || index < 0) return;

    final updatedSession = ChatSessionModel(
      id: _chatHistory[index].id,
      title: _chatHistory[index].title,
      createdAt: _chatHistory[index].createdAt,
      updatedAt: DateTime.now(),
      messages: _chatHistory[index].messages,
    );

    _chatHistory[index] = updatedSession;
    final session = _chatHistory.removeAt(index);
    _chatHistory.insert(0, session);

    await _persistence.saveSessionToRemote(uid, updatedSession);
    await _persistence.saveHistoryLocally(uid, _chatHistory);
  }

  Future<void> deleteChat(String chatId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _chatHistory.removeWhere((s) => s.id == chatId);
    if (_activeChatId == chatId) {
      _activeChatId = null;
      _isViewingHistory = true;
    }
    notifyListeners();

    try {
      await _persistence.deleteSession(uid, chatId);
      await _persistence.saveHistoryLocally(uid, _chatHistory);
    } catch (e) {
      debugPrint('Delete failed: $e');
    }
  }

  void clearChat() => viewHistory();
}
