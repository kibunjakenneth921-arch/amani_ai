import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/sign_in_page.dart';
import '../../features/auth/presentation/sign_up_page.dart';
import '../../features/auth/presentation/password_reset_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/sign-in',
    routes: [
      GoRoute(path: '/sign-in', builder: (context, state) => const SignInPage()),
      GoRoute(path: '/sign-up', builder: (context, state) => const SignUpPage()),
      GoRoute(path: '/reset-password', builder: (context, state) => const PasswordResetPage()),
    ],
  );
}
