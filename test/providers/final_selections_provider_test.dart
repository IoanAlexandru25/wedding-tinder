import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/core/constants/categories.dart';
import 'package:wedding_tinder/models/vendor.dart';
import 'package:wedding_tinder/providers/final_selections_provider.dart';
import 'package:wedding_tinder/providers/service_providers.dart';
import 'package:wedding_tinder/providers/session_provider.dart';
import 'package:wedding_tinder/services/mock/mock_final_selections_service.dart';

Vendor _vendor(String id, {VendorCategory category = VendorCategory.fotograf}) {
  return Vendor(
    id: id,
    name: 'Vendor $id',
    category: category,
    description: '',
    judet: 'Cluj',
    localitate: 'Cluj-Napoca',
    priceMin: 500,
    priceMax: 1000,
    priceUnit: 'RON',
    rating: 4.0,
    reviewCount: 5,
    photos: const [],
    tags: const [],
  );
}

ProviderContainer _makeContainer() {
  return ProviderContainer(
    overrides: [
      finalSelectionsServiceProvider.overrideWithValue(MockFinalSelectionsService()),
      currentWeddingIdProvider.overrideWithValue('test_wedding'),
    ],
  );
}

void main() {
  group('FinalSelectionsNotifier', () {
    late ProviderContainer container;
    late FinalSelectionsNotifier notifier;

    setUp(() {
      container = _makeContainer();
      notifier = container.read(finalSelectionsProvider.notifier);
    });

    tearDown(() => container.dispose());

    test('initial state is empty', () {
      expect(container.read(finalSelectionsProvider), isEmpty);
    });

    group('confirm', () {
      test('adds a vendor to final selections', () async {
        await notifier.confirm(_vendor('foto_01'));
        expect(container.read(finalSelectionsProvider).length, 1);
        expect(
            container.read(finalSelectionsProvider).first.vendorId, 'foto_01');
      });

      test('stores the correct category from the vendor', () async {
        await notifier.confirm(_vendor('dj_01', category: VendorCategory.dj));
        expect(container.read(finalSelectionsProvider).first.category,
            VendorCategory.dj);
      });

      test('enforces one selection per category — replaces previous', () async {
        await notifier.confirm(
            _vendor('foto_01', category: VendorCategory.fotograf));
        await notifier.confirm(
            _vendor('foto_02', category: VendorCategory.fotograf));
        final state = container.read(finalSelectionsProvider);
        final count =
            state.where((s) => s.category == VendorCategory.fotograf).length;
        expect(count, 1);
        expect(state.first.vendorId, 'foto_02');
      });

      test('different categories coexist', () async {
        await notifier.confirm(_vendor('foto_01', category: VendorCategory.fotograf));
        await notifier.confirm(_vendor('dj_01', category: VendorCategory.dj));
        expect(container.read(finalSelectionsProvider).length, 2);
      });

      test('replacing a category does not affect other categories', () async {
        await notifier.confirm(_vendor('foto_01', category: VendorCategory.fotograf));
        await notifier.confirm(_vendor('dj_01', category: VendorCategory.dj));
        await notifier.confirm(_vendor('foto_02', category: VendorCategory.fotograf));
        final state = container.read(finalSelectionsProvider);
        expect(state.length, 2);
        expect(state.any((s) => s.vendorId == 'dj_01'), isTrue);
      });
    });

    group('remove', () {
      test('deletes the selection', () async {
        await notifier.confirm(_vendor('foto_01'));
        await notifier.remove('foto_01');
        expect(container.read(finalSelectionsProvider), isEmpty);
      });

      test('on unknown vendorId is a no-op', () async {
        await notifier.confirm(_vendor('foto_01'));
        await notifier.remove('nonexistent');
        expect(container.read(finalSelectionsProvider).length, 1);
      });

      test('only removes the target selection', () async {
        await notifier.confirm(_vendor('f1', category: VendorCategory.fotograf));
        await notifier.confirm(_vendor('d1', category: VendorCategory.dj));
        await notifier.remove('f1');
        final state = container.read(finalSelectionsProvider);
        expect(state.length, 1);
        expect(state.first.vendorId, 'd1');
      });
    });

    group('contains', () {
      test('true after confirming', () async {
        await notifier.confirm(_vendor('foto_01'));
        expect(notifier.contains('foto_01'), isTrue);
      });

      test('false before confirming', () {
        expect(notifier.contains('foto_01'), isFalse);
      });

      test('false after removing', () async {
        await notifier.confirm(_vendor('foto_01'));
        await notifier.remove('foto_01');
        expect(notifier.contains('foto_01'), isFalse);
      });
    });

    group('forCategory', () {
      test('returns the selection for that category', () async {
        await notifier.confirm(_vendor('foto_01', category: VendorCategory.fotograf));
        expect(
            notifier.forCategory(VendorCategory.fotograf)?.vendorId, 'foto_01');
      });

      test('returns null when category has no selection', () {
        expect(notifier.forCategory(VendorCategory.dj), isNull);
      });

      test('returns the latest selection after a replace', () async {
        await notifier.confirm(_vendor('foto_01', category: VendorCategory.fotograf));
        await notifier.confirm(_vendor('foto_02', category: VendorCategory.fotograf));
        expect(
            notifier.forCategory(VendorCategory.fotograf)?.vendorId, 'foto_02');
      });
    });

    group('updateCustomPrice', () {
      setUp(() async => notifier.confirm(_vendor('foto_01')));

      test('sets price on the matching vendor', () async {
        await notifier.updateCustomPrice('foto_01', 3000);
        expect(
            container.read(finalSelectionsProvider).first.customPrice, 3000);
      });

      test('null price clears customPrice', () async {
        await notifier.updateCustomPrice('foto_01', 3000);
        await notifier.updateCustomPrice('foto_01', null);
        expect(
            container.read(finalSelectionsProvider).first.customPrice, isNull);
      });

      test('does not affect other selections', () async {
        await notifier.confirm(_vendor('dj_01', category: VendorCategory.dj));
        await notifier.updateCustomPrice('foto_01', 2000);
        final state = container.read(finalSelectionsProvider);
        final dj = state.firstWhere((s) => s.vendorId == 'dj_01');
        expect(dj.customPrice, isNull);
      });
    });

    group('updateNotes', () {
      setUp(() async => notifier.confirm(_vendor('foto_01')));

      test('sets notes on the matching vendor', () async {
        await notifier.updateNotes('foto_01', 'Special requests');
        expect(
            container.read(finalSelectionsProvider).first.notes,
            'Special requests');
      });

      test('trims whitespace from notes', () async {
        await notifier.updateNotes('foto_01', '  trimmed  ');
        expect(
            container.read(finalSelectionsProvider).first.notes, 'trimmed');
      });

      test('empty string clears notes', () async {
        await notifier.updateNotes('foto_01', 'old note');
        await notifier.updateNotes('foto_01', '');
        expect(container.read(finalSelectionsProvider).first.notes, isNull);
      });

      test('whitespace-only string clears notes', () async {
        await notifier.updateNotes('foto_01', 'old note');
        await notifier.updateNotes('foto_01', '   ');
        expect(container.read(finalSelectionsProvider).first.notes, isNull);
      });

      test('null clears notes', () async {
        await notifier.updateNotes('foto_01', 'old note');
        await notifier.updateNotes('foto_01', null);
        expect(container.read(finalSelectionsProvider).first.notes, isNull);
      });
    });
  });
}
