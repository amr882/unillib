import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unilib/core/model/chat_session_model.dart';

class ChatPersistenceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ChatSessionModel>> fetchLocalHistory(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localData = prefs.getString('ai_chats_$userId');
      if (localData != null) {
        final List<dynamic> decoded = jsonDecode(localData);
        return decoded.map((e) => ChatSessionModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error loading local chats: $e');
    }
    return [];
  }

  Future<List<ChatSessionModel>> fetchRemoteHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .orderBy('updatedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => ChatSessionModel.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Error fetching from firestore: $e');
      rethrow;
    }
  }

  Future<void> saveHistoryLocally(String userId, List<ChatSessionModel> history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = history.map((e) => e.toJson()).toList();
      await prefs.setString('ai_chats_$userId', jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving local history: $e');
    }
  }

  Future<void> saveSessionToRemote(String userId, ChatSessionModel session) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc(session.id)
          .set(session.toMap());
    } catch (e) {
      debugPrint('Failed to save to firestore: $e');
    }
  }

  Future<void> deleteSession(String userId, String sessionId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc(sessionId)
          .delete();
    } catch (e) {
      debugPrint('Failed to delete from firestore: $e');
    }
  }

  String generateSessionId(String userId) {
    return _firestore.collection('users').doc(userId).collection('chats').doc().id;
  }
}
