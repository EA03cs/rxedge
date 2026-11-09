import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/app/l10n/l10n.dart';
import 'package:rxedge/core/utils/result.dart';
import 'package:rxedge/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:rxedge/features/notifications/domain/entities/notification_entities.dart';
import 'package:rxedge/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:rxedge/features/notifications/presentation/screens/notifications_screen.dart';

class MockNotificationsRepository extends Mock implements NotificationsRepository {}

void main() {
  late MockNotificationsRepository mockRepo;

  final sampleUnread = NotificationItemEntity(
    id: 'n_unread_1',
    type: NotificationType.feedbackReply,
    title: 'Marketing Reply Received',
    body: 'Dr. Kareem replied to your report',
    timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
    isRead: false,
    targetRoute: '/feedback',
  );

  final sampleRead = NotificationItemEntity(
    id: 'n_read_2',
    type: NotificationType.newChallenge,
    title: 'Cardio Blitz Active',
    body: 'Complete milestones before deadline',
    timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    isRead: true,
    targetRoute: '/challenges',
  );

  setUp(() {
    mockRepo = MockNotificationsRepository();
    when(() => mockRepo.markAsRead(any())).thenAnswer((_) async => const Result.success(null));
    when(() => mockRepo.markAllAsRead()).thenAnswer((_) async => const Result.success(null));
  });

  Widget buildTestWidget({List<NotificationItemEntity> items = const []}) {
    when(() => mockRepo.getNotifications()).thenAnswer((_) async => Result.success(items));

    return ProviderScope(
      overrides: [
        notificationsRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: const MaterialApp(
        themeMode: ThemeMode.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: NotificationsScreen(),
      ),
    );
  }

  group('NotificationsScreen Widget Tests', () {
    testWidgets('renders notifications list and marks all read on action tap', (tester) async {
      await tester.pumpWidget(buildTestWidget(items: [sampleUnread, sampleRead]));
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Marketing Reply Received'), findsOneWidget);
      expect(find.text('Cardio Blitz Active'), findsOneWidget);
      expect(find.text('Mark all as read'), findsOneWidget);

      await tester.tap(find.text('Mark all as read'));
      await tester.pumpAndSettle();

      verify(() => mockRepo.markAllAsRead()).called(1);
    });

    testWidgets('renders empty state when no notifications exist', (tester) async {
      await tester.pumpWidget(buildTestWidget(items: const []));
      await tester.pumpAndSettle();

      expect(find.text('All Caught Up'), findsOneWidget);
      expect(find.text('You have reviewed all clinical updates, quiz deadlines, and marketing messages.'), findsOneWidget);
    });
  });
}
