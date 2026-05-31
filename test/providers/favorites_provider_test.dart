import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/core/constants/categories.dart';
import 'package:wedding_tinder/models/vendor.dart';
import 'package:wedding_tinder/providers/favorites_provider.dart';

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

void main() {
  group('FavoritesNotifier', () {
    late ProviderContainer container;
    late FavoritesNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(favoritesProvider.notifier);
    });

    tearDown(() => container.dispose());

    test('initial state is empty', () {
      expect(container.read(favoritesProvider), isEmpty);
    });

    test('like adds vendor to favorites', () {
      notifier.like(_vendor('foto_01'), addedBy: 'user_1');
      final faves = container.read(favoritesProvider);
      expect(faves.length, 1);
      expect(faves.first.vendorId, 'foto_01');
      expect(faves.first.addedBy, 'user_1');
    });

    test('like stores the correct category from the vendor', () {
      notifier.like(_vendor('dj_01', category: VendorCategory.dj),
          addedBy: 'user_1');
      expect(container.read(favoritesProvider).first.category,
          VendorCategory.dj);
    });

    test('like is idempotent — duplicate not added', () {
      notifier.like(_vendor('foto_01'), addedBy: 'user_1');
      notifier.like(_vendor('foto_01'), addedBy: 'user_1');
      expect(container.read(favoritesProvider).length, 1);
    });

    test('like multiple different vendors all appear', () {
      notifier.like(_vendor('f1'), addedBy: 'u');
      notifier.like(_vendor('f2'), addedBy: 'u');
      notifier.like(_vendor('f3'), addedBy: 'u');
      expect(container.read(favoritesProvider).length, 3);
    });

    test('remove deletes the vendor', () {
      notifier.like(_vendor('foto_01'), addedBy: 'user_1');
      notifier.remove('foto_01');
      expect(container.read(favoritesProvider), isEmpty);
    });

    test('remove on non-existent id is a no-op', () {
      notifier.like(_vendor('foto_01'), addedBy: 'user_1');
      notifier.remove('nonexistent');
      expect(container.read(favoritesProvider).length, 1);
    });

    test('remove only deletes the target, not other favorites', () {
      notifier.like(_vendor('f1'), addedBy: 'u');
      notifier.like(_vendor('f2'), addedBy: 'u');
      notifier.remove('f1');
      final faves = container.read(favoritesProvider);
      expect(faves.length, 1);
      expect(faves.first.vendorId, 'f2');
    });

    test('contains returns true after liking', () {
      notifier.like(_vendor('dj_01', category: VendorCategory.dj),
          addedBy: 'user_1');
      expect(notifier.contains('dj_01'), isTrue);
    });

    test('contains returns false before liking', () {
      expect(notifier.contains('foto_01'), isFalse);
    });

    test('contains returns false after removing', () {
      notifier.like(_vendor('foto_01'), addedBy: 'user_1');
      notifier.remove('foto_01');
      expect(notifier.contains('foto_01'), isFalse);
    });
  });

  group('favoritesByCategoryProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('empty favorites produces empty map', () {
      expect(container.read(favoritesByCategoryProvider), isEmpty);
    });

    test('groups favorites by category', () {
      final notifier = container.read(favoritesProvider.notifier);
      notifier.like(_vendor('f1', category: VendorCategory.fotograf),
          addedBy: 'u');
      notifier.like(_vendor('f2', category: VendorCategory.fotograf),
          addedBy: 'u');
      notifier.like(_vendor('d1', category: VendorCategory.dj), addedBy: 'u');

      final grouped = container.read(favoritesByCategoryProvider);
      expect(grouped[VendorCategory.fotograf]?.length, 2);
      expect(grouped[VendorCategory.dj]?.length, 1);
      expect(grouped.containsKey(VendorCategory.restaurant), isFalse);
    });

    test('removing a favorite updates the grouped map', () {
      final notifier = container.read(favoritesProvider.notifier);
      notifier.like(_vendor('f1', category: VendorCategory.fotograf),
          addedBy: 'u');
      notifier.remove('f1');
      expect(container.read(favoritesByCategoryProvider), isEmpty);
    });
  });
}
