import '../../core/utils/invite_code_generator.dart';
import '../../models/wedding.dart';
import '../service_exception.dart';
import '../wedding_service.dart';

class MockWeddingService implements WeddingService {
  final Map<String, Wedding> _store = {};
  final Map<String, String> _codeToId = {};
  int _counter = 0;

  @override
  Future<Wedding> createWedding({
    required String userId,
    required DateTime start,
    required DateTime end,
    required int guestCount,
    required int budgetMin,
    required int budgetMax,
  }) async {
    final id = 'wed_${++_counter}';
    String code;
    do {
      code = InviteCodeGenerator.generate();
    } while (_codeToId.containsKey(code));

    final wedding = Wedding(
      id: id,
      inviteCode: code,
      partnerIds: [userId],
      weddingDateStart: start,
      weddingDateEnd: end,
      guestCount: guestCount,
      budgetMin: budgetMin,
      budgetMax: budgetMax,
      createdAt: DateTime.now(),
    );
    _store[id] = wedding;
    _codeToId[code] = id;
    return wedding;
  }

  @override
  Future<Wedding> joinWedding(String inviteCode, {required String userId}) async {
    if (!InviteCodeGenerator.isValidFormat(inviteCode)) {
      throw const WeddingException('invalid-code', 'Invite code format is invalid.');
    }
    final normalized = inviteCode.trim().toUpperCase();
    final id = _codeToId[normalized];
    if (id == null) {
      throw const WeddingException('not-found', 'No wedding found for that invite code.');
    }
    final wedding = _store[id]!;
    if (wedding.partnerIds.contains(userId)) {
      throw const WeddingException('already-member', 'You are already a member of this wedding.');
    }
    if (wedding.hasBothPartners) {
      throw const WeddingException('full', 'This wedding already has two partners.');
    }
    final updated = wedding.copyWith(partnerIds: [...wedding.partnerIds, userId]);
    _store[id] = updated;
    return updated;
  }

  @override
  Future<Wedding> getWedding(String weddingId) async {
    final wedding = _store[weddingId];
    if (wedding == null) {
      throw const WeddingException('not-found', 'Wedding not found.');
    }
    return wedding;
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
    final wedding = _store[weddingId];
    if (wedding == null) {
      throw const WeddingException('not-found', 'Wedding not found.');
    }
    final updated = wedding.copyWith(
      weddingDateStart: start,
      weddingDateEnd: end,
      guestCount: guestCount,
      budgetMin: budgetMin,
      budgetMax: budgetMax,
    );
    _store[weddingId] = updated;
    return updated;
  }
}
