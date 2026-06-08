import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notification_service.dart';
import '../../auth/state/auth_notifier.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());
final notificationNotifierProvider = StateNotifierProvider<NotificationNotifier, String?>((ref) => NotificationNotifier(ref.read));

class NotificationNotifier extends StateNotifier<String?> {
  final Reader read;

  NotificationNotifier(this.read) : super(null);

  Future<void> enable() async {
    final user = read(authStateProvider);
    if (user == null) return;
    final token = await read(notificationServiceProvider).requestPermissionAndGetToken(user.uid);
    state = token;
  }

  Stream<dynamic> onMessage() => read(notificationServiceProvider).onMessage();
}
