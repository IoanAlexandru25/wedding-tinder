import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/core/utils/invite_code_generator.dart';
import 'package:wedding_tinder/services/mock/mock_wedding_service.dart';
import 'package:wedding_tinder/services/service_exception.dart';

Future<dynamic> _create(
  MockWeddingService service, {
  String userId = 'user_1',
  int guestCount = 100,
  int budgetMin = 40000,
  int budgetMax = 60000,
}) {
  return service.createWedding(
    userId: userId,
    start: DateTime(2026, 6, 15),
    end: DateTime(2026, 6, 15),
    guestCount: guestCount,
    budgetMin: budgetMin,
    budgetMax: budgetMax,
  );
}

void main() {
  group('MockWeddingService', () {
    late MockWeddingService service;

    setUp(() => service = MockWeddingService());

    group('createWedding', () {
      test('returns wedding with caller as first partner', () async {
        final w = await _create(service, userId: 'user_1');
        expect(w.partnerIds, ['user_1']);
      });

      test('returns wedding with correct guest count and budget', () async {
        final w = await _create(service, guestCount: 150, budgetMin: 50000, budgetMax: 80000);
        expect(w.guestCount, 150);
        expect(w.budgetMin, 50000);
        expect(w.budgetMax, 80000);
      });

      test('generates a valid invite code', () async {
        final w = await _create(service);
        expect(InviteCodeGenerator.isValidFormat(w.inviteCode), isTrue);
      });

      test('generates unique IDs for multiple weddings', () async {
        final w1 = await _create(service, userId: 'u1');
        final w2 = await _create(service, userId: 'u2');
        expect(w1.id, isNot(equals(w2.id)));
      });

      test('generated invite codes are unique', () async {
        final codes = <String>{};
        for (var i = 0; i < 10; i++) {
          final w = await _create(service, userId: 'u$i');
          codes.add(w.inviteCode);
        }
        expect(codes.length, 10);
      });
    });

    group('joinWedding', () {
      test('adds second partner to partnerIds', () async {
        final created = await _create(service, userId: 'user_1');
        final joined = await service.joinWedding(created.inviteCode, userId: 'user_2');
        expect(joined.partnerIds, containsAll(['user_1', 'user_2']));
        expect(joined.hasBothPartners, isTrue);
      });

      test('returns the wedding with updated partnerIds', () async {
        final created = await _create(service, userId: 'user_1');
        final joined = await service.joinWedding(created.inviteCode, userId: 'user_2');
        expect(joined.id, created.id);
        expect(joined.inviteCode, created.inviteCode);
      });

      test('throws not-found for unknown invite code', () async {
        expect(
          () => service.joinWedding('WED-XXXX', userId: 'user_1'),
          throwsA(isA<WeddingException>().having((e) => e.code, 'code', 'not-found')),
        );
      });

      test('throws already-member when same user joins twice', () async {
        final created = await _create(service, userId: 'user_1');
        expect(
          () => service.joinWedding(created.inviteCode, userId: 'user_1'),
          throwsA(isA<WeddingException>().having((e) => e.code, 'code', 'already-member')),
        );
      });

      test('throws full when wedding already has two partners', () async {
        final created = await _create(service, userId: 'user_1');
        await service.joinWedding(created.inviteCode, userId: 'user_2');
        expect(
          () => service.joinWedding(created.inviteCode, userId: 'user_3'),
          throwsA(isA<WeddingException>().having((e) => e.code, 'code', 'full')),
        );
      });

      test('throws for invalid invite code format', () async {
        expect(
          () => service.joinWedding('INVALID', userId: 'user_1'),
          throwsA(isA<WeddingException>()),
        );
      });

      test('accepts lowercase invite code', () async {
        final created = await _create(service, userId: 'user_1');
        final joined = await service.joinWedding(
          created.inviteCode.toLowerCase(),
          userId: 'user_2',
        );
        expect(joined.partnerIds.length, 2);
      });
    });

    group('getWedding', () {
      test('retrieves a previously created wedding', () async {
        final created = await _create(service, userId: 'user_1');
        final retrieved = await service.getWedding(created.id);
        expect(retrieved.id, created.id);
      });

      test('throws not-found for unknown wedding ID', () async {
        expect(
          () => service.getWedding('unknown_id'),
          throwsA(isA<WeddingException>().having((e) => e.code, 'code', 'not-found')),
        );
      });
    });

    group('updateWedding', () {
      test('persists updated guest count', () async {
        final created = await _create(service, guestCount: 100);
        final updated = await service.updateWedding(created.id, guestCount: 200);
        expect(updated.guestCount, 200);
        expect(updated.id, created.id);
      });

      test('persists updated budget', () async {
        final created = await _create(service, budgetMin: 40000, budgetMax: 60000);
        final updated = await service.updateWedding(
          created.id,
          budgetMin: 50000,
          budgetMax: 90000,
        );
        expect(updated.budgetMin, 50000);
        expect(updated.budgetMax, 90000);
      });

      test('partial update does not change omitted fields', () async {
        final created = await _create(service, guestCount: 100, budgetMin: 40000);
        final updated = await service.updateWedding(created.id, guestCount: 150);
        expect(updated.budgetMin, 40000);
      });

      test('throws not-found for unknown wedding ID', () async {
        expect(
          () => service.updateWedding('unknown_id', guestCount: 100),
          throwsA(isA<WeddingException>().having((e) => e.code, 'code', 'not-found')),
        );
      });
    });
  });
}
