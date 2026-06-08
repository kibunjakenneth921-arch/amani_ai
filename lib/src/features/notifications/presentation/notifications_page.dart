import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/notification_notifier.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(notificationNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          ElevatedButton(onPressed: () => ref.read(notificationNotifierProvider.notifier).enable(), child: const Text('Enable Push Notifications')),
          const SizedBox(height: 12),
          SelectableText(token ?? 'Token not available'),
          const SizedBox(height: 12),
          const Text('Notes: Server components will use saved tokens to send pushes via FCM. Configure Cloud Functions or external services to send notifications.'),
        ]),
      ),
    );
  }
}
