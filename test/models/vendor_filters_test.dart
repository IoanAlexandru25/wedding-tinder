import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/core/constants/categories.dart';
import 'package:wedding_tinder/models/vendor_filters.dart';

void main() {
  group('VendorFilters', () {
    group('isEmpty', () {
      test('true when all fields are null', () {
        expect(const VendorFilters().isEmpty, isTrue);
      });

      test('false when category is set', () {
        expect(
          const VendorFilters(category: VendorCategory.dj).isEmpty,
          isFalse,
        );
      });

      test('false when judet is set', () {
        expect(const VendorFilters(judet: 'Cluj').isEmpty, isFalse);
      });

      test('false when query is set to non-empty string', () {
        expect(const VendorFilters(query: 'foto').isEmpty, isFalse);
      });

      test('true when query is empty string', () {
        expect(const VendorFilters(query: '').isEmpty, isTrue);
      });

      test('false when priceMin is set', () {
        expect(const VendorFilters(priceMin: 100).isEmpty, isFalse);
      });

      test('false when priceMax is set', () {
        expect(const VendorFilters(priceMax: 500).isEmpty, isFalse);
      });
    });

    group('copyWith', () {
      test('updates only the specified field', () {
        const f = VendorFilters(
          category: VendorCategory.fotograf,
          judet: 'Cluj',
        );
        final f2 = f.copyWith(judet: 'Iasi');
        expect(f2.category, VendorCategory.fotograf);
        expect(f2.judet, 'Iasi');
      });

      test('with no args returns equivalent filters', () {
        const f = VendorFilters(category: VendorCategory.dj, priceMin: 200);
        expect(f.copyWith(), equals(f));
      });
    });

    group('clear', () {
      const full = VendorFilters(
        category: VendorCategory.tort,
        judet: 'Cluj',
        query: 'elegant',
        priceMin: 200,
        priceMax: 800,
      );

      test('clear(category: true) nullifies only category', () {
        final f = full.clear(category: true);
        expect(f.category, isNull);
        expect(f.judet, 'Cluj');
        expect(f.query, 'elegant');
        expect(f.priceMin, 200);
        expect(f.priceMax, 800);
      });

      test('clear(judet: true) nullifies only judet', () {
        final f = full.clear(judet: true);
        expect(f.judet, isNull);
        expect(f.category, VendorCategory.tort);
      });

      test('clear(query: true) nullifies only query', () {
        final f = full.clear(query: true);
        expect(f.query, isNull);
        expect(f.category, VendorCategory.tort);
      });

      test('clear(price: true) nullifies both priceMin and priceMax', () {
        final f = full.clear(price: true);
        expect(f.priceMin, isNull);
        expect(f.priceMax, isNull);
        expect(f.category, VendorCategory.tort);
      });

      test('clear with no flags is a no-op', () {
        expect(full.clear(), equals(full));
      });
    });

    group('equality', () {
      test('equal when all fields match', () {
        const a = VendorFilters(category: VendorCategory.dj, judet: 'Cluj');
        const b = VendorFilters(category: VendorCategory.dj, judet: 'Cluj');
        expect(a, equals(b));
        expect(a.hashCode, b.hashCode);
      });

      test('not equal when judet differs', () {
        const a = VendorFilters(category: VendorCategory.dj, judet: 'Cluj');
        const b = VendorFilters(category: VendorCategory.dj, judet: 'Iasi');
        expect(a, isNot(equals(b)));
      });

      test('not equal when category differs', () {
        const a = VendorFilters(category: VendorCategory.dj);
        const b = VendorFilters(category: VendorCategory.fotograf);
        expect(a, isNot(equals(b)));
      });

      test('not equal when price range differs', () {
        const a = VendorFilters(priceMin: 100, priceMax: 500);
        const b = VendorFilters(priceMin: 200, priceMax: 500);
        expect(a, isNot(equals(b)));
      });
    });
  });
}
