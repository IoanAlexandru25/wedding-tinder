import '../core/constants/categories.dart';

class Vendor {
  const Vendor({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.judet,
    required this.localitate,
    required this.priceMin,
    required this.priceMax,
    required this.priceUnit,
    required this.rating,
    required this.reviewCount,
    required this.photos,
    required this.tags,
    this.phone,
    this.website,
    this.instagram,
  });

  final String id;
  final String name;
  final VendorCategory category;
  final String description;
  final String judet;
  final String localitate;
  final int priceMin;
  final int priceMax;
  final String priceUnit;
  final double rating;
  final int reviewCount;
  final List<String> photos;
  final List<String> tags;
  final String? phone;
  final String? website;
  final String? instagram;

  factory Vendor.fromJson(Map<String, dynamic> json) {
    final categoryRaw = json['category'] as String?;
    final category = VendorCategoryX.tryParse(categoryRaw);
    if (category == null) {
      throw FormatException(
        'Unknown vendor category "$categoryRaw" for vendor ${json['id']}.',
      );
    }
    return Vendor(
      id: json['id'] as String,
      name: json['name'] as String,
      category: category,
      description: json['description'] as String,
      judet: json['judet'] as String,
      localitate: json['localitate'] as String,
      priceMin: (json['priceMin'] as num).toInt(),
      priceMax: (json['priceMax'] as num).toInt(),
      priceUnit: json['priceUnit'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      photos: (json['photos'] as List).cast<String>(),
      tags: (json['tags'] as List).cast<String>(),
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      instagram: json['instagram'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.jsonKey,
        'description': description,
        'judet': judet,
        'localitate': localitate,
        'priceMin': priceMin,
        'priceMax': priceMax,
        'priceUnit': priceUnit,
        'rating': rating,
        'reviewCount': reviewCount,
        'photos': photos,
        'tags': tags,
        if (phone != null) 'phone': phone,
        if (website != null) 'website': website,
        if (instagram != null) 'instagram': instagram,
      };

  Vendor copyWith({
    String? id,
    String? name,
    VendorCategory? category,
    String? description,
    String? judet,
    String? localitate,
    int? priceMin,
    int? priceMax,
    String? priceUnit,
    double? rating,
    int? reviewCount,
    List<String>? photos,
    List<String>? tags,
    String? phone,
    String? website,
    String? instagram,
  }) {
    return Vendor(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      judet: judet ?? this.judet,
      localitate: localitate ?? this.localitate,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      priceUnit: priceUnit ?? this.priceUnit,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      photos: photos ?? this.photos,
      tags: tags ?? this.tags,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      instagram: instagram ?? this.instagram,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Vendor && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
