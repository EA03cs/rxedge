import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/widgets/widgets.dart';
import '../../features/app_info/presentation/screens/app_info_screen.dart';
import '../../features/design_system/presentation/design_system_showcase_screen.dart';
import '../l10n/l10n.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// App Route Paths
abstract final class AppRoutes {
  static const String home = '/';
  static const String detailing = '/detailing';
  static const String products = '/products';
  static const String modules = '/modules';
  static const String schedule = '/schedule';
  static const String profile = '/profile';
  static const String showcase = '/showcase';
  static const String appInfo = '/app-info';
}

/// Router Provider supporting deep linking and auth redirect guard
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.showcase,
    debugLogDiagnostics: false,
    routes: [
      // Standalone full-screen routes
      GoRoute(
        path: AppRoutes.showcase,
        name: 'design_showcase',
        builder: (context, state) => const DesignSystemShowcaseScreen(),
      ),
      GoRoute(
        path: AppRoutes.appInfo,
        name: 'app_info',
        builder: (context, state) => const AppInfoScreen(),
      ),

      // 5-Tab StatefulShellRoute for Field Representatives
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final l10n = context.l10n;
          return AppScaffold(
            body: navigationShell,
            bottomNavigationBar: AppBottomNav(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) => navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              ),
              items: [
                NavItemData(icon: LucideIcons.fileText, label: l10n.navHome),
                NavItemData(icon: LucideIcons.pill, label: l10n.navProducts),
                NavItemData(icon: LucideIcons.graduationCap, label: l10n.navLearning, badge: '2'),
                NavItemData(icon: LucideIcons.calendar, label: l10n.navSchedule),
                NavItemData(icon: LucideIcons.user, label: l10n.navProfile),
              ],
            ),
          );
        },
        branches: [
          // 1. Detailing Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.detailing,
                builder: (context, state) => const DesignSystemShowcaseScreen(),
              ),
            ],
          ),
          // 2. Products Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.products,
                builder: (context, state) => const _TabPlaceholderScreen(title: 'Products'),
              ),
            ],
          ),
          // 3. Modules Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.modules,
                builder: (context, state) => const _TabPlaceholderScreen(title: 'Learning Modules'),
              ),
            ],
          ),
          // 4. Schedule Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.schedule,
                builder: (context, state) => const _TabPlaceholderScreen(title: 'Doctor Visits Schedule'),
              ),
            ],
          ),
          // 5. Profile Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const AppInfoScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _TabPlaceholderScreen extends StatelessWidget {
  final String title;
  const _TabPlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
