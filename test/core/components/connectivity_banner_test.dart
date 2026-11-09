import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxedge/app/l10n/l10n.dart';
import 'package:rxedge/core/components/connectivity_banner.dart';

void main() {
  Widget buildTestWidget({required bool isOffline}) {
    return ProviderScope(
      overrides: [
        isOfflineProvider.overrideWith((ref) => isOffline),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ConnectivityBanner(
            child: Center(child: Text('Main Screen Content')),
          ),
        ),
      ),
    );
  }

  group('ConnectivityBanner Component Tests', () {
    testWidgets('renders main content normally when online', (tester) async {
      await tester.pumpWidget(buildTestWidget(isOffline: false));
      await tester.pumpAndSettle();

      expect(find.text('Main Screen Content'), findsOneWidget);
      expect(find.text('Offline mode — displaying cached materials and lessons.'), findsNothing);
    });

    testWidgets('renders offline banner when offline', (tester) async {
      await tester.pumpWidget(buildTestWidget(isOffline: true));
      await tester.pumpAndSettle();

      expect(find.text('Main Screen Content'), findsOneWidget);
      expect(find.text('Offline mode — displaying cached materials and lessons.'), findsOneWidget);
    });
  });
}
