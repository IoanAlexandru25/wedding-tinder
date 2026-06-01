import '../../models/user_model.dart';
import '../service_exception.dart';
import '../user_service.dart';

class MockUserService implements UserService {
  final Map<String, UserModel> _store = {};

  @override
  Future<UserModel> createUser({
    required String userId,
    required String email,
    String? displayName,
  }) async {
    if (_store.containsKey(userId)) {
      throw const UserException('already-exists', 'User profile already exists.');
    }
    final user = UserModel(
      id: userId,
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
    );
    _store[userId] = user;
    return user;
  }

  @override
  Future<UserModel> getUser(String userId) async {
    final user = _store[userId];
    if (user == null) {
      throw const UserException('not-found', 'User not found.');
    }
    return user;
  }

  @override
  Future<UserModel> updateUser(
    String userId, {
    String? displayName,
    String? weddingId,
  }) async {
    final user = _store[userId];
    if (user == null) {
      throw const UserException('not-found', 'User not found.');
    }
    final updated = user.copyWith(displayName: displayName, weddingId: weddingId);
    _store[userId] = updated;
    return updated;
  }
}
