import 'package:cloud_firestore/cloud_firestore.dart';

class Habit {
  final String id;
  final String name;
  final int streak;

  Habit({required this.id, required this.name, required this.streak});

  factory Habit.fromMap(Map<String, dynamic> map) => Habit(id: map['id'] as String, name: map['name'] as String, streak: (map['streak'] as num).toInt());
  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'streak': streak};
}

class Milestone {
  final String id;
  final String title;
  final bool completed;

  Milestone({required this.id, required this.title, this.completed = false});

  factory Milestone.fromMap(Map<String, dynamic> map) => Milestone(id: map['id'] as String, title: map['title'] as String, completed: map['completed'] as bool? ?? false);
  Map<String, dynamic> toMap() => {'id': id, 'title': title, 'completed': completed};
}

class Goal {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime? targetDate;
  final double progress; // 0.0 - 100.0
  final List<Milestone> milestones;
  final List<Habit> habits;
  final Timestamp createdAt;
  final Timestamp? updatedAt;

  Goal({required this.id, required this.userId, required this.title, required this.description, this.targetDate, this.progress = 0.0, this.milestones = const [], this.habits = const [], required this.createdAt, this.updatedAt});

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      targetDate: map['targetDate'] != null ? (map['targetDate'] as Timestamp).toDate() : null,
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      milestones: map['milestones'] != null ? List<Map<String, dynamic>>.from(map['milestones']).map((m) => Milestone.fromMap(m)).toList() : [],
      habits: map['habits'] != null ? List<Map<String, dynamic>>.from(map['habits']).map((h) => Habit.fromMap(h)).toList() : [],
      createdAt: map['createdAt'] as Timestamp,
      updatedAt: map['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'title': title,
        'description': description,
        'targetDate': targetDate != null ? Timestamp.fromDate(targetDate!) : null,
        'progress': progress,
        'milestones': milestones.map((m) => m.toMap()).toList(),
        'habits': habits.map((h) => h.toMap()).toList(),
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
