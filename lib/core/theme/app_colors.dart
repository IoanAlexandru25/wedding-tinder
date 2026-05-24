import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Brand
  static const Color wine = Color(0xFF7C2D3A);
  static const Color peach = Color(0xFFE8B4A0);
  static const Color brass = Color(0xFFC9A961);

  // Semantic
  static const Color primary = wine;
  static const Color secondary = peach;
  static const Color accent = brass;

  static const Color background = Color(0xFFFAF6F1);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF2EBE3);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1A1416);
  static const Color onSurfaceMuted = Color(0xFF6B5A60);

  static const Color success = Color(0xFF5C7F5E);
  static const Color error = Color(0xFFB5483F);

  // Neutrals (warm grays)
  static const Color border = Color(0xFFE5DED5);
  static const Color borderStrong = Color(0xFFCBC0B5);
  static const Color disabled = Color(0xFFB8ADA4);

  /// 80% black for photo-bottom gradient — tuned for white text legibility.
  static const Color overlayDark = Color(0xCC000000);

  /// Tinted wine shadow — gives cards "object in space" feel vs. flat gray.
  static Color get wineShadow => wine.withValues(alpha: 0.08);
}
