import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.wine,
    required this.peach,
    required this.brass,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.onPrimary,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.success,
    required this.error,
    required this.border,
    required this.borderStrong,
    required this.disabled,
    required this.overlayDark,
    required this.navBarBackground,
    required this.navBarTabPill,
    required this.navBarContent,
    required this.navBarActiveContent,
  });

  final Color wine;
  final Color peach;
  final Color brass;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color onPrimary;
  final Color onSurface;
  final Color onSurfaceMuted;
  final Color success;
  final Color error;
  final Color border;
  final Color borderStrong;
  final Color disabled;
  final Color overlayDark;
  final Color navBarBackground;
  final Color navBarTabPill;
  final Color navBarContent;
  final Color navBarActiveContent;

  Color get primary => wine;
  Color get secondary => peach;
  Color get accent => brass;
  Color get wineShadow => wine.withValues(alpha: 0.08);

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  // ── Palettes ─────────────────────────────────────────────────────────────

  static const AppColors rose = AppColors(
    wine: Color(0xFF7C2D3A),
    peach: Color(0xFFE8B4A0),
    brass: Color(0xFFC9A961),
    background: Color(0xFFFAF6F1),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF2EBE3),
    onPrimary: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1A1416),
    onSurfaceMuted: Color(0xFF6B5A60),
    success: Color(0xFF5C7F5E),
    error: Color(0xFFB5483F),
    border: Color(0xFFE5DED5),
    borderStrong: Color(0xFFCBC0B5),
    disabled: Color(0xFFB8ADA4),
    overlayDark: Color(0xCC000000),
    navBarBackground: Color(0xFF1A1416),
    navBarTabPill: Color(0xFFFAF6F1),
    navBarContent: Color(0xFFFAF6F1),
    navBarActiveContent: Color(0xFF1A1416),
  );

  static const AppColors midnight = AppColors(
    wine: Color(0xFF9B7AB3),
    peach: Color(0xFFC4B0D0),
    brass: Color(0xFFC8A84B),
    background: Color(0xFF141018),
    surface: Color(0xFF1E1A24),
    surfaceVariant: Color(0xFF252030),
    onPrimary: Color(0xFFFFFFFF),
    onSurface: Color(0xFFF0EBF5),
    onSurfaceMuted: Color(0xFF9B8FA8),
    success: Color(0xFF7DAF80),
    error: Color(0xFFD47070),
    border: Color(0xFF332E3C),
    borderStrong: Color(0xFF4A4358),
    disabled: Color(0xFF5A5465),
    overlayDark: Color(0xCC000000),
    navBarBackground: Color(0xFF1E1A24),
    navBarTabPill: Color(0xFF332E3C),
    navBarContent: Color(0xFFF0EBF5),
    navBarActiveContent: Color(0xFFF0EBF5),
  );

  static const AppColors sage = AppColors(
    wine: Color(0xFF3D6B4F),
    peach: Color(0xFFE8C4B8),
    brass: Color(0xFFC8A84B),
    background: Color(0xFFF4F7F2),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFE8F0E6),
    onPrimary: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1A2518),
    onSurfaceMuted: Color(0xFF5A6B56),
    success: Color(0xFF4A8050),
    error: Color(0xFFB5483F),
    border: Color(0xFFD8E6D2),
    borderStrong: Color(0xFFC0D4B8),
    disabled: Color(0xFFADB8A8),
    overlayDark: Color(0xCC000000),
    navBarBackground: Color(0xFF1A2518),
    navBarTabPill: Color(0xFFF4F7F2),
    navBarContent: Color(0xFFF4F7F2),
    navBarActiveContent: Color(0xFF1A2518),
  );

  // ── ThemeExtension ────────────────────────────────────────────────────────

  @override
  AppColors copyWith({
    Color? wine,
    Color? peach,
    Color? brass,
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? onPrimary,
    Color? onSurface,
    Color? onSurfaceMuted,
    Color? success,
    Color? error,
    Color? border,
    Color? borderStrong,
    Color? disabled,
    Color? overlayDark,
    Color? navBarBackground,
    Color? navBarTabPill,
    Color? navBarContent,
    Color? navBarActiveContent,
  }) =>
      AppColors(
        wine: wine ?? this.wine,
        peach: peach ?? this.peach,
        brass: brass ?? this.brass,
        background: background ?? this.background,
        surface: surface ?? this.surface,
        surfaceVariant: surfaceVariant ?? this.surfaceVariant,
        onPrimary: onPrimary ?? this.onPrimary,
        onSurface: onSurface ?? this.onSurface,
        onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
        success: success ?? this.success,
        error: error ?? this.error,
        border: border ?? this.border,
        borderStrong: borderStrong ?? this.borderStrong,
        disabled: disabled ?? this.disabled,
        overlayDark: overlayDark ?? this.overlayDark,
        navBarBackground: navBarBackground ?? this.navBarBackground,
        navBarTabPill: navBarTabPill ?? this.navBarTabPill,
        navBarContent: navBarContent ?? this.navBarContent,
        navBarActiveContent: navBarActiveContent ?? this.navBarActiveContent,
      );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      wine: Color.lerp(wine, other.wine, t)!,
      peach: Color.lerp(peach, other.peach, t)!,
      brass: Color.lerp(brass, other.brass, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceMuted: Color.lerp(onSurfaceMuted, other.onSurfaceMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      overlayDark: Color.lerp(overlayDark, other.overlayDark, t)!,
      navBarBackground: Color.lerp(navBarBackground, other.navBarBackground, t)!,
      navBarTabPill: Color.lerp(navBarTabPill, other.navBarTabPill, t)!,
      navBarContent: Color.lerp(navBarContent, other.navBarContent, t)!,
      navBarActiveContent: Color.lerp(navBarActiveContent, other.navBarActiveContent, t)!,
    );
  }
}
