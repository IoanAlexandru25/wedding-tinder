import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/invite_code_generator.dart';
import '../models/user_model.dart';
import '../models/wedding.dart';

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
  SessionState build() => const SessionState();

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final user = UserModel(
      id: 'mock_${email.hashCode.toUnsigned(32)}',
      email: email,
      displayName: _displayNameFromEmail(email),
      createdAt: DateTime.now(),
    );
    // Mock convention: accounts that "sign in" come pre-seeded with a wedding
    // so we can test the full app quickly. Use sign-up to experience the
    // onboarding path.
    final wedding = _mockSeededWedding(user.id);
    state = state.copyWith(user: user, wedding: wedding);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final user = UserModel(
      id: 'mock_${email.hashCode.toUnsigned(32)}',
      email: email,
      displayName: displayName.trim(),
      createdAt: DateTime.now(),
    );
    // No wedding yet — UI redirects to wedding setup.
    state = state.copyWith(user: user);
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
      state = state.copyWith(error: 'Codul nu are formatul corect.');
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
    state = const SessionState();
  }

  /// Best-effort display name from an email address. "ioana.popescu@..." →
  /// "Ioana Popescu". Used only when signing in (sign-up takes a real name).
  static String _displayNameFromEmail(String email) {
    final local = email.split('@').first;
    if (local.isEmpty) return 'Tu';
    final words = local.split(RegExp(r'[._\-+]'));
    final cleaned = words
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .toList();
    return cleaned.isEmpty ? 'Tu' : cleaned.join(' ');
  }

  /// Seeded wedding for sign-in shortcut and join flow. Tuned to feel real
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
