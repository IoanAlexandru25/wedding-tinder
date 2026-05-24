import '../core/constants/categories.dart';

class Favorite {
  const Favorite({
    required this.vendorId,
    required this.category,
    required this.addedBy,
    required this.addedAt,
  });

  final String vendorId;
  final VendorCategory category;
  final String addedBy;
  final DateTime addedAt;

  factory Favorite.fromJson(Map<String, dynamic> json) {
    final category = VendorCategoryX.tryParse(json['category'] as String?);
    if (category == null) {
      throw FormatException(
        'Unknown category "${json['category']}" for favorite ${json['vendorId']}.',
      );
    }
    return Favorite(
      vendorId: json['vendorId'] as String,
      category: category,
      addedBy: json['addedBy'] as String,
      addedAt: DateTime.fromMillisecondsSinceEpoch(json['addedAt'] as int),
    );
  }

  Map<String, dynamic> toJson() => {
        'vendorId': vendorId,
        'category': category.jsonKey,
        'addedBy': addedBy,
        'addedAt': addedAt.millisecondsSinceEpoch,
      };

  Favorite copyWith({
    String? vendorId,
    VendorCategory? category,
    String? addedBy,
    DateTime? addedAt,
  }) {
    return Favorite(
      vendorId: vendorId ?? this.vendorId,
      category: category ?? this.category,
      addedBy: addedBy ?? this.addedBy,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Favorite && other.vendorId == vendorId;

  @override
  int get hashCode => vendorId.hashCode;
}
