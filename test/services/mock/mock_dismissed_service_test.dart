import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/services/mock/mock_dismissed_service.dart';

void main() {
  group('MockDismissedService', () {
    late MockDismissedService service;

    setUp(() => service = MockDismissedService());

    group('listDismissed', () {
      test('returns empty list for unknown weddingId', () async {
        expect(await service.listDismissed('wed_x'), isEmpty);
      });

      test('returns dismissed vendor ids after dismissing', () async {
        await service.dismiss('wed_1', 'v_01');
        await service.dismiss('wed_1', 'v_02');
        final ids = await service.listDismissed('wed_1');
        expect(ids, containsAll(['v_01', 'v_02']));
        expect(ids.length, 2);
      });

      test('scopes dismissed list per wedding', () async {
        await service.dismiss('wed_1', 'v_01');
        await service.dismiss('wed_2', 'v_02');
        expect(await service.listDismissed('wed_1'), equals(['v_01']));
        expect(await service.listDismissed('wed_2'), equals(['v_02']));
      });

      test('returned list is unmodifiable', () async {
        await service.dismiss('wed_1', 'v_01');
        final ids = await service.listDismissed('wed_1');
        expect(() => (ids as dynamic).add('v_02'), throwsA(anything));
      });
    });

    group('dismiss', () {
      test('adds vendor id to dismissed list', () async {
        await service.dismiss('wed_1', 'v_01');
        expect(await service.listDismissed('wed_1'), contains('v_01'));
      });

      test('is idempotent — dismissing same vendor twice does not duplicate', () async {
        await service.dismiss('wed_1', 'v_01');
        await service.dismiss('wed_1', 'v_01');
        expect((await service.listDismissed('wed_1')).length, 1);
      });

      test('multiple different vendors all stored', () async {
        await service.dismiss('wed_1', 'v_01');
        await service.dismiss('wed_1', 'v_02');
        await service.dismiss('wed_1', 'v_03');
        expect((await service.listDismissed('wed_1')).length, 3);
      });
    });
  });
}
