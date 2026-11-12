import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:rxedge/l10n/app_localizations.dart';
import '../storage/storage_initializer.dart';

/// Active Locale Provider (defaults to Arabic 'ar', supports 'en')
final localeProvider = StateProvider<Locale>((ref) {
  return Locale(StorageInitializer.readInitialLocaleCode(fallback: 'ar'));
});

/// Theme Mode Provider (persisted via StorageInitializer, defaults to light)
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return StorageInitializer.readInitialThemeMode(fallback: ThemeMode.light);
});

/// Offline State Provider for testing / global state
final isOfflineProvider = StateProvider<bool>((ref) {
  return false;
});

/// Extension on BuildContext for quick access to AppLocalizations and Directional Icons
extension LocalizedContextExtension on BuildContext {
  AppLocalizations get l10n {
    return AppLocalizations.of(this)!;
  }

  bool get isRtl {
    return Directionality.of(this) == TextDirection.rtl;
  }

  /// Forward navigation chevron: points Left in RTL (Arabic), Right in LTR
  IconData get chevronForward => isRtl ? LucideIcons.chevronLeft : LucideIcons.chevronRight;

  /// Back navigation chevron: points Right in RTL (Arabic), Left in LTR
  IconData get chevronBack => isRtl ? LucideIcons.chevronRight : LucideIcons.chevronLeft;

  /// Forward action arrow: points Left in RTL (Arabic), Right in LTR
  IconData get arrowForward => isRtl ? LucideIcons.arrowLeft : LucideIcons.arrowRight;

  /// Back action arrow: points Right in RTL (Arabic), Left in LTR
  IconData get arrowBack => isRtl ? LucideIcons.arrowRight : LucideIcons.arrowLeft;
}
