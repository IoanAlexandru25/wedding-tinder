import '../../core/constants/categories.dart';
import '../../models/final_selection.dart';
import '../final_selections_service.dart';
import '../service_exception.dart';
import 'api_http_client.dart';

class ApiFinalSelectionsService implements FinalSelectionsService {
  ApiFinalSelectionsService(this._client);

  final ApiHttpClient _client;

  @override
  Future<List<FinalSelection>> listFinalSelections(String weddingId) async {
    final list = await _client.getList('/weddings/$weddingId/final-selections');
    return list
        .cast<Map<String, dynamic>>()
        .map(_fromJson)
        .toList(growable: false);
  }

  @override
  Future<FinalSelection> confirm(
    String weddingId, {
    required String vendorId,
    required VendorCategory category,
    int? customPrice,
    String? notes,
  }) async {
    final json = await _client.post('/weddings/$weddingId/final-selections', {
      'vendorId': vendorId,
      'category': category.jsonKey,
      if (customPrice != null) 'customPrice': customPrice,
      if (notes != null) 'notes': notes,
    });
    return _fromJson(json);
  }

  @override
  Future<FinalSelection> updateCustomPrice(
    String weddingId,
    String vendorId,
    int? price,
  ) async {
    final json = await _client.patch(
      '/weddings/$weddingId/final-selections/$vendorId',
      {'customPrice': price},
    );
    return _fromJson(json);
  }

  @override
  Future<FinalSelection> updateNotes(
    String weddingId,
    String vendorId,
    String? notes,
  ) async {
    final trimmed = notes?.trim();
    final json = await _client.patch(
      '/weddings/$weddingId/final-selections/$vendorId',
      {'notes': trimmed?.isEmpty == true ? null : trimmed},
    );
    return _fromJson(json);
  }

  @override
  Future<void> remove(String weddingId, String vendorId) async {
    await _client.delete('/weddings/$weddingId/final-selections/$vendorId');
  }

  // ── Helper ─────────────────────────────────────────────────────────────────

  static FinalSelection _fromJson(Map<String, dynamic> json) {
    final category = VendorCategoryX.tryParse(json['category'] as String?);
    if (category == null) {
      throw SelectionException(
        'invalid-data',
        'Unknown category "${json['category']}" in final-selection response.',
      );
    }
    return FinalSelection(
      vendorId: json['vendorId'] as String,
      category: category,
      confirmedAt: DateTime.parse(json['confirmedAt'] as String),
      customPrice: json['customPrice'] as int?,
      notes: json['notes'] as String?,
    );
  }
}
