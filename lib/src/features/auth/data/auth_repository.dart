import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<fb.User?> authStateChanges() => _auth.authStateChanges();

  fb.User? get currentUser => _auth.currentUser;

  Future<fb.UserCredential> signInWithEmail({required String email, required String password}) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<fb.UserCredential> signUpWithEmail({required String email, required String password, String? displayName}) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    // Optionally set display name
    if (displayName != null && cred.user != null) {
      await cred.user!.updateDisplayName(displayName);
    }
    await _createUserDocument(cred.user);
    return cred;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<fb.UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    await _createUserDocument(cred.user);
    return cred;
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  Future<void> _createUserDocument(fb.User? user) async {
    if (user == null) return;
    final doc = _firestore.collection('users').doc(user.uid);
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await doc.set({
        'id': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? null,
        'ageRange': null,
        'goals': <String>[],
        'preferences': {},
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
