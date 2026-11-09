import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxedge/features/notifications/data/datasources/notifications_local_datasource.dart';
import 'package:rxedge/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:rxedge/features/notifications/data/models/notification_dto.dart';
import 'package:rxedge/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:rxedge/features/notifications/domain/entities/notification_entities.dart';

class MockNotificationsRemoteDatasource extends Mock implements NotificationsRemoteDatasource {}

class MockNotificationsLocalDatasource extends Mock implements NotificationsLocalDatasource {}

void main() {
  late MockNotificationsRemoteDatasource mockRemote;
  late MockNotificationsLocalDatasource mockLocal;
  late NotificationsRepositoryImpl repository;

  final sampleNotifDto = NotificationDto(
    id: 'n_1',
    typeString: 'newMaterial',
    title: 'Cardura XL Monograph Added',
    body: 'Available for offline download',
    timestampIso: DateTime(2026, 11, 9, 10, 0).toIso8601String(),
    isRead: false,
  );

  setUp(() {
    mockRemote = MockNotificationsRemoteDatasource();
    mockLocal = MockNotificationsLocalDatasource();
    repository = NotificationsRepositoryImpl(
      remoteDatasource: mockRemote,
      localDatasource: mockLocal,
    );
  });

  group('NotificationsRepositoryImpl Tests', () {
    test('getNotifications returns cached items when present', () async {
      when(() => mockLocal.getCachedNotifications()).thenAnswer((_) async => [sampleNotifDto]);

      final result = await repository.getNotifications();

      expect(result.isSuccess, isTrue);
      result.when(
        success: (list) {
          expect(list.length, 1);
          expect(list.first.title, 'Cardura XL Monograph Added');
          expect(list.first.type, NotificationType.newMaterial);
        },
        failure: (_) => fail('Expected success'),
      );
      verifyZeroInteractions(mockRemote);
    });

    test('markAsRead updates item state', () async {
      when(() => mockLocal.markAsRead('n_1')).thenAnswer((_) async {});

      final result = await repository.markAsRead('n_1');

      expect(result.isSuccess, isTrue);
      verify(() => mockLocal.markAsRead('n_1')).called(1);
    });

    test('markAllAsRead updates all items to read', () async {
      when(() => mockLocal.markAllAsRead()).thenAnswer((_) async {});

      final result = await repository.markAllAsRead();

      expect(result.isSuccess, isTrue);
      verify(() => mockLocal.markAllAsRead()).called(1);
    });
  });
}
