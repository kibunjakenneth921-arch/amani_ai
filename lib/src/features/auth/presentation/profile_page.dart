import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/auth_notifier.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Logged in as: ${user?.email ?? 'Unknown'}'),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () => ref.read(authStateProvider.notifier).signOut(), child: const Text('Sign out')),
        ]),
      ),
    );
  }
}
