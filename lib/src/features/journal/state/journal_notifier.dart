import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/journal_entry_model.dart';
import '../data/journal_repository.dart';
import '../../chat/data/ai_provider.dart';
import '../../auth/state/auth_notifier.dart';

final journalRepositoryProvider = Provider<JournalRepository>((ref) => JournalRepository());
final journalNotifierProvider = StateNotifierProvider<JournalNotifier, List<JournalEntry>>((ref) => JournalNotifier(ref.read));

class JournalNotifier extends StateNotifier<List<JournalEntry>> {
  final Reader read;

  JournalNotifier(this.read) : super([]);

  Future<void> loadEntries() async {
    final user = read(journalUserIdProvider);
    if (user == null) return;
    final repo = read(journalRepositoryProvider);
    final entries = await repo.listEntries(user);
    state = entries;
  }

  Future<void> create(String userId, String title, String content, {String? category}) async {
    final repo = read(journalRepositoryProvider);
    final entry = await repo.createEntry(userId: userId, title: title, content: content, category: category);
    state = [entry, ...state];
  }

  Future<void> update(JournalEntry entry) async {
    final repo = read(journalRepositoryProvider);
    await repo.updateEntry(entry);
    state = [for (final e in state) if (e.id == entry.id) entry else e];
  }

  Future<void> delete(String id) async {
    final repo = read(journalRepositoryProvider);
    await repo.deleteEntry(id);
    state = state.where((e) => e.id != id).toList();
  }

  Future<void> search(String q) async {
    final user = read(journalUserIdProvider);
    if (user == null) return;
    if (q.isEmpty) {
      await loadEntries();
      return;
    }
    final repo = read(journalRepositoryProvider);
    final results = await repo.searchEntries(user, q);
    state = results;
  }

  Future<String> generateReflection(String prompt) async {
    final ai = read(aiProviderImpl);
    if (ai == null) return 'AI not configured.';
    return await ai.complete(prompt: prompt);
  }
}

/// Helper provider to get current user id from auth.
final journalUserIdProvider = Provider<String?>((ref) {
  final user = ref.watch(authStateProvider);
  return user?.uid;
});
