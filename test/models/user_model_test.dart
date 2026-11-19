import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/models/user_model.dart';

void main() {
  final created = DateTime.fromMillisecondsSinceEpoch(1767225600000);

  UserModel user({String? weddingId, String? displayName}) => UserModel(
        id: 'uid_1',
        email: 'ana@example.com',
        createdAt: created,
        weddingId: weddingId,
        displayName: displayName,
      );

  group('UserModel', () {
    test('fromJson reads every field', () {
      final u = UserModel.fromJson({
        'id': 'uid_1',
        'email': 'ana@example.com',
        'weddingId': 'wed_1',
        'displayName': 'Ana',
        'createdAt': created.millisecondsSinceEpoch,
      });
      expect(u.id, 'uid_1');
      expect(u.email, 'ana@example.com');
      expect(u.weddingId, 'wed_1');
      expect(u.displayName, 'Ana');
      expect(u.createdAt, created);
    });

    test('fromJson accepts missing optional fields', () {
      final u = UserModel.fromJson({
        'id': 'uid_1',
        'email': 'ana@example.com',
        'createdAt': created.millisecondsSinceEpoch,
      });
      expect(u.weddingId, isNull);
      expect(u.displayName, isNull);
    });

    test('toJson omits null optional fields', () {
      final json = user().toJson();
      expect(json.containsKey('weddingId'), isFalse);
      expect(json.containsKey('displayName'), isFalse);
      expect(json['createdAt'], created.millisecondsSinceEpoch);
    });

    test('toJson / fromJson round-trip keeps all values', () {
      final original = user(weddingId: 'wed_1', displayName: 'Ana');
      final copy = UserModel.fromJson(original.toJson());
      expect(copy.id, original.id);
      expect(copy.email, original.email);
      expect(copy.weddingId, original.weddingId);
      expect(copy.displayName, original.displayName);
      expect(copy.createdAt, original.createdAt);
    });

    test('copyWith changes only the given fields', () {
      final updated = user(displayName: 'Ana').copyWith(weddingId: 'wed_9');
      expect(updated.weddingId, 'wed_9');
      expect(updated.displayName, 'Ana');
      expect(updated.email, 'ana@example.com');
    });

    test('equality is based on id only', () {
      expect(user(), equals(user(weddingId: 'other', displayName: 'X')));
      expect(user().hashCode, user(displayName: 'Y').hashCode);
      expect(
        user(),
        isNot(equals(UserModel(
          id: 'uid_2',
          email: 'ana@example.com',
          createdAt: created,
        ))),
      );
    });
  });
}
