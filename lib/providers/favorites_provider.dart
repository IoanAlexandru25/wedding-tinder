import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/categories.dart';
import '../models/favorite.dart';
import '../models/vendor.dart';

class FavoritesNotifier extends Notifier<List<Favorite>> {
  @override
  List<Favorite> build() => const [];

  void like(Vendor vendor, {required String addedBy}) {
    if (contains(vendor.id)) return;
    state = [
      ...state,
      Favorite(
        vendorId: vendor.id,
        category: vendor.category,
        addedBy: addedBy,
        addedAt: DateTime.now(),
      ),
    ];
  }

  void remove(String vendorId) {
    state = state.where((f) => f.vendorId != vendorId).toList(growable: false);
  }

  bool contains(String vendorId) =>
      state.any((f) => f.vendorId == vendorId);
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, List<Favorite>>(
  FavoritesNotifier.new,
);

final favoritesByCategoryProvider =
    Provider<Map<VendorCategory, List<Favorite>>>((ref) {
  final all = ref.watch(favoritesProvider);
  final grouped = <VendorCategory, List<Favorite>>{};
  for (final f in all) {
    grouped.putIfAbsent(f.category, () => []).add(f);
  }
  return grouped;
});
