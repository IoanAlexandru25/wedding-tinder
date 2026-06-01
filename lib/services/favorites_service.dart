import '../core/constants/categories.dart';
import '../models/favorite.dart';

abstract class FavoritesService {
  Future<List<Favorite>> listFavorites(String weddingId);

  // addedBy is used by mock implementations. The real API derives who added
  // the favorite from the Firebase ID token and ignores this parameter.
  Future<Favorite> addFavorite(
    String weddingId, {
    required String vendorId,
    required VendorCategory category,
    required String addedBy,
  });

  Future<void> removeFavorite(String weddingId, String vendorId);
}
