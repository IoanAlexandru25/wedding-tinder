import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/services/api/api_http_client.dart';
import 'package:wedding_tinder/services/api/api_user_service.dart';
import 'package:wedding_tinder/services/service_exception.dart';

import '../../helpers/fake_http_client.dart';

const _userJson = {
  'id': 'uid_1',
  'email': 'test@example.com',
  'displayName': 'Test User',
  'weddingId': null,
  'createdAt': '2026-01-10T12:00:00Z',
};

ApiUserService _makeService(FakeHttpClient fake) {
  final client = ApiHttpClient(fake, () async => 'test_token');
  return ApiUserService(client);
}

void main() {
  group('ApiUserService', () {
    late FakeHttpClient fake;
    late ApiUserService service;

    setUp(() {
      fake = FakeHttpClient();
      service = _makeService(fake);
    });

    group('createUser', () {
      setUp(() => fake.stub('POST', '/users', status: 201, body: _userJson));

      test('posts to /users', () async {
        await service.createUser(userId: 'uid_1', email: 'test@example.com');
        expect(fake.lastRequest.method, 'POST');
        expect(fake.lastRequest.url.path, '/users');
      });

      test('sends email in request body', () async {
        await service.createUser(userId: 'uid_1', email: 'test@example.com');
        expect(fake.lastRequest.decodedBody!['email'], 'test@example.com');
      });

      test('includes displayName when provided', () async {
        await service.createUser(
            userId: 'uid_1', email: 'test@example.com', displayName: 'Alice');
        expect(fake.lastRequest.decodedBody!['displayName'], 'Alice');
      });

      test('omits displayName when not provided', () async {
        await service.createUser(userId: 'uid_1', email: 'test@example.com');
        expect(
            fake.lastRequest.decodedBody!.containsKey('displayName'), isFalse);
      });

      test('does not send userId in body', () async {
        await service.createUser(userId: 'uid_1', email: 'test@example.com');
        expect(fake.lastRequest.decodedBody!.containsKey('userId'), isFalse);
      });

      test('sets Authorization header', () async {
        await service.createUser(userId: 'uid_1', email: 'test@example.com');
        expect(fake.lastRequest.headers['authorization'], 'Bearer test_token');
      });

      test('parses response into UserModel', () async {
        final user =
            await service.createUser(userId: 'uid_1', email: 'test@example.com');
        expect(user.id, 'uid_1');
        expect(user.email, 'test@example.com');
        expect(user.displayName, 'Test User');
        expect(user.weddingId, isNull);
      });

      test('throws UserException(already-exists) on 409', () async {
        fake.stub('POST', '/users',
            status: 409,
            body: {
              'code': 'user/already-exists',
              'message': 'User already exists.'
            });
        expect(
          () => service.createUser(userId: 'uid_1', email: 'test@example.com'),
          throwsA(isA<UserException>()
              .having((e) => e.code, 'code', 'already-exists')),
        );
      });
    });

    group('getUser', () {
      setUp(() =>
          fake.stub('GET', '/users/uid_1', status: 200, body: _userJson));

      test('gets /users/{id}', () async {
        await service.getUser('uid_1');
        expect(fake.lastRequest.method, 'GET');
        expect(fake.lastRequest.url.path, '/users/uid_1');
      });

      test('parses response into UserModel', () async {
        final user = await service.getUser('uid_1');
        expect(user.id, 'uid_1');
        expect(user.createdAt, DateTime.parse('2026-01-10T12:00:00Z'));
      });

      test('throws UserException(not-found) on 404', () async {
        fake.stub('GET', '/users/unknown',
            status: 404,
            body: {'code': 'user/not-found', 'message': 'Not found.'});
        expect(
          () => service.getUser('unknown'),
          throwsA(
              isA<UserException>().having((e) => e.code, 'code', 'not-found')),
        );
      });

      test('throws ApiException(forbidden) on 403', () async {
        fake.stub('GET', '/users/uid_1',
            status: 403,
            body: {'code': 'auth/forbidden', 'message': 'Forbidden.'});
        expect(
          () => service.getUser('uid_1'),
          throwsA(
              isA<ApiException>().having((e) => e.code, 'code', 'forbidden')),
        );
      });
    });

    group('updateUser', () {
      setUp(() =>
          fake.stub('PATCH', '/users/uid_1', status: 200, body: _userJson));

      test('patches /users/{id}', () async {
        await service.updateUser('uid_1', weddingId: 'wed_1');
        expect(fake.lastRequest.method, 'PATCH');
        expect(fake.lastRequest.url.path, '/users/uid_1');
      });

      test('sends only provided fields', () async {
        await service.updateUser('uid_1', weddingId: 'wed_1');
        final body = fake.lastRequest.decodedBody!;
        expect(body['weddingId'], 'wed_1');
        expect(body.containsKey('displayName'), isFalse);
      });

      test('parses updated UserModel from response', () async {
        final user = await service.updateUser('uid_1', weddingId: 'wed_1');
        expect(user.id, 'uid_1');
      });
    });
  });
}
