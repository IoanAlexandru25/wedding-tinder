import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/core/constants/categories.dart';
import 'package:wedding_tinder/models/vendor.dart';
import 'package:wedding_tinder/models/vendor_filters.dart';
import 'package:wedding_tinder/providers/dismissed_provider.dart';
import 'package:wedding_tinder/providers/favorites_provider.dart';
import 'package:wedding_tinder/providers/filters_provider.dart';
import 'package:wedding_tinder/providers/service_providers.dart';
import 'package:wedding_tinder/providers/session_provider.dart';
import 'package:wedding_tinder/providers/vendors_provider.dart';
import 'package:wedding_tinder/services/mock/mock_dismissed_service.dart';
import 'package:wedding_tinder/services/mock/mock_favorites_service.dart';
import 'package:wedding_tinder/services/vendor_repository.dart';

Vendor _vendor(
  String id, {
  VendorCategory category = VendorCategory.restaurant,
  String judet = 'Cluj',
  int priceMin = 100,
  int priceMax = 200,
}) {
  return Vendor(
    id: id,
    name: 'Vendor $id',
    category: category,
    description: '',
    judet: judet,
    localitate: judet,
    priceMin: priceMin,
    priceMax: priceMax,
    priceUnit: 'RON/person',
    rating: 4.5,
    reviewCount: 10,
    photos: const [],
    tags: const [],
  );
}

final _catalog = [
  _vendor('r_cluj_cheap', judet: 'Cluj', priceMin: 100, priceMax: 200),
  _vendor('r_cluj_pricey', judet: 'Cluj', priceMin: 500, priceMax: 700),
  _vendor('r_buc', judet: 'Bucharest', priceMin: 300, priceMax: 400),
  _vendor('f_cluj',
      category: VendorCategory.fotograf,
      judet: 'Cluj',
      priceMin: 3000,
      priceMax: 5000),
  _vendor('dj_buc',
      category: VendorCategory.dj, judet: 'Bucharest', priceMin: 1500, priceMax: 2500),
];

Future<ProviderContainer> _makeContainer() async {
  final repo = VendorRepository()..debugSeed(_catalog);
  final container = ProviderContainer(
    overrides: [
      vendorRepositoryProvider.overrideWithValue(repo),
      favoritesServiceProvider.overrideWithValue(MockFavoritesService()),
      dismissedServiceProvider.overrideWithValue(MockDismissedService()),
      currentWeddingIdProvider.overrideWithValue(null),
    ],
  );
  await container.read(vendorsProvider.future);
  return container;
}

List<String> _ids(List<Vendor> vendors) => vendors.map((v) => v.id).toList();

