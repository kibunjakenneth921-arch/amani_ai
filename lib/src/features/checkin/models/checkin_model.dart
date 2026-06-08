import 'package:cloud_firestore/cloud_firestore.dart';

class CheckInEntry {
  final String id;
  final String userId;
  final int mood; // 1-10
  final int energy; // 1-10
  final int stress; // 1-10
  final String? gratitude;
  final String? notes;
  final Timestamp createdAt;

  CheckInEntry({required this.id, required this.userId, required this.mood, required this.energy, required this.stress, this.gratitude, this.notes, required this.createdAt});

  factory CheckInEntry.fromMap(Map<String, dynamic> map) {
    return CheckInEntry(
      id: map['id'] as String,
      userId: map['userId'] as String,
      mood: (map['mood'] as num).toInt(),
      energy: (map['energy'] as num).toInt(),
      stress: (map['stress'] as num).toInt(),
      gratitude: map['gratitude'] as String?,
      notes: map['notes'] as String?,
      createdAt: map['createdAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'mood': mood,
        'energy': energy,
        'stress': stress,
        'gratitude': gratitude,
        'notes': notes,
        'createdAt': createdAt,
      };
}
