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

  /// Light Color Tokens (Primary Palette)
  static const light = RxColors(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF6F7F9),
    border: Color(0xFFE7E9EE),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF5B6475),
    textTertiary: Color(0xFF8A93A3),
    primary: Color(0xFF0E6B6B),
    primaryPressed: Color(0xFF0A5555),
    primarySoft: Color(0xFFE7F2F2),
    accent: Color(0xFFD9930D),
    accentSoft: Color(0xFFFBF1DC),
    success: Color(0xFF168A4A),
    successSoft: Color(0xFFE5F4EB),
    warning: Color(0xFFC26A0A),
    warningSoft: Color(0xFFFBEBD9),
    error: Color(0xFFC93A3A),
    errorSoft: Color(0xFFFBE7E7),
    info: Color(0xFF2F5FD0),
    infoSoft: Color(0xFFE8EEFB),
  );

  /// Dark Color Tokens
  static const dark = RxColors(
    background: Color(0xFF0C1117),
    surface: Color(0xFF131A22),
    surfaceMuted: Color(0xFF19212B),
    border: Color(0xFF243040),
    textPrimary: Color(0xFFEAEEF3),
    textSecondary: Color(0xFFA3ADBB),
    textTertiary: Color(0xFF6E7B8E),
    primary: Color(0xFF3FB5B0),
    primaryPressed: Color(0xFF2E9C97),
    primarySoft: Color(0xFF173235),
    accent: Color(0xFFF2AC34),
    accentSoft: Color(0xFF362916),
    success: Color(0xFF34C77B),
    successSoft: Color(0xFF132E22),
    warning: Color(0xFFE58E2E),
    warningSoft: Color(0xFF352516),
    error: Color(0xFFE05353),
    errorSoft: Color(0xFF351C1C),
    info: Color(0xFF5487F5),
    infoSoft: Color(0xFF192942),
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
