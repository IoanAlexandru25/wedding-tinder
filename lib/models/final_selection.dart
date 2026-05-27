import '../core/constants/categories.dart';

class FinalSelection {
  const FinalSelection({
    required this.vendorId,
    required this.category,
    required this.confirmedAt,
    this.customPrice,
    this.notes,
  });

  final String vendorId;
  final VendorCategory category;
  final DateTime confirmedAt;
  final int? customPrice;
  final String? notes;

  FinalSelection copyWith({
    String? vendorId,
    VendorCategory? category,
    DateTime? confirmedAt,
    int? customPrice,
    String? notes,
    bool clearCustomPrice = false,
    bool clearNotes = false,
  }) {
    return FinalSelection(
      vendorId: vendorId ?? this.vendorId,
      category: category ?? this.category,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      customPrice: clearCustomPrice ? null : (customPrice ?? this.customPrice),
      notes: clearNotes ? null : (notes ?? this.notes),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinalSelection && other.vendorId == vendorId;

  @override
  int get hashCode => vendorId.hashCode;
}
