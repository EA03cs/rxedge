import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/app/l10n/l10n.dart';
import 'package:rxedge/app/theme/theme.dart';
import 'package:rxedge/core/error/failures.dart';
import 'package:rxedge/core/utils/result.dart';
import 'package:rxedge/features/app_info/data/repositories/app_info_repository_impl.dart';
import 'package:rxedge/features/app_info/domain/entities/app_info_entity.dart';
import 'package:rxedge/features/app_info/domain/repositories/app_info_repository.dart';
import 'package:rxedge/features/app_info/presentation/screens/app_info_screen.dart';

class MockAppInfoRepository extends Mock implements AppInfoRepository {}

void main() {
  late MockAppInfoRepository mockRepository;

  final testEntity = AppInfoEntity(
    appName: 'RxEdge Medical Suite',
    version: '2.4.0',
    buildNumber: '108',
    environment: 'production',
    apiEndpoint: 'https://api.rxedge.internal/v1',
    minSupportedVersion: '2.0.0',
    maintenanceMode: false,
    serverTimestamp: DateTime(2026, 11, 9, 10, 0),
  );

  setUp(() {
    mockRepository = MockAppInfoRepository();
  });

  Widget buildTestableScreen(Widget child) {
    return ProviderScope(
      overrides: [
        appInfoRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: MaterialApp(
        theme: RxTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  group('AppInfoScreen Widget Tests', () {
    testWidgets('renders loading skeleton then populates metadata', (WidgetTester tester) async {
      when(() => mockRepository.getAppInfo(forceRefresh: any(named: 'forceRefresh')))
          .thenAnswer((_) async => Result.success(testEntity));

      await tester.pumpWidget(buildTestableScreen(const AppInfoScreen()));

      // Initially renders loading skeleton before pump settled
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verifies data displayed accurately
      expect(find.text('System Diagnostics'), findsOneWidget);
      expect(find.text('RxEdge Medical Suite'), findsOneWidget);
      expect(find.text('v2.4.0 (Build 108)'), findsOneWidget);
      expect(find.text('PRODUCTION'), findsOneWidget);
      expect(find.text('Operational'), findsOneWidget);
      expect(find.text('Refresh System Status'), findsOneWidget);
    });

    testWidgets('renders ErrorState when repository fails and allows retry', (WidgetTester tester) async {
      when(() => mockRepository.getAppInfo(forceRefresh: false))
          .thenAnswer((_) async => const Result.failure(NetworkFailure(debugMessage: 'Offline')));
      when(() => mockRepository.getAppInfo(forceRefresh: true))
          .thenAnswer((_) async => Result.success(testEntity));

      await tester.pumpWidget(buildTestableScreen(const AppInfoScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verifies error state presentation
      expect(find.text('Unable to Load Diagnostics'), findsOneWidget);
      expect(find.text('Retry Connection'), findsOneWidget);

      // Tap retry button
      await tester.tap(find.text('Retry Connection'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verifies refreshed to success
      expect(find.text('RxEdge Medical Suite'), findsOneWidget);
    });
  });
}
