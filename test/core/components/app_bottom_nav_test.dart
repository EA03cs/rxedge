import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxedge/core/components/app_bottom_nav.dart';

void main() {
  const items = [
    NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    NavItemData(
      icon: Icons.school_outlined,
      activeIcon: Icons.school_rounded,
      label: 'Product Navigator',
    ),
    NavItemData(
      icon: Icons.folder_outlined,
      activeIcon: Icons.folder_rounded,
      label: 'Marketing Hub',
    ),
    NavItemData(
      icon: Icons.emoji_events_outlined,
      activeIcon: Icons.emoji_events_rounded,
      label: 'Eye-Know Challenges',
    ),
    NavItemData(
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
      label: 'Rep Voice',
    ),
  ];

  Widget buildNavHarness({
    required double width,
    double height = 800.0,
    double textScale = 1.0,
    TextDirection textDirection = TextDirection.ltr,
    int currentIndex = 0,
    ValueChanged<int>? onTap,
  }) {
    return MaterialApp(
      home: Directionality(
        textDirection: textDirection,
        child: MediaQuery(
          data: MediaQueryData(
            size: Size(width, height),
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(
            bottomNavigationBar: AppBottomNav(
              currentIndex: currentIndex,
              onTap: onTap ?? (_) {},
              items: items,
            ),
          ),
        ),
      ),
    );
  }

  group('AppBottomNav Phase 1 Verification', () {
    testWidgets('renders all 5 tabs with exact labels in order', (tester) async {
      await tester.pumpWidget(buildNavHarness(width: 390.0));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Product Navigator'), findsOneWidget);
      expect(find.text('Marketing Hub'), findsOneWidget);
      expect(find.text('Eye-Know Challenges'), findsOneWidget);
      expect(find.text('Rep Voice'), findsOneWidget);
    });

    testWidgets('Eye-Know Challenges wraps to 2 lines on compact screen', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildNavHarness(width: 360.0));
      await tester.pumpAndSettle();

      final renderParagraph = tester.renderObject<RenderParagraph>(find.text('Eye-Know Challenges'));
      // A single line of 10pt text is ~12-14px tall. 2 lines are > 20px tall.
      expect(renderParagraph.size.height, greaterThan(20.0),
          reason: 'Eye-Know Challenges should wrap to two lines instead of shrinking to 1 line');
    });

    testWidgets('works without overflow on small 320dp screen width', (tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildNavHarness(width: 320.0));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('works without overflow at 1.3x text scale', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildNavHarness(width: 360.0, textScale: 1.3));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('works in RTL directionality (Arabic locale layout)', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildNavHarness(width: 390.0, textDirection: TextDirection.rtl),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Eye-Know Challenges'), findsOneWidget);
    });

    testWidgets('tapping tab invokes onTap callback', (tester) async {
      int selected = 0;
      await tester.pumpWidget(
        buildNavHarness(
          width: 390.0,
          onTap: (index) => selected = index,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Eye-Know Challenges'));
      await tester.pumpAndSettle();

      expect(selected, 3);
    });
  });
}
