const admin = require('firebase-admin');
let fetch = globalThis.fetch;
try {
  if (!fetch) fetch = require('node-fetch');
} catch (e) {
  // ignore; fetch may be available globally in newer Node versions
}

// Use emulator environment if set
if (process.env.FIRESTORE_EMULATOR_HOST) {
  process.env.FIRESTORE_EMULATOR_HOST = process.env.FIRESTORE_EMULATOR_HOST.trim();
}

if (process.env.FUNCTIONS_EMULATOR_HOST) {
  process.env.FUNCTIONS_EMULATOR_HOST = process.env.FUNCTIONS_EMULATOR_HOST.trim();
}

admin.initializeApp({ projectId: process.env.GCLOUD_PROJECT || 'demo-project' });
const db = admin.firestore();

async function run() {
  console.log('Running functions integration test against emulator...');
  // Create a test user
  const userId = 'test-user-1';
  await db.collection('users').doc(userId).set({ id: userId, email: 'test@example.com', name: 'Test User' });
  // Add a token
  await db.collection('users').doc(userId).collection('fcmTokens').doc('token1').set({ token: 'fake-token', createdAt: admin.firestore.FieldValue.serverTimestamp() });
  // Add a mood
  await db.collection('moods').doc('m1').set({ id: 'm1', userId: userId, mood: 7, energy: 6, stress: 3, createdAt: admin.firestore.FieldValue.serverTimestamp() });
  // Call computeSummaries by requiring analytics module
  const analytics = require('./analytics');
  await analytics.computeSummaries();
  const summary = await db.collection('analytics').doc(userId).get();
  console.log('Analytics summary:', summary.data());

  // Test sendNotification HTTP function locally if emulator is running on functions port
  const functionsHost = process.env.FUNCTIONS_EMULATOR_HOST || 'http://localhost:5001';
  const project = process.env.GCLOUD_PROJECT || 'demo-project';
  const url = `${functionsHost}/${project}/us-central1/sendNotification`;
  console.log('Calling sendNotification at', url);
  const resp = await fetch(url, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ userId, title: 'Test', body: 'Hello' }) });
  console.log('sendNotification status:', resp.status);
  const body = await resp.text();
  console.log('sendNotification body:', body);

  console.log('Integration test completed.');
}

run().catch(e => { console.error(e); process.exit(1); });
