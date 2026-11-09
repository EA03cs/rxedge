import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/localization/app_locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme.dart';
import 'l10n/app_localizations.dart';

/// RxEdge Root Application
class RxEdgeApp extends ConsumerWidget {
  const RxEdgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLocale = ref.watch(localeProvider);
    final activeThemeMode = ref.watch(themeModeProvider);
    final isArabic = activeLocale.languageCode == 'ar';

    return MaterialApp.router(
      title: 'RxEdge',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      locale: activeLocale,
      themeMode: activeThemeMode,
      theme: RxTheme.light(isArabic: isArabic),
      darkTheme: RxTheme.dark(isArabic: isArabic),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
