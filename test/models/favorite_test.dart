import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/core/constants/categories.dart';
import 'package:wedding_tinder/models/favorite.dart';

void main() {
  group('Favorite', () {
    final fixedDate = DateTime.utc(2024, 6, 15, 10, 30);

    Map<String, dynamic> baseJson() => {
          'vendorId': 'foto_01',
          'category': 'fotograf',
          'addedBy': 'user_abc',
          'addedAt': fixedDate.millisecondsSinceEpoch,
        };

    test('fromJson parses all fields', () {
      final f = Favorite.fromJson(baseJson());
      expect(f.vendorId, 'foto_01');
      expect(f.category, VendorCategory.fotograf);
      expect(f.addedBy, 'user_abc');
      expect(f.addedAt.millisecondsSinceEpoch,
          fixedDate.millisecondsSinceEpoch);
    });

    test('fromJson parses all category values', () {
      const categories = {
        'restaurant': VendorCategory.restaurant,
        'fotograf': VendorCategory.fotograf,
        'dj': VendorCategory.dj,
        'formatie': VendorCategory.formatie,
        'florarie': VendorCategory.florarie,
        'tort': VendorCategory.tort,
      };
      for (final entry in categories.entries) {
        final f = Favorite.fromJson({...baseJson(), 'category': entry.key});
        expect(f.category, entry.value);
      }
    });

    test('fromJson throws FormatException for unknown category', () {
      final bad = {...baseJson(), 'category': 'unknown'};
      expect(() => Favorite.fromJson(bad), throwsFormatException);
    });

    test('toJson round-trips through fromJson', () {
      final f = Favorite.fromJson(baseJson());
      final f2 = Favorite.fromJson(f.toJson());
      expect(f2.vendorId, f.vendorId);
      expect(f2.category, f.category);
      expect(f2.addedBy, f.addedBy);
      expect(f2.addedAt.millisecondsSinceEpoch,
          f.addedAt.millisecondsSinceEpoch);
    });

    test('toJson serializes category as json key string', () {
      final f = Favorite.fromJson(baseJson());
      expect(f.toJson()['category'], 'fotograf');
    });

    test('copyWith updates specified field', () {
      final f = Favorite.fromJson(baseJson());
      final copy = f.copyWith(addedBy: 'user_xyz');
      expect(copy.addedBy, 'user_xyz');
      expect(copy.vendorId, f.vendorId);
      expect(copy.category, f.category);
    });

    test('copyWith with no args is equivalent', () {
      final f = Favorite.fromJson(baseJson());
      expect(f.copyWith().vendorId, f.vendorId);
    });

    test('equality is by vendorId', () {
      final f1 = Favorite.fromJson(baseJson());
      final f2 = f1.copyWith(addedBy: 'different_user');
      expect(f1, equals(f2));
      expect(f1.hashCode, f2.hashCode);
    });

    test('different vendorIds are not equal', () {
      final f1 = Favorite.fromJson(baseJson());
      final f2 = f1.copyWith(vendorId: 'foto_02');
      expect(f1, isNot(equals(f2)));
    });
  });
}
