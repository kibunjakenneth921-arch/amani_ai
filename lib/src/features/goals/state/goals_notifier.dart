import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/goal_model.dart';
import '../data/goals_repository.dart';
import '../../auth/state/auth_notifier.dart';

final goalsRepositoryProvider = Provider<GoalsRepository>((ref) => GoalsRepository());
final goalsNotifierProvider = StateNotifierProvider<GoalsNotifier, List<Goal>>((ref) => GoalsNotifier(ref.read));

class GoalsNotifier extends StateNotifier<List<Goal>> {
  final Reader read;

  GoalsNotifier(this.read) : super([]);

  Future<void> loadGoals() async {
    final user = read(authStateProvider);
    if (user == null) return;
    final repo = read(goalsRepositoryProvider);
    final list = await repo.listGoals(user.uid);
    state = list;
  }

  Future<void> createGoal(String title, {String description = '', DateTime? targetDate}) async {
    final user = read(authStateProvider);
    if (user == null) return;
    final repo = read(goalsRepositoryProvider);
    final g = await repo.createGoal(userId: user.uid, title: title, description: description, targetDate: targetDate);
    state = [g, ...state];
  }

  Future<void> updateGoal(Goal g) async {
    final repo = read(goalsRepositoryProvider);
    await repo.updateGoal(g);
    state = [for (final x in state) if (x.id == g.id) g else x];
  }

  Future<void> deleteGoal(String id) async {
    final repo = read(goalsRepositoryProvider);
    await repo.deleteGoal(id);
    state = state.where((g) => g.id != id).toList();
  }

  Future<void> addMilestone(String goalId, Milestone m) async {
    final repo = read(goalsRepositoryProvider);
    await repo.addMilestone(goalId, m);
    await loadGoals();
  }

  Future<void> completeMilestone(String goalId, String milestoneId) async {
    final repo = read(goalsRepositoryProvider);
    await repo.completeMilestone(goalId, milestoneId);
    await loadGoals();
  }

  Future<void> addHabit(String goalId, Habit h) async {
    final repo = read(goalsRepositoryProvider);
    await repo.addHabit(goalId, h);
    await loadGoals();
  }

  Future<void> incrementHabitStreak(String goalId, String habitId) async {
    final repo = read(goalsRepositoryProvider);
    await repo.incrementHabitStreak(goalId, habitId);
    await loadGoals();
  }

  Future<void> updateProgress(String goalId, double progress) async {
    final repo = read(goalsRepositoryProvider);
    await repo.updateProgress(goalId, progress);
    await loadGoals();
  }

  Map<String, dynamic> weeklyInsights() {
    // Placeholder: compute simple stats
    final avgProgress = state.isEmpty ? 0.0 : state.map((g) => g.progress).reduce((a, b) => a + b) / state.length;
    return {'avgProgress': avgProgress};
  }
}
