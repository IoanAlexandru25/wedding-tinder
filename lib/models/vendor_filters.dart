import '../core/constants/categories.dart';

class VendorFilters {
  const VendorFilters({
    this.category,
    this.judet,
    this.query,
    this.priceMin,
    this.priceMax,
  });

  final VendorCategory? category;
  final String? judet;
  final String? query;
  final int? priceMin;
  final int? priceMax;

  bool get isEmpty =>
      category == null &&
      judet == null &&
      (query == null || query!.isEmpty) &&
      priceMin == null &&
      priceMax == null;

  VendorFilters copyWith({
    VendorCategory? category,
    String? judet,
    String? query,
    int? priceMin,
    int? priceMax,
  }) {
    return VendorFilters(
      category: category ?? this.category,
      judet: judet ?? this.judet,
      query: query ?? this.query,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
    );
  }

  VendorFilters clear({
    bool category = false,
    bool judet = false,
    bool query = false,
    bool price = false,
  }) {
    return VendorFilters(
      category: category ? null : this.category,
      judet: judet ? null : this.judet,
      query: query ? null : this.query,
      priceMin: price ? null : priceMin,
      priceMax: price ? null : priceMax,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VendorFilters &&
        other.category == category &&
        other.judet == judet &&
        other.query == query &&
        other.priceMin == priceMin &&
        other.priceMax == priceMax;
  }

  @override
  int get hashCode =>
      Object.hash(category, judet, query, priceMin, priceMax);
}
