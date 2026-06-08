import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/sign_in_page.dart';
import '../features/auth/presentation/sign_up_page.dart';
import '../features/auth/presentation/password_reset_page.dart';
import '../features/core/app_shell.dart';
import '../features/home/presentation/home_page.dart';
import '../features/chat/presentation/chat_page.dart';
import '../features/journal/presentation/journal_page.dart';
import '../features/auth/presentation/profile_page.dart';
import '../features/auth/state/auth_notifier.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: user == null ? '/sign-in' : '/home',
    routes: [
      GoRoute(path: '/sign-in', builder: (context, state) => const SignInPage()),
      GoRoute(path: '/sign-up', builder: (context, state) => const SignUpPage()),
      GoRoute(path: '/reset-password', builder: (context, state) => const PasswordResetPage()),
      GoRoute(
        path: '/',
        builder: (context, state) => const AppShell(),
        routes: [
          GoRoute(path: 'home', builder: (context, state) => const HomePage()),
          GoRoute(path: 'goals', builder: (context, state) => const GoalsPage()),
          GoRoute(path: 'check-in', builder: (context, state) => const CheckInPage()),
          GoRoute(path: 'chat', builder: (context, state) => const ChatPage()),
          GoRoute(path: 'journal', builder: (context, state) => const JournalPage()),
          GoRoute(path: 'profile', builder: (context, state) => const ProfilePage()),
        ],
      ),
    ],
    redirect: (context, state) {
      final loggingIn = state.location == '/sign-in' || state.location == '/sign-up' || state.location == '/reset-password';
      if (user == null && !loggingIn) return '/sign-in';
      if (user != null && loggingIn) return '/home';
      return null;
    },
  );
});
