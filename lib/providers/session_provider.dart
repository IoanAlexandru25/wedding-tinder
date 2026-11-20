import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../models/wedding.dart';
import '../services/auth_service.dart';
import '../services/service_exception.dart';
import 'service_providers.dart';

final firebaseAuthProvider =
    Provider<fb_auth.FirebaseAuth>((_) => fb_auth.FirebaseAuth.instance);

final authServiceProvider =
    Provider<AuthService>((ref) => AuthService(ref.watch(firebaseAuthProvider)));

final authStateChangesProvider = StreamProvider<fb_auth.User?>(
  (ref) => ref.watch(authServiceProvider).authStateChanges(),
);

class SessionState {
  const SessionState({
    this.user,
    this.wedding,
    this.isLoading = false,
    this.error,
  });

  final UserModel? user;
  final Wedding? wedding;
  final bool isLoading;
  final String? error;

  bool get isSignedIn => user != null;
  bool get hasWedding => wedding != null;
  bool get isReady => isSignedIn && hasWedding;

  SessionState copyWith({
    UserModel? user,
    Wedding? wedding,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearUser = false,
    bool clearWedding = false,
  }) {
    return SessionState(
      user: clearUser ? null : (user ?? this.user),
      wedding: clearWedding ? null : (wedding ?? this.wedding),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class SessionNotifier extends Notifier<SessionState> {
  bool _signUpInProgress = false;
  String? _signUpDisplayName;

  @override
  SessionState build() {
    ref.listen<AsyncValue<fb_auth.User?>>(
      authStateChangesProvider,
      (_, next) {
        next.whenData((firebaseUser) {
          if (firebaseUser == null) {
            state = const SessionState();
            return;
          }
          final switchingUser =
              state.user != null && state.user!.id != firebaseUser.uid;
          state = state.copyWith(
            user: _fromFirebase(
              firebaseUser,
              displayName: _signUpInProgress ? _signUpDisplayName : null,
            ),
            isLoading: true,
            clearError: true,
            clearWedding: switchingUser,
          );
          if (_signUpInProgress) return;
          _loadWeddingForUser(firebaseUser); // fire-and-forget
        });
      },
    );
    return const SessionState();
  }

  Future<void> _loadWeddingForUser(fb_auth.User firebaseUser) async {
    try {
      final userModel = await _backfillDisplayName(
        await ref.read(userServiceProvider).getUser(firebaseUser.uid),
        firebaseUser.displayName,
      );
      if (state.user?.id != firebaseUser.uid) return;
      state = state.copyWith(user: userModel);

      final weddingId = userModel.weddingId;
      if (weddingId != null) {
        final wedding =
            await ref.read(weddingServiceProvider).getWedding(weddingId);
        if (state.user?.id != firebaseUser.uid) return;
        state = state.copyWith(wedding: wedding, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } on UserException catch (e) {
      if (e.code == 'not-found') await _ensureUserDoc(firebaseUser);
      if (state.user?.id == firebaseUser.uid) {
        state = state.copyWith(isLoading: false);
      }
    } on WeddingException {
      if (state.user?.id == firebaseUser.uid) {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      if (state.user?.id == firebaseUser.uid) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(authServiceProvider).signIn(
            email: email,
            password: password,
          );
    } on fb_auth.FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _authErrorMessage(e),
      );
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final name = displayName.trim();
    _signUpInProgress = true;
    _signUpDisplayName = name.isEmpty ? null : name;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final firebaseUser = await ref.read(authServiceProvider).signUp(
            email: email,
            password: password,
            displayName: name,
          );
      final profile = await _createOrCompleteProfile(
        userId: firebaseUser.uid,
        email: email,
        displayName: _signUpDisplayName,
      );
      final weddingId = profile.weddingId;
      final wedding = weddingId == null
          ? null
          : await ref.read(weddingServiceProvider).getWedding(weddingId);
      if (state.user?.id != firebaseUser.uid) return;
      state = state.copyWith(
        user: profile.displayName == null
            ? profile.copyWith(displayName: state.user?.displayName)
            : profile,
        wedding: wedding,
        isLoading: false,
      );
    } on fb_auth.FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _authErrorMessage(e),
      );
    } on ServiceException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: _connectionError);
    } finally {
      _signUpInProgress = false;
      _signUpDisplayName = null;
    }
  }

