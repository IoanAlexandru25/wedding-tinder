import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/services/api/api_http_client.dart';
import 'package:wedding_tinder/services/api/api_wedding_service.dart';
import 'package:wedding_tinder/services/service_exception.dart';

import '../../helpers/fake_http_client.dart';

const _weddingJson = {
  'id': 'wed_1',
  'inviteCode': 'WED-ABCD',
  'partnerIds': ['uid_1'],
  'weddingDateStart': '2026-06-15',
  'weddingDateEnd': '2026-06-15',
  'guestCount': 150,
  'budgetMin': 60000,
  'budgetMax': 80000,
  'createdAt': '2026-01-10T12:00:00Z',
};

ApiWeddingService _makeService(FakeHttpClient fake) {
  final client = ApiHttpClient(fake, () async => 'test_token');
  return ApiWeddingService(client);
}

void main() {
  group('ApiWeddingService', () {
    late FakeHttpClient fake;
    late ApiWeddingService service;

    setUp(() {
      fake = FakeHttpClient();
      service = _makeService(fake);
    });

    group('createWedding', () {
      setUp(() => fake.stub('POST', '/weddings', status: 201, body: _weddingJson));

      test('posts to /weddings', () async {
        await service.createWedding(
          userId: 'uid_1',
          start: DateTime(2026, 6, 15),
          end: DateTime(2026, 6, 15),
          guestCount: 150,
          budgetMin: 60000,
          budgetMax: 80000,
        );
        expect(fake.lastRequest.method, 'POST');
        expect(fake.lastRequest.url.path, '/weddings');
      });

      test('sends correct request body', () async {
        await service.createWedding(
          userId: 'uid_1',
          start: DateTime(2026, 6, 15),
          end: DateTime(2026, 6, 15),
          guestCount: 150,
          budgetMin: 60000,
          budgetMax: 80000,
        );
        final body = fake.lastRequest.decodedBody!;
        expect(body['weddingDateStart'], '2026-06-15');
        expect(body['weddingDateEnd'], '2026-06-15');
        expect(body['guestCount'], 150);
        expect(body['budgetMin'], 60000);
        expect(body['budgetMax'], 80000);
        expect(body.containsKey('userId'), isFalse);
      });

      test('sets Authorization header', () async {
        await service.createWedding(
          userId: 'uid_1',
          start: DateTime(2026, 6, 15),
          end: DateTime(2026, 6, 15),
          guestCount: 150,
          budgetMin: 60000,
          budgetMax: 80000,
        );
        expect(fake.lastRequest.headers['authorization'], 'Bearer test_token');
      });

      test('parses response into Wedding', () async {
        final wedding = await service.createWedding(
          userId: 'uid_1',
          start: DateTime(2026, 6, 15),
          end: DateTime(2026, 6, 15),
          guestCount: 150,
          budgetMin: 60000,
          budgetMax: 80000,
        );
        expect(wedding.id, 'wed_1');
        expect(wedding.inviteCode, 'WED-ABCD');
        expect(wedding.partnerIds, ['uid_1']);
        expect(wedding.guestCount, 150);
        expect(wedding.weddingDateStart, DateTime(2026, 6, 15));
      });

      test('throws WeddingException(already-member) on 409', () async {
        fake.stub('POST', '/weddings',
            status: 409,
            body: {'code': 'wedding/already-member', 'message': 'Already a member.'});
        expect(
          () => service.createWedding(
            userId: 'uid_1',
            start: DateTime(2026, 6, 15),
            end: DateTime(2026, 6, 15),
            guestCount: 100,
            budgetMin: 40000,
            budgetMax: 60000,
          ),
          throwsA(isA<WeddingException>()
              .having((e) => e.code, 'code', 'already-member')),
        );
      });
    });

    group('joinWedding', () {
      setUp(() => fake.stub('POST', '/weddings/join', status: 200, body: _weddingJson));

      test('posts to /weddings/join with inviteCode', () async {
        await service.joinWedding('WED-ABCD', userId: 'uid_2');
        expect(fake.lastRequest.method, 'POST');
        expect(fake.lastRequest.url.path, '/weddings/join');
        expect(fake.lastRequest.decodedBody!['inviteCode'], 'WED-ABCD');
      });

      test('parses response into Wedding', () async {
        final wedding = await service.joinWedding('WED-ABCD', userId: 'uid_2');
        expect(wedding.id, 'wed_1');
        expect(wedding.inviteCode, 'WED-ABCD');
      });

      test('throws WeddingException(not-found) on 404', () async {
        fake.stub('POST', '/weddings/join',
            status: 404,
            body: {'code': 'wedding/not-found', 'message': 'Not found.'});
        expect(
          () => service.joinWedding('WED-XXXX', userId: 'uid_2'),
          throwsA(isA<WeddingException>()
              .having((e) => e.code, 'code', 'not-found')),
        );
      });

      test('throws WeddingException(full) on 400 wedding/full', () async {
        fake.stub('POST', '/weddings/join',
            status: 400,
            body: {'code': 'wedding/full', 'message': 'Full.'});
        expect(
          () => service.joinWedding('WED-ABCD', userId: 'uid_3'),
          throwsA(isA<WeddingException>().having((e) => e.code, 'code', 'full')),
        );
      });
    });

    group('getWedding', () {
      setUp(() =>
          fake.stub('GET', '/weddings/wed_1', status: 200, body: _weddingJson));

      test('gets /weddings/{id}', () async {
        await service.getWedding('wed_1');
        expect(fake.lastRequest.method, 'GET');
        expect(fake.lastRequest.url.path, '/weddings/wed_1');
      });

      test('parses response into Wedding', () async {
        final w = await service.getWedding('wed_1');
        expect(w.id, 'wed_1');
        expect(w.budgetMax, 80000);
      });

      test('throws WeddingException(not-found) on 404', () async {
        fake.stub('GET', '/weddings/unknown',
            status: 404,
            body: {'code': 'wedding/not-found', 'message': 'Not found.'});
        expect(
          () => service.getWedding('unknown'),
          throwsA(isA<WeddingException>()
              .having((e) => e.code, 'code', 'not-found')),
        );
      });
    });

    group('updateWedding', () {
      setUp(() =>
          fake.stub('PATCH', '/weddings/wed_1', status: 200, body: _weddingJson));

      test('patches /weddings/{id}', () async {
        await service.updateWedding('wed_1', guestCount: 200);
        expect(fake.lastRequest.method, 'PATCH');
        expect(fake.lastRequest.url.path, '/weddings/wed_1');
      });

      test('only sends provided fields', () async {
        await service.updateWedding('wed_1', guestCount: 200);
        final body = fake.lastRequest.decodedBody!;
        expect(body.containsKey('guestCount'), isTrue);
        expect(body.containsKey('budgetMin'), isFalse);
        expect(body.containsKey('weddingDateStart'), isFalse);
      });

      test('sends date fields as ISO-8601 date strings', () async {
        await service.updateWedding('wed_1', start: DateTime(2026, 9, 1));
        expect(fake.lastRequest.decodedBody!['weddingDateStart'], '2026-09-01');
      });

      test('throws ApiException(unauthorized) on 401', () async {
        fake.stub('PATCH', '/weddings/wed_1',
            status: 401,
            body: {'code': 'auth/unauthorized', 'message': 'Token expired.'});
        expect(
          () => service.updateWedding('wed_1', guestCount: 100),
          throwsA(isA<ApiException>()
              .having((e) => e.code, 'code', 'unauthorized')),
        );
      });
    });
  });
}
