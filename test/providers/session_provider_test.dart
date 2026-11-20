import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/models/wedding.dart';
import 'package:wedding_tinder/providers/service_providers.dart';
import 'package:wedding_tinder/providers/session_provider.dart';
import 'package:wedding_tinder/services/mock/mock_user_service.dart';
import 'package:wedding_tinder/services/mock/mock_wedding_service.dart';

import 'package:wedding_tinder/models/user_model.dart';
import 'package:wedding_tinder/services/user_service.dart';

import '../helpers/fake_auth.dart';

class _OfflineUserService implements UserService {
  Never _offline() => throw Exception('SocketException: Connection timed out');

  @override
  Future<UserModel> createUser({
    required String userId,
    required String email,
    String? displayName,
  }) async =>
      _offline();

  @override
  Future<UserModel> getUser(String userId) async => _offline();

  @override
  Future<UserModel> updateUser(
    String userId, {
    String? displayName,
    String? weddingId,
  }) async =>
      _offline();
}

void main() {
  late FakeAuthService auth;
  late MockUserService userService;
  late MockWeddingService weddingService;
  late ProviderContainer container;

  SessionState session() => container.read(sessionProvider);
  SessionNotifier notifier() => container.read(sessionProvider.notifier);

  setUp(() {
    auth = FakeAuthService();
    userService = MockUserService();
    weddingService = MockWeddingService();
    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(auth),
        userServiceProvider.overrideWithValue(userService),
        weddingServiceProvider.overrideWithValue(weddingService),
      ],
    );
    // Build the notifier so it subscribes to the auth stream.
    container.listen(sessionProvider, (_, _) {});
  });

  tearDown(() async {
    container.dispose();
    await auth.dispose();
  });

  Future<Wedding> seedWeddingFor(String uid) async {
    final wedding = await weddingService.createWedding(
      userId: uid,
      start: DateTime(2026, 6, 12),
      end: DateTime(2026, 6, 13),
      guestCount: 150,
      budgetMin: 60000,
      budgetMax: 80000,
    );
    await userService.updateUser(uid, weddingId: wedding.id);
    return wedding;
  }

  group('SessionState', () {
    test('defaults to signed out, no wedding, not loading', () {
      const s = SessionState();
      expect(s.isSignedIn, isFalse);
      expect(s.hasWedding, isFalse);
      expect(s.isReady, isFalse);
      expect(s.isLoading, isFalse);
      expect(s.error, isNull);
    });

    test('copyWith clear flags reset user, wedding and error', () {
      final s = const SessionState(error: 'boom').copyWith(
        clearError: true,
        clearUser: true,
        clearWedding: true,
      );
      expect(s.error, isNull);
      expect(s.user, isNull);
      expect(s.wedding, isNull);
    });
  });

  group('auth state changes', () {
    test('initial state is signed out', () {
      expect(session().isSignedIn, isFalse);
      expect(session().isLoading, isFalse);
    });

    test('signed-in user without wedding ends up signed in, no wedding', () async {
      await userService.createUser(
        userId: 'uid_1',
        email: 'ana@example.com',
        displayName: 'Ana Pop',
      );

      auth.emit(FakeFirebaseUser(uid: 'uid_1', email: 'ana@example.com'));
      await settle();

      expect(session().isSignedIn, isTrue);
      expect(session().hasWedding, isFalse);
      expect(session().isLoading, isFalse);
      expect(session().user!.displayName, 'Ana Pop');
    });

    test('signed-in user with weddingId loads the wedding', () async {
      await userService.createUser(userId: 'uid_1', email: 'ana@example.com');
      final wedding = await seedWeddingFor('uid_1');

      auth.emit(FakeFirebaseUser(uid: 'uid_1', email: 'ana@example.com'));
      await settle();

      expect(session().isReady, isTrue);
      expect(session().wedding!.id, wedding.id);
      expect(session().isLoading, isFalse);
    });

    test('missing user document is created on first sign-in', () async {
      auth.emit(FakeFirebaseUser(
        uid: 'uid_new',
        email: 'new@example.com',
        displayName: 'New Person',
      ));
      await settle();

      final created = await userService.getUser('uid_new');
      expect(created.email, 'new@example.com');
      expect(created.displayName, 'New Person');
      expect(session().isSignedIn, isTrue);
      expect(session().isLoading, isFalse);
    });

    test('display name falls back to a name derived from the email', () async {
      auth.emit(FakeFirebaseUser(uid: 'uid_2', email: 'maria.ionescu@x.ro'));
      await settle();

      expect(session().user!.displayName, 'Maria Ionescu');
    });

    test('wedding that cannot be loaded leaves the user without wedding', () async {
      await userService.createUser(userId: 'uid_1', email: 'ana@example.com');
      await userService.updateUser('uid_1', weddingId: 'missing_wedding');

      auth.emit(FakeFirebaseUser(uid: 'uid_1', email: 'ana@example.com'));
      await settle();

      expect(session().isSignedIn, isTrue);
      expect(session().hasWedding, isFalse);
      expect(session().isLoading, isFalse);
    });

    test('sign-out event resets the session', () async {
      await userService.createUser(userId: 'uid_1', email: 'ana@example.com');
      await seedWeddingFor('uid_1');
      auth.emit(FakeFirebaseUser(uid: 'uid_1', email: 'ana@example.com'));
      await settle();
      expect(session().isReady, isTrue);

      auth.emit(null);
      await settle();

      expect(session().isSignedIn, isFalse);
      expect(session().hasWedding, isFalse);
    });

    test('switching to another user drops the previous wedding', () async {
      await userService.createUser(userId: 'uid_1', email: 'ana@example.com');
      await seedWeddingFor('uid_1');
      await userService.createUser(userId: 'uid_2', email: 'bob@example.com');
      auth.emit(FakeFirebaseUser(uid: 'uid_1', email: 'ana@example.com'));
      await settle();
      expect(session().hasWedding, isTrue);

      auth.emit(FakeFirebaseUser(uid: 'uid_2', email: 'bob@example.com'));
      await settle();

      expect(session().user!.id, 'uid_2');
      expect(session().hasWedding, isFalse);
    });
  });

  group('signIn', () {
    test('success signs the user in', () async {
      await userService.createUser(userId: 'uid_1', email: 'ana@example.com');

      await notifier().signIn(email: 'ana@example.com', password: 'secret');
      await settle();

      expect(session().isSignedIn, isTrue);
      expect(session().error, isNull);
    });

    const errorCases = {
      'invalid-email': 'Invalid email address.',
      'user-disabled': 'This account has been disabled.',
      'user-not-found': 'Incorrect email or password.',
      'wrong-password': 'Incorrect email or password.',
      'invalid-credential': 'Incorrect email or password.',
    };

    for (final entry in errorCases.entries) {
      test('maps FirebaseAuthException(${entry.key}) to a friendly error', () async {
        auth.nextError = fb_auth.FirebaseAuthException(code: entry.key);

        await notifier().signIn(email: 'ana@example.com', password: 'bad');

        expect(session().error, entry.value);
        expect(session().isLoading, isFalse);
        expect(session().isSignedIn, isFalse);
      });
    }

    test('unknown error code falls back to the Firebase message', () async {
      auth.nextError = fb_auth.FirebaseAuthException(
        code: 'too-many-requests',
        message: 'Slow down.',
      );

      await notifier().signIn(email: 'ana@example.com', password: 'x');

      expect(session().error, 'Slow down.');
    });

    test('unknown error code without message uses a generic message', () async {
      auth.nextError = fb_auth.FirebaseAuthException(code: 'something-odd');

      await notifier().signIn(email: 'ana@example.com', password: 'x');

      expect(session().error, 'Authentication failed.');
    });

    test('a new attempt clears the previous error', () async {
      auth.nextError = fb_auth.FirebaseAuthException(code: 'wrong-password');
      await notifier().signIn(email: 'ana@example.com', password: 'bad');
      expect(session().error, isNotNull);

      auth.nextError = null;
      await userService.createUser(userId: 'uid_1', email: 'ana@example.com');
      await notifier().signIn(email: 'ana@example.com', password: 'good');
      await settle();

      expect(session().error, isNull);
    });
  });

  group('signUp', () {
    test('creates the user document with the display name', () async {
      auth.userToReturn = FakeFirebaseUser(
        uid: 'uid_9',
        email: 'maria@example.com',
        displayName: 'Maria',
      );

      await notifier().signUp(
        email: 'maria@example.com',
        password: 'secret123',
        displayName: 'Maria',
      );
      await settle();

      final doc = await userService.getUser('uid_9');
      expect(doc.email, 'maria@example.com');
      expect(doc.displayName, 'Maria');
      expect(session().isSignedIn, isTrue);
    });

    test('email-already-in-use is reported', () async {
      auth.nextError =
          fb_auth.FirebaseAuthException(code: 'email-already-in-use');

      await notifier().signUp(
        email: 'ana@example.com',
        password: 'secret123',
        displayName: 'Ana',
      );

      expect(session().error, 'An account already exists for that email.');
      expect(session().isLoading, isFalse);
    });

    test('weak-password is reported', () async {
      auth.nextError = fb_auth.FirebaseAuthException(code: 'weak-password');

      await notifier().signUp(
        email: 'ana@example.com',
        password: '1',
        displayName: 'Ana',
      );

      expect(session().error, 'Password is too weak.');
    });

    test('profile keeps the typed name although Firebase reports the user first',
        () async {
      auth.userToReturn = FakeFirebaseUser(
        uid: 'uid_9',
        email: 'elena.popescu@example.com',
        displayName: 'Elena',
      );

      await notifier().signUp(
        email: 'elena.popescu@example.com',
        password: 'secret123',
        displayName: 'Elena',
      );
      await settle();

      final doc = await userService.getUser('uid_9');
      expect(doc.displayName, 'Elena');
      expect(session().user!.displayName, 'Elena');
      expect(session().isLoading, isFalse);
    });

    test('shows the typed name while sign-up is still running', () async {
      auth.userToReturn = FakeFirebaseUser(
        uid: 'uid_9',
        email: 'elena.popescu@example.com',
        displayName: 'Elena',
      );

      final pending = notifier().signUp(
        email: 'elena.popescu@example.com',
        password: 'secret123',
        displayName: '  Elena  ',
      );
      await Future<void>.delayed(Duration.zero);

      expect(session().user!.displayName, 'Elena');
      await pending;
    });

    test('completes an existing profile that has no name', () async {
      await userService.createUser(userId: 'uid_1', email: 'ana@example.com');

      await notifier().signUp(
        email: 'ana@example.com',
        password: 'secret123',
        displayName: 'Ana',
      );
      await settle();

      expect((await userService.getUser('uid_1')).displayName, 'Ana');
      expect(session().user!.displayName, 'Ana');
      expect(session().error, isNull);
    });

    test('keeps an existing profile that already has the same name', () async {
      await userService.createUser(
        userId: 'uid_1',
        email: 'ana@example.com',
        displayName: 'Ana',
      );

      await notifier().signUp(
        email: 'ana@example.com',
        password: 'secret123',
        displayName: 'Ana',
      );
      await settle();

      expect((await userService.getUser('uid_1')).displayName, 'Ana');
      expect(session().error, isNull);
    });

    test('loads the wedding when the existing profile already has one', () async {
      await userService.createUser(userId: 'uid_1', email: 'ana@example.com');
      final wedding = await seedWeddingFor('uid_1');

      await notifier().signUp(
        email: 'ana@example.com',
        password: 'secret123',
        displayName: 'Ana',
      );
      await settle();

      expect(session().wedding?.id, wedding.id);
    });

    test('a connection failure stops loading and reports an error', () async {
      final offline = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(auth),
          userServiceProvider.overrideWithValue(_OfflineUserService()),
          weddingServiceProvider.overrideWithValue(weddingService),
        ],
      );
      addTearDown(offline.dispose);
      offline.listen(sessionProvider, (_, _) {});

      await offline.read(sessionProvider.notifier).signUp(
            email: 'ana@example.com',
            password: 'secret123',
            displayName: 'Ana',
          );

      final s = offline.read(sessionProvider);
      expect(s.isLoading, isFalse);
      expect(s.error, contains('Could not reach the server'));
      expect(s.isSignedIn, isTrue);
    });

    test('existing user document is not treated as an error', () async {
      await userService.createUser(userId: 'uid_1', email: 'ana@example.com');

      await notifier().signUp(
        email: 'ana@example.com',
        password: 'secret123',
        displayName: 'Ana',
      );
      await settle();

      expect(session().error, isNull);
    });
  });

  group('profile name backfill on sign-in', () {
    test('fills a missing profile name from the Firebase account', () async {
      await userService.createUser(userId: 'uid_1', email: 'ana@example.com');

      auth.emit(FakeFirebaseUser(
        uid: 'uid_1',
        email: 'ana@example.com',
        displayName: 'Ana Pop',
      ));
      await settle();

      expect((await userService.getUser('uid_1')).displayName, 'Ana Pop');
      expect(session().user!.displayName, 'Ana Pop');
    });

    test('never overwrites a name the profile already has', () async {
      await userService.createUser(
        userId: 'uid_1',
        email: 'ana@example.com',
        displayName: 'Ana',
      );

      auth.emit(FakeFirebaseUser(
        uid: 'uid_1',
        email: 'ana@example.com',
        displayName: 'Someone Else',
      ));
      await settle();

      expect((await userService.getUser('uid_1')).displayName, 'Ana');
      expect(session().user!.displayName, 'Ana');
    });

    test('leaves the profile alone when Firebase has no name either', () async {
      await userService.createUser(userId: 'uid_1', email: 'ana@example.com');

      auth.emit(FakeFirebaseUser(uid: 'uid_1', email: 'ana@example.com'));
      await settle();

      expect((await userService.getUser('uid_1')).displayName, isNull);
    });
  });

  group('wedding actions', () {
    Future<void> signInAs(String uid, String email) async {
      await userService.createUser(userId: uid, email: email);
      auth.emit(FakeFirebaseUser(uid: uid, email: email));
      await settle();
    }

    test('createWedding stores the new wedding in the session', () async {
      await signInAs('uid_1', 'ana@example.com');

      await notifier().createWedding(
        weddingDateStart: DateTime(2026, 9, 5),
        weddingDateEnd: DateTime(2026, 9, 6),
        guestCount: 120,
        budgetMin: 50000,
        budgetMax: 70000,
      );

      final wedding = session().wedding!;
      expect(wedding.partnerIds, ['uid_1']);
      expect(wedding.guestCount, 120);
      expect(wedding.budgetMax, 70000);
      expect(wedding.inviteCode, matches(RegExp(r'^WED-[A-Z0-9]{4}$')));
      expect(session().isLoading, isFalse);
    });

    test('createWedding without a signed-in user does nothing', () async {
      await notifier().createWedding(
        weddingDateStart: DateTime(2026, 9, 5),
        weddingDateEnd: DateTime(2026, 9, 6),
        guestCount: 120,
        budgetMin: 50000,
        budgetMax: 70000,
      );

      expect(session().hasWedding, isFalse);
      expect(session().isLoading, isFalse);
    });

    test('joinWedding normalises the invite code', () async {
      final wedding = await weddingService.createWedding(
        userId: 'partner',
        start: DateTime(2026, 6, 12),
        end: DateTime(2026, 6, 13),
        guestCount: 100,
        budgetMin: 1,
        budgetMax: 2,
      );
      await signInAs('uid_1', 'ana@example.com');

      await notifier().joinWedding('  ${wedding.inviteCode.toLowerCase()} ');

      expect(session().wedding!.id, wedding.id);
      expect(session().wedding!.partnerIds, ['partner', 'uid_1']);
      expect(session().error, isNull);
    });

    test('joinWedding with an unknown code sets an error', () async {
      await signInAs('uid_1', 'ana@example.com');

      await notifier().joinWedding('WED-ZZZZ');

      expect(session().hasWedding, isFalse);
      expect(session().error, 'No wedding found for that invite code.');
      expect(session().isLoading, isFalse);
    });

    test('joinWedding with a malformed code sets an error', () async {
      await signInAs('uid_1', 'ana@example.com');

      await notifier().joinWedding('hello');

      expect(session().error, 'Invite code format is invalid.');
    });

    test('joinWedding on a full wedding sets an error', () async {
      final wedding = await weddingService.createWedding(
        userId: 'p1',
        start: DateTime(2026, 6, 12),
        end: DateTime(2026, 6, 13),
        guestCount: 100,
        budgetMin: 1,
        budgetMax: 2,
      );
      await weddingService.joinWedding(wedding.inviteCode, userId: 'p2');
      await signInAs('uid_1', 'ana@example.com');

      await notifier().joinWedding(wedding.inviteCode);

      expect(session().error, 'This wedding already has two partners.');
    });

    test('updateWedding replaces the wedding in the session', () async {
      await userService.createUser(userId: 'uid_1', email: 'ana@example.com');
      await seedWeddingFor('uid_1');
      auth.emit(FakeFirebaseUser(uid: 'uid_1', email: 'ana@example.com'));
      await settle();

      await notifier().updateWedding(
        weddingDateStart: DateTime(2027, 1, 1),
        weddingDateEnd: DateTime(2027, 1, 2),
        guestCount: 200,
        budgetMin: 90000,
        budgetMax: 120000,
      );

      final wedding = session().wedding!;
      expect(wedding.guestCount, 200);
      expect(wedding.budgetMin, 90000);
      expect(wedding.weddingDateStart, DateTime(2027, 1, 1));
      expect(session().isLoading, isFalse);
    });

    test('updateWedding without a wedding does nothing', () async {
      await signInAs('uid_1', 'ana@example.com');

      await notifier().updateWedding(
        weddingDateStart: DateTime(2027, 1, 1),
        weddingDateEnd: DateTime(2027, 1, 2),
        guestCount: 200,
        budgetMin: 1,
        budgetMax: 2,
      );

      expect(session().hasWedding, isFalse);
      expect(session().isLoading, isFalse);
    });
  });

  group('signOut', () {
    test('delegates to the auth service and clears the session', () async {
      await userService.createUser(userId: 'uid_1', email: 'ana@example.com');
      auth.emit(FakeFirebaseUser(uid: 'uid_1', email: 'ana@example.com'));
      await settle();

      notifier().signOut();
      await settle();

      expect(auth.signOutCalls, 1);
      expect(session().isSignedIn, isFalse);
    });
  });

  group('derived providers', () {
    test('currentUserIdProvider and currentWeddingIdProvider follow the session',
        () async {
      expect(container.read(currentUserIdProvider), isNull);
      expect(container.read(currentWeddingIdProvider), isNull);

      await userService.createUser(userId: 'uid_1', email: 'ana@example.com');
      final wedding = await seedWeddingFor('uid_1');
      auth.emit(FakeFirebaseUser(uid: 'uid_1', email: 'ana@example.com'));
      await settle();

      expect(container.read(currentUserIdProvider), 'uid_1');
      expect(container.read(currentWeddingIdProvider), wedding.id);
    });
  });
}
