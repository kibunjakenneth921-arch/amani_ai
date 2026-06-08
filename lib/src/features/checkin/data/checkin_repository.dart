import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/checkin_model.dart';
import 'package:uuid/uuid.dart';

class CheckInRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Future<CheckInEntry> createCheckIn({required String userId, required int mood, required int energy, required int stress, String? gratitude, String? notes}) async {
    final id = _uuid.v4();
    final doc = _firestore.collection('moods').doc(id);
    final now = FieldValue.serverTimestamp();
    await doc.set({
      'id': id,
      'userId': userId,
      'mood': mood,
      'energy': energy,
      'stress': stress,
      'gratitude': gratitude,
      'notes': notes,
      'createdAt': now,
    });
    final snap = await doc.get();
    return CheckInEntry.fromMap(snap.data()!);
  }

  Future<List<CheckInEntry>> listRecent(String userId, {int days = 30}) async {
    final since = DateTime.now().toUtc().subtract(Duration(days: days));
    final snap = await _firestore.collection('moods').where('userId', isEqualTo: userId).where('createdAt', isGreaterThan: Timestamp.fromDate(since)).orderBy('createdAt', descending: true).get();
    return snap.docs.map((d) => CheckInEntry.fromMap(d.data())).toList();
  }

  Future<List<CheckInEntry>> listRange(String userId, DateTime from, DateTime to) async {
    final snap = await _firestore.collection('moods').where('userId', isEqualTo: userId).where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from)).where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(to)).orderBy('createdAt', descending: true).get();
    return snap.docs.map((d) => CheckInEntry.fromMap(d.data())).toList();
  }
}
