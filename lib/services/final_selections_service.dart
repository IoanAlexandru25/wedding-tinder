import '../core/constants/categories.dart';
import '../models/final_selection.dart';

abstract class FinalSelectionsService {
  Future<List<FinalSelection>> listFinalSelections(String weddingId);

  // Confirms a vendor as the final selection for its category.
  // Enforces one-per-category: replaces any existing selection for the same
  // category. The real backend also validates the vendor is in favorites.
  Future<FinalSelection> confirm(
    String weddingId, {
    required String vendorId,
    required VendorCategory category,
    int? customPrice,
    String? notes,
  });

  // Updates the negotiated price for a confirmed vendor.
  // Pass null to clear a previously set price.
  Future<FinalSelection> updateCustomPrice(
    String weddingId,
    String vendorId,
    int? price,
  );

  // Updates free-form notes for a confirmed vendor.
  // Pass null or empty string to clear notes.
  Future<FinalSelection> updateNotes(
    String weddingId,
    String vendorId,
    String? notes,
  );

  Future<void> remove(String weddingId, String vendorId);
}
