// Trim any accidental whitespace in environment variables
if (process.env.FIRESTORE_EMULATOR_HOST) process.env.FIRESTORE_EMULATOR_HOST = process.env.FIRESTORE_EMULATOR_HOST.trim();
if (process.env.FUNCTIONS_EMULATOR_HOST) process.env.FUNCTIONS_EMULATOR_HOST = process.env.FUNCTIONS_EMULATOR_HOST.trim();
if (process.env.GCLOUD_PROJECT) process.env.GCLOUD_PROJECT = process.env.GCLOUD_PROJECT.trim();

console.log('FIRESTORE_EMULATOR_HOST=', process.env.FIRESTORE_EMULATOR_HOST);
console.log('FUNCTIONS_EMULATOR_HOST=', process.env.FUNCTIONS_EMULATOR_HOST);
console.log('GCLOUD_PROJECT=', process.env.GCLOUD_PROJECT);

require('./integration_test.js');
