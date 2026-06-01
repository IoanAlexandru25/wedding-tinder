import '../../models/user_model.dart';
import '../user_service.dart';
import 'api_http_client.dart';

class ApiUserService implements UserService {
  ApiUserService(this._client);

  final ApiHttpClient _client;

  @override
  Future<UserModel> createUser({
    required String userId, // ignored — server derives UID from ID token
    required String email,
    String? displayName,
  }) async {
    final json = await _client.post('/users', {
      'email': email,
      if (displayName != null) 'displayName': displayName,
    });
    return _fromJson(json);
  }

  @override
  Future<UserModel> getUser(String userId) async {
    final json = await _client.get('/users/$userId');
    return _fromJson(json);
  }

  @override
  Future<UserModel> updateUser(
    String userId, {
    String? displayName,
    String? weddingId,
  }) async {
    final body = <String, dynamic>{
      if (displayName != null) 'displayName': displayName,
      if (weddingId != null) 'weddingId': weddingId,
    };
    final json = await _client.patch('/users/$userId', body);
    return _fromJson(json);
  }

  // ── Helper ─────────────────────────────────────────────────────────────────

  static UserModel _fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      weddingId: json['weddingId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
