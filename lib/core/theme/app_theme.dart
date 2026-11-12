import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_radii.dart';
import 'app_shadows.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// RxEdge Design System Theme Factory
abstract final class RxTheme {
  /// Build Light ThemeData
  static ThemeData light({bool isArabic = false}) {
    const colors = RxColors.light;
    final textTheme = RxTypography.createTextTheme(
      colors.textPrimary,
      colors.textSecondary,
      isArabic: isArabic,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: colors.primary,
      scaffoldBackgroundColor: colors.background,
      cardColor: colors.surface,
      dividerColor: colors.border,
      splashFactory: InkRipple.splashFactory,

      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: colors.primary,
        onPrimary: Colors.white,
        primaryContainer: colors.primarySoft,
        onPrimaryContainer: colors.primary,
        secondary: colors.textSecondary,
        onSecondary: Colors.white,
        secondaryContainer: colors.surfaceMuted,
        onSecondaryContainer: colors.textPrimary,
        tertiary: colors.accent,
        onTertiary: Colors.white,
        tertiaryContainer: colors.accentSoft,
        onTertiaryContainer: colors.accent,
        error: colors.error,
        onError: Colors.white,
        errorContainer: colors.errorSoft,
        onErrorContainer: colors.error,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        surfaceContainerHighest: colors.surfaceMuted,
        outline: colors.border,
        outlineVariant: colors.border,
      ),

      textTheme: textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: colors.background,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),

      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: RxRadii.borderCard,
          side: BorderSide(
            color: colors.border,
            width: RxShadows.hairlineBorderWidth,
          ),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: RxShadows.hairlineBorderWidth,
        space: RxShadows.hairlineBorderWidth,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: RxSpacing.s16,
          vertical: RxSpacing.s12,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colors.textTertiary,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colors.textSecondary,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: RxRadii.borderInput,
          borderSide: BorderSide(color: colors.border, width: RxShadows.hairlineBorderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: RxRadii.borderInput,
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: RxRadii.borderInput,
          borderSide: BorderSide(color: colors.error, width: RxShadows.hairlineBorderWidth),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: RxRadii.borderInput,
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
        errorStyle: textTheme.bodySmall?.copyWith(
          color: colors.error,
          fontSize: 12.0,
        ),
      ),

      extensions: const <ThemeExtension<dynamic>>[
        RxColors.light,
      ],
    );
  }

  /// Build Dark ThemeData
  static ThemeData dark({bool isArabic = false}) {
    const colors = RxColors.dark;
    final textTheme = RxTypography.createTextTheme(
      colors.textPrimary,
      colors.textSecondary,
      isArabic: isArabic,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: colors.primary,
      scaffoldBackgroundColor: colors.background,
      cardColor: colors.surface,
      dividerColor: colors.border,
      splashFactory: InkRipple.splashFactory,

      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: colors.primary,
        onPrimary: const Color(0xFF0C1117),
        primaryContainer: colors.primarySoft,
        onPrimaryContainer: colors.primary,
        secondary: colors.textSecondary,
        onSecondary: colors.background,
        secondaryContainer: colors.surfaceMuted,
        onSecondaryContainer: colors.textPrimary,
        tertiary: colors.accent,
        onTertiary: const Color(0xFF0C1117),
        tertiaryContainer: colors.accentSoft,
        onTertiaryContainer: colors.accent,
        error: colors.error,
        onError: Colors.white,
        errorContainer: colors.errorSoft,
        onErrorContainer: colors.error,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        surfaceContainerHighest: colors.surfaceMuted,
        outline: colors.border,
        outlineVariant: colors.border,
      ),

      textTheme: textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: colors.background,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),

      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: RxRadii.borderCard,
          side: BorderSide(
            color: colors.border,
            width: RxShadows.hairlineBorderWidth,
          ),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: RxShadows.hairlineBorderWidth,
        space: RxShadows.hairlineBorderWidth,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: RxSpacing.s16,
          vertical: RxSpacing.s12,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colors.textTertiary,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colors.textSecondary,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: RxRadii.borderInput,
          borderSide: BorderSide(color: colors.border, width: RxShadows.hairlineBorderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: RxRadii.borderInput,
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: RxRadii.borderInput,
          borderSide: BorderSide(color: colors.error, width: RxShadows.hairlineBorderWidth),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: RxRadii.borderInput,
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
        errorStyle: textTheme.bodySmall?.copyWith(
          color: colors.error,
          fontSize: 12.0,
        ),
      ),

      extensions: const <ThemeExtension<dynamic>>[
        RxColors.dark,
      ],
    );
  }
}
