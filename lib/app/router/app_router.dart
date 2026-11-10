import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/widgets/widgets.dart';
import '../../features/app_info/presentation/screens/app_info_screen.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/challenges/presentation/screens/challenges_screen.dart';
import '../../features/design_system/presentation/design_system_showcase_screen.dart';
import '../../features/feedback/presentation/screens/feedback_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/learn/presentation/screens/learn_screen.dart';
import '../../features/library/presentation/screens/library_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../l10n/l10n.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// App Route Paths
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';

  // 5 Main Tabs
  static const String home = '/home';
  static const String learn = '/learn';
  static const String library = '/library';
  static const String challenges = '/challenges';
  static const String feedback = '/feedback';

  // Overlays & Secondary Screens
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String search = '/search';

  // System & Design System
  static const String showcase = '/showcase';
  static const String appInfo = '/app-info';
}

/// Listenable that notifies GoRouter when AuthState changes
class AuthStateListenable extends ChangeNotifier {
  AuthStateListenable(Ref ref) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      notifyListeners();
    });
  }
}

/// Router Provider supporting deep linking, auth redirect guard, and tab state preservation
final routerProvider = Provider<GoRouter>((ref) {
  final authListenable = AuthStateListenable(ref);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: authListenable,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final location = state.matchedLocation;

      // Allow direct access to Design System Showcase and Diagnostics in dev
      if (location == AppRoutes.showcase || location == AppRoutes.appInfo) {
        return null;
      }

      switch (authState) {
        case AuthInitial():
          return location == AppRoutes.splash ? null : AppRoutes.splash;

        case AuthNeedsOnboarding():
          return location == AppRoutes.onboarding ? null : AppRoutes.onboarding;

        case AuthUnauthenticated():
          if (location == AppRoutes.login || location == AppRoutes.forgotPassword) {
            return null;
          }
          return AppRoutes.login;

        case AuthAuthenticating():
          return null;

        case AuthAuthenticated():
          if (location == AppRoutes.login ||
              location == AppRoutes.splash ||
              location == AppRoutes.onboarding) {
            return AppRoutes.home;
          }
          return null;
      }
    },
    routes: [
      // 1. Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // 2. Onboarding Screen
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // 3. Login Screen
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // 4. Forgot Password Screen
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot_password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // 5. System Showcase & Diagnostics
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

      // Secondary Feature Screens
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.search,
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),

      // 6. 5-Tab StatefulShellRoute (Home, Learn, Library, Challenges, Feedback)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final l10n = context.l10n;
          return AppScaffold(
            body: ConnectivityBanner(child: navigationShell),
            bottomNavigationBar: AppBottomNav(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) => navigationShell.goBranch(
                index,
                initialLocation: index == 0 || index == navigationShell.currentIndex,
              ),
              items: [
                NavItemData(icon: LucideIcons.home, label: l10n.tabHome),
                NavItemData(icon: LucideIcons.graduationCap, label: l10n.tabLearn),
                NavItemData(icon: LucideIcons.bookOpen, label: l10n.tabLibrary),
                NavItemData(icon: LucideIcons.award, label: l10n.tabChallenges, badge: '🔥'),
                NavItemData(icon: LucideIcons.messageSquare, label: l10n.tabFeedback),
              ],
            ),
          );
        },
        branches: [
          // Tab 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Tab 1: Learn
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.learn,
                name: 'learn',
                builder: (context, state) => const LearnScreen(),
              ),
            ],
          ),
          // Tab 2: Library
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.library,
                name: 'library',
                builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),
          // Tab 3: Challenges
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.challenges,
                name: 'challenges',
                builder: (context, state) => const ChallengesScreen(),
              ),
            ],
          ),
          // Tab 4: Feedback
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.feedback,
                name: 'feedback',
                builder: (context, state) => const FeedbackScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
