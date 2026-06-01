abstract class DismissedService {
  /// Returns the list of vendor IDs that have been dismissed (left-swiped)
  /// for this wedding. Used to exclude them from the swipe deck on startup.
  Future<List<String>> listDismissed(String weddingId);

  /// Marks a vendor as dismissed for this wedding.
  ///
  /// Idempotent — calling with an already-dismissed vendorId is a no-op.
  /// [weddingId] is ignored by the real API (server derives it from the
  /// token + path), but required by the mock.
  Future<void> dismiss(String weddingId, String vendorId);
}
