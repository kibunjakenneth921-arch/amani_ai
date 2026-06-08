import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageRole { user, assistant, system }

class ChatMessage {
  final String id;
  final String conversationId;
  final MessageRole role;
  final String text;
  final Timestamp createdAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      conversationId: map['conversationId'] as String,
      role: _roleFromString(map['role'] as String),
      text: map['text'] as String,
      createdAt: map['createdAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'role': role.name,
      'text': text,
      'createdAt': createdAt,
    };
  }

  static MessageRole _roleFromString(String v) {
    switch (v) {
      case 'assistant':
        return MessageRole.assistant;
      case 'system':
        return MessageRole.system;
      default:
        return MessageRole.user;
    }
  }
}
