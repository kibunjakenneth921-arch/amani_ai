process.env.FIRESTORE_EMULATOR_HOST = '127.0.0.1:8085';
const { Firestore } = require('@google-cloud/firestore');
try {
  new Firestore();
  console.log('Firestore instantiated successfully');
} catch (e) {
  console.error('Error instantiating Firestore:', e.message);
  process.exit(1);
}
