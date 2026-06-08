import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String id;
  final String title;
  final String userId;
  final Timestamp createdAt;

  Conversation({required this.id, required this.title, required this.userId, required this.createdAt});

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'] as String,
      title: map['title'] as String,
      userId: map['userId'] as String,
      createdAt: map['createdAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'userId': userId,
        'createdAt': createdAt,
      };
}