  Future<UserModel> _createOrCompleteProfile({
    required String userId,
    required String email,
    required String? displayName,
  }) async {
    final userService = ref.read(userServiceProvider);
    try {
      return await userService.createUser(
        userId: userId,
        email: email,
        displayName: displayName,
      );
    } on UserException catch (e) {
      if (e.code != 'already-exists') rethrow;
      final existing = await userService.getUser(userId);
      if (displayName == null || existing.displayName == displayName) {
        return existing;
      }
      return userService.updateUser(userId, displayName: displayName);
    }
  }

  Future<UserModel> _backfillDisplayName(
    UserModel profile,
    String? authDisplayName,
  ) async {
    final current = profile.displayName?.trim() ?? '';
    final fromAuth = authDisplayName?.trim() ?? '';
    if (current.isNotEmpty || fromAuth.isEmpty) return profile;
    try {
      return await ref
          .read(userServiceProvider)
          .updateUser(profile.id, displayName: fromAuth);
    } catch (_) {
      return profile.copyWith(displayName: fromAuth);
    }
  }

  Future<void> _ensureUserDoc(fb_auth.User firebaseUser) async {
    final userService = ref.read(userServiceProvider);
    try {
      await userService.getUser(firebaseUser.uid);
    } on UserException catch (e) {
      if (e.code != 'not-found') return;
      try {
        await userService.createUser(
          userId: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName,
        );
      } on UserException {
        // already-exists — concurrent create, safe to ignore.
      }
    }
  }

  Future<void> createWedding({
    required DateTime weddingDateStart,
    required DateTime weddingDateEnd,
    required int guestCount,
    required int budgetMin,
    required int budgetMax,
  }) async {
    final user = state.user;
    if (user == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final wedding = await ref.read(weddingServiceProvider).createWedding(
            userId: user.id,
            start: weddingDateStart,
            end: weddingDateEnd,
            guestCount: guestCount,
            budgetMin: budgetMin,
            budgetMax: budgetMax,
          );
      state = state.copyWith(wedding: wedding, isLoading: false);
    } on WeddingException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> updateWedding({
    required DateTime weddingDateStart,
    required DateTime weddingDateEnd,
    required int guestCount,
    required int budgetMin,
    required int budgetMax,
  }) async {
    final current = state.wedding;
    if (current == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updated = await ref.read(weddingServiceProvider).updateWedding(
            current.id,
            start: weddingDateStart,
            end: weddingDateEnd,
            guestCount: guestCount,
            budgetMin: budgetMin,
            budgetMax: budgetMax,
          );
      state = state.copyWith(wedding: updated, isLoading: false);
    } on WeddingException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> joinWedding(String inviteCode) async {
    final user = state.user;
    if (user == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final wedding = await ref.read(weddingServiceProvider).joinWedding(
            inviteCode.trim().toUpperCase(),
            userId: user.id,
          );
      state = state.copyWith(wedding: wedding, isLoading: false);
    } on WeddingException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  void signOut() {
    ref.read(authServiceProvider).signOut();
  }

  static String _displayNameFromEmail(String email) {
    final local = email.split('@').first;
    if (local.isEmpty) return 'You';
    final words = local.split(RegExp(r'[._\-+]'));
    final cleaned = words
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .toList();
    return cleaned.isEmpty ? 'You' : cleaned.join(' ');
  }

  static const String _connectionError =
      'Could not reach the server. Check your connection and try again.';

  static UserModel _fromFirebase(fb_auth.User user, {String? displayName}) {
    final email = user.email ?? '';
    return UserModel(
      id: user.uid,
      email: email,
      displayName:
          displayName ?? user.displayName ?? _displayNameFromEmail(email),
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  static String _authErrorMessage(fb_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Password is too weak.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}

final sessionProvider =
    NotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);

final currentWeddingIdProvider = Provider<String?>((ref) {
  return ref.watch(sessionProvider).wedding?.id;
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(sessionProvider).user?.id;
});
