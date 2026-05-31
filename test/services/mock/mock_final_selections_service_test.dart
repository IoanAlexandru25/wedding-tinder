import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/core/constants/categories.dart';
import 'package:wedding_tinder/services/mock/mock_final_selections_service.dart';
import 'package:wedding_tinder/services/service_exception.dart';

void main() {
  group('MockFinalSelectionsService', () {
    late MockFinalSelectionsService service;
    const weddingId = 'wed_1';

    setUp(() => service = MockFinalSelectionsService());

    group('listFinalSelections', () {
      test('returns empty list initially', () async {
        expect(await service.listFinalSelections(weddingId), isEmpty);
      });
    });

    group('confirm', () {
      test('returns selection with correct fields', () async {
        final s = await service.confirm(
          weddingId,
          vendorId: 'v1',
          category: VendorCategory.fotograf,
        );
        expect(s.vendorId, 'v1');
        expect(s.category, VendorCategory.fotograf);
        expect(s.customPrice, isNull);
        expect(s.notes, isNull);
      });

      test('selection appears in listFinalSelections', () async {
        await service.confirm(weddingId, vendorId: 'v1', category: VendorCategory.fotograf);
        expect((await service.listFinalSelections(weddingId)).length, 1);
      });

      test('accepts optional customPrice and notes', () async {
        final s = await service.confirm(
          weddingId,
          vendorId: 'v1',
          category: VendorCategory.fotograf,
          customPrice: 3000,
          notes: 'Great value',
        );
        expect(s.customPrice, 3000);
        expect(s.notes, 'Great value');
      });

      test('enforces one-per-category: replaces previous', () async {
        await service.confirm(weddingId, vendorId: 'v1', category: VendorCategory.fotograf);
        await service.confirm(weddingId, vendorId: 'v2', category: VendorCategory.fotograf);
        final list = await service.listFinalSelections(weddingId);
        expect(list.where((s) => s.category == VendorCategory.fotograf).length, 1);
        expect(list.first.vendorId, 'v2');
      });

      test('different categories coexist', () async {
        await service.confirm(weddingId, vendorId: 'v1', category: VendorCategory.fotograf);
        await service.confirm(weddingId, vendorId: 'v2', category: VendorCategory.dj);
        expect((await service.listFinalSelections(weddingId)).length, 2);
      });

      test('replacing a category does not affect other categories', () async {
        await service.confirm(weddingId, vendorId: 'v1', category: VendorCategory.fotograf);
        await service.confirm(weddingId, vendorId: 'd1', category: VendorCategory.dj);
        await service.confirm(weddingId, vendorId: 'v2', category: VendorCategory.fotograf);
        final list = await service.listFinalSelections(weddingId);
        expect(list.length, 2);
        expect(list.any((s) => s.vendorId == 'd1'), isTrue);
      });
    });

    group('updateCustomPrice', () {
      setUp(() async {
        await service.confirm(weddingId, vendorId: 'v1', category: VendorCategory.fotograf);
      });

      test('sets custom price', () async {
        final updated = await service.updateCustomPrice(weddingId, 'v1', 5000);
        expect(updated.customPrice, 5000);
      });

      test('null clears the price', () async {
        await service.updateCustomPrice(weddingId, 'v1', 5000);
        final updated = await service.updateCustomPrice(weddingId, 'v1', null);
        expect(updated.customPrice, isNull);
      });

      test('does not affect notes', () async {
        await service.confirm(weddingId, vendorId: 'v2', category: VendorCategory.dj, notes: 'Nice DJ');
        await service.updateCustomPrice(weddingId, 'v2', 2000);
        final list = await service.listFinalSelections(weddingId);
        expect(list.firstWhere((s) => s.vendorId == 'v2').notes, 'Nice DJ');
      });

      test('throws not-found for unknown vendorId', () async {
        expect(
          () => service.updateCustomPrice(weddingId, 'unknown', 3000),
          throwsA(isA<SelectionException>().having((e) => e.code, 'code', 'not-found')),
        );
      });
    });

    group('updateNotes', () {
      setUp(() async {
        await service.confirm(weddingId, vendorId: 'v1', category: VendorCategory.fotograf);
      });

      test('sets notes', () async {
        final updated = await service.updateNotes(weddingId, 'v1', 'Great photographer');
        expect(updated.notes, 'Great photographer');
      });

      test('trims whitespace from notes', () async {
        final updated = await service.updateNotes(weddingId, 'v1', '  trimmed  ');
        expect(updated.notes, 'trimmed');
      });

      test('null clears notes', () async {
        await service.updateNotes(weddingId, 'v1', 'old note');
        final updated = await service.updateNotes(weddingId, 'v1', null);
        expect(updated.notes, isNull);
      });

      test('empty string clears notes', () async {
        await service.updateNotes(weddingId, 'v1', 'old note');
        final updated = await service.updateNotes(weddingId, 'v1', '');
        expect(updated.notes, isNull);
      });

      test('whitespace-only string clears notes', () async {
        await service.updateNotes(weddingId, 'v1', 'old note');
        final updated = await service.updateNotes(weddingId, 'v1', '   ');
        expect(updated.notes, isNull);
      });

      test('throws not-found for unknown vendorId', () async {
        expect(
          () => service.updateNotes(weddingId, 'unknown', 'note'),
          throwsA(isA<SelectionException>().having((e) => e.code, 'code', 'not-found')),
        );
      });
    });

    group('remove', () {
      setUp(() async {
        await service.confirm(weddingId, vendorId: 'v1', category: VendorCategory.fotograf);
        await service.confirm(weddingId, vendorId: 'd1', category: VendorCategory.dj);
      });

      test('removes the target selection', () async {
        await service.remove(weddingId, 'v1');
        final list = await service.listFinalSelections(weddingId);
        expect(list.any((s) => s.vendorId == 'v1'), isFalse);
      });

      test('only removes the target, not others', () async {
        await service.remove(weddingId, 'v1');
        final list = await service.listFinalSelections(weddingId);
        expect(list.length, 1);
        expect(list.first.vendorId, 'd1');
      });

      test('on unknown vendorId is a no-op', () async {
        await service.remove(weddingId, 'unknown');
        expect((await service.listFinalSelections(weddingId)).length, 2);
      });
    });
  });
}
