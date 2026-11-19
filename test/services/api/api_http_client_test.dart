import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/core/config/api_config.dart';
import 'package:wedding_tinder/services/api/api_http_client.dart';
import 'package:wedding_tinder/services/service_exception.dart';

import '../../helpers/fake_http_client.dart';

void main() {
  late FakeHttpClient fake;
  late ApiHttpClient client;

  setUp(() {
    fake = FakeHttpClient();
    client = ApiHttpClient(fake, () async => 'token_123');
  });

  group('requests', () {
    test('prefixes paths with the configured base URL', () async {
      fake.stub('GET', '/things/1', status: 200, body: {'id': '1'});
      await client.get('/things/1');
      expect(fake.lastRequest.url.toString(), '$kBaseUrl/things/1');
    });

    test('sends JSON content type and bearer token', () async {
      fake.stub('GET', '/things', status: 200, body: []);
      await client.getList('/things');
      expect(fake.lastRequest.headers['content-type'], startsWith('application/json'));
      expect(fake.lastRequest.headers['authorization'], 'Bearer token_123');
    });

    test('omits the Authorization header when there is no token', () async {
      final anonymous = ApiHttpClient(fake, () async => null);
      fake.stub('GET', '/things', status: 200, body: []);
      await anonymous.getList('/things');
      expect(fake.lastRequest.headers.containsKey('authorization'), isFalse);
    });

    test('fetches a fresh token for every request', () async {
      var calls = 0;
      final counting = ApiHttpClient(fake, () async => 'token_${++calls}');
      fake.stub('GET', '/a', status: 200, body: {});
      await counting.get('/a');
      await counting.get('/a');
      expect(calls, 2);
      expect(fake.lastRequest.headers['authorization'], 'Bearer token_2');
    });

    test('getList decodes a JSON array', () async {
      fake.stub('GET', '/list', status: 200, body: ['a', 'b']);
      expect(await client.getList('/list'), ['a', 'b']);
    });

    test('get decodes a JSON object', () async {
      fake.stub('GET', '/obj', status: 200, body: {'x': 1});
      expect(await client.get('/obj'), {'x': 1});
    });

    test('post sends the encoded body and decodes the response', () async {
      fake.stub('POST', '/obj', status: 201, body: {'ok': true});
      final res = await client.post('/obj', {'name': 'Ana', 'n': 3});
      expect(fake.lastRequest.method, 'POST');
      expect(fake.lastRequest.decodedBody, {'name': 'Ana', 'n': 3});
      expect(res, {'ok': true});
    });

    test('patch sends the encoded body', () async {
      fake.stub('PATCH', '/obj/1', status: 200, body: {'ok': true});
      await client.patch('/obj/1', {'customPrice': null});
      expect(fake.lastRequest.method, 'PATCH');
      expect(fake.lastRequest.body, '{"customPrice":null}');
    });

    test('postNoContent accepts an empty 204 response', () async {
      fake.stub('POST', '/dismissed', status: 204, body: '');
      await client.postNoContent('/dismissed', {'vendorId': 'v1'});
      expect(fake.lastRequest.decodedBody, {'vendorId': 'v1'});
    });

    test('delete accepts an empty 204 response', () async {
      fake.stub('DELETE', '/obj/1', status: 204, body: '');
      await client.delete('/obj/1');
      expect(fake.lastRequest.method, 'DELETE');
    });
  });

  group('error mapping', () {
    Future<void> failWith(int status, Object body) {
      fake.stub('GET', '/fail', status: status, body: body);
      return client.get('/fail');
    }

    test('401 becomes ApiException(unauthorized) regardless of body', () {
      expect(
        failWith(401, {'code': 'auth/unauthorized', 'message': 'Expired.'}),
        throwsA(isA<ApiException>()
            .having((e) => e.code, 'code', 'unauthorized')
            .having((e) => e.message, 'message', 'Authentication required.')),
      );
    });

    test('403 becomes ApiException(forbidden)', () {
      expect(
        failWith(403, {'code': 'auth/forbidden', 'message': 'Not a member.'}),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', 'forbidden')),
      );
    });

    test('wedding/* codes become WeddingException with the suffix', () {
      expect(
        failWith(404, {'code': 'wedding/not-found', 'message': 'Gone.'}),
        throwsA(isA<WeddingException>()
            .having((e) => e.code, 'code', 'not-found')
            .having((e) => e.message, 'message', 'Gone.')),
      );
    });

    test('user/* codes become UserException with the suffix', () {
      expect(
        failWith(409, {'code': 'user/already-exists', 'message': 'Exists.'}),
        throwsA(isA<UserException>()
            .having((e) => e.code, 'code', 'already-exists')),
      );
    });

    test('selection/* codes become SelectionException with the suffix', () {
      expect(
        failWith(400, {'code': 'selection/not-favorited', 'message': 'No.'}),
        throwsA(isA<SelectionException>()
            .having((e) => e.code, 'code', 'not-favorited')),
      );
    });

    test('other prefixes become ApiException keeping the full code', () {
      expect(
        failWith(400, {
          'code': 'validation/invalid-input',
          'message': 'guestCount: must be greater than or equal to 1',
        }),
        throwsA(isA<ApiException>()
            .having((e) => e.code, 'code', 'validation/invalid-input')
            .having((e) => e.message, 'message', contains('guestCount'))),
      );
    });

    test('code without a slash becomes ApiException', () {
      expect(
        failWith(500, {'code': 'boom', 'message': 'Kaboom.'}),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', 'boom')),
      );
    });

    test('missing code and message fall back to defaults', () {
      expect(
        failWith(500, {}),
        throwsA(isA<ApiException>()
            .having((e) => e.code, 'code', 'api/unknown')
            .having((e) => e.message, 'message', 'An unexpected error occurred.')),
      );
    });

    test('empty error body falls back to defaults', () {
      expect(
        failWith(502, ''),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', 'api/unknown')),
      );
    });

    test('non-JSON error body reports the HTTP status', () {
      expect(
        failWith(503, '<html>Service Unavailable</html>'),
        throwsA(isA<ApiException>()
            .having((e) => e.code, 'code', 'api/unknown')
            .having((e) => e.message, 'message', 'HTTP 503')),
      );
    });

    test('2xx responses never throw', () async {
      fake.stub('GET', '/ok', status: 299, body: {'fine': true});
      expect(await client.get('/ok'), {'fine': true});
    });
  });
}
