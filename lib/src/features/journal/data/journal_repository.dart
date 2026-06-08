import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/journal_entry_model.dart';
import 'package:uuid/uuid.dart';

class JournalRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Future<JournalEntry> createEntry({required String userId, required String title, required String content, String? category}) async {
    final id = _uuid.v4();
    final doc = _firestore.collection('journals').doc(id);
    final now = FieldValue.serverTimestamp();
    await doc.set({
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'category': category,
      'createdAt': now,
      'updatedAt': now,
    });

    final snapshot = await doc.get();
    return JournalEntry.fromMap(snapshot.data()!);
  }

  Future<void> updateEntry(JournalEntry entry) async {
    final doc = _firestore.collection('journals').doc(entry.id);
    await doc.update({
      'title': entry.title,
      'content': entry.content,
      'category': entry.category,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteEntry(String id) async {
    await _firestore.collection('journals').doc(id).delete();
  }

  Future<List<JournalEntry>> listEntries(String userId, {int limit = 50}) async {
    final snap = await _firestore.collection('journals').where('userId', isEqualTo: userId).orderBy('createdAt', descending: true).limit(limit).get();
    return snap.docs.map((d) => JournalEntry.fromMap(d.data())).toList();
  }

  Future<List<JournalEntry>> searchEntries(String userId, String query, {int limit = 50}) async {
    // Simple client-side filter: Firestore text search requires extensions or paid services.
    final all = await listEntries(userId, limit: limit);
    final lower = query.toLowerCase();
    return all.where((e) => e.title.toLowerCase().contains(lower) || e.content.toLowerCase().contains(lower)).toList();
  }
}
