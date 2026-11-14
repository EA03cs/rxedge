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

  /// Light Color Tokens (Navy & Ice Blue .2 - Corporate Clinical Palette)
  static const light = RxColors(
    background: Color(0xFFF2F6F9), // Ice Light Clinical Canvas
    surface: Color(0xFFFFFFFF), // Pure White card/list surfaces
    surfaceMuted: Color(0xFFE8EFF5), // Muted Ice Blue for grouped headers & chips
    border: Color(0xFFDCE6ED), // Crisp 1px Ice Blue separation
    textPrimary: Color(0xFF1D2935), // Deep Charcoal Navy text
    textSecondary: Color(0xFF4B6173), // Medium Slate Navy metadata
    textTertiary: Color(0xFF889CAE), // Muted Ice Slate captions & subtle hints
    primary: Color(0xFF183B56), // Deep Corporate Medical Navy
    primaryPressed: Color(0xFF10273B),
    primarySoft: Color(0xFFE8EEF3),
    accent: Color(0xFFD97706), // Amber 600 - strictly for points, streaks, badges
    accentSoft: Color(0xFFFEF3C7),
    success: Color(0xFF16803D), // Emerald 700
    successSoft: Color(0xFFDCFCE7),
    warning: Color(0xFFB45309),
    warningSoft: Color(0xFFFEF3C7),
    error: Color(0xFFDC2626), // Red 600
    errorSoft: Color(0xFFFEE2E2),
    info: Color(0xFF39789A), // Secondary Ice/Steel Blue
    infoSoft: Color(0xFFEBF2F6),
  );

  /// Dark Color Tokens (Fallback / Mirrored to Light as Dark Mode is Disabled)
  static const dark = light;

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
