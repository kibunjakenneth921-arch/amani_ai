import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String? category;
  final Timestamp createdAt;
  final Timestamp? updatedAt;

  JournalEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.category,
    required this.createdAt,
    this.updatedAt,
  });

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      category: map['category'] as String?,
      createdAt: map['createdAt'] as Timestamp,
      updatedAt: map['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'title': title,
        'content': content,
        'category': category,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
