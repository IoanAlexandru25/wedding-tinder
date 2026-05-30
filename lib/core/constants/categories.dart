import 'package:flutter/widgets.dart';
import 'package:wedding_tinder/core/icons/phosphor_icons_thin.dart';

enum VendorCategory {
  restaurant,
  fotograf,
  dj,
  formatie,
  florarie,
  tort,
}

extension VendorCategoryX on VendorCategory {
  String get jsonKey {
    switch (this) {
      case VendorCategory.restaurant:
        return 'restaurant';
      case VendorCategory.fotograf:
        return 'fotograf';
      case VendorCategory.dj:
        return 'dj';
      case VendorCategory.formatie:
        return 'formatie';
      case VendorCategory.florarie:
        return 'florarie';
      case VendorCategory.tort:
        return 'tort';
    }
  }

  String get displayName {
    switch (this) {
      case VendorCategory.restaurant:
        return 'Restaurant';
      case VendorCategory.fotograf:
        return 'Photographer';
      case VendorCategory.dj:
        return 'DJ';
      case VendorCategory.formatie:
        return 'Band';
      case VendorCategory.florarie:
        return 'Florist';
      case VendorCategory.tort:
        return 'Bakery';
    }
  }

  String get pluralLabel {
    switch (this) {
      case VendorCategory.restaurant:
        return 'Restaurants';
      case VendorCategory.fotograf:
        return 'Photographers';
      case VendorCategory.dj:
        return 'DJ';
      case VendorCategory.formatie:
        return 'Bands';
      case VendorCategory.florarie:
        return 'Florists';
      case VendorCategory.tort:
        return 'Bakeries';
    }
  }

  IconData get icon {
    switch (this) {
      case VendorCategory.restaurant:
        return PhosphorIconsThin.wine;
      case VendorCategory.fotograf:
        return PhosphorIconsThin.camera;
      case VendorCategory.dj:
        return PhosphorIconsThin.musicNotes;
      case VendorCategory.formatie:
        return PhosphorIconsThin.guitar;
      case VendorCategory.florarie:
        return PhosphorIconsThin.flower;
      case VendorCategory.tort:
        return PhosphorIconsThin.cake;
    }
  }

  static VendorCategory? tryParse(String? raw) {
    if (raw == null) return null;
    for (final c in VendorCategory.values) {
      if (c.jsonKey == raw) return c;
    }
    return null;
  }
}
