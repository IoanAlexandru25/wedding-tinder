import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/core/constants/categories.dart';
import 'package:wedding_tinder/services/mock/mock_favorites_service.dart';

void main() {
  group('MockFavoritesService', () {
    late MockFavoritesService service;
    const weddingId = 'wed_1';

    setUp(() => service = MockFavoritesService());

    group('listFavorites', () {
      test('returns empty list when no favorites added', () async {
        expect(await service.listFavorites(weddingId), isEmpty);
      });

      test('returns empty list for unknown weddingId', () async {
        await service.addFavorite(
          'wed_other',
          vendorId: 'v1',
          category: VendorCategory.fotograf,
          addedBy: 'u1',
        );
        expect(await service.listFavorites(weddingId), isEmpty);
      });
    });

    group('addFavorite', () {
      test('returns the added favorite with correct fields', () async {
        final fav = await service.addFavorite(
          weddingId,
          vendorId: 'v1',
          category: VendorCategory.fotograf,
          addedBy: 'u1',
        );
        expect(fav.vendorId, 'v1');
        expect(fav.category, VendorCategory.fotograf);
        expect(fav.addedBy, 'u1');
      });

      test('favorite appears in listFavorites after adding', () async {
        await service.addFavorite(
          weddingId,
          vendorId: 'v1',
          category: VendorCategory.fotograf,
          addedBy: 'u1',
        );
        final list = await service.listFavorites(weddingId);
        expect(list.length, 1);
        expect(list.first.vendorId, 'v1');
      });

      test('multiple vendors can be added', () async {
        await service.addFavorite(weddingId, vendorId: 'v1', category: VendorCategory.fotograf, addedBy: 'u1');
        await service.addFavorite(weddingId, vendorId: 'v2', category: VendorCategory.dj, addedBy: 'u1');
        expect((await service.listFavorites(weddingId)).length, 2);
      });

      test('is idempotent — duplicate vendorId not added', () async {
        await service.addFavorite(weddingId, vendorId: 'v1', category: VendorCategory.fotograf, addedBy: 'u1');
        await service.addFavorite(weddingId, vendorId: 'v1', category: VendorCategory.fotograf, addedBy: 'u1');
        expect((await service.listFavorites(weddingId)).length, 1);
      });

      test('idempotent call returns existing favorite', () async {
        final first = await service.addFavorite(weddingId, vendorId: 'v1', category: VendorCategory.fotograf, addedBy: 'u1');
        final second = await service.addFavorite(weddingId, vendorId: 'v1', category: VendorCategory.fotograf, addedBy: 'u2');
        expect(second.addedBy, first.addedBy);
      });

      test('favorites are scoped per weddingId', () async {
        await service.addFavorite('wed_a', vendorId: 'v1', category: VendorCategory.fotograf, addedBy: 'u1');
        expect(await service.listFavorites('wed_b'), isEmpty);
      });
    });

    group('removeFavorite', () {
      setUp(() async {
        await service.addFavorite(weddingId, vendorId: 'v1', category: VendorCategory.fotograf, addedBy: 'u1');
        await service.addFavorite(weddingId, vendorId: 'v2', category: VendorCategory.dj, addedBy: 'u1');
      });

      test('removes the target favorite', () async {
        await service.removeFavorite(weddingId, 'v1');
        final list = await service.listFavorites(weddingId);
        expect(list.any((f) => f.vendorId == 'v1'), isFalse);
      });

      test('only removes the target, not others', () async {
        await service.removeFavorite(weddingId, 'v1');
        final list = await service.listFavorites(weddingId);
        expect(list.length, 1);
        expect(list.first.vendorId, 'v2');
      });

      test('on unknown vendorId is a no-op', () async {
        await service.removeFavorite(weddingId, 'unknown');
        expect((await service.listFavorites(weddingId)).length, 2);
      });
    });
  });
}
