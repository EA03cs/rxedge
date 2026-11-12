import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// RxEdge Design System Typography Tokens
///
/// Fonts:
/// - Inter for Latin / English
/// - IBM Plex Sans Arabic for Arabic
///
/// Hierarchy:
/// - Tight, confident headings with negative letter-spacing
/// - Comfortable body line-height (1.45)
/// - Minimum body size of 14sp for outdoor / mobile legibility
abstract final class RxTypography {
  static const String fontInter = 'Inter';
  static const String fontArabic = 'IBMPlexSansArabic';

  static TextTheme createTextTheme(Color primaryColor, Color secondaryColor, {bool isArabic = false}) {
    TextStyle base(double size, FontWeight weight, double height, {double? letterSpacing}) {
      if (isArabic) {
        return GoogleFonts.ibmPlexSansArabic(
          fontSize: size,
          fontWeight: weight,
          height: (height * 1.06).clamp(1.35, 1.60), // Breathing room for Arabic ascenders/descenders
          color: primaryColor,
          letterSpacing: 0, // Arabic does not use letter spacing
          fontFeatures: const [FontFeature.tabularFigures()],
        );
      }
      return GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: primaryColor,
        letterSpacing: letterSpacing,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
    }

    return TextTheme(
      // Display / H1
      displayLarge: base(28.0, FontWeight.w600, 1.25, letterSpacing: -0.6),
      displayMedium: base(24.0, FontWeight.w600, 1.28, letterSpacing: -0.4),
      displaySmall: base(20.0, FontWeight.w600, 1.30, letterSpacing: -0.3),

      // Headings
      headlineLarge: base(22.0, FontWeight.w600, 1.30, letterSpacing: -0.3),
      headlineMedium: base(18.0, FontWeight.w600, 1.35, letterSpacing: -0.2),
      headlineSmall: base(16.0, FontWeight.w600, 1.40),

      // Subtitles / Titles
      titleLarge: base(18.0, FontWeight.w600, 1.35),
      titleMedium: base(16.0, FontWeight.w500, 1.45),
      titleSmall: base(14.0, FontWeight.w600, 1.45),

      // Body (min 14sp, line height 1.45)
      bodyLarge: base(16.0, FontWeight.w400, 1.45),
      bodyMedium: base(14.0, FontWeight.w400, 1.45),
      bodySmall: base(13.0, FontWeight.w400, 1.45),

      // Labels & Buttons
      labelLarge: base(14.0, FontWeight.w600, 1.40), // Primary buttons
      labelMedium: base(12.0, FontWeight.w500, 1.40), // Badges & tabs
      labelSmall: base(11.0, FontWeight.w500, 1.35),
    );
  }
}
