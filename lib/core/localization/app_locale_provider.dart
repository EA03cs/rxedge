import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxedge/l10n/app_localizations.dart';

/// Active Locale Provider (defaults to Arabic 'ar', supports 'en')
final localeProvider = StateProvider<Locale>((ref) {
  return const Locale('ar');
});

/// Theme Mode Provider (defaults to light as primary)
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.light;
});

/// Offline State Provider for testing / global state
final isOfflineProvider = StateProvider<bool>((ref) {
  return false;
});

/// Extension on BuildContext for quick access to AppLocalizations
extension LocalizedContextExtension on BuildContext {
  AppLocalizations get l10n {
    return AppLocalizations.of(this)!;
  }

  bool get isRtl {
    return Directionality.of(this) == TextDirection.rtl;
  }
}
