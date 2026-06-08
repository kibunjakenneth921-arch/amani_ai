const functions = require('firebase-functions');
const admin = require('firebase-admin');
const fetch = require('node-fetch');

admin.initializeApp();

// HTTP function to send a push notification to a user's saved FCM tokens.
exports.sendNotification = functions.https.onRequest(async (req, res) => {
  try {
    const { userId, title, body, data } = req.body;
    if (!userId || !title || !body) return res.status(400).send('Missing params');

    const tokensSnap = await admin.firestore().collection('users').doc(userId).collection('fcmTokens').get();
    const tokens = tokensSnap.docs.map(d => d.id);
    if (!tokens.length) return res.status(200).send('No tokens');

    const message = {
      notification: { title, body },
      tokens,
      data: data || {},
    };

    const resp = await admin.messaging().sendMulticast(message);
    return res.status(200).send({ success: resp.successCount, failure: resp.failureCount });
  } catch (e) {
    console.error(e);
    return res.status(500).send(e.toString());
  }
});

// HTTP function to perform simple moderation or forward to OpenAI moderation endpoint if OPENAI_API_KEY is set.
exports.moderateContent = functions.https.onRequest(async (req, res) => {
  try {
    const { text } = req.body;
    if (!text) return res.status(400).send('Missing text');

    // Basic keyword-based check (example). For production use a proper moderation API.
    const forbidden = ['suicide', 'kill', 'bomb'];
    const lowered = text.toLowerCase();
    for (const f of forbidden) {
      if (lowered.includes(f)) return res.status(200).send({ flagged: true, reason: 'profanity/violence' });
    }

    // Optional: call OpenAI moderation if key provided in env
    const openaiKey = process.env.OPENAI_API_KEY;
    if (openaiKey) {
      const resp = await fetch('https://api.openai.com/v1/moderations', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${openaiKey}` },
        body: JSON.stringify({ input: text })
      });
      const json = await resp.json();
      return res.status(200).send({ flagged: json.results?.[0]?.flagged || false, details: json });
    }

    return res.status(200).send({ flagged: false });
  } catch (e) {
    console.error(e);
    return res.status(500).send(e.toString());
  }
});

// Scheduled analytics: daily summary
const analytics = require('./analytics');
exports.scheduledAnalytics = functions.pubsub.schedule('every 24 hours').onRun(async (context) => {
  try {
    await analytics.computeSummaries();
    return null;
  } catch (e) {
    console.error('Analytics job failed', e);
    return null;
  }
});

// Scheduled motivational notifications: pick a random message and send to users daily.
const MOTIVATIONAL_MESSAGES = [
  'Take a deep breath — you’re doing your best.',
  'Small steps create big change. Keep going.',
  'Reflection is progress. Be kind to yourself today.',
  'One positive step today is worth a thousand tomorrow.',
];

exports.sendDailyMotivation = functions.pubsub.schedule('every 24 hours').onRun(async (context) => {
  try {
    const usersSnap = await admin.firestore().collection('users').get();
    for (const userDoc of usersSnap.docs) {
      const tokensSnap = await admin.firestore().collection('users').doc(userDoc.id).collection('fcmTokens').get();
      const tokens = tokensSnap.docs.map(d => d.id);
      if (!tokens.length) continue;
      const msg = MOTIVATIONAL_MESSAGES[Math.floor(Math.random() * MOTIVATIONAL_MESSAGES.length)];
      await admin.messaging().sendMulticast({ notification: { title: 'Amani AI — Daily Check-in', body: msg }, tokens });
    }
    return null;
  } catch (e) {
    console.error('sendDailyMotivation failed', e);
    return null;
  }
});
