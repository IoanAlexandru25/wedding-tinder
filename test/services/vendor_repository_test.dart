import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/core/constants/categories.dart';
import 'package:wedding_tinder/models/vendor.dart';
import 'package:wedding_tinder/services/vendor_repository.dart';

Vendor _make({
  String id = 'v_01',
  String name = 'Test Vendor',
  VendorCategory category = VendorCategory.fotograf,
  String judet = 'Cluj',
  String localitate = 'Cluj-Napoca',
  String description = 'A description',
  List<String> tags = const [],
  int priceMin = 500,
  int priceMax = 1000,
}) {
  return Vendor(
    id: id,
    name: name,
    category: category,
    description: description,
    judet: judet,
    localitate: localitate,
    priceMin: priceMin,
    priceMax: priceMax,
    priceUnit: 'RON',
    rating: 4.5,
    reviewCount: 10,
    photos: const [],
    tags: tags,
  );
}

void main() {
  group('VendorRepository', () {
    late VendorRepository repo;

    setUp(() => repo = VendorRepository());

    group('filterBy — category', () {
      setUp(() {
        repo.debugSeed([
          _make(id: 'r1', category: VendorCategory.restaurant),
          _make(id: 'f1', category: VendorCategory.fotograf),
          _make(id: 'f2', category: VendorCategory.fotograf),
          _make(id: 'd1', category: VendorCategory.dj),
        ]);
      });

      test('no filters returns all vendors', () async {
        expect((await repo.filterBy()).length, 4);
      });

      test('category filter returns only matching vendors', () async {
        final result = await repo.filterBy(category: VendorCategory.fotograf);
        expect(result.length, 2);
        expect(result.every((v) => v.category == VendorCategory.fotograf), isTrue);
      });

      test('category with zero matches returns empty list', () async {
        final result = await repo.filterBy(category: VendorCategory.tort);
        expect(result, isEmpty);
      });
    });

    group('filterBy — judet', () {
      setUp(() {
        repo.debugSeed([
          _make(id: 'v1', judet: 'Cluj'),
          _make(id: 'v2', judet: 'Cluj'),
          _make(id: 'v3', judet: 'Bucharest'),
        ]);
      });

      test('judet filter is an exact match', () async {
        final result = await repo.filterBy(judet: 'Cluj');
        expect(result.length, 2);
        expect(result.every((v) => v.judet == 'Cluj'), isTrue);
      });

      test('judet with no match returns empty', () async {
        final result = await repo.filterBy(judet: 'Iasi');
        expect(result, isEmpty);
      });
    });

    group('filterBy — price range', () {
      setUp(() {
        repo.debugSeed([
          _make(id: 'cheap', priceMin: 100, priceMax: 300),
          _make(id: 'mid', priceMin: 500, priceMax: 1000),
          _make(id: 'premium', priceMin: 1500, priceMax: 3000),
        ]);
      });

      // priceMin filter: exclude vendors whose priceMax < priceMin
      test('priceMin excludes vendors with priceMax below threshold', () async {
        final result = await repo.filterBy(priceMin: 400);
        final ids = result.map((v) => v.id).toSet();
        expect(ids, containsAll(['mid', 'premium']));
        expect(ids, isNot(contains('cheap')));
      });

      // priceMax filter: exclude vendors whose priceMin > priceMax
      test('priceMax excludes vendors with priceMin above threshold', () async {
        final result = await repo.filterBy(priceMax: 1000);
        final ids = result.map((v) => v.id).toSet();
        expect(ids, containsAll(['cheap', 'mid']));
        expect(ids, isNot(contains('premium')));
      });

      test('price range filters combine to narrow results', () async {
        final result = await repo.filterBy(priceMin: 400, priceMax: 1200);
        expect(result.map((v) => v.id).toSet(), {'mid'});
      });

      test('vendor whose range overlaps boundary is included', () async {
        // 'mid' priceMax=1000 >= priceMin=1000 → included
        final result = await repo.filterBy(priceMin: 1000);
        expect(result.map((v) => v.id), contains('mid'));
      });
    });

    group('filterBy — text query', () {
      setUp(() {
        repo.debugSeed([
          _make(id: 'marble', name: 'Marble Palace', description: 'luxury'),
          _make(id: 'garden', name: 'Garden Studio', description: 'outdoor'),
          _make(
            id: 'diacritic',
            name: 'Grădina Florilor',
            description: 'flowers',
          ),
          _make(
            id: 'tagged',
            name: 'Tag Vendor',
            description: 'basic',
            tags: ['elegant', 'classic'],
          ),
        ]);
      });

      test('matches by vendor name (case-insensitive)', () async {
        final result = await repo.filterBy(query: 'marble');
        expect(result.length, 1);
        expect(result.first.id, 'marble');
      });

      test('matches by description', () async {
        final result = await repo.filterBy(query: 'outdoor');
        expect(result.length, 1);
        expect(result.first.id, 'garden');
      });

      test('matches by tag', () async {
        final result = await repo.filterBy(query: 'elegant');
        expect(result.length, 1);
        expect(result.first.id, 'tagged');
      });

      test('normalizes Romanian diacritics — ă matches a', () async {
        // 'Grădina' → 'gradina' after normalization; query 'Gradina' → 'gradina'
        final result = await repo.filterBy(query: 'Gradina');
        expect(result.length, 1);
        expect(result.first.id, 'diacritic');
      });

      test('query is case-insensitive', () async {
        final lower = await repo.filterBy(query: 'MARBLE');
        expect(lower.length, 1);
      });

      test('empty query returns all vendors', () async {
        final result = await repo.filterBy(query: '');
        expect(result.length, 4);
      });

      test('null query returns all vendors', () async {
        final result = await repo.filterBy(query: null);
        expect(result.length, 4);
      });

      test('no match returns empty list', () async {
        final result = await repo.filterBy(query: 'zzznomatch999');
        expect(result, isEmpty);
      });
    });

    group('filterBy — combined filters', () {
      setUp(() {
        repo.debugSeed([
          _make(
            id: 'cluj_foto',
            category: VendorCategory.fotograf,
            judet: 'Cluj',
          ),
          _make(
            id: 'iasi_foto',
            category: VendorCategory.fotograf,
            judet: 'Iasi',
          ),
          _make(
            id: 'cluj_dj',
            category: VendorCategory.dj,
            judet: 'Cluj',
          ),
        ]);
      });

      test('category + judet combination returns only the matching vendor', () async {
        final result = await repo.filterBy(
          category: VendorCategory.fotograf,
          judet: 'Cluj',
        );
        expect(result.length, 1);
        expect(result.first.id, 'cluj_foto');
      });
    });

    group('findById', () {
      setUp(() {
        repo.debugSeed([
          _make(id: 'foto_01'),
          _make(id: 'dj_01', category: VendorCategory.dj),
        ]);
      });

      test('returns vendor with matching id', () async {
        final v = await repo.findById('foto_01');
        expect(v, isNotNull);
        expect(v!.id, 'foto_01');
      });

      test('returns null for unknown id', () async {
        final v = await repo.findById('nonexistent');
        expect(v, isNull);
      });
    });

    group('countsByCategory', () {
      test('counts vendors per category correctly', () async {
        repo.debugSeed([
          _make(id: 'r1', category: VendorCategory.restaurant),
          _make(id: 'r2', category: VendorCategory.restaurant),
          _make(id: 'f1', category: VendorCategory.fotograf),
        ]);
        final counts = await repo.countsByCategory();
        expect(counts[VendorCategory.restaurant], 2);
        expect(counts[VendorCategory.fotograf], 1);
        expect(counts[VendorCategory.dj], 0);
      });

      test('result contains an entry for every VendorCategory', () async {
        repo.debugSeed([]);
        final counts = await repo.countsByCategory();
        for (final c in VendorCategory.values) {
          expect(counts.containsKey(c), isTrue,
              reason: '${c.name} should be present');
        }
      });

      test('empty catalog produces all-zero counts', () async {
        repo.debugSeed([]);
        final counts = await repo.countsByCategory();
        expect(counts.values.every((n) => n == 0), isTrue);
      });
    });

    group('caching', () {
      test('loadAll returns the identical list on repeated calls', () async {
        repo.debugSeed([_make(id: 'v1')]);
        final first = await repo.loadAll();
        final second = await repo.loadAll();
        expect(identical(first, second), isTrue);
      });
    });
  });
}