void main() {
  late ProviderContainer container;

  setUp(() async => container = await _makeContainer());
  tearDown(() => container.dispose());

  void setFilters(VendorFilters filters) =>
      container.read(filtersProvider.notifier).state = filters;

  group('vendorsProvider', () {
    test('loads the whole catalog from the repository', () async {
      final all = await container.read(vendorsProvider.future);
      expect(all.length, _catalog.length);
    });
  });

  group('filteredVendorsProvider', () {
    test('no filters returns every vendor', () {
      expect(_ids(container.read(filteredVendorsProvider)), _ids(_catalog));
    });

    test('filters by category', () {
      setFilters(const VendorFilters(category: VendorCategory.restaurant));
      expect(
        _ids(container.read(filteredVendorsProvider)),
        ['r_cluj_cheap', 'r_cluj_pricey', 'r_buc'],
      );
    });

    test('filters by judet', () {
      setFilters(const VendorFilters(judet: 'Bucharest'));
      expect(_ids(container.read(filteredVendorsProvider)), ['r_buc', 'dj_buc']);
    });

    test('combines category and judet', () {
      setFilters(const VendorFilters(
        category: VendorCategory.restaurant,
        judet: 'Cluj',
      ));
      expect(
        _ids(container.read(filteredVendorsProvider)),
        ['r_cluj_cheap', 'r_cluj_pricey'],
      );
    });

    test('priceMin keeps vendors whose upper price reaches it', () {
      setFilters(const VendorFilters(
        category: VendorCategory.restaurant,
        priceMin: 400,
      ));
      // r_buc tops out at exactly 400, so it still overlaps the range.
      expect(
        _ids(container.read(filteredVendorsProvider)),
        ['r_cluj_pricey', 'r_buc'],
      );
    });

    test('priceMax keeps vendors whose lower price is within it', () {
      setFilters(const VendorFilters(
        category: VendorCategory.restaurant,
        priceMax: 300,
      ));
      expect(
        _ids(container.read(filteredVendorsProvider)),
        ['r_cluj_cheap', 'r_buc'],
      );
    });

    test('price range keeps only overlapping vendors', () {
      setFilters(const VendorFilters(
        category: VendorCategory.restaurant,
        priceMin: 250,
        priceMax: 450,
      ));
      expect(_ids(container.read(filteredVendorsProvider)), ['r_buc']);
    });

    test('excludes dismissed vendors', () async {
      await container.read(dismissedProvider.notifier).dismiss('r_buc');
      expect(_ids(container.read(filteredVendorsProvider)),
          isNot(contains('r_buc')));
    });

    test('excludes vendors already in favorites', () async {
      final vendor = _catalog.firstWhere((v) => v.id == 'f_cluj');
      await container
          .read(favoritesProvider.notifier)
          .like(vendor, addedBy: 'uid_1');
      expect(_ids(container.read(filteredVendorsProvider)),
          isNot(contains('f_cluj')));
    });

    test('resetting dismissed vendors brings them back', () async {
      final dismissed = container.read(dismissedProvider.notifier);
      await dismissed.dismiss('r_buc');
      dismissed.resetSession();
      expect(_ids(container.read(filteredVendorsProvider)), contains('r_buc'));
    });

    test('returns an empty list when nothing matches', () {
      setFilters(const VendorFilters(
        category: VendorCategory.tort,
      ));
      expect(container.read(filteredVendorsProvider), isEmpty);
    });
  });

  group('filteredCategoryCountsProvider', () {
    test('counts every category, including empty ones', () {
      final counts = container.read(filteredCategoryCountsProvider);
      expect(counts.keys, containsAll(VendorCategory.values));
      expect(counts[VendorCategory.restaurant], 3);
      expect(counts[VendorCategory.fotograf], 1);
      expect(counts[VendorCategory.dj], 1);
      expect(counts[VendorCategory.tort], 0);
    });

    test('ignores the selected category so all tabs keep their counts', () {
      setFilters(const VendorFilters(category: VendorCategory.dj));
      final counts = container.read(filteredCategoryCountsProvider);
      expect(counts[VendorCategory.restaurant], 3);
      expect(counts[VendorCategory.dj], 1);
    });

    test('respects judet and price filters', () {
      setFilters(const VendorFilters(judet: 'Cluj', priceMax: 300));
      final counts = container.read(filteredCategoryCountsProvider);
      expect(counts[VendorCategory.restaurant], 1);
      expect(counts[VendorCategory.fotograf], 0);
      expect(counts[VendorCategory.dj], 0);
    });
  });

  group('vendorCountsProvider', () {
    test('counts the unfiltered catalog per category', () async {
      setFilters(const VendorFilters(judet: 'Cluj'));
      final counts = await container.read(vendorCountsProvider.future);
      expect(counts[VendorCategory.restaurant], 3);
      expect(counts[VendorCategory.dj], 1);
    });
  });

  group('vendorByIdProvider', () {
    test('returns the vendor with the matching id', () {
      expect(container.read(vendorByIdProvider('dj_buc'))?.category,
          VendorCategory.dj);
    });

    test('returns null for an unknown id', () {
      expect(container.read(vendorByIdProvider('nope')), isNull);
    });
  });
}
