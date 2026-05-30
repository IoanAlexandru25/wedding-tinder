import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/invite_code_generator.dart';
import '../models/user_model.dart';
import '../models/wedding.dart';
import '../services/auth_service.dart';

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
          final shouldClearWedding =
              state.user != null && state.user!.id != firebaseUser.uid;
          state = state.copyWith(
            user: _fromFirebase(firebaseUser),
            isLoading: false,
            clearError: true,
            clearWedding: shouldClearWedding,
          );
        });
      },
    );
    return const SessionState();
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
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(authServiceProvider).signUp(
            email: email,
            password: password,
            displayName: displayName,
          );
    } on fb_auth.FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _authErrorMessage(e),
      );
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
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final wedding = Wedding(
      id: 'wed_mock_${DateTime.now().millisecondsSinceEpoch}',
      inviteCode: InviteCodeGenerator.generate(),
      partnerIds: [user.id],
      weddingDateStart: weddingDateStart,
      weddingDateEnd: weddingDateEnd,
      guestCount: guestCount,
      budgetMin: budgetMin,
      budgetMax: budgetMax,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(wedding: wedding, isLoading: false);
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
    await Future<void>.delayed(const Duration(milliseconds: 250));
    state = state.copyWith(
      wedding: current.copyWith(
        weddingDateStart: weddingDateStart,
        weddingDateEnd: weddingDateEnd,
        guestCount: guestCount,
        budgetMin: budgetMin,
        budgetMax: budgetMax,
      ),
      isLoading: false,
    );
  }

  Future<void> joinWedding(String inviteCode) async {
    final user = state.user;
    if (user == null) return;
    if (!InviteCodeGenerator.isValidFormat(inviteCode)) {
      state = state.copyWith(error: 'Invite code format is invalid.');
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    // Mock: pretend the code resolves to a wedding hosted by another partner.
    final wedding = _mockSeededWedding(user.id).copyWith(
      inviteCode: inviteCode.trim().toUpperCase(),
      partnerIds: ['mock_partner_id', user.id],
    );
    state = state.copyWith(wedding: wedding, isLoading: false);
  }

  void signOut() {
    ref.read(authServiceProvider).signOut();
  }

  /// Best-effort display name from an email address. "ioana.popescu@..." →
  /// "Ioana Popescu". Used only when signing in (sign-up takes a real name).
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

  static UserModel _fromFirebase(fb_auth.User user) {
    final email = user.email ?? '';
    return UserModel(
      id: user.uid,
      email: email,
      displayName: user.displayName ?? _displayNameFromEmail(email),
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

  /// Seeded wedding for the join flow. Tuned to feel real
  /// in the UI — June 2026, 150 guests, 80k RON.
  static Wedding _mockSeededWedding(String userId) {
    return Wedding(
      id: 'wed_mock_default',
      inviteCode: InviteCodeGenerator.generate(),
      partnerIds: [userId],
      weddingDateStart: DateTime(2026, 6, 12),
      weddingDateEnd: DateTime(2026, 6, 13),
      guestCount: 150,
      budgetMin: 60000,
      budgetMax: 80000,
      createdAt: DateTime.now(),
    );
  }
}

final sessionProvider =
    NotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);
