import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_tinder/models/wedding.dart';

void main() {
  group('Wedding', () {
    final dateStart = DateTime.utc(2025, 6, 14);
    final dateEnd = DateTime.utc(2025, 6, 15);
    final createdAt = DateTime.utc(2024, 1, 1);

    Map<String, dynamic> baseJson() => {
          'id': 'wed_01',
          'inviteCode': 'WED-ABCD',
          'partnerIds': ['user_1', 'user_2'],
          'weddingDateStart': dateStart.millisecondsSinceEpoch,
          'weddingDateEnd': dateEnd.millisecondsSinceEpoch,
          'guestCount': 120,
          'budgetMin': 30000,
          'budgetMax': 50000,
          'createdAt': createdAt.millisecondsSinceEpoch,
        };

    test('fromJson parses all fields', () {
      final w = Wedding.fromJson(baseJson());
      expect(w.id, 'wed_01');
      expect(w.inviteCode, 'WED-ABCD');
      expect(w.partnerIds, ['user_1', 'user_2']);
      expect(w.guestCount, 120);
      expect(w.budgetMin, 30000);
      expect(w.budgetMax, 50000);
      expect(w.weddingDateStart.millisecondsSinceEpoch,
          dateStart.millisecondsSinceEpoch);
      expect(w.weddingDateEnd.millisecondsSinceEpoch,
          dateEnd.millisecondsSinceEpoch);
      expect(w.createdAt.millisecondsSinceEpoch, createdAt.millisecondsSinceEpoch);
    });

    test('toJson round-trips through fromJson', () {
      final w = Wedding.fromJson(baseJson());
      final w2 = Wedding.fromJson(w.toJson());
      expect(w2.id, w.id);
      expect(w2.inviteCode, w.inviteCode);
      expect(w2.guestCount, w.guestCount);
      expect(w2.budgetMin, w.budgetMin);
      expect(w2.partnerIds, w.partnerIds);
      expect(w2.weddingDateStart.millisecondsSinceEpoch,
          w.weddingDateStart.millisecondsSinceEpoch);
    });

    group('hasBothPartners', () {
      test('true when exactly 2 partnerIds', () {
        final w = Wedding.fromJson(baseJson());
        expect(w.hasBothPartners, isTrue);
      });

      test('false when only 1 partnerId', () {
        final w = Wedding.fromJson({...baseJson(), 'partnerIds': ['user_1']});
        expect(w.hasBothPartners, isFalse);
      });

      test('false when partnerIds is empty', () {
        final w = Wedding.fromJson({...baseJson(), 'partnerIds': <String>[]});
        expect(w.hasBothPartners, isFalse);
      });

      test('true when 3 or more partnerIds', () {
        final w = Wedding.fromJson({
          ...baseJson(),
          'partnerIds': ['user_1', 'user_2', 'user_3'],
        });
        expect(w.hasBothPartners, isTrue);
      });
    });

    test('copyWith updates only specified field', () {
      final w = Wedding.fromJson(baseJson());
      final copy = w.copyWith(guestCount: 200);
      expect(copy.guestCount, 200);
      expect(copy.id, w.id);
      expect(copy.inviteCode, w.inviteCode);
      expect(copy.budgetMin, w.budgetMin);
    });

    test('copyWith with no args is equivalent', () {
      final w = Wedding.fromJson(baseJson());
      expect(w.copyWith().id, w.id);
      expect(w.copyWith().guestCount, w.guestCount);
    });

    test('equality is by id', () {
      final w1 = Wedding.fromJson(baseJson());
      final w2 = w1.copyWith(guestCount: 999);
      expect(w1, equals(w2));
      expect(w1.hashCode, w2.hashCode);
    });

    test('different ids are not equal', () {
      final w1 = Wedding.fromJson(baseJson());
      final w2 = w1.copyWith(id: 'wed_02');
      expect(w1, isNot(equals(w2)));
    });
  });
}
