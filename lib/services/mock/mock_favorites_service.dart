import '../../core/constants/categories.dart';
import '../../models/favorite.dart';
import '../favorites_service.dart';

class MockFavoritesService implements FavoritesService {
  final Map<String, List<Favorite>> _store = {};

  @override
  Future<List<Favorite>> listFavorites(String weddingId) async {
    return List.unmodifiable(_store[weddingId] ?? const []);
  }

  @override
  Future<Favorite> addFavorite(
    String weddingId, {
    required String vendorId,
    required VendorCategory category,
    required String addedBy,
  }) async {
    final list = _store.putIfAbsent(weddingId, () => []);
    final existing = list.where((f) => f.vendorId == vendorId).firstOrNull;
    if (existing != null) return existing;
    final fav = Favorite(
      vendorId: vendorId,
      category: category,
      addedBy: addedBy,
      addedAt: DateTime.now(),
    );
    list.add(fav);
    return fav;
  }

  @override
  Future<void> removeFavorite(String weddingId, String vendorId) async {
    _store[weddingId]?.removeWhere((f) => f.vendorId == vendorId);
  }
}
