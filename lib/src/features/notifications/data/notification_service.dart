import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> requestPermissionAndGetToken(String userId) async {
    final settings = await _messaging.requestPermission(alert: true, badge: true, sound: true);
    if (settings.authorizationStatus == AuthorizationStatus.authorized || settings.authorizationStatus == AuthorizationStatus.provisional) {
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveToken(userId, token);
      }
      return token;
    }
    return null;
  }

  Future<void> _saveToken(String userId, String token) async {
    final doc = _firestore.collection('users').doc(userId).collection('fcmTokens').doc(token);
    await doc.set({'token': token, 'createdAt': FieldValue.serverTimestamp()});
  }

  Stream<RemoteMessage> onMessage() => FirebaseMessaging.onMessage;
}
