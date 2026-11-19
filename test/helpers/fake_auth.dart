import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:wedding_tinder/services/auth_service.dart';

class FakeUserMetadata implements fb_auth.UserMetadata {
  FakeUserMetadata(this.creationTime);

  @override
  final DateTime? creationTime;

  @override
  DateTime? get lastSignInTime => null;
}

class FakeFirebaseUser implements fb_auth.User {
  FakeFirebaseUser({
    required this.uid,
    this.email,
    this.displayName,
    DateTime? creationTime,
  }) : metadata = FakeUserMetadata(creationTime);

  @override
  final String uid;

  @override
  final String? email;

  @override
  final String? displayName;

  @override
  final fb_auth.UserMetadata metadata;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Stand-in for [AuthService] that never touches Firebase.
///
/// Successful sign-in/sign-up pushes the user onto [authStateController],
/// mimicking Firebase's `authStateChanges()` stream.
class FakeAuthService implements AuthService {
  final StreamController<fb_auth.User?> authStateController =
      StreamController<fb_auth.User?>.broadcast();

  fb_auth.FirebaseAuthException? nextError;
  FakeFirebaseUser userToReturn = FakeFirebaseUser(
    uid: 'uid_1',
    email: 'ana@example.com',
    displayName: 'Ana',
  );
  int signOutCalls = 0;

  void emit(fb_auth.User? user) => authStateController.add(user);

  @override
  Stream<fb_auth.User?> authStateChanges() => authStateController.stream;

  @override
  Future<fb_auth.User> signIn({
    required String email,
    required String password,
  }) async {
    final error = nextError;
    if (error != null) throw error;
    emit(userToReturn);
    return userToReturn;
  }

  @override
  Future<fb_auth.User> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final error = nextError;
    if (error != null) throw error;
    emit(userToReturn);
    return userToReturn;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    emit(null);
  }

  Future<void> dispose() => authStateController.close();
}

/// Lets fire-and-forget futures and stream events settle.
Future<void> settle() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}
