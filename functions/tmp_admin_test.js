process.env.FIRESTORE_EMULATOR_HOST = '127.0.0.1:8085';
const admin = require('firebase-admin');
try {
  admin.initializeApp({ projectId: 'demo-project' });
  const db = admin.firestore();
  console.log('firebase-admin Firestore initialized');
} catch (e) {
  console.error('firebase-admin error:', e.message);
  process.exit(1);
}
