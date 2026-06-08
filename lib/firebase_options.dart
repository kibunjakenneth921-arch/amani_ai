// GENERATED FILE NOTE:
// This file provides a runtime fallback for Firebase initialization using
// build-time environment variables. For a real project, run
// `flutterfire configure` to generate a full `firebase_options.dart` file.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

const String _firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
const String _firebaseAuthDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
const String _firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
const String _firebaseStorageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
const String _firebaseMessagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
const String _firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');
const String _firebaseMeasurementId = String.fromEnvironment('FIREBASE_MEASUREMENT_ID');

bool get _hasFirebaseEnv {
  return _firebaseApiKey.isNotEmpty &&
      _firebaseAuthDomain.isNotEmpty &&
      _firebaseProjectId.isNotEmpty &&
      _firebaseStorageBucket.isNotEmpty &&
      _firebaseMessagingSenderId.isNotEmpty &&
      _firebaseAppId.isNotEmpty;
}

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (_hasFirebaseEnv) {
      return FirebaseOptions(
        apiKey: _firebaseApiKey,
        authDomain: _firebaseAuthDomain,
        projectId: _firebaseProjectId,
        storageBucket: _firebaseStorageBucket,
        messagingSenderId: _firebaseMessagingSenderId,
        appId: _firebaseAppId,
        measurementId: _firebaseMeasurementId.isNotEmpty ? _firebaseMeasurementId : null,
      );
    }

    if (kIsWeb) {
      throw UnsupportedError(
        'Firebase options for web are not configured. Run `flutterfire configure` to generate firebase_options.dart, or set FIREBASE_* build-time environment variables.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'Firebase options for Android are not configured. Run `flutterfire configure` to generate firebase_options.dart.',
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'Firebase options for iOS/macOS are not configured. Run `flutterfire configure` to generate firebase_options.dart.',
        );
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Firebase options for desktop platforms are not configured. Run `flutterfire configure` to generate firebase_options.dart.',
        );
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not configured for this platform.');
    }
  }
}
