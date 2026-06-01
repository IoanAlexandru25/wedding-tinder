import '../../core/constants/categories.dart';
import '../../models/final_selection.dart';
import '../final_selections_service.dart';
import '../service_exception.dart';

class MockFinalSelectionsService implements FinalSelectionsService {
  final Map<String, List<FinalSelection>> _store = {};

  @override
  Future<List<FinalSelection>> listFinalSelections(String weddingId) async {
    return List.unmodifiable(_store[weddingId] ?? const []);
  }

  @override
  Future<FinalSelection> confirm(
    String weddingId, {
    required String vendorId,
    required VendorCategory category,
    int? customPrice,
    String? notes,
  }) async {
    final list = _store.putIfAbsent(weddingId, () => []);
    list.removeWhere((s) => s.category == category);
    final selection = FinalSelection(
      vendorId: vendorId,
      category: category,
      confirmedAt: DateTime.now(),
      customPrice: customPrice,
      notes: notes,
    );
    list.add(selection);
    return selection;
  }

  @override
  Future<FinalSelection> updateCustomPrice(
    String weddingId,
    String vendorId,
    int? price,
  ) async {
    final list = _store[weddingId] ?? [];
    final index = list.indexWhere((s) => s.vendorId == vendorId);
    if (index == -1) {
      throw const SelectionException('not-found', 'Final selection not found.');
    }
    final updated = list[index].copyWith(
      customPrice: price,
      clearCustomPrice: price == null,
    );
    list[index] = updated;
    return updated;
  }

  @override
  Future<FinalSelection> updateNotes(
    String weddingId,
    String vendorId,
    String? notes,
  ) async {
    final list = _store[weddingId] ?? [];
    final index = list.indexWhere((s) => s.vendorId == vendorId);
    if (index == -1) {
      throw const SelectionException('not-found', 'Final selection not found.');
    }
    final trimmed = notes?.trim();
    final shouldClear = trimmed == null || trimmed.isEmpty;
    final updated = list[index].copyWith(
      notes: shouldClear ? null : trimmed,
      clearNotes: shouldClear,
    );
    list[index] = updated;
    return updated;
  }

  @override
  Future<void> remove(String weddingId, String vendorId) async {
    _store[weddingId]?.removeWhere((s) => s.vendorId == vendorId);
  }
}
