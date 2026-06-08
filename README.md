# Amani AI

Find Peace. Gain Clarity. Grow Forward.

Amani AI is an AI-powered listening, reflection, and personal growth companion built with Flutter and Firebase.

This repository contains a production-oriented scaffold following Clean Architecture and Riverpod state management.

## Front-end / Back-end deployment

### Front-end

The Flutter web app can deploy as a static site.

- For Vercel deployment, use `npm run build` and set the output directory to `build/web`.
- You can also deploy the generated web assets to Firebase Hosting with `flutter build web --release`.

### Back-end

The backend is Firebase-based.

- Firestore stores user data and journal/chat records.
- Firebase Authentication handles sign-in.
- Cloud Functions run scheduled analytics and messaging jobs.
- Deploy backend services separately with:

```bash
cd functions
npm install
firebase deploy --only functions
```

> Note: Vercel serves only the static frontend. The Firebase backend must remain deployed to Firebase.

## Vercel deployment

This project can deploy the Flutter web build to Vercel as a static site.

1. Add the repo to Vercel.
2. Set the build command to:

```bash
npm run build
```

3. Set the output directory to:

```bash
build/web
```

4. Deploy.

Vercel will download Flutter, build the web app, and serve the generated static files.

> Set `GEMINI_API_KEY` in Vercel environment variables and the build script will pass it into Flutter with `--dart-define`. If you need a custom Gemini endpoint, also set `GEMINI_API_URL`.
>
> Set Firebase build-time env vars in Vercel if you do not want to commit a generated `lib/firebase_options.dart`:
> `FIREBASE_API_KEY`, `FIREBASE_AUTH_DOMAIN`, `FIREBASE_PROJECT_ID`, `FIREBASE_STORAGE_BUCKET`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_APP_ID`, `FIREBASE_MEASUREMENT_ID`.
>
> The app supports runtime Firebase initialization from these `FIREBASE_*` env vars when built with `npm run build`.

Getting started

1. Install Flutter: https://flutter.dev/docs/get-started/install
2. Install Firebase CLI and FlutterFire CLI for platform-specific config: https://firebase.flutter.dev/
3. From repository root run:

```bash
flutter pub get
```

Firebase setup

- Create a Firebase project and enable Authentication, Firestore, Storage, Cloud Messaging, and Google Analytics.
- Run `flutterfire configure` to generate `lib/firebase_options.dart` with analytics measurement IDs included.
- If you want Google Analytics for the web build, make sure Firebase Hosting and web app settings include your Analytics measurement ID.

Development

- Run on device or web:

```bash
flutter run
```

Build

```bash
flutter build apk
flutter build appbundle
```

Folder structure

- lib/: application source
  - src/core/: shared theming, routing, constants
  - src/features/: feature-first modules (auth, chat, journal...)

Next steps

- Configure Firebase project and fill in `lib/firebase_options.dart` with your options.
- Continue implementing feature modules; start with Authentication.

Firebase setup

- Run the FlutterFire CLI to generate platform options (recommended):

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This will create `lib/firebase_options.dart` with platform-specific values. Replace the placeholder currently in the repo.

Building

- Android APK / AAB:

```bash
flutter pub get
flutter build apk --release
flutter build appbundle --release
```

- Web (for Firebase Hosting):

```bash
flutter build web --release
```

Continuous Integration

This repo includes GitHub Actions workflows in `.github/workflows/`:
- `ci.yml`: runs `flutter analyze` and `flutter test` on push/PR to `main`.
- `build.yml`: manual workflow to build APK and upload as artifact.
- `deploy.yml`: manual workflow that builds web and deploys to Firebase Hosting using the secret `FIREBASE_TOKEN`.

Security rules

Firestore and Storage rules are included under `firebase/`:
- `firebase/firestore.rules`
- `firebase/storage.rules`

Notifications

The app saves FCM tokens under `users/{uid}/fcmTokens`. Configure a server (Cloud Functions or external service) to send pushes via FCM.

Notes

- The Gemini AI provider in `lib/src/features/chat/data/gemini_ai_provider.dart` uses placeholder endpoints. Provide a real endpoint and set `GEMINI_API_KEY` via `--dart-define` when building.
- For production analytics or heavy aggregation, consider using Cloud Functions to compute summaries to avoid client-side costs.
Emulators & scheduled analytics

- To run the Firebase emulators locally (Firestore, Functions, Hosting):

```bash
firebase emulators:start --only firestore,functions,hosting
```

- A helper script is included at `scripts/run_emulators.sh`.

- The Cloud Functions folder includes `analytics.js` and a scheduled function `scheduledAnalytics` which computes per-user summaries and writes them to `analytics/{userId}`. Deploy functions with:

```bash
cd functions
npm install
firebase deploy --only functions

Scheduled motivations

The Functions include `sendDailyMotivation`, a scheduled job that sends a short motivational message to users with saved FCM tokens. Configure Cloud Scheduler via Firebase when deploying functions.

Integration test script

In `functions/integration_test.js` there is a small script that can be run against emulators to validate functions and summaries. Start emulators then run:

```bash
cd functions
node integration_test.js
```

Hosting & preview

To preview the web UI locally (quick):

```bash
# Serve the Flutter web app locally on port 5000
flutter pub get
flutter run -d web-server --web-port=5000 --web-hostname=0.0.0.0
# then open http://localhost:5000 in your browser
```

To deploy to Firebase Hosting (produces a public link like `https://<PROJECT>.web.app`):

1. Create a Firebase project and set up Hosting via `flutterfire configure` or the Firebase console.
2. Add a secret `FIREBASE_TOKEN` for CI (generate via `firebase login:ci`).
3. In GitHub, add `FIREBASE_TOKEN` and `FIREBASE_PROJECT_ID` to repository secrets.
4. Push to `main` — the workflow `.github/workflows/deploy-hosting.yml` will build and deploy.

After deployment, your site URL is visible in the Firebase Console and typically is `https://<PROJECT>.web.app` or `https://<PROJECT>.firebaseapp.com`.
```

