import '../models/user_model.dart';

abstract class UserService {
  // userId must match the Firebase UID from the auth token. The real API
  // derives userId from the token; the mock uses this parameter directly.
  Future<UserModel> createUser({
    required String userId,
    required String email,
    String? displayName,
  });

  Future<UserModel> getUser(String userId);

  Future<UserModel> updateUser(
    String userId, {
    String? displayName,
    String? weddingId,
  });
}
