import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/auth_notifier.dart';

class PasswordResetPage extends ConsumerStatefulWidget {
  const PasswordResetPage({super.key});

  @override
  ConsumerState<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends ConsumerState<PasswordResetPage> {
  final _emailController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(_emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent.')));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send reset email: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loading ? null : _sendReset, child: _loading ? const CircularProgressIndicator() : const Text('Send reset email')),
        ]),
      ),
    );
  }
}
