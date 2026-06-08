import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_model.dart';
import 'package:uuid/uuid.dart';

class GoalsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Future<Goal> createGoal({required String userId, required String title, String description = '', DateTime? targetDate}) async {
    final id = _uuid.v4();
    final doc = _firestore.collection('goals').doc(id);
    final now = FieldValue.serverTimestamp();
    await doc.set({
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'targetDate': targetDate != null ? Timestamp.fromDate(targetDate) : null,
      'progress': 0.0,
      'milestones': [],
      'habits': [],
      'createdAt': now,
      'updatedAt': now,
    });
    final snap = await doc.get();
    return Goal.fromMap(snap.data()!);
  }

  Future<void> updateGoal(Goal goal) async {
    final doc = _firestore.collection('goals').doc(goal.id);
    await doc.update(goal.toMap());
  }

  Future<void> deleteGoal(String id) async {
    await _firestore.collection('goals').doc(id).delete();
  }

  Future<List<Goal>> listGoals(String userId, {int limit = 100}) async {
    final snap = await _firestore.collection('goals').where('userId', isEqualTo: userId).orderBy('createdAt', descending: true).limit(limit).get();
    return snap.docs.map((d) => Goal.fromMap(d.data())).toList();
  }

  Future<void> addMilestone(String goalId, Milestone milestone) async {
    final doc = _firestore.collection('goals').doc(goalId);
    await doc.update({'milestones': FieldValue.arrayUnion([milestone.toMap()]), 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> completeMilestone(String goalId, String milestoneId) async {
    final docRef = _firestore.collection('goals').doc(goalId);
    final snap = await docRef.get();
    final data = snap.data()!;
    final milestones = List<Map<String, dynamic>>.from(data['milestones'] ?? []);
    for (var m in milestones) {
      if (m['id'] == milestoneId) m['completed'] = true;
    }
    await docRef.update({'milestones': milestones, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> addHabit(String goalId, Habit habit) async {
    final doc = _firestore.collection('goals').doc(goalId);
    await doc.update({'habits': FieldValue.arrayUnion([habit.toMap()]), 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> incrementHabitStreak(String goalId, String habitId) async {
    final docRef = _firestore.collection('goals').doc(goalId);
    final snap = await docRef.get();
    final data = snap.data()!;
    final habits = List<Map<String, dynamic>>.from(data['habits'] ?? []);
    for (var h in habits) {
      if (h['id'] == habitId) h['streak'] = (h['streak'] as int? ?? 0) + 1;
    }
    await docRef.update({'habits': habits, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> updateProgress(String goalId, double progress) async {
    final docRef = _firestore.collection('goals').doc(goalId);
    await docRef.update({'progress': progress, 'updatedAt': FieldValue.serverTimestamp()});
  }
}
