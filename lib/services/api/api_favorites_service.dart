import '../../core/constants/categories.dart';
import '../../models/favorite.dart';
import '../favorites_service.dart';
import '../service_exception.dart';
import 'api_http_client.dart';

class ApiFavoritesService implements FavoritesService {
  ApiFavoritesService(this._client);

  final ApiHttpClient _client;

  @override
  Future<List<Favorite>> listFavorites(String weddingId) async {
    final list = await _client.getList('/weddings/$weddingId/favorites');
    return list
        .cast<Map<String, dynamic>>()
        .map(_fromJson)
        .toList(growable: false);
  }

  @override
  Future<Favorite> addFavorite(
    String weddingId, {
    required String vendorId,
    required VendorCategory category,
    required String addedBy,
  }) async {
    final json = await _client.post('/weddings/$weddingId/favorites', {
      'vendorId': vendorId,
      'category': category.jsonKey,
    });
    return _fromJson(json);
  }

  @override
  Future<void> removeFavorite(String weddingId, String vendorId) async {
    await _client.delete('/weddings/$weddingId/favorites/$vendorId');
  }

  static Favorite _fromJson(Map<String, dynamic> json) {
    final category = VendorCategoryX.tryParse(json['category'] as String?);
    if (category == null) {
      throw FavoritesException(
        'invalid-data',
        'Unknown category "${json['category']}" in favorite response.',
      );
    }
    return Favorite(
      vendorId: json['vendorId'] as String,
      category: category,
      addedBy: json['addedBy'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }
}
