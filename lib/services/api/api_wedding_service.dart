import '../../models/wedding.dart';
import '../wedding_service.dart';
import 'api_http_client.dart';

class ApiWeddingService implements WeddingService {
  ApiWeddingService(this._client);

  final ApiHttpClient _client;

  @override
  Future<Wedding> createWedding({
    required String userId, // ignored — server derives from ID token
    required DateTime start,
    required DateTime end,
    required int guestCount,
    required int budgetMin,
    required int budgetMax,
  }) async {
    final json = await _client.post('/weddings', {
      'weddingDateStart': _dateOnly(start),
      'weddingDateEnd': _dateOnly(end),
      'guestCount': guestCount,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
    });
    return _fromJson(json);
  }

  @override
  Future<Wedding> joinWedding(String inviteCode, {required String userId}) async {
    final json = await _client.post('/weddings/join', {'inviteCode': inviteCode});
    return _fromJson(json);
  }

  @override
  Future<Wedding> getWedding(String weddingId) async {
    final json = await _client.get('/weddings/$weddingId');
    return _fromJson(json);
  }

  @override
  Future<Wedding> updateWedding(
    String weddingId, {
    DateTime? start,
    DateTime? end,
    int? guestCount,
    int? budgetMin,
    int? budgetMax,
  }) async {
    final body = <String, dynamic>{
      if (start != null) 'weddingDateStart': _dateOnly(start),
      if (end != null) 'weddingDateEnd': _dateOnly(end),
      if (guestCount != null) 'guestCount': guestCount,
      if (budgetMin != null) 'budgetMin': budgetMin,
      if (budgetMax != null) 'budgetMax': budgetMax,
    };
    final json = await _client.patch('/weddings/$weddingId', body);
    return _fromJson(json);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _dateOnly(DateTime dt) => dt.toIso8601String().split('T').first;

  static Wedding _fromJson(Map<String, dynamic> json) {
    return Wedding(
      id: json['id'] as String,
      inviteCode: json['inviteCode'] as String,
      partnerIds: (json['partnerIds'] as List).cast<String>(),
      weddingDateStart: DateTime.parse(json['weddingDateStart'] as String),
      weddingDateEnd: DateTime.parse(json['weddingDateEnd'] as String),
      guestCount: (json['guestCount'] as num).toInt(),
      budgetMin: (json['budgetMin'] as num).toInt(),
      budgetMax: (json['budgetMax'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
