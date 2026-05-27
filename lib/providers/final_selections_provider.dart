import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/categories.dart';
import '../models/final_selection.dart';
import '../models/vendor.dart';

class FinalSelectionsNotifier extends Notifier<List<FinalSelection>> {
  @override
  List<FinalSelection> build() => const [];

  void confirm(Vendor vendor) {
    final without =
        state.where((s) => s.category != vendor.category).toList(growable: true);
    without.add(
      FinalSelection(
        vendorId: vendor.id,
        category: vendor.category,
        confirmedAt: DateTime.now(),
      ),
    );
    state = without;
  }

  void remove(String vendorId) {
    state = state.where((s) => s.vendorId != vendorId).toList(growable: false);
  }

  void updateCustomPrice(String vendorId, int? price) {
    state = [
      for (final s in state)
        if (s.vendorId == vendorId)
          s.copyWith(customPrice: price, clearCustomPrice: price == null)
        else
          s,
    ];
  }

  void updateNotes(String vendorId, String? notes) {
    final trimmed = notes?.trim();
    state = [
      for (final s in state)
        if (s.vendorId == vendorId)
          s.copyWith(
            notes: trimmed,
            clearNotes: trimmed == null || trimmed.isEmpty,
          )
        else
          s,
    ];
  }

  bool contains(String vendorId) =>
      state.any((s) => s.vendorId == vendorId);

  FinalSelection? forCategory(VendorCategory category) {
    for (final s in state) {
      if (s.category == category) return s;
    }
    return null;
  }
}

final finalSelectionsProvider =
    NotifierProvider<FinalSelectionsNotifier, List<FinalSelection>>(
  FinalSelectionsNotifier.new,
);
