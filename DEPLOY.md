# Live Launch Checklist

This checklist walks through deploying the frontend (Vercel) and backend (Firebase).

## 1) Prepare Firebase

- Create a Firebase project and enable Authentication, Firestore, Storage, Cloud Messaging, and Google Analytics.
- Install FlutterFire CLI and run:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

- Commit the generated `lib/firebase_options.dart` to the repo (or provide equivalent runtime config via `--dart-define`). Ensure the generated options contain the Analytics measurement ID.

## 2) Frontend (Vercel)

- Connect repository to Vercel.
- Set build command: `npm run build`.
- Set output directory: `build/web`.
- Add Vercel environment variables if you prefer not to commit `firebase_options.dart` and instead provide Firebase config via `--dart-define`.

Example Vercel env keys:
- `FIREBASE_API_KEY`
- `FIREBASE_AUTH_DOMAIN`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_STORAGE_BUCKET`
- `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_APP_ID`
- `FIREBASE_MEASUREMENT_ID`

If using `--dart-define`, add a build step that passes them:

```bash
flutter build web --release --dart-define=FIREBASE_API_KEY=$FIREBASE_API_KEY \
  --dart-define=FIREBASE_AUTH_DOMAIN=$FIREBASE_AUTH_DOMAIN \
  --dart-define=FIRESTORE_PROJECT_ID=$FIRESTORE_PROJECT_ID \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=$FIREBASE_MESSAGING_SENDER_ID \
  --dart-define=FIREBASE_APP_ID=$FIREBASE_APP_ID
```

## 3) Backend (Firebase Functions)

- From repository root:

```bash
cd functions
npm ci
firebase deploy --only functions
```

- Provide the `FIREBASE_TOKEN` secret in CI for automated deploys (generate with `firebase login:ci`).

## 4) Verify

- Visit the Vercel URL and sign in.
- Confirm Firestore reads/writes in the Firebase Console.
- Check Cloud Functions logs in the Firebase Console for any errors.

## 5) Local integration tests (emulator)

- Start emulators and run the test script from the repository root:

```bash
cd functions
npm ci
# from repo root
npx firebase emulators:exec --only firestore,functions --project demo-project "node functions/integration_test.js"
```

This runs the emulators temporarily and stops them when the script completes.
