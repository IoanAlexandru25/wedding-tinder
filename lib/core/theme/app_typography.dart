import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTypography {
  const AppTypography._();

  static TextStyle get displayLarge => GoogleFonts.cormorantGaramond(
        fontSize: 56,
        height: 1.0,
        letterSpacing: -1.1,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get displayMedium => GoogleFonts.cormorantGaramond(
        fontSize: 44,
        height: 1.02,
        letterSpacing: -0.8,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get displaySmall => GoogleFonts.cormorantGaramond(
        fontSize: 34,
        height: 1.05,
        letterSpacing: -0.5,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get headlineLarge => GoogleFonts.cormorantGaramond(
        fontSize: 28,
        height: 1.1,
        letterSpacing: -0.3,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get headlineMedium => GoogleFonts.cormorantGaramond(
        fontSize: 22,
        height: 1.15,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get headlineSmall => GoogleFonts.cormorantGaramond(
        fontSize: 18,
        height: 1.2,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 17,
        height: 1.3,
        letterSpacing: -0.1,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 15,
        height: 1.35,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleSmall => GoogleFonts.inter(
        fontSize: 13,
        height: 1.35,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 13,
        height: 1.5,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 15,
        height: 1.2,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 13,
        height: 1.3,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        height: 1.3,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get overline => GoogleFonts.inter(
        fontSize: 11,
        height: 1.4,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.6,
      );

  static TextStyle get displayItalic => GoogleFonts.cormorantGaramond(
        fontSize: 56,
        height: 1.0,
        letterSpacing: -1.1,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      );

  static TextStyle get headlineItalic => GoogleFonts.cormorantGaramond(
        fontSize: 28,
        height: 1.1,
        letterSpacing: -0.3,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
      );

  static TextTheme get textTheme => textThemeWith(AppColors.rose);

  static TextTheme textThemeWith(AppColors c) => TextTheme(
        displayLarge: GoogleFonts.cormorantGaramond(
          fontSize: 56, height: 1.0, letterSpacing: -1.1,
          fontWeight: FontWeight.w400, color: c.onSurface,
        ),
        displayMedium: GoogleFonts.cormorantGaramond(
          fontSize: 44, height: 1.02, letterSpacing: -0.8,
          fontWeight: FontWeight.w400, color: c.onSurface,
        ),
        displaySmall: GoogleFonts.cormorantGaramond(
          fontSize: 34, height: 1.05, letterSpacing: -0.5,
          fontWeight: FontWeight.w400, color: c.onSurface,
        ),
        headlineLarge: GoogleFonts.cormorantGaramond(
          fontSize: 28, height: 1.1, letterSpacing: -0.3,
          fontWeight: FontWeight.w500, color: c.onSurface,
        ),
        headlineMedium: GoogleFonts.cormorantGaramond(
          fontSize: 22, height: 1.15,
          fontWeight: FontWeight.w500, color: c.onSurface,
        ),
        headlineSmall: GoogleFonts.cormorantGaramond(
          fontSize: 18, height: 1.2,
          fontWeight: FontWeight.w500, color: c.onSurface,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 17, height: 1.3, letterSpacing: -0.1,
          fontWeight: FontWeight.w600, color: c.onSurface,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 15, height: 1.35,
          fontWeight: FontWeight.w600, color: c.onSurface,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 13, height: 1.35,
          fontWeight: FontWeight.w600, color: c.onSurface,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16, height: 1.5,
          fontWeight: FontWeight.w400, color: c.onSurface,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, height: 1.5,
          fontWeight: FontWeight.w400, color: c.onSurface,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 13, height: 1.5,
          fontWeight: FontWeight.w400, color: c.onSurfaceMuted,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 15, height: 1.2, letterSpacing: 0.2,
          fontWeight: FontWeight.w500, color: c.onSurface,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 13, height: 1.3,
          fontWeight: FontWeight.w500, color: c.onSurface,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11, height: 1.3,
          fontWeight: FontWeight.w500, color: c.onSurfaceMuted,
        ),
      );
}
