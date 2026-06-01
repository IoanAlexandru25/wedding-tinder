import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_theme_variant.dart';
import 'app_colors.dart';
import 'app_radii.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData build(AppThemeVariant variant) {
    final c = switch (variant) {
      AppThemeVariant.rose => AppColors.rose,
      AppThemeVariant.midnight => AppColors.midnight,
      AppThemeVariant.sage => AppColors.sage,
    };
    final brightness =
        variant == AppThemeVariant.midnight ? Brightness.dark : Brightness.light;
    final overlayStyle = brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      secondary: c.secondary,
      onSecondary: c.onSurface,
      tertiary: c.accent,
      onTertiary: c.onSurface,
      error: c.error,
      onError: c.onPrimary,
      surface: c.surface,
      onSurface: c.onSurface,
      surfaceContainerHighest: c.surfaceVariant,
      onSurfaceVariant: c.onSurfaceMuted,
      outline: c.border,
      outlineVariant: c.borderStrong,
    );

    final textTheme = AppTypography.textThemeWith(c);

    return ThemeData(
      useMaterial3: true,
      extensions: [c],
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      textTheme: textTheme,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineSmall.copyWith(color: c.onSurface),
        systemOverlayStyle: overlayStyle,
      ),
      iconTheme: IconThemeData(
        color: c.onSurface,
        size: 22,
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.cardAll,
          side: BorderSide(color: c.border, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: c.border,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 0,
          vertical: AppSpacing.md,
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(color: c.onSurfaceMuted),
        floatingLabelStyle: AppTypography.labelSmall.copyWith(
          color: c.primary,
          letterSpacing: 1.0,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: c.borderStrong),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: c.borderStrong),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: c.primary, width: 1.5),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: c.error),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: c.error, width: 1.5),
        ),
        errorStyle: AppTypography.labelSmall.copyWith(color: c.error),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.onSurface,
        contentTextStyle:
            AppTypography.bodyMedium.copyWith(color: c.background),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: c.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.xl),
          ),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: _FadeSlidePageTransitions(),
          TargetPlatform.android: _FadeSlidePageTransitions(),
          TargetPlatform.macOS: _FadeSlidePageTransitions(),
        },
      ),
    ).copyWith(
      textTheme: GoogleFonts.interTextTheme(textTheme),
    );
  }
}

class _FadeSlidePageTransitions extends PageTransitionsBuilder {
  const _FadeSlidePageTransitions();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.03, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
