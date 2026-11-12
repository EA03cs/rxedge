import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/socket_service.dart';
import '../core/services/sync_service.dart';
import '../core/storage/local_cache_service.dart';
import '../core/storage/storage_initializer.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/challenges/presentation/controllers/challenges_controller.dart';
import '../features/feedback/presentation/controllers/feedback_controller.dart';
import '../features/home/presentation/controllers/home_controller.dart';
import '../features/learn/presentation/controllers/learn_controller.dart';
import '../features/library/presentation/controllers/library_controller.dart';
import '../features/notifications/presentation/controllers/notifications_controller.dart';
import '../features/profile/presentation/controllers/profile_controller.dart';
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

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is AuthAuthenticated) {
        ref.read(socketServiceProvider).connectIfAuthenticated();
      } else if (next is AuthUnauthenticated) {
        ref.read(socketServiceProvider).disconnect();
      }
    });

    ref.listen<Locale>(localeProvider, (previous, next) {
      if (previous == null || previous.languageCode == next.languageCode) {
        return;
      }
      StorageInitializer.writePreference(
        StorageInitializer.prefLocaleKey,
        next.languageCode,
      );
      ref.read(localCacheServiceProvider).clear();

      if (ref.read(authControllerProvider) is AuthAuthenticated) {
        ref.invalidate(homeControllerProvider);
        ref.invalidate(learnControllerProvider);
        ref.invalidate(libraryControllerProvider);
        ref.invalidate(challengesControllerProvider);
        ref.invalidate(feedbackListControllerProvider);
        ref.invalidate(notificationsControllerProvider);
        ref.invalidate(profileControllerProvider);
      }
    });

    ref.listen<ThemeMode>(themeModeProvider, (previous, next) {
      if (previous == null || previous == next) {
        return;
      }
      StorageInitializer.writePreference(
        StorageInitializer.prefThemeModeKey,
        next.name,
      );
    });

    ref.listen<AsyncValue<bool>>(isOnlineStreamProvider, (previous, next) {
      final becameOnline =
          previous?.valueOrNull == false && next.valueOrNull == true;
      if (becameOnline && ref.read(authControllerProvider) is AuthAuthenticated) {
        ref.read(syncServiceProvider).flushQueue().then((syncedCount) {
          if (syncedCount > 0) {
            ref.invalidate(feedbackListControllerProvider);
            ref.invalidate(challengesControllerProvider);
          }
        });
      }
    });

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
