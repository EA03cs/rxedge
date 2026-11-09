import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/app/l10n/l10n.dart';
import 'package:rxedge/core/components/coach_marks_sheet.dart';
import 'package:rxedge/core/storage/secure_storage_service.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockSecureStorageService mockStorage;

  setUp(() {
    mockStorage = MockSecureStorageService();
    when(() => mockStorage.read('rxedge_coach_marks_completed'))
        .thenAnswer((_) async => null);
    when(() => mockStorage.write('rxedge_coach_marks_completed', 'true'))
        .thenAnswer((_) async {});
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        secureStorageServiceProvider.overrideWithValue(mockStorage),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CoachMarksSheet(),
        ),
      ),
    );
  }

  group('CoachMarksSheet Component Tests', () {
    testWidgets('cycles through slides and finishes on Got It', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Slide 1
      expect(find.text('Instant Detailing Review'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Advance to Slide 2
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Reliable Offline Library'), findsOneWidget);

      // Advance to Slide 3
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Direct Voice to Marketing'), findsOneWidget);
      expect(find.text('Got It'), findsOneWidget);

      // Finish
      await tester.tap(find.text('Got It'));
      await tester.pumpAndSettle();

      verify(() => mockStorage.write('rxedge_coach_marks_completed', 'true')).called(1);
    });

    testWidgets('tapping Skip immediately marks completed', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Skip'), findsOneWidget);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      verify(() => mockStorage.write('rxedge_coach_marks_completed', 'true')).called(1);
    });

    testWidgets('renders cleanly without overflow in constrained height viewport', (tester) async {
      await tester.binding.setSurfaceSize(const Size(592, 288));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(CoachMarksSheet), findsOneWidget);
    });
  });
}
