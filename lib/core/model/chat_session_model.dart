import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      text: map['text'] as String,
      isUser: map['isUser'] as bool,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}

class ChatSessionModel {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Message> messages;

  ChatSessionModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'messages': messages.map((m) => m.toMap()).toList(),
    };
  }

  factory ChatSessionModel.fromMap(Map<String, dynamic> map) {
    return ChatSessionModel(
      id: map['id'] as String,
      title: map['title'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      messages: (map['messages'] as List<dynamic>)
          .map((m) => Message.fromMap(m as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'messages': messages.map((m) => m.toMap()).toList(),
    };
  }

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      messages: (json['messages'] as List<dynamic>)
          .map((m) => Message.fromMap(m as Map<String, dynamic>))
          .toList(),
    );
  }
}
