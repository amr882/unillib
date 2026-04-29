import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:unilib/core/model/book_model.dart';
import 'package:unilib/core/model/chat_session_model.dart';
import 'package:unilib/core/model/user_model.dart';
import '../general/ai_core_service.dart';
import 'chat_persistence_service.dart';
import 'chat_session_manager.dart';
import 'chat_message_handler.dart';

class GenerativeAiProvider extends ChangeNotifier {
  final AiCoreService _aiCore = AiCoreService();
  final ChatPersistenceService _persistence = ChatPersistenceService();
  late final ChatSessionManager _sessionManager;
  late final ChatMessageHandler _messageHandler;

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
    _sessionManager = ChatSessionManager(aiCore: _aiCore);
    _messageHandler = ChatMessageHandler(
      aiCore: _aiCore,
      persistence: _persistence,
    );
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

  // ── Initialization ────────────────────────────────────────────

  Future<void> _initModel() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final uid = _auth.currentUser?.uid;
      UserModel? appUser;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        if (doc.exists && doc.data() != null) {
          appUser = UserModel.fromMap(doc.data()!, uid);
        }
      }
      _model = await _aiCore.initModel(user: appUser);
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

    if (!_isInitialized) await _initModel();
    if (!_isInitialized) return false;

    if (_chat == null) {
      if (_activeChatId == null) {
        _chat = _sessionManager.startNewChatSession(_model);
      } else {
        _chat = _sessionManager.restoreFromHistory(
          _model,
          _chatHistory,
          _activeChatId!,
        );
      }
    }
    return _chat != null;
  }

  // ── Chat History ──────────────────────────────────────────────

  Future<void> loadChatHistory() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _chatHistory = await _persistence.fetchLocalHistory(uid);
    _chatHistory.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    notifyListeners();

    try {
      _chatHistory = await _persistence.fetchRemoteHistory(uid);
      await _messageHandler.saveHistoryLocally(uid, _chatHistory);
      notifyListeners();
    } catch (e) {
      debugPrint('Firestore fetch failed: $e');
    }
  }

  // ── Session Lifecycle ─────────────────────────────────────────

  void startNewChat() {
    _isViewingHistory = false;
    _activeChatId = null;
    _sessionStartTime = DateTime.now();
    _tempNewChatMessages = [_sessionManager.buildWelcomeMessage()];
    if (_isInitialized) _chat = _sessionManager.startNewChatSession(_model);
    notifyListeners();
  }

  void startBookContextChat(Book book) {
    _isViewingHistory = false;
    _activeChatId = null;
    _sessionStartTime = DateTime.now();
    _tempNewChatMessages = [_sessionManager.buildBookWelcomeMessage(book)];
    if (_isInitialized) {
      _chat = _sessionManager.startBookContextChatSession(_model, book);
    }
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
        _chat = _sessionManager.startChatWithHistory(_model, session.messages);
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

  // ── Messaging ─────────────────────────────────────────────────

  Future<void> sendMessage(String text, {Uint8List? imageBytes}) async {
    if (text.trim().isEmpty && imageBytes == null) return;
    _isRequestCancelled = false;

    if (!await _ensureChatReady()) return;

    final userMsg = _messageHandler.createUserMessage(
      text,
      imageBytes: imageBytes,
    );
    _addMessageToActiveSession(userMsg);

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fullPrompt = await _messageHandler.buildFullPrompt(text);
      final responseText = await _messageHandler.sendToModel(
        _chat!,
        fullPrompt,
        imageBytes: imageBytes,
      );

      // If the request was cancelled while waiting, don't add the AI message
      if (_isRequestCancelled) return;

      if (responseText == null && !_isRequestCancelled) {
        debugPrint(
          'AI Response was null. This might be due to safety filters or a model error.',
        );
      }

      final aiMsg = _messageHandler.createAiMessage(responseText);
      _addMessageToActiveSession(aiMsg);

      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        if (_activeChatId == null) {
          await _finalizeNewSession(uid, text);
        } else {
          await _updateExistingSession(uid);
        }
      }
    } catch (e) {
      if (!_isRequestCancelled) {
        _errorMessage = 'Error: $e';
        
        String errorText = "I'm sorry, I'm currently experiencing high demand or network issues. Please try again in a moment.";
        if (e.toString().contains('503')) {
          errorText = "I'm currently experiencing high demand spikes. Please try again in a moment.";
        }
        
        final aiErrorMsg = _messageHandler.createAiMessage(errorText);
        _addMessageToActiveSession(aiErrorMsg);
        
        final uid = _auth.currentUser?.uid;
        if (uid != null) {
          if (_activeChatId == null) {
            await _finalizeNewSession(uid, text);
          } else {
            await _updateExistingSession(uid);
          }
        }
      }
    } finally {
      if (!_isRequestCancelled) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void stopGenerating() {
    if (_isLoading) {
      _isRequestCancelled = true;
      _isLoading = false;
      _errorMessage = "Response stopped by user.";
      notifyListeners();
    }
  }

  // ── Internal Helpers ──────────────────────────────────────────

  void _addMessageToActiveSession(Message msg) {
    if (_activeChatId == null) {
      _tempNewChatMessages.add(msg);
    } else {
      final index = _chatHistory.indexWhere((s) => s.id == _activeChatId);
      if (index >= 0) _chatHistory[index].messages.add(msg);
    }
  }

  Future<void> _finalizeNewSession(String uid, String titleText) async {
    final newSession = await _messageHandler.finalizeNewSession(
      uid: uid,
      titleText: titleText,
      messages: _tempNewChatMessages,
    );

    _chatHistory.insert(0, newSession);
    _activeChatId = newSession.id;
    _tempNewChatMessages = [];

    await _messageHandler.saveHistoryLocally(uid, _chatHistory);
  }

  Future<void> _updateExistingSession(String uid) async {
    final index = _chatHistory.indexWhere((s) => s.id == _activeChatId);
    if (index < 0) return;

    final updatedSession = await _messageHandler.updateExistingSession(
      uid: uid,
      session: _chatHistory[index],
    );

    _chatHistory[index] = updatedSession;
    final session = _chatHistory.removeAt(index);
    _chatHistory.insert(0, session);

    await _messageHandler.saveHistoryLocally(uid, _chatHistory);
  }

  // ── Delete ────────────────────────────────────────────────────

  Future<void> deleteChat(String chatId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _chatHistory.removeWhere((s) => s.id == chatId);
    if (_activeChatId == chatId) {
      _activeChatId = null;
      _isViewingHistory = true;
    }
    notifyListeners();

    await _messageHandler.deleteSession(uid, chatId);
    await _messageHandler.saveHistoryLocally(uid, _chatHistory);
  }

  void clearChat() => viewHistory();
}
