import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/services/mock/mock_user_service.dart';
import 'package:wedding_tinder/services/service_exception.dart';

void main() {
  group('MockUserService', () {
    late MockUserService service;

    setUp(() => service = MockUserService());

    group('createUser', () {
      test('returns user with correct fields', () async {
        final user = await service.createUser(
          userId: 'uid_1',
          email: 'test@example.com',
          displayName: 'Test User',
        );
        expect(user.id, 'uid_1');
        expect(user.email, 'test@example.com');
        expect(user.displayName, 'Test User');
        expect(user.weddingId, isNull);
      });

      test('works without a display name', () async {
        final user = await service.createUser(
          userId: 'uid_1',
          email: 'test@example.com',
        );
        expect(user.displayName, isNull);
      });

      test('throws already-exists when creating same userId twice', () async {
        await service.createUser(userId: 'uid_1', email: 'test@example.com');
        expect(
          () => service.createUser(userId: 'uid_1', email: 'other@example.com'),
          throwsA(isA<UserException>().having((e) => e.code, 'code', 'already-exists')),
        );
      });

      test('allows different userIds', () async {
        await service.createUser(userId: 'uid_1', email: 'a@example.com');
        await service.createUser(userId: 'uid_2', email: 'b@example.com');
        final u1 = await service.getUser('uid_1');
        final u2 = await service.getUser('uid_2');
        expect(u1.email, 'a@example.com');
        expect(u2.email, 'b@example.com');
      });
    });

    group('getUser', () {
      test('returns previously created user', () async {
        await service.createUser(userId: 'uid_1', email: 'test@example.com');
        final user = await service.getUser('uid_1');
        expect(user.id, 'uid_1');
      });

      test('throws not-found for unknown userId', () async {
        expect(
          () => service.getUser('unknown'),
          throwsA(isA<UserException>().having((e) => e.code, 'code', 'not-found')),
        );
      });
    });

    group('updateUser', () {
      setUp(() async {
        await service.createUser(userId: 'uid_1', email: 'test@example.com');
      });

      test('updates weddingId', () async {
        final updated = await service.updateUser('uid_1', weddingId: 'wed_abc');
        expect(updated.weddingId, 'wed_abc');
      });

      test('updates displayName', () async {
        final updated = await service.updateUser('uid_1', displayName: 'New Name');
        expect(updated.displayName, 'New Name');
      });

      test('partial update preserves other fields', () async {
        await service.updateUser('uid_1', weddingId: 'wed_abc');
        final updated = await service.updateUser('uid_1', displayName: 'Name');
        expect(updated.weddingId, 'wed_abc');
      });

      test('throws not-found for unknown userId', () async {
        expect(
          () => service.updateUser('unknown', weddingId: 'wed_abc'),
          throwsA(isA<UserException>().having((e) => e.code, 'code', 'not-found')),
        );
      });
    });
  });
}
