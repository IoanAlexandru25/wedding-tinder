import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/categories.dart';
import '../models/favorite.dart';
import '../models/vendor.dart';
import 'service_providers.dart';
import 'session_provider.dart';

class FavoritesNotifier extends Notifier<List<Favorite>> {
  @override
  List<Favorite> build() => const [];

  String get _weddingId => ref.read(currentWeddingIdProvider) ?? 'mock';

  Future<void> like(Vendor vendor, {required String addedBy}) async {
    if (contains(vendor.id)) return;
    final fav = await ref.read(favoritesServiceProvider).addFavorite(
          _weddingId,
          vendorId: vendor.id,
          category: vendor.category,
          addedBy: addedBy,
        );
    state = [...state, fav];
  }

  Future<void> remove(String vendorId) async {
    await ref.read(favoritesServiceProvider).removeFavorite(_weddingId, vendorId);
    state = state.where((f) => f.vendorId != vendorId).toList(growable: false);
  }

  bool contains(String vendorId) => state.any((f) => f.vendorId == vendorId);
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
