import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

final authStateProvider = StateNotifierProvider<AuthNotifier, fb.User?>(
  (ref) => AuthNotifier(ref.read),
);

class AuthNotifier extends StateNotifier<fb.User?> {
  final Reader read;
  late final AuthRepository _repo;

  AuthNotifier(this.read) : super(null) {
    _repo = read(authRepositoryProvider);
    _repo.authStateChanges().listen((user) {
      state = user;
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _repo.signInWithEmail(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, {String? displayName}) async {
    try {
      await _repo.signUpWithEmail(email: email, password: password, displayName: displayName);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await _repo.signInWithGoogle();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
  }
}
