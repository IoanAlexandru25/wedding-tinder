import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  const AuthService(this._auth);

  final FirebaseAuth _auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('Auth user missing after sign-in.');
    }
    return user;
  }

  Future<User> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    var user = credential.user;
    if (user == null) {
      throw StateError('Auth user missing after sign-up.');
    }
    final trimmed = displayName.trim();
    if (trimmed.isNotEmpty) {
      await user.updateDisplayName(trimmed);
      await user.reload();
      user = _auth.currentUser ?? user;
    }
    return user;
  }

  Future<void> signOut() => _auth.signOut();
}
