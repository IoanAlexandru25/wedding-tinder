import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/core/constants/categories.dart';
import 'package:wedding_tinder/services/api/api_favorites_service.dart';
import 'package:wedding_tinder/services/api/api_http_client.dart';
import 'package:wedding_tinder/services/service_exception.dart';

import '../../helpers/fake_http_client.dart';

const _favoriteJson = {
  'vendorId': 'foto_01',
  'category': 'fotograf',
  'addedBy': 'uid_1',
  'addedAt': '2026-01-10T14:00:00Z',
};

ApiFavoritesService _makeService(FakeHttpClient fake) {
  final client = ApiHttpClient(fake, () async => 'test_token');
  return ApiFavoritesService(client);
}

void main() {
  group('ApiFavoritesService', () {
    late FakeHttpClient fake;
    late ApiFavoritesService service;

    setUp(() {
      fake = FakeHttpClient();
      service = _makeService(fake);
    });

    group('listFavorites', () {
      test('gets /weddings/{id}/favorites', () async {
        fake.stub('GET', '/weddings/wed_1/favorites',
            status: 200, body: [_favoriteJson]);
        await service.listFavorites('wed_1');
        expect(fake.lastRequest.method, 'GET');
        expect(fake.lastRequest.url.path, '/weddings/wed_1/favorites');
      });

      test('parses list of Favorite objects', () async {
        fake.stub('GET', '/weddings/wed_1/favorites',
            status: 200, body: [_favoriteJson, _favoriteJson]);
        final list = await service.listFavorites('wed_1');
        expect(list.length, 2);
        expect(list.first.vendorId, 'foto_01');
        expect(list.first.category, VendorCategory.fotograf);
        expect(list.first.addedBy, 'uid_1');
      });

      test('returns empty list for empty response', () async {
        fake.stub('GET', '/weddings/wed_1/favorites',
            status: 200, body: <dynamic>[]);
        expect(await service.listFavorites('wed_1'), isEmpty);
      });

      test('throws ApiException(forbidden) on 403', () async {
        fake.stub('GET', '/weddings/wed_1/favorites',
            status: 403, body: {'code': 'auth/forbidden', 'message': 'Forbidden.'});
        expect(
          () => service.listFavorites('wed_1'),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 'forbidden')),
        );
      });
    });

    group('addFavorite', () {
      setUp(() => fake.stub('POST', '/weddings/wed_1/favorites',
          status: 201, body: _favoriteJson));

      test('posts to /weddings/{id}/favorites', () async {
        await service.addFavorite(
          'wed_1',
          vendorId: 'foto_01',
          category: VendorCategory.fotograf,
          addedBy: 'uid_1',
        );
        expect(fake.lastRequest.method, 'POST');
        expect(fake.lastRequest.url.path, '/weddings/wed_1/favorites');
      });

      test('sends vendorId and category in body', () async {
        await service.addFavorite(
          'wed_1',
          vendorId: 'foto_01',
          category: VendorCategory.fotograf,
          addedBy: 'uid_1',
        );
        final body = fake.lastRequest.decodedBody!;
        expect(body['vendorId'], 'foto_01');
        expect(body['category'], 'fotograf');
      });

      test('does not send addedBy in body', () async {
        await service.addFavorite(
          'wed_1',
          vendorId: 'foto_01',
          category: VendorCategory.fotograf,
          addedBy: 'uid_1',
        );
        expect(
            fake.lastRequest.decodedBody!.containsKey('addedBy'), isFalse);
      });

      test('sets Authorization header', () async {
        await service.addFavorite(
          'wed_1',
          vendorId: 'foto_01',
          category: VendorCategory.fotograf,
          addedBy: 'uid_1',
        );
        expect(
            fake.lastRequest.headers['authorization'], 'Bearer test_token');
      });

      test('parses response into Favorite', () async {
        final fav = await service.addFavorite(
          'wed_1',
          vendorId: 'foto_01',
          category: VendorCategory.fotograf,
          addedBy: 'uid_1',
        );
        expect(fav.vendorId, 'foto_01');
        expect(fav.addedBy, 'uid_1');
        expect(fav.addedAt, DateTime.parse('2026-01-10T14:00:00Z'));
      });
    });

    group('removeFavorite', () {
      test('deletes /weddings/{id}/favorites/{vendorId}', () async {
        fake.stub('DELETE', '/weddings/wed_1/favorites/foto_01',
            status: 204, body: '');
        await service.removeFavorite('wed_1', 'foto_01');
        expect(fake.lastRequest.method, 'DELETE');
        expect(fake.lastRequest.url.path,
            '/weddings/wed_1/favorites/foto_01');
      });

      test('succeeds on 204 no-content', () async {
        fake.stub('DELETE', '/weddings/wed_1/favorites/foto_01',
            status: 204, body: '');
        await expectLater(
            service.removeFavorite('wed_1', 'foto_01'), completes);
      });

      test('throws ApiException(unauthorized) on 401', () async {
        fake.stub('DELETE', '/weddings/wed_1/favorites/foto_01',
            status: 401,
            body: {'code': 'auth/unauthorized', 'message': 'Unauthorized.'});
        expect(
          () => service.removeFavorite('wed_1', 'foto_01'),
          throwsA(
              isA<ApiException>().having((e) => e.code, 'code', 'unauthorized')),
        );
      });
    });
  });
}
