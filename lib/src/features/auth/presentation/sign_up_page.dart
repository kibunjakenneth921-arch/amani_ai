import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/auth_notifier.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() => _loading = true);
    try {
      await ref.read(authStateProvider.notifier).signUp(_emailController.text.trim(), _passwordController.text, displayName: _nameController.text.trim());
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign-up failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full name')),
          const SizedBox(height: 12),
          TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 12),
          TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _loading ? null : _signUp, child: _loading ? const CircularProgressIndicator() : const Text('Create account')),
          const SizedBox(height: 8),
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Back to sign in')),
        ]),
      ),
    );
  }
}
