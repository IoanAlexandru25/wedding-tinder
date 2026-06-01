import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/services/api/api_dismissed_service.dart';
import 'package:wedding_tinder/services/api/api_http_client.dart';
import 'package:wedding_tinder/services/service_exception.dart';

import '../../helpers/fake_http_client.dart';

ApiDismissedService _makeService(FakeHttpClient fake) {
  final client = ApiHttpClient(fake, () async => 'test_token');
  return ApiDismissedService(client);
}

void main() {
  group('ApiDismissedService', () {
    late FakeHttpClient fake;
    late ApiDismissedService service;

    setUp(() {
      fake = FakeHttpClient();
      service = _makeService(fake);
    });

    group('listDismissed', () {
      test('gets /weddings/{id}/dismissed', () async {
        fake.stub('GET', '/weddings/wed_1/dismissed',
            status: 200, body: ['v_01', 'v_02']);
        await service.listDismissed('wed_1');
        expect(fake.lastRequest.method, 'GET');
        expect(fake.lastRequest.url.path, '/weddings/wed_1/dismissed');
      });

      test('sets Authorization header', () async {
        fake.stub('GET', '/weddings/wed_1/dismissed',
            status: 200, body: <String>[]);
        await service.listDismissed('wed_1');
        expect(
            fake.lastRequest.headers['authorization'], 'Bearer test_token');
      });

      test('parses list of vendor id strings', () async {
        fake.stub('GET', '/weddings/wed_1/dismissed',
            status: 200, body: ['v_01', 'v_02', 'v_03']);
        final ids = await service.listDismissed('wed_1');
        expect(ids, ['v_01', 'v_02', 'v_03']);
      });

      test('returns empty list for empty response', () async {
        fake.stub('GET', '/weddings/wed_1/dismissed',
            status: 200, body: <String>[]);
        expect(await service.listDismissed('wed_1'), isEmpty);
      });

      test('throws ApiException(forbidden) on 403', () async {
        fake.stub('GET', '/weddings/wed_1/dismissed',
            status: 403,
            body: {'code': 'auth/forbidden', 'message': 'Forbidden.'});
        expect(
          () => service.listDismissed('wed_1'),
          throwsA(isA<ApiException>()
              .having((e) => e.code, 'code', 'forbidden')),
        );
      });

      test('throws ApiException(unauthorized) on 401', () async {
        fake.stub('GET', '/weddings/wed_1/dismissed',
            status: 401,
            body: {'code': 'auth/unauthorized', 'message': 'Unauthorized.'});
        expect(
          () => service.listDismissed('wed_1'),
          throwsA(isA<ApiException>()
              .having((e) => e.code, 'code', 'unauthorized')),
        );
      });
    });

    group('dismiss', () {
      setUp(() => fake.stub('POST', '/weddings/wed_1/dismissed',
          status: 204, body: ''));

      test('posts to /weddings/{id}/dismissed', () async {
        await service.dismiss('wed_1', 'v_01');
        expect(fake.lastRequest.method, 'POST');
        expect(fake.lastRequest.url.path, '/weddings/wed_1/dismissed');
      });

      test('sends vendorId in body', () async {
        await service.dismiss('wed_1', 'v_01');
        expect(fake.lastRequest.decodedBody!['vendorId'], 'v_01');
      });

      test('sets Authorization header', () async {
        await service.dismiss('wed_1', 'v_01');
        expect(
            fake.lastRequest.headers['authorization'], 'Bearer test_token');
      });

      test('succeeds on 204 no-content', () async {
        await expectLater(service.dismiss('wed_1', 'v_01'), completes);
      });
    });
  });
}
