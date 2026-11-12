import 'package:flutter/material.dart';

/// RxEdge Design System Color Palette
///
/// Follows strict flat design guidelines:
/// - 90% white / neutral dominance
/// - Deep teal primary for main actions, active states, and key data
/// - Amber accent strictly for rewards, streaks, and badges
/// - Semantic colors for status indication
class RxColors extends ThemeExtension<RxColors> {
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color primary;
  final Color primaryPressed;
  final Color primarySoft;
  final Color accent;
  final Color accentSoft;
  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;
  final Color error;
  final Color errorSoft;
  final Color info;
  final Color infoSoft;

  const RxColors({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.primary,
    required this.primaryPressed,
    required this.primarySoft,
    required this.accent,
    required this.accentSoft,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.error,
    required this.errorSoft,
    required this.info,
    required this.infoSoft,
  });

  /// Light Color Tokens (Precision Clinical Palette)
  static const light = RxColors(
    background: Color(0xFFF8FAFC), // Slate 50 clean clinical canvas
    surface: Color(0xFFFFFFFF), // Pure White card/list surfaces
    surfaceMuted: Color(0xFFF1F5F9), // Slate 100 grouped headers & chips
    border: Color(0xFFE2E8F0), // Slate 200 crisp 1px separation
    textPrimary: Color(0xFF0F172A), // Slate 900 high contrast clinical text
    textSecondary: Color(0xFF475569), // Slate 600 clinical metadata
    textTertiary: Color(0xFF94A3B8), // Slate 400 captions & subtle hints
    primary: Color(0xFF0C6264), // Precision Medical Deep Teal
    primaryPressed: Color(0xFF094E50),
    primarySoft: Color(0xFFE6F4F4),
    accent: Color(0xFFB45309), // Amber 700 - strictly for points, streaks, badges
    accentSoft: Color(0xFFFEF3C7),
    success: Color(0xFF15803D), // Emerald 700
    successSoft: Color(0xFFDCFCE7),
    warning: Color(0xFFC26A0A),
    warningSoft: Color(0xFFFEF3C7),
    error: Color(0xFFBE123C), // Rose 700
    errorSoft: Color(0xFFFFE4E6),
    info: Color(0xFF1D4ED8), // Blue 700
    infoSoft: Color(0xFFDBEAFE),
  );

  /// Dark Color Tokens (Clinical Night Palette)
  static const dark = RxColors(
    background: Color(0xFF0B0F17),
    surface: Color(0xFF111827),
    surfaceMuted: Color(0xFF1E293B),
    border: Color(0xFF2E3D52),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFF94A3B8),
    textTertiary: Color(0xFF64748B),
    primary: Color(0xFF2DD4BF),
    primaryPressed: Color(0xFF14B8A6),
    primarySoft: Color(0xFF132E2E),
    accent: Color(0xFFFBBF24),
    accentSoft: Color(0xFF3B2D14),
    success: Color(0xFF34D399),
    successSoft: Color(0xFF133827),
    warning: Color(0xFFF59E0B),
    warningSoft: Color(0xFF3A2B14),
    error: Color(0xFFFB7185),
    errorSoft: Color(0xFF3B181E),
    info: Color(0xFF60A5FA),
    infoSoft: Color(0xFF172B4D),
  );

  @override
  ThemeExtension<RxColors> copyWith({
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? primary,
    Color? primaryPressed,
    Color? primarySoft,
    Color? accent,
    Color? accentSoft,
    Color? success,
    Color? successSoft,
    Color? warning,
    Color? warningSoft,
    Color? error,
    Color? errorSoft,
    Color? info,
    Color? infoSoft,
  }) {
    return RxColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      primary: primary ?? this.primary,
      primaryPressed: primaryPressed ?? this.primaryPressed,
      primarySoft: primarySoft ?? this.primarySoft,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      success: success ?? this.success,
      successSoft: successSoft ?? this.successSoft,
      warning: warning ?? this.warning,
      warningSoft: warningSoft ?? this.warningSoft,
      error: error ?? this.error,
      errorSoft: errorSoft ?? this.errorSoft,
      info: info ?? this.info,
      infoSoft: infoSoft ?? this.infoSoft,
    );
  }

  @override
  ThemeExtension<RxColors> lerp(
    covariant ThemeExtension<RxColors>? other,
    double t,
  ) {
    if (other is! RxColors) return this;
    return RxColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryPressed: Color.lerp(primaryPressed, other.primaryPressed, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      success: Color.lerp(success, other.success, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorSoft: Color.lerp(errorSoft, other.errorSoft, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoSoft: Color.lerp(infoSoft, other.infoSoft, t)!,
    );
  }
}

/// Convenience context extension to easily access theme colors
extension RxColorsExtension on BuildContext {
  RxColors get rxColors {
    return Theme.of(this).extension<RxColors>() ?? RxColors.light;
  }
}
