import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/categories.dart';
import '../models/final_selection.dart';
import '../models/vendor.dart';
import 'service_providers.dart';
import 'session_provider.dart';

class FinalSelectionsNotifier extends Notifier<List<FinalSelection>> {
  @override
  List<FinalSelection> build() => const [];

  String get _weddingId => ref.read(currentWeddingIdProvider) ?? 'mock';

  Future<void> confirm(Vendor vendor) async {
    final selection = await ref.read(finalSelectionsServiceProvider).confirm(
          _weddingId,
          vendorId: vendor.id,
          category: vendor.category,
        );
    final without =
        state.where((s) => s.category != vendor.category).toList(growable: true);
    without.add(selection);
    state = without;
  }

  Future<void> remove(String vendorId) async {
    await ref.read(finalSelectionsServiceProvider).remove(_weddingId, vendorId);
    state = state.where((s) => s.vendorId != vendorId).toList(growable: false);
  }

  Future<void> updateCustomPrice(String vendorId, int? price) async {
    final updated = await ref
        .read(finalSelectionsServiceProvider)
        .updateCustomPrice(_weddingId, vendorId, price);
    state = [
      for (final s in state)
        if (s.vendorId == vendorId) updated else s,
    ];
  }

  Future<void> updateNotes(String vendorId, String? notes) async {
    final updated = await ref
        .read(finalSelectionsServiceProvider)
        .updateNotes(_weddingId, vendorId, notes);
    state = [
      for (final s in state)
        if (s.vendorId == vendorId) updated else s,
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
