const admin = require('firebase-admin');

/**
 * Compute simple analytics summaries per user and store in `analytics/{userId}`.
 * This function can be scheduled to run daily.
 */
async function computeSummaries() {
  const db = admin.firestore();
  const usersSnap = await db.collection('users').get();
  const now = new Date();
  for (const userDoc of usersSnap.docs) {
    const userId = userDoc.id;
    // Count journal entries
    const journalsSnap = await db.collection('journals').where('userId', '==', userId).get();
    const journalCount = journalsSnap.size;

    // Average mood over last 30 days
    const from = new Date();
    from.setDate(now.getDate() - 30);
    const moodsSnap = await db.collection('moods').where('userId', '==', userId).where('createdAt', '>=', admin.firestore.Timestamp.fromDate(from)).get();
    let avgMood = 0;
    if (moodsSnap.size > 0) {
      const nums = moodsSnap.docs.map(d => d.data().mood || 0);
      avgMood = nums.reduce((a, b) => a + b, 0) / nums.length;
    }

    // Goal progress avg
    const goalsSnap = await db.collection('goals').where('userId', '==', userId).get();
    let avgGoalProgress = 0;
    if (goalsSnap.size > 0) {
      const vals = goalsSnap.docs.map(d => (d.data().progress || 0));
      avgGoalProgress = vals.reduce((a, b) => a + b, 0) / vals.length;
    }

    await db.collection('analytics').doc(userId).set({
      journalCount,
      avgMood,
      avgGoalProgress,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
  }
}

module.exports = { computeSummaries };
