import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/core/constants/categories.dart';
import 'package:wedding_tinder/services/api/api_final_selections_service.dart';
import 'package:wedding_tinder/services/api/api_http_client.dart';
import 'package:wedding_tinder/services/service_exception.dart';

import '../../helpers/fake_http_client.dart';

const _selectionJson = {
  'vendorId': 'foto_01',
  'category': 'fotograf',
  'confirmedAt': '2026-01-10T15:00:00Z',
  'customPrice': null,
  'notes': null,
};

ApiFinalSelectionsService _makeService(FakeHttpClient fake) {
  final client = ApiHttpClient(fake, () async => 'test_token');
  return ApiFinalSelectionsService(client);
}

void main() {
  group('ApiFinalSelectionsService', () {
    late FakeHttpClient fake;
    late ApiFinalSelectionsService service;

    setUp(() {
      fake = FakeHttpClient();
      service = _makeService(fake);
    });

    group('listFinalSelections', () {
      test('gets /weddings/{id}/final-selections', () async {
        fake.stub('GET', '/weddings/wed_1/final-selections',
            status: 200, body: [_selectionJson]);
        await service.listFinalSelections('wed_1');
        expect(fake.lastRequest.method, 'GET');
        expect(
            fake.lastRequest.url.path, '/weddings/wed_1/final-selections');
      });

      test('parses list of FinalSelection objects', () async {
        fake.stub('GET', '/weddings/wed_1/final-selections',
            status: 200, body: [_selectionJson]);
        final list = await service.listFinalSelections('wed_1');
        expect(list.length, 1);
        expect(list.first.vendorId, 'foto_01');
        expect(list.first.category, VendorCategory.fotograf);
        expect(list.first.customPrice, isNull);
      });

      test('returns empty list for empty response', () async {
        fake.stub('GET', '/weddings/wed_1/final-selections',
            status: 200, body: <dynamic>[]);
        expect(await service.listFinalSelections('wed_1'), isEmpty);
      });
    });

    group('confirm', () {
      setUp(() => fake.stub('POST', '/weddings/wed_1/final-selections',
          status: 201, body: _selectionJson));

      test('posts to /weddings/{id}/final-selections', () async {
        await service.confirm('wed_1',
            vendorId: 'foto_01', category: VendorCategory.fotograf);
        expect(fake.lastRequest.method, 'POST');
        expect(fake.lastRequest.url.path,
            '/weddings/wed_1/final-selections');
      });

      test('sends vendorId and category in body', () async {
        await service.confirm('wed_1',
            vendorId: 'foto_01', category: VendorCategory.fotograf);
        final body = fake.lastRequest.decodedBody!;
        expect(body['vendorId'], 'foto_01');
        expect(body['category'], 'fotograf');
      });

      test('includes customPrice when provided', () async {
        await service.confirm('wed_1',
            vendorId: 'foto_01',
            category: VendorCategory.fotograf,
            customPrice: 5000);
        expect(fake.lastRequest.decodedBody!['customPrice'], 5000);
      });

      test('omits customPrice when not provided', () async {
        await service.confirm('wed_1',
            vendorId: 'foto_01', category: VendorCategory.fotograf);
        expect(
            fake.lastRequest.decodedBody!.containsKey('customPrice'), isFalse);
      });

      test('sets Authorization header', () async {
        await service.confirm('wed_1',
            vendorId: 'foto_01', category: VendorCategory.fotograf);
        expect(
            fake.lastRequest.headers['authorization'], 'Bearer test_token');
      });

      test('parses response into FinalSelection', () async {
        final s = await service.confirm('wed_1',
            vendorId: 'foto_01', category: VendorCategory.fotograf);
        expect(s.vendorId, 'foto_01');
        expect(s.confirmedAt, DateTime.parse('2026-01-10T15:00:00Z'));
      });

      test('throws SelectionException(not-favorited) on 400', () async {
        fake.stub('POST', '/weddings/wed_1/final-selections',
            status: 400,
            body: {
              'code': 'selection/not-favorited',
              'message': 'Must be in favorites.'
            });
        expect(
          () => service.confirm('wed_1',
              vendorId: 'foto_01', category: VendorCategory.fotograf),
          throwsA(isA<SelectionException>()
              .having((e) => e.code, 'code', 'not-favorited')),
        );
      });
    });

    group('updateCustomPrice', () {
      setUp(() => fake.stub(
          'PATCH', '/weddings/wed_1/final-selections/foto_01',
          status: 200, body: _selectionJson));

      test('patches /weddings/{id}/final-selections/{vendorId}', () async {
        await service.updateCustomPrice('wed_1', 'foto_01', 3000);
        expect(fake.lastRequest.method, 'PATCH');
        expect(fake.lastRequest.url.path,
            '/weddings/wed_1/final-selections/foto_01');
      });

      test('sends customPrice in body', () async {
        await service.updateCustomPrice('wed_1', 'foto_01', 3000);
        expect(fake.lastRequest.decodedBody!['customPrice'], 3000);
      });

      test('sends null to clear price', () async {
        await service.updateCustomPrice('wed_1', 'foto_01', null);
        expect(fake.lastRequest.decodedBody!['customPrice'], isNull);
      });

      test('parses updated FinalSelection', () async {
        final s = await service.updateCustomPrice('wed_1', 'foto_01', 3000);
        expect(s.vendorId, 'foto_01');
      });
    });

    group('updateNotes', () {
      setUp(() => fake.stub(
          'PATCH', '/weddings/wed_1/final-selections/foto_01',
          status: 200, body: _selectionJson));

      test('patches /weddings/{id}/final-selections/{vendorId}', () async {
        await service.updateNotes('wed_1', 'foto_01', 'Great choice');
        expect(fake.lastRequest.method, 'PATCH');
      });

      test('sends trimmed notes in body', () async {
        await service.updateNotes('wed_1', 'foto_01', '  note  ');
        expect(fake.lastRequest.decodedBody!['notes'], 'note');
      });

      test('sends null for empty notes', () async {
        await service.updateNotes('wed_1', 'foto_01', '');
        expect(fake.lastRequest.decodedBody!['notes'], isNull);
      });

      test('sends null for whitespace-only notes', () async {
        await service.updateNotes('wed_1', 'foto_01', '   ');
        expect(fake.lastRequest.decodedBody!['notes'], isNull);
      });

      test('sends null for null notes', () async {
        await service.updateNotes('wed_1', 'foto_01', null);
        expect(fake.lastRequest.decodedBody!['notes'], isNull);
      });
    });

    group('remove', () {
      test('deletes /weddings/{id}/final-selections/{vendorId}', () async {
        fake.stub('DELETE', '/weddings/wed_1/final-selections/foto_01',
            status: 204, body: '');
        await service.remove('wed_1', 'foto_01');
        expect(fake.lastRequest.method, 'DELETE');
        expect(fake.lastRequest.url.path,
            '/weddings/wed_1/final-selections/foto_01');
      });

      test('succeeds on 204 no-content', () async {
        fake.stub('DELETE', '/weddings/wed_1/final-selections/foto_01',
            status: 204, body: '');
        await expectLater(service.remove('wed_1', 'foto_01'), completes);
      });
    });
  });
}
