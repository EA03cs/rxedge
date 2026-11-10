import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:rxedge/core/components/components.dart';
import 'package:rxedge/core/config/flavor_config.dart';
import 'package:rxedge/core/localization/app_locale_provider.dart';
import 'package:rxedge/core/theme/theme.dart';
import 'package:rxedge/features/design_system/presentation/design_system_showcase_screen.dart';
import 'package:rxedge/l10n/app_localizations.dart';

void main() {
  setUpAll(() {
    FlavorConfig.initialize(
      flavor: AppFlavor.dev,
      appName: 'RxEdge (Test)',
      apiBaseUrl: 'https://api-dev.rxedge.internal/v1',
    );
  });
  group('App Bootstrap & Showcase Screen Tests', () {
    testWidgets('RxEdge boots with Riverpod and displays Showcase', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: RxTheme.light(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const DesignSystemShowcaseScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify app title and showcase title appear
      expect(find.text('RxEdge'), findsOneWidget);
      expect(find.text('Design System Foundation'), findsOneWidget);

      // Verify core components exist in the showcase
      expect(find.text('Buttons'), findsOneWidget);
      expect(find.text('Input Fields'), findsOneWidget);
      expect(find.text('Surface Cards'), findsOneWidget);
      expect(find.text('Status Badges'), findsOneWidget);

      // Verify Bottom Navigation items exist
      expect(find.byType(AppBottomNav), findsOneWidget);
      expect(find.text('Detailing'), findsOneWidget);
      expect(find.text('Products'), findsOneWidget);
      expect(find.text('Modules'), findsOneWidget);
    });

    testWidgets('Theme and Locale toggles update state dynamically', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) {
              final activeLocale = ref.watch(localeProvider);
              final activeThemeMode = ref.watch(themeModeProvider);
              return MaterialApp(
                locale: activeLocale,
                themeMode: activeThemeMode,
                theme: RxTheme.light(isArabic: activeLocale.languageCode == 'ar'),
                darkTheme: RxTheme.dark(isArabic: activeLocale.languageCode == 'ar'),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const DesignSystemShowcaseScreen(),
              );
            },
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check initial RTL / Arabic (default)
      expect(container.read(localeProvider), const Locale('ar'));
      expect(container.read(themeModeProvider), ThemeMode.light);

      // Tap Language toggle button to switch to English (LTR)
      final langButton = find.text('EN');
      expect(langButton, findsOneWidget);
      await tester.tap(langButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Now locale is English
      expect(container.read(localeProvider), const Locale('en'));

      // Tap Theme toggle button to switch to Dark Mode
      final themeButton = find.byIcon(LucideIcons.moon);
      expect(themeButton, findsOneWidget);
      await tester.tap(themeButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Now theme is Dark
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });
  });

  group('Foundation Component Tests', () {
    testWidgets('AppButton variants, sizing, and loading state', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: RxTheme.light(),
          home: Scaffold(
            body: Column(
              children: [
                AppButton(
                  text: 'Primary Action',
                  onPressed: () => tapped = true,
                ),
                const AppButton(
                  text: 'Loading Action',
                  isLoading: true,
                ),
                const AppButton(
                  text: 'Secondary Action',
                  variant: AppButtonVariant.secondary,
                ),
                const AppButton(
                  text: 'Destructive Action',
                  variant: AppButtonVariant.destructive,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Primary Action'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Secondary Action'), findsOneWidget);
      expect(find.text('Destructive Action'), findsOneWidget);

      await tester.tap(find.text('Primary Action'));
      expect(tapped, isTrue);
    });

    testWidgets('AppTextField renders label, helper, error, and clearable text', (WidgetTester tester) async {
      final controller = TextEditingController(text: 'Initial Query');

      await tester.pumpWidget(
        MaterialApp(
          theme: RxTheme.light(),
          home: Scaffold(
            body: AppTextField(
              label: 'Search Product',
              hint: 'Type here...',
              helperText: 'Enter trade or generic name',
              controller: controller,
              clearable: true,
            ),
          ),
        ),
      );

      expect(find.text('Search Product'), findsOneWidget);
      expect(find.text('Initial Query'), findsOneWidget);
      expect(find.text('Enter trade or generic name'), findsOneWidget);

      // Verify clear button works
      expect(find.byIcon(LucideIcons.x), findsOneWidget);
      await tester.tap(find.byIcon(LucideIcons.x));
      await tester.pump();
      expect(controller.text, isEmpty);
    });

    testWidgets('AppCard handles onTap and variant styling', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: RxTheme.light(),
          home: Scaffold(
            body: AppCard(
              onTap: () => tapped = true,
              child: const Text('Detailing Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Detailing Card Content'), findsOneWidget);
      await tester.tap(find.text('Detailing Card Content'));
      expect(tapped, isTrue);
    });

    testWidgets('AppChip toggles selection state', (WidgetTester tester) async {
      bool isSelected = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              theme: RxTheme.light(),
              home: Scaffold(
                body: AppChip(
                  label: 'Cardiology',
                  isSelected: isSelected,
                  onSelected: (val) => setState(() => isSelected = val),
                ),
              ),
            );
          },
        ),
      );

      expect(find.text('Cardiology'), findsOneWidget);
      await tester.tap(find.text('Cardiology'));
      await tester.pump();
      expect(isSelected, isTrue);
    });

    testWidgets('EmptyState displays microcopy and invokes CTA', (WidgetTester tester) async {
      bool ctaTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: RxTheme.light(),
          home: Scaffold(
            body: EmptyState(
              title: 'No scientific materials found',
              description: 'There are no approved materials matching this territory.',
              actionText: 'Browse Library',
              onAction: () => ctaTriggered = true,
            ),
          ),
        ),
      );

      expect(find.text('No scientific materials found'), findsOneWidget);
      expect(find.text('There are no approved materials matching this territory.'), findsOneWidget);
      expect(find.text('Browse Library'), findsOneWidget);

      await tester.tap(find.text('Browse Library'));
      expect(ctaTriggered, isTrue);
    });

    testWidgets('ErrorState renders plain message and triggers retry', (WidgetTester tester) async {
      bool retryTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: RxTheme.light(),
          home: Scaffold(
            body: ErrorState(
              title: 'Unable to load detailing card',
              description: 'Please check your connection and try again.',
              retryText: 'Try Again',
              onRetry: () => retryTriggered = true,
            ),
          ),
        ),
      );

      expect(find.text('Unable to load detailing card'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      expect(retryTriggered, isTrue);
    });

    testWidgets('OfflineBanner displays message and retry action', (WidgetTester tester) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: RxTheme.light(),
          home: Scaffold(
            body: OfflineBanner(
              message: "You're offline. Changes are saved locally.",
              onRetry: () => retryPressed = true,
            ),
          ),
        ),
      );

      expect(find.text("You're offline. Changes are saved locally."), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(retryPressed, isTrue);
    });

    testWidgets('ProgressRing and ProgressBar render properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: RxTheme.light(),
          home: const Scaffold(
            body: Column(
              children: [
                ProgressRing(value: 0.75),
                ProgressBar(
                  value: 0.60,
                  label: 'Territory Coverage',
                  trailingText: '60%',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('75%'), findsOneWidget);
      expect(find.text('Territory Coverage'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
    });

    testWidgets('StatusBadge displays correct label and respects variants', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: RxTheme.light(),
          home: const Scaffold(
            body: Column(
              children: [
                StatusBadge(
                  label: 'Approved (Phase III)',
                  variant: StatusBadgeVariant.success,
                  showDot: true,
                ),
                StatusBadge(
                  label: 'Streak: 7 Days 🔥 (350 Pts)',
                  variant: StatusBadgeVariant.accent,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Approved (Phase III)'), findsOneWidget);
      expect(find.text('Streak: 7 Days 🔥 (350 Pts)'), findsOneWidget);
    });
  });

  group('RTL & Localization Verification', () {
    testWidgets('RTL directionality is verified when Arabic locale is loaded', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: RxTheme.light(isArabic: true),
          home: Builder(
            builder: (context) {
              final isRtl = Directionality.of(context) == TextDirection.rtl;
              return Scaffold(
                body: Text(
                  isRtl ? 'RTL_CONFIRMED' : 'LTR',
                ),
              );
            },
          ),
        ),
      );

      await tester.pump();
      expect(find.text('RTL_CONFIRMED'), findsOneWidget);
    });
  });
}
