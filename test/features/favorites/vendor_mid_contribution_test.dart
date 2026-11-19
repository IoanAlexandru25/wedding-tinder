import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/core/constants/categories.dart';
import 'package:wedding_tinder/features/favorites/favorites_screen.dart';
import 'package:wedding_tinder/models/vendor.dart';

Vendor _vendor({
  required int priceMin,
  required int priceMax,
  required String priceUnit,
}) {
  return Vendor(
    id: 'v1',
    name: 'Vendor',
    category: VendorCategory.restaurant,
    description: '',
    judet: 'Cluj',
    localitate: 'Cluj-Napoca',
    priceMin: priceMin,
    priceMax: priceMax,
    priceUnit: priceUnit,
    rating: 4.0,
    reviewCount: 1,
    photos: const [],
    tags: const [],
  );
}

void main() {
  group('vendorMidContribution', () {
    test('per-person prices are multiplied by the guest count', () {
      final v = _vendor(priceMin: 300, priceMax: 500, priceUnit: 'RON/person');
      expect(vendorMidContribution(v, 100), 40000);
    });

    test('per-portion prices are multiplied by the guest count', () {
      final v = _vendor(priceMin: 20, priceMax: 30, priceUnit: 'RON/portion');
      expect(vendorMidContribution(v, 150), 3750);
    });

    test('flat prices are not multiplied', () {
      final v = _vendor(priceMin: 3000, priceMax: 5000, priceUnit: 'RON/event');
      expect(vendorMidContribution(v, 200), 4000);
    });

    test('the midpoint is rounded', () {
      final v = _vendor(priceMin: 100, priceMax: 101, priceUnit: 'RON');
      expect(vendorMidContribution(v, 10), 101);
    });

    test('zero guests gives zero for per-person prices', () {
      final v = _vendor(priceMin: 300, priceMax: 500, priceUnit: 'RON/person');
      expect(vendorMidContribution(v, 0), 0);
    });
  });
}
