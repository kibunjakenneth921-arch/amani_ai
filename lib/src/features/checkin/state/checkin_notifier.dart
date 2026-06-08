import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/checkin_model.dart';
import '../data/checkin_repository.dart';
import '../../auth/state/auth_notifier.dart';

final checkInRepositoryProvider = Provider<CheckInRepository>((ref) => CheckInRepository());
final checkInNotifierProvider = StateNotifierProvider<CheckInNotifier, List<CheckInEntry>>((ref) => CheckInNotifier(ref.read));

class CheckInNotifier extends StateNotifier<List<CheckInEntry>> {
  final Reader read;

  CheckInNotifier(this.read) : super([]);

  Future<void> addCheckIn({required int mood, required int energy, required int stress, String? gratitude, String? notes}) async {
    final user = read(authStateProvider);
    if (user == null) return;
    final repo = read(checkInRepositoryProvider);
    final entry = await repo.createCheckIn(userId: user.uid, mood: mood, energy: energy, stress: stress, gratitude: gratitude, notes: notes);
    state = [entry, ...state];
  }

  Future<void> loadRecent({int days = 30}) async {
    final user = read(authStateProvider);
    if (user == null) return;
    final repo = read(checkInRepositoryProvider);
    final entries = await repo.listRecent(user.uid, days: days);
    state = entries;
  }

  Map<String, double> weeklySummary() {
    if (state.isEmpty) return {'mood': 0, 'energy': 0, 'stress': 0};
    final now = DateTime.now().toUtc();
    final weekAgo = now.subtract(const Duration(days: 7));
    final week = state.where((e) => e.createdAt.toDate().toUtc().isAfter(weekAgo)).toList();
    if (week.isEmpty) return {'mood': 0, 'energy': 0, 'stress': 0};
    double avg(List<int> vals) => vals.reduce((a, b) => a + b) / vals.length;
    return {
      'mood': avg(week.map((e) => e.mood).toList()),
      'energy': avg(week.map((e) => e.energy).toList()),
      'stress': avg(week.map((e) => e.stress).toList()),
    };
  }

  Map<String, double> monthlySummary() {
    if (state.isEmpty) return {'mood': 0, 'energy': 0, 'stress': 0};
    final now = DateTime.now().toUtc();
    final monthAgo = now.subtract(const Duration(days: 30));
    final month = state.where((e) => e.createdAt.toDate().toUtc().isAfter(monthAgo)).toList();
    if (month.isEmpty) return {'mood': 0, 'energy': 0, 'stress': 0};
    double avg(List<int> vals) => vals.reduce((a, b) => a + b) / vals.length;
    return {
      'mood': avg(month.map((e) => e.mood).toList()),
      'energy': avg(month.map((e) => e.energy).toList()),
      'stress': avg(month.map((e) => e.stress).toList()),
    };
  }
}
