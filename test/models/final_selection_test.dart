import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/core/constants/categories.dart';
import 'package:wedding_tinder/models/final_selection.dart';

void main() {
  group('FinalSelection', () {
    final base = FinalSelection(
      vendorId: 'dj_01',
      category: VendorCategory.dj,
      confirmedAt: DateTime.utc(2024, 8, 1),
      customPrice: 2000,
      notes: 'Plays until midnight',
    );

    test('copyWith replaces specified fields', () {
      final copy = base.copyWith(vendorId: 'dj_02');
      expect(copy.vendorId, 'dj_02');
      expect(copy.category, VendorCategory.dj);
      expect(copy.customPrice, 2000);
      expect(copy.notes, 'Plays until midnight');
    });

    test('copyWith with no args is equivalent', () {
      final copy = base.copyWith();
      expect(copy.vendorId, base.vendorId);
      expect(copy.customPrice, base.customPrice);
      expect(copy.notes, base.notes);
    });

    test('clearCustomPrice: true nullifies customPrice', () {
      final cleared = base.copyWith(clearCustomPrice: true);
      expect(cleared.customPrice, isNull);
      expect(cleared.notes, base.notes);
    });

    test('clearNotes: true nullifies notes', () {
      final cleared = base.copyWith(clearNotes: true);
      expect(cleared.notes, isNull);
      expect(cleared.customPrice, base.customPrice);
    });

    test('clearCustomPrice: true wins over new customPrice value', () {
      final updated = base.copyWith(customPrice: 9999, clearCustomPrice: true);
      expect(updated.customPrice, isNull);
    });

    test('clearNotes: true wins over new notes value', () {
      final updated = base.copyWith(notes: 'new note', clearNotes: true);
      expect(updated.notes, isNull);
    });

    test('updating customPrice without clear flag applies new value', () {
      final updated = base.copyWith(customPrice: 3000);
      expect(updated.customPrice, 3000);
    });

    test('updating notes without clear flag applies new value', () {
      final updated = base.copyWith(notes: 'updated note');
      expect(updated.notes, 'updated note');
    });

    test('equality is by vendorId', () {
      final copy = base.copyWith(customPrice: 9999);
      expect(base, equals(copy));
      expect(base.hashCode, copy.hashCode);
    });

    test('different vendorIds are not equal', () {
      final other = base.copyWith(vendorId: 'dj_99');
      expect(base, isNot(equals(other)));
    });

    test('selection with no optional fields', () {
      final minimal = FinalSelection(
        vendorId: 'rest_01',
        category: VendorCategory.restaurant,
        confirmedAt: DateTime.utc(2024, 1, 1),
      );
      expect(minimal.customPrice, isNull);
      expect(minimal.notes, isNull);
    });
  });
}
