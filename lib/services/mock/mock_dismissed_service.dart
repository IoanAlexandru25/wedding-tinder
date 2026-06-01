import '../dismissed_service.dart';

class MockDismissedService implements DismissedService {
  final _store = <String, List<String>>{};

  @override
  Future<List<String>> listDismissed(String weddingId) async {
    return List.unmodifiable(_store[weddingId] ?? const []);
  }

  @override
  Future<void> dismiss(String weddingId, String vendorId) async {
    final list = _store.putIfAbsent(weddingId, () => []);
    if (list.contains(vendorId)) return;
    list.add(vendorId);
  }
}
