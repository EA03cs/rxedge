import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/l10n.dart';
import 'router/app_router.dart';
import 'theme/theme.dart';

/// RxEdge Root Application
class RxEdgeApp extends ConsumerWidget {
  const RxEdgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLocale = ref.watch(localeProvider);
    final activeThemeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);
    final isArabic = activeLocale.languageCode == 'ar';

    return MaterialApp.router(
      title: 'RxEdge',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: activeLocale,
      themeMode: activeThemeMode,
      theme: RxTheme.light(isArabic: isArabic),
      darkTheme: RxTheme.dark(isArabic: isArabic),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
