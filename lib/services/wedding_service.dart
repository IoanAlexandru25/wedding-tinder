import '../models/wedding.dart';

abstract class WeddingService {
  // userId is required by mock implementations; the real API derives it from
  // the Firebase ID token and ignores this parameter.
  Future<Wedding> createWedding({
    required String userId,
    required DateTime start,
    required DateTime end,
    required int guestCount,
    required int budgetMin,
    required int budgetMax,
  });

  // userId is required by mock implementations; the real API derives it from
  // the Firebase ID token.
  Future<Wedding> joinWedding(String inviteCode, {required String userId});

  Future<Wedding> getWedding(String weddingId);

  Future<Wedding> updateWedding(
    String weddingId, {
    DateTime? start,
    DateTime? end,
    int? guestCount,
    int? budgetMin,
    int? budgetMax,
  });
}
