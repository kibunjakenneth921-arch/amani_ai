import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../state/auth_notifier.dart';

import 'password_reset_page.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      await ref.read(authStateProvider.notifier).signIn(_emailController.text.trim(), _passwordController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign-in failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      await ref.read(authStateProvider.notifier).signInWithGoogle();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google sign-in failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _loading ? null : _signIn, child: _loading ? const CircularProgressIndicator() : const Text('Sign In')),
            const SizedBox(height: 8),
            TextButton(onPressed: () => context.go('/sign-up'), child: const Text('Create account')),
            const SizedBox(height: 8),
            TextButton(onPressed: () => context.go('/reset-password'), child: const Text('Forgot password?')),
            const SizedBox(height: 12),
            ElevatedButton.icon(onPressed: _loading ? null : _signInWithGoogle, icon: const Icon(Icons.login), label: const Text('Sign in with Google')),
          ],
        ),
      ),
    );
  }
}
